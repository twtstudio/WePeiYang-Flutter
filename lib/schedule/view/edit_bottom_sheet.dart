// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/unit_picker.dart';
import 'package:we_pei_yang_flutter/schedule/view/week_picker.dart';

class EditBottomSheet extends StatefulWidget {
  @override
  _EditBottomSheetState createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
  final _scrollController = ScrollController();

  var name = '';
  var credit = '';

  void _save(BuildContext context) {
    if (name.isEmpty) {
      ToastProvider.error('请填写课程名称');
      return;
    }
    var pvd = context.read<EditProvider>();
    int frameCheck = pvd.check();
    if (frameCheck != -1) {
      ToastProvider.error('time frame ${frameCheck + 1} 信息不完整');
      return;
    }

    int start = 100;
    int end = 0;
    print('name: $name | credit: $credit');
    pvd.arrangeList.forEach((arrange) {
      if (arrange.weekList.first <= start) start = arrange.weekList.first;
      if (arrange.weekList.last >= end) end = arrange.weekList.last;
      print('unit: ${arrange.unitList} | weekDay: ${arrange.weekday}');
      print('week: ${arrange.weekList}');
      print('location: ${arrange.location} | teacher: ${arrange.teacherList}');
    });

    context.read<CourseProvider>().addCustomCourse(
        Course.custom(name, credit, '$start-$end', [], pvd.arrangeList));
    ToastProvider.success('保存成功');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var titleColor = FavorColors.scheduleTitleColor;

    var timeFrameBuilder = Builder(
      builder: (BuildContext context) {
        var provider = context.watch<EditProvider>();
        return Column(
          children: List.generate(
            provider.arrangeList.length,
            (index) => _TimeFrameWidget(
              index,
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    return Material(
      color: Color.fromRGBO(246, 246, 246, 1.0),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: WePeiYangApp.screenHeight * 0.6,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                Text('新建课程',
                    style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _save(context),
                  style: ElevatedButton.styleFrom(
                    primary: titleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('保存',
                      style: TextUtil.base.PingFangSC.regular.white.sp(12)),
                )
              ],
            ),
            Theme(
              data: ThemeData(accentColor: Colors.white),
              child: Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    _CardWidget(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle, color: titleColor),
                          SizedBox(width: 5),
                          Text('输入逻辑班号导入课程',
                              style: TextUtil.base.PingFangSC.medium
                                  .customColor(titleColor)
                                  .sp(12)),
                        ],
                      ),
                    ),
                    _CardWidget(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _InputWidget(
                            onChanged: (text) => name = text,
                            title: '课程名称',
                            hintText: '请输入课程名称（必填）',
                          ),
                          _InputWidget(
                            onChanged: (text) => credit = text,
                            title: '课程学分',
                            hintText: '请输入课程学分（选填）',
                          ),
                        ],
                      ),
                    ),
                    timeFrameBuilder,
                    _CardWidget(
                      onTap: () {
                        context.read<EditProvider>().add();
                        Future.delayed(Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear,
                          );
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle, color: titleColor),
                          SizedBox(width: 5),
                          Text('新增时段',
                              style: TextUtil.base.PingFangSC.medium
                                  .customColor(titleColor)
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

class _TimeFrameWidget extends StatelessWidget {
  final int index;

  _TimeFrameWidget(this.index, {Key? key}) : super(key: key);

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

    return _CardWidget(
      child: Column(
        children: [
          Row(
            children: [
              Text('time frame ${index + 1}',
                  style: TextUtil.base.Aspira.medium.black2A.sp(16)),
              Spacer(),
              GestureDetector(
                onTap: () => pvd.remove(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(),
                  child:
                      Icon(Icons.cancel, color: FavorColors.scheduleTitleColor),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('周数：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    pvd.initWeekList();
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.white.withOpacity(0.1),
                      builder: (_) => WeekPicker(index),
                    ).then((_) => pvd.saveWeekList(index));
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerRight,
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('${weekType}${weekDay}${weekText}',
                        style: TextUtil.base.PingFangSC.medium.greyA8.sp(13)),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('节数：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    pvd.initUnitList(index);
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.white.withOpacity(0.1),
                      builder: (_) => UnitPicker(index),
                    ).then((_) => pvd.saveUnitList(index));
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerRight,
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(unitText,
                        style: TextUtil.base.PingFangSC.medium.greyA8.sp(13)),
                  ),
                ),
              ),
            ],
          ),
          _InputWidget(
            onChanged: (text) => pvd.arrangeList[index].location = text,
            title: '地点',
            hintText: '请输入地点（选填）',
          ),
          _InputWidget(
            onChanged: (text) => pvd.arrangeList[index].teacherList = [text],
            title: '教师',
            hintText: '请输入教师名（选填）',
          ),
        ],
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;

  _CardWidget({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        // 这里如果用Ink，会导致这个组件在上滑被其他组件遮挡时仍然可见，很迷
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            splashFactory: InkRipple.splashFactory,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: child),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

class _InputWidget extends StatelessWidget {
  final Key? key;
  final ValueChanged<String> onChanged;
  final String title;
  final String hintText;

  _InputWidget(
      {required this.onChanged,
      required this.title,
      required this.hintText,
      this.key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$title：', style: TextUtil.base.PingFangSC.bold.black2A.sp(14)),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            textAlign: TextAlign.end,
            style: TextUtil.base.PingFangSC.medium.black2A.sp(16),
            cursorColor: FavorColors.scheduleTitleColor,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextUtil.base.PingFangSC.medium.greyA8.sp(13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
