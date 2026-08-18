import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/providers.dart';

/// A screen for editing an address.
class EditAddressScreen extends ConsumerStatefulWidget {
  /// Create an instance.
  const EditAddressScreen({
    required this.customer,
    required this.address,
    super.key,
  });

  /// The customer whose [address] will be edited.
  final Customer customer;

  /// The address to edit.
  final CustomerAddress address;

  /// Create state for this widget.
  @override
  EditAddressScreenState createState() => EditAddressScreenState();
}

/// State for [EditAddressScreen].
class EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  /// The database to use.
  late OrderlyDatabase db;

  // Controllers:
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postcodeController;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.name);
    _streetController = TextEditingController(text: widget.address.street);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _countryController = TextEditingController(text: widget.address.country);
    _postcodeController = TextEditingController(text: widget.address.postcode);
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    for (final controller in [
      _nameController,
      _streetController,
      _cityController,
      _stateController,
      _countryController,
      _postcodeController,
    ]) {
      controller.dispose();
    }
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    db = ref.watch(databaseProvider);
    return PopScope(
      onPopInvokedWithResult: (_, _) => _updateAddress(),
      child: Cancel(
        child: SimpleScaffold(
          title: 'Edit Address',
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    selectAllOnFocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street address',
                    ),
                    selectAllOnFocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    selectAllOnFocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                    selectAllOnFocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    selectAllOnFocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _postcodeController,
                    decoration: const InputDecoration(labelText: 'Postcode'),
                    selectAllOnFocus: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Update the address.
  Future<void> _updateAddress() async {
    final street = _streetController.text;
    final city = _cityController.text;
    final state = _stateController.text;
    final country = _countryController.text;
    final postcode = _postcodeController.text;
    final name = _nameController.text;
    final query = db.managers.customerAddresses.filter(
      (f) => f.id.equals(widget.address.id),
    );
    await query.update(
      (o) => o(
        street: Value(street),
        city: Value(city),
        state: Value(state),
        country: Value(country),
        postcode: Value(postcode),
        name: Value(name),
      ),
    );
    ref.invalidate(addressesProvider(widget.customer));
  }
}
