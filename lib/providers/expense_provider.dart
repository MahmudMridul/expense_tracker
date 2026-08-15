import 'package:flutter/foundation.dart';

import '../models/expense_period.dart';
import '../services/csv_service.dart';
import '../services/expense_repository.dart';
import '../utils/command_parser.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseProvider({ExpenseRepository? repository})
    : _repository = repository ?? ExpenseRepository();

  ExpensePeriod? _currentPeriod;
  List<ExpensePeriod> _previousPeriods = [];
  bool _loading = true;

  ExpensePeriod? get currentPeriod => _currentPeriod;

  List<ExpensePeriod> get previousPeriods => _previousPeriods;

  bool get loading => _loading;

  /// Current period (if loaded) followed by every previous period,
  /// newest to oldest.
  List<ExpensePeriod> get allPeriods => [
    ?_currentPeriod,
    ..._previousPeriods,
  ];

  Future<void> load() async {
    _currentPeriod = await _repository.getCurrentPeriod();
    _previousPeriods = await _repository.getPreviousPeriods();
    _loading = false;
    notifyListeners();
  }

  /// Parses and submits [input] as a command. Throws a [FormatException]
  /// (with a user-facing message) when the command is malformed, leaving
  /// state untouched.
  Future<void> submitCommand(String input) async {
    final parsed = parseCommand(input);
    await _repository.addExpense(parsed.type, parsed.amount);
    await load();
  }

  Future<void> closeCurrent() async {
    await _repository.closeCurrentPeriod();
    await load();
  }

  Future<void> clearOldestPrevious(int count) async {
    await _repository.clearOldestPreviousPeriods(count);
    await load();
  }

  /// Parses [csvContent] and replaces all existing data with it. Throws a
  /// [FormatException] (with a user-facing message) when the CSV is
  /// malformed, leaving existing data untouched.
  Future<void> importCsv(String csvContent) async {
    final rows = parseCsvToRows(csvContent);
    await _repository.replaceAllData(rows);
    await load();
  }
}
