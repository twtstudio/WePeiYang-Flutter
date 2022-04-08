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
  var major = PrefsBean<String>('major');
  var stuType = PrefsBean<String>('stuType');
  var avatar = PrefsBean<String>('avatar');
  var area = PrefsBean<String>('area');
  var building = PrefsBean<String>('building');
  var floor = PrefsBean<String>('floor');
  var room = PrefsBean<String>('room');
  var bed = PrefsBean<String>('bed');

  var themeToken = PrefsBean<String>("themeToken");

  /// 校务专区
  var feedbackToken = PrefsBean<String>("lakeToken");
  var feedbackUid = PrefsBean<String>('feedbackUid');
  var feedbackSearchHistory =
      PrefsBean<List<String>>("feedbackSearchHistory", []);

  // 1 -> 按时间排序; 2 -> 按热度排序
  var feedbackSearchType = PrefsBean<String>("feedbackSearchType", "1");
  var feedbackLastWeCo = PrefsBean<String>("feedbackLastWeKo");
  var isFirstLogin = PrefsBean<bool>("firstLogin", true);
  ///愚人节用，从上到下为总判断第一次，考表，GPA，点赞，头像,课表
  var isAprilFoolGen = PrefsBean<bool>("aprilFoolGen", true);
  var isAprilFool = PrefsBean<bool>("aprilFool", false);
  var isAprilFoolGPA = PrefsBean<bool>("aprilFoolGpa", false);
  var isAprilFoolHead = PrefsBean<bool>("aprilFoolHead", false);
  var isAprilFoolLike = PrefsBean<bool>("aprilFoolLike", false);
  var isAprilFoolClass = PrefsBean<bool>("aprilFoolClass", false);
  ///海棠节用
  var isBegonia = PrefsBean<bool>("begonia", false);

  /// 这里说明一下GPA和课程表的逻辑：
  /// 1. 进入主页时先从缓存中读取数据
  /// 2. 进入 gpa / 课程表 / 考表 页面时再尝试用缓存中办公网的cookie爬取最新数据
  ///
  /// 办公网
  var gpaData = PrefsBean<String>('gpaData');
  var scheduleData = PrefsBean<String>('scheduleData');
  var examData = PrefsBean<String>('examData');
  var isBindTju = PrefsBean<bool>('bindtju');
  var tjuuname = PrefsBean<String>('tjuuname');
  var tjupasswd = PrefsBean<String>('tjupasswd');
  var scheduleShrink = PrefsBean<bool>('scheduleShrink');

  /// 学期信息
  /// 由于好奇心搜了一下，这个时间戳大概2038年才会int范围溢出，懒得改了哈哈
  /// 修改termStart默认值的时候，记得也修改下kotlin/com.twt.service/widget/SharedPreferences.kt中的默认值
  var termStart = PrefsBean<int>('termStart', 1645372800);
  var termName = PrefsBean<String>('termName', '21222');
  var termStartDate = PrefsBean<String>('termStartDate', '2022-02-21');

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
  var hideExam = PrefsBean<bool>("hideExam"); // 首页不显示考表
  var showPosterGirl = PrefsBean<bool>("hidePosterGirl"); //首页不显示看板娘
  var nightMode = PrefsBean<bool>("nightMode", true); // 开启夜猫子模式
  var otherWeekSchedule =
      PrefsBean<bool>("otherWeekSchedule", true); // 课表显示非本周课程

  /// 自习室
  var loungeUpdateTime = PrefsBean<String>("loungeUpdateTime", "");
  var lastChoseCampus = PrefsBean<int>("lastChoseCampus", 0);

  /// 健康信息提交时间
  var reportTime = PrefsBean<String>('reportTime');

  /// ----------下方是一些应用相关的杂项----------
  /// 上次修改数据逻辑的时间（当课表、gpa的逻辑修改时，判断这个来强制清除缓存）
  var updateTime = PrefsBean<String>('updateTime');

  /// 是否为初次使用此app
  var firstUse = PrefsBean<bool>('firstUse', true);

  /// 是否使用账密登陆（false则为短信登陆）
  var usePwLogin = PrefsBean<bool>('pwLogin', true);

  // 应用更新相关配置
  /// 使用beta版还是release版微北洋
  var apkType = PrefsBean('apkType', "release");
  var todayShowUpdateAgain = PrefsBean('todayShowUpdateAgain', '');
  var canPush = PrefsBean('can_push', false);

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
    realName.clear();
    department.clear();
    stuType.clear();
    major.clear();
    feedbackToken.clear();
    canPush.clear();
    todayShowUpdateAgain.clear();
    area.clear();
    building.clear();
    floor.clear();
    room.clear();
    bed.clear();
  }

  /// 清除办公网缓存
  void clearTjuPrefs() {
    gpaData.clear();
    scheduleData.clear();
    isBindTju.clear();
    tjuuname.clear();
    tjupasswd.clear();
  }
}

class PrefsBean<T> with PreferencesUtil<T> {
  PrefsBean(this._key, [this._default]) {
    if (_default == null) _default = _getDefaultValue();
  }

  String _key;
  T _default;

  T get value => _getValue(_key) ?? _default;

  // 这个判断不能加，因为不存储的话原生那边获取不到，除非原生那边也设置了默认值
  // if (value == newValue) return;
  set value(T newValue) => _setValue(newValue, _key);

  clear() => _clearValue(_key);
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
