import '../../lib/fluent_query_builder.dart';

abstract class DBConnectionInfoBuilder {
  static DBConnectionInfo build() {
    return DBConnectionInfo(
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
}