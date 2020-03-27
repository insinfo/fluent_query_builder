abstract class OrmModelBase {
  String get tableName;
  Map<String, dynamic> toMap();
  //T fromMap(Map<String, dynamic> json);
  /// Todo implementar
  /*Future<RestResponseGeneric<T>> getAllT<T>(String apiEndPoint,
      {bool forceRefresh = false, String topNode, Map<String, String> headers, Map<String, String> queryParameters}) {
    throw UnimplementedError('This feature is not implemented yet.');
    return null;
  }*/
}
