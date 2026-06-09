import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_pic/post_preview_pic.dart';
import '../../../commons/environment/config.dart';
import '../../../commons/util/text_util.dart';
import '../../../main.dart';
import '../../feedback_router.dart';
import '../components/widget/round_taggings.dart';
import '../image_view/image_view_page.dart';

final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
final radius = 4.r;

//内侧的单张图片
class InnerSinglePostPic extends StatefulWidget {
  final String imgUrl;

  InnerSinglePostPic({required this.imgUrl});

  @override
  _InnerSinglePostPicState createState() => _InnerSinglePostPicState();
}

class _InnerSinglePostPicState extends State<InnerSinglePostPic> {
  late final CachedNetworkImageProvider _imageProvider;
  ui.Image? _imageInfo;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFullView = false;

  @override
  void initState() {
    super.initState();
    _imageProvider = CachedNetworkImageProvider(
      picBaseUrl + 'origin/' + widget.imgUrl,
    );
    _loadImageInfo();
  }

  void _loadImageInfo() {
    _imageProvider
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener(
      (info, syncCall) {
        if (syncCall) {
          _imageInfo = info.image;
          _isLoading = false;
        } else {
          if (!mounted) return;
          setState(() {
            _imageInfo = info.image;
            _isLoading = false;
          });
        }
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        if (_hasError) {
          return _buildErrorHint(layout.maxWidth);
        }
        if (_isLoading || _imageInfo == null) {
          return _buildPlaceholder(layout.maxWidth);
        }

        final devicePixelRatio =
            MediaQuery.of(context).devicePixelRatio;
        final resizedProvider = ResizeImage(
          _imageProvider,
          width: (layout.maxWidth * devicePixelRatio).round(),
        );
        final image = Image(
          image: resizedProvider,
          width: layout.maxWidth,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        );

        final isLongImage =
            _imageInfo!.height / _imageInfo!.width > 2.0;

        if (isLongImage) {
          return AnimatedSize(
            duration: Duration(milliseconds: 250),
            child: _isFullView
                ? _buildExpandedImageView(context, image)
                : _buildCollapsedImageView(context, image),
          );
        } else {
          return _buildRegularImageView(context, image);
        }
      },
    );
  }

  Widget _buildPlaceholder(double width) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Builder(builder: (context) {
          return Shimmer.fromColors(
            child: Container(
              color: Colors.black12,
              width: width,
              height: width,
            ),
            baseColor:
                WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
            highlightColor:
                WpyTheme.of(context).get(WpyColorKey.infoTextColor),
          );
        }));
  }

  Widget _buildExpandedImageView(BuildContext context, Image image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              FeedbackRouter.imageView,
              arguments:
                  ImageViewPageArgs([widget.imgUrl], 1, 0, true),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 2,
              ),
              child: ClipRect(child: image),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isFullView = false),
          child: Text(
            '收起',
            style: TextUtil.base.textButtonPrimary(context).w600.NotoSansSC
                .sp(14),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedImageView(BuildContext context, Image image) {
    return SizedBox(
      height: WePeiYangApp.screenWidth * 1.2,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                FeedbackRouter.imageView,
                arguments:
                    ImageViewPageArgs([widget.imgUrl], 1, 0, true),
              ),
              child: image,
            ),
            Positioned(
              top: 8,
              left: 8,
              child: TextPod('长图'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () => setState(() => _isFullView = true),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0, -0.7),
                      end: Alignment(0, 1),
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16)),
                        ),
                        padding:
                            EdgeInsets.fromLTRB(12, 4, 10, 6),
                        child: Text(
                          '长图模式',
                          style: TextUtil.base.w300
                              .bright(context)
                              .sp(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularImageView(BuildContext context, Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          FeedbackRouter.imageView,
          arguments:
              ImageViewPageArgs([widget.imgUrl], 1, 0, false),
        ),
        child: image,
      ),
    );
  }

  Widget _buildErrorHint(double maxWidth) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          width: maxWidth,
          height: maxWidth / 3,
          child: WpyPic.errorPlaceHolder,
        ));
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
      return SizedBox.shrink();
    } else if (imgUrls.length == 1) {
      return InnerSinglePostPic(imgUrl: imgUrls[0]);
    } else {
      return InnerMultiPostPic(imgUrls: imgUrls);
    }
  }
}
