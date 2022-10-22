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
  bool useSSL;
  ConnectionDriver driver;
  String host;
  int port;
  String database;
  String username;
  String password;
  String? charset = 'utf8';
  List<String>? schemes = ['public'];
  int numberOfProcessors = 1;
  bool setNumberOfProcessorsFromPlatform = false;
  bool usePool = false;
  QueryBuilderOptions options = QbOptionBuilder.postgres().build();
  int timeoutInSeconds = 120;

  DBConnectionInfo({
    this.driver = ConnectionDriver.pgsql,
    this.host = 'loalhost',
    this.port = 5432,
    this.database = 'postgres',
    required this.username,
    required this.password,
    this.charset,
    this.schemes,
    this.prefix,
    this.useSSL = false,
    this.numberOfProcessors = 1,
    this.setNumberOfProcessorsFromPlatform = false,
    this.reconnectIfConnectionIsNotOpen = true,
    this.enablePsqlAutoSetSearchPath = true,
    this.timeoutInSeconds = 120,
  });

  DBConnectionInfo clone() {
    var opt = DBConnectionInfo(
      driver: driver,
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      charset: charset,
      schemes: schemes,
      prefix: prefix,
      useSSL: useSSL,
      numberOfProcessors: numberOfProcessors,
      setNumberOfProcessorsFromPlatform: setNumberOfProcessorsFromPlatform,
      reconnectIfConnectionIsNotOpen: reconnectIfConnectionIsNotOpen,
      enablePsqlAutoSetSearchPath: enablePsqlAutoSetSearchPath,
      timeoutInSeconds: timeoutInSeconds,
    );

    return opt;
  }

  DBConnectionInfo getSettings() {
    var settings = clone();
    return settings;
  }

  QueryBuilderOptions getQueryOptions() {
    if (driver == ConnectionDriver.pgsql) {
      options = QbOptionBuilder.postgres().build();
      return options;
    } else if (driver == ConnectionDriver.mysql) {
      options = QbOptionBuilder.mysql().build();
      return options;
    }

    throw NullPointerException('options | driver not selected');
  }
}
