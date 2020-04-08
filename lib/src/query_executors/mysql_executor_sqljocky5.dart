import 'dart:async';
import 'package:pool/pool.dart';
import 'package:sqljocky5/connection/connection.dart';
import 'package:sqljocky5/sqljocky.dart';
import '../models/exceptions.dart';
import 'query_executor.dart';
import 'package:logging/logging.dart';

import 'utils.dart';

class MySqlExecutor extends QueryExecutor {
  /// An optional [Logger] to write to.
  final Logger logger;

  final Querier _connection;

  MySqlExecutor(this._connection, {this.logger});

  @override
  Future<void> close() {
    if (_connection is MySqlConnection) {
      return (_connection as MySqlConnection).close();
    } else {
      return Future.value();
    }
  }

  Future<Transaction> _startTransaction() {
    if (_connection is Transaction) {
      return Future.value(_connection as Transaction);
    } else if (_connection is MySqlConnection) {
      return (_connection as MySqlConnection).begin();
    } else {
      throw StateError('Connection must be transaction or connection');
    }
  }

  @override
  Future<List<List>> query(String query, Map<String, dynamic> substitutionValues, [List<String> returningFields]) {
    // Change @id -> ?
    for (var name in substitutionValues.keys) {
      query = query.replaceAll('@$name', '?');
    }

    logger?.fine('Query: $query');
    logger?.fine('Values: $substitutionValues');

    //if (returningFields?.isNotEmpty != true) {
    return _connection
        .prepared(query, Utils.substitutionMapToList(substitutionValues))
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
  Future<T> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (_connection is Transaction) {
      return await f(this);
    }

    Transaction tx;
    try {
      tx = await _startTransaction();
      var executor = MySqlExecutor(tx, logger: logger);
      var result = await f(executor);
      await tx.commit();
      return result;
    } catch (_) {
      await tx?.rollback();
      rethrow;
    }
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta(String query,
      {Map<String, dynamic> substitutionValues}) async {
    // return rs.map((row) => row.toTableColumnMap()).toList();
    throw UnsupportedOperationException('mappedResultsQuery not implemented');
    //var rows = await this.query(query,substitutionValues);
  }

  @override
  Future<List<Map<String, dynamic>>> getAsMap(String query, {Map<String, dynamic> substitutionValues}) async {
    //print('MySqlExecutor@getAsMap query $query');
    //print('MySqlExecutor@getAsMap substitutionValues $substitutionValues');
    var results = <Map<String, dynamic>>[];
    
    for (var name in substitutionValues.keys) {
      query = query.replaceAll('@$name', '?');
    }
    var rows = await _connection.prepared(query, Utils.substitutionMapToList(substitutionValues));

    var fields = rows.fields;
    await rows.forEach((Row row) {
      var map = <String, dynamic>{};
      //print('key: ${fields[0].name}, value: ${row[0]}');
      for (var i = 0; i < row.length; i++) {
        map.addAll({fields[i].name: row[i]});
      }
      results.add(map);
    });
    //print('MySqlExecutor@getAsMap results ${results}');
    return results;
  }
}

/// A [QueryExecutor] that manages a pool of PostgreSQL connections.
class MySqlExecutorExecutorPool implements QueryExecutor {
  /// The maximum amount of concurrent connections.
  final int size;

  /// Creates a new [PostgreSQLConnection], on demand.
  ///
  /// The created connection should **not** be open.
  final Querier Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger logger;

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

          final executor = await MySqlExecutor(conn, logger: logger);

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
      {Map<String, dynamic> substitutionValues}) {
    /*return _pool.withResource(() async {
      final executor = await _next();
      return executor.mappedResultsQuery(query, substitutionValues: substitutionValues);
    });*/
    throw UnsupportedOperationException('mappedResultsQuery not implemented');
  }

  @override
  Future<List<Map<String, dynamic>>> getAsMap(String query, {Map<String, dynamic> substitutionValues}) async {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.getAsMap(query, substitutionValues: substitutionValues);
    });
  }

  Future<List<List>> execute(String query, {Map<String, dynamic> substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues);
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
