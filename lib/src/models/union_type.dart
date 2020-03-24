/// Specifies the type of UNION operation to combines the results of two SQL queries into a single table.

enum UnionType { UNION, UNION_ALL }

String unionTypeToSql(UnionType type) {
  String result;
  switch (type) {
    case UnionType.UNION_ALL:
      result = 'UNION ALL';
      break;

    case UnionType.UNION:
    default:
      result = 'UNION';
      break;
  }

  return result;
}
