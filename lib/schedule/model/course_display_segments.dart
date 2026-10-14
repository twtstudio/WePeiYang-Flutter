/// Split a displayed course at the lunch and dinner breaks without changing
/// its underlying arrangement or the course details shown on tap.
List<({int start, int end})> courseDisplaySegments(int start, int end) {
  final segments = <({int start, int end})>[];
  var segmentStart = start;
  for (final boundary in const [4, 8]) {
    if (segmentStart <= boundary && end > boundary) {
      segments.add((start: segmentStart, end: boundary));
      segmentStart = boundary + 1;
    }
  }
  segments.add((start: segmentStart, end: end));
  return segments;
}
