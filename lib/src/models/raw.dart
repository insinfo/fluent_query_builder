import '../../fluent_query_builder.dart';
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

/// Raw query builder.
class Raw extends QueryBuilder {
  Raw(
    String rawQueryString, {
    QueryBuilderOptions options,
    Future<List<List>> Function() execFunc,
    Future<Map<String, Map<String, dynamic>>> Function() firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String, dynamic>>>> Function() getAsMapFuncWithMeta,
    Future<List> Function() firstFunc,
    Future<Map<String, dynamic>> Function() firstAsMapFunc,
    Future<List<Map<String, dynamic>>> Function() getAsMapFunc,
      Future<int> Function() countFunc,
  }) : super(
          options,
          [
            StringBlock(options, rawQueryString),
          ],
          execFunc: execFunc,
          firstAsMapFuncWithMeta: firstAsMapFuncWithMeta,
          getAsMapFuncWithMeta: getAsMapFuncWithMeta,
          firstFunc: firstFunc,
          firstAsMapFunc: firstAsMapFunc,
          getAsMapFunc: getAsMapFunc,
            countFunc: countFunc,
        );
}
