import '../models/expense.dart';
import '../models/expense_period.dart';
import 'database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Expense>> _expensesForPeriod(int periodId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'expenses',
      where: 'period_id = ?',
      whereArgs: [periodId],
      orderBy: 'created_at DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<ExpensePeriod> getCurrentPeriod() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'periods',
      where: 'closed_at IS NULL',
      limit: 1,
    );
    final period = ExpensePeriod.fromMap(rows.first);
    final expenses = await _expensesForPeriod(period.id);
    return period.copyWith(expenses: expenses);
  }

  Future<List<ExpensePeriod>> getPreviousPeriods() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'periods',
      where: 'closed_at IS NOT NULL',
      orderBy: 'closed_at DESC',
    );
    final periods = <ExpensePeriod>[];
    for (final row in rows) {
      final period = ExpensePeriod.fromMap(row);
      final expenses = await _expensesForPeriod(period.id);
      periods.add(period.copyWith(expenses: expenses));
    }
    return periods;
  }

  Future<void> addExpense(String type, double amount) async {
    final db = await _dbHelper.database;
    final current = await getCurrentPeriod();

    final existing = await db.query(
      'expenses',
      where: 'period_id = ? AND type = ?',
      whereArgs: [current.id, type],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('expenses', {
        'period_id': current.id,
        'type': type,
        'amount': amount,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      return;
    }

    final row = existing.first;
    final updatedAmount = (row['amount'] as num).toDouble() + amount;
    await db.update(
      'expenses',
      {
        'amount': updatedAmount,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<void> closeCurrentPeriod() async {
    final db = await _dbHelper.database;
    final current = await getCurrentPeriod();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'periods',
      {'closed_at': now},
      where: 'id = ?',
      whereArgs: [current.id],
    );
    await db.insert('periods', {'started_at': now, 'closed_at': null});
  }
}
