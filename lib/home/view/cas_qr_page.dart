import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:we_pei_yang_flutter/commons/network/cas_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/schedule_background.dart';

class RefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final refreshNotifier = RefreshNotifier();

class CasQRPage extends StatelessWidget {
  const CasQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: WpyTheme.of(context).brightness.uiOverlay.copyWith(
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor)),
      child: Stack(
        children: [
          ScheduleBackground(),
          Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.refresh_outlined,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                  ),
                  onPressed: () {
                    refreshNotifier.refresh();
                  },
                ),
                SizedBox(width: 10.w)
              ],
              centerTitle: true,
              title: Text(
                '入校码',
                style: TextUtil.base.NotoSansSC.label(context).w600.sp(18),
              ),
              elevation: 0,
            ),
            backgroundColor: WpyTheme.of(context)
                .get(WpyColorKey.primaryLightActionColor)
                .withOpacity(0.4),
            body: Center(
              child: QRRegionWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class QRRegionWidget extends StatefulWidget {
  const QRRegionWidget({super.key});

  @override
  State<QRRegionWidget> createState() => _QRRegionWidgetState();
}

class _QRRegionWidgetState extends State<QRRegionWidget> {
  String? qrContent = null;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(lastRefresh),
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lastRefresh == null
                      ? null
                      : WpyTheme.of(context)
                          .get(WpyColorKey.primaryActionColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  lastRefresh == null
                      ? ''
                      : '更新于 '
                          '${lastRefresh?.month ?? ""}月${lastRefresh?.day ?? ""}日 '
                          '${lastRefresh?.hour.toString() ?? ""}:${lastRefresh?.minute.toString().padLeft(2, '0') ?? ""}:${lastRefresh?.second.toString().padLeft(2, '0') ?? ""}',
                  style: TextUtil.base.PingFangSC.sp(22).bold.copyWith(
                        color: lastRefresh == null
                            ? Colors.grey[600]
                            : Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 300,
              child: AnimatedSwitcher(
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                duration: Duration(milliseconds: 300),
                child: qrContent == null
                    ? CircularProgressIndicator()
                    : SfBarcodeGenerator(
                        key: ValueKey(qrContent),
                        value: qrContent ?? '',
                        symbology: QRCode(),
                      ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '二维码3分钟有效, 自动刷新',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 5),
            Text(
              '如过期，请再点击“刷新”按钮',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              '解析自融合门户APP, 仅供参考',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? lastRefresh = null;
  int buzyCnt = 0;

  void _refresh() async {
    if (lastRefresh != null &&
        DateTime.now().difference(lastRefresh!) < Duration(seconds: 1)) return;

    ToastProvider.running('正在刷新');
    final sid = CommonPreferences.userNumber.value;
    qrContent = await CasService.getQRContent(sid);
    lastRefresh = DateTime.now();
    if (mounted) setState(() {});
  }

  late final Timer _periodUpdateCycle =
      Timer.periodic(Duration(minutes: 2, seconds: 30), (timer) {
    _refresh();
  });

  bool expectUpdate = false;

  @override
  void dispose() {
    super.dispose();
    _periodUpdateCycle.cancel();
  }

  @override
  void initState() {
    super.initState();
    refreshNotifier.addListener(() => _refresh());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _refresh());
  }
}
