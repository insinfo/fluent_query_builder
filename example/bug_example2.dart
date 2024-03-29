import 'dart:async';

import 'package:fluent_query_builder/fluent_query_builder.dart';
//import 'package:postgres/postgres.dart';

void main() async {
  final pgsqlComInfo = DBConnectionInfo(
    enablePsqlAutoSetSearchPath: true,
    reconnectIfConnectionIsNotOpen: true,
    host: '192.168.133.13',
    database: 'test',
    driver: ConnectionDriver.pgsql,
    port: 5432,
    username: 'sisadmin',
    password: 's1sadm1n',
    charset: 'utf8',
    schemes: ['public'],
    setNumberOfProcessorsFromPlatform: false,
    numberOfProcessors: 1,
  );
  var db = await DbLayer(pgsqlComInfo).connect();
  await db.execute('DROP TABLE IF EXISTS "public"."naturalPerson" CASCADE');
  await db.execute('DROP TABLE IF EXISTS "public"."legalPerson" CASCADE');
  //create tables
  await db.execute('''
CREATE TABLE IF NOT EXISTS "public"."naturalPerson" (
  "id" serial8 PRIMARY KEY,
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "email" varchar(255) COLLATE "pg_catalog"."default" 
);
''');
  await db.execute('''
CREATE TABLE IF NOT EXISTS "public"."legalPerson" (
  "idPerson" int8 PRIMARY KEY,
  "socialSecurityNumber" varchar(12) COLLATE "pg_catalog"."default",
   CONSTRAINT "ssn" UNIQUE ("socialSecurityNumber")
);
''');
  //insert natural Person
  await db.raw('''
INSERT INTO "naturalPerson" (name,email) VALUES ('John Doe', 'johndoe@gmail.com');
''').exec();
  //insert legal Person
  await db.raw('''
INSERT INTO "legalPerson" ("idPerson","socialSecurityNumber") VALUES ('1', '856-45-6789');
''').exec();

  var repository = NaturalPersonRepository();
  var person = NaturalPerson(name: 'John Doe 2', email: 'johndoe2@gmail.com');
  Timer.periodic(Duration(seconds: 3), (t) async {
    var idPerson;
    try {
      await db.transaction((ctx) async {
        idPerson = await repository.insert(person, ctx);

        await ctx.raw(
            '''INSERT INTO "legalPerson" ("idPerson","socialSecurityNumber") VALUES ('$idPerson', '956-45-6789');''').exec();
      });
    } catch (e) {
      print(e);
    }
  });

  //exit(0);
}

class NaturalPerson {
  int? id;
  final String name;
  final String email;

  NaturalPerson({this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  factory NaturalPerson.fromMap(Map<String, dynamic> map) {
    return NaturalPerson(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class LegalPerson extends NaturalPerson {
  final int idPerson;
  final String socialSecurityNumber;

  LegalPerson(
      {required String name,
      required String email,
      required this.idPerson,
      required this.socialSecurityNumber})
      : super(name: name, email: email);
}

class NaturalPersonRepository {
  Future<int> insert(NaturalPerson person, DbLayer ctx) async {
    var result = await ctx
        .insertGetId()
        .into('naturalPerson')
        .setAll(person.toMap())
        .exec();

    // ...othes inserts

    var idPerson = result.first.first;
    return idPerson;
  }
}

//Taxpayer Identification Number=123-45-6789
//Employer Identification Number
//Social Security Number

bool isValidSSN(String? str) {
  // Regex to check SSN
  // (Social Security Number).

  var regex =
      // ignore: prefer_adjacent_string_concatenation
      '^(?!666|000|9\\d{2})\\d{3}' + '-(?!00)\\d{2}-' + '(?!0{4})\\d{4}\$';

  // Compile the ReGex
  var p = RegExp(regex);

  // If the string is empty
  // return false
  if (str == null) {
    return false;
  }

  // Pattern class contains matcher()
  //  method to find matching between
  //  given string and regular expression.
  // var m = p.firstMatch(str);

  // Return if the string
  // matched the ReGex
  return p.hasMatch(str);
}
 


 
// Test Case 1:
/* 
String str1 = "856-45-6789";       
System.out.println(isValidSSN(str1)); 
// Test Case 2:
String str2 = "000-45-6789";       
System.out.println(isValidSSN(str2)); 
// Test Case 3:
String str3 = "856-452-6789";
System.out.println(isValidSSN(str3)); 
// Test Case 4:
String str4 = "856-45-0000";
System.out.println(isValidSSN(str4));
Output
true
false
false
false
*/







