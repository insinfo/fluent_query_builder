import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'expression.dart';

class WhereNode {
  WhereNode(this.text, this.param, {this.operator});
  final String text;
  final Object param;
  String operator;
}

/// WHERE
class OrWhereBlock extends Block {
  OrWhereBlock(QueryBuilderOptions options) : super(options);
  List<WhereNode> mWheres;
  List<String> wheresRawSql;

  /// Add a Or Where condition.
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

  void setWhereSafe(String field, String operator, value) {
    assert(field != null);
    assert(operator != null);
    assert(value != null);
    mWheres ??= [];
    mWheres.add(WhereNode(field, value, operator: operator));
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
          sb.write(' OR ');
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
        sb.write(') OR (');
      }
      if (where.operator == null) {
        sb.write(where.text.replaceAll('?', Validator.formatValue(where.param, mOptions)));
      } else {
        sb.write('${where.text}');
        sb.write(' ${where.operator} ');
        sb.write('@${where.text}');
      }
    }

    return 'WHERE ($sb)';
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    final result = <String, dynamic>{};
    if (mWheres == null || mWheres.isEmpty) {
      return result;
    }

    for (var item in mWheres) {
      if (item.operator != null) {
        var v = Validator.formatValue(item.param, mOptions);
        result.addAll({'${item.text}': v});
      }
    }

    return result;
  }

  /*List<String> buildFieldValuesForSubstitution(List<WhereNode> nodes) {
    final values = <String>[];
    for (var item in nodes) {
      if (item.operator != null) {
        values.add('@${item.text}');
      }
    }
    return values;
  }*/

  void doSetWhere(String condition, param) {
    mWheres ??= [];
    mWheres.add(WhereNode(condition, param));
  }
}
