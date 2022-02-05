import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:we_pei_yang_flutter/main.dart';

enum PicType { postMulti, postSingle, comment }

typedef HitCallback = void Function(bool, int);

class WPYPic extends StatefulWidget {
  final PicType type;
  final String imageUrl;
  final int index, total;

  WPYPic.comment(this.imageUrl,)
      : type = PicType.comment,
        index = 0,
        total = 1;

  WPYPic.postMulti(this.imageUrl,
      this.index,
      this.total,) : type = PicType.postMulti;

  WPYPic.postSingle(this.imageUrl,)
      : type = PicType.postSingle,
        index = 0,
        total = 1;

  @override
  _WPYPicState createState() =>
      _WPYPicState(this.imageUrl, this.index, this.total);
}

class _WPYPicState extends State<WPYPic> {
  String imageUrl;
  int index, total;
  final String baseUrl = 'https://www.zrzz.site:7012/';

  _WPYPicState(this.imageUrl, this.index, this.total);

  @override
  Widget build(BuildContext context) {
    _image(int index, String imageUrl) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          child: FadeInImage.memoryNetwork(
              fit: BoxFit.cover,
              height: (WePeiYangApp.screenWidth - 80) / total,
              placeholder: kTransparentImage,
              image: 'https://www.zrzz.site:7012/' + imageUrl),
        ),
      );
    }

    //ENTRY
    return widget.type == PicType.comment
        ? SizedBox()
        : widget.type == PicType.postSingle
        ? SizedBox()
        : _image;
  }
}
