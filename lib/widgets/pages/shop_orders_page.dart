import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/edit_order_screen.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';
import 'package:orderly/src/performable_actions/price_actions.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';
import 'package:orderly/widgets/date_text.dart';

/// The shop orders page.
class ShopOrdersPage extends ConsumerWidget {
  /// Create an instance.
  const ShopOrdersPage({required this.shop, super.key});

  /// The shop to show orders for.
  final Shop shop;

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final value = ref.watch(ordersForShopProvider(shop));
    return AsyncValueBuilder(
      value: value,
      builder: (orders) {
        if (orders.isEmpty) {
          return const CenterText(
            text: 'There are no orders to show.',
            autofocus: true,
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            final order = orders[index];
            final query = db.managers.shopOrders.filter(
              (f) => f.id.equals(order.order.id),
            );
            return PerformableActionsListTile(
              actions: [
                PerformableAction(
                  name: 'Order Paid',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyP,
                    shift: true,
                  ),
                  checked: order.order.orderPaid != null,
                  invoke: () async {
                    await query.update(
                      (o) => o(
                        orderPaid: Value(
                          order.order.orderPaid == null ? DateTime.now() : null,
                        ),
                      ),
                    );
                    ref.invalidate(ordersForShopProvider(shop));
                  },
                ),
                PerformableAction(
                  name: 'Order Dispatched',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyD,
                    shift: true,
                  ),
                  checked: order.order.orderDispatched != null,
                  invoke: () async {
                    await query.update(
                      (o) => o(
                        orderDispatched: Value(
                          order.order.orderDispatched == null
                              ? DateTime.now()
                              : null,
                        ),
                      ),
                    );
                    ref.invalidate(ordersForShopProvider(shop));
                  },
                ),
                ...PriceActions(
                  context: context,
                  price: order.order.postageCost,
                  currency: shop.currency,
                  onChanged: (newPrice) async {
                    await query.update((o) => o(postageCost: Value(newPrice)));
                    ref.invalidate(orderProvider(order.order));
                  },
                ).actions,
                PerformableAction(
                  name: 'Copy Email Text',
                  activator: copyShortcut,
                  invoke: () {
                    final address = order.address;
                    final buffer = StringBuffer()
                      ..writeln(
                        'Order #${_formatDateTime(order.order.orderPlaced)}.',
                      )
                      ..writeln('Deliver to:')
                      ..writeln(order.customer.name)
                      ..writeln(address.street)
                      ..writeln(address.city)
                      ..writeln(address.state)
                      ..writeln(address.country)
                      ..writeln(address.postcode)
                      ..writeln()
                      ..writeln('Items in order:')
                      ..writeln(
                        [
                          'Product',
                          'Quantity',
                          'Unit Price',
                          'Total Price',
                          'Notes',
                        ].join('\t'),
                      );
                    for (final item in order.items) {
                      final product = item.product;
                      buffer.writeln(
                        [
                          product.name,
                          'x ${item.quantity}',
                          '${shop.currency}${product.price.asPrice}',
                          // ignore: lines_longer_than_80_chars
                          '${shop.currency}${(product.price * item.quantity).asPrice}',
                          if (item.orderItem.notes.isEmpty)
                            'N/A'
                          else
                            item.orderItem.notes,
                        ].join('\t'),
                      );
                    }
                    buffer
                      ..writeln()
                      ..writeln(
                        // ignore: lines_longer_than_80_chars
                        'Before Postage: ${shop.currency}${order.productsPrice.asPrice}',
                      )
                      ..writeln(
                        // ignore: lines_longer_than_80_chars
                        'Postage: ${shop.currency}${order.order.postageCost.asPrice}',
                      )
                      ..writeln(
                        'Total: ${shop.currency}${order.totalPrice.asPrice}',
                      );
                    buffer.toString().copyToClipboard();
                  },
                ),
              ],
              autofocus: index == 0,
              title: DateText(date: order.order.orderPlaced),
              subtitle: Text(
                // ignore: lines_longer_than_80_chars
                '${shop.currency}${order.totalPrice.asPrice} (${shop.currency}${order.order.postageCost.asPrice})',
              ),
              onTap: () => context.pushWidgetBuilder(
                (_) => EditOrderScreen(shop: shop, order: order.order),
              ),
            );
          },
          itemCount: orders.length,
          shrinkWrap: true,
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${date.year}'
        '${twoDigits(date.month)}'
        '${twoDigits(date.day)}'
        '${twoDigits(date.hour)}'
        '${twoDigits(date.minute)}'
        '${twoDigits(date.second)}';
  }

  // Example: 20260818210645
}
