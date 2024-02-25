import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

class Base64Image extends StatelessWidget {
  final String base64String;
  final double width;
  final double height;

  Base64Image(
      {required this.base64String, required this.width, required this.height,});

  @override
  Widget build(BuildContext context) {

    //return Text("12313");
    //圆角,边框
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ImagePreviewPage(base64String: base64String)),
          );
        },
        child: Image.memory(
          base64Decode(base64String),
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String base64String;

  ImagePreviewPage({required this.base64String});

  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64Decode(base64String);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              // 保存图片到相册
              final directory = await getApplicationDocumentsDirectory();
              final path = '${directory.path}/image.png';
              final file = await File(path).writeAsBytes(bytes);
              final success = await GallerySaver.saveImage(file.path);
              if (success != null && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存成功')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存失败')));
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
            child: Image.memory(
              bytes,
              width: screenWidth * 0.9,
              height: screenWidth * 0.9,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
