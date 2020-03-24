A dart library that allows you to execute SQL queries in the PostgreSQL database in a fluent way, is very easy to execute.
This library implements POOL of connections.
This lib implements the vast majority of SQL statements and clauses

Soon it will also support mysql and ORM without reflection and without code generation in a simple and consistent way.

## Usage

A simple usage example:

```dart
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() {
  final com = DBConnectionInfo(
    host: 'localhost',
    database: 'test',
    port: 5432,
    username: 'root',
    password: '123456',
    charset: 'utf8',
    schemes: ['public'],
  );

  DBLayer.connect(com).then((db) {
    final query = db
        .select()
        //.fields(['login', 'idSistema', 's.sigla'])
        //.fieldRaw('DISTINCT jubarte.sistemas.sigla as')
        .from('user', alias: 't')
        .leftJoin('systems', 's.id', '=', 't."idSystem"', alias: 's')
        .whereRaw("login='jon.doe'")
        // .whereRaw("s.id='8'")
        // .where("login=?", 'jon.doe')
        /*.group('login')
      .group('t.idSistema')
      .group('sistemas.sigla');*/
        //.groupRaw('"login", "t"."idSystem", "s"."sigla"')
        .limit(1);
    // .groups(['login', 't.idSystem', 's.sigla']);

    query.firstAsMap().then((onValue) {
      print(onValue);
    });

  });
}

```

