import 'dart:async';

import 'package:pool/pool.dart';
import 'package:galileo_mysql/galileo_mysql.dart';
import '../models/exceptions.dart';
import 'query_executor.dart';
import 'package:logging/logging.dart';

import 'utils.dart';

class MySqlExecutor extends QueryExecutor {
  /// An optional [Logger] to write to.
  final Logger? logger;

  final MySqlConnection _connection;

  MySqlExecutor(this._connection, {this.logger});

  @override
  Future<void> close() {
    if (_connection is MySqlConnection) {
      return _connection.close();
    } else {
      return Future.value();
    }
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues, [List<String?>? returningFields]) {
    // Change @id -> ?
    for (var name in substitutionValues.keys) {
      query = query.replaceAll('@$name', '?');
    }

    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');

    //if (returningFields?.isNotEmpty != true) {
    return _connection
        .query(query, Utils.substitutionMapToList(substitutionValues))
        .then((results) => results.map((r) => r.toList()).toList());
    /*} else {
      return Future(() async {
        var tx = await _startTransaction();
        try {
          var writeResults = await tx.prepared(query, substitutionValues.values);
          var fieldSet = returningFields.map((s) => '`$s`').join(',');
          var fetchSql = 'select $fieldSet from $tableName where id = ?;';
          logger?.fine(fetchSql);
          var readResults = await tx.prepared(fetchSql, [writeResults.insertId]);
          var mapped = readResults.map((r) => r.toList()).toList();
          await tx.commit();
          return mapped;
        } catch (_) {
          await tx?.rollback();
          rethrow;
        }
      });
    }*/
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    // return rs.map((row) => row.toTableColumnMap()).toList();
    throw UnsupportedOperationException('mappedResultsQuery not implemented');
    //var rows = await this.query(query,substitutionValues);
  }

  Future<dynamic> simpleTransaction(Future<dynamic> Function(QueryExecutor) f) async {
    logger?.fine('Entering simpleTransaction');
    if (_connection is! MySqlConnection) {
      return await f(this);
    }

    final conn = _connection;
    var returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = MySqlExecutor(ctx, logger: logger);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is MySqlException) {
      /*//if (txResult.sqlState == null) {
        throw StateError('The transaction was cancelled.');
      } else {*/
      throw StateError('The transaction was cancelled with reason "${txResult.message}".');
      //}
    } else {
      return returnValue;
    }
  }

  @override
  Future<T?> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (_connection is! MySqlConnection) return await f(this);

    var conn = _connection;
    T? returnValue;

    var txResult = await conn.transaction((ctx) async {
      try {
        logger?.fine('Entering transaction');
        var tx = MySqlExecutor(ctx, logger: logger);
        returnValue = await f(tx);
      } catch (e) {
        ctx.cancelTransaction(reason: e.toString());
        rethrow;
      } finally {
        logger?.fine('Exiting transaction');
      }
    });

    if (txResult is MySqlException) {
      /*if (txResult.sqlState == null) {
        throw StateError('The transaction was cancelled.');
      } else {*/
      throw StateError('The transaction was cancelled with reason "${txResult.message}".');
      //}
    } else {
      return returnValue;
    }
  }

  @override
  Future<List<Map<String?, dynamic>>> getAsMap(String query, {Map<String, dynamic>? substitutionValues}) async {
    print('MySqlExecutor@getAsMap query $query');
    print('MySqlExecutor@getAsMap substitutionValues $substitutionValues');

    var rows = await _connection.query(query, Utils.substitutionMapToList(substitutionValues));
    print(rows);

    final result = <Map<String?, dynamic>>[];
    /*if (rows != null || rows.isNotEmpty) {
      for (var row in rows) {
        var map = <String, dynamic>{};
        for (var i = 0; i < row.length; i++) {
          map.addAll({row[i]: row[i + 1]});
        }
        result.add(map);
      }
      return result;
    }*/
    return result;
  }

  /*@override
  Future transaction2(Function queryBlock, {int commitTimeoutInSeconds}) {
    return _connection.transaction(queryBlock);
  }*/
}

/// A [QueryExecutor] that manages a pool of PostgreSQL connections.
class MySqlExecutorExecutorPool implements QueryExecutor {
  /// The maximum amount of concurrent connections.
  final int size;

  /// Creates a new [PostgreSQLConnection], on demand.
  ///
  /// The created connection should **not** be open.
  final MySqlConnection Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger? logger;

  final List<MySqlExecutor> _connections = [];
  int _index = 0;
  final Pool _pool, _connMutex = Pool(1);

  MySqlExecutorExecutorPool(this.size, this.connectionFactory, {this.logger}) : _pool = Pool(size) {
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
          final conn = connectionFactory();

          final executor = MySqlExecutor(conn, logger: logger);

          return executor;
        }),
      );
      _connections.addAll(listCon);
    }
  }

  Future<MySqlExecutor> _next() {
    return _connMutex.withResource(() async {
      await _open();
      if (_index >= size) _index = 0;
      return _connections[_index++];
    });
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic>? substitutionValues}) {
    /*return _pool.withResource(() async {
      final executor = await _next();
      return executor.mappedResultsQuery(query, substitutionValues: substitutionValues);
    });*/
    throw UnsupportedOperationException('mappedResultsQuery not implemented');
  }

  @override
  Future<List<Map<String?, dynamic>>> getAsMap(String query, {Map<String, dynamic>? substitutionValues}) async {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMap(query, substitutionValues: substitutionValues);
    });
  }

  Future<List<List>> execute(String query, {Map<String, dynamic>? substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues!);
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

  /*@override
  Future transaction2(Function queryBlock, {int commitTimeoutInSeconds}) async {
    var executor = await _next();
    return executor.transaction(queryBlock);
  }*/
}
