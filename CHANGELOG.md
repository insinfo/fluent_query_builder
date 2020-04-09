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