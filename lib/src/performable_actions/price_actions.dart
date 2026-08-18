import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/services.dart';

/// Actions for prices.
class PriceActions {
  /// Create an instance.
  const PriceActions({
    required this.price,
    required this.currency,
    required this.onChanged,
  });

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
  ];
}
