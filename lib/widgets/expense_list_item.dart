import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

String formatBdt(double amount) {
  final formatted = NumberFormat('#,##0.##', 'en_US').format(amount);
  return '৳$formatted';
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(expense.type),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(expense.createdAt)),
      trailing: Text(
        formatBdt(expense.amount),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
