import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'expression.dart';

class WhereNode {
  WhereNode(this.text, this.param);
  final String text;
  final Object param;
}

/// WHERE
class WhereBlock extends Block {
  WhereBlock(QueryBuilderOptions options) : super(options);
  List<WhereNode> mWheres;
  List<String> wheresRawSql;

  /// Add a WHERE condition.
  /// @param condition Condition to add
  /// @param param Parameter to add to condition.
  /// @param <P> Type of the parameter to add.
  void setWhere(String condition, param) {
    assert(condition != null);
    doSetWhere(condition, param);
  }

  void setWhereRaw(String whereRawSql) {
    assert(whereRawSql != null);
    wheresRawSql ??= [];
    wheresRawSql.add(whereRawSql);
  }

  void setWhereWithExpression(Expression condition, param) {
    assert(condition != null);
    doSetWhere(condition.toString(), param);
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    final sb = StringBuffer();

    if (wheresRawSql != null) {
      for (var whereRaw in wheresRawSql) {
        if (sb.length > 0) {
          sb.write(' AND ');
        }

        sb.write(whereRaw);
      }
      return 'WHERE $sb';
    }

    if (mWheres == null || mWheres.isEmpty) {
      return '';
    }

    for (var where in mWheres) {
      if (sb.length > 0) {
        sb.write(') AND (');
      }

      sb.write(where.text
          .replaceAll('?', Validator.formatValue(where.param, mOptions)));
    }

    return 'WHERE ($sb)';
  }

  void doSetWhere(String condition, param) {
    mWheres ??= [];
    mWheres.add(WhereNode(condition, param));
  }
}
