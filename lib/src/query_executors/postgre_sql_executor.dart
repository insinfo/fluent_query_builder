import 'dart:async';
import 'query_executor.dart';
import 'package:logging/logging.dart';
import 'package:pool/pool.dart';
import 'package:postgres/postgres.dart';

/// A [QueryExecutor] that queries a PostgreSQL database.
class PostgreSqlExecutor implements QueryExecutor {
  final PostgreSQLExecutionContext _connection;

  /// An optional [Logger] to print information to.
  final Logger logger;

  PostgreSqlExecutor(this._connection, {this.logger});

  /// The underlying connection.
  PostgreSQLExecutionContext get connection => _connection;

  /// Closes the connection.
  Future close() {
    if (_connection is PostgreSQLConnection) {
      return (_connection as PostgreSQLConnection).close();
    } else {
      return Future.value();
    }
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues, [List<String> returningFields]) {
    if (returningFields != null) {
      var fields = returningFields.join(', ');
      var returning = 'RETURNING $fields';
      query = '$query $returning';
    }

    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');

    return _connection.query(query, substitutionValues: substitutionValues);
  }

  Future<int> execute(String query, {Map<String, dynamic> substitutionValues}) {
    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');
    return _connection.execute(query, substitutionValues: substitutionValues);
  }

  Future<List<Map<String, Map<String, dynamic>>>> mappedResultsQuery(String query,
      {Map<String, dynamic> substitutionValues}) {
    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');
    return _connection.mappedResultsQuery(query, substitutionValues: substitutionValues);
  }

  //Use generic function type syntax for parameters.
  //Future<dynamic> f(QueryExecutor connection)
  Future<dynamic> simpleTransaction(Future<dynamic> Function(QueryExecutor) f) async {
    logger?.fine('Entering simpleTransaction');
    if (_connection is! PostgreSQLConnection) {
      return await f(this);
    }

    final conn = _connection as PostgreSQLConnection;
    var returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = PostgreSqlExecutor(ctx, logger: logger);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is PostgreSQLRollback) {
      if (txResult.reason == null) {
        throw StateError('The transaction was cancelled.');
      } else {
        throw StateError('The transaction was cancelled with reason "${txResult.reason}".');
      }
    } else {
      return returnValue;
    }
  }

  @override
  Future<T> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (_connection is! PostgreSQLConnection) return await f(this);

    var conn = _connection as PostgreSQLConnection;
    T returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = PostgreSqlExecutor(ctx, logger: logger);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is PostgreSQLRollback) {
      if (txResult.reason == null) {
        throw StateError('The transaction was cancelled.');
      } else {
        throw StateError('The transaction was cancelled with reason "${txResult.reason}".');
      }
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
  final PostgreSQLConnection Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger logger;

  final List<PostgreSqlExecutor> _connections = [];
  int _index = 0;
  final Pool _pool, _connMutex = Pool(1);
  List<String> schemes = ['public'];

  PostgreSqlExecutorPool(this.size, this.connectionFactory, {this.logger, this.schemes}) : _pool = Pool(size) {
    assert(size > 0, 'Connection pool cannot be empty.');
  }

  /// Closes all connections.
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
          final conn = connectionFactory();

          final executor = await conn.open().then((_) => PostgreSqlExecutor(conn, logger: logger));

          //isso executa uma query para definir os esquemas
          if (schemes != null && schemes.isNotEmpty) {
            final schs = schemes.map((i) => '"$i"').toList().join(', ');
            await executor.query('set search_path to $schs;', {});
          }

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
      return _connections[_index++];
    });
  }

  Future<List<Map<String, Map<String, dynamic>>>> mappedResultsQuery(String query,
      {Map<String, dynamic> substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.mappedResultsQuery(query, substitutionValues: substitutionValues);
    });
  }

  Future<int> execute(String query, {Map<String, dynamic> substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.execute(query, substitutionValues: substitutionValues);
    });
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues, [List<String> returningFields]) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues, returningFields);
    });
  }

  @override
  Future<T> transaction<T>(FutureOr<T> Function(QueryExecutor) f) {
    return _pool.withResource(() async {
      var executor = await _next();
      return executor.transaction(f);
    });
  }
}
