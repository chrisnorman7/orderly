import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// The customers page.
class CustomersPage extends ConsumerWidget {
  /// Create an instance.
  const CustomersPage({super.key});

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(customersProvider);
    return AsyncValueBuilder(
      value: value,
      builder: (customers) {
        if (customers.isEmpty) {
          return const CenterText(
            text: 'There are no customers to show.',
            autofocus: true,
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            final customer = customers[index];
            return PerformableActionsListTile(
              actions: const [],
              autofocus: index == 0,
              title: Text(customer.name),
              subtitle: Text(customer.id.toString()),
              onTap: () {},
            );
          },
          itemCount: customers.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
