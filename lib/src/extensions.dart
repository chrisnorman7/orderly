import 'package:orderly/src/database/database.dart';

/// Useful extensions for [int]s.
extension IntX on int {
  /// Return this [int] as a price.
  ///
  /// [asPrice] assumes that `this` [int] is given as the number of pennies or
  /// cents in the target currency.
  String get asPrice {
    if (this < 0) {
      return '-${abs().asPrice}';
    }
    if (this == 0) {
      return '0.00';
    }
    final pounds = (this / 100).floor();
    final pence = this % 100;
    final penceString = pence.toString().padLeft(2, '0');
    return '$pounds.$penceString';
  }
}

/// Useful extensions for [DateTime]s.
extension DateTimeX on DateTime {
  /// Return `this` [DateTime] as an order number.
  String asOrderNumber() {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '$year'
        '${twoDigits(month)}'
        '${twoDigits(day)}'
        '${twoDigits(hour)}'
        '${twoDigits(minute)}'
        '${twoDigits(second)}';
  }
}

/// Useful extensions on [Shop]s.
extension ShopX on Shop {
  /// Return [price] as a readable string.
  String getPrice(int price) => '$currency${price.asPrice}';
}
