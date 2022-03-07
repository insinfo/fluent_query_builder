import 'dart:async';
import 'dart:io';

import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:postgres/postgres.dart';

void main() async {
  final comInfo = DBConnectionInfo(
    enablePsqlAutoSetSearchPath: true,
    reconnectIfConnectionIsNotOpen: true,
    host: '192.168.133.13',
    database: 'sistemas',
    driver: ConnectionDriver.pgsql,
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['jubarte', 'pmro_padrao'],
    setNumberOfProcessorsFromPlatform: false,
    numberOfProcessors: 1,
  );
  /*var db = PostgreSQLConnection(
    comInfo.host,
    5432,
    comInfo.database,
    username: comInfo.username,
    password: comInfo.password,
  );
  await db.open();
  var p = await db
      .mappedResultsQuery('SELECT * FROM pmro_padrao.pessoas WHERE id=1');
  // print(p);

  await db.transaction((ctx) async {
    await ctx.query(
        "INSERT INTO pmro_padrao.pessoas (nome,tipo5) VALUES ('Joao das coves teste','Fisica')");
  });*/
  final db = await DbLayer().connect(comInfo);
  /*await db.startTransaction();
  var re;
  try {
    re = await db
        .insert()
        .into('pessoas')
        .setAll({'nome': 'Joao das coves teste', 'tipo': 'Fisica'}).exec();
    re = await db
        .insert()
        .into('pessoas')
        .setAll({'nome': 'Joao das coves teste 2', 'tipo2': 'Fisica'}).exec();
    await db.commit();
  } catch (_) {
    await db.rollback();
    rethrow;
  }*/

  // var p = await db.select().from('pessoas').whereSafe('id', '=', 1).firstAsMap();
  // print(p);

// ignore: unused_local_variable
  Timer.periodic(Duration(seconds: 3), (timer) async {
    var re;
    try {
      await db.transaction((ctx) async {
        await ctx
            .insert()
            .into('pessoas')
            .setAll({'nome': 'Joao das coves teste', 'tipo': 'Fisica'}).exec();

        await ctx.insert().into('pessoas').setAll(
            {'nome': 'Joao das coves teste 2', 'tipo2': 'Fisica'}).exec();
      });
    } catch (e) {
      //
      print('error: $e');
      var p = await db
          .select()
          .fieldRaw('nome')
          .from('pessoas')
          .whereSafe('id', '=', 1)
          .firstAsMap();
      print(p);
    }
    print('end ');
    //exit(0);
  });
}
