import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';
import 'package:orderly/src/performable_actions/price_actions.dart';
import 'package:orderly/src/performable_actions/rename_action.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// The products page.
class ProductsPage extends ConsumerWidget {
  /// Create an instance.
  const ProductsPage({required this.shop, super.key});

  /// The shop to show products for.
  final Shop shop;

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final value = ref.watch(productsProvider(shop));
    return AsyncValueBuilder(
      value: value,
      builder: (products) {
        if (products.isEmpty) {
          return const CenterText(
            text: 'There are no products to show.',
            autofocus: true,
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            final product = products[index];
            final query = db.managers.shopProducts.filter(
              (f) => f.id.equals(product.id),
            );
            return PerformableActionsListTile(
              actions: [
                RenameAction(
                  context: context,
                  currentName: product.name,
                  setName: (newName) async {
                    await query.update((o) => o(name: Value(newName)));
                    ref.invalidate(productsProvider(shop));
                  },
                ),
                ...PriceActions(
                  context: context,
                  price: product.price,
                  currency: shop.currency,
                  onChanged: (newPrice) async {
                    await query.update((o) => o(price: Value(newPrice)));
                    ref.invalidate(productsProvider(shop));
                  },
                ).actions,
              ],
              autofocus: index == 0,
              title: Text(product.name),
              subtitle: Text('${shop.currency}${product.price.asPrice}'),
              onTap: () {},
            );
          },
          itemCount: products.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
