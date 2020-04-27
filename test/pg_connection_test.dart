import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:fluent_query_builder/src/exceptions/null_pointer_exception.dart';
import 'package:fluent_query_builder/src/filter.dart';
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

    test('Test Connection When Charset is Null', () async {
      var connectionInfo = DbConnectionBuilder().withNullCharset().build();
      fail('Falta implementar');
    });

  });

  group('Queries Tests', () {

    setUp(() {
      _dbLayer = DbLayer();
    });

    test('Select Get Fnction With Success', () async {
      var db = await _dbLayer.connect(_connectionInfo);
      var select = await db.select()
          .from('pessoas')
          .whereSafe('nome', 'ilike', '%isaque%')
          .limit(1)
          .get();

      var expectedValue = [[3, 'Isaque Neves Sant Ana', '(22) 99701-5305', '54654']];

      expect(select, equals(expectedValue));
    });
  });
}
