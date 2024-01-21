import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class ReportBasePage extends StatelessWidget {
  final Widget body;
  final Widget action;

  const ReportBasePage({Key? key, required this.body, required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.whiteF8Color,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: Container(
          color: ColorUtil.blue2CColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Hero(
            tag: 'appbar',
            transitionOnUserGestures: true,
            child: AppBar(
              titleSpacing: 0,
              leadingWidth: 30,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                '健康信息填报',
                style: TextUtil.base.bold.whiteFD.sp(18),
              ),
              leading: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(CupertinoIcons.back, size: 25, color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              actions: [action],
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: SelfInformation()),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}

class SelfInformation extends StatefulWidget {
  @override
  _SelfInformationState createState() => _SelfInformationState();
}

class _SelfInformationState extends State<SelfInformation> {
  String name = CommonPreferences.realName.value;
  String id = 'ID: ${CommonPreferences.userNumber.value}';
  String department = CommonPreferences.department.value;
  String type = CommonPreferences.stuType.value;
  String major = CommonPreferences.major.value;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 13),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(" , 你好"),
                  SizedBox(width: 20),
                  Text("ID:"),
                  Expanded(
                    child: Text(
                      id.substring(4),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              SizedBox(
                height: 32,
                child: TextScroller(
                  stepOffset: 200.0,
                  duration: Duration(seconds: 5),
                  paddingLeft: 0.0,
                  children: [
                    Text(department),
                    SizedBox(width: 10),
                    Text(type),
                    SizedBox(width: 10),
                    Text(major),
                    SizedBox(width: 30),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

//https://www.cnblogs.com/qqcc1388/p/12405548.html
/// 跑马灯哗哗哗
class TextScroller extends StatefulWidget {
  final Duration duration; // 轮播时间
  final double stepOffset; // 偏移量
  final double paddingLeft; // 内容之间的间距
  final List<Widget> children; //内容

  TextScroller(
      {required this.paddingLeft,
      required this.duration,
      required this.stepOffset,
      required this.children});

  _TextScrollerState createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  late ScrollController _controller; // 执行动画的controller
  late Timer _timer; // 定时器timer
  double _offset = 0.0; // 执行动画的偏移量

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: _offset);
    _timer = Timer.periodic(widget.duration, (timer) {
      double newOffset = _controller.offset + widget.stepOffset;
      if (newOffset != _offset) {
        _offset = newOffset;
        _controller.animateTo(_offset,
            duration: widget.duration, curve: Curves.linear); // 线性曲线动画
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _child() {
    return new Row(children: _children());
  }

  // 子视图
  List<Widget> _children() {
    List<Widget> items = [];
    List list = widget.children;
    for (var i = 0; i < list.length; i++) {
      Container item = new Container(
        margin: new EdgeInsets.only(right: widget.paddingLeft),
        child: list[i],
      );
      items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal, // 横向滚动
      controller: _controller, // 滚动的controller
      itemBuilder: (context, index) {
        return _child();
      },
    );
  }
}
