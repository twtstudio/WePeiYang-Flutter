import 'dart:math' show min;

import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show TextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';

import '../../commons/widgets/w_button.dart';

final _ITEM_HEIGHT = 48.h;

class TimeFrameWidget extends StatelessWidget {
  final int index;
  final bool canDelete;
  final ScrollController parentController;
  final Future<void> Function()? delCb;

  TimeFrameWidget(this.index, this.canDelete, this.parentController,
      {this.delCb, Key? key})
      : super(key: key);

  static const _weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  Widget build(BuildContext context) {
    var pvd = context.read<EditProvider>();
    var unitList = pvd.arrangeList[index].unitList;
    var unitText = unitList.every((e) => e == 0)
        ? '点击选择'
        : '第${unitList.first}-${unitList.last}节';
    var weekList = pvd.arrangeList[index].weekList;
    var weekText =
        weekList.isEmpty ? '点击选择' : '第${weekList.first}-${weekList.last}周';
    var weekType = '';
    if (weekList.isEmpty || weekList.length == 1) {
      // pass
    } else if (weekList[1] - weekList[0] == 1) {
      weekType = '每周';
    } else if (weekList.first.isOdd) {
      weekType = '单周';
    } else if (weekList.first.isEven) {
      weekType = '双周';
    }

    var weekDay = weekList.isEmpty
        ? ''
        : _weekDays[pvd.arrangeList[index].weekday - 1] + '   ';

    return CardWidget(
      child: Column(
        children: [
          Row(
            children: [
              Text('time frame ${index + 1}',
                  style: TextUtil.base.Swis.medium.black2A.sp(16)),
              Spacer(),
              // canDelete为false时改为白色是为了不改变row的高度
              WButton(
                onPressed: () async {
                  if (canDelete) {
                    if (delCb != null) {
                      await delCb!();
                    }
                    pvd.remove(index);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(),
                  child: Icon(Icons.cancel,
                      color: canDelete
                          ? ColorUtil.blue2CColor
                          : ColorUtil.whiteFFColor),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('周数：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
              Expanded(
                child: Builder(builder: (context) {
                  return WButton(
                    onPressed: () {
                      // 先找到点击位置的y坐标（记为top）
                      var renderBox = context.findRenderObject() as RenderBox;
                      var top = renderBox.localToGlobal(Offset.zero).dy;
                      // 弹出的选择框高度为220，如果超出屏幕高度，则让外部ListView向上jump
                      if (top + 220 > 1.sh) {
                        // 计算jump的目标位置
                        var jumpPos = min(parentController.offset + 220,
                            parentController.position.maxScrollExtent);
                        // 计算jump了多少距离
                        var jumpDis = jumpPos - parentController.offset;
                        top -= jumpDis;
                        // 额外减去5作为距离屏幕底部的padding
                        top -= 5;
                        parentController.jumpTo(jumpPos);
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      pvd.initWeekList(index);
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: ColorUtil.whiteOpacity01,
                        builder: (_) => WeekPicker(
                            index,
                            top,
                            pvd.arrangeList[index].weekday,
                            pvd.arrangeList[index].weekList),
                      ).then((_) => pvd.notify());
                    },
                    child: Container(
                      height: _ITEM_HEIGHT,
                      alignment: Alignment.centerRight,
                      decoration: const BoxDecoration(),
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text('${weekType}${weekDay}${weekText}',
                          style: TextUtil.base.PingFangSC.medium.greyA8.sp(13)),
                    ),
                  );
                }),
              ),
            ],
          ),
          Row(
            children: [
              Text('节数：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
              Expanded(
                child: Builder(builder: (context) {
                  return WButton(
                    onPressed: () {
                      var renderBox = context.findRenderObject() as RenderBox;
                      var top = renderBox.localToGlobal(Offset.zero).dy;
                      if (top + 150 > 1.sh) {
                        var jumpPos = min(parentController.offset + 150,
                            parentController.position.maxScrollExtent);
                        var jumpDis = jumpPos - parentController.offset;
                        top -= jumpDis;
                        parentController.jumpTo(jumpPos);
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      pvd.initUnitList(index);
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: ColorUtil.whiteOpacity01,
                        builder: (_) => UnitPicker(
                            index, top, pvd.arrangeList[index].unitList),
                      ).then((_) => pvd.notify());
                    },
                    child: Container(
                      height: _ITEM_HEIGHT,
                      alignment: Alignment.centerRight,
                      decoration: const BoxDecoration(),
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(unitText,
                          style: TextUtil.base.PingFangSC.medium.greyA8.sp(13)),
                    ),
                  );
                }),
              ),
            ],
          ),
          InputWidget(
            onChanged: (text) => pvd.arrangeList[index].location = text,
            title: '地点',
            hintText: '请输入地点（选填）',
            initText: pvd.arrangeList[index].location == ''
                ? null
                : pvd.arrangeList[index].location,
            inputFormatter: [LengthLimitingTextInputFormatter(10)],
          ),
          InputWidget(
            onChanged: (text) => pvd.arrangeList[index].teacherList = [text],
            title: '教师',
            hintText: '请输入教师名（选填）',
            initText: pvd.arrangeList[index].teacherList.isEmpty
                ? null
                : pvd.arrangeList[index].teacherList.first,
            inputFormatter: [LengthLimitingTextInputFormatter(10)],
          ),
        ],
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  final Key? key;
  final ValueChanged<String> onChanged;
  final String? title;
  final String hintText;
  final String? initText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;

  InputWidget(
      {required this.onChanged,
      this.title,
      required this.hintText,
      this.initText,
      this.keyboardType,
      this.inputFormatter,
      this.focusNode,
      this.key})
      : super(key: key) {
    if (initText != null) {
      _controller = TextEditingController.fromValue(TextEditingValue(
        text: initText!,
        selection:
            TextSelection.fromPosition(TextPosition(offset: initText!.length)),
      ));
    } else {
      _controller = null;
    }
  }

  late final TextEditingController? _controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ITEM_HEIGHT,
      child: Row(
        children: [
          if (title != null)
            Text('$title：',
                style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: _controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              inputFormatters: inputFormatter,
              textAlign: TextAlign.end,
              style: TextUtil.base.PingFangSC.medium.black2A.sp(16),
              cursorColor: ColorUtil.blue2CColor,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextUtil.base.PingFangSC.medium.greyA8.sp(13),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;

  CardWidget({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          color: ColorUtil.whiteFFColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 10,
              color: ColorUtil.blackOpacity006,
            ),
          ],
        ),
        // 这里如果用Ink，会导致这个组件在上滑被其他组件遮挡时仍然可见，很迷
        child: Material(
          color: ColorUtil.transparent,
          child: InkWell(
            onTap: onTap,
            splashFactory: InkRipple.splashFactory,
            borderRadius: BorderRadius.circular(10.r),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.r, 10.r, 12.r, 10.r),
              child: Center(child: child),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.fromLTRB(12.r, 10.r, 12.r, 10.r),
      decoration: BoxDecoration(
        color: ColorUtil.whiteFFColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 10,
            color: ColorUtil.blackOpacity008,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class UnitPicker extends Dialog {
  final int _index;
  final double _top;
  final List<FixedExtentScrollController> _controllers;

  UnitPicker(this._index, this._top, List<int> unitInit)
      : _controllers = List.generate(2,
            (i) => FixedExtentScrollController(initialItem: unitInit[i] - 1));

  static const _text = ['至', '节'];

  final _textStyle =
      TextUtil.base.PingFangSC.w900.black00.space(letterSpacing: 1);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int section = 0; section < 2; section++) {
      children.add(
        Expanded(
          flex: 1,
          child: CupertinoPicker.builder(
            scrollController: _controllers[section],
            diameterRatio: 1.5,
            squeeze: 1.45,
            selectionOverlay: Container(color: ColorUtil.transparent),
            itemExtent: 40,
            childCount: 12,
            onSelectedItemChanged: (row) {
              if (section == 0) {
                if (_controllers[0].selectedItem >
                    _controllers[1].selectedItem) {
                  _controllers[1].jumpToItem(_controllers[0].selectedItem);
                }
              } else {
                if (_controllers[1].selectedItem <
                    _controllers[0].selectedItem) {
                  _controllers[0].jumpToItem(_controllers[1].selectedItem);
                }
              }
              context
                  .read<EditProvider>()
                  .arrangeList[_index]
                  .unitList[section] = row + 1;
            },
            itemBuilder: (context, row) {
              var str = '${row + 1}';
              if (str.length == 1) str = '0$str';
              return Center(child: Text(str, style: _textStyle.sp(18)));
            },
          ),
        ),
      );
      children.add(Text(_text[section], style: _textStyle.sp(15)));
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 0.66.sw,
        height: 150.h,
        margin: EdgeInsets.only(top: _top + 10.w),
        child: Material(
          color: ColorUtil.whiteFFColor,
          borderRadius: BorderRadius.circular(15.r),
          elevation: 5,
          child: Center(
            child: Container(
              width: 0.5.sw,
              padding: EdgeInsets.all(5.r),
              margin: EdgeInsets.only(right: 0.05.sw),
              child: Row(children: children),
            ),
          ),
        ),
      ),
    );
  }
}

class WeekPicker extends Dialog {
  final int _index;
  final double _top;
  final ValueNotifier<String> _selectedWeekType;
  final FixedExtentScrollController _weekdayController;
  final List<FixedExtentScrollController> _controllers;

  WeekPicker(this._index, this._top, int _weekdayInit, List<int> weekInit)
      : _selectedWeekType = ValueNotifier(_weekTypeInit(weekInit)),
        _weekdayController =
            FixedExtentScrollController(initialItem: _weekdayInit - 1),
        _controllers = List.generate(2, (i) {
          var item = (i == 0) ? weekInit.first - 1 : weekInit.last - 1;
          return FixedExtentScrollController(initialItem: item);
        });

  static const _text = ['至', '周'];

  static const _weekdays = [
    'Mon.',
    'Tue.',
    'Wed.',
    'Thu.',
    'Fri.',
    'Sat.',
    'Sun.'
  ];

  static const _weekTypes = ['每周', '单周', '双周'];

  final _textStyle =
      TextUtil.base.PingFangSC.w900.black00.space(letterSpacing: 1);

  static String _weekTypeInit(List<int> weekInit) {
    if (weekInit.every((e) => e == 1)) return '每周';
    var odd = weekInit.any((e) => e.isOdd);
    var even = weekInit.any((e) => e.isEven);
    if (odd && !even) return '单周';
    if (even && !odd) return '双周';
    return '每周';
  }

  void _save(BuildContext context) {
    int start = _controllers[0].selectedItem + 1;
    int end = _controllers[1].selectedItem + 1;
    String type = _selectedWeekType.value;

    var weekList = <int>[];
    if (start == end) {
      weekList = [start];
    } else if (type == '每周') {
      for (int i = start; i <= end; i++) {
        weekList.add(i);
      }
    } else if (type == '单周') {
      for (int i = start; i <= end; i++) {
        if (i % 2 == 1) weekList.add(i);
      }
    } else if (type == '双周') {
      for (int i = start; i <= end; i++) {
        if (i % 2 == 0) weekList.add(i);
      }
    }

    context.read<EditProvider>().arrangeList[_index].weekList = weekList;
  }

  @override
  Widget build(BuildContext context) {
    var pvd = context.read<EditProvider>();
    var weekCount = context.read<CourseProvider>().weekCount;
    List<Widget> children = [
      Expanded(
        flex: 1,
        child: CupertinoPicker.builder(
          scrollController: _weekdayController,
          diameterRatio: 1.5,
          squeeze: 1.45,
          selectionOverlay: Container(color: ColorUtil.transparent),
          itemExtent: 40,
          childCount: 7,
          onSelectedItemChanged: (row) {
            pvd.arrangeList[_index].weekday = row + 1;
          },
          itemBuilder: (context, row) =>
              Center(child: Text(_weekdays[row], style: _textStyle.sp(18))),
        ),
      ),
    ];

    for (int section = 0; section < 2; section++) {
      children.add(
        Expanded(
          flex: 1,
          child: CupertinoPicker.builder(
            scrollController: _controllers[section],
            diameterRatio: 1.5,
            squeeze: 1.45,
            selectionOverlay: Container(color: ColorUtil.transparent),
            itemExtent: 40,
            childCount: weekCount,
            onSelectedItemChanged: (row) {
              if (section == 0) {
                if (_controllers[0].selectedItem >
                    _controllers[1].selectedItem) {
                  _controllers[1].jumpToItem(_controllers[0].selectedItem);
                }
              } else {
                if (_controllers[1].selectedItem <
                    _controllers[0].selectedItem) {
                  _controllers[0].jumpToItem(_controllers[1].selectedItem);
                }
              }
              _save(context);
            },
            itemBuilder: (context, row) {
              var str = '${row + 1}';
              if (str.length == 1) str = '0$str';
              return Center(child: Text(str, style: _textStyle.sp(18)));
            },
          ),
        ),
      );
      children.add(Text(_text[section], style: _textStyle.sp(15)));
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 0.8.sw,
        height: 220.h,
        margin: EdgeInsets.only(top: _top + 10.w),
        child: Material(
          color: ColorUtil.whiteFFColor,
          borderRadius: BorderRadius.circular(15.r),
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 150.h,
                width: 0.65.sw,
                padding: EdgeInsets.all(10.r),
                margin: EdgeInsets.only(right: 0.05.sw),
                child: Row(children: children),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(3, (index) {
                    return ValueListenableBuilder(
                      valueListenable: _selectedWeekType,
                      builder: (context, String type, _) {
                        return ElevatedButton(
                          onPressed: () {
                            _selectedWeekType.value = _weekTypes[index];
                            _save(context);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: index == _weekTypes.indexOf(type)
                                ? ColorUtil.blue2CColor
                                : ColorUtil.whiteF8Color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(_weekTypes[index],
                              style: TextUtil.base.PingFangSC.regular
                                  .sp(12)
                                  .customColor(index == _weekTypes.indexOf(type)
                                      ? ColorUtil.whiteFFColor
                                      : ColorUtil.greyCAColor)),
                        );
                      },
                    );
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
