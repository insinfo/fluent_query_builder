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
      var result = await db.select().from('pessoas').whereSafe('nome', 'ilike', '%isaque%').limit(1).get();

      var expectedValue = [
        [1, 'Isaque', '99701-5305', '54654']
      ];

      expect(result, expectedValue);
    });

    test('Select With one where', () async {
      var result = await db.select().from('pessoas').where('nome ilike ?', "'%isaque%'").limit(1).get();
      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With Multiples where', () async {
      var result = await db
          .select()
          .from('pessoas')
          .where('nome ilike ?', "'%isaque%'")
          .where('telefone ilike ?', "'%99701-5305%'")
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
          .where('nome ilike ?', "'%isaque%'")
          .where('telefone ilike ?', "'%99701-5305%'", 'OR')
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
          .where('nome ilike ?', "'%isaque%'")
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Complex selection With whereGroup, whereSafe, where whereRaw', () async {
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

    /* test('Select With whereExpr', () async {
      var result =
          await db.select().from('pessoas').whereExpr(DbLayer().expression().and('nome ilike ?'), "'%isaque%'").get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });*/

    test('Select With WhereGroup', () async {
      var result = await db
          .select()
          .from('pessoas')
          .whereGroup((QueryBuilder qb) {
            return qb.where('nome ilike ?', "'%isaque%'");
          })
          .limit(1)
          .get();

      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select With whereRaw', () async {
      var result = await db.select().from('pessoas').whereRaw("nome ilike '%isaque%'").limit(1).get();
      expect(result, [
        [1, 'Isaque', '99701-5305', '54654']
      ]);
    });

    test('Select getAsMap With whereRaw', () async {
      var result = await db.select().from('pessoas').whereRaw("nome ilike '%isaque%'").limit(1).getAsMap();
      expect(result[0] is Map, true);
    });

    test('Select firstAsMap With whereRaw', () async {
      var result = await db.select().from('pessoas').whereRaw("nome ilike '%isaque%'").limit(1).firstAsMap();
      expect(result is Map, true);
    });
  });

  group('Insert Queries', () {
    test('Insert set', () async {
      var result = await db.insert().into('pessoas').set('nome', 'Darth Vader').exec();
      expect(result, []);
    });
    test('Insert setAll', () async {
      var data = <String, dynamic>{'nome': 'Darth Vader', 'telefone': '123123123', 'cep': '123'};
      var result = await db.insert().into('pessoas').setAll(data).exec();
      expect(result, []);
    });

    test('Insert Get Id', () async {
      var data = <String, dynamic>{'nome': 'Darth Vader', 'telefone': '123123123'};
      var result = await db.insertGetId().into('pessoas').setAll(data).exec();
      expect(result![0]![0] is int, true);
    });

    test('Insert Get All', () async {
      var data = <String, dynamic>{'nome': 'Darth Vader', 'telefone': '123123123'};
      var response = await db.insertGetAll(returningFields: ['nome', 'telefone']).into('pessoas').setAll(data).exec();
      var expectedValue = [
        ['Darth Vader', '123123123']
      ];
      expect(response, expectedValue);
    });

    test('Insert Get All in transaction', () async {
      var data = <String, dynamic>{'nome': 'transaction', 'telefone': 'test'};
      var response;
      await db.transaction((ctx) async {
        response = await ctx.insertGetAll(returningFields: ['nome', 'telefone']).into('pessoas').setAll(data).exec();
        response = await ctx.insertGetAll(returningFields: ['nome', 'telefone']).into('pessoas').setAll(data).exec();
      });

      var expectedValue = [
        ['transaction', 'test']
      ];
      expect(response, expectedValue);
    });
  });

  group('Update Queries', () {});
}
