abstract class FluentModelBase<T> {
  Map<String, dynamic> toMap();
  //T fromMap(Map<String, dynamic> map);

  OrmDefinitions get ormDefinitions;
  //
  /// Todo implementar
  /*Future<RestResponseGeneric<T>> getAllT<T>(String apiEndPoint,
      {bool forceRefresh = false, String topNode, Map<String, String> headers, Map<String, String> queryParameters}) {
    throw UnimplementedError('This feature is not implemented yet.');
    return null;
  }*/
}

/// define orm settings
/// @param tableName => the table name of model
/// @param primaryKey => The primary key associated with the table.
/// @param primaryKeyVal => The value of primaryKey
class OrmDefinitions {
  OrmDefinitions({
    this.tableName,
    this.primaryKey,
    this.idIncrementing = true,
    this.keyType = 'integer',
    this.attributes,
    this.fillable,
    this.guarded,
    this.relations,
  });

  OrmDefinitions clone() {
    var definitions = OrmDefinitions();
    definitions.tableName = tableName;
    definitions.primaryKey = primaryKey;
    definitions.idIncrementing = idIncrementing;
    definitions.keyType = keyType;
    definitions.attributes = attributes;
    definitions.fillable = fillable;
    definitions.guarded = guarded;
    definitions.relations = relations;
    definitions.data = data;
    definitions.primaryKeyVal = primaryKeyVal;
    return definitions;
  }

  /// supports several different types of relationships
  List<OrmRelation>? relations;

  Map<String, dynamic>? data;
  dynamic primaryKeyVal;

  /// the data of model to insert or update on database
  //Map<String, dynamic> data;

  /// the table name of model
  String? tableName;

  /// The primary key associated with the table.
  String? primaryKey;

  /// Indicates if the IDs are auto-incrementing.
  bool idIncrementing = true;

  /// The "type" of the auto-incrementing ID.
  String keyType = 'integer'; //string | num
  /// Indicates if the model should be timestamped.
  /// $timestamps = false;
  /// The storage format of the model's date columns.
  /// dateFormat = 'U';
  /// const CREATED_AT = 'creation_date';
  /// const UPDATED_AT = 'last_update';
  /// The connection name for the model.
  /// connection = 'connection-name';
  /// The model's default values for attributes.
  List<Map<String, dynamic>>? attributes;

  /// The attributes that are mass assignable.
  /// Example fillable = ['name'];
  /// A mass-assignment vulnerability occurs when a user passes an unexpected HTTP parameter through a request, and that parameter changes a column in your database you did not expect. For example, a malicious user might send an is_admin parameter through an HTTP request, which is then passed into your model's create method, allowing the user to escalate themselves to an administrator.
  /// While $fillable serves as a "white list" of attributes that should be mass assignable
  /// Importantly, you should use either $fillable or $guarded - not both.
  /// In the example below, all attributes
  List<String>? fillable;

  /// The attributes that aren't mass assignable.
  /// you may also choose to use $guarded. The $guarded property should contain an array of
  /// attributes that you do not want to be mass assignable. All other attributes not in
  /// the array will be mass assignable. So, $guarded functions like a "black list".
  /// Importantly, you should use either $fillable or $guarded - not both.
  /// In the example below, all attributes
  List<String>? guarded;

  bool isRelations() {
    return relations?.isNotEmpty == true;
  }
}

/// Um a um | Um para muitos | Muitos para muitos
enum OrmRelationType { oneToOne, belongsTo, oneToMany, manyToMany }

/// @param tableRelation => the table name of related model example: pessoas
/// @param foreignKey => foreign key example: idPessoa
/// @param localKey => local Key example: id
/// @param relationType => different types of relationships one To One | one To Many | many To Many
class OrmRelation {
  OrmRelation(this.tableRelation, this.foreignKey, this.localKey, this.relationType, this.relationName);

  /// model name example: phone
  final String tableRelation;

  final String relationName;

  /// foreign Key example: user_id
  final String foreignKey;

  /// local Key example: id
  final String localKey;

  /// different types of relationships one To One | one To Many | many To Many
  final OrmRelationType relationType;

  Map<String, dynamic>? data = <String, dynamic>{};

  /*Map<String, dynamic> get data => _data;
  set data(Map<String, dynamic> d) => _data = d;*/
}
