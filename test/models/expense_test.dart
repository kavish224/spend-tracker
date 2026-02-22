import 'package:flutter_test/flutter_test.dart';
import 'package:spend_tracker/models/expense.dart';

void main() {
  group('Expense.fromMap', () {
    test('parses numeric and string values safely', () {
      final expense = Expense.fromMap({
        'id': 7,
        'amount': '129.5',
        'category': null,
        'paymentMethod': null,
        'date': '2026-02-22T10:30:00.000',
        'note': 123,
      });

      expect(expense.id, 7);
      expect(expense.amount, 129.5);
      expect(expense.category, 'Other');
      expect(expense.paymentMethod, 'Unknown');
      expect(expense.date, DateTime.parse('2026-02-22T10:30:00.000'));
      expect(expense.note, '123');
    });

    test('falls back for invalid amount/date input', () {
      final expense = Expense.fromMap({
        'amount': 'invalid',
        'category': 'Food',
        'paymentMethod': 'UPI',
        'date': 'invalid-date',
      });

      expect(expense.amount, 0.0);
      expect(expense.date, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
