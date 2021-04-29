import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:test/test.dart';

import 'constants.dart';

DbLayer get db => _db;
late DbLayer _db;

var connectionInfo = DBConnectionInfo(
    host: 'localhost',
    database: 'banco_teste',
    driver: ConnectionDriver.pgsql,
    port: dbPort,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['public']);

void initializeTest() {
  setUp(() async {
    _db = DbLayer();

    await _db.connect(connectionInfo);
    //create DATABASE IF NOT EXISTS
    try {
      //CREATE DATABASE ${connectionInfo.database} WITH OWNER "${connectionInfo.username}" TEMPLATE=template0  ENCODING 'UTF8' LC_COLLATE = 'pt_BR.UTF-8' LC_CTYPE = 'pt_BR.UTF-8';
      await _db
          .raw(
              'CREATE DATABASE ${connectionInfo.database} WITH OWNER "${connectionInfo.username}" TEMPLATE=template0  ENCODING \'UTF8\' LC_COLLATE = \'pt_BR.UTF-8\' LC_CTYPE = \'pt_BR.UTF-8\';')
          .exec();
    } catch (e) {
      //
    }
    await _db.raw('DROP TABLE IF EXISTS pessoas').exec();
    //CREATE TABLE IF NOT EXISTS
    await _db.raw('CREATE TABLE pessoas (id serial, nome VARCHAR(200),telefone VARCHAR(200),cep VARCHAR(200));').exec();
    await _db.insert().into('pessoas').setAll({'nome': 'Isaque', 'telefone': '99701-5305', 'cep': '54654'}).exec();
  });

  tearDown(() async {
    await _db.close();
  });
}
