abstract class FluentModelBase<T> {
  String get tableName;
  String get primaryKey;
  dynamic get primaryKeyVal;

  Map<String, dynamic> toMap();
  T fromMap(Map<String, dynamic> map);
  //
  /// Todo implementar
  /*Future<RestResponseGeneric<T>> getAllT<T>(String apiEndPoint,
      {bool forceRefresh = false, String topNode, Map<String, String> headers, Map<String, String> queryParameters}) {
    throw UnimplementedError('This feature is not implemented yet.');
    return null;
  }*/
}
