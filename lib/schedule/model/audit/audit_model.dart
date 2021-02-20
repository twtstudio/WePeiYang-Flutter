import '../school/school_model.dart';

class AuditCourse {
  String college;
  int courseId;
  String courseName;
  String year;
  String semester;
  List<dynamic> infos; // List<InfoItem>

  AuditCourse.fromJson(dynamic tmp) {
    college = tmp['college'];
    courseId = tmp['courseId'];
    courseName = tmp['courseName'];
    year = tmp['year'];
    semester = tmp['semester'];
    infos = tmp['infos'];
  }

  List<ScheduleCourse> convertToCourseList() {
    var infoSample = (infos as List<InfoItem>)[0];
    var week =
        Week(infoSample.startWeek.toString(), infoSample.endWeek.toString());
    List<ScheduleCourse> courseList = [];
    (infos as List<InfoItem>).forEach((it) {
      String weekType = "单双周";
      switch (it.weekType) {
        case 1:
          weekType = "单周";
          break;
        case 2:
          weekType = "双周";
      }
      var arrange = Arrange(
          weekType,
          "${it.building}楼${it.room}",
          it.startTime.toString(),
          (it.startTime - 1 + it.courseLength).toString(),
          it.weekDay.toString());
      courseList
          .add(ScheduleCourse.audit(infoSample.teacher, week, courseName, arrange));
    });
    return courseList;
  }

  AuditCourse(this.college, this.courseId, this.courseName, this.year,
      this.semester, this.infos);
}

class AuditSearchCourse {
  int id;
  int courseId;
  String name;
  String year;
  String semester;
  Map college; // CollegeBean
  List<dynamic> info; // List<InfoItem>

  AuditSearchCourse.fromJson(dynamic tmp) {
    id = tmp['id'];
    courseId = tmp['courseId'];
    name = tmp['name'];
    year = tmp['year'];
    semester = tmp['semester'];
    college = tmp['college'];
    info = tmp['info'];
  }

  AuditCourse convertToAuditCourse() => AuditCourse(
      (college as CollegeBean).name, id, name, year, semester, info);
}

class CollegeBean {
  int id;
  String name;

  CollegeBean.fromJson(dynamic tmp) {
    id = tmp['id'];
    name = tmp['name'];
  }
}

class InfoItem {
  String courseId;
  int startWeek;
  int endWeek;
  String courseName;
  int weekType;
  String courseIdInTju;
  String building;
  String room;
  int startTime;
  String teacher;
  int courseLength;
  int weekDay;
  String teacherType;
  int id;

  InfoItem.fromJson(dynamic tmp) {
    courseId = tmp['courseId'];
    startWeek = tmp['startWeek'];
    endWeek = tmp['endWeek'];
    courseName = tmp['courseName'];
    weekType = tmp['weekType'];
    courseIdInTju = tmp['courseIdInTju'];
    building = tmp['building'];
    room = tmp['room'];
    startTime = tmp['startTime'];
    teacher = tmp['teacher'];
    courseLength = tmp['courseLength'];
    weekDay = tmp['weekDay'];
    teacherType = tmp['teacherType'];
    id = tmp['id'];
  }
}

class CollegeCourse {
  int id;
  String name;
  String collegeName = "";

  CollegeCourse.fromJson(dynamic tmp) {
    id = tmp['id'];
    name = tmp['name'];
  }
}

class AuditCollegeData {
  String collegeName;
  int collegeId;
  List<CollegeCourse> collegeCourses = [];

  AuditCollegeData.fromJson(dynamic tmp) {
    collegeName = tmp['collegeName'];
    collegeId = tmp['collegeId'];
  }
}
