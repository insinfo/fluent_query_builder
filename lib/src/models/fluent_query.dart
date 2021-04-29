import 'expression.dart';
import 'query_builder.dart';
import 'query_builder_options.dart';
import 'select.dart';
import 'update.dart';
import 'insert.dart';
import 'delete.dart';

/// API-functions exposed.
class FluentQuery {
  FluentQuery();

  /// Starts a new expression with the provided options.
  /// @param options Options to use for expression generation.
  /// @return Expression
  static Expression expression({QueryBuilderOptions? options}) {
    return Expression(options);
  }

  /// Starts the SELECT-query chain with the provided options
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  static QueryBuilder select({QueryBuilderOptions? options}) {
    return Select(options);
  }

  /// Starts the UPDATE-query.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  static QueryBuilder update({QueryBuilderOptions? options}) {
    return Update(options);
  }

  /// Starts the INSERT-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  static QueryBuilder insert({QueryBuilderOptions? options}) {
    return Insert(options);
  }

  /// Starts the DELETE-query with the provided options.
  /// @param options Options to use for query generation.
  /// @return QueryBuilder
  static QueryBuilder delete(QueryBuilderOptions options) {
    return Delete(options);
  }
}
