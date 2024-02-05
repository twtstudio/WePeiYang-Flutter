import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/edit_detail_page.dart';

import '../../commons/themes/color_util.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

void showCourseDialog(BuildContext context, List<Pair<Course, int>> pairs) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: ColorUtil.dislikeSecondary,
        builder: (BuildContext context) => CourseDialog(pairs));

class CourseDialog extends Dialog {
  final List<Pair<Course, int>> _pairs;

  CourseDialog(this._pairs);

  _nameStyle(context) => TextUtil.base.bold.reverse(context).noLine.sp(20);

  _teacherStyle(context) =>
      TextUtil.base.regular.reverse(context).noLine.sp(12);

  _hintNameStyle(context) => TextUtil.base.regular
      .reverse(context)
      .noLine
      .sp(10)
      .space(letterSpacing: 1);

  _hintValueStyle(context) => TextUtil.base.Swis
      .reverse(context)
      .noLine
      .sp(9)
      .space(letterSpacing: 0.5);
  final _width = 1.sw - 120.w;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 330.h,
        child: _pairs.length == 1
            ? _getSingleCard(context, _pairs[0])
            : Theme(
                data: Theme.of(context).copyWith(
                    secondaryHeaderColor:
                        WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)),
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
          gradient: ColorUtil.primaryGradientAllScreen,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 10,
              color: ColorUtil.blackOpacity005,
            ),
            BoxShadow(
              blurRadius: 10,
              color: ColorUtil.white10,
            ),
          ]),
      child: WButton(
        onPressed: () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 35.h, 20.w, 35.h),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pair.first.name, style: _nameStyle(context)),
                  SizedBox(height: 12.h),
                  Text(teacher, style: _teacherStyle(context)),
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
                  child: WButton(
                    onPressed: () {
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

  Widget _getRow1(Pair<Course, int> pair) => Builder(
      builder: (context) => Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Text('ID', style: _hintNameStyle(context)),
                  ),
                  SizedBox(height: 3.h),
                  Text(pair.first.courseId, style: _hintValueStyle(context))
                ],
              ),
              SizedBox(width: 18.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.class_id, style: _hintNameStyle(context)),
                  SizedBox(height: 3.h),
                  Text(pair.first.classId, style: _hintValueStyle(context))
                ],
              ),
              SizedBox(width: 18.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.campus,
                      style:
                          _hintNameStyle(context).copyWith(letterSpacing: 3)),
                  Padding(
                    padding: const EdgeInsets.only(top: 1, left: 1),
                    child: Text(
                        '${pair.first.campus}${pair.first.campus.isNotEmpty ? "校区" : ""}',
                        style: _hintValueStyle(context).copyWith(fontSize: 10)),
                  )
                ],
              )
            ],
          ));

  Widget _getRow2(Pair<Course, int> pair) => Builder(
      builder: (context) => Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.arrange_room, style: _hintNameStyle(context)),
                  SizedBox(height: 3.h),
                  Text(replaceBuildingWord(pair.arrange.location),
                      style: _hintValueStyle(context))
                ],
              ),
              SizedBox(width: 18.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.arrange_week, style: _hintNameStyle(context)),
                  SizedBox(height: 3.h),
                  Text(pair.first.weeks, style: _hintValueStyle(context))
                ],
              ),
              SizedBox(width: 28.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.credit,
                      style:
                          _hintNameStyle(context).copyWith(letterSpacing: 3)),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 2),
                    child: Text(pair.first.credit,
                        style: _hintValueStyle(context)),
                  )
                ],
              )
            ],
          ));

  Widget _getRow3(Pair<Course, int> pair) => Builder(
      builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.time,
                  style: _hintNameStyle(context).copyWith(letterSpacing: 3)),
              SizedBox(height: 3.h),
              Text(getCourseTime(pair.arrange.unitList),
                  style: _hintValueStyle(context))
            ],
          ));
}
