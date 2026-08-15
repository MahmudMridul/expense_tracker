import 'expense.dart';

class ExpensePeriod {
  final int id;
  final DateTime startedAt;
  final DateTime? closedAt;
  final List<Expense> expenses;

  const ExpensePeriod({
    required this.id,
    required this.startedAt,
    this.closedAt,
    this.expenses = const [],
  });

  bool get isCurrent => closedAt == null;

  double get total => expenses.fold(0, (sum, e) => sum + e.amount);

  ExpensePeriod copyWith({List<Expense>? expenses}) {
    return ExpensePeriod(
      id: id,
      startedAt: startedAt,
      closedAt: closedAt,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'started_at': startedAt.millisecondsSinceEpoch,
      'closed_at': closedAt?.millisecondsSinceEpoch,
    };
  }

  factory ExpensePeriod.fromMap(Map<String, Object?> map) {
    return ExpensePeriod(
      id: map['id'] as int,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['closed_at'] as int),
    );
  }
}
