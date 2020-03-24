import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';

class TableNode {
  TableNode(this.table, this.alias);
  final Object table; // String | QueryBuilder
  final String alias;
}

/// Table base class
abstract class TableBlockBase extends Block {
  TableBlockBase(QueryBuilderOptions options) : super(options);

  List<TableNode> mTables;

  void setTable(String table, String alias) {
    final tbl = Validator.sanitizeTable(table, mOptions);
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doSetTable(tbl, als);
  }

  void setTableFromQueryBuilder(QueryBuilder table, String alias) {
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doSetTable(table, als);
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mTables != null && mTables.isNotEmpty);

    final sb = StringBuffer();
    for (TableNode tab in mTables) {
      if (sb.length > 0) {
        sb.write(", ");
      }

      if (tab.table is String) {
        sb.write(tab.table.toString());
      } else {
        sb.write("(");
        sb.write(tab.table.toString());
        sb.write(")");
      }

      if (tab.alias != null) {
        sb.write(" ");
        sb.write(tab.alias);
      }
    }

    return sb.toString();
  }

  void doSetTable(Object table, String alias) {
    mTables ??= [];
    mTables.add(TableNode(table, alias));
  }
}
