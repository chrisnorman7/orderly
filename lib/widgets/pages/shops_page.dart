import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/shop_screen.dart';
import 'package:orderly/src/extensions.dart';
import 'package:orderly/src/performable_actions/rename_action.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';
import 'package:url_launcher/url_launcher.dart';

/// The shops page.
class ShopsPage extends ConsumerWidget {
  /// Create an instance.
  const ShopsPage({super.key});

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final value = ref.watch(shopsProvider);
    return AsyncValueBuilder(
      value: value,
      builder: (shops) {
        if (shops.isEmpty) {
          return const CenterText(
            text: 'There are no shops to show.',
            autofocus: true,
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            final shop = shops[index];
            final query = db.managers.shops.filter((f) => f.id.equals(shop.id));
            return PerformableActionsListTile(
              actions: [
                RenameAction(
                  context: context,
                  currentName: shop.name,
                  setName: (newName) async {
                    await query.update((o) => o(name: Value(newName)));
                    ref.invalidate(shopsProvider);
                  },
                ),
                PerformableAction(
                  name: 'Change Currency',
                  invoke: () => context.pushWidgetBuilder(
                    (builderContext) => GetText(
                      onDone: (currency) async {
                        builderContext.pop();
                        await query.update((o) => o(currency: Value(currency)));
                        ref.invalidate(shopsProvider);
                      },
                      labelText: 'New currency',
                      text: shop.currency,
                      title: 'Change Currency',
                    ),
                  ),
                ),
                PerformableAction(
                  name: 'Change Payment URL',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyU,
                    shift: true,
                  ),
                  invoke: () => context.pushWidgetBuilder(
                    (builderContext) => GetText(
                      onDone: (url) async {
                        builderContext.pop();
                        await query.update((o) => o(paymentUrl: Value(url)));
                        ref.invalidate(shopsProvider);
                      },
                      // ignore: lines_longer_than_80_chars
                      labelText: 'Payment URL ({{ price }} for price, {{ reference }} for reference)',
                      text: shop.paymentUrl,
                      title: 'Payment URL',
                    ),
                  ),
                ),
                PerformableAction(
                  name: 'Test Payment URL',
                  activator: CrossPlatformSingleActivator(
                    LogicalKeyboardKey.keyT,
                    shift: true,
                  ),
                  invoke: () => launchUrl(
                    shop.getPaymentUrl(
                      price: '0.01',
                      reference: 'Test Payment',
                    ),
                  ),
                ),
                PerformableAction(
                  name: 'Delete',
                  activator: deleteShortcut,
                  invoke: () async {
                    final products = await ref.read(
                      productsProvider(shop).future,
                    );
                    if (products.isEmpty) {
                      await query.delete();
                      ref.invalidate(shopsProvider);
                    } else if (context.mounted) {
                      await context.showMessage(
                        message:
                            'You can only delete shops which have no products.',
                      );
                    }
                  },
                ),
              ],
              autofocus: index == 0,
              title: Text(shop.name),
              subtitle: Text(shop.currency),
              onTap: () =>
                  context.pushWidgetBuilder((_) => ShopScreen(shop: shop)),
            );
          },
          itemCount: shops.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
