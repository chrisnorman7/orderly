import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/edit_order_screen.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';
import 'package:orderly/src/order_invoice.dart';
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
            final String status;
            final orderCancelled = order.order.orderCancelled;
            final orderDispatched = order.order.orderDispatched;
            final orderPaid = order.order.orderPaid;
            if (orderCancelled != null) {
              status = 'Cancelled on ${dateFormatter.format(orderCancelled)}';
            } else if (orderDispatched != null) {
              status = 'Dispatched on ${dateFormatter.format(orderDispatched)}';
            } else if (orderPaid != null) {
              status = 'Paid on ${dateFormatter.format(orderPaid)}';
            } else {
              status = 'Unpaid';
            }
            return PerformableActionsListTile(
              actions: [
                PerformableAction(
                  name: 'Order Paid',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyP,
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
                PerformableAction(
                  name: 'Order Cancelled',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyC,
                    shift: true,
                  ),
                  checked: order.order.orderCancelled != null,
                  invoke: () async {
                    await query.update(
                      (o) => o(
                        orderCancelled: Value(
                          order.order.orderCancelled == null
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
                  name: 'Save Invoice',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyS,
                  ),
                  invoke: () async {
                    final invoice = OrderInvoice(shop: shop, order: order);
                    final document = invoice.makePdf();
                    final location = await getSaveLocation(
                      acceptedTypeGroups: [
                        const XTypeGroup(
                          extensions: ['pdf'],
                          label: 'Portable Document File',
                        ),
                      ],
                      suggestedName:
                          // ignore: lines_longer_than_80_chars
                          'order_${order.order.orderPlaced.asOrderNumber()}.pdf',
                    );
                    if (location == null) {
                      return;
                    }
                    final data = await document.save();
                    final file = XFile.fromData(data);
                    await file.saveTo(location.path);
                  },
                ),
                PerformableAction(
                  name: 'Copy Order Number',
                  activator: copyShortcut,
                  invoke: () => '#${order.order.orderPlaced.asOrderNumber()}'
                      .copyToClipboard(),
                ),
                PerformableAction(
                  name: 'Create Duplicate',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyD,
                  ),
                  invoke: () async {
                    final duplicate = await db.managers.shopOrders
                        .createReturning(
                          (o) => o(
                            addressId: order.address.id,
                            shopId: shop.id,
                            postageCost: Value(order.order.postageCost),
                          ),
                        );
                    for (final item in order.items) {
                      await db.managers.orderItems.create(
                        (o) => o(
                          orderId: duplicate.id,
                          productId: item.product.id,
                          notes: Value(item.orderItem.notes),
                          quantity: Value(item.quantity),
                        ),
                      );
                    }
                    ref.invalidate(ordersForShopProvider(shop));
                  },
                ),
                if (order.items.isEmpty)
                  PerformableAction(
                    name: 'Delete',
                    activator: deleteShortcut,
                    invoke: () async {
                      await query.delete();
                      ref.invalidate(ordersForShopProvider(shop));
                    },
                  ),
              ],
              autofocus: index == 0,
              title: Text(
                // ignore: lines_longer_than_80_chars
                [
                  // ignore: lines_longer_than_80_chars
                  '${order.customer.name} (#${order.order.orderPlaced.asOrderNumber()})',
                  // ignore: lines_longer_than_80_chars
                  '${shop.getPrice(order.totalPrice)} (${shop.getPrice(order.order.postageCost)} postage)',
                ].join('\n'),
              ),
              subtitle: Text(
                // ignore: lines_longer_than_80_chars
                status,
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
}
