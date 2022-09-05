import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class ImageViewPage extends StatefulWidget {
  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  List<String> urlList;
  int urlListLength = 0;
  int indexNow = 0;
  int tempSelect;
  bool isLongPic;

  final String baseUrl = '${EnvConfig.QNHDPIC}download/origin/';

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;
    dynamic obj = ModalRoute.of(context).settings.arguments;
    urlList = obj['urlList'];
    urlListLength = obj['urlListLength'];
    indexNow = obj['indexNow'];
    isLongPic = obj['isLongPic'] ?? false;

    return Stack(
      alignment: Alignment.center,
      children: [
        PhotoViewGallery.builder(
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
              basePosition: isLongPic ? Alignment.topCenter : Alignment.center,
              imageProvider: NetworkImage(baseUrl + urlList[index]),
              maxScale: isLongPic
                  ? PhotoViewComputedScale.contained * 20
                  : PhotoViewComputedScale.contained * 5.0,
              minScale: PhotoViewComputedScale.contained * 1.0,
              initialScale: isLongPic
                  ? PhotoViewComputedScale.covered
                  : PhotoViewComputedScale.contained,
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
          }),
        ),
        SafeArea(
          child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15.h, 15.h, 0, 0),
                child: WButton(
                  child: Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 30.h,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
        ),
        Positioned(
            bottom: 10.w,
            right: 10.w,
            child: Container(
              decoration: BoxDecoration(color: Color(0x88444444), borderRadius: BorderRadius.all(Radius.circular(14.r))),
              padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 14.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WButton(
                    child: Icon(
                      CupertinoIcons.square_arrow_down,
                      color: Colors.white,
                      size: 30.h,
                    ),
                    onPressed: () {
                      saveImage();
                    },
                  ),
                  SizedBox(width: 30.w),
                  WButton(
                    child: Icon(
                      CupertinoIcons.share,
                      color: Colors.white,
                      size: 30.h,
                    ),
                    onPressed: () {
                      showSaveImageBottomSheet();
                    },
                  ),
                ],
              ),
            ))
      ],
    );
  }

  void saveImage() async {
    ToastProvider.running('保存中');
    await GallerySaver.saveImage(baseUrl + urlList[indexNow], albumName: "微北洋");
    ToastProvider.success('保存成功');
  }

  void showSaveImageBottomSheet() async {
    ToastProvider.running('请稍后');
    final path = await StorageUtil.saveTempFileFromNetwork(
        baseUrl + urlList[indexNow],
        filename: urlList[indexNow]);
    Share.shareFiles([path]);
  }
}
