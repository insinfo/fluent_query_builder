import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'expression.dart';
import 'where_node.dart';

/// WHERE
class WhereBlock extends Block {
  WhereBlock(QueryBuilderOptions? options) : super(options);
  List<WhereNode> mWheres = <WhereNode>[];
  List<WhereRawNode> wheresRawSql = <WhereRawNode>[];

  void setStartGroup() {
    mWheres.add(WhereNode(null, null, groupDivider: '('));
  }

  void setEndGroup() {
    mWheres.add(WhereNode(null, null, groupDivider: ')'));
  }

  /// Add a WHERE condition.
  /// @param condition Condition to add
  /// @param param Parameter to add to condition.
  /// @param <P> Type of the parameter to add.
  void setWhere(String condition, param, [String andOr = 'AND']) {
    //assert(condition != null);
    doSetWhere(condition, param, andOr);
  }

  void setWhereRaw(String whereRawSql, [String andOr = 'AND']) {
    //assert(whereRawSql != null);

    wheresRawSql.add(WhereRawNode(whereRawSql, andOr));
  }

  void setWhereSafe(String field, String operator, value) {
    //assert(field != null);
    //assert(operator != null);
    //assert(value != null);

    mWheres.add(WhereNode(field, value, operator: operator, andOr: 'AND'));
  }

  void setOrWhereSafe(String field, String operator, value) {
    //assert(field != null);
    //assert(operator != null);
    //assert(value != null);

    mWheres.add(WhereNode(field, value, operator: operator, andOr: 'OR'));
  }

  void setWhereWithExpression(Expression condition, param, [String andOr = 'AND']) {
    //assert(condition != null);
    doSetWhere(condition.toString(), param, andOr);
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    final sb = StringBuffer();

    if (wheresRawSql.isNotEmpty) {
      for (var whereRaw in wheresRawSql) {
        if (sb.length > 0) {
          sb.write(' ${whereRaw.andOr} ');
        }
        sb.write(whereRaw.sqlString);
      }
      return 'WHERE $sb';
    }

    if (mWheres.isEmpty) {
      return '';
    }

    var length = mWheres.length;

    for (var i = 0; i < length; i++) {
      var where = mWheres[i];

      if (where.groupDivider == null) {
        if (where.operator == null) {
          sb.write(where.text!.replaceAll('?', Validator.formatValue(where.param, mOptions)!));
        } else {
          //text = collunm
          sb.write('${where.text}');
          sb.write(' ${where.operator} ');
          /* var substitutionValue = where.text;
          if (where?.text?.startsWith('"') == true) {
            substitutionValue = substitutionValue.substring(1).substring(0, substitutionValue.length - 2);
          }*/
          var substitutionValue = _getSubstitutionValue(where.text);
          sb.write('@$substitutionValue');
        }

        if (i < length - 1) {
          sb.write(' ${where.andOr} ');
        }
        //quando tiver grupo
      } else {
        if (where.groupDivider == ')') {
          var str = sb.toString();
          //print('WhereBlock@buildStr $str');
          if (str.toLowerCase().contains('or')) {
            var lastIndexOf = str.contains('OR') ? str.lastIndexOf('OR') : str.lastIndexOf('or');
            str = str.substring(0, lastIndexOf);
          }
          if (str.toLowerCase().contains('and')) {
            var lastIndexOf = str.contains('AND') ? str.lastIndexOf('AND') : str.lastIndexOf('and');
            str = str.substring(0, lastIndexOf);
          }

          sb.clear();
          var andOr = where.andOr;
          if (i == length - 1) {
            andOr = '';
          }
          sb.write(' $str ) $andOr ');
        } else {
          sb.write(' ${where.groupDivider} ');
        }
      }
    }

    return 'WHERE $sb';
  }

  String? _getSubstitutionValue(String? text) {
    var substitutionValue = text;
    if (text?.contains('.') == true) {
      var parts = text!.split('.');
      substitutionValue = parts[1];
    }
    if (text?.startsWith('"') == true && text?.endsWith('"') == true) {
      substitutionValue = substitutionValue!.substring(1, substitutionValue.length - 1);
    }
    return substitutionValue;
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    final result = <String, dynamic>{};
    if (mWheres.isEmpty) {
      return result;
    }

    for (var item in mWheres) {
      if (item.operator != null) {
        var v = Validator.formatValue(item.param, mOptions);

        /* var substitutionValue = item.text;
        if (item?.text?.startsWith('"') == true) {
          substitutionValue = substitutionValue.substring(1).substring(0, substitutionValue.length - 2);
        }*/
        var substitutionValue = _getSubstitutionValue(item.text);

        result.addAll({'$substitutionValue': v});
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

  void doSetWhere(String condition, param, [String andOr = 'AND']) {
    mWheres.add(WhereNode(condition, param, andOr: andOr));
  }
}
