import 'query_builder.dart';
import 'query_builder_options.dart';

abstract class Block {
  Block(QueryBuilderOptions options) {
    mOptions = options ?? QueryBuilderOptions();
    //mOptions = options != null ? options :  QueryBuilderOptions();
  }

  QueryBuilderOptions mOptions;
  String buildStr(QueryBuilder queryBuilder);
}
