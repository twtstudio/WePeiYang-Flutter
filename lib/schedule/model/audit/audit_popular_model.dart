class AuditPopular{
  String courseId;
  String updatedAt;
  String count;
  int rank;
  Map course; // AuditPopularCourse

  AuditPopular.fromJson(dynamic tmp){
    courseId = tmp['courseId'];
    updatedAt = tmp['updatedAt'];
    count = tmp['count'];
    rank = tmp['rank'];
    course = tmp['course'];
  }
}

class AuditPopularCourse{
  String collegeId;
  String year;
  String name;
  String semester;
  int id;

  AuditPopularCourse.fromJson(dynamic tmp){
    collegeId = tmp['collegeId'];
    year = tmp['year'];
    name = tmp['name'];
    semester = tmp['semester'];
    id = tmp['id'];
  }
}