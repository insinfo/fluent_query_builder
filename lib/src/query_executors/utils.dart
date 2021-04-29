class Utils {
  static List<Object?> substitutionMapToList(
      Map<String, dynamic>? substitutionValues) {
    var values = <Object?>[];
    if (substitutionValues != null) {
      if (substitutionValues.values.isNotEmpty) {
        for (var v in substitutionValues.values) {
          values.add(v);
        }
      }
    }
    return values;
  }
}
