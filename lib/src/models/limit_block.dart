import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';

/// LIMIT
class LimitBlock extends Block {
  LimitBlock(QueryBuilderOptions? options) : super(options);
  int? mLimit;

  void setLimit(int value) {
    assert(value >= 0);
    mLimit = value;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    return mLimit != null ? 'LIMIT $mLimit' : '';
  }
}
