import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderly/src/extensions.dart';

/// Actions for prices.
class PriceActions {
  /// Create an instance.
  const PriceActions({
    required this.context,
    required this.price,
    required this.currency,
    required this.onChanged,
  });

  /// The build context to use.
  final BuildContext context;

  /// The current price.
  final int price;

  /// The currency to use.
  final String currency;

  /// The function to call to set a new [price].
  final Future<void> Function(int newPrice) onChanged;

  /// The actions to use.
  List<PerformableAction> get actions => [
    PerformableAction(
      name: 'Increase by ${currency}1',
      activator: CrossPlatformSingleActivator(LogicalKeyboardKey.home),
      invoke: () => onChanged(price + 100),
    ),
    PerformableAction(
      name: 'Decrease by ${currency}1',
      activator: CrossPlatformSingleActivator(LogicalKeyboardKey.end),
      invoke: () => onChanged(price - 100),
    ),
    PerformableAction(
      name: 'Increase by ${currency}0.01',
      activator: CrossPlatformSingleActivator(LogicalKeyboardKey.pageUp),
      invoke: () => onChanged(price + 1),
    ),
    PerformableAction(
      name: 'Decrease by ${currency}0.01',
      activator: CrossPlatformSingleActivator(LogicalKeyboardKey.pageDown),
      invoke: () => onChanged(price - 1),
    ),
    PerformableAction(
      name: 'Set Price',
      activator: CrossPlatformSingleActivator(
        LogicalKeyboardKey.keyP,
        shift: true,
      ),
      invoke: () => context.pushWidgetBuilder(
        (builderContext) => GetText(
          onDone: (priceString) async {
            final price = double.parse(priceString);
            builderContext.pop();
            await onChanged((price * 100).floor());
          },
          labelText: 'Price',
          text: price.asPrice,
          title: 'Set Price',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'You must enter a value.';
            }
            if (double.tryParse(value) == null) {
              return 'Invalid price.';
            }
            return null;
          },
        ),
      ),
    ),
  ];
}
