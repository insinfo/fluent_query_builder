import 'dart:async';
import '../../fluent_query_builder.dart';
import 'query_executor.dart';
import 'package:logging/logging.dart';
import 'package:pool/pool.dart';
import 'package:galileo_postgres/galileo_postgres.dart';

/// A [QueryExecutor] that queries a PostgreSQL database.
class PostgreSqlExecutor implements QueryExecutor {
  PostgreSQLExecutionContext? connection;

  /// An optional [Logger] to print information to.
  final Logger? logger;
  DBConnectionInfo? connectionInfo;

  PostgreSqlExecutor(this.connectionInfo, {this.logger, this.connection});

  Future<void> reconnect() async {
    await open();
  }

  String get schemesString => connectionInfo!.schemes!.map((i) => '"$i"').toList().join(', ');

  Future<void> open() async {
    if (connection is PostgreSQLConnection) {
      var com = connection as PostgreSQLConnection;
      if (com.isClosed) {
        connection = PostgreSQLConnection(
          connectionInfo!.host,
          connectionInfo!.port!,
          connectionInfo!.database,
          username: connectionInfo!.username,
          password: connectionInfo!.password,
        );
        com = connection as PostgreSQLConnection;
        await com.open();
        //isso executa uma query para definir os esquemas
        if (connectionInfo?.enablePsqlAutoSetSearchPath == true && connectionInfo?.schemes?.isNotEmpty == true) {
          await query('set search_path to $schemesString;', {});
        }
      }
    } else if (connection == null) {
      connection = PostgreSQLConnection(
        connectionInfo!.host,
        connectionInfo!.port!,
        connectionInfo!.database,
        username: connectionInfo!.username,
        password: connectionInfo!.password,
      );
      var com = connection as PostgreSQLConnection;
      await com.open();
      //isso executa uma query para definir os esquemas
      if (connectionInfo?.enablePsqlAutoSetSearchPath == true && connectionInfo?.schemes?.isNotEmpty == true) {
        await query('set search_path to $schemesString;', {});
      }
    } else {
      await Future.value();
    }

    //print('PostgreSqlExecutor@open connection ${connection}');
  }

  /// Closes the connection.
  @override
  Future<void> close() async {
    if (connection is PostgreSQLConnection) {
      await (connection as PostgreSQLConnection?)?.close();
    } else {
      await Future.value();
    }
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues,
      [List<String?>? returningFields]) async {
    if (returningFields?.isNotEmpty == true) {
      //if (returningFields != null) {
      var fields = returningFields!.join(', ');
      var returning = 'RETURNING $fields';
      query = '$query $returning';
    }

    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');
    //print('Query: $query');
    //print('Values: $substitutionValues');
    //print('Fields: $returningFields');
    List<List> results;
    //return _connection.query(query, substitutionValues: substitutionValues);

    try {
      results = await connection!.query(query, substitutionValues: substitutionValues);
    } catch (e) {
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo?.reconnectIfConnectionIsNotOpen == true && '$e'.contains('connection is not open')) {
        // print('PostgreSqlExecutor@query reconnect in Error');
        await reconnect();
        results = await connection!.query(query, substitutionValues: substitutionValues);
      } else {
        rethrow;
      }
    }

    return results;
  }

  @override
  Future<List<Map<String, dynamic>>> getAsMap(String query, {Map<String, dynamic>? substitutionValues}) async {
    var rows = await getAsMapWithMeta(query, substitutionValues: substitutionValues);

    final result = <Map<String, dynamic>>[];
    if (rows.isNotEmpty) {
      for (var item in rows) {
        //Combine/merge multiple maps into 1 map
        result.add(item.values.reduce((map1, map2) => map1..addAll(map2)));
      }
    }
    return result;
  }

  Future<int> execute(String query, {Map<String, dynamic>? substitutionValues}) async {
    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');

    var results;
    try {
      results = await connection!.execute(query, substitutionValues: substitutionValues);
    } catch (e) {
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo?.reconnectIfConnectionIsNotOpen == true && '$e'.contains('connection is not open')) {
        //print('PostgreSqlExecutor@execute reconnect in Error');
        await reconnect();
        results = await connection!.query(query, substitutionValues: substitutionValues);
      } else {
        rethrow;
      }
    }

    return results;
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');
    //return _connection.mappedResultsQuery(query, substitutionValues: substitutionValues);

    var results = <Map<String, Map<String, dynamic>>>[];
    try {
      results = await connection!.mappedResultsQuery(query, substitutionValues: substitutionValues);
    } catch (e) {
      // print('PostgreSqlExecutor@getAsMapWithMeta reconnect in Error  $e');
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo?.reconnectIfConnectionIsNotOpen == true && '$e'.contains('connection is not open')) {
        //print('PostgreSqlExecutor@getAsMapWithMeta reconnect in Error');
        await reconnect();
        results = await connection!.mappedResultsQuery(query, substitutionValues: substitutionValues);
      } else {
        rethrow;
      }
    }
    return results;
  }

  //Use generic function type syntax for parameters.
  //Future<dynamic> f(QueryExecutor connection)
  Future<dynamic> simpleTransaction(Future<dynamic> Function(QueryExecutor) f) async {
    logger?.fine('Entering simpleTransaction');
    if (connection is! PostgreSQLConnection) {
      return await f(this);
    }

    final conn = connection as PostgreSQLConnection;
    var returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = PostgreSqlExecutor(connectionInfo, logger: logger, connection: ctx);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is PostgreSQLRollback) {
      /*if (txResult.reason == null) {
        throw StateError('The transaction was cancelled.');
      } else {*/
      throw StateError('The transaction was cancelled with reason "${txResult.reason}".');
      //}
    } else {
      return returnValue;
    }
  }

  @override
  Future<T?> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (connection is! PostgreSQLConnection) return await f(this);

    var conn = connection as PostgreSQLConnection;
    T? returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = PostgreSqlExecutor(connectionInfo, logger: logger, connection: ctx);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is PostgreSQLRollback) {
      /*if (txResult.reason == null) {
        throw StateError('The transaction was cancelled.');
      } else {*/
      throw StateError('The transaction was cancelled with reason "${txResult.reason}".');
      //}
    } else {
      return returnValue;
    }
  }
}

/// A [QueryExecutor] that manages a pool of PostgreSQL connections.
class PostgreSqlExecutorPool implements QueryExecutor {
  /// The maximum amount of concurrent connections.
  final int size;

  /// Creates a new [PostgreSQLConnection], on demand.
  ///
  /// The created connection should **not** be open.
  // final PostgreSQLConnection Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger? logger;

  final List<PostgreSqlExecutor> _connections = [];
  int _index = 0;
  final Pool _pool, _connMutex = Pool(1);

  DBConnectionInfo? connectionInfo;

  PostgreSqlExecutorPool(this.size, this.connectionInfo, {this.logger}) : _pool = Pool(size) {
    assert(size > 0, 'Connection pool cannot be empty.');
  }

  /// Closes all connections.
  @override
  Future close() async {
    await _pool.close();
    await _connMutex.close();
    return Future.wait(_connections.map((c) => c.close()));
  }

  Future _open() async {
    if (_connections.isEmpty) {
      final listCon = await Future.wait(
        List.generate(size, (_) async {
          logger?.fine('Spawning connections...');

          final executor = PostgreSqlExecutor(connectionInfo, logger: logger);
          await executor.open();

          return executor;
        }),
      );
      _connections.addAll(listCon);
    }
  }

  Future<PostgreSqlExecutor> _next() {
    return _connMutex.withResource(() async {
      await _open();
      if (_index >= size) _index = 0;
      var currentConnIdx = _index++;
      //print('PostgreSqlExecutorPool currentConnIdx $currentConnIdx ');
      return _connections[currentConnIdx];
    });
  }

  @override
  Future<List<Map<String, Map<String?, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic>? substitutionValues, List<String>? returningFields}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMapWithMeta(query, substitutionValues: substitutionValues);
    });
  }

  @override
  Future<List<Map<String?, dynamic>>> getAsMap(String query,
      {Map<String, dynamic>? substitutionValues, returningFields}) async {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMap(query, substitutionValues: substitutionValues);
    });
  }

  Future<int> execute(String query, {Map<String, dynamic>? substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.execute(query, substitutionValues: substitutionValues);
    });
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues, [List<String?>? returningFields]) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues, returningFields);
    });
  }

  @override
  Future<T?> transaction<T>(FutureOr<T> Function(QueryExecutor) f) {
    return _pool.withResource(() async {
      var executor = await _next();
      return executor.transaction(f);
    });
  }
}
