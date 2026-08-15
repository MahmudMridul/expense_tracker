import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/utils/command_parser.dart';

void main() {
  group('parseCommand', () {
    test('parses a valid command', () {
      final result = parseCommand('fare 60');
      expect(result.type, 'fare');
      expect(result.amount, 60);
    });

    test('trims surrounding whitespace and collapses internal spacing', () {
      final result = parseCommand('  lunch   150.50  ');
      expect(result.type, 'lunch');
      expect(result.amount, 150.50);
    });

    test('throws when the amount is missing', () {
      expect(() => parseCommand('fare'), throwsFormatException);
    });

    test('throws when the amount is not numeric', () {
      expect(() => parseCommand('fare abc'), throwsFormatException);
    });

    test('throws when there are extra tokens', () {
      expect(() => parseCommand('fare 60 today'), throwsFormatException);
    });

    test('throws when the amount is zero', () {
      expect(() => parseCommand('fare 0'), throwsFormatException);
    });

    test('allows a negative amount for adjustments', () {
      final result = parseCommand('fare -10');
      expect(result.type, 'fare');
      expect(result.amount, -10);
    });
  });
}
