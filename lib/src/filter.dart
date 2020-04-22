/// Error thrown for invalid operations in [Filter].
class FilterError {
  final String message;
  FilterError(this.message);
}

/// Condition for [Filter].
class Condition {
  static const String EQ = '=';
  static const String NE = '<>';
  static const String GT = '>';
  static const String GTE = '>=';
  static const String LT = '<';
  static const String LTE = '<=';
  static const String IN = 'IN';
  static const String BETWEEN = 'BETWEEN';
  static const String LIKE = 'LIKE';
  static const String MATCHES = 'MATCHES';

  String key;
  dynamic value;
  String predicate;

  Condition(this.key, this.value, this.predicate);

  @override
  String toString() => 'Condition(${key} ${predicate} $value)';
}

/// Criteria provides a way to filter entities fetched from [Repository] based
/// on certain conditions. Used in `findOne`, `find` and `count` methods of
/// [Repository] interface.
class Filter<T> {
  final List<Condition> conditions = <Condition>[];
  int skip;
  int take;

  /// Default constructor.
  Filter();

  /// Creates new criteria as a copy of [other].
  factory Filter.from(Filter<T> other) {
    return Filter<T>()
      ..conditions.addAll(other.conditions)
      ..skip = other.skip
      ..take = other.take;
  }

  /// Adds a condition to this criteria. Provides convenient way for defining
  /// basic conditions (`==`, `<`, `<=`, `>`, `>=`) based on values of entity
  /// fields.
  ///
  ///     var criteria = new Criteria<User>();
  ///     criteria.where((user) => user.name == 'John');
  ///
  /// The above example will add an "equals" condition to the criteria. It is
  /// basically a "sugar" syntax for:
  ///
  ///     var criteria = new Criteria<User>();
  ///     criteria.conditions.add(new Condition('name', 'John', Condition.EQ));
  /*void where(bool test(T entity)) {
    var entity = new _EntityStub<T>();
    test(entity); // dynamic proxies... where are you?
    conditions.addAll(entity.conditions);
  }*/
}
/*
@proxy
class _EntityStub<T> {
  final List<_FieldStub> fields = new List();
  List<Condition> _conditions;

  @override
  noSuchMethod(Invocation invocation) {
    // TODO: validate that field name actually exists in `T`.
    if (invocation.isGetter) {
      var field = new _FieldStub(MirrorSystem.getName(invocation.memberName));
      fields.add(field);
      return field;
    } else {
      throw new FilterError('Only getters can be called in criteria builder.');
    }
  }

  List<Condition> get conditions {
    if (_conditions == null) {
      _conditions = new List();
      for (var f in fields) {
        _conditions.addAll(f.conditions);
      }
    }
    return _conditions;
  }
}

abstract class FieldStub {
  List<Condition> get conditions;
}

// TODO: implement all possible operators.
@proxy
class _FieldStub implements FieldStub {
  final String name;
  final List<Condition> conditions = new List();

  _FieldStub(this.name);

  @override
  bool operator ==(other) {
    conditions.add(new Condition(name, other, Condition.EQ));
    return true;
  }

  bool operator >(other) {
    conditions.add(new Condition(name, other, Condition.GT));
    return true;
  }

  bool operator >=(other) {
    conditions.add(new Condition(name, other, Condition.GTE));
    return true;
  }

  bool operator <(other) {
    conditions.add(new Condition(name, other, Condition.LT));
    return true;
  }

  bool operator <=(other) {
    conditions.add(new Condition(name, other, Condition.LTE));
    return true;
  }
}*/
