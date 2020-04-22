class WhereNode {
  WhereNode(this.text, this.param,
      {this.operator, this.groupDivider, this.andOr = 'AND'});
  final String text;
  final Object param;
  String operator;
  String groupDivider;
  String andOr;
}

class WhereRawNode {
  WhereRawNode(this.sqlString, [this.andOr = 'AND']);
  final String sqlString;
  final String andOr;
}
