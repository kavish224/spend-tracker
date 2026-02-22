import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helpers.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  late Database _db;

  List<Expense> get expenses => _expenses;

  Future<void> init() async {
    _db = await DBHelper.initDB();
    await fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final data = await _db.query('expenses', orderBy: 'date DESC');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _db.insert('expenses', expense.toMap());
    await fetchExpenses();
  }

  double get monthlyTotal {
    return _currentMonthExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final expense in _currentMonthExpenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  Map<String, double> get paymentMethodTotals {
    final totals = <String, double>{};
    for (final expense in _currentMonthExpenses) {
      totals.update(
        expense.paymentMethod,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  List<Expense> get recentExpenses {
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  List<Expense> get _currentMonthExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
  }
}
