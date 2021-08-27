import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static final _instance = CommonPreferences._();

  /// 用create函数获取commonPref类单例
  factory CommonPreferences() => _instance;

  static SharedPreferences getPref() => _instance._sharedPref;

  SharedPreferences _sharedPref;

  /// 初始化sharedPrefs，在运行app前被调用
  static Future<void> initPrefs() async {
    _instance._sharedPref = await SharedPreferences.getInstance();
  }

  /// 天外天账号系统
  var isLogin = PrefsBean<bool>('login');
  var token = PrefsBean<String>('token');
  var nickname = PrefsBean<String>('nickname', '未登录');
  var userNumber = PrefsBean<String>('userNumber');
  var phone = PrefsBean<String>('phone');
  var email = PrefsBean<String>('email');
  var account = PrefsBean<String>('account');
  var password = PrefsBean<String>('password');
  var captchaCookie = PrefsBean<String>('Cookie');
  var realName = PrefsBean<String>('realName');
  var department = PrefsBean<String>('department');
  var stuType = PrefsBean<String>('stuType');
  var major = PrefsBean<String>('major');

  /// 这里说明一下GPA和课程表的逻辑：
  /// 1. 进入主页时先从缓存中读取数据
  /// 2. 进入 gpa / 课程表 页面时再尝试用缓存中办公网的cookie爬取最新数据
  ///
  /// GPA & 课程表 & 学期信息
  var gpaData = PrefsBean<String>('gpaData');
  var scheduleData = PrefsBean<String>('scheduleData');
  var termStart = PrefsBean<int>('termStart', 1629043200); // 由于好奇心搜了一下，这个时间戳大概2038年才会范围溢出，懒得改了哈哈
  var termName = PrefsBean<String>('termName', '20212');
  var termStartDate = PrefsBean<String>('termStartDate', '');

  /// 办公网
  var isBindTju = PrefsBean<bool>('bindtju');
  var tjuuname = PrefsBean<String>('tjuuname');
  var tjupasswd = PrefsBean<String>('tjupasswd');

  /// cookies in classes.tju.edu.cn
  var gSessionId = PrefsBean<String>("gsessionid"); // GSESSIONID
  var garbled = PrefsBean<String>("garbled"); // UqZBpD3n3iXPAw1X
  var semesterId = PrefsBean<String>("semester"); // semester.id
  var ids = PrefsBean<String>("ids"); // ids

  List<String> getCookies() {
    var jSessionId = 'J' +
        ((gSessionId.value.length > 0) ? gSessionId.value.substring(1) : "");
    return [gSessionId.value, jSessionId, garbled.value, semesterId.value];
  }

  /// 设置页面
  var language = PrefsBean<int>("language", 0); // 系统语言
  var dayNumber = PrefsBean<int>("dayNumber", 7); // 每周显示天数
  var hideGPA = PrefsBean<bool>("hideGPA"); // 首页不显示GPA
  var nightMode = PrefsBean<bool>("nightMode", true); // 开启夜猫子模式
  var otherWeekSchedule =
      PrefsBean<bool>("otherWeekSchedule", true); // 课表显示非本周课程
  var remindBefore = PrefsBean<bool>("remindBefore"); // 课前提醒
  var remindTime = PrefsBean<int>("remindTime", 900); // 提醒时间，默认为上课15分钟前

  /// feedback token
  var feedbackToken = PrefsBean<String>("feedbackToken");

  /// lounge temporary data update time
  var temporaryUpdateTime = PrefsBean<String>("temporaryUpdateTime", "");
  var lastChoseCampus = PrefsBean<int>("lastChoseCampus", 0);
  var favorListState = PrefsBean<int>("favorListState", 0);

  /// 疫情提交时间
  var reportTime = PrefsBean<String>('reportTime');

  /// 清除天外天账号系统缓存
  void clearUserPrefs() {
    isLogin.clear();
    token.clear();
    nickname.clear();
    userNumber.clear();
    phone.clear();
    email.clear();
    account.clear();
    password.clear();
    captchaCookie.clear();
    feedbackToken.clear();
  }

  /// 清除办公网缓存
  void clearTjuPrefs() {
    gpaData.clear();
    scheduleData.clear();
    isBindTju.clear();
    tjuuname.clear();
    tjupasswd.clear();
    gSessionId.clear();
    garbled.clear();
    semesterId.clear();
    ids.clear();
  }
}

class PrefsBean<T> with PreferencesUtil<T> {
  PrefsBean(this._key, [this._default]) {
    if (_default == null) _default = _getDefaultValue();
  }

  String _key;
  T _default;

  T get value => _getValue(_key) ?? _default;

  set value(T newValue) {
    if (value == newValue) return;
    _setValue(newValue, _key);
  }

  clear() {
    _clearValue(_key);
  }
}

mixin PreferencesUtil<T> {
  SharedPreferences _instance;

  SharedPreferences get pref {
    if (_instance == null) _instance = CommonPreferences.getPref();
    return _instance;
  }

  dynamic _getValue(String key) => pref.get(key);

  _setValue(T value, String key) async {
    switch (T) {
      case String:
        await pref.setString(key, value as String);
        break;
      case bool:
        await pref.setBool(key, value as bool);
        break;
      case int:
        await pref.setInt(key, value as int);
        break;
      case double:
        await pref.setDouble(key, value as double);
        break;
      case List:
        await pref.setStringList(key, value as List<String>);
        break;
    }
  }

  _clearValue(String key) async {
    await pref.remove(key);
  }

  dynamic _getDefaultValue() {
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
}
