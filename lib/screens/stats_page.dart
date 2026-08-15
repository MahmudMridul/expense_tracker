import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_period.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Stats')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final periods = [
          if (provider.currentPeriod != null) provider.currentPeriod!,
          ...provider.previousPeriods,
        ];

        final typeStats = <String, _TypeStat>{};
        for (final period in periods) {
          final typesInPeriod = <String>{};
          for (final expense in period.expenses) {
            final stat = typeStats.putIfAbsent(expense.type, _TypeStat.new);
            stat.total += expense.amount;
            typesInPeriod.add(expense.type);
          }
          for (final type in typesInPeriod) {
            typeStats[type]!.count += 1;
          }
        }
        final sortedTypeStats = typeStats.entries.toList()
          ..sort((a, b) => b.value.total.compareTo(a.value.total));

        final periodTotalSum = periods.fold<double>(
          0,
          (sum, period) => sum + period.total,
        );
        final averagePerPeriod = periods.isEmpty
            ? 0.0
            : periodTotalSum / periods.length;

        return Scaffold(
          appBar: AppBar(title: const Text('Stats')),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Totals by period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Avg ${formatBdt(averagePerPeriod)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              if (periods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No periods yet'),
                )
              else
                for (final period in periods)
                  _PeriodTotalTile(period: period),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Totals by expense type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (sortedTypeStats.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No expenses yet'),
                )
              else
                for (final entry in sortedTypeStats)
                  ListTile(
                    dense: true,
                    title: Text(entry.key),
                    subtitle: Text(
                      'Avg ${formatBdt(entry.value.average.toDouble())}',
                    ),
                    trailing: Text(
                      formatBdt(entry.value.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _TypeStat {
  double total = 0;

  /// Number of periods that contain this type (not the number of raw
  /// expense rows), so the average below is per period.
  int count = 0;

  /// Average amount for this type per period, rounded up to the nearest
  /// integer.
  int get average => count == 0 ? 0 : (total / count).ceil();
}

class _PeriodTotalTile extends StatelessWidget {
  final ExpensePeriod period;

  const _PeriodTotalTile({required this.period});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        period.isCurrent ? 'Current' : formatPeriodDateRange(period),
      ),
      trailing: Text(
        formatBdt(period.total),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
