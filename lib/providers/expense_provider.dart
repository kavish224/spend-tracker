import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helpers.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  Database? _db;
  bool _isLoading = false;
  bool _isAdding = false;
  bool _isReady = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    if (_isReady || _isLoading) return;
    _setLoading(true);
    try {
      await _openDbIfNeeded();
      await _loadExpenses();
      _isReady = true;
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Failed to initialize local database.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchExpenses() async {
    _setLoading(true);
    try {
      await _openDbIfNeeded();
      await _loadExpenses();
      _errorMessage = null;
      _isReady = true;
    } catch (_) {
      _errorMessage = 'Failed to load expenses.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (expense.amount <= 0) {
      throw ArgumentError('Expense amount must be greater than zero.');
    }

    _isAdding = true;
    notifyListeners();
    try {
      await _openDbIfNeeded();
      await _db!.insert('expenses', expense.toMap());
      await _loadExpenses();
      _errorMessage = null;
      _isReady = true;
    } catch (_) {
      _errorMessage = 'Failed to add expense.';
      rethrow;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
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

  Future<void> _openDbIfNeeded() async {
    _db ??= await DBHelper.initDB();
  }

  Future<void> _loadExpenses() async {
    final data = await _db!.query('expenses', orderBy: 'date DESC');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(DBHelper.closeDB());
    super.dispose();
  }
}
