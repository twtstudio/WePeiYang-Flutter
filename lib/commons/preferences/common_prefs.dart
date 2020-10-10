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

  void clearPrefs() {
    _token = "";
    _username = "";
    _password = "";
    _tjuuname = "";
    _tjupasswd = "";
    _sharedPref.clear();
  }

  ///twt相关

  var _isLogin = false;

  bool get isLogin {
    if (_isLogin == false) _isLogin = _sharedPref.getBool('login') ?? false;
    return _isLogin;
  }

  set isLogin(bool b) {
    if (_isLogin == b) return;
    _sharedPref.setBool('login', b);
    _isLogin = b;
  }

  var _token = "";

  String get token {
    if (_token == "") _token = _sharedPref.getString('token') ?? "";
    return _token;
  }

  set token(String newToken) {
    if (_token == newToken) return;
    _sharedPref.setString('token', newToken);
    _token = newToken;
  }

  var _username = "";

  String get username {
    if (_username == "") _username = _sharedPref.getString('username') ?? "";
    return _username;
  }

  set username(String newUsername) {
    if (_username == newUsername) return;
    _sharedPref.setString('username', newUsername);
    _username = newUsername;
  }

  var _password = "";

  String get password {
    if (_password == "") _password = _sharedPref.getString('password') ?? "";
    return _password;
  }

  set password(String newPassword) {
    if (_password == newPassword) return;
    _sharedPref.setString('password', newPassword);
    _password = newPassword;
  }

  ///办公网相关(看着这些绿色波浪线就想犯强迫症，可惜接口就是这么写的)
  var _tjuuname = "";

  String get tjuuname {
    if (_tjuuname == "") _tjuuname = _sharedPref.getString('tjuuname') ?? "";
    return _tjuuname;
  }

  set tjuuname(String newTjuName) {
    if (_tjuuname == newTjuName) return;
    _sharedPref.setString('tjuuname', newTjuName);
    _password = newTjuName;
  }

  var _tjupasswd = "";

  String get tjupasswd {
    if (_tjupasswd == "") _tjupasswd = _sharedPref.getString('tjupasswd') ?? "";
    return _tjupasswd;
  }

  set tjupasswd(String newTjuPassword) {
    if (_tjupasswd == newTjuPassword) return;
    _sharedPref.setString('tjupasswd', newTjuPassword);
    _tjupasswd = newTjuPassword;
  }

  /// cookies in sso.tju.edu.cn
  var tgc = PrefsBean<String>("tgc").value; // TGC

  /// cookies in classes.tju.edu.cn
  var gSessionId = PrefsBean<String>("gsessionid").value; // GSESSIONID

  var garbled = PrefsBean<String>("garbled").value; // UqZBpD3n3iXPAw1X

  var semesterId = PrefsBean<String>("semester").value; // semester.id

  var ids = PrefsBean<String>("ids").value; // ids
}

class PrefsBean<T> {
  PrefsBean(this._key);

  String _key;
  T _value;
  bool _init = true;

  T get value {
    if(_init) {
      _init = false;
      return null;
    }
    if (_value == null) _value = _getValue(T, _key);
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _setValue(newValue, _key);
    _value = newValue;
  }
}

dynamic _getValue(Type type, String key) {
  var pref = CommonPreferences.getPref();
  return pref?.get(key);
}

void _setValue<T>(T value, String key) {
  var pref = CommonPreferences.getPref();
  if(pref == null) return;
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
    default:
      break;
  }
}