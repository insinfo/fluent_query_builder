import 'dart:async';
import 'package:postgres/postgres.dart';

import '../../fluent_query_builder.dart';
import 'query_executor.dart';
import 'package:logging/logging.dart';
import 'package:pool/pool.dart';
//import 'package:galileo_postgres/galileo_postgres.dart';

/// A [QueryExecutor] that queries a PostgreSQL database.
class PostgreSqlExecutor extends QueryExecutor<PostgreSQLExecutionContext> {
  @override
  PostgreSQLExecutionContext? connection;

  /// An optional [Logger] to print information to.
  final Logger? logger;
  DBConnectionInfo connectionInfo;

  PostgreSqlExecutor(this.connectionInfo, {this.logger, this.connection});

  Future<void> reconnect() async {
    //  print('PostgreSqlExecutor@reconnect');
    await open();
  }

  String get schemesString =>
      connectionInfo.schemes!.map((i) => '"$i"').toList().join(', ');

  @override
  Future<void> open() async {
    connection = PostgreSQLConnection(
      connectionInfo.host,
      connectionInfo.port,
      connectionInfo.database,
      username: connectionInfo.username,
      password: connectionInfo.password,
      useSSL: connectionInfo.useSSL,
      timeoutInSeconds: connectionInfo.timeoutInSeconds,
    );
    //print( 'PostgreSqlExecutor@open timeoutInSeconds: ${connectionInfo!.timeoutInSeconds}');
    var com = connection as PostgreSQLConnection;
    await com.open();
    //isso executa uma query para definir os esquemas
    if (connectionInfo.enablePsqlAutoSetSearchPath == true &&
        connectionInfo.schemes?.isNotEmpty == true) {
      await query('set search_path to $schemesString;', {});
    }
    /* } else if (connection is PostgreSQLConnection) {
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
        if (connectionInfo?.enablePsqlAutoSetSearchPath == true &&
            connectionInfo?.schemes?.isNotEmpty == true) {
          await query('set search_path to $schemesString;', {});
        }
      }
    } else {
      await Future.value();
    }*/
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
  Future<bool> reconnectIfNecessary() async {
    try {
      await connection!.query('select true');
      return true;
    } catch (e) {
      //when the database restarts there is a loss of connection
      if ('$e'.contains('Cannot write to socket, it is closed') ||
          '$e'.contains('database connection closing')) {
        await reconnect();
        return true;
      }
      rethrow;
    }
  }

  @override
  Future<bool> isConnect() async {
    try {
      await connection!.query('select true');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<List>> query(
      String query, Map<String, dynamic> substitutionValuesInput,
      [List<String?>? returningFields]) async {
    if (returningFields?.isNotEmpty == true) {
      //if (returningFields != null) {
      var fields = returningFields!.join(', ');
      var returning = 'RETURNING $fields';
      query = '$query $returning';
    }

    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValuesInput');

    var substitutionValues = <String, dynamic>{};
    if (substitutionValuesInput.entries.isNotEmpty) {
      substitutionValuesInput.entries.forEach((item) {
        var key = item.key;
        var val = item.value;
        if (key.startsWith('"') && key.endsWith('"')) {
          key = key.substring(1, key.length - 1);
          query = query.replaceAll('@${item.key}', '@$key');
        }

        substitutionValues.addAll({key: val});
      });
    }

    //print('substitutionValues: $substitutionValues');
    //print('query: $query');

    List<List> results;

    try {
      results = await connection!.query(query,
          substitutionValues: substitutionValues,
          timeoutInSeconds: connectionInfo.timeoutInSeconds);
    } catch (e) {
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo.reconnectIfConnectionIsNotOpen == true &&
              '$e'.contains('connection is not open') ||
          '$e'.contains('database connection closing')) {
        await reconnect();
        results = await connection!
            .query(query, substitutionValues: substitutionValues);
      } else {
        rethrow;
      }
    }

    return results;
  }

  @override
  Future<List<Map<String, dynamic>>> getAsMap(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    var rows =
        await getAsMapWithMeta(query, substitutionValues: substitutionValues);

    final result = <Map<String, dynamic>>[];
    if (rows.isNotEmpty) {
      for (var item in rows) {
        //Combine/merge multiple maps into 1 map
        result.add(item.values.reduce((map1, map2) => map1..addAll(map2)));
      }
    }
    return result;
  }

  @override
  Future<int> execute(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');

    var results;
    try {
      results = await connection!.execute(query,
          substitutionValues: substitutionValues,
          timeoutInSeconds: connectionInfo.timeoutInSeconds);
    } catch (e) {
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo.reconnectIfConnectionIsNotOpen == true &&
              '$e'.contains('connection is not open') ||
          '$e'.contains('database connection closing')) {
        await reconnect();
        results = await connection!.execute(query,
            substitutionValues: substitutionValues,
            timeoutInSeconds: connectionInfo.timeoutInSeconds);
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
      results = await connection!.mappedResultsQuery(query,
          substitutionValues: substitutionValues,
          timeoutInSeconds: connectionInfo.timeoutInSeconds);
    } catch (e) {
      //reconnect in Error
      //PostgreSQLSeverity.error : Attempting to execute query, but connection is not open.
      if (connectionInfo.reconnectIfConnectionIsNotOpen == true &&
              '$e'.contains('connection is not open') ||
          '$e'.contains('database connection closing')) {
        await reconnect();
        results = await connection!.mappedResultsQuery(query,
            substitutionValues: substitutionValues,
            timeoutInSeconds: connectionInfo.timeoutInSeconds);
      } else {
        rethrow;
      }
    }
    return results;
  }

  //Use generic function type syntax for parameters.
  //Future<dynamic> f(QueryExecutor connection)
  Future<dynamic> simpleTransaction(
      Future<dynamic> Function(QueryExecutor) f) async {
    logger?.fine('Entering simpleTransaction');
    if (connection is! PostgreSQLConnection) {
      return await f(this);
    }

    final conn = connection as PostgreSQLConnection;
    var returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx =
            PostgreSqlExecutor(connectionInfo, logger: logger, connection: ctx);
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
      throw StateError(
          'The transaction was cancelled with reason "${txResult.reason}".');
      //}
    } else {
      return returnValue;
    }
  }

  @override
  Future<QueryExecutor> startTransaction() async {
    await connection!.execute('begin');
    return this;
  }

  @override
  Future<void> commit() async {
    await connection!
        .execute('commit', timeoutInSeconds: connectionInfo.timeoutInSeconds);
  }

  @override
  Future<void> rollback() async {
    //await connection!.execute('rollback');
  }

  @override
  Future<T?> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (connection is! PostgreSQLConnection) return f(this);
    //print('PostgreSqlExecutor transaction');
    var conn = connection as PostgreSQLConnection;
    T? returnValue;

    var txResult = await conn.transaction((ctx) async {
      //print('PostgreSqlExecutor entering transaction');
      try {
        logger?.fine('Entering transaction');
        var tx =
            PostgreSqlExecutor(connectionInfo, logger: logger, connection: ctx);
        returnValue = await f(tx);
        //  print('PostgreSqlExecutor end transaction');
      } catch (e) {
        // print('PostgreSqlExecutor catch transaction');
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
        // print('PostgreSqlExecutor Exiting transactionn');
      }
    });

    if (txResult is PostgreSQLRollback) {
      /*if (txResult.reason == null) {
        throw StateError('The transaction was cancelled.');
      } else {*/
      throw StateError(
          'The transaction was cancelled with reason "${txResult.reason}".');
      //}
    } else {
      return returnValue;
    }
  }

  @override
  Future<dynamic> transaction2(
      Future<dynamic> Function(QueryExecutor) queryBlock,
      {int? commitTimeoutInSeconds}) async {
    var conn = connection as PostgreSQLConnection;
    var re = await conn.transaction((ctx) async {
      var tx =
          PostgreSqlExecutor(connectionInfo, logger: logger, connection: ctx);
      await queryBlock(tx);
    }, commitTimeoutInSeconds: commitTimeoutInSeconds);

    return re;
  }
}

/// A [QueryExecutor] that manages a pool of PostgreSQL connections.
class PostgreSqlExecutorPool extends QueryExecutor<PostgreSqlExecutor> {
  /// The maximum amount of concurrent connections.
  final int size;

  /// Creates a new [PostgreSQLConnection], on demand.
  ///
  /// The created connection should **not** be open.
  // final PostgreSQLConnection Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger? logger;

  @override
  final List<PostgreSqlExecutor> connections = [];

  int _index = 0;
  final Pool _pool, _connMutex = Pool(1);

  DBConnectionInfo connectionInfo;

  PostgreSqlExecutorPool(this.size, this.connectionInfo, {this.logger})
      : _pool = Pool(size) {
    assert(size > 0, 'Connection pool cannot be empty.');
  }

  /// Closes all connections.
  @override
  Future close() async {
    await _pool.close();
    await _connMutex.close();
    return Future.wait(connections.map((c) => c.close()));
  }

  Future _open() async {
    if (connections.isEmpty) {
      final listCon = await Future.wait(
        List.generate(size, (_) async {
          logger?.fine('Spawning connections...');

          final executor = PostgreSqlExecutor(connectionInfo, logger: logger);
          await executor.open();

          return executor;
        }),
      );
      connections.addAll(listCon);
    }
  }

  Future<PostgreSqlExecutor> _next() {
    return _connMutex.withResource(() async {
      await _open();
      if (_index >= size) _index = 0;
      var currentConnIdx = _index++;
      //print('PostgreSqlExecutorPool currentConnIdx $currentConnIdx ');
      return connections[currentConnIdx];
    });
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic>? substitutionValues,
      List<String>? returningFields}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMapWithMeta(query,
          substitutionValues: substitutionValues);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAsMap(String query,
      {Map<String, dynamic>? substitutionValues, returningFields}) async {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMap(query, substitutionValues: substitutionValues);
    });
  }

  @override
  Future<int> execute(String query,
      {Map<String, dynamic>? substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.execute(query, substitutionValues: substitutionValues);
    });
  }

  @override
  Future<List<List>> query(
      String query, Map<String, dynamic> substitutionValues,
      [List<String?>? returningFields]) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues, returningFields);
    });
  }

  @override
  Future<T?> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    return _pool.withResource(() async {
      var executor = await _next();
      return executor.transaction(f);
    });
  }

  @override
  Future<dynamic> transaction2(
      Future<dynamic> Function(QueryExecutor) queryBlock,
      {int? commitTimeoutInSeconds}) async {
    return _pool.withResource(() async {
      var executor = await _next();
      return executor.transaction2(queryBlock);
    });
  }

  @override
  Future reconnectIfNecessary() {
    throw UnimplementedError();
  }
}
