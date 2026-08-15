import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/period_summary_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    int previousCount,
  ) async {
    final provider = context.read<ExpenseProvider>();
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Clear History'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many of the oldest previous periods should be '
                    'deleted? ($previousCount available)',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g. 3',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final n = int.tryParse(controller.text.trim());
                    if (n == null || n <= 0) {
                      setState(() => errorText = 'Enter a positive number');
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    provider.clearOldestPrevious(n);
                  },
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('History')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final current = provider.currentPeriod;
        final previous = provider.previousPeriods;

        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear History',
                onPressed: previous.isEmpty
                    ? null
                    : () => _showClearHistoryDialog(context, previous.length),
              ),
            ],
          ),
          body: ListView(
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
          ),
        );
      },
    );
  }
}
