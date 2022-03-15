// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/time_check.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';

class LoungeBasePage extends StatefulWidget {
  final Widget body;
  final EdgeInsets padding;

  const LoungeBasePage({
    Key? key,
    required this.body,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<LoungeBasePage> createState() => _LoungeBasePageState();
}

class _LoungeBasePageState extends State<LoungeBasePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: const Size(360, 690),
      orientation: Orientation.portrait,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget appbar = AppBar(
      titleSpacing: 0,
      leadingWidth: 50.w,
      elevation: 0,
      toolbarHeight: 60.w,
      leading: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(50.w, 50.w),
          primary: Colors.transparent,
          onPrimary: Colors.transparent,
          onSurface: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Icon(
          Icons.arrow_back,
          size: 26.w,
          color: Theme.of(context).baseIconColor,
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: const [_ErrorAlert(), TimeCheckWidget()],
    );

    appbar = Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Hero(
        tag: 'appbar',
        transitionOnUserGestures: true,
        child: appbar,
      ),
    );

    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: Theme.of(context).baseBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.w),
          child: appbar,
        ),
        body: Padding(
          padding: widget.padding,
          child: widget.body,
        ),
      );
    });
  }
}

class _ErrorAlert extends StatelessWidget {
  const _ErrorAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataState = context.select((BuildingData data) => data.dataState);
    final loadState = context.select((BuildingData data) => data.loadState);

    return Visibility(
      visible: !dataState.isUpdated && !loadState.isBusy,
      child: SizedBox(
        width: 50.w,
        child: InkWell(
          child: Icon(Icons.warning, color: Colors.red),
          onTap: () {
            ToastProvider.error(dataState.error.toString());
          },
        ),
      ),
    );
  }
}
