import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'union_type.dart';

class UnionNode {
  UnionNode(this.table, this.unionType);

  UnionNode.fromQuery(QueryBuilder table, this.unionType) {
    this.table = table;
  }
  Object? table; // String or QueryBuilder
  UnionType unionType;
}

/// UNION
class UnionBlock extends Block {
  UnionBlock(QueryBuilderOptions? options) : super(options);

  List<UnionNode>? mUnions;

  /// Add a UNION with the given table/query.
  /// @param table Name of the table or query to union with.
  /// @param unionType Type of the union.
  void setUnion(String table, UnionType unionType) {
    final tbl = Validator.sanitizeTable(table, mOptions!);
    ensureUnionsList();
    mUnions!.add(UnionNode(tbl, unionType));
  }

  void setUnionSubQuery(QueryBuilder table, UnionType unionType) {
    ensureUnionsList();
    mUnions!.add(UnionNode(table, unionType));
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mUnions == null || mUnions!.isEmpty) {
      return '';
    }

    final sb = StringBuffer();
    for (var j in mUnions!) {
      if (sb.length > 0) {
        sb.write(' ');
      }

      sb.write(unionTypeToSql(j.unionType));
      sb.write(' ');

      if (j.table is String) {
        sb.write(j.table);
      } else {
        sb.write('(');
        sb.write(j.table.toString());
        sb.write(')');
      }
    }

    return sb.toString();
  }

  void ensureUnionsList() {
    mUnions ??= [];
  }
}
