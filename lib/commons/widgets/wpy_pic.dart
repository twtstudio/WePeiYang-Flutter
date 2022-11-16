// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart' hide Logger;
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

/// 统一Button样式
class WpyPic extends StatefulWidget {
  WpyPic(this.res,
      {Key? key,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.withHolder = false,
      this.holderHeight = 40,
      this.withCache = true,
      this.alignment = Alignment.center})
      : super(key: key);

  final String res;
  final double? width;
  final double? height;
  final double holderHeight;
  final BoxFit fit;
  final bool withHolder;
  final bool withCache;
  final Alignment alignment;

  @override
  _WpyPicState createState() => _WpyPicState();
}

class _WpyPicState extends State<WpyPic> {
  Widget get asset {
    if (widget.res.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    } else {
      return Image.asset(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    }
  }

  Widget get network {
    if (widget.res.endsWith('.svg')) {
      return SvgPicture.network(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        placeholderBuilder: widget.withHolder ? (_) => Loading() : null,
      );
    } else {
      return Image.network(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        loadingBuilder: widget.withHolder
            ? (context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                double? value;
                if (loadingProgress.expectedTotalBytes != null) {
                  value = loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!;
                }
                return Container(
                  width: widget.width ?? widget.holderHeight,
                  height: widget.height ?? widget.holderHeight,
                  color: Colors.black26,
                  child: Center(
                    child: SizedBox(
                        width: widget.width == null ? 20 : widget.width! * 0.25,
                        height:
                            widget.width == null ? 20 : widget.width! * 0.25,
                        child: CircularProgressIndicator(value: value)),
                  ),
                );
              }
            : null,
        errorBuilder: widget.withHolder
            ? (context, exception, stacktrace) {
                Logger.reportError(exception, stacktrace);
                return Text('💔[图片加载失败]',
                    style: TextUtil.base.grey6C.w400.sp(12));
              }
            : null,
      );
    }
  }

  Widget get cachedNetwork => SizedBox(
        width: widget.width,
        height: widget.height,
        child: OptimizedCacheImage(
          imageUrl: widget.res,
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
    if (widget.res.startsWith('assets')) {
      return asset;
      // } else if (widget.withCache) {
      //   return cachedNetwork;
    } else {
      return network;
    }
  }
}
