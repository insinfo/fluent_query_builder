import 'query_builder.dart';
import 'query_builder_options.dart';
import 'string_block.dart';
import 'into_table_block.dart';
import 'insert_field_value_block.dart';
import 'insert_fields_from_query_block.dart';

/// An INSERT query builder.
class Insert extends QueryBuilder {
  Insert(
    QueryBuilderOptions? options, {
    List<String?>? returningFields,
    Future<List<List?>?> Function()? execFunc,
    Future<Map<String, Map<String?, dynamic>>?> Function()? firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String?, dynamic>>>> Function()? getAsMapFuncWithMeta,
    Future<List?> Function()? firstFunc,
    Future<Map<String?, dynamic>?> Function()? firstAsMapFunc,
    Future<List<Map<String?, dynamic>>> Function()? getAsMapFunc,
    Future Function<T>(T entity)? putSingleFunc,
  }) : super(
          options,
          [
            StringBlock(options, 'INSERT', returningFields: returningFields),
            IntoTableBlock(options), // 1
            InsertFieldValueBlock(options), // 2
            InsertFieldsFromQueryBlock(options) // 3
          ],
          execFunc: execFunc,
          firstAsMapFuncWithMeta: firstAsMapFuncWithMeta,
          getAsMapFuncWithMeta: getAsMapFuncWithMeta,
          firstFunc: firstFunc,
          firstAsMapFunc: firstAsMapFunc,
          getAsMapFunc: getAsMapFunc,
          putSingleFunc: putSingleFunc,
        ) {
    ;
  }

  @override
  QueryBuilder into(String? table) {
    final block = mBlocks![1] as IntoTableBlock;
    block.setInto(table);
    return this;
  }

  @override
  QueryBuilder set(String field, value) {
    final block = mBlocks![2] as InsertFieldValueBlock;
    block.setFieldValue(field, value);
    return this;
  }

  @override
  QueryBuilder setAll(Map<String, dynamic>? fieldsAndValues) {
    final block = mBlocks![2] as InsertFieldValueBlock;
    fieldsAndValues?.forEach((field, value) {
      block.setFieldValue(field, value);
    });
    return this;
  }

  @override
  QueryBuilder fromQuery(Iterable<String> fields, QueryBuilder query) {
    final block = mBlocks![3] as InsertFieldsFromQueryBlock;
    block.setFromQuery(fields, query);
    return this;
  }
}
