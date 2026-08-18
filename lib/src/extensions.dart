/// Useful extensions for [int]s.
extension IntX on int {
  /// Return this [int] as a price.
  ///
  /// [asPrice] assumes that `this` [int] is given as the number of pennies or
  /// cents in the target currency.
  String get asPrice {
    final pounds = (this / 100).floor();
    final pence = this % 100;
    return '$pounds.$pence';
  }
}
