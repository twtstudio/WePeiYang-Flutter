import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class ColoredIcon extends StatelessWidget {
  final String path;
  final double? width;
  final Color? color;

  ColoredIcon(this.path, {super.key, this.color, this.width}) {
    loadImageFromAssets(this.path);
  }

  final _image = ValueNotifier<ui.Image?>(null);

  Future<void> loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final ui.FrameInfo fi = await codec.getNextFrame();
    _image.value = fi.image;
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = Image.asset(
      path,
      width: width,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.color,
    );

    final widget = ValueListenableBuilder<ui.Image?>(
      valueListenable: _image,
      child: defaultImage,
      builder: (context, value, child) {
        if (value == null || this.color == null) return child!;
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bound) {
            Matrix4 matrix = Matrix4.identity()
              ..scale(bound.height / value.height,
                  bound.width / value.width); // Scale to the same size

            return ImageShader(
                value, TileMode.clamp, TileMode.clamp, matrix.storage,
                filterQuality: FilterQuality.high);
          },
          child: Builder(
            builder: (context) {
              final img = Image.asset(
                path,
                width: width,
                color: color,
                colorBlendMode: color == null ? null : BlendMode.color,
              );
              if (WpyTheme.of(context).brightness == Brightness.light)
                return img;
              return ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), // 调整这个透明度值来控制降低亮度的程度
                    BlendMode.darken, // 使用darken混合模式来降低亮度
                  ),
                  child: img);
            },
          ),
        );
      },
    );
    return widget;
  }
}
