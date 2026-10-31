// lib/SERVICES/expiry_date_parser.dart
//
// Finds an expiry date in OCR text from a product label, e.g.
//   "MFG 12/05/2026 EXP 11/05/2027"   -> 2027-05-11
//   "BEST BEFORE 15 NOV 2026"          -> 2026-11-15
//   "EXP: 03/2027"                     -> 2027-03-31 (last day of the month)
// Dates are read day-first (Kenyan convention). Pure Dart, so it is unit-tested.

class ExpiryDateParser {
  ExpiryDateParser._();

  static const Map<String, int> _months = {
    'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
    'JUL': 7, 'AUG': 8, 'SEP': 9, 'SEPT': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
    'JANUARY': 1, 'FEBRUARY': 2, 'MARCH': 3, 'APRIL': 4, 'JUNE': 6, 'JULY': 7,
    'AUGUST': 8, 'SEPTEMBER': 9, 'OCTOBER': 10, 'NOVEMBER': 11, 'DECEMBER': 12,
  };

  static final RegExp _expWord = RegExp(
      r'(EXP|EXPIRY|EXPIRES|EXPIRE|USE\s*BY|BEST\s*BEFORE|BBE|BB)\b');
  static final RegExp _mfgWord =
      RegExp(r'(MFG|MFD|MANUF\w*|PROD\w*|PACKED|DOM)\b');

  static DateTime? _make(int y, int m, int d) {
    if (y < 100) y += 2000;
    if (m < 1 || m > 12 || d < 1) return null;
    final dt = DateTime.utc(y, m, d);
    if (dt.year != y || dt.month != m || dt.day != d) return null;
    return dt;
  }

  static DateTime _endOfMonth(int y, int m) {
    if (y < 100) y += 2000;
    return DateTime.utc(y, m + 1, 0);
  }

  static DateTime? parse(String raw, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final text = raw.toUpperCase().replaceAll(RegExp(r'[\r\n]+'), ' ');
    var work = text;
    final cands = <_Cand>[];

    void scan(RegExp re, DateTime? Function(RegExpMatch m) build) {
      final spans = <List<int>>[];
      for (final m in re.allMatches(work)) {
        final d = build(m);
        if (d != null) {
          cands.add(_Cand(d, m.start));
          spans.add([m.start, m.end]);
        }
      }
      if (spans.isEmpty) return;
      // blank out only the dates that were accepted, so later patterns cannot
      // match them again (the text length stays the same)
      final chars = work.split('');
      for (final s in spans) {
        for (var i = s[0]; i < s[1]; i++) {
          chars[i] = ' ';
        }
      }
      work = chars.join();
    }

    // 2026-12-01
    scan(RegExp(r'(\d{4})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{1,2})'),
        (m) => _make(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)));
    // 15/11/2026, 15-11-26, 15.11.2026
    scan(RegExp(r'(\d{1,2})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{4}|\d{2})\b'),
        (m) => _make(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!)));
    // 15 NOV 2026, 15NOV26
    scan(RegExp(r'(\d{1,2})\s*([A-Z]{3,9})\s*[,.\-/]?\s*(\d{4}|\d{2})\b'), (m) {
      final mo = _months[m[2]!];
      return mo == null ? null : _make(int.parse(m[3]!), mo, int.parse(m[1]!));
    });
    // NOV 2026, NOV/26 (month and year only -> last day of that month)
    scan(RegExp(r'\b([A-Z]{3,9})\s*[,.\-/ ]\s*(\d{4}|\d{2})\b'), (m) {
      final mo = _months[m[1]!];
      return mo == null ? null : _endOfMonth(int.parse(m[2]!), mo);
    });
    // 03/2027
    scan(RegExp(r'\b(\d{1,2})\s*[/\-.]\s*(\d{4})\b'), (m) {
      final mo = int.parse(m[1]!);
      return (mo < 1 || mo > 12) ? null : _endOfMonth(int.parse(m[2]!), mo);
    });

    // keep plausible dates only
    final ok = cands
        .where((c) =>
            c.date.year >= today.year - 1 && c.date.year <= today.year + 12)
        .toList();
    if (ok.isEmpty) return null;

    // Prefer dates that follow EXP / USE BY / BEST BEFORE; ignore MFG dates.
    int score(_Cand c) {
      final from = c.start - 28 < 0 ? 0 : c.start - 28;
      final before = text.substring(from, c.start);
      // the keyword closest to the date decides
      var bestEnd = -1;
      var s = 0;
      for (final m in _expWord.allMatches(before)) {
        if (m.end > bestEnd) {
          bestEnd = m.end;
          s = 10;
        }
      }
      for (final m in _mfgWord.allMatches(before)) {
        if (m.end > bestEnd) {
          bestEnd = m.end;
          s = -10;
        }
      }
      return s;
    }

    ok.sort((a, b) {
      final byScore = score(b).compareTo(score(a));
      return byScore != 0 ? byScore : b.date.compareTo(a.date);
    });
    return ok.first.date;
  }
}

class _Cand {
  final DateTime date;
  final int start;
  const _Cand(this.date, this.start);
}
