import 'dart:io';
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() async {
  //connection information
  final psqlInfo = DBConnectionInfo(
      reconnectIfConnectionIsNotOpen: true,
      host: 'localhost',
      database: 'banco_teste',
      driver: ConnectionDriver.pgsql,
      port: 5432,
      username: 'sisadmin',
      password: 's1sadm1n',
      charset: 'utf8',
      setNumberOfProcessorsFromPlatform: false,
      numberOfProcessors: 1,
      enablePsqlAutoSetSearchPath: true,
      schemes: ['public']);
  final db = DbLayer(psqlInfo);
  try {
    QueryBuilder query;
    dynamic result;
    print('try connect to postgresql');
    await db.connect();

    await db.execute('DROP TABLE IF EXISTS "table_01"');

    await db.execute('''
      CREATE TABLE "public"."table_01" (
      "id" serial4 NOT NULL ,
      "name" varchar(255) ,
      "test" varchar(255) ,
      "date" timestamp ,
      "buleano" bool,
      CONSTRAINT "table_01_pkey" PRIMARY KEY ("id")
      );
    ''');

    await db.execute('DROP TABLE IF EXISTS "table_02"');

    await db.execute('''
      CREATE TABLE "public"."table_02" (
      "id" serial4 NOT NULL ,
      "idtb1" int4 ,
      "info" varchar(255) ,
      "idPessoa" int4 ,
      CONSTRAINT "table_02_pkey" PRIMARY KEY ("id")
      );
    ''');

    await db.delete().from('table_01').whereSafe('id', '=', 11).exec();
    await db.delete().from('table_02').whereSafe('id', '=', 22).exec();

    //INSERT INTO table_01(id, name) VALUES ('11','infomation in table 01');
    // INSERT query
    query = db
        .insertGetId()
        .into('table_01')
        .setAll({'id': 11, 'name': 'Isaque', 'buleano': true});
    print('insert query sql: ${query.toSql()}');
    result = await query.exec();
    print('result insert: $result');

    // update query
    query = db.update().whereSafe('id', '=', 11).table('table_01').setAll(
        {'test': 'sda', 'name': 'Isaque Neves', 'date': DateTime.now()});

    print('update query sql: ${query.toSql()}');
    result = await query.exec();
    print('result update: $result');

    //INSERT INTO table_02(id, idtb1, info) VALUES ('22','11','infomation in table 02');
    query = db.insertGetId().into('table_02').setAll({
      'id': 22,
      'idtb1': 11,
      'info': 'infomation in table 04',
      'idPessoa': 21
    });
    print('insert query sql: ${query.toSql()}');
    result = await query.exec();
    print('result insert: $result');

    query = db.update().whereSafe('id', '=', 22).table('table_02').setAll(
        {'idtb1': 11, 'info': 'infomation in table 02', 'idPessoa': 22});
    result = await query.exec();
    print('result update: $result');

    // select query
    query = db
        .select()
        .fields(['name', 'b.info', 'b.id', 'b."idPessoa"'])
        .from('table_01', alias: 'a')
        .leftJoin('table_02', 'a.id', '=', 'b.idtb1', alias: 'b')
        .offset(0)
        .limit(100)
        //.group('a.id')
        .order('b.info');

    print('select query sql: ${query.toSql()}');
    result = await query.getAsMap();

    print('result: $result');
  } catch (e, s) {
    print('catch connect $e $s');
  }

  exit(0);
}
