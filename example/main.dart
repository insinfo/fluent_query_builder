import 'dart:convert';

import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() async {
  print('start execution');
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
    /*db
        .insertGetId()
        .into('pessoas')
        .set('nome', 'Isaque Neves Sant\'Ana')
        .set('telefone', '(22) 2771-6265')
        .exec()
        .then((result) => print('mysql insert $result'));*/

    //mysql insertGetId with setAll
    db
        .insertGetId()
        .into('pessoas')
        .setAll({
      'nome': 'Jon Doe',
      'telefone': '171171171',
    })
        .exec()
        .then((result) => print('mysql insertGetId $result'));

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
        .then((result) => print('mysql update $result'));

    //mysql select
    db
        .select()
    //.fields(['login', 'idSistema', 's.sigla'])
    //.fieldRaw('SELECT COUNT(*)')
        .from('pessoas')
        .whereSafe('nome', 'like', '%Sant\'Ana%')
    //.limit(1)
        .getAsMap()
        .then((result) => print('mysql select $result'));



  });




  /*DbLayer().connect(mysqlCom).then((db) {
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
        .then((result) => print('mysql select $result'));
  });*/

  var db = await DbLayer().connect(pgsqlCom);

  db.select()
      .from('pessoas')
      .where('nome ilike ?', "'%darth%'")
      .get()
      .then((res) {
        print('Ilike simple select');
        print(res);
      });

  db.select()
      .from('pessoas')
      .where('nome ilike ?', "'%darth%'")
      .get()
      .then((res) {
    print('Ilike simple select');
    print(res);
  });

  var res = db.select()
      .from('pessoas')
      .orWhereGroup((QueryBuilder qb) {
        return qb
            .orWhereSafe('nome', 'ilike' ,"%dart%")
            .orWhereSafe('telefone', '=', '123123123');
      })
  .whereSafe('id', '>', 0)
      .toSql();
  print('TOSQL');
  print(res);

  //pgsql insertGetAll
  /* db
      .insertGetAll()
      .into('usuarios')
      .set('username', 'isaque')
      .set('password', '123456')
      .exec()
      .then((result) => print('pgsql insertGetAll $result'));

  db.select().from('usuarios')
  .count()
  .then((result) => print('pgsql count $result'));*/

  /*var data = await db
      .select()
      .from('pessoas')
      // .whereSafe('nome', 'ilike', '%Sant\'Ana%')
      .orWhereGroup((query) {
        return query.orWhereSafe('nome', 'ilike', '%5%').orWhereSafe('cpf', 'ilike', '%5%');
      })
      .whereSafe('id', '>', 0)
      .getAsMap();

  data = await db.getRelationFromMaps(data, 'usuarios', 'idPessoa', 'id');

  print('pgsql select \r\n ${jsonEncode(data)}');*/

  // var r = await db.select().from('pessoas').fieldRaw('1').limit(1).exec();
  // var r = await db.raw('select 1').exec();
  // print(r);

  /*await db.transaction((ctx) async {

    var result = await ctx.insert().into('usuarios')
    .set('username', 'isaque')
    .set('password', '123456')
    .exec();

    await ctx
        .select()
        .from('pessoas')
        // .whereSafe('nome', 'ilike', '%Sant\'Ana%')
        .orWhereGroup((query) {
          return query
          .orWhereSafe('nome', 'ilike', '%5%')
          .orWhereSafe('cpf', 'ilike', '%5%');
        })
        .whereSafe('id', '>', 0)
        .getAsMap();

    print('pgsql transaction $result');
  });*/

  /*DbLayer().connect(pgsqlCom).then((db) {
    final query = db
        .select()
        //.fields(['login', 'idSistema', 's.sigla'])
        //.fieldRaw('DISTINCT jubarte.sistemas.sigla as')
        //.from('usuarios', alias: 't')
        //  .leftJoin('sistemas', 's.id', '=', 't."idSistema"', alias: 's')
        // .whereRaw("login='isaque.neves'")
        // .whereRaw("s.id='8'")
        // .where("login=?", 'isaque.neves')
        /*.group('login')
      .group('t.idSistema')
      .group('sistemas.sigla');*/
        //.groupRaw('"login", "t"."idSistema", "s"."sigla"')
        .limit(1);
    // .groups(['login', 't.idSistema', 's.sigla']);

    query.firstAsMap().then((onValue) {
      print(onValue);
    });
  });*/

  //example
  /* DbLayer(factories: [
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
  });*/
  print('end execution');
  // exit(0);
}

class Usuario implements FluentModelBase {
  Usuario({this.id, this.username, this.password, this.idPerfil});

  Usuario.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    username = map['username'] as String;
    password = map['password'] as String;
    ativo = map['ativo'] as bool;
    idPerfil = map['idPerfil'] as int;
  }

  @override
  Usuario fromMap(Map<String, dynamic> map) {
    return Usuario.fromMap(map);
  }

  int id;
  String username;
  String password;
  bool ativo;
  int idPerfil;

  @override
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
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

  @override
  String get primaryKey => 'id';

  @override
  dynamic get primaryKeyVal => id;
}
