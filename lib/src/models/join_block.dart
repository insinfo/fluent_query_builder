import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'join_type.dart';
import 'validator.dart';
import 'expression.dart';
import 'util.dart';

class JoinNode {
  JoinNode(this.table, this.alias, this.condition, this.type);
  final JoinType type;
  final Object? table; // String | QueryBuilder
  final String? alias;
  final Object condition; // String | Expression
}

/// JOIN
class JoinBlock extends Block {
  JoinBlock(QueryBuilderOptions? options) : super(options);
  List<JoinNode> mJoins = <JoinNode>[];

  /// Add a JOIN with the given table.
  /// @param table Name of the table to setJoin with.
  /// @param alias Optional alias for the table name.
  /// @param condition Optional condition (containing an SQL expression) for the JOIN.
  /// @param type Join Type.
  void setJoin(String table, String? alias, String condition, JoinType type) {
    final tbl = Validator.sanitizeTable(table, mOptions!);
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doJoin(tbl, als, condition, type);
  }

  void setJoinWithExpression(String table, String? alias, Expression condition, JoinType type) {
    final tbl = Validator.sanitizeTable(table, mOptions!);
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doJoin(tbl, als, condition, type);
  }

  void setJoinWithSubQuery(QueryBuilder table, String? alias, String condition, JoinType type) {
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doJoin(table, als, condition, type);
  }

  void setJoinWithQueryWithExpr(QueryBuilder table, String? alias, Expression condition, JoinType type) {
    final als = Validator.sanitizeTableAlias(alias, mOptions);
    doJoin(table, als, condition, type);
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mJoins.isEmpty) {
      return '';
    }

    final sb = StringBuffer();
    for (var j in mJoins) {
      if (sb.length > 0) {
        sb.write(' ');
      }

      sb.write(joinTypeToSql(j.type));
      sb.write(' JOIN ');

      if (j.table is String) {
        sb.write(j.table);
      } else {
        sb.write('(');
        sb.write(j.table.toString());
        sb.write(')');
      }

      if (!Util.isEmpty(j.alias)) {
        sb.write(' ');
        sb.write(j.alias);
      }

      String conditionStr;
      if (j.condition is String) {
        conditionStr = j.condition.toString();
      } else {
        conditionStr = j.condition.toString();
      }

      if (!Util.isEmpty(conditionStr)) {
        sb.write(' ON (');
        sb.write(conditionStr);
        sb.write(')');
      }
    }

    return sb.toString();
  }

  void doJoin(Object? table, String? alias, Object condition, JoinType? type) {
    var t = type;
    t ??= JoinType.INNER;
    mJoins.add(JoinNode(table, alias, condition, t));
  }
}
