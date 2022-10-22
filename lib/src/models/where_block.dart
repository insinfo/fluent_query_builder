import 'block.dart';
import 'query_builder_options.dart';
import 'query_builder.dart';

import 'expression.dart';
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

  void setWhereRaw(String whereRawSql, [String andOr = 'AND']) {
    mWheres.add(WhereNode(whereRawSql, andOr: andOr, type: WhereType.raw));
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
          var left = ' ${whereNode.text} ';
          if (left.contains('?')) {
            left = left.replaceAll('?', '${whereNode.param}');
            //Validator.formatValue(whereNode.param, mOptions)
          }
          str += left;
          //str += ' ${whereNode.operator} ';
          break;
        case WhereType.safe:
          str += ' ${whereNode.text} ';
          str += ' ${whereNode.operator} ';
          var substitutionValue = _getSubstitutionValue(whereNode.text);
          str += ' @$substitutionValue ';
          break;
        case WhereType.openGroup:
          str += ' ( ';
          break;
        case WhereType.closeGroup:
          str += ' ) ';
          break;
        case WhereType.raw:
          str += ' ${whereNode.text}';
          break;
      }
      /* if (i + 1 < length) {
        if (mWheres[i + 1].type == WhereType.group &&
            mWheres[i + 1].text.contains('(')) {
          // str += ' ${mWheres[i + 1].andOr} ';
          //print('o proximo é grupo abre');
        } else if (mWheres[i + 1].type == WhereType.group &&
            mWheres[i + 1].text.contains(')')) {
          //print('o proximo é grupo fecha');
        } else if (mWheres[i].type != WhereType.group) {
          if (!mWheres[i + 1].text.contains(')')) {
            // str += ' ${whereNode.andOr} ';
            // print('o item atual não é grupo ${mWheres[i].text} ${mWheres[i + 1].text}');
          }
        } else if (mWheres[i].type == WhereType.group &&
            mWheres[i].text.contains(')') &&
            mWheres[i + 1].type != WhereType.group) {
          //str += ' ${whereNode.andOr} ';
        }
      }*/

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

      /*if (i + 1 < length &&
          whereNode.type != WhereType.group &&
          mWheres[i + 1].type != WhereType.group) {
        str += ' ${whereNode.andOr}  ';
        //print('mWheres[i].type == WhereType.raw): ${whereNode.andOr} ');
      }*/

      sb.write(str);
    }
    var result = 'WHERE $sb';
    //print('WhereBlock result: $result');
    return result;
  }

  String? _getSubstitutionValue(String? text) {
    var substitutionValue = text;
    if (text?.contains('.') == true) {
      var parts = text!.split('.');
      substitutionValue = parts[1];
    }
    substitutionValue = substitutionValue?.trim();
    if (substitutionValue?.startsWith('"') == true &&
        substitutionValue?.endsWith('"') == true) {
      substitutionValue =
          substitutionValue!.substring(1, substitutionValue.length - 1);
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
      if (item.type == WhereType.safe) {
        var v = item.param; //Validator.formatValue(item.param, mOptions);

        /* var substitutionValue = item.text;
        if (item?.text?.startsWith('"') == true) {
          substitutionValue = substitutionValue.substring(1).substring(0, substitutionValue.length - 2);
        }*/
        var substitutionValue = _getSubstitutionValue(item.text);

        result.addAll({'$substitutionValue': '$v'});
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
