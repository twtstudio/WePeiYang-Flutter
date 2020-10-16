class Schedule {
  int termStart;
  String term;
  List<Course> courses;

  Schedule(this.termStart, this.term, this.courses);
}

/// course对象指的是 “一节课” 而不是 “一门课”
class Course {
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

  Course(this.classId, this.courseId, this.courseName, this.credit,
      this.teacher, this.campus, this.week, this.arrange) {
    type = 0;
  }

  Course.audit(this.teacher, this.week, this.courseName, this.arrange) {
    type = 1;
  }
}

class Arrange {
  String week; // 单双周、单周、双周
  String room; // 上课地点
  String start; // 第几节开始 (从1开始数)
  String end; // 第几节结束
  String day; // 周几 （1 -> 周一）
  String courseName; // 课程名称，仅供爬虫时对照用

  Arrange(this.week, this.room, this.start, this.end, this.day);

  /// 用这个构造方法需要自行补上room
  Arrange.spider(this.week, this.start, this.end, this.day, this.courseName);
}

class Week {
  String start;
  String end;

  Week(this.start, this.end);
}
