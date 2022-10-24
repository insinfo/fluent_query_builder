import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:fluent_query_builder/src/models/validator.dart';
import 'package:fluent_query_builder/src/query_executors/utils.dart';

import 'where_node.dart';

/// WHERE
class WhereBlock extends Block {
  WhereBlock(QueryBuilderOptions options) : super(options);
  List<WhereNode> mWheres = <WhereNode>[];
  //coloca um arouba @ a mais no subistitution values para o Mysql

  void setStartGroup(String andOr) {
    mWheres.add(WhereNode('', type: WhereType.openGroup, andOr: andOr));
  }

  void setEndGroup() {
    mWheres.add(WhereNode('', type: WhereType.closeGroup));
  }

  /// Add a WHERE condition.
  /// @param condition Condition to add
  /// @param param Parameter to add to condition.
  /// @param <P> Type of the parameter to add.
  void setWhere(String condition, param, [String andOr = 'AND']) {
    //assert(condition != null);
    //doSetWhere(condition, param, andOr);
    mWheres.add(WhereNode(condition,
        param: param, andOr: andOr, type: WhereType.simple));
  }

  void setWhereRaw(String whereRawSql,
      {String andOr = 'AND', Map<String, dynamic>? substitutionValues}) {
    mWheres.add(WhereNode(whereRawSql,
        andOr: andOr,
        type: WhereType.raw,
        substitutionValues: substitutionValues));
  }

  void setWhereSafe(String field, String operator, value) {
    mWheres.add(WhereNode(field,
        param: value, operator: operator, andOr: 'AND', type: WhereType.safe));
  }

  void setOrWhereSafe(String field, String operator, value) {
    mWheres.add(WhereNode(field,
        param: value, operator: operator, andOr: 'OR', type: WhereType.safe));
  }

  void setWhereWithExpression(Expression condition, param,
      [String andOr = 'AND']) {
    mWheres.add(WhereNode(condition.toString(),
        param: param, andOr: andOr, type: WhereType.simple));
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mWheres.isEmpty) {
      return '';
    }

    final sb = StringBuffer();
    var length = mWheres.length;

    for (var i = 0; i < length; i++) {
      var whereNode = mWheres[i];
      var str = '';

      switch (whereNode.type) {
        case WhereType.simple:
          var left = ' ${whereNode.field} ';
          if (left.contains('?')) {
            var value = Validator.formatValue(whereNode.param, mOptions);
            left = left.replaceAll('?', value);
          }
          str += left;
          break;
        case WhereType.safe:
          str += ' ${whereNode.field} ';
          str += ' ${whereNode.operator} ';

          if (mOptions.driver == ConnectionDriver.pgsql) {
            var substitutionValue = Utils.getFieldName(whereNode.field);
            str += ' @$substitutionValue ';
          } else {
            str += ' ? ';
          }

          break;
        case WhereType.openGroup:
          str += ' ( ';
          break;
        case WhereType.closeGroup:
          str += ' ) ';
          break;
        case WhereType.raw:
          str += ' ${whereNode.field}';
          break;
      }

      if (i + 1 < length) {
        //se o proximo for abre grupo
        if (mWheres[i + 1].type == WhereType.openGroup) {
          str += ' ${mWheres[i + 1].andOr}   ';
        } else if (mWheres[i].type == WhereType.closeGroup) {
          str += ' ${mWheres[i + 1].andOr}   ';
        } else if (mWheres[i].type == WhereType.openGroup) {
          str += ' ';
        } else if (mWheres[i + 1].type == WhereType.closeGroup) {
          str += ' ';
        } else {
          str += ' ${mWheres[i + 1].andOr}  ';
        }
      }

      sb.write(str);
    }
    var result = 'WHERE $sb';
    //print('WhereBlock result: $result');
    return result;
  }

  @override
  Map<String, dynamic> buildSubstitutionValues() {
    final result = <String, dynamic>{};
    if (mWheres.isEmpty) {
      return result;
    }

    for (var item in mWheres) {
      if (item.type == WhereType.safe) {
        var v = item.param; //Validator.formatValue(item.param, mOptions);
        var substitutionValue = Utils.getFieldName(item.field);
        result.addAll({'$substitutionValue': v});
      } else if (item.type == WhereType.raw &&
          item.substitutionValues != null) {
        result.addAll(item.substitutionValues!);
      } else if (item.type == WhereType.simple &&
          item.substitutionValues != null) {
        result.addAll(item.substitutionValues!);
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

  /* void doSetWhere(String condition, param, [String andOr = 'AND']) {
    mWheres.add(WhereNode(condition, param, andOr: andOr,type: WhereType));
  }*/
}
