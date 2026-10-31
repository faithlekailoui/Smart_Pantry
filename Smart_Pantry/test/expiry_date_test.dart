import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/SERVICES/expiry_date_parser.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28);
  DateTime? p(String s) => ExpiryDateParser.parse(s, now: now);

  test('chooses the EXP date, not the manufacture date', () {
    expect(p('MFG 12/05/2026 EXP 11/05/2027'), DateTime.utc(2027, 5, 11));
    expect(p('EXP 11/05/2027 MFG 12/05/2026'), DateTime.utc(2027, 5, 11));
  });

  test('reads day-month-name-year formats', () {
    expect(p('BEST BEFORE 15 NOV 2026'), DateTime.utc(2026, 11, 15));
    expect(p('USE BY 15NOV26'), DateTime.utc(2026, 11, 15));
  });

  test('month and year only gives the last day of the month', () {
    expect(p('EXP: 03/2027'), DateTime.utc(2027, 3, 31));
    expect(p('EXP FEB 2028'), DateTime.utc(2028, 2, 29));
  });

  test('reads ISO and two-digit-year dates', () {
    expect(p('BB 2026-12-01'), DateTime.utc(2026, 12, 1));
    expect(p('EXP 11.05.27'), DateTime.utc(2027, 5, 11));
  });

  test('returns null when there is no usable date', () {
    expect(p('NO DATE HERE'), isNull);
    expect(p('MFG 01/01/2020'), isNull); // far in the past
  });
}
