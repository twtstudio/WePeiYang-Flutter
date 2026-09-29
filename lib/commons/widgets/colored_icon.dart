import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class ColoredIcon extends StatefulWidget {
  final String path;
  final double? width;
  final Color? color;

  ColoredIcon(this.path, {super.key, this.color, this.width});

  @override
  State<ColoredIcon> createState() => _ColoredIconState();
}

class _ColoredIconState extends State<ColoredIcon> {
  ui.Image? _image = null;

  static final _cache = <String, ui.Image>{};

  Future<void> loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final ui.FrameInfo fi = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _image = fi.image);
    _cache[assetPath] = fi.image;
  }

  @override
  void initState() {
    super.initState();
    if (_cache.containsKey(widget.path)) {
      _image = _cache[widget.path];
    } else
      loadImageFromAssets(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = Image.asset(
      widget.path,
      width: widget.width,
    );
    if (_image == null || this.widget.color == null) return defaultImage;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bound) {
        final realHeight = _image!.height;
        final realWidth = _image!.width;
        final imageRatio = realWidth / realHeight;
        var height = bound.height;
        var width = bound.width;
        double dw = 0;
        double dh = 0;
        // Display Contain Mode
        if (bound.width > bound.height * imageRatio) {
          final newWidth = bound.height * imageRatio;
          width = newWidth;
          height = bound.height;
          dw = bound.width - width;
          dh = 0;
        } else {
          final newHeight = bound.width / imageRatio;
          height = newHeight;
          width = bound.width;
          dw = 0;
          dh = bound.height - height;
        }
        Matrix4 matrix = Matrix4.identity()
          ..scaleByDouble(width / realWidth, height / realHeight, 1.0, 1.0)
          ..translateByDouble(dw, dh, 0.0, 1.0);

        return ImageShader(
          _image!,
          TileMode.clamp,
          TileMode.clamp,
          matrix.storage,
          filterQuality: FilterQuality.low,
        );
      },
      child: Builder(
        builder: (context) {
          final img = Image.asset(
            widget.path,
            width: widget.width,
            color: widget.color,
            colorBlendMode: widget.color == null ? null : BlendMode.color,
          );
          if (WpyTheme.of(context).brightness == Brightness.light) return img;
          return ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.2), // 调整这个透明度值来控制降低亮度的程度
                // 用 srcATop 而非 darken：srcATop 只在目标已有像素处叠加、不改变 alpha，
                // 透明区域仍透明。darken 会把完全透明的像素抬成 alpha=0.2 的黑，配合外层
                // ShaderMask(dstIn) 会在抗锯齿边缘留下一圈淡淡的暗色描边（深色模式下可见）。
                BlendMode.srcATop,
              ),
              child: img);
        },
      ),
    );
  }
}
