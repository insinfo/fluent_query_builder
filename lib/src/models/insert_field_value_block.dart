import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';

import 'set_field_block_base.dart';
import 'util.dart';

/// (INSERT INTO) ... setField ... value
class InsertFieldValueBlock extends SetFieldBlockBase {
  InsertFieldValueBlock(QueryBuilderOptions? options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mFields == null || mFields!.isEmpty) {
      return '';
    }

    final fields = Util.join(', ', buildFieldNames(mFields!));

    final values = Util.join(', ', buildFieldValuesForSubstitution(mFields!));

    var sql = '($fields) VALUES ($values)';

    return sql;
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    final result = <String, dynamic>{};
    if (mFields == null || mFields!.isEmpty) {
      return result;
    }

    for (var item in mFields!) {
      var v = Validator.formatValue(item.value, mOptions);
      result.addAll({'${item.field}': v});
    }

    return result;
  }

  List<String> buildFieldValuesForSubstitution(List<SetNode> nodes) {
    final values = <String>[];
    for (var item in nodes) {
      values.add('@${item.field}');
    }
    return values;
  }

  List<String> buildFieldNames(List<SetNode> nodes) {
    final names = <String>[];
    for (var item in nodes) {
      var field = Validator.sanitizeField(item.field, mOptions!);

      names.add(field);
    }

    return names;
  }

  List<String?> buildFieldValues(List<SetNode> nodes) {
    final values = <String?>[];
    for (var n in nodes) {
      values.add(Validator.formatValue(n.value, mOptions));
    }
    return values;
  }
}
