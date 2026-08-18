import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:orderly/src/database/tables.dart';

part 'database.g.dart';

/// The database to use.
@DriftDatabase(
  tables: [
    Customers,
    CustomerAddresses,
    Shops,
    ShopProducts,
    ShopOrders,
    OrderItems,
  ],
)
class OrderlyDatabase extends _$OrderlyDatabase {
  /// Create an instance.
  OrderlyDatabase() : super(driftDatabase(name: 'orderly'));

  /// The schema version.
  @override
  int get schemaVersion => 1;
}
