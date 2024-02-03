import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class ImageViewPageArgs {
  final List<String> urlList;
  final int urlListLength;
  final int indexNow;
  final bool isLongPic;

  ImageViewPageArgs(
      this.urlList, this.urlListLength, this.indexNow, this.isLongPic);
}

class ImageViewPage extends StatefulWidget {
  final ImageViewPageArgs args;

  ImageViewPage(this.args);

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/origin/';
  late int indexNow;

  @override
  void initState() {
    indexNow = widget.args.indexNow;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;

    return Stack(
      alignment: Alignment.center,
      children: [
        PhotoViewGallery.builder(
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
            return PhotoViewGalleryPageOptions(
              basePosition: widget.args.isLongPic
                  ? Alignment.topCenter
                  : Alignment.center,
              imageProvider: NetworkImage(baseUrl + widget.args.urlList[index]),
              maxScale: widget.args.isLongPic
                  ? PhotoViewComputedScale.contained * 20
                  : PhotoViewComputedScale.contained * 5.0,
              minScale: PhotoViewComputedScale.contained * 1.0,
              initialScale: widget.args.isLongPic
                  ? PhotoViewComputedScale.covered
                  : PhotoViewComputedScale.contained,
            );
          },
          scrollDirection: Axis.horizontal,
          itemCount: widget.args.urlListLength,
          backgroundDecoration: BoxDecoration(color: ColorUtil.black00Color),
          pageController: PageController(
            initialPage: indexNow,
          ),
          onPageChanged: (c) {
            indexNow = c;
          },
        ),
        SafeArea(
          child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15.h, 15.h, 0, 0),
                child: WButton(
                  child: Container(
                      decoration: BoxDecoration(
                          color: ColorUtil.black88Color,
                          borderRadius:
                              BorderRadius.all(Radius.circular(14.r))),
                      padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 14.w),
                      child: Icon(
                        CupertinoIcons.back,
                        color: ColorUtil.primaryBackgroundColor,
                        size: 30.h,
                      )),
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
              decoration: BoxDecoration(
                  color: ColorUtil.black88Color,
                  borderRadius: BorderRadius.all(Radius.circular(14.r))),
              padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 14.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WButton(
                    child: Icon(
                      CupertinoIcons.square_arrow_down,
                      color: ColorUtil.primaryBackgroundColor,
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
                      color: ColorUtil.primaryBackgroundColor,
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
    await GallerySaver.saveImage(
        baseUrl + widget.args.urlList[indexNow],
        albumName: "微北洋");
    ToastProvider.success('保存成功');
  }

  void showSaveImageBottomSheet() async {
    ToastProvider.running('请稍后');
    final path = await StorageUtil.saveTempFileFromNetwork(
        baseUrl + widget.args.urlList[indexNow],
        filename: widget.args.urlList[indexNow]);
    Share.shareXFiles([XFile(path)]);
  }
}
