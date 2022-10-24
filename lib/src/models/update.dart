import '../../fluent_query_builder.dart';

/// UPDATE query builder.
class Update extends QueryBuilder {
  Update(
    QueryBuilderOptions options, {
    Future<List<List>> Function()? execFunc,
    Future<Map<String, Map<String?, dynamic>>?> Function()?
        firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String?, dynamic>>>> Function()?
        getAsMapFuncWithMeta,
    Future<List?> Function()? firstFunc,
    Future<Map<String, dynamic>?> Function()? firstAsMapFunc,
    Future<List<Map<String, dynamic>>> Function()? getAsMapFunc,
    this.updateSingleFunc,
  }) : super(
          options,
          [
            StringBlock(options, 'UPDATE'),
            UpdateTableBlock(options), // 1
            SetFieldBlock(options), // 2
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
          // updateSingleFunc: updateSingleFunc,
        );

  Future Function<T>(T entity, [QueryBuilder? queryBuilder])? updateSingleFunc;

  @override
  QueryBuilder table(String? table, {String? alias}) {
    final block = mBlocks![1] as UpdateTableBlock;
    block.setTable(table, alias);
    return this;
  }

  @override
  Future updateSingle<T>(T entity, [QueryBuilder? queryBuilder]) {
    return updateSingleFunc!(entity, this);
  }

  @override
  QueryBuilder set(String fieldP, value) {
    final block = mBlocks![2] as SetFieldBlock;

    block.setFieldValue(fieldP, value);
    return this;
  }

  @override
  QueryBuilder setAll(Map<String, dynamic> fieldsAndValues) {
    final block = mBlocks![2] as SetFieldBlock;

    fieldsAndValues.forEach((fieldP, value) {
      block.setFieldValue(fieldP, value);
    });

    return this;
  }

  @override
  QueryBuilder where(String condition, [Object? param, String andOr = 'AND']) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhere(condition, param, andOr);
    return this;
  }

  @override
  QueryBuilder whereExpr(Expression condition,
      [Object? param, String andOr = 'AND']) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhereWithExpression(condition, param);
    return this;
  }

  @override
  QueryBuilder whereRaw(String whereRawSql,
      {String andOr = 'AND', Map<String, dynamic>? substitutionValues}) {
    final block = mBlocks![3] as WhereBlock;
    block.setWhereRaw(whereRawSql,
        andOr: andOr, substitutionValues: substitutionValues);
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
    final block = mBlocks![5] as WhereBlock;
    block.setStartGroup('AND');
    var r = function(this);
    block.setEndGroup();
    return r;
  }

  @override
  QueryBuilder orWhereGroup(QueryBuilder Function(QueryBuilder) function) {
    final block = mBlocks![5] as WhereBlock;
    block.setStartGroup('OR');
    var r = function(this);
    block.setEndGroup();
    return r;
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
