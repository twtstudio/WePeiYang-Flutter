import 'package:flutter/cupertino.dart' show required;
import 'package:wei_pei_yang_demo/commons/preferences/shared_pref.dart';

class Cache<V> with SharedPref{
  String _key;

  Cache(this._key);

  Future<V> get() async => await read(_key);

  Future<void> set(V value) async => await save(_key, value);
}



Future<void> refresh<V>(Cache<V> local, Future<V> Function() remote,
    {void Function(V) callback,void Function() onFailure}) async {
  var localValue = await local.get();
  var remoteValue = await remote();
  //TODO 逻辑再说吧555
}
