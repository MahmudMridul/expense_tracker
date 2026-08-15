import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_period.dart';
import 'expense_list_item.dart';

class PeriodSummaryCard extends StatelessWidget {
  final ExpensePeriod period;

  const PeriodSummaryCard({super.key, required this.period});

  String get _dateRange {
    final format = DateFormat('MMM d');
    final start = format.format(period.startedAt);
    final end = format.format(period.closedAt ?? period.startedAt);
    return start == end ? start : '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(_dateRange),
        subtitle: Text(
          '${period.expenses.length} expenses · ${formatBdt(period.total)}',
        ),
        children: [
          for (final expense in period.expenses)
            ExpenseListItem(expense: expense),
        ],
      ),
    );
  }
}
