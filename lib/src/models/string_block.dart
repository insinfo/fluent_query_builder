import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'util.dart';

/// A String which always gets output
class StringBlock extends Block {
  
  StringBlock(QueryBuilderOptions options, String str) : super(options) {
    mText = str;
  }

  String mText;

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mText != null && !Util.isEmpty(mText));
    return mText;
  }
}
