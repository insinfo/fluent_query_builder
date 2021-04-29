import 'query_builder.dart';
import 'block.dart';
import 'query_builder_options.dart';
import 'validator.dart';
import 'util.dart';

/// INTO table
class IntoTableBlock extends Block {
  IntoTableBlock(QueryBuilderOptions? options) : super(options);

  String? mTable;

  void setInto(String? table) {
    var tbl = Validator.sanitizeTable(table, mOptions!);
    mTable = tbl;
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mTable != null && !Util.isEmpty(mTable));
    return 'INTO $mTable';
  }
}
