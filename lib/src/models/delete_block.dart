import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'util.dart';

/// A Delete Block
class DeleteBlock extends Block {
  DeleteBlock(QueryBuilderOptions? options) : super(options);

  String mText = 'DELETE';

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(!Util.isEmpty(mText));
    return mText;
  }
}
