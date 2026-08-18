import 'package:orderly/src/database/database.dart';

/// Hold details for an [orderItem].
class OrderItemContext {
  /// Create an instance.
  const OrderItemContext({required this.orderItem, required this.product});

  /// The item which is being ordered.
  final OrderItem orderItem;

  /// The product which [orderItem] refers to.
  final ShopProduct product;

  /// Get the quantity of [product] in this [orderItem].
  int get quantity => orderItem.quantity;
}
