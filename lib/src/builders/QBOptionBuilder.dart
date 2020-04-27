import 'package:fluent_query_builder/fluent_query_builder.dart';

class QBOptionBuilder {
  QueryBuilderOptions _options;

  QBOptionBuilder() {
    _options.replaceDoubleQuotes = false;
    _options.ignorePeriodsForFieldNameQuotes = false;
    _options.fieldAliasQuoteCharacter = '"';
    _options.separator = ' ';
  }

  QBOptionBuilder.postgres() {
    _options = QueryBuilderOptions();
    _options.autoQuoteTableNames = true;
    _options.autoQuoteFieldNames = true;
    _options.autoQuoteAliasNames = true;
    _options.replaceSingleQuotes = false;
    _options.dontQuote = true;
    _options.nameQuoteCharacter = '"';
    _options.tableAliasQuoteCharacter = '"';
    _options.singleQuoteReplacement = "''";
    _options.valueQuoteCharacter = "'";
    _options.doubleQuoteReplacement = '""';
    _options.quoteStringWithFieldsTablesSeparator = true;
    _options.fieldsTablesSeparator = '.';
    _options.allowAliasInFields = true;
  }

  QBOptionBuilder.mysql() {
    _options = QueryBuilderOptions();
    _options.autoQuoteTableNames = false;
    _options.autoQuoteFieldNames = false;
    _options.autoQuoteAliasNames = true;
    _options.replaceSingleQuotes = false;
    _options.dontQuote = false;
    _options.nameQuoteCharacter = '`';
    _options.tableAliasQuoteCharacter = '`';
    _options.singleQuoteReplacement = "\'";
    _options.valueQuoteCharacter = '';
  }

  QueryBuilderOptions build() {
    return _options;
  }


}
