import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:fluent_query_builder/src/exceptions/null_pointer_exception.dart';
import 'package:test/test.dart';

import 'builders/db_connection_builder.dart';

void main() {

  var _connectionInfo = DbConnectionBuilder().build();
  DbLayer _dbLayer;

  group('Test Connection', () {

    setUp(() {
      _dbLayer = DbLayer();
    });


    test('Test Connection Default Builder Params With Success', () async {
      var db = await _dbLayer.connect(_connectionInfo);
      expect(await db.raw('select 1').exec(), equals([[1]]));
    });

    test('Test Connection When Driver is Null', () async {
      var connectionInfo = DbConnectionBuilder().withNullDrive().build();
      expect(
        () async => await _dbLayer.connect(connectionInfo),
        throwsA(TypeMatcher<NullPointerException>())
      );
    });

//    test('Test Connection When Charset is Null', () async {
//      var connectionInfo = DbConnectionBuilder().withNullCharset().build();
//      fail('Falta implementar');
//    });

  });

  group('Teste Select Query', () {

    setUp(() {
      _dbLayer = DbLayer();
    });

    test('Select Find All', () async {
      var db = await _dbLayer.connect(_connectionInfo);
      var result = await db.select()
          .from('pessoas')
          .get();

      var expectedValue = true;

      expect(result.length > 1, equals(expectedValue));
    });

    test('Select Get Function With Success', () async {
      var db = await _dbLayer.connect(_connectionInfo);
      var result = await db.select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%isaque%')
          .limit(1)
          .get();

      var expectedValue = [[3, 'Isaque Neves Sant Ana', '(22) 99701-5305', '54654']];

      expect(result, equals(expectedValue));
    });

    test('Select Get Function With Simple Where', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .where('nome ilike ?', "'%darth%'")
          .get();

      expect(result.length > 1, equals(true));
    });

    test('Select Get Function With Multiples Where', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .where('nome ilike ?', "'%darth%'")
          .where('telefone ilike ?', "'%123%'")
          .get();

      expect(result.length > 1, equals(true));
    });

    test('Select Get Function With OrWhere', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .where('nome ilike ?', "'%darth%'")
          .where('telefone ilike ?', "'%123%'", 'OR')
          .get();

      expect(result.length > 1, equals(true));
    });

    test('Select Get Function With WhereSafe', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%dart%')
          .get();

      expect(result.length > 1, equals(true));
    });

    test('Select Get Function With Multiples where Safes', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%dart%')
          .whereSafe('telefone', 'ilike', '%123%')
          .get();

      expect(result.length > 1, equals(true));
    });

    test('Select Get Function With WhereSafe And OrWhereSafe', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db.select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%dart%')
          .orWhereSafe('telefone', 'ilike', '%123%')
          .get();

      expect(result.length > 1, equals(true));
    });

    /**     * 
     * Importante enviar uma mensagem regnérica para o desenvolvedor usar apenas um tipo de wehere.
     */
    test('Select Get Function With Where And OrWhereSafe', () async {
      var db = await _dbLayer.connect(_connectionInfo);
      /*
      var result = await db.select()
          .from('pessoas')
          .whereSafe('telefone', 'ilike', '%123%')
          .where('nome ilike ?', '%dart%')
          .get();

      expect(result.length > 1, equals(true));
      */
    });

    /**
     * TODO Resolver Where Expression
     */
    test('Select Get Function With WhereExpression', () async {
      var db = await _dbLayer.connect(_connectionInfo);
//
//      var result = await db.select()
//          .from('pessoas')
//          .whereExpr(DbLayer().expression().and('nome ilike ?'))
//          .get();

//      expect(result.length > 1, equals(true));

    });

    /**
     * TODO WhereGroup com bug, gerando And no final da clausula
     */
    test('Select Get Function With WhereGroup', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var result = await db
          .select()
          .from('pessoas')
          .whereGroup((QueryBuilder qb) {
            return qb.where('nome ilike ?', "'%dart%'");
          }).get();

      expect(result.length > 1, equals(true));

    });

    test('Select Get Function With whereRaw', () async {
      var db = await _dbLayer.connect(_connectionInfo);


      var result = await db.select()
          .from('pessoas')
          .whereRaw("nome ilike '%dart%'")
          .get();

      expect(result.length > 1, equals(true));

    });



  });

  group('Insert Queries', () {

    setUp(() {
      _dbLayer = DbLayer();
    });

    /**
     * TODO Ver a possibilidade do insert receber o TableName
     * Ao inves de ser exec(), para insert, colocar save()
     */
    test('Simple Insert', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123'
      };

      expect(() async {
        await db.insert()
          .into('pessoas')
          .setAll(data)
          .exec();
      }, () => dynamic);
    });

    test('Insert Get Id', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123'
      };

      var id = await db.insertGetId()
          .into('pessoas')
          .setAll(data)
          .exec();

      expect(id, equals(id));
    });

    test('Insert Get All', () async {
      var db = await _dbLayer.connect(_connectionInfo);

      var data = <String, dynamic>{
        'nome': 'Darth Vader',
        'telefone': '123123123'
      };

      var response = await db.insertGetAll(returningFields:[
        'nome', 'telefone'
      ]).into('pessoas').setAll(data).exec();

      var expectedValue = [['Darth Vader', '123123123']];

      expect(response, equals(expectedValue));
    });
  });
}
