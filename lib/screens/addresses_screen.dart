import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/edit_address_screen.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// A screen for editing a [customer]'s addresses.
class AddressesScreen extends ConsumerWidget {
  /// Create an instance.
  const AddressesScreen({required this.customer, super.key});

  /// The customer to use.
  final Customer customer;

  /// Build the widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(addressesProvider(customer));
    return Cancel(
      child: CommonShortcuts(
        newCallback: () => _newAddress(ref),
        child: SimpleScaffold(
          title: 'Customer Addresses',
          body: AsyncValueBuilder(
            value: value,
            builder: (addresses) {
              if (addresses.isEmpty) {
                return CenterText(
                  text: 'There are no addresses for ${customer.name}.',
                  autofocus: true,
                );
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return ListTile(
                    autofocus: index == 0,
                    title: Text(address.name),
                    subtitle: Text(
                      [
                        address.street,
                        address.city,
                        address.state,
                        address.country,
                        address.postcode,
                      ].join('\n'),
                    ),
                    onTap: () => context.pushWidgetBuilder(
                      (_) => EditAddressScreen(
                        customer: customer,
                        address: address,
                      ),
                    ),
                  );
                },
                itemCount: addresses.length,
                shrinkWrap: true,
              );
            },
          ),
          floatingActionButton: NewButton(onPressed: () => _newAddress(ref)),
        ),
      ),
    );
  }

  /// Create a new address.
  Future<void> _newAddress(WidgetRef ref) => ref.context.pushWidgetBuilder(
    (builderContext) => GetText(
      onDone: (name) async {
        builderContext.pop();
        final db = ref.watch(databaseProvider);
        final address = await db.managers.customerAddresses.createReturning(
          (o) => o(
            name: name,
            street: '1234 Nowhere Street',
            city: 'Nowhere',
            state: 'West Nothing',
            country: 'England',
            postcode: 'NW5 4WN',
            customerId: customer.id,
          ),
        );
        if (ref.context.mounted) {
          await ref.context.pushWidgetBuilder(
            (_) => EditAddressScreen(customer: customer, address: address),
          );
        }
        ref.invalidate(addressesProvider(customer));
      },
      labelText: 'Address name',
      text: 'Home',
      title: 'Add Address',
    ),
  );
}
