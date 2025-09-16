import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/network/image_cache_service.dart';

class MapCalendarPage extends StatefulWidget {
  const MapCalendarPage({super.key});

  @override
  MapCalenderState createState() => MapCalenderState();
}

class MapCalenderState extends State<MapCalendarPage> {
  MapCalenderState();

  static const imageUrls = <String>[
    'https://qnhdpic.twt.edu.cn/map/byy', // 0 北洋园
    'https://qnhdpic.twt.edu.cn/map/wjl', // 1 卫津路
    'https://qnhdpic.twt.edu.cn/calendar/1', // 2 第一学期
    'https://qnhdpic.twt.edu.cn/calendar/2', // 3 第二学期
  ];

  Future<void>? _prefetch;
  List<File?> _files = List<File?>.filled(4, null, growable: false);

  @override
  void initState() {
    super.initState();
    _prefetch = _loadAndCacheAll();
  }

  Future<void> _loadAndCacheAll() async {
    _dlog('[MapCalendarPage] Prefetch start');
    await ImageCacheService.instance.ensureAllCached(imageUrls);
    final list = await Future.wait<File?>(
      imageUrls.map((u) => ImageCacheService.instance.getLocalFileIfExists(u)),
    );
    for (int i = 0; i < list.length; i++) {
      _dlog(
          '[MapCalendarPage] file[$i]=${list[i]?.path} exists=${list[i] != null && list[i]!.existsSync()}');
    }
    if (mounted) {
      setState(() => _files = list);
    }
    _dlog('[MapCalendarPage] Prefetch done');
  }

  Future<void> _openMapGallery(int initialIndex) async {
    final wjl =
        await ImageCacheService.instance.getLocalFileIfExists(imageUrls[1]);
    final byy =
        await ImageCacheService.instance.getLocalFileIfExists(imageUrls[0]);
    _dlog('[MapCalendarPage] onOpenMapGallery initialIndex=$initialIndex');
    _dlog(
        '[MapCalendarPage] wjl=${wjl?.path} exists=${wjl != null && wjl.existsSync()}');
    _dlog(
        '[MapCalendarPage] byy=${byy?.path} exists=${byy != null && byy.existsSync()}');

    if (wjl != null && byy != null) {
      if (!mounted) return;
      final uriList = [wjl, byy];
      _dlog('[MapCalendarPage] push gallery, uriListLen=${uriList.length}');
      Navigator.pushNamed(
        context,
        FeedbackRouter.localImageView,
        arguments:
            LocalImageViewPageArgs(uriList, [], uriList.length, initialIndex),
      );
    } else {
      _showSnack('图片还在准备中，请稍后再试');
    }
  }

  Future<void> _openCalendarGallery(int initialIndex) async {
    final first =
        await ImageCacheService.instance.getLocalFileIfExists(imageUrls[2]);
    final second =
        await ImageCacheService.instance.getLocalFileIfExists(imageUrls[3]);
    _dlog('[MapCalendarPage] onOpenCalendarGallery initialIndex=$initialIndex');
    _dlog(
        '[MapCalendarPage] cal1=${first?.path} exists=${first != null && first.existsSync()}');
    _dlog(
        '[MapCalendarPage] cal2=${second?.path} exists=${second != null && second.existsSync()}');

    if (first != null && second != null) {
      if (!mounted) return;
      final uriList = [first, second];
      _dlog('[MapCalendarPage] push gallery, uriListLen=${uriList.length}');
      Navigator.pushNamed(
        context,
        FeedbackRouter.localImageView,
        arguments:
            LocalImageViewPageArgs(uriList, [], uriList.length, initialIndex),
      );
    } else {
      _showSnack('图片还在准备中，请稍后再试');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        titleSpacing: 0,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('地图·校历',
            style: TextUtil.base.NotoSansSC.label(context).w600.sp(18)),
        elevation: 0,
      ),
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      body: FutureBuilder<void>(
        future: _prefetch,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: MapAndCalender(
                files: _files,
                loading: loading,
                onOpenMapGallery: _openMapGallery,
                onOpenCalendarGallery: _openCalendarGallery,
              ),
            ),
          );
        },
      ),
    );
  }

  void _dlog(Object? o) {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    // ignore: avoid_print
    print('$hh:$mm:$ss | $o');
  }
}

class MapAndCalender extends StatefulWidget {
  const MapAndCalender({
    super.key,
    this.files,
    this.loading,
    this.onOpenMapGallery,
    this.onOpenCalendarGallery,
  });

  final List<File?>? files; // [byy, wjl, cal1, cal2]
  final bool? loading;
  final Future<void> Function(int initialIndex)? onOpenMapGallery;
  final Future<void> Function(int initialIndex)? onOpenCalendarGallery;

  @override
  State<MapAndCalender> createState() => MapAndCalenderState();
}

class MapAndCalenderState extends State<MapAndCalender> {
  List<File?> _files = List<File?>.filled(4, null, growable: false);
  bool _internalLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.files != null) {
      _files = widget.files!;
      _internalLoading = widget.loading ?? false;
    }
  }

  @override
  void didUpdateWidget(covariant MapAndCalender oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.files != oldWidget.files && widget.files != null) {
      setState(() {
        _files = widget.files!;
        _internalLoading = widget.loading ?? false;
      });
    }
  }

  BoxDecoration cardDecoration(ctx) => BoxDecoration(
        color: WpyTheme.of(ctx).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 8,
            color: WpyTheme.of(ctx)
                .get(WpyColorKey.basicTextColor)
                .withOpacity(0.05),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final byy = _files[0];
    final wjl = _files[1];
    final cal1 = _files[2];
    final cal2 = _files[3];

    final loading = widget.loading ?? _internalLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 28.w),
          child: Text('校园地图',
              style: TextUtil.base.PingFangSC.primary(context).bold.sp(14)),
        ),
        SizedBox(
          height: 126.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.h),
            children: [
              WButton(
                onPressed: () => (widget.onOpenMapGallery ?? (_) async {})(0),
                child: _ImageCardWithOverlay(
                  file: wjl,
                  width: 250.h,
                  height: 100.h,
                  margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                  loading: loading,
                  label: '卫津路校区',
                  overlayColor: Colors.white.withOpacity(0.9), // màu mờ mờ
                  textColor: Colors.black,
                ),
              ),
              WButton(
                onPressed: () => (widget.onOpenMapGallery ?? (_) async {})(1),
                child: _ImageCardWithOverlay(
                  file: byy,
                  width: 250.h,
                  height: 100.h,
                  margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                  loading: loading,
                  label: '北洋园校区',
                  overlayColor: Colors.white.withOpacity(0.9),
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 28.w),
          child: Text('校历',
              style: TextUtil.base.PingFangSC.primary(context).bold.sp(14)),
        ),
        SizedBox(
          height: 126.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.h),
            children: [
              WButton(
                onPressed: () =>
                    (widget.onOpenCalendarGallery ?? (_) async {})(0),
                child: _ImageCardWithOverlay(
                  file: cal1,
                  width: 250.h,
                  height: 100.h,
                  margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                  loading: loading,
                  label: '25-26第一学期',
                  overlayColor: Colors.white.withOpacity(0.9),
                  textColor: Colors.black,
                ),
              ),
              WButton(
                onPressed: () =>
                    (widget.onOpenCalendarGallery ?? (_) async {})(1),
                child: _ImageCardWithOverlay(
                  file: cal2,
                  width: 250.h,
                  height: 100.h,
                  margin: EdgeInsets.fromLTRB(0, 10.h, 18.h, 16.h),
                  loading: loading,
                  label: '25-26第二学期',
                  overlayColor: Colors.white.withOpacity(0.9),
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget card ảnh + overlay mờ + label
class _ImageCardWithOverlay extends StatelessWidget {
  final File? file;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final bool loading;
  final String label;
  final Color overlayColor;
  final Color textColor;

  const _ImageCardWithOverlay({
    required this.file,
    required this.width,
    required this.height,
    required this.margin,
    required this.loading,
    required this.label,
    required this.overlayColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null && file!.existsSync();
    return Container(
      width: width,
      height: height,
      margin: margin,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 8,
            color: WpyTheme.of(context)
                .get(WpyColorKey.basicTextColor)
                .withOpacity(0.05),
          ),
        ],
      ),
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  file!,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: overlayColor,
                ),
                Positioned(
                  top: 20.h,
                  left: 14.h,
                  child: Opacity(
                    opacity: 0.34,
                    child: Text(
                      label,
                      style: TextUtil.base.PingFangSC
                          .infoText(context)
                          .w900
                          .sp(22)
                          .copyWith(color: textColor),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryLightestActionColor),
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.basicTextColor)
                          .withOpacity(0.25),
                    ),
            ),
    );
  }
}
