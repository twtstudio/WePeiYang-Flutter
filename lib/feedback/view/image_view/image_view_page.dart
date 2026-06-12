import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';

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

class _ImageViewPageState extends State<ImageViewPage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/origin/';
  late int indexNow;
  bool hasQRCode = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    indexNow = widget.args.indexNow;
    super.initState();
    _checkQRCode();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _imageUrlAt(int index) {
    final url = widget.args.urlList[index];
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return baseUrl + url;
  }

  String _imageFileNameAt(int index) {
    final url = widget.args.urlList[index].split('#').first;
    final name = Uri.tryParse(url)?.pathSegments.last ?? url;
    if (name.contains('.') && name.split('.').last.length <= 5) return name;
    return '$name.jpg';
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor)),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PhotoViewGallery.builder(
              loadingBuilder: (context, event) => Center(
                  child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value:
                            (event == null || event.expectedTotalBytes == null)
                                ? 0
                                : event.cumulativeBytesLoaded /
                                    event.expectedTotalBytes!,
                      ))),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  basePosition: widget.args.isLongPic
                      ? Alignment.topCenter
                      : Alignment.center,
                  imageProvider: NetworkImage(_imageUrlAt(index)),
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
              backgroundDecoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.reverseBackgroundColor)),
              pageController: PageController(
                initialPage: indexNow,
              ),
              onPageChanged: (c) {
                setState(() {
                  indexNow = c;
                  hasQRCode = false;
                });
                _checkQRCode();
              },
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.h, 15.h, 0, 0),
                  child: WButton(
                    child: Container(
                        decoration: BoxDecoration(
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.labelTextColor)
                                .withOpacity(0.8),
                            borderRadius:
                                BorderRadius.all(Radius.circular(14.r))),
                        padding: EdgeInsets.fromLTRB(12.w, 10.w, 14.w, 10.w),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          size: 30.h,
                        )),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )),
            Positioned(
                bottom: 10.w,
                right: 10.w,
                child: Container(
                  decoration: BoxDecoration(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.labelTextColor)
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.all(Radius.circular(14.r))),
                  padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 14.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: hasQRCode
                            ? Row(
                                children: [
                                  WButton(
                                    child: Icon(
                                      Icons.qr_code_scanner_outlined,
                                      color: WpyTheme.of(context).get(
                                          WpyColorKey.primaryBackgroundColor),
                                      size: 30.h,
                                    ),
                                    onPressed: () {
                                      recognizeQRCode();
                                    },
                                  ),
                                  SizedBox(width: 30.w),
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                      WButton(
                        child: Icon(
                          Icons.file_download_outlined,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          size: 30.h,
                        ),
                        onPressed: () {
                          saveImage();
                        },
                      ),
                      SizedBox(width: 30.w),
                      WButton(
                        child: Icon(
                          Icons.share_outlined,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
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
        ),
      ),
    );
  }

  void _checkQRCode() async {
    try {
      final imageUrl = _imageUrlAt(indexNow);
      final imagePath = await StorageUtil.saveTempFileFromNetwork(imageUrl,
          filename: _imageFileNameAt(indexNow));
      String? qrResult = await QrCodeToolsPlugin.decodeFrom(imagePath);
      if (!mounted) return;
      if (qrResult != null && qrResult.isNotEmpty) {
        setState(() {
          hasQRCode = true;
        });
        _animationController.forward();
      } else {
        setState(() {
          hasQRCode = false;
        });
        _animationController.reverse();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasQRCode = false;
      });
      _animationController.reverse();
    }
  }

  void saveImage() async {
    ToastProvider.running('保存中');
    await GallerySaver.saveImage(_imageUrlAt(indexNow), albumName: "微北洋");
    ToastProvider.success('保存成功');
  }

  void showSaveImageBottomSheet() async {
    ToastProvider.running('请稍后');
    final path = await StorageUtil.saveTempFileFromNetwork(_imageUrlAt(indexNow),
        filename: _imageFileNameAt(indexNow));
    await SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'image/*')]));
  }

  void recognizeQRCode() async {
    ToastProvider.running('识别中');
    try {
      final imageUrl = _imageUrlAt(indexNow);
      final imagePath = await StorageUtil.saveTempFileFromNetwork(imageUrl,
          filename: _imageFileNameAt(indexNow));
      String? qrResult = await QrCodeToolsPlugin.decodeFrom(imagePath);
      if (qrResult != null && qrResult.isNotEmpty) {
        if (await canLaunchUrl(Uri.parse(qrResult))) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return LakeDialogWidget(
                    title: '天外天工作室提示您',
                    titleTextStyle: TextUtil.base.normal
                        .infoText(context)
                        .NotoSansSC
                        .sp(22)
                        .w600,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' 你即将离开微北洋，去往：',
                          style: TextStyle(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.basicTextColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 6),
                          child: Text(qrResult,
                              style: qrResult.contains('b23.tv') ||
                                      qrResult.contains('bilibili.com')
                                  ? TextUtil.base.NotoSansSC
                                      .biliPink(context)
                                      .w600
                                      .h(1.6)
                                  : TextUtil.base.NotoSansSC
                                      .link(context)
                                      .w600
                                      .h(1.6)),
                        ),
                        Text(
                          ' 请注意您的账号和财产安全\n',
                          style: TextStyle(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.basicTextColor)),
                        ),
                      ],
                    ),
                    cancelText: "取消",
                    confirmTextStyle: TextUtil.base.normal
                        .bright(context)
                        .NotoSansSC
                        .sp(16)
                        .w600,
                    confirmButtonColor: qrResult.contains('b23.tv') ||
                            qrResult.contains('bilibili.com')
                        ? WpyTheme.of(context).get(WpyColorKey.biliPink)
                        : WpyTheme.of(context)
                            .get(WpyColorKey.primaryTextButtonColor),
                    cancelTextStyle: TextUtil.base.normal
                        .label(context)
                        .NotoSansSC
                        .sp(16)
                        .w400,
                    confirmText: "继续",
                    cancelFun: () {
                      Navigator.pop(context);
                    },
                    confirmFun: () async {
                      await launchUrl(Uri.parse(qrResult),
                          mode: qrResult.contains('b23.tv') ||
                                  qrResult.contains('bilibili.com')
                              ? LaunchMode.externalNonBrowserApplication
                              : LaunchMode.externalApplication);
                      Navigator.pop(context);
                    });
              });
        } else {
          ToastProvider.success("识别成功, 已将内容复制到剪贴板");
          Clipboard.setData(ClipboardData(text: qrResult));
        }
      }
    } catch (e) {
      if (e.toString().contains('Not found data')) {
        ToastProvider.error('未检测到二维码');
      } else {
        ToastProvider.error('识别失败');
      }
    }
  }
}
