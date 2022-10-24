import 'package:fluent_query_builder/fluent_query_builder.dart';

/// (INSERT INTO) ... setField ... value
class InsertFieldValueBlock extends SetFieldBlockBase {
  //
  InsertFieldValueBlock(QueryBuilderOptions options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mFields == null || mFields!.isEmpty) {
      return '';
    }

    var fieldsName = StringBuffer();
    var fieldValuesForSubstitution = StringBuffer();

    for (var item in mFields!) {
      if (fieldsName.length > 0) {
        fieldsName.write(', ');
        fieldValuesForSubstitution.write(', ');
      }
      final field = item.field;
      //Validator.sanitizeField(item.field, mOptions!);
      if (mOptions.driver == ConnectionDriver.pgsql) {
        fieldValuesForSubstitution.write('@$field');
        fieldsName.write('"$field"');
      } else {
        fieldsName.write('`$field`');
        fieldValuesForSubstitution.write('?');
      }
    }
    final sql = '($fieldsName) VALUES ($fieldValuesForSubstitution)';
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

  // List<String> buildFieldValuesForSubstitution(List<SetNode> nodes) {
  //   final values = <String>[];

  //   for (var item in nodes) {
  //     var field = item.field;

  //     values.add('@$field');
  //   }
  //   return values;
  // }

  // List<String?> buildFieldValues(List<SetNode> nodes) {
  //   final values = <String?>[];
  //   for (var n in nodes) {
  //     values.add('${n.value}'); //Validator.formatValue(n.value, mOptions));
  //   }
  //   return values;
  // }

  // Object? formatValue(Object? value) {
  //   if (value == null) {
  //     return null;
  //   } else if (value is num) {
  //     return value.toString();
  //   } else if (value is String) {
  //     return value;
  //   } else if (value is QueryBuilder) {
  //     return '(${value.toSql()})';
  //   } else if (value is Expression) {
  //     return '(${value.toSql()})';
  //   } else if (value is List) {
  //     final results = [];
  //     for (var value in value) {
  //       results.add(formatValue(value));
  //     }
  //     return "(${results.join(', ')})";
  //   }
  //   return null;
  // }
}
