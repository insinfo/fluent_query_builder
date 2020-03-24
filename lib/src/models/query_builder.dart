import 'expression.dart';
import 'join_type.dart';
import 'query_builder_options.dart';
import 'block.dart';
import 'sort_order.dart';
import 'union_type.dart';
import 'util.dart';
import 'exceptions.dart';
import 'dart:async';

abstract class QueryBuilder {
  QueryBuilder(
    QueryBuilderOptions options,
    List<Block> blocks, {
    Future<List<List>> Function() execFunc,
    Future<Map<String, Map<String, dynamic>>> Function() firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String, dynamic>>>> Function()
        getAsMapFuncWithMeta,
    Future<List> Function() firstFunc,
    Future<Map<String, dynamic>> Function() firstAsMapFunc,
    Future<List<Map<String, dynamic>>> Function() getAsMapFunc,
  }) {
    mOptions = options ?? QueryBuilderOptions();
    //mOptions = options != null ? options : QueryBuilderOptions();
    //mBlocks = blocks != null ? blocks : [];
    mBlocks = blocks ?? [];

    _execFunc = execFunc;
    _firstAsMapFuncWithMeta = firstAsMapFuncWithMeta;
    _getAsMapFuncWithMeta = getAsMapFuncWithMeta;
    _firstFunc = firstFunc;
    _firstAsMapFunc = firstAsMapFunc;
    _getAsMapFunc = getAsMapFunc;
  }
  QueryBuilderOptions mOptions;
  List<Block> mBlocks;

  Future<List<List>> Function() _execFunc;
  Future<Map<String, Map<String, dynamic>>> Function() _firstAsMapFuncWithMeta;
  Future<List<Map<String, Map<String, dynamic>>>> Function()
      _getAsMapFuncWithMeta;
  Future<Map<String, dynamic>> Function() _firstAsMapFunc;
  Future<List<Map<String, dynamic>>> Function() _getAsMapFunc;
  Future<List> Function() _firstFunc;

  bool isQuery() {
    if (mBlocks == null) {
      return false;
    } else if (mBlocks.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    final results = <String>[];
    for (var block in mBlocks) {
      results.add(block.buildStr(this));
    }

    return Util.joinNonEmpty(mOptions.separator, results);
  }

  //isFirst used to add or replace limit 1 offset 0 in query string
  String toSql({bool isFirst = false}) {
    final results = <String>[];
    for (var block in mBlocks) {
      results.add(block.buildStr(this));
    }
    var result = Util.joinNonEmpty(mOptions.separator, results);

    if (isFirst) {
      //LIMIT.*?(?=\)|$) Regex for
      final idx = result.lastIndexOf(RegExp(r'LIMIT', caseSensitive: false));
      if (idx != -1) {
        result = result.substring(0, idx - 1);
      }
      final idx2 = result.lastIndexOf(RegExp(r'OFFSET', caseSensitive: false));
      if (idx2 != -1) {
        result = result.substring(0, idx2 - 1);
      }
      result = '$result LIMIT 1 OFFSET 0';
    }
    return result;
  }

  //
  // EXECUTE QUERY AND GET DATA FROM DATABASE
  //
  Future<List<List>> exec() async {
    if (_execFunc == null) {
      throw Exception('QueryBuilder@exec execFunc not defined');
    }
    return _execFunc();
  }

  Future<List<List>> get() async {
    if (_execFunc == null) {
      throw Exception('QueryBuilder@get execFunc not defined');
    }
    return _execFunc();
  }

  Future<List> first() async {
    if (_firstFunc == null) {
      throw Exception('QueryBuilder@first firstFunc not defined');
    }
    return _firstFunc();
  }

  ///Return rows as maps containing table and column names
  Future<List<Map<String, Map<String, dynamic>>>> getAsMapWithMeta() async {
    if (_getAsMapFuncWithMeta == null) {
      throw Exception(
          'QueryBuilder@getAsMapWithMeta getAsMapFuncWithMeta not defined');
    }
    return _getAsMapFuncWithMeta();
  }

  ///Return row as maps containing table and column names
  Future<Map<String, Map<String, dynamic>>> firstAsMapWithMeta() async {
    if (_firstAsMapFuncWithMeta == null) {
      throw Exception(
          'QueryBuilder@firstAsMapWithMeta firstAsMapFuncWithMeta not defined');
    }
    return _firstAsMapFuncWithMeta();
  }

  Future<List<Map<String, dynamic>>> getAsMap() async {
    if (_getAsMapFunc == null) {
      throw Exception('QueryBuilder@getAsMap getAsMapFunc not defined');
    }
    return _getAsMapFunc();
  }

  Future<Map<String, dynamic>> firstAsMap() async {
    if (_firstAsMapFunc == null) {
      throw Exception('QueryBuilder@firstAsMap firstAsMapFunc not defined');
    }
    return _firstAsMapFunc();
  }

  //
  // DISTINCT
  //
  QueryBuilder distinct() {
    throw UnsupportedOperationException('`distinct` not implemented');
  }

  //
  // FROM
  //
  QueryBuilder from(String table, {String alias}) {
    throw UnsupportedOperationException('`from` not implemented');
  }

  QueryBuilder fromSubQuery(QueryBuilder table, {String alias}) {
    throw UnsupportedOperationException('`fromSubQuery` not implemented');
  }

  //
  // GET FIELDS
  //
  QueryBuilder field(String field, {String alias}) {
    throw UnsupportedOperationException('`fieldWithAlias` not implemented');
  }

  QueryBuilder fieldSubQuery(QueryBuilder field, {String alias}) {
    throw UnsupportedOperationException(
        '`fieldSubQueryWithAlias` not implemented');
  }

  QueryBuilder fields(Iterable<String> fields) {
    throw UnsupportedOperationException('`fields` not implemented');
  }

  QueryBuilder fieldRaw(String setFieldRawSql) {
    throw UnsupportedOperationException('`fieldRaw` not implemented');
  }

  //
  // GROUP
  //
  QueryBuilder group(String field) {
    throw UnsupportedOperationException('`group` not implemented');
  }

  QueryBuilder groups(Iterable<String> fields) {
    throw UnsupportedOperationException('`groups` not implemented');
  }

  QueryBuilder groupRaw(String groupRawSql) {
    throw UnsupportedOperationException('`groupRaw` not implemented');
  }

  //
  // JOIN
  //
  QueryBuilder joinRaw(String sql) {
    throw UnsupportedOperationException('`joinRaw` not implemented');
  }

  QueryBuilder join(String joinTableName, String condition,
      {String alias, JoinType type = JoinType.INNER}) {
    throw UnsupportedOperationException('`join` not implemented');
  }

  QueryBuilder innerJoin(
      String joinTableName, String field1, String operator, String field2,
      {String alias}) {
    return join(joinTableName, field1 + operator + field2,
        type: JoinType.INNER, alias: alias);
  }

  QueryBuilder leftJoin(
      String joinTableName, String field1, String operator, String field2,
      {String alias}) {
    return join(joinTableName, field1 + operator + field2,
        type: JoinType.LEFT, alias: alias);
  }

  QueryBuilder rightJoin(
      String joinTableName, String field1, String operator, String field2,
      {String alias}) {
    return join(joinTableName, field1 + operator + field2,
        type: JoinType.RIGHT, alias: alias);
  }

  QueryBuilder joinWithSubQuery(QueryBuilder table, String condition,
      {String alias, JoinType type = JoinType.INNER}) {
    throw UnsupportedOperationException('`joinWithSubQuery` not implemented');
  }

  QueryBuilder joinWithExpression(String table, Expression condition,
      {String alias, JoinType type = JoinType.INNER}) {
    throw UnsupportedOperationException('`joinWithExpression` not implemented');
  }

  QueryBuilder joinWithQueryExpr(QueryBuilder table, Expression condition,
      {String alias, JoinType type = JoinType.INNER}) {
    throw UnsupportedOperationException('`joinWithQueryExpr` not implemented');
  }

  //
  // WHERE
  //
  QueryBuilder where(String condition, [Object param]) {
    throw UnsupportedOperationException('`where` not implemented');
  }

  QueryBuilder whereExpr(Expression condition, [Object param]) {
    throw UnsupportedOperationException('`whereExpr` not implemented');
  }

  QueryBuilder whereRaw(String whereRawSql) {
    throw UnsupportedOperationException('`whereRaw` not implemented');
  }

  //
  // LIMIT
  //
  QueryBuilder limit(int value) {
    throw UnsupportedOperationException('`limit` not implemented');
  }

  //
  // ORDER BY
  //
  QueryBuilder order(String field, {SortOrder dir = SortOrder.ASC}) {
    throw UnsupportedOperationException('`order` not implemented');
  }

  //
  // OFFSET
  //
  QueryBuilder offset(int value) {
    throw UnsupportedOperationException('`offset` not implemented');
  }

  //
  // UNION
  //
  QueryBuilder union(String table, UnionType unionType) {
    throw UnsupportedOperationException('union not implemented');
  }

  QueryBuilder unionSubQuery(QueryBuilder table, UnionType unionType) {
    throw UnsupportedOperationException('unionSubQuery not implemented');
  }

  //
  // TABLE
  //
  QueryBuilder table(String table, {String alias}) {
    throw UnsupportedOperationException('`table` not implemented');
  }

  //
  // SET
  //
  QueryBuilder set(String field, value) {
    throw UnsupportedOperationException('`set` not implemented');
  }

  //
  // INTO
  //
  QueryBuilder into(String table) {
    throw UnsupportedOperationException('`into` not implemented');
  }

  //
  // `FROM QUERY`
  //
  QueryBuilder fromQuery(Iterable<String> fields, QueryBuilder query) {
    throw UnsupportedOperationException('`fromQuery` not implemented');
  }
}
