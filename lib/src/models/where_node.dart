enum WhereType { openGroup, closeGroup, raw, safe, simple }

class WhereNode {
  WhereNode(
    this.field, {
    this.param = '',
    this.operator = '',
    this.andOr = 'AND',
    this.type = WhereType.simple,
    this.substitutionValues,
  });
  final String field;
  Object? param = '';
  String operator = '';
  String andOr;
  WhereType type = WhereType.simple;
  Map<String, dynamic>? substitutionValues;
}

class WhereRawNode {
  WhereRawNode(this.sqlString,
      [this.andOr = 'AND', Map<String, dynamic>? substitutionValues]);
  final String sqlString;
  final String andOr;
}
