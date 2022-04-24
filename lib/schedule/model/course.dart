// @dart = 2.12
/// 本地缓存用
class CourseTable {
  List<Course> schoolCourses;
  List<Course> customCourses;

  CourseTable(this.schoolCourses, this.customCourses);

  CourseTable.fromJson(Map<String, dynamic> map)
      : schoolCourses = []..addAll(
            (map['schoolCourses'] as List).map((e) => Course.fromJson(e))),
        customCourses = []..addAll(
            (map['customCourses'] as List).map((e) => Course.fromJson(e)));

  Map<String, dynamic> toJson() => {
        'schoolCourses': schoolCourses.map((e) => e.toJson()).toList(),
        'customCourses': customCourses.map((e) => e.toJson()).toList()
      };
}

class Pair<A, B> {
  A first;
  B last;

  Pair(this.first, this.last);
}

extension PairArrange on Pair<Course, int> {
  Arrange get arrange => this.first.arrangeList[this.last];
}

class Course {
  /// 以下属性需要缓存
  String name;
  String classId = ''; // serial
  String courseId = ''; // no
  String credit;
  String campus = '';
  String weeks; // 格式为 `1-16`
  List<String> teacherList; // 讲这门课的所有老师，带职称
  List<Arrange> arrangeList;
  int type; // 0->正常课程; 1->自定义课程
  /// 以下属性不需要缓存，临时存储
  int? index; // 在自定义课程列表中的下标

  /// 爬课表用
  Course.spider(this.name, this.classId, this.courseId, this.credit,
      this.campus, this.weeks, this.teacherList, this.arrangeList)
      : type = 0;

  /// 自定义课表用，没有classId、courseId、campus，index需要后续补充
  Course.custom(
      this.name, this.credit, this.weeks, this.teacherList, this.arrangeList)
      : type = 1;

  Course.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        classId = map['classId'],
        courseId = map['courseId'],
        credit = map['credit'],
        campus = map['campus'],
        weeks = map['weeks'],
        teacherList = List<String>.from(map['teacherList']),
        arrangeList = []..addAll(
            (map['arrangeList'] as List).map((e) => Arrange.fromJson(e))),
        type = map['type'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'classId': classId,
        'courseId': courseId,
        'credit': credit,
        'campus': campus,
        'weeks': weeks,
        'teacherList': teacherList,
        'arrangeList': arrangeList.map((e) => e.toJson()).toList(),
        'type': type
      };
}

/// [weekday], [weekList], [unitList]均从1开始数，例如[weekDay] == 1代表周一
class Arrange {
  String? name; // 课程名称，仅供爬虫时对照用，不进缓存
  String location = ''; // 上课地点
  int weekday = 1; // 周几
  List<int> weekList = []; // 哪些周有课
  List<int> unitList = [0, 0]; // 从第几节上到第几节
  List<String> teacherList = []; // 讲这节课的所有老师，带职称
  /// 以下属性不需要缓存，临时存储
  bool? needFloat; // 是否需要“漂浮”显示

  /// 爬课表用，构造后需要补上location属性
  Arrange.spider(
      this.name, this.weekday, this.weekList, this.unitList, this.teacherList);

  /// 自定义课表用
  Arrange.empty();

  Arrange.fromJson(Map<String, dynamic> map)
      : location = map['location'],
        weekday = map['weekday'],
        weekList = List<int>.from(map['weekList']),
        unitList = List<int>.from(map['unitList']),
        teacherList = []
          ..addAll((map['teacherList'] as List).map((e) => e.toString()));

  Map<String, dynamic> toJson() => {
        'location': location,
        'weekday': weekday,
        'weekList': weekList,
        'unitList': unitList,
        'teacherList': teacherList
      };

  @override
  String toString() => toJson().toString();
}
