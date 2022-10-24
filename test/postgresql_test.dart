import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'test_infrastructure.dart';

void main() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord r) {
    print('${r.time}: ${r.loggerName}: ${r.message}');
  });

  initializeTest();
  group('Test Connection', () {
    test('Test Connection postgresql', () async {
      var r = await db.raw('select 1').exec();
      expect(r, [
        [1]
      ]);
    });
  });

  group('Teste Select Query', () {
    test('Select get All', () async {
      var result = await db.select().from('pessoas').get();
      expect(result!.isNotEmpty, true);
    });

    test('Select With whereSafe', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%isaque%')
          .limit(1)
          .get();

      var expectedValue = [
        [1, 'Isaque', '99701-5305', '54654']
      ];

      expect(result, expectedValue);
    });

    test('Select With one where', () async {
      var result = await db
          .select()
          .from('pessoas')
          .where('nome ilike ?', '%isaque%')
          .limit(1)
          .get();
      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With Multiples where', () async {
      var result = await db
          .select()
          .from('pessoas')
          .where('nome ilike ?', '%isaque%')
          .where('telefone ilike ?', '%99701-5305%')
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With where OR', () async {
      var result = await db
          .select()
          .from('pessoas')
          .where('nome ilike ?', '%isaque%')
          .where('telefone ilike ?', '%99701-5305%', 'OR')
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With Multiples whereSafe', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%isaque%')
          .whereSafe('telefone', 'ilike', '%99701-5305%')
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With whereSafe And orWhereSafe', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%isaque%')
          .orWhereSafe('telefone', 'ilike', '%99701-5305%')
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With whereSafe And where', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereSafe('telefone', 'ilike', '%99701-5305%')
          .where('nome ilike ?', '%isaque%')
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Complex selection With whereGroup, whereSafe, where whereRaw',
        () async {
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
      query.where(
          '"dataCriado"::TIMESTAMP  > ?::TIMESTAMP ', '2021-05-04 17:53:55');

      query.whereGroup((q) {
        q.where('"idPessoa"=?', 2, 'or');
        q.where('"idOrganograma"=?', 19, 'or');
        q.where('"toAll"=?', 't', 'or');
        q.whereSafe('"toAll"', '=', 'true');
        q.whereRaw('"toAll"= true');
        return q;
      });
      query.orWhereGroup((q) {
        q.whereSafe('"toAll"', '=', 'true');
        return q;
      });

      query.order('"dataCriado"', dir: SortOrder.DESC);

      //print( 'Complex selection With whereGroup, whereSafe, where whereRaw \r\n ${query.toSql()}');
      final listMap = await query.limit(1).getAsMap();

      expect(listMap, [
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
      ]);
    });

    test(
        'Select with fields, leftJoin, whereSafe, where, whereRaw, offset, limit, order and getAsMap',
        () async {
      await db.execute('DROP TABLE IF EXISTS "table_01"');
      await db.execute('''
      CREATE TABLE "public"."table_01" (
      "id" serial4 NOT NULL ,
      "name" varchar(255) ,
      "test" varchar(255) ,
      "date" timestamp ,
      "buleano" bool,
      CONSTRAINT "table_01_pkey" PRIMARY KEY ("id")
      );
    ''');
      await db.execute('DROP TABLE IF EXISTS "table_02"');
      await db.execute('''
      CREATE TABLE "public"."table_02" (
      "id" serial4 NOT NULL ,
      "idtb1" int4 ,
      "info" varchar(255) ,
      "idPessoa" int4 ,
      CONSTRAINT "table_02_pkey" PRIMARY KEY ("id")
      );
    ''');
      await db
          .insertGetId()
          .into('table_01')
          .setAll({'id': 11, 'name': 'Isaque', 'buleano': true}).exec();

      await db.insertGetId().into('table_02').setAll(
          {'id': 22, 'idtb1': 11, 'info': "Sant'Ana", 'idPessoa': 21}).exec();

      var result = await db
          .select()
          .fields(['name', 'b.info', 'b.id', 'b."idPessoa"'])
          .from('table_01', alias: 'a')
          .leftJoin('table_02', 'a.id', '=', 'b.idtb1', alias: 'b')
          .whereSafe('b.info', 'ilike', "%Sant'Ana%")
          .whereRaw('b.info ilike @info',
              andOr: 'AND', substitutionValues: {'info': "%Sant'Ana%"})
          .where('a.test is null')
          .offset(0)
          .limit(100)
          //.group('a.id')
          .order('b.info')
          .getAsMap();

      expect(result, [
        {'name': 'Isaque', 'info': 'Sant\'Ana', 'id': 22, 'idPessoa': 21}
      ]);
    });

    test('Select With WhereGroup', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereGroup((QueryBuilder qb) {
            return qb.where('nome ilike ?', '%isaque%');
          })
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With whereRaw', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereRaw("nome ilike '%isaque%'")
          .limit(1)
          .get();
      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select getAsMap With whereRaw', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereRaw("nome ilike '%isaque%'")
          .limit(1)
          .getAsMap();

      expect(result.length, 1);
    });

    test('Select firstAsMap With whereRaw', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereRaw("nome ilike '%isaque%'")
          .limit(1)
          .firstAsMap();
      expect(result is Map, true);
    });
  });

  group('Insert Queries', () {
    test('Insert set', () async {
      var result =
          await db.insert().into('pessoas').set('nome', 'Darth Vader').exec();
      expect(result, []);
    });
    test('Insert setAll', () async {
      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123',
        'cep': '123'
      };
      var result = await db.insert().into('pessoas').setAll(data).exec();
      expect(result, []);
    });

    test('Insert Get Id', () async {
      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123'
      };
      var result = await db.insertGetId().into('pessoas').setAll(data).exec();
      expect(result[0][0] is int, true);
    });

    test('Insert Get All', () async {
      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123'
      };
      var response = await db
          .insertGetAll(returningFields: ['nome', 'telefone'])
          .into('pessoas')
          .setAll(data)
          .exec();
      var expectedValue = [
        ['Darth Vader', '123123123']
      ];
      expect(response, expectedValue);
    });

    test('Insert Get All in transaction', () async {
      var data = <String, dynamic>{'nome': 'transaction', 'telefone': 'test'};
      var response;
      await db.transaction((ctx) async {
        response = await ctx
            .insertGetAll(returningFields: ['nome', 'telefone'])
            .into('pessoas')
            .setAll(data)
            .exec();
        response = await ctx
            .insertGetAll(returningFields: ['nome', 'telefone'])
            .into('pessoas')
            .setAll(data)
            .exec();
      });

      var expectedValue = [
        ['transaction', 'test']
      ];
      expect(response, expectedValue);
    });
  });

  group('Update Queries', () {
    test('simple update with whereSafe', () async {
      await db.execute('DROP TABLE IF EXISTS "table_01"');
      await db.execute('''
      CREATE TABLE "public"."table_01" (
      "id" serial4 NOT NULL ,
      "name" varchar(255) ,
      "test" varchar(255) ,
      "date" timestamp ,
      "buleano" bool,
      "idPessoa" int4 ,
      CONSTRAINT "table_01_pkey" PRIMARY KEY ("id")
      );
    ''');

      await db.insertGetId().into('table_01').setAll(
          {'id': 11, 'name': "Isaque Sant'Ana", 'buleano': true}).exec();

      var response;

      response = await db
          .update()
          .whereSafe('id', '=', 11)
          .table('table_01')
          .setAll({
        'test': null,
        'name': "Isaque Neves Sant'Ana",
        'date': DateTime.now()
      }).exec();

      var expectedValue = [];
      expect(response, expectedValue);
    });
  });

  group('Delete Queries', () {
    test('Simple Delete with whereSafe', () async {
      await db.execute('DROP TABLE IF EXISTS "table_01"');
      await db.execute('''
      CREATE TABLE "public"."table_01" (
      "id" serial4 NOT NULL ,
      "name" varchar(255) ,
      "test" varchar(255) ,
      "date" timestamp ,
      "buleano" bool,
      "idPessoa" int4 ,
      CONSTRAINT "table_01_pkey" PRIMARY KEY ("id")
      );
    ''');

      await db.insertGetId().into('table_01').setAll(
          {'id': 11, 'name': "Isaque Sant'Ana", 'buleano': true}).exec();

      var response;

      response =
          await db.delete().from('table_01').whereSafe('id', '=', 11).exec();

      var expectedValue = [];
      expect(response, expectedValue);
    });
  });
}
