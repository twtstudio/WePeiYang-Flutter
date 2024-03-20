import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/page/rating_page.dart';

import '../modle/rating/power_load.dart';
import '../modle/rating/rating_page_data.dart';

class IndexTreeLoadingDots extends StatefulWidget {
  DataIndex dataIndex;

  IndexTreeLoadingDots(this.dataIndex);
  @override
  _IndexTreeLoadingDotsState createState() => _IndexTreeLoadingDotsState();
}

class _IndexTreeLoadingDotsState extends State<IndexTreeLoadingDots> {
  String _loadingText = 'UI构建中';
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _dotCount++;
        if (_dotCount > 3) {
          _dotCount = 1;
        }
        _loadingText = 'UI构建中' + '.' * _dotCount;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    dataIndexTree() => context.read<RatingPageData>().getDataIndexTree(widget.dataIndex);

    /************************
     * 获取相对长度
     ************************/
    double _getMM(){
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度
    }
    double mm = _getMM();

    Widget dot = (!dataIndexTree().stopFlag)?Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(4), // 设置圆角半径
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 使Row占用的空间仅足够包含子组件
        children: [
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          Icon(
            Icons.downloading, // 使用内置的wifi图标
            color: Colors.white, // 设置图标颜色为白色
          ),
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          Text(
            _loadingText, // 更改文本为"加载中"
            style: TextStyle(
              color: Colors.white, // 文本颜色为白色
              fontWeight: FontWeight.bold, // 字体粗细为粗体
              fontSize: 25,
            ),
          ),
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
        ],
      ),
    ) :
    GestureDetector(
      onTap: () {
        // 在这里添加你希望点击后执行的函数
        dataIndexTree().reTry();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(4), // 设置圆角半径
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 使Row占用的空间仅足够包含子组件
          children: [
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
            Icon(
              Icons.error, // 更改图标为error图标
              color: Colors.white, // 设置图标颜色为白色
            ),
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
            Text(
              "网络错误", // 更改文本为"网络错误"
              style: TextStyle(
                color: Colors.white, // 文本颜色为白色
                fontWeight: FontWeight.bold, // 字体粗细为粗体
                fontSize: 25,
              ),
            ),
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          ],
        ),
      ),
    );

    // 更新Text组件以应用白色粗体字样式
    return (!dataIndexTree().isFinish())?
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.0,sigmaY: 2.0),///整体模糊度
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0),///背景透明
            borderRadius: BorderRadius.all(Radius.circular(1.2))///圆角
        ),
        child: dot,
      ),
    ):
    Container();

  }
}


///数据叶加载动画

class IndexLeafLoadingDots extends StatefulWidget {
  DataIndex dataIndex;

  IndexLeafLoadingDots(this.dataIndex);
  @override
  _IndexLeafLoadingDotsState createState() => _IndexLeafLoadingDotsState();
}

class _IndexLeafLoadingDotsState extends State<IndexLeafLoadingDots> {
  String _loadingText = 'UI构建中';
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _dotCount++;
        if (_dotCount > 3) {
          _dotCount = 1;
        }
        _loadingText = 'UI构建中' + '.' * _dotCount;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    dataIndexLeaf() => context.read<RatingPageData>().getDataIndexLeaf(widget.dataIndex);

    Widget dot = (!dataIndexLeaf().isError("get"))?Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(4), // 设置圆角半径
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 使Row占用的空间仅足够包含子组件
        children: [
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          Icon(
            Icons.downloading, // 使用内置的wifi图标
            color: Colors.white, // 设置图标颜色为白色
          ),
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          Text(
            _loadingText, // 更改文本为"加载中"
            style: TextStyle(
              color: Colors.white, // 文本颜色为白色
              fontWeight: FontWeight.bold, // 字体粗细为粗体
              fontSize: 25,
            ),
          ),
          SizedBox(width: 5), // 在图标和文本之间添加一些间隔
        ],
      ),
    ) :
    GestureDetector(
      onTap: () {
        // 在这里添加你希望点击后执行的函数
        dataIndexLeaf().retry("get");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(4), // 设置圆角半径
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 使Row占用的空间仅足够包含子组件
          children: [
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
            Icon(
              Icons.error, // 更改图标为error图标
              color: Colors.white, // 设置图标颜色为白色
            ),
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
            Text(
              "网络错误", // 更改文本为"网络错误"
              style: TextStyle(
                color: Colors.white, // 文本颜色为白色
                fontWeight: FontWeight.bold, // 字体粗细为粗体
                fontSize: 25,
              ),
            ),
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          ],
        ),
      ),
    );
    // 更新Text组件以应用白色粗体字样式
    return (!dataIndexLeaf().isSucceed("get"))?
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.0,sigmaY: 2.0),///整体模糊度
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0),///背景透明
            borderRadius: BorderRadius.all(Radius.circular(1.2))///圆角
        ),
        child: dot,
      ),
    ):
    Container();
  }
}




