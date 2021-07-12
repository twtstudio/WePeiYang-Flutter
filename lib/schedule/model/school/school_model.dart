class ScheduleBean {
  int termStart;
  String termName;
  List<ScheduleCourse> courses;

  ScheduleBean(this.termStart, this.termName, this.courses);

  ScheduleBean.fromJson(Map<String, dynamic> map)
      : termStart = map['termStart'],
        termName = map['termName'],
        courses = List()
          ..addAll((map['courses'] as List ?? [])
              .map((e) => ScheduleCourse.fromJson(e)));

  Map<String, dynamic> toJson() => {
        'termStart': termStart,
        'termName': termName,
        'courses': courses.map((e) => e.toJson()).toList(),
      };
}

/// course对象指的是 “一节课” 而不是 “一门课”
class ScheduleCourse {
  String classId = "";
  String courseId = "";
  String courseName = "";
  String credit = "";
  String teacher = "";
  String campus = "";
  Week week;
  Arrange arrange;

  /// 课程类型  0->普通课程  1->蹭课
  int type;

  ScheduleCourse(this.classId, this.courseId, this.courseName, this.credit,
      this.teacher, this.campus, this.week, this.arrange) {
    type = 0;
  }

  ScheduleCourse.audit(this.teacher, this.week, this.courseName, this.arrange) {
    type = 1;
  }

  ScheduleCourse.fromJson(Map<String, dynamic> map)
      : classId = map['classId'],
        courseId = map['courseId'],
        courseName = map['courseName'],
        credit = map['credit'],
        teacher = map['teacher'],
        campus = map['campus'],
        week = Week.fromJson(map['week']),
        arrange = Arrange.fromJson(map['arrange']);

  Map<String, dynamic> toJson() => {
        'classId': classId,
        'courseId': courseId,
        'courseName': courseName,
        'credit': credit,
        'teacher': teacher,
        'campus': campus,
        'week': week.toJson(),
        'arrange': arrange.toJson()
      };
}

class Arrange {
  String week; // 单双周、单周、双周
  String binStr; // 每周是否有课的二进制字符串
  String room; // 上课地点
  String start; // 第几节开始 (从1开始数)
  String end; // 第几节结束
  String day; // 周几 （1 -> 周一）
  String courseName; // 课程名称，仅供爬虫时对照用

  // TODO 这个是蹭课用的，记得补上binStr
  Arrange(this.week, this.room, this.start, this.end, this.day);

  /// 用这个构造方法需要自行补上room
  Arrange.spider(
      this.week, this.binStr, this.start, this.end, this.day, this.courseName);

  Arrange.fromJson(Map<String, dynamic> map)
      : week = map['week'],
        binStr = map['binStr'],
        room = map['room'],
        start = map['start'],
        end = map['end'],
        day = map['day'],
        courseName = map['courseName'];

  Map<String, dynamic> toJson() => {
        'week': week,
        'binStr': binStr,
        'room': room,
        'start': start,
        'end': end,
        'day': day,
        'courseName': courseName
      };
}

class Week {
  String start;
  String end;

  Week(this.start, this.end);

  Week.fromJson(Map<String, dynamic> map)
      : start = map['start'],
        end = map['end'];

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
}
