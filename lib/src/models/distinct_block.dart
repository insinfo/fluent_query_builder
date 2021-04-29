import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';

class DistinctBlock extends Block {
  DistinctBlock(QueryBuilderOptions? options) : super(options);
  bool mIsDistinct = false;

  void setDistinct() {
    mIsDistinct = true;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    return mIsDistinct ? 'DISTINCT' : '';
  }
}
