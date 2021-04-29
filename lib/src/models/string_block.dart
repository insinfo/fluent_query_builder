import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'util.dart';

/// A String which always gets output
class StringBlock extends Block {
  StringBlock(QueryBuilderOptions? options, String str, {this.returningFields}) : super(options) {
    mText = str;
  }

  String? mText;
  List<String?>? returningFields;

  @override
  String? buildStr(QueryBuilder queryBuilder) {
    assert(mText != null && !Util.isEmpty(mText));
    return mText;
  }

  @override
  List<String?>? buildReturningFields() {
    return returningFields;
  }
}
