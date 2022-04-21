// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/edit_detail_page.dart';

void showCourseDialog(BuildContext context, List<Pair<Course, int>> pairs) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromRGBO(255, 255, 255, 0.7),
        builder: (BuildContext context) => CourseDialog(pairs));

class CourseDialog extends Dialog {
  final List<Pair<Course, int>> _pairs;

  CourseDialog(this._pairs);

  final _nameStyle = FontManager.YaQiHei.copyWith(
      fontSize: 20,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);

  final _teacherStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 12, color: Colors.white, decoration: TextDecoration.none);

  final _hintNameStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 10,
      color: Colors.white,
      decoration: TextDecoration.none,
      letterSpacing: 1);

  final _hintValueStyle = FontManager.Montserrat.copyWith(
      fontSize: 9,
      color: Colors.white,
      letterSpacing: 0.5,
      decoration: TextDecoration.none);

  final _width = WePeiYangApp.screenWidth - 120;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 340,
        child: _pairs.length == 1
            ? _getSingleCard(context, _pairs[0])
            : Theme(
                data: ThemeData(accentColor: Colors.white),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    itemCount: _pairs.length,
                    itemBuilder: (context, i) =>
                        _getSingleCard(context, _pairs[i])),
              ),
      ),
    );
  }

  Widget _getSingleCard(BuildContext context, Pair<Course, int> pair) {
    var teacher = '';
    pair.first.teacherList.forEach((str) {
      if (teacher != '') teacher += ', ';
      teacher += str;
    });
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: _width,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/icon_peiyang.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(15),
          color: generateColor(pair.first.name)),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pair.first.name, style: _nameStyle),
                  SizedBox(height: 12),
                  Text(teacher, style: _teacherStyle),
                  Spacer(),
                  _getRow1(pair),
                  SizedBox(height: 12),
                  _getRow2(pair),
                  SizedBox(height: 12),
                  _getRow3(pair),
                ],
              ),
              if (pair.first.type == 1)
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      context.read<EditProvider>().load(pair.first);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ScheduleRouter.editDetail,
                          arguments: EditDetailPageArgs(pair.first.index!,
                              pair.first.name, pair.first.credit));
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Image.asset('assets/images/schedule/card_edit.png',
                          height: 16, width: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRow1(Pair<Course, int> pair) => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text('ID', style: _hintNameStyle),
              ),
              SizedBox(height: 3),
              Text(pair.first.courseId, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.class_id, style: _hintNameStyle),
              SizedBox(height: 3),
              Text(pair.first.classId, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.campus,
                  style: _hintNameStyle.copyWith(letterSpacing: 3)),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 1),
                child: Text(
                    '${pair.first.campus}${pair.first.campus.isNotEmpty ? "校区" : ""}',
                    style: _hintValueStyle.copyWith(fontSize: 10)),
              )
            ],
          )
        ],
      );

  Widget _getRow2(Pair<Course, int> pair) => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.arrange_room, style: _hintNameStyle),
              SizedBox(height: 3),
              Text(replaceBuildingWord(pair.arrange.location),
                  style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.arrange_week, style: _hintNameStyle),
              SizedBox(height: 3),
              Text(pair.first.weeks, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.credit,
                  style: _hintNameStyle.copyWith(letterSpacing: 3)),
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 2),
                child: Text(pair.first.credit, style: _hintValueStyle),
              )
            ],
          )
        ],
      );

  Widget _getRow3(Pair<Course, int> pair) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.current.time,
              style: _hintNameStyle.copyWith(letterSpacing: 3)),
          SizedBox(height: 3),
          Text(getCourseTime(pair.arrange.unitList), style: _hintValueStyle)
        ],
      );
}
