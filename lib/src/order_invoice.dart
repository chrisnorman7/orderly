import 'package:intl/intl.dart';
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
        )..addPage(
          pw.Page(
            build: (context) {
              final items = order.items;
              final invoiceDate = DateFormat('dd MMMM yyyy')
                  .format(order.order.orderPlaced);
              final boldTextStyle = pw.TextStyle.defaultStyle().copyWith(
                fontWeight: pw.FontWeight.bold,
              );
              final paymentUrl = shop
                  .getPaymentUrl(
                    price: order.totalPrice.asPrice,
                    reference: '#${order.order.orderPlaced.asOrderNumber()}',
                  )
                  .toString();
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(child: pw.Text('Invoice', style: boldTextStyle)),
                  pw.Text('Thank you for shopping with ${shop.name}.'),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Order #${order.order.orderPlaced.asOrderNumber()}',
                        style: boldTextStyle,
                      ),
                      pw.Text('Date: $invoiceDate'),
                    ],
                  ),
                  pw.Header(
                    level: 2,
                    child: pw.Text('Deliver To', style: boldTextStyle),
                  ),
                  ...<String>[
                    '${order.customer.name} (${address.name})',
                    address.street,
                    address.city,
                    address.state,
                    address.country,
                    address.postcode,
                  ].map(pw.Text.new),
                  pw.Header(
                    level: 2,
                    child: pw.Text('Payment Link', style: boldTextStyle),
                  ),
                  pw.Link(
                    child: pw.Text(
                      paymentUrl,
                      style: pw.TextStyle.defaultStyle().copyWith(
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    destination: paymentUrl,
                  ),
                  pw.SizedBox(height: 50.0),
                  pw.TableHelper.fromTextArray(
                    headers: [
                      'Product',
                      'Quantity',
                      'Unit Price',
                      'Total Price',
                      'Notes',
                    ].map((s) => pw.Text(s, style: boldTextStyle)).toList(),
                    headerCount: 5,
                    data: [
                      ...items.map((item) {
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
                      }),
                      [
                        'Price without postage',
                        '',
                        '',
                        shop.getPrice(order.productsPrice),
                        '',
                      ],
                      [
                        'Postage',
                        '',
                        '',
                        shop.getPrice(order.order.postageCost),
                        '',
                      ],
                      [
                        'Total Price',
                        '',
                        '',
                        shop.getPrice(order.totalPrice),
                        '',
                      ],
                      [
                        'Order Total',
                        '',
                        '',
                        shop.getPrice(order.totalPrice),
                        '',
                      ],
                    ],
                  ),
                ],
              );
            },
            pageFormat: PdfPageFormat.a4,
          ),
        );
    return document;
  }
}
