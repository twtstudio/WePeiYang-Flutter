class GPABean {
  Map stat; // List<Stat
  List<dynamic> data; // List<Term>
  // String updated_at;
  // String session;

  GPABean.fromJson(dynamic tmp) {
    stat = tmp['stat'];
    data = tmp['data'];
    // updated_at = tmp['updated_at'];
    // session = tmp['session'];
  }
}

class Term {
  String term;
  List<dynamic> data; // List<Course>
  String name;
  Map stat; // TermStat

  Term.fromJson(dynamic tmp) {
    term = tmp['term'];
    data = tmp['data'];
    name = tmp['name'];
    stat = tmp['stat'];
  }
}

class TermStat {
  double score;
  double gpa;
  double credit;

  TermStat.fromJson(dynamic tmp) {
    var cr = tmp['credit'];
    if (cr is int)
      credit = cr.toDouble();
    else
      credit = cr;
    var sc = tmp['score'];
    if (sc is int)
      score = sc.toDouble();
    else
      score = sc;
    var gp = tmp['gpa'];
    if (gp is int)
      gpa = gp.toDouble();
    else
      gpa = gp;
  }
}

/// 省略了部分参数
class GPACourse {
  // String no;
  String name;
  String classType;
  double score;
  double credit;
  // double gpa;
  // int estimated;
  // int type;
  // int reset;
  // String scoreProp;

  GPACourse.fromJson(dynamic tmp) {
    name = tmp['name'];
    classType = tmp['classType'];
    var sc = tmp['score'];
    if (sc is int)
      score = sc.toDouble();
    else
      score = sc;
    var cr = tmp['credit'];
    if (cr is int)
      credit = cr.toDouble();
    else
      credit = cr;
  }

  GPACourse(this.name, this.classType, this.credit, this.score);
}

// class Stat{
//   List<Year> stat;
//   Total total;
// }

// class Course{
//   String no;
//   String name;
//   int type;
//   double credit;
//   int reset;
//   double scroe;
//   double gpa;
//   Evaluate evaluate;
// }

// class Year{
//   String year;
//   double score;
//   double gpa;
//   double credit;
// }

// class Total{
//   double score;
//   double gpa;
//   double credit;
// }

// class Evaluate{
//   String lesson_id;
//   String term;
//   String union_id;
//   String course_id;
// }

/// gpa页面实际使用的数据类
class GPAStat {
  double weighted;
  double gpa;
  double credits;
  List<GPACourse> courses;

  GPAStat(this.weighted, this.gpa, this.credits, this.courses);
}