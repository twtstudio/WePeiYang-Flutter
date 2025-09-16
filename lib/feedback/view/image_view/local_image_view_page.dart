import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

import '../../../commons/widgets/w_button.dart';

/// - true: 使用resized，虚拟机适用
/// - false: 不使用resized，实机可以看清楚
const bool kUseResizeInViewer = false;

const bool kNoUpscale = true;

const int kMaxDecodeEdge = 2048;

class LocalImageViewPageArgs {
  final List<File> uriList;
  final List<String> assetList;
  final int uriListLength;
  final int indexNow;

  LocalImageViewPageArgs(
      this.uriList, this.assetList, this.uriListLength, this.indexNow);
}

class LocalImageViewPage extends StatefulWidget {
  final LocalImageViewPageArgs args;

  LocalImageViewPage(this.args) {
    _dlog('[LocalImageViewPage] ctor uriListLen=${args.uriList.length} '
        'assetListLen=${args.assetList.length} '
        'uriListLength(field)=${args.uriListLength} indexNow=${args.indexNow}');
    for (int i = 0; i < args.uriList.length; i++) {
      final f = args.uriList[i];
      _dlog(
          '[LocalImageViewPage] uri[$i]=${f.path} exists=${f.existsSync()} size=${f.existsSync() ? f.lengthSync() : -1}');
    }
    for (int i = 0; i < args.assetList.length; i++) {
      _dlog('[LocalImageViewPage] asset[$i]=${args.assetList[i]}');
    }
  }

  @override
  _LocalImageViewPageState createState() => _LocalImageViewPageState();
}

class _LocalImageViewPageState extends State<LocalImageViewPage> {
  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;

    final realLen = widget.args.uriList.isNotEmpty
        ? widget.args.uriList.length
        : widget.args.assetList.length;
    final itemCount =
        realLen == 0 ? 0 : widget.args.uriListLength.clamp(1, realLen);
    final initialIndex =
        widget.args.indexNow.clamp(0, realLen == 0 ? 0 : realLen - 1);

    _dlog(
        '[LocalImageViewPage] build itemCount=$itemCount initialIndex=$initialIndex realLen=$realLen');

    return WButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Container(
        child: PhotoViewGallery.builder(
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: (event == null || event.expectedTotalBytes == null)
                    ? null
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
          itemCount: itemCount,
          backgroundDecoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor),
          ),
          pageController: PageController(initialPage: initialIndex),
          scrollDirection: Axis.horizontal,
          builder: (BuildContext context, int index) {
            try {
              _dlog('[LocalImageViewPage] builder index=$index');

              // Lưu ý: file gốc dùng 2 if liên tiếp -> nếu cả hai list đều non-empty, Asset sẽ ghi đè File.
              // Để giữ hành vi cũ, vẫn giữ 2 if (không else-if).
              late ImageProvider image;

              if (widget.args.uriList.isNotEmpty) {
                final file = widget.args.uriList[index];
                if (kUseResizeInViewer) {
                  final sz = MediaQuery.sizeOf(context);
                  final ratio = MediaQuery.devicePixelRatioOf(context);
                  final targetW =
                      (sz.width * ratio).clamp(320, kMaxDecodeEdge).toInt();
                  final targetH =
                      (sz.height * ratio).clamp(320, kMaxDecodeEdge).toInt();
                  _dlog(
                      '[LocalImageViewPage] ResizeImage -> ${file.path} w=$targetW h=$targetH');
                  image = ResizeImage(FileImage(file),
                      width: targetW, height: targetH);
                } else {
                  _dlog('[LocalImageViewPage] FileImage (HQ) -> ${file.path}');
                  image = FileImage(file);
                }
              }

              if (widget.args.assetList.isNotEmpty) {
                final asset = widget.args.assetList[index];
                _dlog(
                    '[LocalImageViewPage] AssetImage $asset (overrides if both lists provided)');
                image = AssetImage(asset);
              }

              //
              if (realLen == 0) {
                _dlog('[LocalImageViewPage][WARN] both lists empty');
                return PhotoViewGalleryPageOptions.customChild(
                  child: const Center(child: Text('No image')),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained,
                );
              }

              // scale
              final base = PhotoViewComputedScale.contained;
              final minScale = base;
              final maxScale = kNoUpscale ? base : base * 5.0;

              return PhotoViewGalleryPageOptions(
                imageProvider: image,
                minScale: minScale,
                maxScale: maxScale,
                initialScale: base,
                filterQuality: FilterQuality.medium,
                basePosition: Alignment.center,
              );
            } catch (e, st) {
              _dlog('[LocalImageViewPage][ERROR] index=$index e=$e\n$st');
              // Fallback an toàn để không làm văng app
              final base = PhotoViewComputedScale.contained;
              return PhotoViewGalleryPageOptions.customChild(
                child: const Center(
                    child:
                        Text('加载图片出错', style: TextStyle(color: Colors.white))),
                minScale: base,
                maxScale: base,
              );
            }
          },
        ),
      ),
    );
  }
}

void _dlog(Object? o) {
  final now = DateTime.now();
  final hh = now.hour.toString().padLeft(2, '0');
  final mm = now.minute.toString().padLeft(2, '0');
  final ss = now.second.toString().padLeft(2, '0');
  // ignore: avoid_print
  print('$hh:$mm:$ss | $o');
}
