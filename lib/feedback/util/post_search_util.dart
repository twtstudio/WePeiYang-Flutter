final _postSearchPattern = RegExp(
  r'^(#?(?:mp)?)([0-9]{1,6})$',
  caseSensitive: false,
);

/// Parses a 1–6 digit post ID with optional '#' and case-insensitive 'MP'.
/// Set [requirePrefix] for searches where bare numbers remain keywords.
int? parsePostSearchId(String keyword, {bool requirePrefix = false}) {
  final match = _postSearchPattern.firstMatch(keyword.trim());
  if (match == null || (requirePrefix && match.group(1)!.isEmpty)) return null;
  return int.tryParse(match.group(2)!);
}

/// Adds the canonical '#MP' prefix while preserving any leading zeros.
String? normalizePostSearchKeyword(String keyword) {
  final match = _postSearchPattern.firstMatch(keyword.trim());
  return match == null ? null : '#MP${match.group(2)!}';
}
