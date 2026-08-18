import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';
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
            return PerformableActionsListTile(
              actions: const [],
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
