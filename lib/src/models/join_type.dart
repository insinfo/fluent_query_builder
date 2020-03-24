/// JOIN type.
enum JoinType {
  INNER,
  LEFT,
  RIGHT,
  FULL,
  CROSS,
}

String joinTypeToSql(JoinType type) {
  String result;
  switch (type) {
    case JoinType.LEFT:
      result = 'LEFT';
      break;

    case JoinType.RIGHT:
      result = 'RIGHT';
      break;

    case JoinType.FULL:
      result = 'FULL';
      break;

    case JoinType.CROSS:
      result = 'CROSS';
      break;

    case JoinType.INNER:
    default:
      result = 'INNER';
      break;
  }

  return result;
}
