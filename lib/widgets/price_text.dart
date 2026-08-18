import 'package:flutter/material.dart';
import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';

/// A [Text] widget which shows a
/// [shop] [price].
class PriceText extends StatelessWidget {
  /// Create an instance.
  const PriceText({required this.shop, required this.price, super.key});

  /// The shop whose currency will be used.
  final Shop shop;

  /// The price to show.
  final int price;

  /// Build the widget.
  @override
  Widget build(BuildContext context) =>
      Text('${shop.currency}${price.asPrice}');
}
