import 'sort_order.dart';

import 'expression.dart';
import 'join_type.dart';
import 'query_builder.dart';
import 'query_builder_options.dart';
import 'delete_block.dart';
import 'from_table_block.dart';
import 'join_block.dart';
import 'where_block.dart';
import 'order_by_block.dart';
import 'limit_block.dart';

/// DELETE query builder.
class Delete extends QueryBuilder {
  Delete(
    QueryBuilderOptions? options, {
    Future<List<List?>?> Function()? execFunc,
    Future<Map<String, Map<String?, dynamic>>?> Function()? firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String?, dynamic>>>> Function()? getAsMapFuncWithMeta,
    Future<List?> Function()? firstFunc,
    Future<Map<String?, dynamic>?> Function()? firstAsMapFunc,
    Future<List<Map<String?, dynamic>>> Function()? getAsMapFunc,
    this.deleteSingleFunc,
  }) : super(
          options,
          [
            DeleteBlock(options),
            FromTableBlock(options), // 1
            JoinBlock(options), // 2
            WhereBlock(options), // 3
            OrderByBlock(options), // 4
            LimitBlock(options) // 5
          ],
          execFunc: execFunc,
          firstAsMapFuncWithMeta: firstAsMapFuncWithMeta,
          getAsMapFuncWithMeta: getAsMapFuncWithMeta,
          firstFunc: firstFunc,
          firstAsMapFunc: firstAsMapFunc,
          getAsMapFunc: getAsMapFunc,
        );

  Future Function<T>(T entity, [QueryBuilder? queryBuilder])? deleteSingleFunc;

  @override
  Future deleteSingle<T>(T entity, [QueryBuilder? queryBuilder]) {
    return deleteSingleFunc!(entity, this);
  }

  @override
  QueryBuilder from(String? table, {String? alias}) {
    final block = mBlocks![1] as FromTableBlock;
    block.setFrom(table, alias);
    return this;
  }

  @override
  QueryBuilder where(String condition, [Object? param, String andOr = 'AND']) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhere(condition, param, andOr);
    return this;
  }

  @override
  QueryBuilder whereExpr(Expression condition, [Object? param, String andOr = 'AND']) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhereWithExpression(condition, param);
    return this;
  }

  @override
  QueryBuilder whereRaw(String whereRawSql, [String andOr = 'AND']) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhereRaw(whereRawSql, andOr);
    return this;
  }

  @override
  QueryBuilder whereSafe(String field, String operator, value) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhereSafe(field, operator, value);
    return this;
  }

  @override
  QueryBuilder orWhereSafe(String field, String operator, value) {
    final block = mBlocks![3] as WhereBlock;
    block.setOrWhereSafe(field, operator, value);
    return this;
  }

  @override
  QueryBuilder whereGroup(QueryBuilder Function(QueryBuilder) function) {
    final block = mBlocks![3] as WhereBlock;
    block.setStartGroup('AND');
    var r = function(this);
    block.setEndGroup();
    return r;
  }

  @override
  QueryBuilder orWhereGroup(QueryBuilder Function(QueryBuilder) function) {
    final block = mBlocks![3] as WhereBlock;
    block.setStartGroup('OR');
    var r = function(this);
    block.setEndGroup();
    return r;
  }

  @override
  QueryBuilder join(String joinTableName, String condition, {String? alias, JoinType type = JoinType.INNER}) {
    final block = mBlocks![2] as JoinBlock;
    block.setJoin(joinTableName, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithSubQuery(QueryBuilder table, String condition, {String? alias, JoinType type = JoinType.INNER}) {
    final block = mBlocks![2] as JoinBlock;
    block.setJoinWithSubQuery(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithExpression(String table, Expression condition, {String? alias, JoinType type = JoinType.INNER}) {
    final block = mBlocks![2] as JoinBlock;
    block.setJoinWithExpression(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithQueryExpr(QueryBuilder table, Expression condition,
      {String? alias, JoinType type = JoinType.INNER}) {
    final block = mBlocks![2] as JoinBlock;
    block.setJoinWithQueryWithExpr(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder order(String field, {SortOrder dir = SortOrder.ASC}) {
    final block = mBlocks![4] as OrderByBlock;
    block.setOrder(field, dir);
    return this;
  }

  @override
  QueryBuilder limit(int value) {
    final block = mBlocks![5] as LimitBlock;
    block.setLimit(value);
    return this;
  }
}
