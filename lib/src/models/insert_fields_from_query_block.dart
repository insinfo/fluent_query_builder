import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';

import 'util.dart';

/// (INSERT INTO) ... setField ... (SELECT ... FROM ...)
class InsertFieldsFromQueryBlock extends Block {
  InsertFieldsFromQueryBlock(QueryBuilderOptions? options) : super(options);
  List<String>? mFields;
  QueryBuilder? mQuery;

  void setFromQuery(Iterable<String> fields, QueryBuilder query) {
    mFields = [];
    for (var field in fields) {
      mFields!.add(Validator.sanitizeField(field, mOptions!));
    }

    mQuery = query;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mFields == null || mFields!.isEmpty || mQuery == null) {
      return '';
    }
    return "(${Util.join(', ', mFields!)}) (${mQuery.toString()})";
  }
}
