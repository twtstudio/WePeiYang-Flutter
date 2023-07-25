import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/edit_detail_page.dart';

void showCourseDialog(BuildContext context, List<Pair<Course, int>> pairs) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (BuildContext context) => CourseDialog(pairs));

class CourseDialog extends Dialog {
  final List<Pair<Course, int>> _pairs;

  CourseDialog(this._pairs);

  final _nameStyle = TextUtil.base.bold.white.noLine.sp(20);
  final _teacherStyle = TextUtil.base.regular.white.noLine.sp(12);
  final _hintNameStyle =
      TextUtil.base.regular.white.noLine.sp(10).space(letterSpacing: 1);
  final _hintValueStyle =
      TextUtil.base.Swis.white.noLine.sp(9).space(letterSpacing: 0.5);
  final _width = 1.sw - 120.w;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 330.h,
        child: _pairs.length == 1
            ? _getSingleCard(context, _pairs[0])
            : Theme(
                data: Theme.of(context)
                    .copyWith(secondaryHeaderColor: Colors.white),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
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
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      width: _width,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/icon_peiyang.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(44, 126, 223, 1),
              Color.fromRGBO(166, 207, 255, 1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
            ),
            BoxShadow(
              blurRadius: 10,
              color: Colors.white10,
            ),
          ]),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 35.h, 20.w, 35.h),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pair.first.name, style: _nameStyle),
                  SizedBox(height: 12.h),
                  Text(teacher, style: _teacherStyle),
                  Spacer(),
                  _getRow1(pair),
                  SizedBox(height: 12.h),
                  _getRow2(pair),
                  SizedBox(height: 12.h),
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
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
                      child: Image.asset('assets/images/schedule/card_edit.png',
                          height: 16.h, width: 16.w),
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
              SizedBox(height: 3.h),
              Text(pair.first.courseId, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.class_id, style: _hintNameStyle),
              SizedBox(height: 3.h),
              Text(pair.first.classId, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18.w),
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
              SizedBox(height: 3.h),
              Text(replaceBuildingWord(pair.arrange.location),
                  style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 18.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.arrange_week, style: _hintNameStyle),
              SizedBox(height: 3.h),
              Text(pair.first.weeks, style: _hintValueStyle)
            ],
          ),
          SizedBox(width: 28.w),
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
          SizedBox(height: 3.h),
          Text(getCourseTime(pair.arrange.unitList), style: _hintValueStyle)
        ],
      );
}
