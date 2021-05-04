# fluent_query_builder

[![Build Status](https://api.travis-ci.org/insinfo/fluent_query_builder.svg?branch=master)](https://travis-ci.com/github/insinfo/fluent_query_builder) 

A dart library that allows you to execute SQL queries in the PostgreSQL and MySql database in a fluent way, is very easy to execute.
This library implements POOL of connections.
This lib implements the vast majority of SQL statements and clauses

Soon it will also support ORM without reflection and without code generation in a simple and consistent way.

## Usage

A simple query builder usage example:

```dart
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() {
  //PostgreSQL connection information
  final pgsqlCom = DBConnectionInfo(
    host: 'localhost',
    database: 'banco_teste',
    driver: ConnectionDriver.pgsql,
    port: 5432,
    username: 'user',
    password: 'pass',
    charset: 'utf8',
    schemes: ['public'],
  );

  //MySQL connection information
  final mysqlCom = DBConnectionInfo(
    host: 'localhost',
    database: 'banco_teste',
    driver: ConnectionDriver.mysql,
    port: 3306,
     username: 'user',
    password: 'pass',
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

    //mysql update with setAll
    db
        .update()
        .whereSafe('id', '=', 13)
        .table('pessoas')
        .setAll({
          'nome': 'Jon Doe',
          'telefone': '171171171',
        })
        .exec()
        .then((result) => print('mysql update with setAll $result'));

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

  //pgsql insertGetAll
  db
      .insertGetAll()
      .into('usuarios')
      .set('username', 'isaque')
      .set('password', '123456')
      .exec()
      .then((result) => print('pgsql insertGetAll $result'));

 //pgsql insertGetId
  db
      .insertGetId()
      .into('usuarios')
      .set('username', 'isaque')
      .set('password', '123456')
      .exec()
      .then((result) => print('pgsql insertGetId $result'));

    //pgsql count records
         db
        .select()
        .from('pessoas')       
        .count()
        .then((result) => print('pgsql count $result'));

     //Complex selection With whereGroup, whereSafe, where whereRaw
      await db.raw('DROP TABLE IF EXISTS notificacoes').exec();
      await db.raw('''CREATE TABLE notificacoes (
                      "id" serial NOT NULL ,
                      "mensagem" text COLLATE "pg_catalog"."default",
                      "dataCriado" timestamp(0) DEFAULT now(),
                      "link" text COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
                      "idPessoa" int4,
                      "idSistema" int4,
                      "userAgent" text COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
                      "idOrganograma" int4,
                      "isLido" bool,
                      "toAll" bool,
                      "icon" text COLLATE "pg_catalog"."default",
                      CONSTRAINT "notificacoes_pkey" PRIMARY KEY ("id")
                    )''').exec();
      await db.insert().into('notificacoes').setAll({
        'mensagem': 'Teste',
        'link': 'https://pub.dev',
        'dataCriado': '2021-05-04 17:53:55',
        'idPessoa': 2,
        'idSistema': 1,
        'userAgent': 'Google',
        'idOrganograma': 19,
        'isLido': false,
        'toAll': true,
        'icon': ''
      }).exec();

      final query = db.select().fromRaw('notificacoes');
      query.where('"dataCriado"::TIMESTAMP  > \'?\'::TIMESTAMP ', '2021-05-04 17:53:55');
      query.whereGroup((q) {
        q.where('"idPessoa"=?', 2, 'or');
        q.where('"idOrganograma"=?', 19, 'or');
        q.where('"toAll"=?', "'t'", 'or');
        q.whereSafe('"toAll"', '=', 'true');
        q.whereRaw('"toAll"= true');
        return q;
      });
      query.orWhereGroup((q) {
        q.whereSafe('"toAll"', '=', 'true');
        query.orWhereGroup((q) {
          q.whereSafe('"toAll"', '=', 'true');
          return q;
        });
        return q;
      });
      query.order('dataCriado', dir: SortOrder.DESC);
      final listMap = await query.limit(1).getAsMap();

      print(listMap)
       /*Resullt
       [
        {
          'id': 1,
          'mensagem': 'Teste',
          'dataCriado': DateTime.tryParse('2021-05-04 17:53:55.000Z'),
          'link': 'https://pub.dev',
          'idPessoa': 2,
          'idSistema': 1,
          'userAgent': 'Google',
          'idOrganograma': 19,
          'isLido': false,
          'toAll': true,
          'icon': ''
        }
      ]*/
   

        
  });
  
  //pgsql transaction example
  var db = await DbLayer().connect(pgsqlCom);
  await db.transaction((ctx) async {
    
    var result = await ctx.insert().into('usuarios')
    .set('username', 'isaque')
    .set('password', '123456')
    .exec();
    //pgsql use of Where Group => WHERE (nome ilike '%5%' or cpf ilike '%5%') AND id > 0
    await ctx
    .select()
    .from('pessoas')     
    .orWhereGroup((query) {
      return query
      .orWhereSafe('nome', 'ilike', '%5%')
      .orWhereSafe('cpf', 'ilike', '%5%');
    })
    .whereSafe('id', '>', 0)
    .getAsMap();

    print('pgsql transaction $result');
  });

  //pgsql getRelationFromMaps example
   var data = await db
      .select()
      .from('pessoas') 
      .orWhereGroup((query) {
        return query.orWhereSafe('nome', 'ilike', '%5%').orWhereSafe('cpf', 'ilike', '%5%');
      })
      .whereSafe('id', '>', 0)
      .getAsMap();

  data = await db.getRelationFromMaps(data, 'usuarios', 'idPessoa', 'id');

  print('pgsql select \r\n ${jsonEncode(data)}');
  /* pgsql select 
    [
      {
        "id":2,
        "nome":"Isaque Neves Sant'Ana",
        "telefone":"(22) 99701-5305",
        "cpf":"54654",
        "usuarios":[
            {
              "id":16,
              "username":"isaque",
              "password":"123456",
              "ativo":null,
              "idPessoa":2
            }
        ]
      },
      {
        "id":1,
        "nome":"João da Silva 5",
        "telefone":"27772339",
        "cpf":"1111",
        "usuarios":[

        ]
      }
    ]  */
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
