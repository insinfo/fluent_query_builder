import 'package:fluent_query_builder/src/builders/QBOptionBuilder.dart';
import 'package:fluent_query_builder/src/exceptions/null_pointer_exception.dart';

import 'models/query_builder_options.dart';

enum ConnectionDriver { mysql, pgsql }

class DBConnectionInfo {
  ///enable execution of query 'set search_path to schemes' on open connection
  bool enablePsqlAutoSetSearchPath = true;

  /// reconnect if connection is not open
  ///PostgreSQLSeverity.error : Attempting to execute query, but connection is not open
  bool reconnectIfConnectionIsNotOpen = true;

  String? prefix = '';
  String? sslmode = 'prefer';
  ConnectionDriver driver;
  String host;
  int? port;
  String database;
  String username;
  String password;
  String? charset = 'utf8';
  List<String>? schemes = ['public'];
  int numberOfProcessors = 1;
  bool setNumberOfProcessorsFromPlatform = false;
  QueryBuilderOptions? options;

  DBConnectionInfo({
    this.driver = ConnectionDriver.pgsql,
    this.host = 'loalhost',
    this.port,
    this.database = 'postgres',
    this.username = '',
    this.password = '',
    this.charset,
    this.schemes,
    this.prefix,
    this.sslmode,
    this.numberOfProcessors = 1,
    this.setNumberOfProcessorsFromPlatform = false,
    this.reconnectIfConnectionIsNotOpen = true,
    this.enablePsqlAutoSetSearchPath = true,
  });

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
      reconnectIfConnectionIsNotOpen: reconnectIfConnectionIsNotOpen,
      enablePsqlAutoSetSearchPath: enablePsqlAutoSetSearchPath,
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
      case ConnectionDriver.mysql:
        {
          settings.port ??= 3306;
          return settings;
        }
      default:
        {
          throw NullPointerException('Database Drive not selected');
        }
    }
  }

  QueryBuilderOptions? getQueryOptions() {
    if (options == null) {
      switch (driver) {
        case ConnectionDriver.pgsql:
          {
            options = QbOptionBuilder.postgres().build();
          }
          break;
        case ConnectionDriver.mysql:
          {
            options = QbOptionBuilder.mysql().build();
          }
          break;
        default:
          {
            throw NullPointerException('Database drive not selected');
          }
      }
    }
    return options;
  }
}
