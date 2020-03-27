import 'package:fluent_query_builder/fluent_query_builder.dart';

void main() {
  //configura a conexão
  final com = DBConnectionInfo(
    host: '192.168.133.13',
    database: 'sistemas',
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['riodasostrasapp'],
  );

  /*DbLayer().connect(com).then((db) {
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

  DbLayer(factory: {Usuario: (x) => Usuario.fromMap(x)}).connect(com).then((db) {
    final query = db.select().from(Usuario().tableName);

    query.fetchAll<Usuario>().then((onValue) {
      print(onValue);
    });
  });
}

class Usuario implements OrmModelBase {
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
