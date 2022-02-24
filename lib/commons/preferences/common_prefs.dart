// @dart = 2.12
import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static late SharedPreferences sharedPref;

  /// 初始化sharedPrefs，在运行app前被调用
  static Future<void> initPrefs() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  /// 天外天账号系统
  static final isLogin = PrefsBean<bool>('login');
  static final token = PrefsBean<String>('token');
  static final nickname = PrefsBean<String>('nickname', '未登录');
  static final userNumber = PrefsBean<String>('userNumber');
  static final phone = PrefsBean<String>('phone');
  static final email = PrefsBean<String>('email');
  static final account = PrefsBean<String>('account');
  static final password = PrefsBean<String>('password');
  static final captchaCookie = PrefsBean<String>('Cookie');
  static final realName = PrefsBean<String>('realName');
  static final department = PrefsBean<String>('department');
  static final major = PrefsBean<String>('major');
  static final stuType = PrefsBean<String>('stuType');
  static final avatar = PrefsBean<String>('avatar');

  /// 校务专区
  static final feedbackToken = PrefsBean<String>('lakeToken');
  static final feedbackUid = PrefsBean<String>('feedbackUid');
  static final feedbackSearchHistory =
      PrefsBean<List<String>>('feedbackSearchHistory');

  // 1 -> 按时间排序; 2 -> 按热度排序
  static final feedbackSearchType =
      PrefsBean<String>('feedbackSearchType', '1');
  static final feedbackLastWeCo = PrefsBean<String>('feedbackLastWeKo');

  /// 这里说明一下GPA和课程表的逻辑：
  /// 1. 进入主页时先从缓存中读取数据
  /// 2. 进入 gpa / 课程表 / 考表 页面时再尝试用缓存中办公网的cookie爬取最新数据
  ///
  /// 办公网
  static final gpaData = PrefsBean<String>('gpaData');
  static final scheduleData = PrefsBean<String>('scheduleData');
  static final examData = PrefsBean<String>('examData');
  static final isBindTju = PrefsBean<bool>('bindtju');
  static final tjuuname = PrefsBean<String>('tjuuname');
  static final tjupasswd = PrefsBean<String>('tjupasswd');
  static final scheduleShrink = PrefsBean<bool>('scheduleShrink');

  /// 学期信息
  /// 由于好奇心搜了一下，这个时间戳大概2038年才会int范围溢出，懒得改了哈哈
  /// 修改termStart默认值的时候，记得也修改下kotlin/com.twt.service/widget/SharedPreferences.kt中的默认值
  static final termStart = PrefsBean<int>('termStart', 1645372800);
  static final termName = PrefsBean<String>('termName', '21222');
  static final termStartDate = PrefsBean<String>('termStartDate', '2022-02-21');

  /// cookies in classes.tju.edu.cn
  static final gSessionId = PrefsBean<String>('gsessionid'); // GSESSIONID
  static final garbled = PrefsBean<String>('garbled'); // UqZBpD3n3iXPAw1X
  static final semesterId = PrefsBean<String>('semester'); // semester.id
  static final ids = PrefsBean<String>('ids'); // ids

  static List<String> getCookies() {
    var jSessionId = 'J' +
        ((gSessionId.value.length > 0) ? gSessionId.value.substring(1) : '');
    return [gSessionId.value, jSessionId, garbled.value, semesterId.value];
  }

  /// 设置页面
  static final language = PrefsBean<int>('language', 0); // 系统语言
  static final dayNumber = PrefsBean<int>('dayNumber', 7); // 每周显示天数
  static final hideGPA = PrefsBean<bool>('hideGPA'); // 首页不显示GPA
  static final hideExam = PrefsBean<bool>('hideExam'); // 首页不显示考表
  static final showPosterGirl = PrefsBean<bool>('hidePosterGirl'); //首页不显示看板娘
  static final nightMode = PrefsBean<bool>('nightMode', true); // 开启夜猫子模式
  static final otherWeekSchedule =
      PrefsBean<bool>('otherWeekSchedule', true); // 课表显示非本周课程

  /// lounge temporary data update time
  static final temporaryUpdateTime = PrefsBean<String>('temporaryUpdateTime');
  static final lastChoseCampus = PrefsBean<int>('lastChoseCampus', 0);

  /// 健康信息提交时间
  static final reportTime = PrefsBean<String>('reportTime');

  /// ----------下方是一些应用相关的杂项----------
  /// 上次修改数据逻辑的时间（当课表、gpa的逻辑修改时，判断这个来强制清除缓存）
  static final updateTime = PrefsBean<String>('updateTime');

  /// 是否为初次使用此app
  static final firstUse = PrefsBean<bool>('firstUse', true);

  /// 是否使用账密登陆（false则为短信登陆）
  static final usePwLogin = PrefsBean<bool>('pwLogin', true);

  /// 应用更新相关配置，使用beta版还是release版微北洋
  static final apkType = PrefsBean<String>('apkType', 'release');
  static final todayShowUpdateAgain = PrefsBean<String>('todayShowUpdateAgain');
  static final canPush = PrefsBean<bool>('can_push', false);

  /// 清除天外天账号系统缓存
  static void clearUserPrefs() {
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
  }

  /// 清除办公网缓存
  static void clearTjuPrefs() {
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
  T? _default;

  T get value => _getValue(_key) ?? _default;

  // 这个判断不能加，因为不存储的话原生那边获取不到，除非原生那边也设置了默认值
  // if (value == newValue) return;
  void set value(T newValue) => _setValue(newValue, _key);

  void clear() => _clearValue(_key);
}

mixin PreferencesUtil<T> {
  static SharedPreferences get pref => CommonPreferences.sharedPref;

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

  void _clearValue(String key) async => await pref.remove(key);

  dynamic _getDefaultValue() {
    switch (T) {
      case String:
        return '';
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
