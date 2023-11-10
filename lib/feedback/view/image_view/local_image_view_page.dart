import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';

import '../../../commons/widgets/w_button.dart';

class LocalImageViewPageArgs {
  final List<File> uriList;
  final List<String> assetList;
  final int uriListLength;
  final int indexNow;

  LocalImageViewPageArgs(
      this.uriList, this.assetList, this.uriListLength, this.indexNow);
}

class LocalImageViewPage extends StatefulWidget {
  final LocalImageViewPageArgs args;

  LocalImageViewPage(this.args);

  @override
  _LocalImageViewPageState createState() => _LocalImageViewPageState();
}

class _LocalImageViewPageState extends State<LocalImageViewPage> {
  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;

    return WButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Container(
        child: PhotoViewGallery.builder(
          loadingBuilder: (context, event) => Center(
              child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: (event == null || event.expectedTotalBytes == null)
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ))),
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            late ImageProvider image;
            if (widget.args.uriList.isNotEmpty) {
              image = FileImage(widget.args.uriList[index]);
            }
            if (widget.args.assetList.isNotEmpty) {
              image = AssetImage(widget.args.assetList[index]);
            }
            return PhotoViewGalleryPageOptions(
              imageProvider: image,
              maxScale: PhotoViewComputedScale.contained * 5.0,
              minScale: PhotoViewComputedScale.contained * 1.0,
              initialScale: PhotoViewComputedScale.contained,
            );
          },
          scrollDirection: Axis.horizontal,
          itemCount: widget.args.uriListLength,
          backgroundDecoration: BoxDecoration(color: ColorUtil.black00Color),
          pageController: PageController(
            initialPage: widget.args.indexNow,
          ),
        ),
      ),
    );
  }
}
