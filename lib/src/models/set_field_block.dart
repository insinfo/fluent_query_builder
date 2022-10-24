import 'package:fluent_query_builder/fluent_query_builder.dart';

/// (UPDATE) SET setField=value
class SetFieldBlock extends SetFieldBlockBase {
  SetFieldBlock(QueryBuilderOptions options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mFields != null && mFields!.isNotEmpty);
    //print('SetFieldBlock ${mOptions?.driver}');

    final sb = StringBuffer();
    for (var item in mFields!) {
      if (sb.length > 0) {
        sb.write(', ');
      }
      final field = item.field;
      ////Validator.sanitizeField(item.field, mOptions!);
      if (mOptions.driver == ConnectionDriver.pgsql) {
        sb.write('"$field"');
        sb.write(' = ');
        sb.write('@${item.field}');
      } else {
        sb.write('`$field`');
        sb.write(' = ');
        sb.write('?');
      }
    }

    return 'SET $sb';
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    final result = <String, dynamic>{};
    if (mFields == null || mFields!.isEmpty) {
      return result;
    }

    for (var item in mFields!) {
      var v = item.value;
      //formatValue(item.value);
      //Validator.formatValue(item.value, mOptions);
      result.addAll({'${item.field}': v});
    }
    return result;
  }

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
