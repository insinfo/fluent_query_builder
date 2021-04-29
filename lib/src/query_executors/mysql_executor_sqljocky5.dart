import 'dart:async';
import 'package:galileo_sqljocky5/public/connection/connection.dart';
import 'package:pool/pool.dart';

import 'package:galileo_sqljocky5/sqljocky.dart';
import '../../fluent_query_builder.dart';
import '../models/exceptions.dart';
import 'query_executor.dart';
import 'package:logging/logging.dart';

import 'utils.dart';

class MySqlExecutor extends QueryExecutor {
  /// An optional [Logger] to write to.
  final Logger? logger;
  Querier? _connection;
  DBConnectionInfo? connectionInfo;

  MySqlExecutor(this._connection, {this.logger, this.connectionInfo});

  Future<void> reconnect() async {
    _connection = await MySqlConnection.connect(
      ConnectionSettings(
        host: connectionInfo!.host,
        port: connectionInfo!.port,
        db: connectionInfo!.database,
        user: connectionInfo!.username,
        password: connectionInfo!.password,
      ),
    );
  }

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
      return Future.value(_connection as Transaction?);
    } else if (_connection is MySqlConnection) {
      return (_connection as MySqlConnection).begin();
    } else {
      throw StateError('Connection must be transaction or connection');
    }
  }

  ///this method execute query on MySQL or MariaDB DataBase
  @override
  Future<List<List?>?> query(String query, Map<String, dynamic> substitutionValues,
      [List<String?>? returningFields]) async {
    // Change @id -> ?
    for (var name in substitutionValues.keys) {
      query = query.replaceAll('@$name', '?');
    }

    logger?.fine('MySqlExecutor@query Query: $query');
    logger?.fine('MySqlExecutor@query Values: $substitutionValues');
    // print('MySqlExecutor@query Query: $query');
    //  print('MySqlExecutor@query Values: $substitutionValues');
    //  print('MySqlExecutor@query Fields: $returningFields');

    /*
    for MariaDB 10.5 only
    if (returningFields != null) {
      var fields = returningFields.join(', ');
      var returning = 'RETURNING $fields';
      query = '$query $returning';
    }*/

    if (returningFields?.isNotEmpty != true) {
      var results;
      try {
        results = await _connection!.prepared(query, Utils.substitutionMapToList(substitutionValues));
      } catch (e) {
        //reconnect in Error
        //MySQL Client Error: Connection cannot process a request for Instance of 'PrepareHandler' while a request is already in progress for Instance of 'PrepareHandler'
        if ('$e'.contains('PrepareHandler') || '$e'.contains('Cannot write to socket, it is closed')) {
          //print('MySqlExecutor@query reconnect in Error');
          await reconnect();
          results = await _connection!.prepared(query, Utils.substitutionMapToList(substitutionValues));
        } else {
          rethrow;
        }
      }
      var list = <List?>[];
      await for (var item in results) {
        list.add(item);
      }
      //print('results ${results.map((r) => r.toList())}');
      // return results.map((r) => r.toList()).toList();
      return list;
    } else {
      return Future(() async {
        var tx = await _startTransaction();
        try {
          var tableName = '';
          /*          
          INSERT INTO `pessoas` (nome,telefone)  VALUES ('Dog','2771-2898') ;
          SELECT id,nome from `pessoas` WHERE id=LAST_INSERT_ID();
          */
          var indexOfInsert = query.toUpperCase().indexOf('INTO');
          var indexOfEnd = query.indexOf('(');
          tableName = query.substring(indexOfInsert + 4, indexOfEnd);

          var writeResults;
          try {
            writeResults = await tx.prepared(query, Utils.substitutionMapToList(substitutionValues));
          } catch (e) {
            //reconnect in Error
            //MySQL Client Error: Connection cannot process a request for Instance of 'PrepareHandler' while a request is already in progress for Instance of 'PrepareHandler'
            if ('$e'.contains('PrepareHandler') || '$e'.contains('Cannot write to socket, it is closed')) {
              //print('MySqlExecutor@query reconnect in Error');
              await reconnect();
              writeResults = await tx.prepared(query, Utils.substitutionMapToList(substitutionValues));
            } else {
              rethrow;
            }
          }

          var fieldSet = returningFields!.map((s) => '`$s`').join(',');
          var fetchSql = 'select $fieldSet from $tableName where id = ?;';

          logger?.fine(fetchSql);
          var readResults;

          try {
            readResults = await tx.prepared(fetchSql, [writeResults.insertId]);
          } catch (e) {
            //reconnect in Error
            //MySQL Client Error: Connection cannot process a request for Instance of 'PrepareHandler' while a request is already in progress for Instance of 'PrepareHandler'
            if ('$e'.contains('PrepareHandler') || '$e'.contains('Cannot write to socket, it is closed')) {
              //print('MySqlExecutor@query reconnect in Error');
              await reconnect();
              readResults = await tx.prepared(fetchSql, [writeResults.insertId]);
            } else {
              rethrow;
            }
          }
          // print('fetchSql $fetchSql');
          var mapped = readResults.map((r) => r.toList()).toList();
          await tx.commit();
          return mapped;
        } catch (_) {
          await tx.rollback();
          rethrow;
        }
      });
    }
  }

  @override
  Future<T> transaction<T>(FutureOr<T> Function(QueryExecutor) f) async {
    if (_connection is Transaction) {
      return await f(this);
    }

    Transaction? tx;
    try {
      tx = await _startTransaction();
      var executor = MySqlExecutor(tx, logger: logger, connectionInfo: connectionInfo);
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
      {Map<String, dynamic>? substitutionValues}) async {
    // return rs.map((row) => row.toTableColumnMap()).toList();
    throw UnsupportedOperationException('mappedResultsQuery not implemented');
    //var rows = await this.query(query,substitutionValues);
  }

  @override
  Future<List<Map<String?, dynamic>>> getAsMap(String query, {Map<String, dynamic>? substitutionValues}) async {
    //print('MySqlExecutor@getAsMap query $query');
    //print('MySqlExecutor@getAsMap substitutionValues $substitutionValues');
    var results = <Map<String?, dynamic>>[];

    for (var name in substitutionValues!.keys) {
      query = query.replaceAll('@$name', '?');
    }
    var rows;
    try {
      rows = await _connection!.prepared(query, Utils.substitutionMapToList(substitutionValues));
    } catch (e) {
      //reconnect in Error
      //MySQL Client Error: Connection cannot process a request for Instance of 'PrepareHandler' while a request is already in progress for Instance of 'PrepareHandler'
      //Bad state: Cannot write to socket, it is closed
      //print('MySqlExecutor@getAsMap reconnect in Error $e');
      if ('$e'.contains('PrepareHandler') || '$e'.contains('Cannot write to socket, it is closed')) {
        //print('MySqlExecutor@getAsMap reconnect in Error');
        await reconnect();
        rows = await _connection!.prepared(query, Utils.substitutionMapToList(substitutionValues));
      } else {
        rethrow;
      }
    }

    var fields = rows.fields;
    await rows.forEach((Row row) {
      var map = <String?, dynamic>{};
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
class MySqlExecutorPool implements QueryExecutor {
  /// The maximum amount of concurrent connections.
  final int size;

  /// Creates a new [PostgreSQLConnection], on demand.
  ///
  /// The created connection should **not** be open.
  //final Querier Function() connectionFactory;
  final Future<Querier> Function() connectionFactory;

  /// An optional [Logger] to print information to.
  final Logger? logger;

  final List<MySqlExecutor> _connections = [];
  int _index = 0;
  final Pool _pool, _connMutex = Pool(1);
  DBConnectionInfo? connectionInfo;

  MySqlExecutorPool(this.size, this.connectionFactory, {this.logger, this.connectionInfo}) : _pool = Pool(size) {
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
          final conn = await connectionFactory();

          final executor = MySqlExecutor(conn, logger: logger, connectionInfo: connectionInfo);

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

  Future<List<List?>?> execute(String query, {Map<String, dynamic>? substitutionValues}) {
    return _pool.withResource(() async {
      final executor = await _next();
      return executor.query(query, substitutionValues!);
    });
  }

  @override
  Future<List<List?>?> query(String query, Map<String, dynamic> substitutionValues, [List<String?>? returningFields]) {
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
