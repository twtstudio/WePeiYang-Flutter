// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';

class EditDetailPageArgs {
  final Course course;
  final int index;

  EditDetailPageArgs(this.course, this.index);
}

class EditDetailPage extends StatefulWidget {
  final Course course;
  final int index;

  EditDetailPage(EditDetailPageArgs args)
      : course = args.course,
        index = args.index;

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
    name = widget.course.name;
    credit = widget.course.credit;
  }

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

    context.read<CourseProvider>().modifyCustomCourse(
        Course.custom(name, credit, '$start-$end', [], pvd.arrangeList),
        widget.index);
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
            (index) => TimeFrameWidget(
              index,
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorUtil.black2AColor, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 40,
        title:
            Text('课程详情', style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
        actions: [
          Center(
            child: Container(
              height: 35,
              width: 60,
              child: ElevatedButton(
                onPressed: () => _save(context),
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
                          initText: widget.course.name,
                        ),
                        InputWidget(
                          onChanged: (text) => credit = text,
                          title: '课程学分',
                          hintText: '请输入课程学分（选填）',
                          initText: widget.course.credit,
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
                context.read<CourseProvider>().deleteCustomCourse(widget.index);
                Navigator.pop(context);
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
    );
  }
}
