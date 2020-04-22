import 'dart:async';
import 'dart:io';

import 'package:postgres/postgres.dart';

//import 'package:mysql1/mysql1.dart';
import 'package:sqljocky5/sqljocky.dart';

import 'connection_info.dart';
import 'models/raw.dart';
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
  static const dynamic DEFAULT_NULL = [];

  Future<DbLayer> connect(DBConnectionInfo connInfo) async {
    options = connInfo.getQueryOptions();
    connectionInfo = connInfo.getSettings();
    var nOfProces = connectionInfo.setNumberOfProcessorsFromPlatform
        ? Platform.numberOfProcessors
        : connectionInfo.numberOfProcessors;

    //Todo implementar
    //se connectionInfo.driver for pgsql chama PostgreSqlExecutorPool
    //se for mysql chama  MySqlExecutor
    if (connectionInfo.driver == ConnectionDriver.pgsql) {
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
    } else {
      executor = MySqlExecutor(
        await MySqlConnection.connect(
          ConnectionSettings(
            host: connectionInfo.host,
            port: connectionInfo.port,
            db: connectionInfo.database,
            user: connectionInfo.username,
            password: connectionInfo.password,
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
      countFunc: _count,
    );
  }

  /// Starts the UPDATE-query.
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

  QueryBuilder raw(String rawQueryString) {
    return currentQuery = Raw(
      rawQueryString,
      options: options,
      execFunc: exec,
      firstFunc: first,
      firstAsMapFuncWithMeta: firstAsMapWithMeta,
      getAsMapFuncWithMeta: getAsMapWithMeta,
      getAsMapFunc: getAsMap,
      firstAsMapFunc: firstAsMap,
      countFunc: _count,
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
    final rows = await executor.query(currentQuery.toSql(isFirst: true), currentQuery.buildSubstitutionValues());

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

  Future<int> _count() async {
    if (!currentQuery.isQuery()) {
      throw Exception('Is nessesary query');
    }

    final rows = await executor.query(currentQuery.toSql(isCount: true), currentQuery.buildSubstitutionValues());
    //total_records
    if (rows != null) {
      if (rows.isNotEmpty) {
        return rows[0][0];
      }
    }

    return 0;
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

    final rows = await executor.getAsMap(currentQuery.toSql(isFirst: true),
        substitutionValues: currentQuery.buildSubstitutionValues());

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

  Future<T> transaction<T>(FutureOr<T> Function(DbLayer) f) {
    return executor.transaction<T>((queryEcecutor) async {
      var db = await DbLayer(factories: factories);
      db.executor = queryEcecutor;
      return f(db);
    });
  }

  Future transaction2(Future Function(dynamic) queryBlock, {int commitTimeoutInSeconds}) {
    return executor.transaction2(queryBlock);
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

  ///
  /// @param data
  /// @param tableName nome da tabela relacionada
  /// @param localKey key id da tabela relacionada
  /// @param foreignKey id contido nos dados passados pelo parametro data para comparar com o key id da tabela relacionada
  /// @param relationName nome da chave no map que estara com o resultado
  /// @param defaultNull valor padrão para a chave no map caso não tenha resultado List | null
  ///
  /// @param null callback_fields
  /// Este parametro deve ser uma função anonima com um parametro que é o campo
  /// utilizada para alterar as informações de um determinado campo vindo do banco
  /// Exemplo:
  /// (field) {
  ///  field['description'] = strip_tags(field['description']);
  /// }
  ///
  /// @param null $callback_query
  /// Este parametro deve ser uma função com um parametro. Neste parametro você
  /// receberá a query utilizada na consulta, possibilitando
  /// realizar operações de querys extras para esta ação.
  ///
  /// Exemplo:
  /// (query) {
  ///  query.orderBy('field_name', 'asc');
  /// }
  ///
  /// @param bool isSingle
  ///
  ///
  Future<List<Map<String, dynamic>>> getRelationFromMaps(
    List<Map<String, dynamic>> data,
    String tableName,
    String localKey,
    String foreignKey, {
    String relationName,
    dynamic defaultNull = DEFAULT_NULL,
    Function(Map<String, dynamic>) callback_fields,
    Function(QueryBuilder) callback_query,
    isSingle = false,
  }) async {
    //1º obtem os ids
    var itens_id = <int>[];
    for (var item2 in data) {
      var itemId = item2.containsKey(foreignKey) ? item2[foreignKey] : null;
      //não adiciona se for nulo ou vazio ou diferente de int
      if (itemId != null) {
        itens_id.add(itemId);
      }
    }
    //instancia o objeto query builder
    var query = select().from(tableName);
    //checa se foi passado callback_query para mudar a query
    if (callback_query != null) {
      callback_query(query);
    }

    List<Map<String, dynamic>> queryResult;
    //se ouver itens a serem pegos no banco
    if (itens_id.isNotEmpty) {
      //prepara a query where in e executa
      query.whereRaw('"$tableName"."$localKey" in (${itens_id.join(",")})');
      queryResult = await query.getAsMap();
    } else {
      queryResult = null;
    }

    //verifica se foi passado um nome para o node de resultados
    if (relationName != null) {
      relationName = relationName + '';
    } else {
      relationName = tableName;
    }
    if (isSingle) {
      defaultNull = null;
    }

    //var result = <Map<String, dynamic>>[];
    //intera sobre a lista de dados passados
    for (var item in data) {
      //result.add({relationName: defaultNull});
      item[relationName] = defaultNull;
      var conjunto = [];
      //faz o loop sobre os resultados da query
      if (queryResult != null) {
        for (var value in queryResult) {
          //verifica se o item corrente tem relação com algum filho trazido pela query
          if (item[foreignKey] == value[localKey]) {
            //checa se foi passado callback_fields
            if (callback_fields != null) {
              value = callback_fields(value);
            }
            //verifica se é para trazer um filho ou varios
            if (isSingle) {
              item[relationName] = value ?? defaultNull;
              break;
            } else {
              conjunto.add(value ?? defaultNull);
            }

            item[relationName] = conjunto;
          }
        }
      }
    }

    //fim
    return data;
  }
}
