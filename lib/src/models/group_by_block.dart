import 'block.dart';

import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'util.dart';

/// GROUP BY
class GroupByBlock extends Block {
  GroupByBlock(QueryBuilderOptions? options) : super(options);
  List<String>? mGroups;
  String? groupRawSql;

  void setGroups(Iterable<String> groups) {
    for (var field in groups) {
      setGroup(field);
    }
  }

  void setGroup(String field) {
    mGroups ??= [];
    var fieldValue = Validator.sanitizeField(field, mOptions!);
    if (mOptions!.quoteStringWithFieldsTablesSeparator) {
      if (fieldValue.contains(mOptions!.fieldsTablesSeparator)) {
        fieldValue = fieldValue
            .split(mOptions!.fieldsTablesSeparator)
            .map((f) => f)
            .join(
                '${mOptions!.fieldAliasQuoteCharacter}${mOptions!.fieldsTablesSeparator}${mOptions!.fieldAliasQuoteCharacter}');
      }
    }

    mGroups!.add(fieldValue);
  }

  void setGroupRaw(String groupRawSql) {
    this.groupRawSql = groupRawSql;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (groupRawSql != null) {
      return 'GROUP BY $groupRawSql';
    }
    if (mGroups == null || mGroups!.isEmpty) {
      return '';
    }
    return "GROUP BY ${Util.join(', ', mGroups!)}";
  }
}
