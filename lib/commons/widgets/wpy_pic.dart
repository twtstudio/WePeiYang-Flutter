// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

/// 统一Button样式
class WpyPic extends StatefulWidget {
  WpyPic(
    this.res, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.withHolder = false,
    this.withCache = true,
  }) : super(key: key);

  final String res;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool withHolder;
  final bool withCache;

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
      );
    } else {
      return Image.asset(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
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
        placeholderBuilder: widget.withHolder ? (_) => Loading() : null,
      );
    } else {
      return Image.network(
        widget.res,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: widget.withHolder
            ? (context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                double? value;
                if (loadingProgress.expectedTotalBytes != null) {
                  value = loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!;
                }
                return Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.black26,
                  child: Center(
                    child: SizedBox(
                        width:
                            widget.width == null ? 20 : widget.width! * 0.25,
                        height:
                        widget.width == null ? 20 : widget.width! * 0.25,
                        child: CircularProgressIndicator(value: value)),
                  ),
                );
              }
            : null,
        errorBuilder: widget.withHolder
            ? (context, exception, stacktrace) =>
                Text('💔[图片加载失败]', style: TextUtil.base.grey6C.w400.sp(12))
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
