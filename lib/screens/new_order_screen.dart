import 'dart:async';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/async_value_builder.dart';

/// The new orders screen.
class NewOrderScreen extends ConsumerStatefulWidget {
  /// Create an instance.
  const NewOrderScreen({required this.shop, required this.onDone, super.key});

  /// The shop to create an order for.
  final Shop shop;

  /// The function to call when the new order has been placed.
  ///
  /// It is not necessary for [onDone] to invalidate [ordersForShopProvider], as
  /// that will be done by this widget.
  final FutureOr<void> Function(ShopOrder order) onDone;

  /// Create state for this widget.
  @override
  NewOrderScreenState createState() => NewOrderScreenState();
}

/// State for [NewOrderScreen].
class NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  /// The customer to create an order for.
  Customer? _customer;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final customer = _customer;
    if (customer == null) {
      final value = ref.watch(customersProvider);
      return Cancel(
        child: SimpleScaffold(
          title: 'Select Customer',
          body: AsyncValueBuilder(
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
                  return ListTile(
                    autofocus: index == 0,
                    title: Text(customer.name),
                    onTap: () => setState(() => _customer = customer),
                  );
                },
                itemCount: customers.length,
                shrinkWrap: true,
              );
            },
          ),
        ),
      );
    }
    final value = ref.watch(addressesProvider(customer));
    return Cancel(
      child: SimpleScaffold(
        title: 'Select Address',
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
                  title: Text(
                    '${address.street}, ${address.city}, ${address.state}',
                  ),
                  subtitle: Text('${address.country}, ${address.postcode}'),
                  onTap: () async {
                    context.pop();
                    final order = await db.managers.shopOrders.createReturning(
                      (o) => o(addressId: address.id, shopId: widget.shop.id),
                    );
                    ref.invalidate(ordersForShopProvider(widget.shop));
                    widget.onDone(order);
                  },
                );
              },
              itemCount: addresses.length,
              shrinkWrap: true,
            );
          },
        ),
      ),
    );
  }
}
