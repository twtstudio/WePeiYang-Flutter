import 'dart:async';

import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> {
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
    return Container(
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
            _loadingText,
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
