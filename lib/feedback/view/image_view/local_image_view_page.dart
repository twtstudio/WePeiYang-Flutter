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
      this.uriListLength,
      this.indexNow,
      );
}

class LocalImageViewPage extends StatefulWidget {
  final LocalImageViewPageArgs args;

  const LocalImageViewPage(this.args, {Key? key}) : super(key: key);

  @override
  State<LocalImageViewPage> createState() => _LocalImageViewPageState();
}

class _LocalImageViewPageState extends State<LocalImageViewPage> {
  bool _loading = true;
  late int _index;
  late PageController _pageController;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _index = widget.args.indexNow;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecache) return;
    _didPrecache = true;

    _preloadImage(_index);
  }

  Future<void> _preloadImage(int index) async {
    ImageProvider provider;

    if (widget.args.uriList.isNotEmpty) {
      provider = FileImage(widget.args.uriList[index]);
    } else {
      provider = AssetImage(widget.args.assetList[index]);
    }

    await precacheImage(provider, context);

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    _index = index;
    _preloadImage(index);
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

    return WButton(
      onPressed: () => Navigator.pop(context),
      child: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.args.uriListLength,
        onPageChanged: _onPageChanged,
        backgroundDecoration: BoxDecoration(
          color: WpyTheme.of(context)
              .get(WpyColorKey.reverseBackgroundColor),
        ),
        loadingBuilder: (context, event) {
          final value = event == null ||
              event.expectedTotalBytes == null
              ? 0.0
              : event.cumulativeBytesLoaded /
              event.expectedTotalBytes!;

          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(value: value),
            ),
          );
        },
        builder: (BuildContext context, int index) {
          ImageProvider image;

          if (widget.args.uriList.isNotEmpty) {
            image = FileImage(widget.args.uriList[index]);
          } else {
            image = AssetImage(widget.args.assetList[index]);
          }

          return PhotoViewGalleryPageOptions(
            imageProvider: image,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 5.0,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
      ),
    );
  }
}