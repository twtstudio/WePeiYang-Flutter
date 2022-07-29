// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';

class EditDetailPageArgs {
  final int index;
  final String name;
  final String credit;

  EditDetailPageArgs(this.index, this.name, this.credit);
}

class EditDetailPage extends StatefulWidget {
  final int index;
  final String name;
  final String credit;

  EditDetailPage(EditDetailPageArgs args)
      : index = args.index,
        name = args.name,
        credit = args.credit;

  @override
  _EditDetailPageState createState() => _EditDetailPageState();
}

class _EditDetailPageState extends State<EditDetailPage> {
  final _scrollController = ScrollController();

  var name = '';
  var credit = '';

  @override
  void initState() {
    super.initState();
    name = widget.name;
    credit = widget.credit;
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

    context.read<CourseProvider>().modifyCustomCourse(
        Course.custom(
            name, credit, '$start-$end', teacherSet.toList(), pvd.arrangeList),
        widget.index);
    ToastProvider.success('保存成功');
    Navigator.pop(context);
  }

  void _deleteAndQuit(BuildContext context) {
    context.read<CourseProvider>().deleteCustomCourse(widget.index);
    Navigator.pop(context);
  }

  void _showDialog(BuildContext context, String text,
      {VoidCallback? ok, VoidCallback? cancel}) {
    SmartDialog.show(
      clickBgDismissTemp: false,
      widget: WbyDialogLayout(
        bottomPadding: true,
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
              first: () {
                SmartDialog.dismiss();
                if (cancel != null) cancel();
              },
              second: () {
                SmartDialog.dismiss();
                if (ok != null) ok();
              },
              firstText: '取消',
              secondText: '确定',
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
              _scrollController,
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        _showDialog(context, '是否保存修改内容?', ok: () {
          var check = _check(context);
          if (check) _saveAndQuit(context);
        }, cancel: () {
          Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(246, 246, 246, 1),
          brightness: Brightness.light,
          leading: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(),
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Image.asset(
                  'assets/images/schedule/back.png',
                  height: 20,
                  width: 20,
                  color: ColorUtil.black2AColor,
                ),
              ),
            ),
          ),
          titleSpacing: 0,
          leadingWidth: 40,
          title:
              Text('课程详情', style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
          actions: [
            Center(
              child: Container(
                height: 35,
                width: 60,
                child: ElevatedButton(
                  onPressed: () => _saveAndQuit(context),
                  style: ElevatedButton.styleFrom(
                    primary: titleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('保存',
                      style: TextUtil.base.PingFangSC.bold.white.sp(13)),
                ),
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(accentColor: Colors.white),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  controller: _scrollController,
                  children: [
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Material(
              color: Color.fromRGBO(217, 83, 79, 1),
              child: InkWell(
                onTap: () {
                  _showDialog(context, '是否删除此课程?', ok: () {
                    _deleteAndQuit(context);
                  });
                },
                splashFactory: InkRipple.splashFactory,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/schedule/dust_bin.png',
                          height: 18, width: 18),
                      SizedBox(width: 5),
                      Text('删除',
                          style: TextUtil.base.PingFangSC.medium.white.sp(14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
