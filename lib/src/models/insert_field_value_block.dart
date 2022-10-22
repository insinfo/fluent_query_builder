import 'expression.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';

import 'set_field_block_base.dart';

/// (INSERT INTO) ... setField ... value
class InsertFieldValueBlock extends SetFieldBlockBase {
  //
  InsertFieldValueBlock(QueryBuilderOptions options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mFields == null || mFields!.isEmpty) {
      return '';
    }

    final fields = buildFieldNames(mFields!).join(', ');
    final values = buildFieldValuesForSubstitution(mFields!).join(', ');
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
      var v = item.value; //Validator.formatValue(item.value, mOptions);
      result.addAll({'${item.field}': v});
    }

    return result;
  }

  List<String> buildFieldValuesForSubstitution(List<SetNode> nodes) {
    final values = <String>[];

    for (var item in nodes) {
      var field = item.field;

      values.add('@$field');
    }
    return values;
  }

  List<String> buildFieldNames(List<SetNode> nodes) {
    final names = <String>[];
    for (var item in nodes) {
      var field = item.field;

      //Validator.sanitizeField(item.field, mOptions!);

      names.add(field);
    }

    return names;
  }

  List<String?> buildFieldValues(List<SetNode> nodes) {
    final values = <String?>[];
    for (var n in nodes) {
      values.add('${n.value}'); //Validator.formatValue(n.value, mOptions));
    }
    return values;
  }

  Object? formatValue(Object? value) {
    if (value == null) {
      return null;
    } else if (value is num) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else if (value is QueryBuilder) {
      return '(${value.toSql()})';
    } else if (value is Expression) {
      return '(${value.toSql()})';
    } else if (value is List) {
      final results = [];
      for (var value in value) {
        results.add(formatValue(value));
      }
      return "(${results.join(', ')})";
    }
    return null;
  }
}
