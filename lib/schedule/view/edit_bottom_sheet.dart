// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';

class EditBottomSheet extends StatefulWidget {
  @override
  _EditBottomSheetState createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
  final _scrollController = ScrollController();

  var name = '';
  var credit = '';

  bool _check(BuildContext context, {required bool quiet}) {
    if (name.isEmpty) {
      if (!quiet) ToastProvider.error('请填写课程名称');
      return false;
    }
    var pvd = context.read<EditProvider>();
    int frameCheck = pvd.check();
    if (frameCheck != -1) {
      if (!quiet) ToastProvider.error('time frame ${frameCheck + 1} 信息不完整');
      return false;
    }
    return true;
  }

  void _saveAndQuit(BuildContext context) {
    if (!_check(context, quiet: false)) return;

    int start = 100;
    int end = 0;
    var pvd = context.read<EditProvider>();
    pvd.arrangeList.forEach((arrange) {
      if (arrange.weekList.first <= start) start = arrange.weekList.first;
      if (arrange.weekList.last >= end) end = arrange.weekList.last;
    });

    context.read<CourseProvider>().addCustomCourse(
        Course.custom(name, credit, '$start-$end', [], pvd.arrangeList));
    ToastProvider.success('保存成功');
    Navigator.pop(context);
  }

  void _showDialog(BuildContext context, String text, String okText,
      {VoidCallback? ok}) {
    SmartDialog.show(
      clickBgDismissTemp: false,
      widget: WbyDialogLayout(
        padding: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/images/schedule/notify.png',
                  color: FavorColors.scheduleTitleColor, height: 30, width: 30),
            ),
            SizedBox(height: 25),
            Text(text, style: TextUtil.base.PingFangSC.black00.medium.sp(15)),
            SizedBox(height: 30),
            WbyDialogStandardTwoButton(
              cancel: () {
                SmartDialog.dismiss();
              },
              ok: () {
                SmartDialog.dismiss();
                if (ok != null) ok();
              },
              cancelText: "取消",
              okText: okText,
            ),
          ],
        ),
      ),
    );
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
            (index) => TimeFrameWidget(
              index,
              !(provider.arrangeList.length == 1 && index == 0),
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        var check = _check(context, quiet: true);
        var text = check ? '是否保存已填信息?' : '是否取消编辑?';
        var okText = check ? '保存' : '确定';
        _showDialog(context, text, okText, ok: () {
          check ? _saveAndQuit(context) : Navigator.pop(context);
        });
        return false;
      },
      child: Material(
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
                    onPressed: () => _saveAndQuit(context),
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
                      CardWidget(
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
                      CardWidget(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InputWidget(
                              onChanged: (text) => name = text,
                              title: '课程名称',
                              hintText: '请输入课程名称（必填）',
                            ),
                            InputWidget(
                              onChanged: (text) => credit = text,
                              title: '课程学分',
                              hintText: '请输入课程学分（选填）',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      timeFrameBuilder,
                      CardWidget(
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
      ),
    );
  }
}
