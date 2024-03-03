import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  late Widget img;

  loadImg(){
    img = Image.memory(
      base64Decode(widget.base64String),
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();

    img = Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey,
    );

    if (widget.base64String == " ") {
      widget.base64String = "iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==";
    }
  }

  @override
  Widget build(BuildContext context) {

    try{
      loadImg();
    }
    catch(e){
      widget.base64String = "iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAA1BMVEWFhYWbov8QAAAAPUlEQVR4nO3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvgyZwAABCrx9CgAAAABJRU5ErkJggg==";
      //print(e);
      build(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePreviewPage(base64String: widget.base64String),
            ),
          );
        },
        child: img,
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
