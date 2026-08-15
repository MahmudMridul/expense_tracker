class Expense {
  final int? id;
  final int periodId;
  final String type;
  final double amount;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.periodId,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'period_id': periodId,
      'type': type,
      'amount': amount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int,
      periodId: map['period_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
