import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class OhosAvatarCrop extends StatefulWidget {
  const OhosAvatarCrop({super.key, required this.source});

  final File source;

  @override
  State<OhosAvatarCrop> createState() => _OhosAvatarCropState();
}

class _OhosAvatarCropState extends State<OhosAvatarCrop> {
  final _editor = GlobalKey<ExtendedImageEditorState>();
  bool _saving = false;

  Future<void> _save() async {
    final rect = _editor.currentState?.getCropRect();
    if (rect == null || rect.isEmpty) return;
    setState(() => _saving = true);
    try {
      final codec =
          await ui.instantiateImageCodec(await widget.source.readAsBytes());
      try {
        final image = (await codec.getNextFrame()).image;
        try {
          final size = math.min(512, rect.width.round()).clamp(1, 512).toInt();
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final bounds = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
          canvas.clipPath(Path()..addOval(bounds));
          canvas.drawImageRect(
              image, rect, bounds, Paint()..filterQuality = FilterQuality.high);
          final picture = recorder.endRecording();
          try {
            final cropped = await picture.toImage(size, size);
            try {
              final bytes =
                  await cropped.toByteData(format: ui.ImageByteFormat.png);
              if (bytes == null)
                throw StateError('Could not encode the avatar');
              final path =
                  '${StorageUtil.tempDir.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.png';
              final file =
                  await File(path).writeAsBytes(bytes.buffer.asUint8List());
              if (mounted) Navigator.pop(context, file);
            } finally {
              cropped.dispose();
            }
          } finally {
            picture.dispose();
          }
        } finally {
          image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } catch (_) {
      if (mounted) ToastProvider.error('图片裁剪失败');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('裁剪'),
          actions: [
            TextButton(
                onPressed: _saving ? null : _save, child: const Text('完成'))
          ],
        ),
        body: ExtendedImage.file(
          widget.source,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.editor,
          extendedImageEditorKey: _editor,
          initEditorConfigHandler: (_) => EditorConfig(cropAspectRatio: 1),
        ),
      );
}
