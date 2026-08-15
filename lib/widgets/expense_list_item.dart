import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

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
