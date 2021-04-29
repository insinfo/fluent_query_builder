import 'dart:io';
import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() async {
  print('start execution');
  //PostgreSQL connection information
  final pgsqlComInfo = DBConnectionInfo(
    enablePsqlAutoSetSearchPath: true,
    reconnectIfConnectionIsNotOpen: true,
    host: 'localhost', //192.168.133.13
    database: 'banco_teste',
    driver: ConnectionDriver.pgsql,
    port: 5434,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['jubarte', 'public'],
    setNumberOfProcessorsFromPlatform: false,
    numberOfProcessors: 8,
  );

  //MySQL connection information
  /*final mysqlComInfo = DBConnectionInfo(
    host: 'localhost', //10.0.0.22
    database: 'banco_teste', //banco_teste
    driver: ConnectionDriver.mysql,
    port: 3307,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
  );*/

  var db;
  try {
    print('try connect');
    db = await DbLayer().connect(pgsqlComInfo);
  } catch (e, s) {
    print('catch connect $e $s');
  }

  /*Timer.periodic(Duration(milliseconds: 3000), (timer) async {
    try {
      print('Print after 3 seconds');
       await pgsql
          .select()
          .from('usuarios')
          .whereSafe('login', '=', 'isaque.neves')
          .whereSafe('"idSistema"', '=', '1')
          .getAsMap()
          .then((result) => print('pgsql select $result'));*/

  /*var result = await pgsql.select().from('pessoas').whereGroup((QueryBuilder qb) {
    //return qb.where('nome ilike ?', "'%isaque%'", 'or').where('telefone ilike ?', "'%05%'", 'or');
    return qb.orWhereSafe('nome', 'ilike', '%isaque%').orWhereSafe('telefone', 'ilike', '%05%');
  }).get();*/

  var data = <String, dynamic>{'nome': 'transaction', 'telefone': 'test'};
  var response;
  await db.transaction((ctx) async {
    response = await ctx.insertGetAll(returningFields: ['nome', 'telefone']).into('pessoas').setAll(data).exec();
    response = await ctx.insertGetAll(returningFields: ['nome', 'telefone']).into('pessoas5').setAll(data).exec();
  });

  print(response);

  //var result = await pgsql.select().from('pessoas').whereRaw("nome ilike '%isaque%'").limit(1).getAsMap();
  // print('pgsql select ${result[0] is Map}');
  exit(0);
  /* 
    } catch (e, s) {
      print('catch select $e s $s');
    }
  });*/

  /* var mysql;
  try {
    print('try connect');
    mysql = await DbLayer().connect(mysqlComInfo);
  } catch (e, s) {
    print('catch connect $e');
  }

  Timer.periodic(Duration(milliseconds: 600), (timer) async {
    try {
      print('Print after 3 seconds');
      await mysql
          .select()
          .from('pessoas')
          .whereSafe('nome', 'like', '%Sant\'Ana%')
          .getAsMap()
          .then((result) => print('mysql select $result'));
    } catch (e, s) {
      print('catch select $e');
    }
  });*/

  /*DbLayer().connect(mysqlCom).then((db) {
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
  });*/

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

  //
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

  /* var data = await pgsql
      .select()
      .from('pessoas')
      // .whereSafe('nome', 'ilike', '%Sant\'Ana%')
      .orWhereGroup((query) {
        return query.orWhereSafe('nome', 'ilike', '%5%').orWhereSafe('cpf', 'ilike', '%5%');
      })
     // .whereSafe('id', '>', 0)
     // .where('id>?', '0')
      .getAsMap();

  print('pgsql select \r\n ${data}');*/

  /*data = await db.getRelationFromMaps(data, 'usuarios', 'idPessoa', 'id');

  

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
/*
  //example
  var db = await DbLayer(factories: [
    {Usuario: (x) => Usuario.fromMap(x)},
    {Pessoa: (x) => Pessoa.fromMap(x)}
  ]).connect(pgsqlCom);

  //insert Usuario e pessoa relacionada
  var user = Usuario(username: 'jon.doe', password: '123456', idPerfil: 3);
  user.pessoa = Pessoa(nome: 'jon doe', telefone: '717171', cpf: '123');

  //var result = await db.putSingleGetId<Usuario>(user);
  var result = await db.select().from(Usuario.TABLE_NAME).where('id>?', 2).fetchAll<Usuario>();

  print('insert Usuario $result');
  //update Usuario
  //await db.update().where('id=?', 20).updateSingle<Usuario>(Usuario(username: 'jon.doe', password: '987'));
  //select Usuario
 
  //delete Usuario
  //await db.delete().deleteSingle<Usuario>(Usuario(id: 20, username: 'jon.doe', password: '123456'));

  print('end execution');
  // exit(0);*/
}
*/
}
/*
class Usuario implements FluentModelBase {
  Usuario({this.id, this.username, this.password, this.idPerfil, this.idPessoa});

  Usuario.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['username'];
    password = map['password'];
    ativo = map['ativo'];
    idPerfil = map['idPerfil'];
    idPessoa = map['idPessoa'];
    if (map.containsKey('pessoa')) {
      pessoa = Pessoa.fromMap(map['pessoa']);
    }
  }

  int id;
  String username;
  String password;
  bool ativo;
  int idPerfil;
  int idPessoa;
  Pessoa pessoa;

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
    data['idPessoa'] = idPessoa;
    if (pessoa != null) {
      data['pessoa'] = pessoa.toMap();
    }
    return data;
  }

  static const String TABLE_NAME = 'usuarios';
  static const String ID_KEY = 'id';
  static const String USERNAME_KEY = 'username';
  static const String PASSWORD_KEY = 'password';
  static const String ATIVO_KEY = 'ativo';
  static const String ID_PERFIL_KEY = 'idPerfil';
  static const String ID_PESSOA_KEY = 'idPessoa';

  @override
  OrmDefinitions get ormDefinitions {
    return OrmDefinitions(
      tableName: TABLE_NAME,
      primaryKey: ID_KEY,
      relations: [
        OrmRelation(Pessoa.TABLE_NAME, 'idPessoa', 'id', OrmRelationType.belongsTo, 'pessoa'),
      ],
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class Pessoa implements FluentModelBase {
  Pessoa({this.id, this.nome, this.telefone, this.cpf});

  Pessoa.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    telefone = map['telefone'];
    cpf = map['cpf'];
  }

  int id;
  String nome;
  String telefone;
  String cpf;

  @override
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    if (id != null) {
      data['id'] = id;
    }
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['cpf'] = cpf;

    return data;
  }

  static const String TABLE_NAME = 'pessoas';
  static const String ID_KEY = 'id';
  static const String NOME_KEY = 'nome';
  static const String TELEFONE_KEY = 'telefone';
  static const String CPF_KEY = 'cpf';

  @override
  OrmDefinitions get ormDefinitions {
    return OrmDefinitions(
      tableName: TABLE_NAME,
      primaryKey: ID_KEY,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
*/
