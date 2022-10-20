// @dart = 2.12
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  const Tuple2(this.item1, this.item2);

  factory Tuple2.fromList(List items) {
    if (items.length != 2) throw ArgumentError('items must have length 2');
    return Tuple2<T1, T2>(items[0] as T1, items[1] as T2);
  }

  List toList({bool growable = false}) =>
      List.from([item1, item2], growable: growable);

  @override
  String toString() => '[$item1, $item2]';

  @override
  bool operator ==(Object other) =>
      other is Tuple2 && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => Object.hash(item1.hashCode, item2.hashCode);
}

class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;

  const Tuple3(this.item1, this.item2, this.item3);

  factory Tuple3.fromList(List items) {
    if (items.length != 3) throw ArgumentError('items must have length 3');
    return Tuple3<T1, T2, T3>(items[0] as T1, items[1] as T2, items[2] as T3);
  }

  List toList({bool growable = false}) =>
      List.from([item1, item2, item3], growable: growable);

  @override
  String toString() => '[$item1, $item2, $item3]';

  @override
  bool operator ==(Object other) =>
      other is Tuple3 &&
      other.item1 == item1 &&
      other.item2 == item2 &&
      other.item3 == item3;

  @override
  int get hashCode =>
      Object.hash(item1.hashCode, item2.hashCode, item3.hashCode);
}

class Tuple4<T1, T2, T3, T4> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;

  const Tuple4(this.item1, this.item2, this.item3, this.item4);

  factory Tuple4.fromList(List items) {
    if (items.length != 4) throw ArgumentError('items must have length 4');
    return Tuple4<T1, T2, T3, T4>(
        items[0] as T1, items[1] as T2, items[2] as T3, items[3] as T4);
  }

  List toList({bool growable = false}) =>
      List.from([item1, item2, item3, item4], growable: growable);

  @override
  String toString() => '[$item1, $item2, $item3, $item4]';

  @override
  bool operator ==(Object other) =>
      other is Tuple4 &&
      other.item1 == item1 &&
      other.item2 == item2 &&
      other.item3 == item3 &&
      other.item4 == item4;

  @override
  int get hashCode => Object.hash(
      item1.hashCode, item2.hashCode, item3.hashCode, item4.hashCode);
}
