import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/schedule_background.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/view/week_select_widget.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/util/toast_provider.dart';
import '../../commons/widgets/w_button.dart';

/// 课表总页面
class CoursePage extends StatefulWidget {
  final List<Pair<Course, int>> pairs;

  const CoursePage(this.pairs);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  /// 进入课程表页面后重设选中周并自动刷新自定义课程
  _CoursePageState() {
    var provider =
        WePeiYangApp.navigatorState.currentContext!.read<CourseProvider>();
    provider.quietResetWeek();
    provider.refreshCustomCourse();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 初次使用课表时展示办公网dialog
      if (CommonPreferences.firstClassesDialog.value) {
        CommonPreferences.firstClassesDialog.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }
      if (widget.pairs.isNotEmpty && widget.pairs.isNotEmpty) {
        showCourseDialog(context, widget.pairs);
      }

      // 绑定
      if (!CommonPreferences.isBindTju.value) {
        Navigator.pushNamed(context, AuthRouter.tjuBind);
      }
    });
  }

  ///生成当前显示页面课程表截图
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> takeScreenshot() async {
    ToastProvider.running("生成截图中");
    screenshotController.captureAsUiImage(pixelRatio: 4.0).then((image) async {
      await screenshotController
          .captureFromLongWidget(Stack(
        children: [
          Container(
            width: image?.width.toDouble(),
            height: image?.height.toDouble(),
            child: CustomPaint(
              painter: ScheduleBackgroundPrinter(
                primaryActionColor:
                    WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                primaryLightActionColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryLightActionColor),
                primaryBackgroundColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                primaryLighterActionColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryLighterActionColor),
                primaryLightestActionColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryLightestActionColor),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.r),
            child: CustomPaint(
              painter: CustomImagePainter(image!),
            ),
          )
        ],
      ))
          .then((value) async {
        final fullPath = await saveImageToPath(value);
        GallerySaver.saveImage(fullPath!, albumName: "微北洋");
        ToastProvider.success("图片保存成功");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScheduleBackground(),
        // Image.asset(
        //   "assets/images/schedule/home_bg.jpg",
        //   width: 1.sw,
        //   height: 1.sh,
        //   fit: BoxFit.cover,
        // ),
        Scaffold(
          appBar: _CourseAppBar(
            takeScreenshot: takeScreenshot,
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  _TitleWidget(),
                  WeekSelectWidget(),
                  Column(
                    children: [
                      CourseDetailWidget(),
                      _HoursCounterWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 课表页默认AppBar
class _CourseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function() takeScreenshot;

  _CourseAppBar({required this.takeScreenshot});

  @override
  Widget build(BuildContext context) {
    var leading = Align(
      alignment: Alignment.centerRight,
      child: WButton(
        onPressed: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.fromLTRB(0, 8.h, 8.w, 8.h),
          child: Image.asset(
            'assets/images/schedule/back.png',
            height: 18.r,
            width: 18.r,
            color: WpyTheme.of(context).get(WpyColorKey.brightTextColor),
          ),
        ),
      ),
    );

    var actions = [
      WButton(
        onPressed: () {
          if (CommonPreferences.tjuuname.value == '') {
            Navigator.pushNamed(context, AuthRouter.tjuBind);
          } else {
            context.read<CourseProvider>().refreshCourseByBackend(context);
          }
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            'assets/images/schedule/refresh.png',
            height: 20.r,
            width: 20.r,
          ),
        ),
      ),
      WButton(
        onPressed: () {
          Navigator.pushNamed(context, ScheduleRouter.customCourse);
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            'assets/images/schedule/list.png',
            height: 20.r,
            width: 20.r,
          ),
        ),
      ),
      WButton(
        onPressed: () => takeScreenshot(),
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Icon(
            Icons.camera_alt_rounded,
            size: 20.r,
            color: WpyTheme.of(context)
                .get(WpyColorKey.brightTextColor)
                .withOpacity(0.7),
          ),
        ),
      ),
      SizedBox(width: 5.w),
    ];

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      leadingWidth: 40.w,
      actions: actions,
      title: Text(
          'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
          style: TextUtil.base.bright(context).w900.sp(18)),
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 课表页标题栏
class _TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 5.h),
      child: Row(
        children: [
          Text('Schedule', style: TextUtil.base.w900.bright(context).sp(18)),
          Padding(
            padding: EdgeInsets.only(left: 8.w, top: 4.h),
            child: Builder(builder: (context) {
              var currentWeek =
                  context.select<CourseProvider, int>((p) => p.currentWeek);
              return Text('WEEK $currentWeek',
                  style: TextUtil.base.Swis.bold.sp(12).bright(context));
            }),
          ),
          Builder(builder: (context) {
            var provider = context.watch<CourseDisplayProvider>();
            return WButton(
                onPressed: () {
                  provider.shrink = !provider.shrink;
                },
                child: Container(
                  decoration: BoxDecoration(),
                  padding: EdgeInsets.fromLTRB(8.w, 5.h, 8.w, 0),
                  child: Image.asset(
                    provider.shrink
                        ? 'assets/images/schedule/up.png'
                        : 'assets/images/schedule/down.png',
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.primaryBackgroundColor),
                    height: 18.r,
                    width: 18.r,
                  ),
                ));
          })
        ],
      ),
    );
  }
}

/// 课表页底部学时统计栏
class _HoursCounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<CourseProvider>();
    if (provider.schoolCourses.length == 0) return Container();
    int currentHours = getCurrentHours(
        provider.currentWeek, DateTime.now().weekday, provider.schoolCourses);
    int totalHours = getTotalHours(provider.schoolCourses);
    double totalWidth = 1.sw - 2 * 15.w;
    double leftWidth = totalWidth * currentHours / totalHours;
    if (leftWidth > totalWidth) leftWidth = totalWidth;

    /// 如果学期还没开始，则不显示学时
    if (isBeforeTermStart) leftWidth = 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 8.h),
              alignment: Alignment.centerLeft,
              child: Text("Total Class Hours: $totalHours",
                  style: TextUtil.base.Swis.bold.bright(context).sp(12))),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12.h,
                width: totalWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.iconAnimationStartColor)),
              ),
              if (!leftWidth.isNaN) // Avoid No Class in a semester
                Container(
                  height: 8.h,
                  width: leftWidth,
                  margin: EdgeInsets.only(left: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    gradient: LinearGradient(
                      colors: [
                        WpyTheme.of(context).get(WpyColorKey.brightTextColor),
                        WpyTheme.of(context)
                            .get(WpyColorKey.backgroundGradientEndColor),
                      ],
                    ),
                  ),
                )
            ],
          ),
          SizedBox(height: 45.h)
        ],
      ),
    );
  }
}

class CustomImagePainter extends CustomPainter {
  final ui.Image image;

  CustomImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      this != oldDelegate;
}

Future<String?> saveImageToPath(Uint8List imageData) async {
  try {
    final directory = await getTemporaryDirectory();
    final file = File(
        "${directory.path}/wpy_screenshot_${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(imageData);
    return file.path;
  } catch (e) {
    return null;
  }
}
