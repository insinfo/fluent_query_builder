import 'dart:async';
import 'dart:io';

import 'package:postgres/postgres.dart';

//import 'package:mysql1/mysql1.dart';
import 'package:sqljocky5/sqljocky.dart';

import 'connection_info.dart';
import 'query_executors/postgre_sql_executor.dart';
//import 'query_executors/mysql_executor.dart';
import 'query_executors/mysql_executor_sqljocky5.dart';
import 'query_executors/query_executor.dart';
import 'models/query_builder.dart';

import 'models/expression.dart';

import 'models/query_builder_options.dart';
import 'models/select.dart';
import 'models/update.dart';
import 'models/insert.dart';
import 'models/delete.dart';

import 'fluent_model_base.dart';

class DbLayer {
  QueryExecutor executor;
  QueryBuilder currentQuery;
  final List<Map<Type, Function>> factories; // = <Type, Function>{};
  //ex: DiskCache<Agenda>(factories: {Agenda: (x) => Agenda.fromJson(x)});
  //{this.factory}
  DbLayer({this.factories}) {
    //currentQuery = Select(QueryBuilderOptions());
  }
  QueryBuilderOptions options;
  DBConnectionInfo connectionInfo;

  Future<DbLayer> connect(DBConnectionInfo connectionInfo) async {
    options = connectionInfo.getQueryOptions();
    this.connectionInfo = connectionInfo.getSettings();
    var nOfProces = connectionInfo.setNumberOfProcessorsFromPlatform
        ? Platform.numberOfProcessors
        : connectionInfo.numberOfProcessors;

    //Todo implementar
    //se connectionInfo.driver for pgsql chama PostgreSqlExecutorPool
    //se for mysql chama  MySqlExecutor
    if (this.connectionInfo.driver == ConnectionDriver.pgsql) {
      executor = PostgreSqlExecutorPool(
        nOfProces,
        () {
          return PostgreSQLConnection(
            this.connectionInfo.host,
            this.connectionInfo.port,
            this.connectionInfo.database,
            username: this.connectionInfo.username,
            password: this.connectionInfo.password,
          );
        },
        schemes: this.connectionInfo.schemes,
      );
    } else {
      executor = MySqlExecutor(
        await MySqlConnection.connect(
          ConnectionSettings(
            host: this.connectionInfo.host,
            port: this.connectionInfo.port,
            db: this.connectionInfo.database,
            user: this.connectionInfo.username,
            password: this.connectionInfo.password,
          ),
        ),
      );
    }

    return this;
  }

  /// Starts a new expression with the provided options.
  /// @param options Options to use for expression generation.
  /// @return Expression
  Expression expression() {
    return Expression(options);
  }

  /// Starts the SELECT-query chain with the provided options
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder select() {
    return currentQuery = Select(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
      fetchAllFunc: _fetchAll,
      fetchSingleFunc: _fetchSingle,
    );
  }

  /// Starts the UPDATE-query.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder update() {
    return currentQuery = Update(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
      updateSingleFunc: _updateSingle,
    );
  }

  /// Starts the INSERT-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder insert() {
    return currentQuery = Insert(options,
        execFunc: exec,
        firstFunc: first,
        firstAsMapFuncWithMeta: firstAsMapWithMeta,
        getAsMapFuncWithMeta: getAsMapWithMeta,
        getAsMapFunc: getAsMap,
        firstAsMapFunc: firstAsMap,
        putSingleFunc: putSingle);
  }

  /// Starts the DELETE-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  QueryBuilder delete() {
    return currentQuery = Delete(
      options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
      deleteSingleFunc: _deleteSingle,
    );
  }

  Future<List<List>> exec() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }

    final rows = await executor.query(currentQuery.toSql(), currentQuery.buildSubstitutionValues());
    return rows;
  }

  Future<List<List>> get() async {
    return exec();
  }

  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Dblayer@getAsMapWithMeta Is nessesary query');
    }
    final rows = await executor.getAsMapWithMeta(currentQuery.toSql(),
        substitutionValues: currentQuery.buildSubstitutionValues());
    return rows;
  }

  Future<List> first() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Dblayer@first Is nessesary query');
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
      throw Exception('Dblayer@firstAsMapWithMeta Is nessesary query');
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
      throw Exception('Dblayer@getAsMap Is nessesary query');
    }

    final rows =
        await executor.getAsMap(currentQuery.toSql(), substitutionValues: currentQuery.buildSubstitutionValues());
    return rows;
  }

  Future<Map<String, dynamic>> firstAsMap() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Dblayer@firstAsMap Is nessesary query');
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

  //
  Future<List<T>> _fetchAll<T>([T Function(Map<String, dynamic>) factory]) async {
    var records = await getAsMap();

    Function fac;
    if (factories != null) {
      for (var item in factories) {
        if (item.containsKey(T)) {
          fac = item[T];
        }
      }
    }

    fac ??= factory;

    if (fac == null) {
      throw Exception('Dblayer@fetchAll factory not defined');
    }

    final list = <T>[];
    if (records != null) {
      if (records.isNotEmpty) {
        for (var item in records) {
          list.add(fac(item));
        }
      }
    }
    return list;
  }

  Future<T> _fetchSingle<T>([T Function(Map<String, dynamic>) factory]) async {
    Function fac;
    if (factories != null) {
      for (var item in factories) {
        if (item.containsKey(T)) {
          fac = item[T];
        }
      }
    }

    fac ??= factory;

    if (fac == null) {
      throw Exception('Dblayer@fetchAll factory not defined');
    }
    final record = await firstAsMap();

    if (record != null) {
      return factory(record);
    }
    return null;
  }

  Future putSingle<T>(T entity) async {
    if (entity == null) {
      throw Exception('Dblayer@putSingle entity not defined');
    }
    if (entity != null) {
      var db = insert();
      var model = entity as FluentModelBase;
      var map = model.toMap();

      map.forEach((key, value) {
        db.set(key, value);
      });

      db.into(model.tableName);
      await db.exec();
    }
  }

  Future _updateSingle<T>(T entity, [QueryBuilder queryBuilder]) async {
    if (entity == null) {
      throw Exception('Dblayer@updateSingle entity not defined');
    }
    if (queryBuilder == null) {
      throw Exception('Dblayer@updateSingle queryBuilder not defined');
    }
    var model = entity as FluentModelBase;
    queryBuilder.table(model.tableName);
    var map = model.toMap();
    map.forEach((key, value) {
      queryBuilder.set(key, value);
    });
    await queryBuilder.exec();
  }

  Future _deleteSingle<T>(T entity, [QueryBuilder queryBuilder]) async {
    if (entity == null) {
      throw Exception('Dblayer@_deleteSingle entity not defined');
    }
    if (queryBuilder == null) {
      throw Exception('Dblayer@_deleteSingle queryBuilder not defined');
    }
    var model = entity as FluentModelBase;
    queryBuilder.from(model.tableName);
    queryBuilder.where('${model.primaryKey}=?', model.primaryKeyVal);
    await exec();
  }
}
