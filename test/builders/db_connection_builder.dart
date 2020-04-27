import 'package:fluent_query_builder/fluent_query_builder.dart';

class DbConnectionBuilder {

  DBConnectionInfo _connection;

  DbConnectionBuilder() {
    _connection = DBConnectionInfo(
        host: '192.168.133.13',
        database: 'banco_teste',
        driver: ConnectionDriver.pgsql,
        port: 5432,
        username: 'sisadmin',
        password: 's1sadm1n',
        charset: 'utf8',
        schemes: ['public']
    );
  }

  DBConnectionInfo build() {
    return _connection;
  }

  DbConnectionBuilder withHost({String host}) {
    _connection.host = host ?? 'localhost';
    return this;
  }

  DbConnectionBuilder withDatabase({String database}) {
    _connection.database = database;
    return this;
  }

  DbConnectionBuilder withDriver({ConnectionDriver driver}) {
    _connection.driver = driver;
    return this;
  }

  DbConnectionBuilder withPort({int port}) {
    _connection.port = port;
    return this;
  }

  DbConnectionBuilder withUsername({String username}) {
    _connection.username = username;
    return this;
  }

  DbConnectionBuilder withPassoword({String password}) {
    _connection.password = password;
    return this;
  }

  DbConnectionBuilder withCharset({String charset}) {
    _connection.charset = charset;
    return this;
  }

  DbConnectionBuilder withNullDrive() {
    _connection.driver = null;
    return this;
  }

  DbConnectionBuilder withNullPort() {
    _connection.port = null;
    return this;
  }

  DbConnectionBuilder withNullUsername() {
    _connection.username = null;
    return this;
  }

  DbConnectionBuilder withNullPassword() {
    _connection.password = null;
    return this;
  }

  DbConnectionBuilder withNullCharset() {
    _connection.charset = null;
    return this;
  }



}
