A dart library that allows you to execute SQL queries in the PostgreSQL database in a fluent way, is very easy to execute.
This library implements POOL of connections.
This lib implements the vast majority of SQL statements and clauses

Soon it will also support mysql and ORM without reflection and without code generation in a simple and consistent way.

## Usage

A simple query builder usage example:

```dart
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() {
  //PostgreSQL connection information
  final pgsqlCom = DBConnectionInfo(
    host: '192.168.133.13',
    database: 'banco_teste',
    driver: ConnectionDriver.pgsql,
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['public'],
  );

  //MySQL connection information
  final mysqlCom = DBConnectionInfo(
    host: '10.0.0.22',
    database: 'banco_teste',
    driver: ConnectionDriver.mysql,
    port: 3306,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
  );

  DbLayer().connect(mysqlCom).then((db) {
    //mysql insert
    db
        .insert()
        .into('pessoas')
        .set('nome', 'Isaque Neves Sant\'Ana')
        .set('telefone', '(22) 2771-6265')
        .exec()
        .then((result) => print('mysql insert $result'));

    //mysql update
    db
        .update()
        .table('pessoas')
        .set('nome', 'João')
        .where('id=?', 13)
        .exec()
        .then((result) => print('mysql update $result'));

    //mysql delete
    db.delete().from('pessoas')
    .where('id=?', 14)
    .exec()
    .then((result) => print('mysql delete $result'));

    //mysql select
    db
        .select()
        //.fields(['login', 'idSistema', 's.sigla'])
        //.fieldRaw('SELECT COUNT(*)')
        .from('pessoas')
        .whereSafe('nome', 'like', '%Sant\'Ana%')
        //.limit(1)
        .firstAsMap()
        .then((result) => print('mysql select $result'));

    //mysql raw query SELECT * FROM `pessoas` or SELECT COUNT(*) FROM pessoas
    db  
        .raw("SELECT * FROM `pessoas`")
        .firstAsMap()
        .then((result) => print('mysql raw $result'));
        
    //mysql count records 
    db
        .select()
        .from('pessoas')
        .orWhereSafe('nome', 'like', '%Sant\'Ana%')
        .orWhereSafe('id', '<', 20)
        .count()
        .then((result) => print('mysql count $result'));
  });

  DbLayer().connect(pgsqlCom).then((db) {
    //pgsql insert
    db
        .insert()
        .into('usuarios')
        .set('username', 'isaque')
        .set('password', '123456')
        .exec()
        .then((result) => print('pgsql insert $result'));

    //pgsql count records
         db
        .select()
        .from('pessoas')       
        .count()
        .then((result) => print('pgsql count $result'));
  });
  
  //example
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
