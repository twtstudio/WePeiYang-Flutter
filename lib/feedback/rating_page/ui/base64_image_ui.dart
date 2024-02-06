import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Base64Image extends StatelessWidget{

  String base64String;
  double width;
  double height;

  Base64Image({required this.base64String,required this.width,required this.height});

  Widget build(BuildContext context) {
    // 将Base64字符串解码为字节数组
    Uint8List bytes = base64Decode(base64String.split(',')[1]);
    return Image.memory(
      bytes,
      width: width, // 设置图像宽度
      height: height, // 设置图像高度
      fit: BoxFit.cover, // 图像适应方式，可以根据需要进行更改
    );
  }
}