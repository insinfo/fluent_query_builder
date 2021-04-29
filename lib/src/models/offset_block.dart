import 'block.dart';
import 'query_builder.dart';
import 'query_builder_options.dart';

/// OFFSET x
class OffsetBlock extends Block {
  OffsetBlock(QueryBuilderOptions? options) : super(options);
  int? mOffset;

  void setOffset(int value) {
    assert(value >= 0);
    mOffset = value;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    return mOffset != null ? 'OFFSET $mOffset' : '';
  }
}
