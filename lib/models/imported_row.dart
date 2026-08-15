/// One parsed row from an imported CSV file. When [type] is null, the row
/// only marks that a period exists (used for a period with no expenses,
/// most commonly an empty current period) and carries no expense data.
class ImportedExpenseRow {
  final DateTime periodStartedAt;
  final DateTime? periodClosedAt;
  final String? type;
  final double? amount;
  final DateTime? expenseCreatedAt;

  const ImportedExpenseRow({
    required this.periodStartedAt,
    required this.periodClosedAt,
    this.type,
    this.amount,
    this.expenseCreatedAt,
  });

  /// Groups rows belonging to the same period.
  String get periodKey =>
      '${periodStartedAt.toIso8601String()}|${periodClosedAt?.toIso8601String() ?? ''}';
}
