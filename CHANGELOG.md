## 1.0.0

- Initial version

## 1.0.1

- fix 

## 1.0.1

- fix dartfmt 

## 1.0.5

- remove static DBLayer db conection

## 1.0.11

- refactor and overall bug fixes

## 1.0.16

- implemented mysql initial support

## 1.1.0

- improvements against SQL injection with the introduction of the whereSafe() and orWhereSafe() methods, introducing the count() method to modify the query to count the database records, in addition to automatically introducing the limit and offset for the first() and firstAsMap(), in addition to several bug fixes for better compatibility with MySQL. And update the Readme with more examples.

## 1.1.1

- fix break in getAsMap method in PostgreSQL implementation

## 1.1.2

- add orWhereGroup and whereGroup method for grouping conditions

## 1.1.8

- implemented insertGetId and insertGetAll methods for returning id and row post inserted

## 1.1.9

- implemented setAll method for insert and update

## 1.1.10

- fix bug on conbine of orWhereGroup and where

## 1.1.11

- fix bug on orderBy

## 1.1.12

- a reconnection method was implemented in MySqlExecutor, so that the application is more resilient in case MySQL or MariaDB or PostgreSQL is restarted

## 1.1.14

- fix bug on where safe, failure on coted col name

## 1.1.16

- fix bug on where 

## 2.0.0

- refactoring for better resiliency in case of loss of connection to the postgresql server, now has an option called "reconnectIfConnectionIsNotOpen" and "enablePsqlAutoSetSearchPath" in the connection configuration class "DBConnectionInfo"

## 3.0.0

- update to Null safety and fix bugs on whereGroup and fix tests

# 3.0.1

- fix bugs on Complex selection With whereGroup, whereSafe, where and whereRaw

# 3.1.1

- fix bug on count query

# 3.2.1

- fix bugs on transaction

# 3.3.1

- add substitutionValues to raw method ``` await db.raw('INSERT INTO products (name,price) VALUES (@name, @price)',  substitutionValues: {'name': 'iPhone 6S', 'price': 2.50}).exec(); ```

# 3.4.1

- add useSSL option to connect when SSL is required

# 3.4.2

- change default timeoutInSeconds to 120

# 3.4.3

- fix bug on query timeout

# 3.5.3

- bug fix when using a combination of whereGroup, whereRaw, orWhereSafe and where

# 4.0.0

- Null security improvements and bug fixes. Attention breack Change: removal of Sanitizer and Validator in all SQL statements and clauses supported in this lib to avoid bugs, now it's up to the lib user to escape invalid fields and table names.