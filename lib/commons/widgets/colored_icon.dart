import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColoredIcon extends StatelessWidget {
  final String path;
  final double? width;
  final Color? color;

  const ColoredIcon(this.path, {super.key, this.color, this.width});

  Future<ui.Image> loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer<ui.Image>();

    ui.decodeImageFromList(Uint8List.fromList(bytes), (ui.Image img) {
      completer.complete(img);
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = Image.asset(
      path,
      width: width,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.color,
    );

    // Return Directly to improve performance
    if (this.color == null) return defaultImage;

    // Load Image
    return FutureBuilder<ui.Image>(
      future: loadImageFromAssets(path),
      builder: (context, snapshot) {
        if (snapshot.hasData) // Crop the transparent background
          return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bound) {
                Matrix4 matrix = Matrix4.identity()
                  ..scale(
                    bound.height / snapshot.data!.height,
                    bound.width / snapshot.data!.width,
                  ); // Scale to the same size
                return ImageShader(
                  snapshot.data!,
                  TileMode.clamp,
                  TileMode.clamp,
                  matrix.storage,
                  filterQuality: FilterQuality.high,
                );
              },
              child: defaultImage);
        return defaultImage;
      },
    );
  }
}
