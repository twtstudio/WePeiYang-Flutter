// @dart = 2.12
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

part 'classroom.g.dart';

@HiveType(typeId: 3)
class Classroom {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int capacity;

  @HiveField(3)
  Map<int, String> statuses;

  String status;

  @HiveField(4)
  String bId;

  @HiveField(5)
  String aId;

  @HiveField(6)
  String bName;

  Classroom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.statuses,
    required this.status,
    required this.bId,
    required this.aId,
    required this.bName,
  });

  factory Classroom.fromMap(
    Map<String, dynamic> map, {
    String? aId,
    String? bId,
    String? bName,
  }) {
    return Classroom(
      id: map['classroom_id'] ?? '',
      name: map['classroom'] ?? '',
      capacity: map['capacity'] ?? 0,
      status: map['status'] ?? '',
      aId: aId ?? '',
      bId: bId ?? '',
      bName: bName ?? '',
      statuses: {
        1: '111111111111',
        2: '111111111111',
        3: '111111111111',
        4: '111111111111',
        5: '111111111111',
        6: '111111111111',
        7: '111111111111',
      },
    );
  }

  factory Classroom.empty() {
    return Classroom(
        id: 'unknown',
        name: 'unknown',
        capacity: 0,
        statuses: {},
        status: '',
        bId: '',
        aId: '',
        bName: '');
  }

  @override
  String toString() {
    return 'Classroom(id: $id, name: $name, capacity: $capacity, statuses: $statuses, status: $status, bId: $bId, aId: $aId, bName: $bName)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'statuses': statuses,
      'status': status,
      'bId': bId,
      'aId': aId,
      'bName': bName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Classroom &&
        other.id == id &&
        other.name == name &&
        other.capacity == capacity &&
        mapEquals(other.statuses, statuses) &&
        other.status == status &&
        other.bId == bId &&
        other.aId == aId &&
        other.bName == bName;
  }

  bool baseDataEqual(Classroom other) =>
      other.aId == aId && other.bId == bId && other.id == other.id;

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        capacity.hashCode ^
        statuses.hashCode ^
        status.hashCode ^
        bId.hashCode ^
        aId.hashCode ^
        bName.hashCode;
  }

  factory Classroom.deepCopy(Classroom other) {
    return Classroom(
      id: other.id,
      name: other.name,
      capacity: other.capacity,
      statuses: Map.from(other.statuses),
      status: other.status,
      bId: other.bId,
      aId: other.aId,
      bName: other.bName,
    );
  }
}
