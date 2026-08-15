import 'package:csv/csv.dart';

import '../models/expense_period.dart';
import '../models/imported_row.dart';

const csvHeader = [
  'period_started_at',
  'period_closed_at',
  'type',
  'amount',
  'expense_created_at',
];

/// Exports [periods] (current + previous) to a CSV string. A period with
/// no expenses still gets one row (with blank type/amount/expense date)
/// so it round-trips through [parseCsvToRows] correctly.
String exportPeriodsToCsv(List<ExpensePeriod> periods) {
  final rows = <List<Object?>>[csvHeader];
  for (final period in periods) {
    final startedAt = period.startedAt.toIso8601String();
    final closedAt = period.closedAt?.toIso8601String() ?? '';

    if (period.expenses.isEmpty) {
      rows.add([startedAt, closedAt, '', '', '']);
      continue;
    }

    for (final expense in period.expenses) {
      rows.add([
        startedAt,
        closedAt,
        expense.type,
        expense.amount,
        expense.createdAt.toIso8601String(),
      ]);
    }
  }
  return csv.encode(rows);
}

/// Parses CSV content produced by [exportPeriodsToCsv]. Throws a
/// [FormatException] (with a user-facing message) when the content isn't
/// in the expected format.
List<ImportedExpenseRow> parseCsvToRows(String content) {
  final table = csv.decode(content);
  if (table.isEmpty) {
    throw const FormatException('CSV file is empty');
  }

  final header = table.first.map((cell) => cell.toString()).toList();
  if (!_headerMatches(header)) {
    throw const FormatException(
      'CSV header does not match the expected export format',
    );
  }

  final rows = <ImportedExpenseRow>[];
  for (var i = 1; i < table.length; i++) {
    final cells = table[i].map((cell) => cell.toString()).toList();
    if (cells.length != csvHeader.length) {
      throw FormatException('Row ${i + 1} has the wrong number of columns');
    }

    final startedAt = DateTime.tryParse(cells[0]);
    if (startedAt == null) {
      throw FormatException('Row ${i + 1} has an invalid period start date');
    }

    final closedAtRaw = cells[1];
    final closedAt = closedAtRaw.isEmpty
        ? null
        : DateTime.tryParse(closedAtRaw);
    if (closedAtRaw.isNotEmpty && closedAt == null) {
      throw FormatException('Row ${i + 1} has an invalid period close date');
    }

    if (cells[2].isEmpty) {
      rows.add(
        ImportedExpenseRow(
          periodStartedAt: startedAt,
          periodClosedAt: closedAt,
        ),
      );
      continue;
    }

    final amount = double.tryParse(cells[3]);
    if (amount == null) {
      throw FormatException('Row ${i + 1} has an invalid amount');
    }

    final expenseCreatedAt = DateTime.tryParse(cells[4]);
    if (expenseCreatedAt == null) {
      throw FormatException('Row ${i + 1} has an invalid expense date');
    }

    rows.add(
      ImportedExpenseRow(
        periodStartedAt: startedAt,
        periodClosedAt: closedAt,
        type: cells[2],
        amount: amount,
        expenseCreatedAt: expenseCreatedAt,
      ),
    );
  }

  return rows;
}

bool _headerMatches(List<String> header) {
  if (header.length != csvHeader.length) return false;
  for (var i = 0; i < header.length; i++) {
    if (header[i] != csvHeader[i]) return false;
  }
  return true;
}
