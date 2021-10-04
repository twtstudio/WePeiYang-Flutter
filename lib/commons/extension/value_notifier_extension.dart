part of 'extensions.dart';

extension ListValueNotifierExt<T> on ValueNotifier<List<T>> {
  add(T item){
    value.add(item);
    value = value;
  }

  clear(){
    value.clear();
    value = value;
  }
}