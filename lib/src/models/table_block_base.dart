import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';

class TableNode {
  TableNode(this.table, this.alias, {this.fromRawSql});
  final Object? table; // String | QueryBuilder
  final String? alias;
  String? fromRawSql;
}

/// Table base class
abstract class TableBlockBase extends Block {
  TableBlockBase(QueryBuilderOptions? options) : super(options);

  List<TableNode>? mTables;

  void setTable(String? table, String? alias) {
    final tbl = Validator.sanitizeTable(table, mOptions!);
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doSetTable(tbl, als);
  }

  void setTableFromQueryBuilder(QueryBuilder table, String? alias) {
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doSetTable(table, als);
  }

  void setFromRaw(String fromRawSqlString) {
    //fromRawSQL = fromRawSqlString;
    mTables ??= [];
    mTables!.add(TableNode(null, null, fromRawSql: fromRawSqlString));
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    assert(mTables != null && mTables!.isNotEmpty);

    final sb = StringBuffer();
    for (var tab in mTables!) {
      if (tab.fromRawSql == null) {
        if (sb.length > 0) {
          sb.write(', ');
        }

        if (tab.table is String) {
          sb.write(tab.table.toString());
        } else {
          sb.write('(');
          sb.write(tab.table.toString());
          sb.write(')');
        }

        if (tab.alias != null) {
          sb.write(' ');
          sb.write(tab.alias);
        }
      } else {
        sb.write(' ');
        sb.write(tab.fromRawSql);
      }
    }

    return sb.toString();
  }

  void doSetTable(Object? table, String? alias) {
    mTables ??= [];
    mTables!.add(TableNode(table, alias));
  }
}
