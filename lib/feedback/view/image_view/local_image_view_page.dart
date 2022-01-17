import 'package:flutter/material.dart';
import 'dart:io';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class LocalImageViewPage extends StatefulWidget {
  @override
  _LocalImageViewPageState createState() => _LocalImageViewPageState();
}

class _LocalImageViewPageState extends State<LocalImageViewPage> {
  List<File> uriList;
  int uriListLength = 0;
  int indexNow = 0;
  int tempSelect;

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context).settings.arguments;
    uriList = obj['uriList'];
    uriListLength = obj['uriListLength'];
    indexNow = obj['indexNow'];
    tempSelect = indexNow;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
          child: PhotoViewGallery.builder(
              loadingBuilder: (context, event) => Center(
                  child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes,
                      ))),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(uriList[index]),
                  maxScale: PhotoViewComputedScale.contained * 5.0,
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  initialScale: PhotoViewComputedScale.contained,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: uriListLength,
              backgroundDecoration: BoxDecoration(color: Colors.black),
              pageController: PageController(
                initialPage: indexNow,
              ),
              onPageChanged: (index) => setState(() {
                tempSelect = index;
              }))),
    );
  }
}
