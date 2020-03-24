import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'union_type.dart';
import 'set_field_block_base.dart';
import 'util.dart';

/// (INSERT INTO) ... setField ... value
class InsertFieldValueBlock extends SetFieldBlockBase {
  InsertFieldValueBlock(QueryBuilderOptions options) : super(options);

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mFields == null || mFields.isEmpty) {
      return "";
    }

    final String fields = Util.join(", ", buildFieldNames(mFields));
    final String values = Util.join(", ", buildFieldValues(mFields));

    return "($fields) VALUES ($values)";
  }

  List<String> buildFieldNames(List<SetNode> nodes) {
    final List<String> names = [];
    for (SetNode n in nodes) {
      names.add(n.field);
    }
    return names;
  }

  List<String> buildFieldValues(List<SetNode> nodes) {
    final List<String> values = [];
    for (SetNode n in nodes) {
      values.add(Validator.formatValue(n.value, mOptions));
    }
    return values;
  }
}
