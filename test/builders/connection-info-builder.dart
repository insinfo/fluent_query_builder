import 'package:fluent_query_builder/fluent_query_builder.dart';


class DBConnectionInfoBuilder {

  DBConnectionInfo _dbInfo;

  DBConnectionInfoBuilder.init() {
    var builder = this;
    builder._dbInfo = DBConnectionInfo(
        driver: ConnectionDriver.pgsql,
        host: 'localhost',
        port: 5432,
        database: 'postgres',
        username: 'postgres',
        password: 'postgres',
        charset: 'utf8',
        schemes: ['public'],
        numberOfProcessors: 1,
        setNumberOfProcessorsFromPlatform: false
    );
  }

  DBConnectionInfo build() {
    return _dbInfo;
  }
}