import 'package:crabpay/core/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateConversion', () {
    test('maps every month to its abbreviation', () {
      const expectedMonths = <String, String>{
        '01': 'Jan',
        '02': 'Feb',
        '03': 'Mar',
        '04': 'Apr',
        '05': 'May',
        '06': 'Jun',
        '07': 'Jul',
        '08': 'Aug',
        '09': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
      };
      for (final entry in expectedMonths.entries) {
        expect(dateConversion('2026-${entry.key}-15T10:30:00.000Z'), '${entry.value} 15, 2026 | 10:30');
      }
    });

    test('formats a valid ISO string as Mon DD, YYYY | HH:MM', () {
      expect(dateConversion('2026-01-15T10:30:00.000Z'), 'Jan 15, 2026 | 10:30');
    });

    test('prefixes an unknown month with error', () {
      expect(dateConversion('2026-13-15T10:30'), 'error15, 2026 | 10:30');
    });

    test('throws RangeError when the input is shorter than 16 characters', () {
      expect(() => dateConversion('2026-01-15'), throwsRangeError);
      expect(() => dateConversion('2026-01-15T10:3'), throwsRangeError);
    });
  });
}
