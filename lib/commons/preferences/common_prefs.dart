// @dart = 2.12
import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  CommonPreferences._();

  static late SharedPreferences sharedPref;

  /// 初始化sharedPrefs，在运行app前被调用
  static Future<void> initPrefs() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  /// 第一次登录
  static final isFirstUse = PrefsBean<bool>('isFirstUse', true);

  /// 天外天账号系统
  static final isLogin = PrefsBean<bool>('login');
  static final token = PrefsBean<String>('token');
  static final nickname = PrefsBean<String>('nickname', '未登录');
  static final lakeNickname = PrefsBean<String>('lakeNickname', '无昵称');
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
  static final area = PrefsBean<String>('area');
  static final building = PrefsBean<String>('building');
  static final floor = PrefsBean<String>('floor');
  static final room = PrefsBean<String>('room');
  static final bed = PrefsBean<String>('bed');
  static final themeToken = PrefsBean<String>('themeToken');

  /// 用户信息
  static final lakeToken = PrefsBean<String>('lakeToken');
  static final lakeUid = PrefsBean<String>('feedbackUid');
  static final isSuper = PrefsBean<bool>('isSuper', false);
  static final isSchAdmin = PrefsBean<bool>('isSchAdmin', false);
  static final isStuAdmin = PrefsBean<bool>('isStuAdmin', false);
  static final isUser = PrefsBean<bool>('isUser', true);
  static final feedbackSearchHistory =
      PrefsBean<List<String>>('feedbackSearchHistory');

  // 1 -> 按时间排序; 2 -> 按热度排序
  static final feedbackSearchType =
      PrefsBean<String>('feedbackSearchType', '1');
  static final feedbackFloorSortType = PrefsBean<int>('feedbackFloorSortType', 0);
  static final feedbackLastWeCo = PrefsBean<String>('feedbackLastWeKo');
  static final isFirstLogin = PrefsBean<bool>('firstLogin', true);

  /// 愚人节用，从上到下为总判断第一次，考表，GPA，点赞，头像,课表
  static final isAprilFoolGen = PrefsBean<bool>('aprilFoolGen', true);
  static final isAprilFool = PrefsBean<bool>('aprilFool', false);
  static final isAprilFoolGPA = PrefsBean<bool>('aprilFoolGpa', false);
  static final isAprilFoolHead = PrefsBean<bool>('aprilFoolHead', false);
  static final isAprilFoolLike = PrefsBean<bool>('aprilFoolLike', false);
  static final isAprilFoolClass = PrefsBean<bool>('aprilFoolClass', false);

  /// 海棠节用->皮肤用
  static final isSkinUsed = PrefsBean<bool>('skin', false);
  static final isDarkMode = PrefsBean<bool>('isDarkMode', false);
  static final skinProfile = PrefsBean<String>('skinProfile', '');
  static final skinClass = PrefsBean<String>('skinClass', '');
  static final skinMain = PrefsBean<String>('skinMain', '');
  static final skinColorA = PrefsBean<int>('skinColorA', 1);
  static final skinColorB = PrefsBean<int>('skinColorB', 1);
  static final skinColorC = PrefsBean<int>('skinColorC', 1);
  static final skinColorD = PrefsBean<int>('skinColorD', 1);
  static final skinColorE = PrefsBean<int>('skinColorE', 1);
  static final skinColorF = PrefsBean<int>('skinColorF', 1);
  static final skinColorG = PrefsBean<int>('skinColorG', 1);

  /// 这里说明一下GPA和课程表的逻辑：
  /// 1. 进入主页时先从缓存中读取数据
  /// 2. 进入 gpa / 课程表 / 考表 页面时再尝试用缓存中办公网的cookie爬取最新数据
  ///
  /// 办公网
  static final gpaData = PrefsBean<String>('gpaData');
  static final courseData = PrefsBean<String>('courseData');
  static final examData = PrefsBean<String>('examData');
  static final customUpdatedAt = PrefsBean<int>('customUpdatedAt'); // 上次修改自定义课程的时间
  static final isBindTju = PrefsBean<bool>('bindtju');
  static final tjuuname = PrefsBean<String>('tjuuname');
  static final tjupasswd = PrefsBean<String>('tjupasswd');
  ///
  /// 自定义课表
  static final customCourseToken = PrefsBean<String>('customCourseToken');
  static final courseAppBarShrink = PrefsBean<bool>('courseAppBarShrink');

  /// 学期信息
  /// 由于好奇心搜了一下，这个时间戳大概2038年才会int32范围溢出，懒得改了哈哈
  /// 修改termStart默认值的时候，记得也修改下kotlin/com.twt.service/widget/SchedulePreferences.kt中的默认值
  static final termStart = PrefsBean<int>('termStart', 1660492800);
  static final termName = PrefsBean<String>('termName', '22231');
  static final termStartDate = PrefsBean<String>('termStartDate', '2022-08-15');

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
  static final hideGPA = PrefsBean<bool>('hideGPA'); // 首页不显示GPA
  static final hideExam = PrefsBean<bool>('hideExam'); // 首页不显示考表
  static final nightMode = PrefsBean<bool>('nightMode', true); // 开启夜猫子模式
  static final skinNow = PrefsBean<int>('skinNow', 0); // 当前皮肤编号

  /// 自习室
  static final  loungeUpdateTime = PrefsBean<String>('loungeUpdateTime');
  static final  lastChoseCampus = PrefsBean<int>('lastChoseCampus', 0);

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
  static final lastCheckUpdateTime = PrefsBean('lastCheckUpdateTime');
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
    major.clear();
    stuType.clear();
    avatar.clear();
    lakeToken.clear();
    lakeUid.clear();
    isSuper.clear();
    isSchAdmin.clear();
    isStuAdmin.clear();
    isUser.clear();
    canPush.clear();
    lastCheckUpdateTime.clear();
    area.clear();
    building.clear();
    floor.clear();
    room.clear();
    bed.clear();
    isSkinUsed.clear();
    isDarkMode.clear();
    skinProfile.clear();
    skinClass.clear();
    skinMain.clear();
    skinColorA.clear();
    skinColorB.clear();
    skinColorC.clear();
    skinColorD.clear();
    skinColorE.clear();
    skinColorF.clear();
  }

  /// 清除办公网缓存
  static void clearTjuPrefs() {
    gpaData.clear();
    courseData.clear();
    examData.clear();
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
