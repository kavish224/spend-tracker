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
  double _monthlyTotal = 0;
  double _todayTotal = 0;
  Map<String, double> _categoryTotals = const {};
  Map<String, double> _paymentMethodTotals = const {};
  List<Expense> _recentExpenses = const [];
  Timer? _dateChangeTimer;
  DateTime _calendarAnchor = DateTime.now();

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  double get monthlyTotal => _monthlyTotal;
  double get todayTotal => _todayTotal;
  Map<String, double> get categoryTotals => _categoryTotals;
  Map<String, double> get paymentMethodTotals => _paymentMethodTotals;
  List<Expense> get recentExpenses => _recentExpenses;

  Future<void> init() async {
    if (_isReady || _isLoading) return;
    _setLoading(true);
    try {
      await _openDbIfNeeded();
      await _loadExpenses(notify: false);
      _isReady = true;
      _errorMessage = null;
      _startDateChangeTimer();
    } catch (_) {
      _errorMessage = 'Failed to initialize local database.';
    } finally {
      _setLoading(false, notify: false);
      notifyListeners();
    }
  }

  Future<void> fetchExpenses() async {
    _setLoading(true);
    try {
      await _openDbIfNeeded();
      await _loadExpenses(notify: false);
      _errorMessage = null;
      _isReady = true;
      _startDateChangeTimer();
    } catch (_) {
      _errorMessage = 'Failed to load expenses.';
    } finally {
      _setLoading(false, notify: false);
      notifyListeners();
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
      final id = await _db!.insert('expenses', expense.toMap());
      final savedExpense = Expense(
        id: id,
        amount: expense.amount,
        category: expense.category,
        paymentMethod: expense.paymentMethod,
        date: expense.date,
        note: expense.note,
      );
      _expenses = [savedExpense, ..._expenses];
      _recalculateMetrics();
      _errorMessage = null;
      _isReady = true;
      _startDateChangeTimer();
    } catch (_) {
      _errorMessage = 'Failed to add expense.';
      rethrow;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
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

  Future<void> _loadExpenses({bool notify = true}) async {
    final data = await _db!.query('expenses', orderBy: 'date DESC');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    _recalculateMetrics();
    if (notify) notifyListeners();
  }

  void _setLoading(bool value, {bool notify = true}) {
    if (_isLoading == value) return;
    _isLoading = value;
    if (notify) notifyListeners();
  }

  void _recalculateMetrics() {
    final now = DateTime.now();
    _calendarAnchor = now;
    final monthExpenses = _currentMonthExpenses;
    _monthlyTotal = monthExpenses.fold(0.0, (sum, item) => sum + item.amount);
    _todayTotal = _expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, item) => sum + item.amount);

    final categoryTotals = <String, double>{};
    final paymentMethodTotals = <String, double>{};
    for (final expense in monthExpenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      paymentMethodTotals.update(
        expense.paymentMethod,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    _categoryTotals = categoryTotals;
    _paymentMethodTotals = paymentMethodTotals;
    _recentExpenses = _expenses.take(5).toList();
  }

  void _startDateChangeTimer() {
    _dateChangeTimer ??= Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      final isNewDay =
          now.year != _calendarAnchor.year ||
          now.month != _calendarAnchor.month ||
          now.day != _calendarAnchor.day;
      if (isNewDay) {
        _recalculateMetrics();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _dateChangeTimer?.cancel();
    unawaited(DBHelper.closeDB());
    super.dispose();
  }
}
