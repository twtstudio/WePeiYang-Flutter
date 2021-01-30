class GPABean {
  Total total;
  List<GPAStat> stats;

  GPABean(this.total, this.stats);
}

class Total {
  double weighted; // 总加权
  double gpa; // 总绩点
  double credits; // 总学分

  Total(this.weighted, this.gpa, this.credits);
}

class GPAStat {
  double weighted; // 每学期加权
  double gpa; // 每学期绩点
  double credits; // 每学期学分
  List<GPACourse> courses;

  GPAStat(this.weighted, this.gpa, this.credits, this.courses);
}

class GPACourse {
  String name; // 课程名称
  String classType; // 课程类别 （必修/选修/...）
  double score; // 课程成绩
  double credit; // 课程学分
  double gpa; // 课程绩点

  GPACourse(this.name, this.classType, this.score, this.credit, this.gpa);
}
