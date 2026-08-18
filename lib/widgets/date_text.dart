import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The format to use for dates.
final dateFormatter = DateFormat('EEEE dd MMMM y');

/// A widget which shows [date] in a human-readable format.
class DateText extends StatelessWidget {
  /// Create an instance.
  const DateText({required this.date, super.key});

  /// The dateTime to use.
  final DateTime date;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final dateFormat = dateFormatter.format(date);
    return Text(dateFormat);
  }
}
