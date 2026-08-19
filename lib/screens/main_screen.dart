import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/screens/addresses_screen.dart';
import 'package:orderly/screens/shop_screen.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';
import 'package:orderly/widgets/pages/customers_page.dart';
import 'package:orderly/widgets/pages/shops_page.dart';

/// The main screen of the application.
class MainScreen extends ConsumerStatefulWidget {
  /// Create an instance.
  const MainScreen({super.key});

  /// Create state for this widget.
  @override
  MainScreenState createState() => MainScreenState();
}

/// State for [MainScreen].
class MainScreenState extends ConsumerState<MainScreen> {
  late OrderlyDatabase _database;

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    _database.close();
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    _database = ref.watch(databaseProvider);
    return TabbedScaffold(
      tabs: [
        TabbedScaffoldTab(
          title: 'Shops',
          icon: const Icon(Icons.shop),
          child: CommonShortcuts(
            newCallback: _newShop,
            child: const ShopsPage(),
          ),
          floatingActionButton: NewButton(
            onPressed: _newShop,
            tooltip: 'Create a new shop.',
          ),
        ),
        TabbedScaffoldTab(
          title: 'Customers',
          icon: const Icon(Icons.people),
          child: CommonShortcuts(
            newCallback: _newCustomer,
            child: const CustomersPage(),
          ),
          floatingActionButton: NewButton(
            onPressed: _newCustomer,
            tooltip: 'Create a new customer.',
          ),
        ),
      ],
    );
  }

  /// Create a new customer.
  Future<void> _newCustomer() => context.pushWidgetBuilder(
    (builderContext) => GetText(
      onDone: (name) async {
        builderContext.pop();
        final customer = await _database.managers.customers.createReturning(
          (o) => o(name: name),
        );
        if (ref.context.mounted) {
          await ref.context.pushWidgetBuilder(
            (_) => AddressesScreen(customer: customer),
          );
        }
        ref.invalidate(customersProvider);
      },
      labelText: 'Customer name',
      title: 'Create Customer',
    ),
  );

  /// Create a new shop.
  Future<void> _newShop() => context.pushWidgetBuilder(
    (builderContext) => GetText(
      onDone: (name) async {
        builderContext.pop();
        final shop = await _database.managers.shops.createReturning(
          (o) => o(name: name),
        );
        if (ref.context.mounted) {
          await ref.context.pushWidgetBuilder((_) => ShopScreen(shop: shop));
        }
        ref.invalidate(shopsProvider);
      },
      labelText: 'Shop name',
      title: 'Create Shop',
    ),
  );
}
