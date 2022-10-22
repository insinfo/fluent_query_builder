import '../connection_info.dart';

class QueryBuilderOptions {
  ConnectionDriver driver = ConnectionDriver.pgsql;

  ///Indicates whether table names are rendered inside quotes. Default: TRUE.
  /// The quote character used is configurable via the `nameQuoteCharacter` option
  bool autoQuoteTableNames = true;

  ///Indicates whether field names are rendered inside quotes. Default: TRUE.
  // The quote character used is configurable via the nameQuoteCharacter option.
  bool autoQuoteFieldNames = true;

  /// Indicates whether alias names are rendered inside quotes. Default: TRUE.
  /// The quote character used is configurable via the `tableAliasQuoteCharacter` and `fieldAliasQuoteCharacter` options.
  bool autoQuoteAliasNames = true;

  /// Indicates whether to replaces all single quotes within strings. Default: FALSE.
  /// The replacement string used is configurable via the `singleQuoteReplacement` option.
  bool replaceSingleQuotes = false;

  /// Indicates whether to ignore period (.) when automatically quoting the `field` name. Default: FALSE.
  bool replaceDoubleQuotes = false;

  /// Indicates whether don't quote string values while formatting. Default: FALSE.
  bool ignorePeriodsForFieldNameQuotes = false;

  bool dontQuote = true;

  /// Specifies the quote character used for when quoting `table` and `field` names.
  String nameQuoteCharacter = '"';

  /// Specifies the quote character used for when quoting `table alias` names.
  String tableAliasQuoteCharacter = '"';

  String valueQuoteCharacter = "'";

  /// Specifies the quote character used for when quoting `field alias` names.
  String fieldAliasQuoteCharacter = '"';

  /// Specifies the string to replace single quotes with in query strings.
  String singleQuoteReplacement = "''";
  String doubleQuoteReplacement = '""';

  /// Specifies the string to join individual blocks in a query when it's stringified.
  String separator = ' ';

  /// quote table and field string with dot, example:
  /// db.select().fields(['tablename.fieldname']).from('tablename') result in
  ///  SELECT "tablename"."fieldname" FROM tablename
  bool quoteStringWithFieldsTablesSeparator = true;
  String fieldsTablesSeparator = '.';

  /// allow alias in fields, example:
  /// db.select().fields(['tablename.fieldname as f']).from('tablename') result in
  ///  SELECT "tablename"."fieldname" as "f" FROM tablename
  bool allowAliasInFields = true;

  QueryBuilderOptions clone() {
    return QueryBuilderOptions();
  }

  /*Map<String, dynamic> toMap() {
    return {
      'autoQuoteTableNames': autoQuoteTableNames,
      'autoQuoteFieldNames': autoQuoteFieldNames,
      'autoQuoteAliasNames': autoQuoteAliasNames,
      'replaceSingleQuotes': replaceSingleQuotes,
      'replaceDoubleQuotes': replaceDoubleQuotes,
      'ignorePeriodsForFieldNameQuotes': ignorePeriodsForFieldNameQuotes,
      'dontQuote': dontQuote,
      'nameQuoteCharacter': nameQuoteCharacter,
      'tableAliasQuoteCharacter': tableAliasQuoteCharacter,
      'fieldAliasQuoteCharacter': fieldAliasQuoteCharacter,
      'singleQuoteReplacement': singleQuoteReplacement,
      'doubleQuoteReplacement': doubleQuoteReplacement,
      'separator': separator,
      'quoteStringWithFieldsTablesSeparator':
          quoteStringWithFieldsTablesSeparator,
      'fieldsTablesSeparator': fieldsTablesSeparator,
      'allowAliasInFields': allowAliasInFields,
      'valueQuoteCharacter': valueQuoteCharacter
    };
  }*/
}
