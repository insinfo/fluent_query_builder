import 'package:fluent_query_builder/src/builders/QBOptionBuilder.dart';
import 'package:fluent_query_builder/src/exceptions/null_pointer_exception.dart';

import 'models/query_builder_options.dart';

enum ConnectionDriver { mysql, pgsql }

class DBConnectionInfo {

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
  QueryBuilderOptions options;


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
        throw NullPointerException('Database Drive not selected');
      }
  }
    
  }

  QueryBuilderOptions getQueryOptions() {
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
