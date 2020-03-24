import 'distinct_block.dart';
import 'from_table_block.dart';
import 'get_field_block.dart';
import 'group_by_block.dart';
import 'join_block.dart';
import 'limit_block.dart';
import 'sort_order.dart';
import 'union_block.dart';
import 'union_type.dart';
import 'where_block.dart';
import 'offset_block.dart';
import 'order_by_block.dart';
import 'string_block.dart';
import 'query_builder.dart';
import 'query_builder_options.dart';
import 'block.dart';
import 'util.dart';
import 'exceptions.dart';
import 'join_type.dart';
import 'expression.dart';

/// SELECT query builder.
class Select extends QueryBuilder {
  Select(
    QueryBuilderOptions options, {
    Future<List<List>> Function() execFunc,
    Future<Map<String, Map<String, dynamic>>> Function() firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String, dynamic>>>> Function() getAsMapFuncWithMeta,
    Future<List> Function() firstFunc,
    Future<Map<String, dynamic>> Function() firstAsMapFunc,
    Future<List<Map<String, dynamic>>> Function() getAsMapFunc,
  }) : super(
          options,
          [
            StringBlock(options, "SELECT"),
            DistinctBlock(options), // 1
            GetFieldBlock(options), // 2
            FromTableBlock(options), // 3
            JoinBlock(options), // 4
            WhereBlock(options), // 5
            GroupByBlock(options), // 6
            OrderByBlock(options), // 7
            LimitBlock(options), // 8
            OffsetBlock(options), // 9
            UnionBlock(options) // 10
          ],
          execFunc: execFunc,
          firstAsMapFuncWithMeta: firstAsMapFuncWithMeta,
          getAsMapFuncWithMeta: getAsMapFuncWithMeta,
          firstFunc: firstFunc,
          firstAsMapFunc: firstAsMapFunc,
          getAsMapFunc: getAsMapFunc,
        );

  //
  // DISTINCT
  //
  @override
  QueryBuilder distinct() {
    final DistinctBlock block = mBlocks[1] as DistinctBlock;
    block.setDistinct();
    return this;
  }

  //
  // FROM
  //
  @override
  QueryBuilder from(String table, {String alias}) {
    final FromTableBlock block = mBlocks[3] as FromTableBlock;
    block.setFrom(table, alias);
    return this;
  }

  @override
  QueryBuilder fromSubQuery(QueryBuilder table, {String alias}) {
    final FromTableBlock block = mBlocks[3] as FromTableBlock;
    block.setFromSubQuery(table, alias);
    return this;
  }

  //
  // GET
  //
  @override
  QueryBuilder field(String field, {String alias}) {
    final GetFieldBlock block = mBlocks[2] as GetFieldBlock;
    block.setField(field, alias);
    return this;
  }

  @override
  QueryBuilder fieldSubQuery(QueryBuilder field, {String alias}) {
    final GetFieldBlock block = mBlocks[2] as GetFieldBlock;
    block.setFieldFromSubQuery(field, alias);
    return this;
  }

  @override
  QueryBuilder fields(Iterable<String> fields) {
    final GetFieldBlock block = mBlocks[2] as GetFieldBlock;
    block.setFields(fields);
    return this;
  }

  @override
  QueryBuilder fieldRaw(String setFieldRawSql) {
    final GetFieldBlock block = mBlocks[2] as GetFieldBlock;
    block.setFieldRaw(setFieldRawSql);
    return this;
  }

  @override
  QueryBuilder group(String field) {
    final GroupByBlock block = mBlocks[6] as GroupByBlock;
    block.setGroup(field);
    return this;
  }

  @override
  QueryBuilder groups(Iterable<String> fields) {
    final GroupByBlock block = mBlocks[6] as GroupByBlock;
    block.setGroups(fields);
    return this;
  }

  @override
  QueryBuilder groupRaw(String groupRawSql) {
    final GroupByBlock block = mBlocks[6] as GroupByBlock;
    block.setGroupRaw(groupRawSql);
    return this;
  }

  //
  // JOIN
  //
  @override
  QueryBuilder join(String joinTableName, String condition, {String alias, JoinType type = JoinType.INNER}) {
    final JoinBlock block = mBlocks[4] as JoinBlock;
    block.setJoin(joinTableName, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithSubQuery(QueryBuilder table, String condition, {String alias, JoinType type = JoinType.INNER}) {
    final JoinBlock block = mBlocks[4] as JoinBlock;
    block.setJoinWithSubQuery(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithExpression(String table, Expression condition, {String alias, JoinType type = JoinType.INNER}) {
    final JoinBlock block = mBlocks[4] as JoinBlock;
    block.setJoinWithExpression(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder joinWithQueryExpr(QueryBuilder table, Expression condition,
      {String alias, JoinType type = JoinType.INNER}) {
    final JoinBlock block = mBlocks[4] as JoinBlock;
    block.setJoinWithQueryWithExpr(table, alias, condition, type);
    return this;
  }

  @override
  QueryBuilder where(String condition, [Object param]) {
    final WhereBlock block = mBlocks[5] as WhereBlock;
    block.setWhere(condition, param);
    return this;
  }

  @override
  QueryBuilder whereExpr(Expression condition, [Object param]) {
    final WhereBlock block = mBlocks[5] as WhereBlock;
    block.setWhereWithExpression(condition, param);
    return this;
  }

  @override
  QueryBuilder whereRaw(String whereRawSql) {
    final WhereBlock block = mBlocks[5] as WhereBlock;
    block.setWhereRaw(whereRawSql);
    return this;
  }

  //
  // LIMIT
  //
  @override
  QueryBuilder limit(int value) {
    final LimitBlock block = mBlocks[8] as LimitBlock;
    block.setLimit(value);
    return this;
  }

  //
  // ORDER BY
  //
  @override
  QueryBuilder order(String field, {SortOrder dir = SortOrder.ASC}) {
    final OrderByBlock block = mBlocks[7] as OrderByBlock;
    block.setOrder(field, dir);
    return this;
  }

  //
  // OFFSET
  //
  @override
  QueryBuilder offset(int value) {
    final OffsetBlock block = mBlocks[9] as OffsetBlock;
    block.setOffset(value);
    return this;
  }

  //
  // UNION
  //
  @override
  QueryBuilder union(String table, UnionType unionType) {
    final UnionBlock block = mBlocks[10] as UnionBlock;
    block.setUnion(table, unionType);
    return this;
  }

  @override
  QueryBuilder unionSubQuery(QueryBuilder table, UnionType unionType) {
    final UnionBlock block = mBlocks[10] as UnionBlock;
    block.setUnionSubQuery(table, unionType);
    return this;
  }
}
