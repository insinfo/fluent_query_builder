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

  /// get field name example : input = "schema"."table"."fieldname" return fieldname
  static String getFieldName(String text) {
    var substitutionValue = text;
    if (text.contains('.') == true) {
      var parts = text.split('.');
      substitutionValue = parts.last;
    }
    substitutionValue = substitutionValue.trim();
    if (substitutionValue.startsWith('"') == true &&
        substitutionValue.endsWith('"') == true) {
      substitutionValue =
          substitutionValue.substring(1, substitutionValue.length - 1);
    }

    return substitutionValue;
  }
}
