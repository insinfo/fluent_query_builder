import 'query_builder_options.dart';
import 'query_builder.dart';
import 'set_field_block_base.dart';
import 'validator.dart';

/// (UPDATE) SET setField=value
class SetFieldBlock extends SetFieldBlockBase {
  SetFieldBlock(QueryBuilderOptions? options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mFields != null && mFields!.isNotEmpty);

    final sb = StringBuffer();
    for (var item in mFields!) {
      if (sb.length > 0) {
        sb.write(', ');
      }

      var field = Validator.sanitizeField(item.field, mOptions!);

      sb.write(field);
      sb.write(' = ');
      sb.write('@${item.field}');
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
      var v = Validator.formatValue(item.value, mOptions);
      result.addAll({'${item.field}': v});
    }
    return result;
  }
}
