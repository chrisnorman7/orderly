import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/order_item_context.dart';

/// Hold context for an [order].
class OrderContext {
  /// Create an instance.
  const OrderContext({
    required this.order,
    required this.customer,
    required this.address,
    required this.items,
  });

  /// The order to deal with.
  final ShopOrder order;

  /// The customer who made the [order].
  final Customer customer;

  /// THe [customer] address where [order] will be sent.
  final CustomerAddress address;

  /// The items in this [order].
  final List<OrderItemContext> items;
}
