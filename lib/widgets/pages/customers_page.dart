import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/addresses_screen.dart';
import 'package:orderly/src/performable_actions/rename_action.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// The customers page.
class CustomersPage extends ConsumerWidget {
  /// Create an instance.
  const CustomersPage({super.key});

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
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
            final query = db.managers.customers.filter(
              (f) => f.id.equals(customer.id),
            );
            return PerformableActionsListTile(
              actions: [
                RenameAction(
                  context: context,
                  currentName: customer.name,
                  setName: (newName) async {
                    await query.update((o) => o(name: Value(newName)));
                    ref.invalidate(customersProvider);
                  },
                ),
              ],
              autofocus: index == 0,
              title: Text(customer.name),
              subtitle: Text('#${customer.id}'),
              onTap: () => context.pushWidgetBuilder(
                (_) => AddressesScreen(customer: customer),
              ),
            );
          },
          itemCount: customers.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
