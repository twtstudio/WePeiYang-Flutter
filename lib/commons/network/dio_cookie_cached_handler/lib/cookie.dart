import 'package:flutter/foundation.dart';

/// Cookie model for internal use. Nothing to do with dependant projects
@immutable
class Cookie {
  final String name;
  final String value;
  final DateTime expires;

  const Cookie({
    required this.name,
    required this.value,
    required this.expires,
  });

  /// In our case name is only property we distinguish different cookies
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) => other is Cookie && other.name == name;
}