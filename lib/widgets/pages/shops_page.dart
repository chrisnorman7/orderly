import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// The shops page.
class ShopsPage extends ConsumerWidget {
  /// Create an instance.
  const ShopsPage({super.key});

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            return PerformableActionsListTile(
              actions: const [],
              autofocus: index == 0,
              title: Text(shop.name),
              subtitle: Text(shop.currency),
            );
          },
          itemCount: shops.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
