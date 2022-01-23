// @dart = 2.12
part of 'extensions.dart';

extension ListValueNotifierExt<T> on ValueNotifier<List<T>> {
  unequalAdd(T item) {
    var itemIndex = value.indexOf(item);
    if (-1 != itemIndex) {
      var list = [...value];
      int start;
      for (start = itemIndex; start < value.length - 1; start++) {
        list[start] = list[start + 1];
      }
      list[start] = item;
      value = list;
    } else {
      value = [...value, item];
    }
  }
}
