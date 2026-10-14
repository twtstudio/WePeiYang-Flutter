import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_display_segments.dart';

void main() {
  test('courses within a teaching block keep one card', () {
    for (final range in [(1, 4), (5, 8), (9, 12), (4, 4), (8, 8)]) {
      expect(courseDisplaySegments(range.$1, range.$2),
          [(start: range.$1, end: range.$2)]);
    }
  });

  test('courses spanning breaks get separate cards', () {
    expect(courseDisplaySegments(3, 6),
        [(start: 3, end: 4), (start: 5, end: 6)]);
    expect(courseDisplaySegments(7, 10),
        [(start: 7, end: 8), (start: 9, end: 10)]);
    expect(courseDisplaySegments(4, 9),
        [(start: 4, end: 4), (start: 5, end: 8), (start: 9, end: 9)]);
  });

  test('every valid range preserves its periods without crossing a break', () {
    for (var start = 1; start <= 12; start++) {
      for (var end = start; end <= 12; end++) {
        final segments = courseDisplaySegments(start, end);
        final periods = <int>[];
        for (final segment in segments) {
          expect(segment.start <= 4 && segment.end > 4, isFalse);
          expect(segment.start <= 8 && segment.end > 8, isFalse);
          periods.addAll(List.generate(segment.end - segment.start + 1,
              (index) => segment.start + index));
        }
        expect(periods, List.generate(end - start + 1, (index) => start + index));
      }
    }
  });
}
