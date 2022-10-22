import '../../fluent_query_builder.dart';

/// Raw query builder.
class Raw extends QueryBuilder {
  Raw(
    String rawQueryString,
    QueryBuilderOptions options, {
    Map<String, dynamic>? substitutionValues,
    Future<List<List>> Function()? execFunc,
    Future<Map<String, Map<String?, dynamic>>?> Function()?
        firstAsMapFuncWithMeta,
    Future<List<Map<String, Map<String?, dynamic>>>> Function()?
        getAsMapFuncWithMeta,
    Future<List?> Function()? firstFunc,
    Future<Map<String, dynamic>?> Function()? firstAsMapFunc,
    Future<List<Map<String, dynamic>>> Function()? getAsMapFunc,
    Future<int> Function()? countFunc,
  }) : super(
          options,
          [
            RawBlock(options, rawQueryString,
                substitutionValues: substitutionValues),
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
