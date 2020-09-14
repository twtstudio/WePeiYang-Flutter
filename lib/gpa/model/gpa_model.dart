class GPABean{
  Map stat;
  List<dynamic> data;
  String updated_at;
  String session;

  GPABean.fromJson(dynamic tmp){
    stat = tmp['stat'];
    data = tmp['data'];
    updated_at = tmp['updated_at'];
    session = tmp['session'];
  }
}

class Stat{
  List<Year> stat;
  Total total;
}

class Term{
  String term;
  List<Course> data;
  String name;
  TermStat stat;
}

class TermStat{
  double score;
  double gpa;
  double credit;
}

class Course{
  String no;
  String name;
  int type;
  double credit;
  int reset;
  double scroe;
  double gpa;
  Evaluate evaluate;
}

class Year{
  String year;
  double score;
  double gpa;
  double credit;
}

class Total{
  double score;
  double gpa;
  double credit;
}

class Evaluate{
  String lesson_id;
  String term;
  String union_id;
  String course_id;
}