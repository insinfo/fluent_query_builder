import 'block.dart';
import 'dart:collection';
import 'query_builder_options.dart';
import 'query_builder.dart';
import 'validator.dart';
import 'util.dart';

class FieldNode {
  FieldNode(this.name, this.alias);
  final String name;
  final String? alias;
}

/// (SELECT) field
class GetFieldBlock extends Block {
  GetFieldBlock(QueryBuilderOptions? options) : super(options);
  List<FieldNode>? mFields;
  HashMap<String, String?>? mFieldAliases;
  String? fieldRawSql;

  /// Add the given fields to the result.
  /// @param fields A collection of fields to add
  void setFields(Iterable<String> fields) {
    for (var field in fields) {
      setField(field, null);
    }
  }

  void setFieldsFromFieldNodeList(Iterable<FieldNode> fields) {
    for (var field in fields) {
      setField(field.name, field.alias);
    }
  }

  void setFieldRaw(String setFieldRawSql) {
    fieldRawSql = setFieldRawSql;
  }

  /// Add the given field to the final result.
  /// @param field Field to add
  /// @param alias Field's alias
  void setField(String field, String? alias) {
    var fieldValue = Validator.sanitizeField(field.trim(), mOptions!);

    final aliasValue =
        alias != null ? Validator.sanitizeFieldAlias(alias, mOptions!) : null;

    /// quote table and field string with dot, example:
    /// db.select().fields(['tablename.fieldname']).from('tablename') result in
    ///  SELECT "tablename"."fieldname" FROM tablename
    if (mOptions!.quoteStringWithFieldsTablesSeparator) {
      if (fieldValue.contains(mOptions!.fieldsTablesSeparator)) {
        fieldValue = fieldValue
            .split(mOptions!.fieldsTablesSeparator)
            .map((f) => f)
            .join(
                '${mOptions!.fieldAliasQuoteCharacter}${mOptions!.fieldsTablesSeparator}${mOptions!.fieldAliasQuoteCharacter}');
      }
    }

    /// allow alias in fields, example:
    /// db.select().fields(['tablename.fieldname as f']).from('tablename') result in
    ///  SELECT "tablename"."fieldname" as "f" FROM tablename
    if (mOptions!.allowAliasInFields) {
      final reg = RegExp(r'\s+\b|\b\s');
      if (fieldValue.contains(reg)) {
        fieldValue = fieldValue.replaceAll(' as ', ' ');
        fieldValue = fieldValue.replaceAll(reg, '" as "');
      }
    }

    doSetField(fieldValue, aliasValue);
  }

  void setFieldFromSubQuery(QueryBuilder field, String? alias) {
    final fieldName = Validator.sanitizeFieldFromQueryBuilder(field);
    final aliasValue =
        alias != null ? Validator.sanitizeFieldAlias(alias, mOptions!) : null;
    doSetField(fieldName, aliasValue);
  }

  @override
  String? buildStr(QueryBuilder queryBuilder) {
    if (fieldRawSql != null) {
      return fieldRawSql;
    }

    if (mFields == null || mFields!.isEmpty) {
      return '*';
    }

    final sb = StringBuffer();
    for (var field in mFields!) {
      if (sb.length > 0) {
        sb.write(', ');
      }

      sb.write(field.name);

      if (!Util.isEmpty(field.alias)) {
        sb.write(' AS ');
        sb.write(field.alias);
      }
    }

    return sb.toString();
  }

  void doSetField(String field, String? alias) {
    mFields ??= [];

    mFieldAliases ??= HashMap<String, String?>();

    if (mFieldAliases!.containsKey(field) && mFieldAliases![field] == alias) {
      return;
    }

    mFieldAliases![field] = alias;
    mFields!.add(FieldNode(field, alias));
  }
}
