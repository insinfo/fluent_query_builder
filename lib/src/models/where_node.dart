class WhereNode {
  WhereNode(this.text, this.param, {this.operator,this.groupDivider});
  final String text;
  final Object param;
  String operator;
  String groupDivider;
}