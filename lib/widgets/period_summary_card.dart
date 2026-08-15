import 'package:flutter/material.dart';

import '../models/expense_period.dart';
import '../utils/formatters.dart';
import 'expense_list_item.dart';

class PeriodSummaryCard extends StatelessWidget {
  final ExpensePeriod period;

  const PeriodSummaryCard({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(formatPeriodDateRange(period)),
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
