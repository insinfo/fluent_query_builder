A dart library that allows you to execute SQL queries in the PostgreSQL database in a fluent way, is very easy to execute.
This library implements POOL of connections.
This lib implements the vast majority of SQL statements and clauses

Soon it will also support mysql and ORM without reflection and without code generation in a simple and consistent way.

## Usage

A simple query builder usage example:

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

A simple beta pre ORM usage example:

```dart
import 'package:fluent_query_builder/fluent_query_builder.dart';

class Usuario implements FluentModelBase {
  Usuario({this.username});

  Usuario.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    username = map['username'] as String;
    password = map['password'] as String;
    ativo = map['ativo'] as bool;
    idPerfil = map['idPerfil'] as int;
  }

  int id;
  String username;
  String password;
  bool ativo;
  int idPerfil;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (id != null) {
      data['id'] = id;
    }
    data['username'] = username;
    data['password'] = password;
    data['ativo'] = ativo;
    data['idPerfil'] = idPerfil;
    return data;
  }

  @override
  String get tableName => 'usuarios';
}

void main() {
  //connection settings
  final com = DBConnectionInfo(
    host: '192.168.133.13',
    database: 'sistemas',
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['riodasostrasapp'],
  );
  
  //connect on database and set factories for construct instance of model
   DbLayer(factories: [
    {Usuario: (x) => Usuario.fromMap(x)}
  ]).connect(com).then((db) {
    //insert Usuario
    db.putSingle<Usuario>(Usuario(username: 'jon.doe', password: '123456'));
    //update Usuario
    db.update().where('id=?', 20).updateSingle<Usuario>(Usuario(username: 'jon.doe', password: '987'));
    //select Usuario
    db.select().from(Usuario().tableName).where('id>?', 2).fetchAll<Usuario>().then((result) {
      print(result);
    });
    //delete Usuario
    db.delete().deleteSingle<Usuario>(Usuario(id: 20, username: 'jon.doe', password: '123456'));
  });
}

```
