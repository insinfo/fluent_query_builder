import 'query_builder_options.dart';
import 'query_builder.dart';
import 'set_field_block_base.dart';
import 'validator.dart';

/// (UPDATE) SET setField=value
class SetFieldBlock extends SetFieldBlockBase {
  SetFieldBlock(QueryBuilderOptions options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mFields != null && mFields.isNotEmpty);

    final sb = StringBuffer();
    for (var n in mFields) {
      if (sb.length > 0) {
        sb.write(', ');
      }

      sb.write(n.field);
      sb.write(' = ');
      sb.write(Validator.formatValue(n.value, mOptions));
    }

    return 'SET $sb';
  }
}
