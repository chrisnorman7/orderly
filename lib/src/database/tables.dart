import 'package:drift/drift.dart';

/// Add a primary key to a class.
mixin IdMixin on Table {
  /// The primary key column.
  IntColumn get id => integer().autoIncrement()();
}

/// Add a [name] column.
mixin NameMixin on Table {
  /// The name column.
  TextColumn get name => text()();
}

/// A customer.
class Customers extends Table with IdMixin, NameMixin {
  /// When this customer was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// An address for a customer.
@DataClassName('CustomerAddress')
class CustomerAddresses extends Table with IdMixin, NameMixin {
  /// The ID of the customer this address belongs to.
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  /// When this address was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The street address.
  TextColumn get street => text()();

  /// The city where the customer resides.
  TextColumn get city => text()();

  /// The state where the customer resides.
  TextColumn get state => text()();

  /// The customer's country of residence.
  TextColumn get country => text()();

  /// The post or zip code for the customer.
  TextColumn get postcode => text()();
}

/// A shop in the ordering system.
class Shops extends Table with IdMixin, NameMixin {
  /// The date when this shop was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The currency to use in prices.
  TextColumn get currency => text().withDefault(const Constant('£'))();

  /// The payment link to use.
  ///
  /// The [paymentUrl] will be rendered with Jinja.
  TextColumn get paymentUrl => text().withDefault(
    const Constant(
      'https://monzo.me/<username>/{{ price }}?d={{ reference }}&account_type=personal',
    ),
  )();
}

/// A product in a shop.
class ShopProducts extends Table with IdMixin, NameMixin {
  /// The ID of the shop this product is part of.
  IntColumn get shopId =>
      integer().references(Shops, #id, onDelete: KeyAction.restrict)();

  /// The date this product was first available.
  DateTimeColumn get firstAvailable =>
      dateTime().withDefault(currentDateAndTime)();

  /// The price in pennies.
  IntColumn get price => integer().withDefault(const Constant(150))();

  /// The date this product was discontinued.
  DateTimeColumn get discontinuedAt => dateTime().nullable()();
}

/// An order in a shop.
class ShopOrders extends Table with IdMixin {
  /// The shop that items for this order will be chosen from.
  IntColumn get shopId =>
      integer().references(Shops, #id, onDelete: KeyAction.cascade)();

  /// When this order was placed.
  ///
  /// The [orderPlaced] column will also act as the order number.
  DateTimeColumn get orderPlaced =>
      dateTime().withDefault(currentDateAndTime)();

  /// The address where this order will be sent.
  IntColumn get addressId => integer().references(
    CustomerAddresses,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// The postage cost for this order.
  IntColumn get postageCost => integer().withDefault(const Constant(0))();

  /// When this order was paid for.
  DateTimeColumn get orderPaid => dateTime().nullable()();

  /// When this order was dispatched.
  DateTimeColumn get orderDispatched => dateTime().nullable()();
}

/// An item in a shop order.
class OrderItems extends Table with IdMixin {
  /// The ID of the order this item is part of.
  IntColumn get orderId =>
      integer().references(ShopOrders, #id, onDelete: KeyAction.cascade)();

  /// The ID of the product being ordered.
  IntColumn get productId =>
      integer().references(ShopProducts, #id, onDelete: KeyAction.restrict)();

  /// The order quantity.
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// The order notes.
  TextColumn get notes => text().withDefault(const Constant(''))();
}
