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

  var isLogin = PrefsBean<bool>('login').value;

  var token = PrefsBean<String>('token').value;

  var username = PrefsBean<String>('username').value;

  var password = PrefsBean<String>('password').value;

  ///办公网相关(看着这些绿色波浪线就想犯强迫症，可惜接口就是这么写的)
  var tjuuname = PrefsBean<String>('tjuuname').value;

  var tjupasswd = PrefsBean<String>('tjupasswd').value;

  /// cookies in sso.tju.edu.cn
  var tgc = PrefsBean<String>("tgc").value; // TGC

  /// cookies in classes.tju.edu.cn
  var gSessionId = PrefsBean<String>("gsessionid").value; // GSESSIONID

  var garbled = PrefsBean<String>("garbled").value; // UqZBpD3n3iXPAw1X

  var semesterId = PrefsBean<String>("semester").value; // semester.id

  var ids = PrefsBean<String>("ids").value; // ids

  /// 清除程序和本地的缓存
  void clearPrefs() {
    isLogin = false;
    token = "";
    username = "";
    password = "";
    tjuuname = "";
    tjupasswd = "";
    tgc = "";
    gSessionId = "";
    garbled = "";
    semesterId = "";
    ids = "";
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
  bool _init = true;

  T get value {
    if (_init) {
      _init = false;
      return _default;
    }
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

// var _tjuuname = "";
//
// String get tjuuname {
//   if (_tjuuname == "") _tjuuname = _sharedPref.getString('tjuuname') ?? "";
//   return _tjuuname;
// }
//
// set tjuuname(String newTjuName) {
//   if (_tjuuname == newTjuName) return;
//   _sharedPref.setString('tjuuname', newTjuName);
//   _password = newTjuName;
// }

// var _tjupasswd = "";
//
// String get tjupasswd {
//   if (_tjupasswd == "") _tjupasswd = _sharedPref.getString('tjupasswd') ?? "";
//   return _tjupasswd;
// }
//
// set tjupasswd(String newTjuPassword) {
//   if (_tjupasswd == newTjuPassword) return;
//   _sharedPref.setString('tjupasswd', newTjuPassword);
//   _tjupasswd = newTjuPassword;
// }
