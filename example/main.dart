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
    schemes: [
      'pmro_padrao',
      'jubarte',
      'ciente',
      'portal_rh',
      'jubarte_app',
      'faq'
    ],
  );

  DBLayer().connect(com).then((db) {
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
  });
}
