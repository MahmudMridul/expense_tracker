import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/period_summary_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final current = provider.currentPeriod;
          final previous = provider.previousPeriods;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Current',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (current == null || current.expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No expenses yet'),
                )
              else
                for (final expense in current.expenses)
                  ExpenseListItem(expense: expense),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Previous',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (previous.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No previous expenses yet'),
                )
              else
                for (final period in previous)
                  PeriodSummaryCard(period: period),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
