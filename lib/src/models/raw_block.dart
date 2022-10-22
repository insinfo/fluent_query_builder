import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'util.dart';

/// A String which always gets output
class RawBlock extends Block {
  RawBlock(QueryBuilderOptions options, String rawQueryString,
      {this.returningFields, this.substitutionValues})
      : super(options) {
    mText = rawQueryString;
  }

  String? mText;
  List<String?>? returningFields;
  Map<String, dynamic>? substitutionValues;

  @override
  String? buildStr(QueryBuilder queryBuilder) {
    assert(mText != null && !Util.isEmpty(mText));
    return mText;
  }

  @override
  List<String?>? buildReturningFields() {
    return returningFields;
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    return substitutionValues != null ? substitutionValues! : {};
  }
}
