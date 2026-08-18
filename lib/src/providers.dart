import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/order_context.dart';
import 'package:orderly/src/order_item_context.dart';

/// Provide the database.
final databaseProvider = Provider((ref) => OrderlyDatabase());

/// Provide all customers.
final customersProvider = FutureProvider<List<Customer>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.managers.customers.orderBy((o) => o.createdAt.desc()).get();
});

/// Provide a single customer.
final customerProvider = FutureProvider.family<Customer, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.managers.customers.filter((f) => f.id.equals(id)).getSingle();
});

/// Provide all addresses for a [Customer].
final addressesProvider =
    FutureProvider.family<List<CustomerAddress>, Customer>((ref, customer) {
      final db = ref.watch(databaseProvider);
      return db.managers.customerAddresses
          .filter((f) => f.customerId.id.equals(customer.id))
          .orderBy((o) => o.createdAt.desc())
          .get();
    });

/// Provide a single address.
final addressProvider = FutureProvider.family<CustomerAddress, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.managers.customerAddresses
      .filter((f) => f.id.equals(id))
      .getSingle();
});

/// Provide all products in a [Shop].
final productsProvider = FutureProvider.family<List<ShopProduct>, Shop>((
  ref,
  shop,
) {
  final db = ref.watch(databaseProvider);
  return db.managers.shopProducts
      .filter((f) => f.shopId.id.equals(shop.id))
      .orderBy((o) => o.firstAvailable.desc())
      .get();
});

/// Provide a single product.
final productProvider = FutureProvider.family<ShopProduct, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.managers.shopProducts.filter((f) => f.id.equals(id)).getSingle();
});

/// Provide full items for an order.
final orderItemsProvider =
    FutureProvider.family<List<OrderItemContext>, ShopOrder>((
      ref,
      order,
    ) async {
      final db = ref.watch(databaseProvider);
      final orderItems = await db.managers.orderItems
          .filter((f) => f.orderId.id.equals(order.id))
          .get();
      final items = <OrderItemContext>[];
      for (final item in orderItems) {
        final product = await ref.watch(productProvider(item.productId).future);
        items.add(OrderItemContext(orderItem: item, product: product));
      }
      return items;
    });

/// Provide a complete order.
final orderProvider = FutureProvider.family<OrderContext, ShopOrder>((
  ref,
  order,
) async {
  final address = await ref.watch(addressProvider(order.addressId).future);
  final customer = await ref.watch(customerProvider(address.customerId).future);
  final items = await ref.watch(orderItemsProvider(order).future);
  return OrderContext(
    order: order,
    customer: customer,
    address: address,
    items: items,
  );
});
