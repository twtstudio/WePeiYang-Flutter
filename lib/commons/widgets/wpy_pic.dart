import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/SpoilerMask.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

/// 统一Button样式
/// 千万别改!!!!千万别改!!!改了就崩溃
class WpyPic extends StatefulWidget {
  WpyPic(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.withHolder = true,
    this.holderHeight = 40,
    this.withCache = true,
    this.alignment = Alignment.center,
    this.reduce = false,
    this.hide = false,
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

  final bool hide;

  static get errorPlaceHolder => Builder(builder: (context) {
        final background =
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
        final info = WpyTheme.of(context).get(WpyColorKey.infoTextColor);
        final secondaryInfo =
            WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor);
        return ColoredBox(
          color: background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 22,
                  color: secondaryInfo,
                ),
                SizedBox(height: 3),
                Center(
                  child: Text('加载失败',
                      style: TextUtil.base.customColor(info).w400.sp(11)),
                ),
              ],
            ),
          ),
        );
      });

  static Future<void> clearAllCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String cachePath = '${tempDir.path}/libCachedImageData';
      final cacheDir = Directory(cachePath);

      if (await cacheDir.exists()) {
        await for (final FileSystemEntity entity in cacheDir.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {}
  }

  @override
  _WpyPicState createState() => _WpyPicState();
}

class _WpyPicState extends State<WpyPic> {
  Widget _buildAsset(double? width, double? height) {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    } else {
      return Image.asset(
        widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    }
  }

  Widget _buildNetwork(double? width, double? height) {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.network(
        widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        alignment: widget.alignment,
        placeholderBuilder: widget.withHolder ? (_) => Loading() : null,
      );
    } else {
      final imageWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        alignment: widget.alignment,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        memCacheWidth: _cachePixelDimension(width),
        progressIndicatorBuilder: widget.withHolder
            ? (context, url, progress) {
                return _buildLoadingPlaceholder(width, height);
              }
            : null,
        errorWidget: (context, exception, stacktrace) {
          // Log.e(exception, stacktrace);
          return SizedBox(
            width: width ?? widget.holderHeight,
            height: height ?? widget.holderHeight,
            child: WpyPic.errorPlaceHolder,
          );
        },
      );

      final imageBuilder = () {
        if (widget.reduce && WpyTheme.of(context).brightness == Brightness.dark)
          return ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.2), // 调整这个透明度值来控制降低亮度的程度
              BlendMode.darken, // 使用darken混合模式来降低亮度
            ),
            child: imageWidget,
          );
        return imageWidget;
      };

      // xxx.jpg#tag1,tag2,tag3 or xxx.jpg
      if (!widget.imageUrl.contains('#')) {
        return imageBuilder();
      }

      final tags = widget.imageUrl.split('#')[1].split(',');
      if (tags.contains("masked")) {
        return SizedBox(
            height: height,
            width: width,
            child: SpoilerMaskImage(child: imageBuilder()));
      }
      return imageBuilder();
    }
  }

  int? _cachePixelDimension(double? logicalValue) {
    if (logicalValue == null || !logicalValue.isFinite || logicalValue <= 0) {
      return null;
    }
    final mediaQuery = MediaQuery.maybeOf(context);
    final devicePixelRatio = mediaQuery?.devicePixelRatio ??
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.devicePixelRatio;
    return (logicalValue * devicePixelRatio).round();
  }

  Widget _buildLoadingPlaceholder(double? width, double? height) {
    final background =
        WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor);
    final highlight =
        WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor);
    return SizedBox(
      width: width ?? widget.holderHeight,
      height: height ?? widget.holderHeight,
      child: Shimmer.fromColors(
        baseColor: background,
        highlightColor: highlight,
        child: ColoredBox(color: background),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = widget.width ??
          (constraints.hasTightWidth ? constraints.maxWidth : null);
      final height = widget.height ??
          (constraints.hasTightHeight ? constraints.maxHeight : null);

      if (widget.imageUrl.trim().isEmpty) {
        return SizedBox(
          width: width ?? widget.holderHeight,
          height: height ?? widget.holderHeight,
          child: WpyPic.errorPlaceHolder,
        );
      }

      if (widget.imageUrl.startsWith('assets')) {
        return Container(child: _buildAsset(width, height));
      } else {
        return Container(child: _buildNetwork(width, height));
      }
    });
  }
}
