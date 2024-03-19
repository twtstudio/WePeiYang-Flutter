import 'dart:async';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/page/rating_page.dart';

import '../modle/rating/power_load.dart';
import '../modle/rating/rating_page_data.dart';

class IndexTreeLoadingDots extends StatefulWidget {
  DataIndexTree dataIndexTree;

  IndexTreeLoadingDots(this.dataIndexTree);
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
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
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

    // 更新Text组件以应用白色粗体字样式
    return (!widget.dataIndexTree.stopFlag)?Container(
      color: Colors.black,
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
        widget.dataIndexTree.reTry();
      },
      child: Container(
        color: Colors.red, // 将背景颜色改为红色
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

  }
}


///数据叶加载动画

class IndexLeafLoadingDots extends StatefulWidget {
  DataIndexLeaf dataIndexLeaf;

  IndexLeafLoadingDots(this.dataIndexLeaf);
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
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
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

    // 更新Text组件以应用白色粗体字样式
    return (!widget.dataIndexLeaf.isError("get"))?Container(
      color: Colors.black,
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
        widget.dataIndexLeaf.retry("get");
      },
      child: Container(
        color: Colors.red, // 将背景颜色改为红色
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
  }
}


class IndexLeafCreateDots extends StatefulWidget {
  final DataIndexLeaf dataIndexLeaf;

  IndexLeafCreateDots(this.dataIndexLeaf);
  @override
  _IndexLeafCreateDotsState createState() => _IndexLeafCreateDotsState();
}

class _IndexLeafCreateDotsState extends State<IndexLeafCreateDots> {
  String _loadingText = '上传中';
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        _dotCount++;
        if (_dotCount > 3) {
          _dotCount = 1;
        }
        _loadingText = '上传中' + '.' * _dotCount;
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

    return
      (widget.dataIndexLeaf.isError("create"))?
    GestureDetector(
      onTap: () {
        // 在这里添加你希望点击后执行的函数
        widget.dataIndexLeaf.retry("create");
      },
      child: Container(
        color: Colors.red, // 将背景颜色改为红色
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
              "上传失败", // 更改文本为"网络错误"
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
    ):
      (widget.dataIndexLeaf.isSucceed("create"))?
      Container(
        color: Colors.green,
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
              "加载 完了",
              style: TextStyle(
                color: Colors.white, // 文本颜色为白色
                fontWeight: FontWeight.bold, // 字体粗细为粗体
                fontSize: 25,
              ),
            ),
            SizedBox(width: 5), // 在图标和文本之间添加一些间隔
          ],
        ),
      ):
      Container(
        color: Colors.black,
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
      );
  }
}


