import 'package:intl/intl.dart';

import '../models/expense_period.dart';

String formatBdt(double amount) {
  final formatted = NumberFormat('#,##0.##', 'en_US').format(amount);
  return '৳$formatted';
}

/// Formats a period's date range as "MMM d - MMM d" (start - end), using
/// the start date as the end when the period is still open.
String formatPeriodDateRange(ExpensePeriod period) {
  final format = DateFormat('MMM d');
  final start = format.format(period.startedAt);
  final end = format.format(period.closedAt ?? period.startedAt);
  return '$start - $end';
}
