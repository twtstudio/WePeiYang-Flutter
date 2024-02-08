import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  get _color => WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CommonPreferences.firstClassesDialog.value) {
        CommonPreferences.firstClassesDialog.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }

      // 绑定办公网判断
      if (!CommonPreferences.isBindTju.value) {
        Navigator.pushNamed(context, AuthRouter.tjuBind);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      elevation: 0,
      leading: WButton(
          child: Icon(Icons.arrow_back, color: _color, size: 32.r),
          onPressed: () => Navigator.pop(context)),
      actions: [
        IconButton(
          icon: Icon(Icons.autorenew, color: _color, size: 28.r),
          onPressed: () {
            context.read<ExamProvider>().refreshExamByBackend(context);
          },
        ),
        SizedBox(width: 10.w),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Consumer<ExamProvider>(
          builder: (context, provider, _) {
            List<Widget> unfinished = provider.unfinished.isEmpty
                ? [
                    Center(
                        child: Text('没有未完成的考试哦',
                            style:
                                TextUtil.base.w300.unlabeled(context).sp(12)))
                  ]
                : provider.unfinished
                    .map((e) => examCard(context, e, false))
                    .toList();
            List<Widget> finished = provider.finished.isEmpty
                ? [
                    Center(
                        child: Text('没有已完成的考试哦',
                            style:
                                TextUtil.base.w300.unlabeled(context).sp(12)))
                  ]
                : provider.finished
                    .map((e) => examCard(context, e, true))
                    .toList();
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(height: 10.h),
                Text('未完成',
                    style: TextUtil.base.bold.sp(16).customColor(_color)),
                SizedBox(height: 5.h),
                ...unfinished,
                SizedBox(height: 15.h),
                Text('已完成',
                    style: TextUtil.base.bold.sp(16).customColor(_color)),
                SizedBox(height: 5.h),
                ...finished,
              ],
            );
          },
        ),
      ),
    );
  }

  List<Color> get _scheduleColor => [
        WpyTheme.of(context).get(WpyColorKey.examAColor), // #727588
        WpyTheme.of(context).get(WpyColorKey.examBColor), // #8F92A5
        WpyTheme.of(context).get(WpyColorKey.examCColor), // #7A778A
        WpyTheme.of(context).get(WpyColorKey.examDColor), // #8E7A96
        WpyTheme.of(context).get(WpyColorKey.examEColor), // #8286A1
      ];

  Widget examCard(BuildContext context, Exam exam, bool finished) {
    int code = exam.name.hashCode + DateTime.now().day;

    var unfinishedColor = _scheduleColor[code % _scheduleColor.length];
    var name = exam.name;
    if (name.length >= 10) name = name.substring(0, 10) + '...';
    String remain = '';
    if (finished) {
      remain = '';
    } else if (exam.date == '时间未安排') {
      remain = 'Unknown';
    } else {
      var now = DateTime.now();
      var realNow = DateTime(now.year, now.month, now.day);
      var target = DateTime.parse(exam.date);
      var diff = target.difference(realNow).inDays;
      remain = (diff == 0) ? 'today' : '${diff}days';
    }
    var seat = exam.seat;
    if (seat != '地点未安排') seat = '座位' + seat;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4.h, 14.w, 4.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          decoration: BoxDecoration(
            color: finished
                ? WpyTheme.of(context).get(WpyColorKey.reverseTextColor)
                : unfinishedColor,
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10.r),
            splashFactory: InkRipple.splashFactory,
            child: Stack(
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                      color: finished
                          ? WpyTheme.of(context).get(WpyColorKey.oldHintColor)
                          : WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextUtil.base.sp(20)),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Spacer(),
                            Text(exam.arrange,
                                style: TextUtil.base.w500.sp(18)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 17.r,
                                color: finished
                                    ? WpyTheme.of(context)
                                        .get(WpyColorKey.oldHintColor)
                                    : WpyTheme.of(context).get(
                                        WpyColorKey.primaryBackgroundColor)),
                            SizedBox(width: 3.w),
                            Text('${exam.location}-$seat',
                                overflow: TextOverflow.ellipsis,
                                style: TextUtil.base.w300.sp(14)),
                            Spacer(),
                            Text(exam.date, style: TextUtil.base.w500.sp(14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 1.h,
                  child: Text(
                    remain,
                    style: TextUtil.base.Fourche.bold.italic
                        .examRemain(context)
                        .h(0)
                        .sp(55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
