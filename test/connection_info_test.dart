import 'package:fluent_query_builder/fluent_query_builder.dart';
import 'package:fluent_query_builder/src/connection_info.dart';
import 'package:fluent_query_builder/src/exceptions/null_pointer_exception.dart';
import 'package:test/test.dart';


void main() {
  group('getSettings()', () {
    
    DBConnectionInfo _connection;
    
    setUp(() {
      _connection = DBConnectionInfo();
    });

    tearDown(() async {
      _connection = null;
    });

    test('Gera Exceção ao não selecionar o drive', () {
        expect(
            () => _connection.getSettings(),
            throwsA(TypeMatcher<NullPointerException>())
        );
    });

    test('Retorna PostgreSql Settings', () {
      _connection.driver = ConnectionDriver.pgsql;
      expect(
          _connection.getSettings().driver,
          ConnectionDriver.pgsql
      );
    });

    test('Port 5432 como padrão para Driver Postgre', () {
      _connection.driver = ConnectionDriver.pgsql;
      expect(
          _connection.getSettings().port,
          5432
      );
    });

    test('Retorna Mysql Settings', () {
      _connection.driver = ConnectionDriver.mysql;
      expect(
          _connection.getSettings().driver,
          ConnectionDriver.mysql
      );
    });

    test('Retorna porta 3306 para Mysql', () {
      _connection.driver = ConnectionDriver.mysql;
      expect(
          _connection.getSettings().port,
          3306
      );
    });


  });
}
