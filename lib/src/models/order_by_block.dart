import 'block.dart';
import 'query_builder.dart';
import 'query_builder_options.dart';
import 'sort_order.dart';
import 'validator.dart';

class OrderNode {
  OrderNode(this.field, this.dir);
  final String field;
  final SortOrder dir;
}

/// ORDER BY
class OrderByBlock extends Block {
  OrderByBlock(QueryBuilderOptions? options) : super(options);
  List<OrderNode>? mOrders;

  /// Add an ORDER BY transformation for the given setField in the given order.
  /// @param field Field
  /// @param dir Order
  void setOrder(String field, SortOrder dir) {
    mOrders ??= [];

    final fld = Validator.sanitizeField(field, mOptions!);
    mOrders!.add(OrderNode(fld, dir));
  }

  @override
  String buildStr(QueryBuilder queryBuilder) {
    if (mOrders == null || mOrders!.isEmpty) {
      return '';
    }

    final sb = StringBuffer();
    for (var o in mOrders!) {
      if (sb.length > 0) {
        sb.write(', ');
      }

      sb.write(o.field);
      sb.write(' ');
      sb.write(o.dir == SortOrder.ASC ? 'asc' : 'desc');
    }

    return 'ORDER BY $sb';
  }
}
