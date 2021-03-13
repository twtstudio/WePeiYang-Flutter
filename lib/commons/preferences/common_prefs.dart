import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static final _instance = CommonPreferences._();

  /// 用create函数获取commonPref类单例
  factory CommonPreferences() => _instance;

  static SharedPreferences getPref() => _instance._sharedPref;

  SharedPreferences _sharedPref;

  /// 初始化sharedPrefs，在自动登录时就被调用
  static Future<void> initPrefs() async {
    _instance._sharedPref = await SharedPreferences.getInstance();
  }

  ///twt相关

  var isLogin = PrefsBean<bool>('login');
  var token = PrefsBean<String>('token');
  var nickname = PrefsBean<String>('nickname', '未登录');
  var userNumber = PrefsBean<String>('userNumber');
  var phone = PrefsBean<String>('phone');
  var email = PrefsBean<String>('email');
  var account = PrefsBean<String>('account');
  var password = PrefsBean<String>('password');
  var captchaCookie = PrefsBean<String>('Cookie');

  /// 这里说明一下GPA和课程表的逻辑：
  /// 1. 进入主页时先从缓存中读取数据
  /// 2. 进入 gpa / 课程表 页面时再尝试用缓存中办公网的cookie爬取最新数据
  /// GPA & 课程表数据
  var gpaData = PrefsBean<String>('gpaData');
  var scheduleData = PrefsBean<String>('scheduleData');

  ///办公网相关

  var isBindTju = PrefsBean<bool>('bindtju');
  var tjuuname = PrefsBean<String>('tjuuname');
  var tjupasswd = PrefsBean<String>('tjupasswd');

  /// cookies in classes.tju.edu.cn
  var gSessionId = PrefsBean<String>("gsessionid"); // GSESSIONID
  var garbled = PrefsBean<String>("garbled"); // UqZBpD3n3iXPAw1X
  var semesterId = PrefsBean<String>("semester"); // semester.id
  var ids = PrefsBean<String>("ids"); // ids

  /// 设置页面
  var language = PrefsBean<int>("language", 0); // 系统语言
  var dayNumber = PrefsBean<int>("dayNumber", 7); // 每周显示天数
  var hideGPA = PrefsBean<bool>("hideGPA"); // 首页不显示GPA
  var nightMode = PrefsBean<bool>("nightMode"); // 开启夜猫子模式
  var otherWeekSchedule = PrefsBean<bool>("otherWeekSchedule"); // 课表显示非本周课程
  var remindBefore = PrefsBean<bool>("remindBefore"); // 课前提醒
  var remindTime = PrefsBean<int>("remindTime", 900); // 提醒时间，默认为上课15分钟前

  List<String> getCookies() {
    var jSessionId = 'J' +
        ((gSessionId.value.length > 0) ? gSessionId.value.substring(1) : "");
    return [gSessionId.value, jSessionId, garbled.value, semesterId.value];
  }

  /// 清除twt用户的缓存
  void clearPrefs() {
    isLogin.value = false;
    token.value = "";
    nickname.value = "";
    userNumber.value = "";
    phone.value = "";
    email.value = "";
    account.value = "";
    password.value = "";
    captchaCookie.value = "";
  }

  /// 清除办公网缓存
  void clearTjuPrefs() {
    gpaData.value = "";
    scheduleData.value = "";
    isBindTju.value = false;
    tjuuname.value = "";
    tjupasswd.value = "";
    gSessionId.value = "";
    garbled.value = "";
    semesterId.value = "";
    ids.value = "";
  }

  /// 清除gpa和课程表的缓存
}

class PrefsBean<T> {
  PrefsBean(this._key, [this._value]) {
    if (_value == null) _value = _getDefault(T);
  }

  String _key;
  T _value;

  T get value {
    _value = _getValue(T, _key) ?? _value;
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
  return pref?.get(key);
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
    case List:
      pref.setStringList(key, value as List<String>);
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
    case List:
      return [];
    default:
      return null;
  }
}
