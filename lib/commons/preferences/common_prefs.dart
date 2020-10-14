import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static final _instance = CommonPreferences._();

  /// 用create函数获取commonPref类单例
  factory CommonPreferences.create() => _instance;

  static SharedPreferences getPref() => _instance._sharedPref;

  SharedPreferences _sharedPref;

  /// 初始化sharedPrefs，在自动登录时就被调用
  static Future<void> initPrefs() async =>
      _instance._sharedPref = await SharedPreferences.getInstance();

  ///twt相关

  var isLogin = PrefsBean<bool>('login');

  var token = PrefsBean<String>('token');

  var username = PrefsBean<String>('username');

  var password = PrefsBean<String>('password');

  ///办公网相关(看着这些绿色波浪线就想犯强迫症，可惜接口就是这么写的)
  var tjuuname = PrefsBean<String>('tjuuname');

  var tjupasswd = PrefsBean<String>('tjupasswd');

  /// cookies in sso.tju.edu.cn
  var tgc = PrefsBean<String>("tgc"); // TGC

  /// cookies in classes.tju.edu.cn
  var gSessionId = PrefsBean<String>("gsessionid"); // GSESSIONID

  var garbled = PrefsBean<String>("garbled"); // UqZBpD3n3iXPAw1X

  var semesterId = PrefsBean<String>("semester"); // semester.id

  var ids = PrefsBean<String>("ids"); // ids

  /// 清除程序和本地的缓存
  void clearPrefs() {
    isLogin.value = false;
    token.value = "";
    username.value = "";
    password.value = "";
    tjuuname.value = "";
    tjupasswd.value = "";
    tgc.value = "";
    gSessionId.value = "";
    garbled.value = "";
    semesterId.value = "";
    ids.value = "";
    _sharedPref.clear();
  }
}

class PrefsBean<T> {
  PrefsBean(this._key) {
    _default = _getDefault(T);
    _value = _default;
  }

  String _key;
  T _value;
  T _default;

  T get value {
    if (_value == _default) _value = _getValue(T, _key);
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _setValue(newValue, _key);
    _value = newValue;
  }
}

dynamic _getValue<T>(T, String key) {
  var pref = CommonPreferences.getPref();
  return pref?.get(key) ?? _getDefault(T);
}

void _setValue<T>(T value, String key) {
  var pref = CommonPreferences.getPref();
  if (pref == null) return;
  switch (T) {
    case String:
      pref.setString(key, value as String);
      break;
    case bool:
      pref.setBool(key, value as bool);
      break;
    case int:
      pref.setInt(key, value as int);
      break;
    case double:
      pref.setDouble(key, value as double);
      break;
  }
}

dynamic _getDefault<T>(T) {
  switch (T) {
    case String:
      return "";
    case int:
      return 0;
    case double:
      return 0.0;
    case bool:
      return false;
    default:
      return null;
  }
}