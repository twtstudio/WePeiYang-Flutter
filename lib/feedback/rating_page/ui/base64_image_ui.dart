import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
// 假设 ImagePreviewPage 已经在其他地方定义好了

class Base64Image extends StatefulWidget {
  String base64String;
  final double width;
  final double height;

  Base64Image({
    Key? key,
    required this.base64String,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _Base64ImageState createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {

  noThing()=>Container(
    width: widget.width,
    height: widget.height,
    color: Colors.grey.withOpacity(0.5),
  );

  Future<Widget> decodeImageInBackground() async {
    try{

      // 在UI线程中创建图像
      Image image = Image.memory(
        await base64Decode(widget.base64String),
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );

      return image;
    }
    catch(e){
      widget.base64String = "iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==";
      return noThing();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.base64String == " ") {
      widget.base64String = "iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: FutureBuilder<Widget>(
        future: decodeImageInBackground(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果异步任务仍在进行中，显示加载指示器
            return noThing();
          } else if (snapshot.hasError) {
            // 如果异步任务出错，显示错误信息
            return Text('Error: ${snapshot.error}');
          } else {
            // 如果异步任务已完成，显示图像
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewPage(
                      base64String: widget.base64String,
                    ),
                  ),
                );
              },
              child: FadeInImageWidget(
                child: snapshot.data!,
              )
            );
          }
        },
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


class FadeInImageWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInImageWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  _FadeInImageWidgetState createState() => _FadeInImageWidgetState();
}

class _FadeInImageWidgetState extends State<FadeInImageWidget> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // 设置一个延时以便动画在组件构建完成后开始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _opacity,
      child: widget.child,
    );
  }
}