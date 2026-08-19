import 'package:orderly/src/database/database.dart';
import 'package:orderly/src/extensions.dart';
import 'package:orderly/src/order_context.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// An invoice for an [order].
class OrderInvoice {
  /// Create an instance.
  const OrderInvoice({required this.shop, required this.order});

  /// The shop that [order] was made from.
  final Shop shop;

  /// The order to work with.
  final OrderContext order;

  /// Make a PDF invoice of [order].
  pw.Document makePdf() {
    final address = order.address;
    final document =
        pw.Document(
            author: shop.name,
            creator: 'Orderly',
            keywords: '${shop.name} Invoice',
          )
          ..addPage(
            pw.Page(
              build: (context) => pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Center(
                    child: pw.Header(
                      child: pw.Text(
                        'Order #${order.order.orderPlaced.asOrderNumber()}',
                      ),
                    ),
                  ),
                  pw.Header(level: 2, child: pw.Text('Deliver To')),
                  ...<String>[
                    '${order.customer.name} (${address.name})',
                    address.street,
                    address.city,
                    address.state,
                    address.country,
                    address.postcode,
                  ].map(pw.Text.new),
                ],
              ),
              pageFormat: PdfPageFormat.a4,
            ),
          )
          ..addPage(
            pw.Page(
              build: (context) {
                final items = order.items;
                return pw.Column(
                  children: [
                    pw.TableHelper.fromTextArray(
                      data: items.map((item) {
                        final product = item.product;
                        return [
                          product.name,
                          item.quantity.toString(),
                          shop.getPrice(product.price),
                          shop.getPrice(product.price * item.quantity),
                          if (item.orderItem.notes.isEmpty)
                            'N/A'
                          else
                            item.orderItem.notes,
                        ];
                      }).toList(),
                      headers: [
                        'Product',
                        'Quantity',
                        'Unit Price',
                        'Total Price',
                        'Notes',
                      ],
                    ),
                    pw.Header(
                      level: 2,
                      child: pw.Text('Price without postage'),
                    ),
                    pw.Text(shop.getPrice(order.productsPrice)),
                    pw.Header(level: 2, child: pw.Text('Postage')),
                    pw.Text(shop.getPrice(order.order.postageCost)),
                    pw.Header(level: 2, child: pw.Text('Total')),
                    pw.Text(shop.getPrice(order.totalPrice)),
                  ],
                );
              },
            ),
          );
    return document;
  }
}
