import 'dart:io';

import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() async {
  final comInfo = DBConnectionInfo(
    enablePsqlAutoSetSearchPath: true,
    reconnectIfConnectionIsNotOpen: true,
    host: '192.168.133.13',
    database: 'test',
    driver: ConnectionDriver.pgsql,
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    setNumberOfProcessorsFromPlatform: false,
    numberOfProcessors: 1,
  );

  final db = await DbLayer().connect(comInfo);

  await db.raw('INSERT INTO products (name,price) VALUES (@name, @price)',
      substitutionValues: {'name': 'iPhone 6S', 'price': 2.50}).exec();

  /*await db
      .raw("INSERT INTO products (name,price) VALUES ('iPhone 6S', 5.50)")
      .exec();*/

  exit(0);
}
