import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/new_order_screen.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/pages/products_page.dart';
import 'package:orderly/widgets/pages/shop_orders_page.dart';

/// The shop screen.
class ShopScreen extends ConsumerWidget {
  /// Create an instance.
  const ShopScreen({required this.shop, super.key});

  /// The shop to use.
  final Shop shop;

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) => Cancel(
    child: TabbedScaffold(
      tabs: [
        TabbedScaffoldTab(
          title: 'Products',
          icon: const Icon(Icons.shop),
          child: CommonShortcuts(
            child: ProductsPage(shop: shop),
            newCallback: () => _newProduct(ref),
          ),
          floatingActionButton: NewButton(
            onPressed: () => _newProduct(ref),
            tooltip: 'Create New Product.',
          ),
        ),
        TabbedScaffoldTab(
          title: 'Orders',
          icon: const Icon(Icons.sports_basketball),
          child: CommonShortcuts(
            child: ShopOrdersPage(shop: shop),
            newCallback: () => _newOrder(ref),
          ),
          floatingActionButton: NewButton(
            onPressed: () => _newOrder(ref),
            tooltip: 'Create a new order.',
          ),
        ),
      ],
    ),
  );

  /// Create a new product.
  Future<void> _newProduct(WidgetRef ref) => ref.context.pushWidgetBuilder(
    (builderContext) => GetText(
      onDone: (name) async {
        builderContext.pop();
        final db = ref.read(databaseProvider);
        await db.managers.shopProducts.createReturning(
          (o) => o(name: name, shopId: shop.id),
        );
        ref.invalidate(productsProvider(shop));
      },
      labelText: 'Product name',
      title: 'Create Product',
    ),
  );

  /// Create a new order.
  Future<void> _newOrder(WidgetRef ref) => ref.context.pushWidgetBuilder(
    (_) => NewOrderScreen(shop: shop, onDone: (order) {}),
  );
}
