import 'query_builder_options.dart';
import 'validator.dart';
import 'util.dart';

enum ExpressionType { AND, OR }

/// SQL expression builder.
/// A new expression should be created using new Expression() call.
///

class ExpressionNode {
  ExpressionNode();

  ExpressionNode.fromTypeExprParam(
      ExpressionType type, String expr, Object? param) {
    this.type = type;
    this.expr = expr;
    this.param = param;
  }

  ExpressionNode.fromTypeParent(ExpressionType type, ExpressionNode? parent) {
    this.type = type;
    this.parent = parent;
  }
  ExpressionType? type;
  String? expr;
  Object? param;
  ExpressionNode? parent;
  List<ExpressionNode> nodes = [];
}

class Expression {
  Expression(QueryBuilderOptions? options) {
    mOptions = options ?? QueryBuilderOptions();
    //mOptions = options != null ? options : QueryBuilderOptions();
    mTree = ExpressionNode();
    mCurrent = ExpressionNode();
  }

  QueryBuilderOptions? mOptions;
  late ExpressionNode mTree;
  ExpressionNode? mCurrent;

  /// Begin AND nested expression.
  /// @return Expression
  Expression andBegin() {
    return doBegin(ExpressionType.AND);
  }

  /// Begin OR nested expression.
  /// @return Expression
  Expression orBegin() {
    return doBegin(ExpressionType.OR);
  }

  /// End the current compound expression.
  /// @return Expression
  Expression end() {
    assert(mCurrent != null &&
        mCurrent!.parent != null); // "begin() needs to be called"
    mCurrent = mCurrent!.parent;
    return this;
  }

  /// Combine the current expression with the given expression using the intersection operator (AND).
  /// @param expr Expression to combine with.
  /// @return Expression
  Expression and(String expr) {
    return andWithParam(expr, null);
  }

  /// Combine the current expression with the given expression using the intersection operator (AND).
  /// @param expr Expression to combine with.
  /// @param param Value to substitute.
  /// @param <P> Number|String|Boolean|QueryBuilder|Expression|Array|Iterable
  /// @return Expression
  Expression andWithParam(String expr, param) {
    final newNode =
        ExpressionNode.fromTypeExprParam(ExpressionType.AND, expr, param);
    mCurrent!.nodes.add(newNode);
    return this;
  }

  /// Combine the current expression with the given expression using the union operator (OR).
  /// @param expr Expression to combine with.
  /// @return Expression
  Expression or(String expr) {
    return orFromExprParam(expr, null);
  }

  /// Combine the current expression with the given expression using the union operator (OR).
  /// @param expr Expression to combine with.
  /// @param param Value to substitute.
  /// @param <P> Number|String|Boolean|QueryBuilder|Expression|Array|Iterable
  /// @return Expression
  Expression orFromExprParam(String expr, param) {
    final newNode =
        ExpressionNode.fromTypeExprParam(ExpressionType.OR, expr, param);
    mCurrent!.nodes.add(newNode);
    return this;
  }

  /// Get the Expression string.
  /// @return A String representation of the expression.
  @override
  String toString() {
    assert(mCurrent != null &&
        mCurrent!.parent == null); // "end() needs to be called"
    return doString(mTree);
  }

  /// Begin a nested expression
  /// @param op Operator to combine with the current expression
  /// @return Expression
  Expression doBegin(ExpressionType op) {
    final newTree = ExpressionNode.fromTypeParent(op, mCurrent);
    mCurrent!.nodes.add(newTree);
    mCurrent = newTree;
    return this;
  }

  /// Get a string representation of the given expression tree node.
  /// @param node Node to
  /// @return String
  String doString(ExpressionNode node) {
    var sb = StringBuffer();
    String nodeStr;
    for (var child in node.nodes) {
      if (child.expr != null) {
        nodeStr = child.expr!
            .replaceAll('?', Validator.formatValue(child.param, mOptions)!);
      } else {
        nodeStr = doString(child);

        // wrap nested expressions in brackets
        if (!Util.isEmpty(nodeStr)) {
          nodeStr = '($nodeStr)';
        }
      }

      if (!Util.isEmpty(nodeStr)) {
        if (sb.length > 0) {
          sb.write(' ');
          sb.write(child.type);
          sb.write(' ');
        }
        sb.write(nodeStr);
      }
    }
    return sb.toString();
  }
}
