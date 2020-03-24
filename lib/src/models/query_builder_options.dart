class QueryBuilderOptions {
  bool autoQuoteTableNames = true;
  bool autoQuoteFieldNames = true;
  bool autoQuoteAliasNames = true;
  bool replaceSingleQuotes = false;
  bool ignorePeriodsForFieldNameQuotes = false;
  bool dontQuote = false;
  String nameQuoteCharacter = '"';
  String tableAliasQuoteCharacter = '"';
  String fieldAliasQuoteCharacter = '"';
  String singleQuoteReplacement = "\'";
  String separator = " ";

  /// quote table and field string with dot, example:
  /// db.select().fields(['tablename.fieldname']).from('tablename') result in
  ///  SELECT "tablename"."fieldname" FROM tablename
  bool quoteStringWithFieldsTablesSeparator = true;
  String fieldsTablesSeparator = ".";

  /// allow alias in fields, example:
  /// db.select().fields(['tablename.fieldname as f']).from('tablename') result in
  ///  SELECT "tablename"."fieldname" as "f" FROM tablename
  bool allowAliasInFields = true;
}
