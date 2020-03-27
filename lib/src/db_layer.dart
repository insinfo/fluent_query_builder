import 'dart:async';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'connection_info.dart';
import 'query_executors/postgre_sql_executor.dart';
import 'query_executors/query_executor.dart';
import 'models/query_builder.dart';

import 'models/expression.dart';

import 'models/query_builder_options.dart';
import 'models/select.dart';
import 'models/update.dart';
import 'models/insert.dart';
import 'models/delete.dart';

class DbLayer {
  PostgreSqlExecutorPool executor;
  QueryBuilder currentQuery;

  DbLayer() {
    //currentQuery = Select(QueryBuilderOptions());
  }
  //

  Future<DbLayer> connect(DBConnectionInfo connectionInfo) async {
    var nOfProces = connectionInfo.setNumberOfProcessorsFromPlatform
        ? Platform.numberOfProcessors
        : connectionInfo.numberOfProcessors;

    //Todo implementar
    //se connectionInfo.driver for pgsql chama PostgreSqlExecutorPool 
    //se for mysql chama  MySqlExecutor
    executor = PostgreSqlExecutorPool(
      nOfProces,
      () {
        return PostgreSQLConnection(
          connectionInfo.host,
          connectionInfo.port,
          connectionInfo.database,
          username: connectionInfo.username,
          password: connectionInfo.password,
        );
      },
      schemes: connectionInfo.schemes,
    );

    //In order to specify the default schema you should set the search_path instead.
    //$Conn->exec('SET search_path TO accountschema');
    //You can also set the default search_path per database user
    //and in that case the above statement becomes redundant.
    //ALTER USER user SET search_path TO accountschema;
    //Not sure what you mean with 1. ALTER USER username SET search_path TO schema1, schema2,
    //schema3 or ALTER ROLL some_role SET search_path or even
    //ALTER DATABASE start SET search_path TO schema1,schema2 on the PG server directly allows you to do that
    //set squema
    /*if (connectionInfo.schema != null && connectionInfo.schema.isNotEmpty) {
      final schemas = connectionInfo.schema.map((i) => '"$i"').toList().join(', ');
      await executor.query('users', 'set search_path to $schemas;', {});
    }*/

    return this;
  }

  /// Starts a new expression with the provided options.
  /// @param options Options to use for expression generation.
  /// @return Expression
  Expression expression({QueryBuilderOptions options}) {
    return Expression(options);
  }

  /// Starts the SELECT-query chain with the provided options
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder select({QueryBuilderOptions options}) {
    return currentQuery = Select(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
    );
  }

  /// Starts the UPDATE-query.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder update({QueryBuilderOptions options}) {
    return currentQuery = Update(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
    );
  }

  /// Starts the INSERT-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder insert({QueryBuilderOptions options}) {
    return currentQuery = Insert(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
    );
  }

  /// Starts the DELETE-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder delete(QueryBuilderOptions options) {
    return currentQuery = Delete(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
    );
  }

  Future<List<List>> exec() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    final rows = await executor.query('users', currentQuery.toSql(), {});
    return rows;
  }

  Future<List<List>> get() async {
    return exec();
  }

  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    final rows = await executor.mappedResultsQuery(currentQuery.toSql(), substitutionValues: {});
    return rows;
  }

  Future<List> first() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    final rows = await get();

    if (rows != null) {
      if (rows.isNotEmpty) {
        return rows[0];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Map<String, Map<String, dynamic>>> firstAsMapWithMeta() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    final rows = await getAsMapWithMeta();
    if (rows != null) {
      if (rows.isNotEmpty) {
        return rows[0];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAsMap() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    final rows = await getAsMapWithMeta();
    final result = <Map<String, dynamic>>[];
    if (rows != null || rows.isNotEmpty) {
      for (var item in rows) {
        //Combine/merge multiple maps into 1 map
        result.add(item.values.reduce((map1, map2) => map1..addAll(map2)));
      }
      return result;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> firstAsMap() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }
    //final List<Map<String, dynamic>> rows = await getAsMap();
    final rows = await getAsMap();
    if (rows != null) {
      if (rows.isNotEmpty) {
        return rows[0];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future close() async {
    await executor.close();
  }

  Future<T> transaction<T>(FutureOr<T> Function(QueryExecutor) f) {
    return executor.transaction<T>(f);
  }
}
