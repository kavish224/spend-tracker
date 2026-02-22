import 'package:flutter_test/flutter_test.dart';
import 'package:spend_tracker/utils/amount_parser.dart';

void main() {
  group('parseAmount', () {
    test('returns null for null or empty', () {
      expect(parseAmount(null), isNull);
      expect(parseAmount(''), isNull);
      expect(parseAmount('   '), isNull);
    });

    test('parses simple integers and decimals', () {
      expect(parseAmount('499'), 499.0);
      expect(parseAmount('0'), 0.0);
      expect(parseAmount('1.5'), 1.5);
      expect(parseAmount('99.99'), 99.99);
    });

    test('strips spaces', () {
      expect(parseAmount('  1200  '), 1200.0);
      expect(parseAmount('1 200'), 1200.0);
    });

    test('handles thousands comma (Indian/US)', () {
      expect(parseAmount('1,200'), 1200.0);
      expect(parseAmount('1,200.50'), 1200.5);
      expect(parseAmount('12,34,567'), 1234567.0);
    });

    test('handles European decimal comma', () {
      expect(parseAmount('1,50'), 1.5);
      expect(parseAmount('1200,50'), 1200.5);
    });

    test('returns null for invalid input', () {
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('1.2.3'), isNull);
      expect(parseAmount('--1'), isNull);
    });

    test('rejects negative amounts', () {
      expect(parseAmount('-100'), isNull);
      expect(parseAmount('-1.5'), isNull);
    });
  });
}
