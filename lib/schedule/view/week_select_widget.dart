import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import '../../commons/themes/color_util.dart';
import '../../commons/themes/wpy_theme.dart';

/// 用这两个变量绘制点阵图
const double _cubeSideLength = 6;
const double _spacingLength = 2;

/// 点阵图的宽高
double get _canvasWidth {
  var count = CommonPreferences.dayNumber.value;
  return _cubeSideLength * count + _spacingLength * (count - 1);
}

const double _canvasHeight = _cubeSideLength * 5 + _spacingLength * 4;

/// 星期切换栏
class WeekSelectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var listView = Builder(
      builder: (context) {
        var provider = context.watch<CourseProvider>();
        var current = provider.currentWeek;
        if (current == 1) current++;

        double offset = 0.25.sw - _canvasWidth.w - 25.w;
        if (offset < 0) offset = 0;
        return ListView.builder(
            itemCount: provider.weekCount,
            scrollDirection: Axis.horizontal,
            controller: ScrollController(
                initialScrollOffset:
                    (current - 2) * (_canvasWidth + 25 + offset)),
            itemBuilder: (context, i) {
              /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
              return Padding(
                padding: EdgeInsets.only(left: offset),
                child: Stack(
                  children: [
                    _getContent(provider, i),

                    /// 波纹效果蒙版，加上material使inkwell能在list中显示出来
                    SizedBox(
                      height: _canvasHeight + 20.w,
                      width: _canvasWidth + 25.w,
                      child: Material(
                        color: ColorUtil.transparent,
                        child: InkWell(
                          radius: 5000,
                          borderRadius: BorderRadius.circular(5.r),
                          splashColor: ColorUtil.grey246Opacity05,
                          highlightColor: ColorUtil.transparent,
                          onTap: () => provider.selectedWeek = i + 1,
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      },
    );

    return Theme(
      data: Theme.of(context).copyWith(
          secondaryHeaderColor:
              WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)),
      child: Builder(
        builder: (context) {
          var shrink =
              context.select<CourseDisplayProvider, bool>((p) => p.shrink);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: shrink ? 0 : 90.h,
            child: shrink ? Container() : listView,
          );
        },
      ),
    );
  }

  Widget _getContent(CourseProvider provider, int i) {
    return Column(
      children: [
        Container(
          height: _canvasHeight + 20.h,
          width: _canvasWidth + 25.w,
          alignment: Alignment.center,
          child: Builder(builder: (context) {
            return CustomPaint(
              painter: _WeekSelectPainter(
                  getBoolMatrix(
                      i + 1, provider.weekCount, provider.totalCourses),
                  i + 1 == provider.selectedWeek,
                  context: context),
              size: Size(_canvasWidth, _canvasHeight),
            );
          }),
        ),
        SizedBox(height: 3.h),
        Builder(builder: (context) {
          return Text('WEEK ${i + 1}',
              style: TextUtil.base.Swis.w900.sp(10).customColor(
                  (provider.selectedWeek == i + 1)
                      ? WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)
                      : ColorUtil.whiteOpacity04));
        })
      ],
    );
  }
}

class _WeekSelectPainter extends CustomPainter {
  final List<List<bool>> _list;
  final bool _selected;

  final BuildContext context;

  _WeekSelectPainter(
    this._list,
    this._selected, {
    required this.context,
  }) {
    if (!_selected) {
      _cubePaint.color = _cubePaint.color.withOpacity(0.4);
      _spacePaint.color = _spacePaint.color.withOpacity(0.4);
    }
  }

  /// 深色cube，代表该点有课
  final Paint _cubePaint = Paint()
    ..color = ColorUtil.yellow255
    ..style = PaintingStyle.fill;

  /// 白色cube，代表该点没课
  late final Paint _spacePaint = Paint()
    ..color = WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (var j = 0; j < _list.length; j++) {
      for (var k = 0; k < _list[j].length; k++) {
        var centerX =
            k * (_cubeSideLength + _spacingLength) + _cubeSideLength / 2;
        var centerY =
            j * (_cubeSideLength + _spacingLength) + _cubeSideLength / 2;
        Rect rect = Rect.fromCircle(
            center: Offset(centerX, centerY), radius: _cubeSideLength / 2);
        RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(2));

        if (_list[j][k]) {
          canvas.drawRRect(rRect, _cubePaint);
        } else {
          canvas.drawRRect(rRect, _spacePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
