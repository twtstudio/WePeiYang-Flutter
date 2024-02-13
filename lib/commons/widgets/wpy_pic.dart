import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

/// 统一Button样式
class WpyPic extends StatefulWidget {
  WpyPic(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.withHolder = false,
    this.holderHeight = 40,
    this.withCache = true,
    this.alignment = Alignment.center,
    this.reduce = false,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final double holderHeight;
  final BoxFit fit;
  final bool withHolder;
  final bool withCache;
  final Alignment alignment;
  final bool reduce;

  @override
  _WpyPicState createState() => _WpyPicState();
}

class _WpyPicState extends State<WpyPic> {
  Widget get asset {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    } else {
      return Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    }
  }

  Widget get network {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        placeholderBuilder: widget.withHolder ? (_) => Loading() : null,
      );
    } else {
      final imageWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        progressIndicatorBuilder: widget.withHolder
            ? (context, url, progress) {
                return Container(
                  width: widget.width ?? widget.holderHeight,
                  height: widget.height ?? widget.holderHeight,
                  color: WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
                  child: Center(
                    child: SizedBox(
                        width: widget.width == null ? 20 : widget.width! * 0.25,
                        height:
                            widget.width == null ? 20 : widget.width! * 0.25,
                        child: CircularProgressIndicator(
                          value: progress.progress,
                          color: WpyTheme.of(context).primary,
                        )),
                  ),
                );
              }
            : null,
        errorWidget: widget.withHolder
            ? (context, exception, stacktrace) {
                Logger.reportError(exception, stacktrace);
                return Text('💔[图片加载失败]',
                    style: TextUtil.base.infoText(context).w400.sp(12));
              }
            : null,
      );

      if (widget.reduce && WpyTheme.of(context).brightness == Brightness.dark)
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.2), // 调整这个透明度值来控制降低亮度的程度
            BlendMode.darken, // 使用darken混合模式来降低亮度
          ),
          child: imageWidget,
        );
      else
        return imageWidget;
    }
  }

  Widget get cachedNetwork => SizedBox(
        width: widget.width,
        height: widget.height,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          placeholder: (context, url) => CupertinoActivityIndicator(),
          errorWidget: (context, url, error) {
            print('v_image error: $error');
            return Icon(Icons.error);
          },
          fit: widget.fit,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.startsWith('assets')) {
      return asset;
      // } else if (widget.withCache) {
      //   return cachedNetwork;
    } else {
      return network;
    }
  }
}
