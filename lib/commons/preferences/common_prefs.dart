import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static late SharedPreferences sharedPref;

  /// 初始化sharedPrefs，在运行app前被调用
  static Future<void> init() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  /// 天外天账号系统
  static final isLogin = PrefsBean<bool>('login');
  static final token = PrefsBean<String>('token');
  static final nickname = PrefsBean<String>('nickname', '未登录');
  static final lakeNickname = PrefsBean<String>('lakeNickname');
  static final userNumber = PrefsBean<String>('userNumber');
  static final phone = PrefsBean<String>('phone');
  static final email = PrefsBean<String>('email');
  static final account = PrefsBean<String>('account');
  static final password = PrefsBean<String>('password');
  static final realName  = PrefsBean<String>('realName');
  static final department = PrefsBean<String>('department');
  static final major = PrefsBean<String>('major');
  static final stuType = PrefsBean<String>('stuType');
  static final avatar = PrefsBean<String>('avatar');
  static final area = PrefsBean<String>('area');
  static final building = PrefsBean<String>('building');
  static final floor = PrefsBean<String>('floor');
  static final room = PrefsBean<String>('room');
  static final bed = PrefsBean<String>('bed');
  static final accountUpgrade = PrefsBean<List>('accountUpgrade');

  /// 求实论坛相关
  static final lakeToken = PrefsBean<String>('lakeToken', '');
  static final lakeUid = PrefsBean<String>('feedbackUid');
  static final isSuper = PrefsBean<bool>('isSuper', false);
  static final isSchAdmin = PrefsBean<bool>('isSchAdmin', false);
  static final isStuAdmin = PrefsBean<bool>('isStuAdmin', false);
  static final isUser = PrefsBean<bool>('isUser', true);
  static final feedbackFloorSortType =
      PrefsBean<int>('feedbackFloorSortType', 0);
  static final feedbackLastWeCo = PrefsBean<String>('feedbackLastWeKo');
  static final feedbackLastLostAndFoundWeCo =
      PrefsBean<String>('feedbackLastWeKo');
  static final avatarBoxMyUrl = PrefsBean<String>('avatarBoxMyUrl');

  /// 求实论坛--等级系统
  static final levelPoint = PrefsBean<int>('levelPoint');
  static final levelName = PrefsBean<String>('levelName');
  static final level = PrefsBean<int>('level');
  static final nextLevelPoint = PrefsBean<int>('nextLevelPoint');
  static final curLevelPoint = PrefsBean<int>('curLevelPoint');

  /// 办公网
  static final gpaData = PrefsBean<String>('gpaData');
  static final courseData = PrefsBean<String>('courseData');
  static final examData = PrefsBean<String>('examData');
  static final customUpdatedAt =
      PrefsBean<int>('customUpdatedAt'); // 上次修改自定义课程的时间
  static final isBindTju = PrefsBean<bool>('bindtju');
  static final tjuuname = PrefsBean<String>('tjuuname');
  static final tjupasswd = PrefsBean<String>('tjupasswd');

  /// 自定义课表
  static final customCourseToken = PrefsBean<String>('customCourseToken');
  static final courseAppBarShrink = PrefsBean<bool>('courseAppBarShrink');

  /// 学期信息
  /// 修改termStart默认值的时候，记得也修改下kotlin/com.twt.service/widget/SchedulePreferences.kt中的默认值
  static final termStart = PrefsBean<int>('termStart', 1676822400);
  static final termName = PrefsBean<String>('termName', '22232');
  static final termStartDate = PrefsBean<String>('termStartDate', '2023-02-20');

  /// cookies in classes.tju.edu.cn
  static final gSessionId = PrefsBean<String>('gsessionid'); // GSESSIONID
  static final garbled = PrefsBean<String>('garbled'); // UqZBpD3n3iXPAw1X
  static final semesterId = PrefsBean<String>('semester'); // semester.id
  static final ids = PrefsBean<String>('ids'); // ids

  static List<String> get cookies {
    var jSessionId = 'J' +
        ((gSessionId.value.length > 0) ? gSessionId.value.substring(1) : '');
    return [gSessionId.value, jSessionId, garbled.value, semesterId.value];
  }

  /// 设置页面
  static final language = PrefsBean<int>('language', 0); // 系统语言
  static final dayNumber = PrefsBean<int>('dayNumber', 7); // 每周显示天数
  static final hideGPA = PrefsBean<bool>('hideGPA', true); // 首页不显示GPA
  static final hideExam = PrefsBean<bool>('hideExam'); // 首页不显示考表
  static final showMap = PrefsBean<bool>('showMap', false); // 首页不显示考表
  static final nightMode = PrefsBean<bool>('nightMode', true); // 开启夜猫子模式
  static final useClassesBackend =
      PrefsBean<bool>('useClassesBackend', false); // 用后端爬虫代替前端爬虫（课表、考表、GPA）
  static final appThemeId = PrefsBean<String>('appThemeId', 'builtin_light');
  static final appDarkThemeId =
      PrefsBean<String>('appDarkThemeId', 'builtin_dark');

  /// 0 light 1 dark 2 auto
  static final usingDarkTheme = PrefsBean<int>('usingDarkTheme', 0);

  /// 深色模式跟随系统false
  static final autoDarkTheme = PrefsBean<bool>('notFollowSys', true);

  /// 首页工具栏的东西
  static final fastJumpOrder = PrefsBean<String>('fastJumpOrder', "[]");

  /// 自习室
  static final loungeUpdateTime = PrefsBean<String>('loungeUpdateTime');
  static final lastChoseCampus = PrefsBean<int>('lastChoseCampus', 0);

  /// 健康信息提交时间
  static final reportTime = PrefsBean<String>('reportTime');

  /// ----------下方是一些应用相关的杂项----------
  /// 上次修改数据逻辑的时间（当课表、gpa的逻辑修改时，判断这个来强制清除缓存）
  static final updateTime = PrefsBean<String>('updateTime');
  static final lastActivityDialogShownDate =
      PrefsBean<String>('lastActivityDialogShownDate', '');

  /// 是否为初次使用此app（重新登陆也算）
  static final firstPrivacy = PrefsBean<bool>('firstPrivacy', true);
  static final firstClassesDialog = PrefsBean<bool>('firstClassesDialog', true);

  /// 应用更新相关配置，使用beta版还是release版微北洋
  static final apkType = PrefsBean<String>('apkType', 'release');
  static final lastCheckUpdateTime =
      PrefsBean<String>('lastCheckUpdateTime', '');
  static final ignoreUpdateVersion =
      PrefsBean<String>('ignoreUpdateVersion', '');

  // 推送
  static final canPush = PrefsBean<bool>('can_push', false);
  static final pushCid = PrefsBean<String>('pushCid', '');
  static final pushUser = PrefsBean<String>('pushUser', '');
  static final pushTime = PrefsBean<String>('pushTime', '2019-01-01');

  /// 清除所有缓存
  static void clearAllPrefs() {
    sharedPref.clear();
  }

  /// 清除办公网缓存
  static void clearTjuPrefs() {
    gpaData.clear();
    courseData.clear();
    examData.clear();
    customUpdatedAt.clear();
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
