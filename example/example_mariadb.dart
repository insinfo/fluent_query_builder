import 'dart:io';
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() async {
  //connection information
  final mariadbInfo = DBConnectionInfo(
    reconnectIfConnectionIsNotOpen: true,
    host: 'localhost',
    database: 'banco_teste',
    driver: ConnectionDriver.mysql,
    port: 3306,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    setNumberOfProcessorsFromPlatform: false,
    numberOfProcessors: 1,
  );

  final db = DbLayer();
  try {
    QueryBuilder query;
    dynamic result;
    print('try connect to mariadb');
    await db.connect(mariadbInfo);
    // delete table
    await db.execute('DROP TABLE IF EXISTS `table_01`');
    // create table
    await db.execute('''
CREATE TABLE `table_01` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `test` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
''');

    // delete table
    await db.execute('DROP TABLE IF EXISTS `table_02`');
    // create table
    await db.execute('''
CREATE TABLE `table_02` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtb1` int(255) DEFAULT NULL,
  `info` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
''');

    await db.delete().from('table_01').whereSafe('id', '=', 11).exec();
    await db.delete().from('table_02').whereSafe('id', '=', 22).exec();

    //INSERT INTO table_01(id, name) VALUES ('11','infomation in table 01');
    // INSERT query
    query =
        db.insertGetId().into('table_01').setAll({'id': 11, 'name': 'Isaque'});
    result = await query.exec();
    print('result insert: $result');

    // update query
    query = db
        .update()
        .whereSafe('id', '=', 11)
        .table('table_01')
        .setAll({'test': 'test', 'name': 'Isaque Neves'});

    print('update query sql: ${query.toSql()}');
    result = await query.exec();
    print('result update: $result');

    //INSERT INTO table_02(id, idtb1, info) VALUES ('22','11','infomation in table 02');
    query = db
        .insertGetId()
        .into('table_02')
        .setAll({'id': 22, '`idtb1`': 12, 'info': 'infomation in table 02'});

    result = await query.exec();
    print('result insert: $result');

    // select query
    query = db
        .select()
        .fields(['name', 'b.info', 'b.id'])
        .from('table_01', alias: 'a')
        .leftJoin('table_02', 'a.id', '=', 'b.`idtb1`', alias: 'b')
        .offset(0)
        .limit(100)
        .group('b.info')
        .order('b.info');

    print('select query sql: ${query.toSql()}');
    result = await query.getAsMap();

    print('result: $result');
  } catch (e, s) {
    print('catch connect $e $s');
  }

  exit(0);
}
// output
// PS C:\MyDartProjects\fluent_query_builder> dart .\example\example_mariadb.dart
// try connect to mariadb
// result insert: [[11]]
// update query sql: UPDATE table_01 SET test = @test, name = @name WHERE  id  =  @id 
// result update: []
// result insert: [[22]]
// select query sql: SELECT name, b.info, b.id FROM table_01 AS a LEFT JOIN table_02 AS b ON (a.id=b.`idtb1`) GROUP BY b.info ORDER BY b.info asc LIMIT 100 OFFSET 0
// result: [{name: Isaque Neves, info: null, id: null}]