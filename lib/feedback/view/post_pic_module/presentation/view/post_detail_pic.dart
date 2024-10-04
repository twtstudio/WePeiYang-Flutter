import 'dart:async';
import 'dart:ui'as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_pic_module/presentation/view/post_preview_pic.dart';
import '../../../../../commons/environment/config.dart';
import '../../../../../commons/util/text_util.dart';
import '../../../../../main.dart';
import '../../../../feedback_router.dart';
import '../../../components/widget/round_taggings.dart';
import '../../../image_view/image_view_page.dart';

final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
final radius = 4.r;

//内侧的单张图片
class InnerSinglePostPic extends StatelessWidget {
  final String imgUrl;
  final ValueNotifier<bool> isFullView = ValueNotifier(false);
  InnerSinglePostPic({required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, layout) {
      return ValueListenableBuilder(
          valueListenable: isFullView, builder: (BuildContext context, bool value, Widget? child) {
        return LayoutBuilder(builder: (context, layout) {
          /// 计算长图
          Completer<ui.Image> completer = Completer<ui.Image>();

          // 这个不能替换成 WpyPic
          // (考古)WTF
          Image image = Image.network(
            picBaseUrl + 'origin/' + imgUrl,
            width: layout.maxWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          );

          /// 计算长图
          if (!completer.isCompleted) {
            image.image
                .resolve(ImageConfiguration())
                .addListener(ImageStreamListener((ImageInfo info, bool _) {
              if (!completer.isCompleted) completer.complete(info.image);
            }));
          }

          /// 计算长图
          return FutureBuilder<ui.Image>(
            future: completer.future,
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              return Container(
                padding: EdgeInsets.only(
                  top: 0,
                  left: 16.w,
                  right: 16.w,
                  bottom: 8.w,
                ),
                child: snapshot.hasData
                    ? snapshot.data!.height / snapshot.data!.width > 2.0
                    ? isFullView.value
                    ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(radius)),
                        child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              FeedbackRouter.imageView,
                              arguments: ImageViewPageArgs(
                                  [imgUrl], 1, 0, true),
                            ),
                            child: image
                        ),
                      ),
                      TextButton(
                          style: ButtonStyle(
                              alignment: Alignment.topRight,
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.zero),
                              overlayColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: () {
                            isFullView.value = false;
                          },
                          child: Text('收起',
                              style: TextUtil.base
                                  .textButtonPrimary(context)
                                  .w600
                                  .NotoSansSC
                                  .sp(14)))
                    ])
                    : SizedBox(
                    height: WePeiYangApp.screenWidth * 1.2,
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.all(Radius.circular(radius)),
                      child: Stack(children: [
                        GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              FeedbackRouter.imageView,
                              arguments: ImageViewPageArgs(
                                  [imgUrl], 1, 0, true),
                            ),
                            child: image),
                        Positioned(top: 8, left: 8, child: TextPod('长图')),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                                onTap: () {
                                  isFullView.value = true;
                                },
                                child: Container(
                                    height: 60,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(0, -0.7),
                                        end: Alignment(0, 1),
                                        colors: [
                                          Colors.transparent,
                                          Colors.black54,
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(width: 10),
                                          Text(
                                            '点击展开\n',
                                            style: TextUtil.base.w600
                                                .bright(context)
                                                .sp(14)
                                                .h(0.6),
                                          ),
                                          Spacer(),
                                          Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  borderRadius:
                                                  BorderRadius.only(
                                                      topLeft: Radius
                                                          .circular(
                                                          16))),
                                              padding:
                                              EdgeInsets.fromLTRB(
                                                  12, 4, 10, 6),
                                              child: Text(
                                                '长图模式',
                                                style: TextUtil.base.w300
                                                    .bright(context)
                                                    .sp(12),
                                              ))
                                        ]))))
                      ]),
                    ))
                    : ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        FeedbackRouter.imageView,
                        arguments: ImageViewPageArgs(
                            [imgUrl], 1, 0, false),
                      ),
                      child: image),
                )
                    :
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  child: Container(
                    color: Colors.transparent,
                    width: layout.maxWidth,
                    height: layout.maxWidth*3,
                  ),
                ),
                color: snapshot.hasData ? Colors.transparent : Colors.black12,
              );
            },
          );
        });
      }
      );
    });
  }
}

class InnerMultiPostPic extends StatelessWidget {
  final List<String> imgUrls;

  const InnerMultiPostPic({Key? key, required this.imgUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OuterMultiPostPic(imgUrls: imgUrls, isOuter: false);
  }
}

class PostDetailPic extends StatelessWidget {
  final List<String> imgUrls;
  const PostDetailPic({Key? key, required this.imgUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imgUrls.length == 0) {
      return Container();
    }
    else if (imgUrls.length == 1) {
      return InnerSinglePostPic(imgUrl: imgUrls[0]);
    }
    else {
      return InnerMultiPostPic(imgUrls: imgUrls);
    }
  }
}