
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

String fileToBase64(File file) {
  // 检查文件是否存在
  if (!file.existsSync()) {
    throw ArgumentError('文件不存在: ${file.path}');
  }
  // 将图片文件读取为字节列表
  List<int> imageBytes = file.readAsBytesSync();
  // 将字节列表转换为Base64编码
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}
