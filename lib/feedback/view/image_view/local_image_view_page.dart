import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

import '../../../commons/widgets/w_button.dart';

class LocalImageViewPageArgs {
  final List<File> uriList;
  final List<String> assetList;
  final int uriListLength;
  final int indexNow;

  LocalImageViewPageArgs(
    this.uriList,
    this.assetList,
    int countOrIndex, [
    int? indexNow,
  ])  : uriListLength = countOrIndex,
        indexNow = indexNow ?? countOrIndex;

  int get imageCount => uriList.isNotEmpty ? uriList.length : assetList.length;
}

class LocalImageViewPage extends StatefulWidget {
  final LocalImageViewPageArgs args;

  const LocalImageViewPage(this.args, {Key? key}) : super(key: key);

  @override
  State<LocalImageViewPage> createState() => _LocalImageViewPageState();
}

class _LocalImageViewPageState extends State<LocalImageViewPage> {
  bool _loading = true;
  bool _loadFailed = false;
  late int _index;
  late PageController _pageController;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _index = _clampIndex(widget.args.indexNow);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecache) return;
    _didPrecache = true;

    if (widget.args.imageCount == 0) {
      _loading = false;
      _loadFailed = true;
      return;
    }

    unawaited(_preloadImage(_index));
  }

  int _clampIndex(int index) {
    final imageCount = widget.args.imageCount;
    if (imageCount <= 0 || index < 0) return 0;
    if (index >= imageCount) return imageCount - 1;
    return index;
  }

  ImageProvider _imageProviderAt(int index) {
    final safeIndex = _clampIndex(index);
    if (widget.args.uriList.isNotEmpty) {
      return FileImage(widget.args.uriList[safeIndex]);
    }
    return AssetImage(widget.args.assetList[safeIndex]);
  }

  Future<void> _preloadImage(int index) async {
    if (widget.args.imageCount == 0) return;
    final provider = _imageProviderAt(index);

    try {
      await precacheImage(provider, context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _loadFailed = false;
      });
    }
  }

  void _onPageChanged(int index) {
    _index = _clampIndex(index);
    unawaited(_preloadImage(_index));
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;

    if (_loading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                '马上好啦^^...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadFailed) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            '图片加载失败',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return WButton(
      onPressed: () => Navigator.pop(context),
      child: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.args.imageCount,
        onPageChanged: _onPageChanged,
        backgroundDecoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor),
        ),
        loadingBuilder: (context, event) {
          final value = event == null || event.expectedTotalBytes == null
              ? 0.0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!;

          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(value: value),
            ),
          );
        },
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: _imageProviderAt(index),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 5.0,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
