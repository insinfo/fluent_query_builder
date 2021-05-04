enum WhereType { group, raw, safe, simple }

class WhereNode {
  WhereNode(this.text, {this.param = '', this.operator = '', this.andOr = 'AND', this.type = WhereType.simple});
  final String text;
  Object param = '';
  String operator = '';
  String andOr;
  WhereType type = WhereType.simple;
}

class WhereRawNode {
  WhereRawNode(this.sqlString, [this.andOr = 'AND']);
  final String sqlString;
  final String andOr;
}
