import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class ImageViewPage extends StatefulWidget {
  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  List<String> urlList;
  int urlListLength = 0;
  int indexNow = 0;
  int tempSelect;

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context).settings.arguments;
    urlList = obj['urlList'];
    urlListLength = obj['urlListLength'];
    indexNow = obj['indexNow'];
    tempSelect = indexNow;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      onLongPress: () {
        showSaveImageBottomSheet(context);
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
                  imageProvider: NetworkImage(urlList[index]),
                  maxScale: PhotoViewComputedScale.contained * 5.0,
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  initialScale: PhotoViewComputedScale.contained,
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: urlListLength,
              backgroundDecoration: BoxDecoration(color: Colors.black),
              pageController: PageController(
                initialPage: indexNow,
              ),
              onPageChanged: (index) => setState(() {
                    tempSelect = index;
                  }))),
    );
  }

  void showSaveImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            ListTile(
              title: Text(
                  '保存图片',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  ImagePickers.saveImageToGallery(urlList[tempSelect]);
                  ToastProvider.success('已保存到手机相册');
                  Navigator.pop(context);
                },
              )
          ],
        );
      }
    );
  }
}
