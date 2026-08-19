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
}
