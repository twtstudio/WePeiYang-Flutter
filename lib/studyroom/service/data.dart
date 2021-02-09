

import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';

class Data {
  static List<Building> getBuildings() {
    var l_44 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20",
            Classroom()
              ..id = "01"
              ..name = "102"
              ..capacity = "15",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20",
            Classroom()
              ..id = "10"
              ..name = "201"
              ..capacity = "30",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20",
          ]
      ];

    var l_45 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "12"
              ..name = "101"
              ..capacity = "20",
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35",
          ]
      ];

    var l_35 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "18"
              ..name = "105"
              ..capacity = "20",
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30",
          ]
      ];

    return [l_44, l_45, l_35];
  }

  static List<Building> getOneDayAvailable(int day) {
    var l_44_1 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "01"
              ..name = "102"
              ..capacity = "15"
              ..status = "111111000000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "110000001100",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "000000001111",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "111111000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "000000000000",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "001100001100",
            Classroom()
              ..id = "10"
              ..name = "201"
              ..capacity = "30"
              ..status = "001111110000",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "110000000011",
          ]
      ];

    var l_45_1 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "12"
              ..name = "101"
              ..capacity = "20"
              ..status = "000011111100",
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "110011000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111100",
          ]
      ];

    var l_35_1 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "111111000000",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "111111000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111100",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "18"
              ..name = "105"
              ..capacity = "20"
              ..status = "000000111100",
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "111111000000",
          ]
      ];

    var l_44_2 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "111111000000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "111100000000",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "001111111111",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "111111000000",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "000011000011",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "000000001111",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000111100",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "111100000000",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000011110000",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000000000000",
          ]
      ];

    var l_45_2 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "001111000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111100",
          ]
      ];

    var l_35_2 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "111100000000",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "001111000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000001110",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000001111",
          ]
      ];

    var l_44_3 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "111100000000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "111100000011",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "001111111111",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "111100000000",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "000011000011",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "110000001111",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000111100",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "111100000000",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000011110000",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000000000000",
          ]
      ];

    var l_45_3 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "001111110000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111100",
          ]
      ];

    var l_35_3 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "111100001100",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "001111000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111110",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000000011",
          ]
      ];

    var l_44_4 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "110000000000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "001100000011",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "001111110011",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "111100000011",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "110011000011",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "110000000011",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000111100",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "111100000011",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000011110000",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000011000000",
          ]
      ];

    var l_45_4 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "001111000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "110000111100",
          ]
      ];

    var l_35_4 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "110000001100",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "000011000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000110000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000000011",
          ]
      ];

    var l_44_5 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "110000110000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "001111000011",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "001111110011",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "111100000000",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "110011000111",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "110011100011",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000111100",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "110000000011",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000111100",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000000000000",
          ]
      ];

    var l_45_5 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000011000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000111100",
          ]
      ];

    var l_35_5 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "111100001100",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "110011000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000000011",
          ]
      ];

    var l_44_6 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "110000110000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "000011000011",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "000000000011",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "110000000000",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "110011000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "110011100000",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000000000",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "000000000011",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000001100",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000011000000",
          ]
      ];

    var l_45_6 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "110000001100",
          ]
      ];

    var l_35_6 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000001100",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "000011000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000011000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "110000000011",
          ]
      ];

    var l_44_7 = Building()
      ..id = "1"
      ..name = "44"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "00"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000",
            Classroom()
              ..id = "02"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000000000",
            Classroom()
              ..id = "03"
              ..name = "201"
              ..capacity = "40"
              ..status = "000000000000",
            Classroom()
              ..id = "04"
              ..name = "202"
              ..capacity = "30"
              ..status = "000000000000",
            Classroom()
              ..id = "05"
              ..name = "301"
              ..capacity = "20"
              ..status = "000011000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "06"
              ..name = "105"
              ..capacity = "20"
              ..status = "000000000000",
            Classroom()
              ..id = "07"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000000000",
            Classroom()
              ..id = "08"
              ..name = "301"
              ..capacity = "20"
              ..status = "000000111111",
          ],
        Area()
          ..area_id = "C"
          ..classrooms = [
            Classroom()
              ..id = "09"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000",
            Classroom()
              ..id = "11"
              ..name = "202"
              ..capacity = "20"
              ..status = "000000000000",
          ]
      ];

    var l_45_7 = Building()
      ..id = "2"
      ..name = "45"
      ..campus = "1"
      ..areas = [
        Area()
          ..area_id = null
          ..classrooms = [
            Classroom()
              ..id = "13"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000",
            Classroom()
              ..id = "14"
              ..name = "103"
              ..capacity = "35"
              ..status = "111100000000",
          ]
      ];

    var l_35_7 = Building()
      ..id = "3"
      ..name = "35"
      ..campus = "2"
      ..areas = [
        Area()
          ..area_id = "A"
          ..classrooms = [
            Classroom()
              ..id = "15"
              ..name = "101"
              ..capacity = "20"
              ..status = "000000000000",
            Classroom()
              ..id = "16"
              ..name = "102"
              ..capacity = "15"
              ..status = "000000000000",
            Classroom()
              ..id = "17"
              ..name = "103"
              ..capacity = "35"
              ..status = "000000000000",
          ],
        Area()
          ..area_id = "B"
          ..classrooms = [
            Classroom()
              ..id = "19"
              ..name = "106"
              ..capacity = "30"
              ..status = "000000000000",
          ]
      ];

    List<Building> d1 = [l_44_1, l_45_1, l_35_1];
    List<Building> d2 = [l_44_2, l_45_2, l_35_2];
    List<Building> d3 = [l_44_3, l_45_3, l_35_3];
    List<Building> d4 = [l_44_4, l_45_4, l_35_4];
    List<Building> d5 = [l_44_5, l_45_5, l_35_5];
    List<Building> d6 = [l_44_6, l_45_6, l_35_6];
    List<Building> d7 = [l_44_7, l_45_7, l_35_7];

    switch (day) {
      case 0:
        return d1;
      case 1:
        return d2;
      case 2:
        return d3;
      case 3:
        return d4;
      case 4:
        return d5;
      case 5:
        return d6;
      case 6:
        return d7;
    }
  }
}
