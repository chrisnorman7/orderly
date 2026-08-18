import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';
import 'package:orderly/widgets/price_text.dart';

/// A screen for editing an [order].
class EditOrderScreen extends ConsumerWidget {
  /// Create an instance.
  const EditOrderScreen({required this.shop, required this.order, super.key});

  /// The shop to work with.
  final Shop shop;

  /// The order to start with.
  final ShopOrder order;

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final orderContextValue = ref.watch(orderProvider(order));
    return Cancel(
      child: SimpleScaffold(
        title: 'Edit Order',
        body: AsyncValueBuilder(
          value: orderContextValue,
          builder: (orderContext) {
            final productsValue = ref.watch(productsProvider(shop));
            return AsyncValueBuilder(
              value: productsValue,
              builder: (products) {
                if (products.isEmpty) {
                  return const CenterText(
                    text: 'There are no products to show.',
                    autofocus: true,
                  );
                }
                final items = orderContext.items;
                final productIds = Set<int>.from(
                  items.map((i) => i.product.id),
                );
                final remainingProducts = products
                    .where((p) => !productIds.contains(p.id))
                    .toList();
                return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      final productIndex = index - items.length;
                      final product = remainingProducts[productIndex];
                      return ListTile(
                        autofocus: index == 0,
                        title: Text(product.name),
                        subtitle: PriceText(shop: shop, price: product.price),
                        onTap: () async {
                          await db.managers.orderItems.create(
                            (o) => o(orderId: order.id, productId: product.id),
                          );
                          ref.invalidate(orderItemsProvider(order));
                        },
                      );
                    }
                    final item = items[index];
                    final provider = orderItemProvider(item.orderItem);
                    final query = db.managers.orderItems.filter(
                      (f) => f.id.equals(item.orderItem.id),
                    );
                    return PerformableActionsListTile(
                      actions: [
                        PerformableAction(
                          name: 'Add',
                          activator: moveUpShortcut,
                          invoke: () async {
                            await query.update(
                              (o) => o(quantity: Value(item.quantity + 1)),
                            );
                            ref.invalidate(provider);
                          },
                        ),
                        if (item.quantity > 0)
                          PerformableAction(
                            name: 'Remove',
                            activator: moveDownShortcut,
                            invoke: () async {
                              if (item.quantity == 1) {
                                await query.delete();
                              } else {
                                await query.update(
                                  (o) => o(quantity: Value(item.quantity - 1)),
                                );
                              }
                              ref.invalidate(provider);
                            },
                          ),
                        PerformableAction(
                          name: 'Delete',
                          activator: deleteShortcut,
                          invoke: () async {
                            await query.delete();
                            ref.invalidate(provider);
                          },
                        ),
                      ],
                      autofocus: index == 0,
                      title: Text('${item.product.name} x ${item.quantity}'),
                      subtitle: PriceText(
                        shop: shop,
                        price: item.product.price * item.quantity,
                      ),
                      onTap: () => context.pushWidgetBuilder(
                        (builderContext) => GetText(
                          onDone: (notes) async {
                            builderContext.pop();
                            await query.update((o) => o(notes: Value(notes)));
                            ref.invalidate(provider);
                          },
                          labelText: 'Notes',
                          text: item.orderItem.notes,
                          title: 'Edit Notes',
                        ),
                      ),
                    );
                  },
                  itemCount: items.length + remainingProducts.length,
                  shrinkWrap: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
