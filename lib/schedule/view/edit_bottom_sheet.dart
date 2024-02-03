import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/network/custom_course_service.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';

import '../../commons/widgets/w_button.dart';

class EditBottomSheet extends StatefulWidget {
  final String name;
  final String credit;

  EditBottomSheet(this.name, this.credit);

  @override
  _EditBottomSheetState createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
  final _scrollController = ScrollController();
  final _inputSerial = ValueNotifier<bool>(false);
  final _focusNode = FocusNode();
  var _needFocus = false; // 防止弹出输入框时rebuild，导致多次请求focus

  var name = '';
  var credit = '';
  var serial = '';

  @override
  void initState() {
    super.initState();
    name = widget.name;
    credit = widget.credit;
    _inputSerial.addListener(() {
      _needFocus = _inputSerial.value;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _check(BuildContext context) {
    if (name.isEmpty) {
      ToastProvider.error('请填写课程名称');
      return false;
    }
    var pvd = context.read<EditProvider>();
    int frameCheck = pvd.check();
    if (frameCheck != -1) {
      ToastProvider.error('time frame ${frameCheck + 1} 信息不完整');
      return false;
    }
    return true;
  }

  void _saveAndQuit(BuildContext context) {
    if (!_check(context)) return;

    int start = 100;
    int end = 0;
    var teacherSet = Set<String>();

    var pvd = context.read<EditProvider>();
    pvd.arrangeList.forEach((arrange) {
      if (arrange.weekList.first <= start) start = arrange.weekList.first;
      if (arrange.weekList.last >= end) end = arrange.weekList.last;
      if (arrange.teacherList.isNotEmpty) {
        teacherSet.add(arrange.teacherList.first);
      }
    });

    context.read<CourseProvider>().addCustomCourse(Course.custom(
        name, credit, '$start-$end', teacherSet.toList(), pvd.arrangeList));
    ToastProvider.success('保存成功');

    // 这里和EditDetailPage中逻辑不同，需要清空暂存内容
    pvd.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var mainColor = ColorUtil.blue2CColor;

    var timeFrameBuilder = Builder(
      builder: (BuildContext context) {
        var provider = context.watch<EditProvider>();
        return Column(
          children: List.generate(
            provider.arrangeList.length,
            (index) => TimeFrameWidget(
              index,
              !(provider.arrangeList.length == 1 && index == 0),
              _scrollController,
              delCb: () async {
                if (index != provider.arrangeList.length - 1) {
                  /// 删除非最后一个frame时，稍微移动一下，可以在setState后动画滑动
                  await _scrollController.animateTo(
                    _scrollController.offset + 1,
                    duration: const Duration(milliseconds: 10),
                    curve: Curves.linear,
                  );
                } else {
                  /// 删除最后一个frame时，向上滑动再setState
                  var offset = _scrollController.position.maxScrollExtent -
                      _scrollController.offset -
                      200;
                  if (offset > 0) offset = 0;
                  await _scrollController.animateTo(
                    _scrollController.offset + offset,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear,
                  );
                }
              },
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    var inputSerialWidget = ValueListenableBuilder<bool>(
      valueListenable: _inputSerial,
      builder: (context, value, _) {
        if (value) {
          if (_needFocus) {
            FocusManager.instance.primaryFocus?.unfocus(); // 需要先移除其他焦点
            Future.delayed(const Duration(milliseconds: 10), () {
              _focusNode.requestFocus(); // 这里加个delay保证输入框build出来
            });
            _needFocus = false;
          }
          return CardWidget(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InputWidget(
                    onChanged: (text) => serial = text,
                    hintText: '请输入逻辑班号',
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatter: [LengthLimitingTextInputFormatter(20)],
                  ),
                ),
                SizedBox(width: 12.w),
                WButton(
                  onPressed: () {
                    CustomCourseService.getClassBySerial(serial).then((course) {
                      if (course == null) return;
                      context.read<EditProvider>().load(course);
                      ToastProvider.success('导入课程成功');
                      setState(() {
                        _inputSerial.value = false;
                        name = course.name;
                        credit = course.credit;
                      });
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(),
                    child: Icon(
                      Icons.check,
                      color: ColorUtil.blue2CColor,
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return CardWidget(
          onTap: () {
            if (!value) _inputSerial.value = true;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle, color: mainColor),
              SizedBox(width: 5.w),
              Text('输入逻辑班号导入课程',
                  style: TextUtil.base.PingFangSC.medium
                      .customColor(mainColor)
                      .sp(12)),
            ],
          ),
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        // 退出前暂存编辑内容
        context.read<EditProvider>().save(name, credit);
        return true;
      },
      child: Container(
        height: 647.h,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/schedule/sheet_bg.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 12.w),
                Text('新建课程',
                    style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _saveAndQuit(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('保存',
                      style: TextUtil.base.PingFangSC.regular.white.sp(12)),
                ),
                SizedBox(width: 12.w),
              ],
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context)
                    .copyWith(secondaryHeaderColor:ColorUtil.whiteFFColor),
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  children: [
                    SizedBox(height: 5.h),
                    inputSerialWidget,
                    CardWidget(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InputWidget(
                            onChanged: (text) => name = text,
                            title: '课程名称',
                            hintText: '请输入课程名称（必填）',
                            initText: name,
                            inputFormatter: [
                              LengthLimitingTextInputFormatter(20)
                            ],
                          ),
                          InputWidget(
                            onChanged: (text) => credit = text,
                            title: '课程学分',
                            hintText: '请输入课程学分（选填）',
                            initText: credit,
                            keyboardType: TextInputType.number,
                            inputFormatter: [
                              LengthLimitingTextInputFormatter(10)
                            ],
                          ),
                        ],
                      ),
                    ),
                    timeFrameBuilder,
                    CardWidget(
                      onTap: () {
                        context.read<EditProvider>().add();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear,
                          );
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle, color: mainColor),
                          SizedBox(width: 5.w),
                          Text('新增时段',
                              style: TextUtil.base.PingFangSC.medium
                                  .customColor(mainColor)
                                  .sp(12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
