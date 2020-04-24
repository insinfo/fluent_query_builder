import 'models/query_builder_options.dart';

enum ConnectionDriver { mysql, pgsql }

class DBConnectionInfo {
  DBConnectionInfo({
    this.driver,
    this.host,
    this.port,
    this.database,
    this.username,
    this.password,
    this.charset,
    this.schemes,
    this.prefix,
    this.sslmode,
    this.numberOfProcessors = 1,
    this.setNumberOfProcessorsFromPlatform = false,
  });
  String prefix = '';
  String sslmode = 'prefer';
  ConnectionDriver driver = ConnectionDriver.pgsql;
  String host = 'loalhost';
  int port;
  String database = 'postgres';
  String username = '';
  String password = '';
  String charset = 'utf8';
  List<String> schemes = ['public'];
  int numberOfProcessors = 1;
  bool setNumberOfProcessorsFromPlatform = false;

  DBConnectionInfo clone() {
    return DBConnectionInfo(
      driver: driver,
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      charset: charset,
      schemes: schemes,
      prefix: prefix,
      sslmode: sslmode,
      numberOfProcessors: numberOfProcessors,
      setNumberOfProcessorsFromPlatform: setNumberOfProcessorsFromPlatform,
    );
  }

  DBConnectionInfo getSettings() {
    var settings = clone();
    switch (driver) {
      case ConnectionDriver.pgsql:
        {
          settings.port ??= 5432;
          return settings;
        }
        break;
      case ConnectionDriver.mysql:
        {
          settings.port ??= 3306;
          return settings;
        }
        break;
      default:
        {
          return settings;
        }
    }
  }

  QueryBuilderOptions getQueryOptions() {
    var options = QueryBuilderOptions();
    options.autoQuoteTableNames = true;
    options.autoQuoteFieldNames = true;
    options.autoQuoteAliasNames = true;
    options.replaceSingleQuotes = false;
    options.replaceDoubleQuotes = false;
    options.ignorePeriodsForFieldNameQuotes = false;
    options.dontQuote = true;
    options.nameQuoteCharacter = '"';
    options.tableAliasQuoteCharacter = '"';
    options.fieldAliasQuoteCharacter = '"';
    options.singleQuoteReplacement = "''";
    options.doubleQuoteReplacement = '""';
    options.separator = ' ';
    options.quoteStringWithFieldsTablesSeparator = true;
    options.fieldsTablesSeparator = '.';
    options.allowAliasInFields = true;
    options.valueQuoteCharacter = "'";

    switch (driver) {
      case ConnectionDriver.pgsql:
        {
          return options;
        }
        break;
      case ConnectionDriver.mysql:
        {
          options.autoQuoteTableNames = false;
          options.autoQuoteFieldNames = false;
          options.autoQuoteAliasNames = true;
          options.replaceSingleQuotes = false;
          options.ignorePeriodsForFieldNameQuotes = false;
          options.dontQuote = false;
          options.nameQuoteCharacter = '`';
          options.tableAliasQuoteCharacter = '`';
          options.fieldAliasQuoteCharacter = '"';
          options.singleQuoteReplacement = "\'";
          options.separator = ' ';
          options.valueQuoteCharacter = '';
          return options;
        }
        break;
      default:
        {
          return options;
        }
    }
  }
}
