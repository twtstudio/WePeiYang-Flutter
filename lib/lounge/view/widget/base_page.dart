// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/time_check.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';

class LoungeBasePage extends StatefulWidget {
  final Widget body;
  final EdgeInsets padding;
  final bool isOutside;

  const LoungeBasePage({
    Key? key,
    required this.body,
    this.padding = EdgeInsets.zero,
    this.isOutside = false,
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
  Widget build(BuildContext context) {
    Widget appbar = AppBar(
      titleSpacing: 0,
      leadingWidth: 50.w,
      elevation: 0,
      toolbarHeight: 60.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: TextButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Image.asset(
            'assets/images/lounge_icons/pop.png',
            width: 20.w,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: const [_ErrorAlert(), TimeCheckWidget()],
    );

    appbar = Hero(
      tag: 'appbar',
      transitionOnUserGestures: true,
      child: appbar,
    );

    return Builder(builder: (context) {
      return Stack(
        children: [
          Container(
            width: WePeiYangApp.screenWidth,
            height: WePeiYangApp.screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isOutside
                    ? [
                        Color.fromRGBO(44, 126, 223, 1),
                        Color.fromRGBO(166, 207, 255, 1),
                        Color.fromRGBO(166, 207, 255, 1),
                        Color.fromRGBO(166, 207, 255, 1),
                      ]
                    : [
                        Color.fromRGBO(44, 126, 223, 1),
                        Color.fromRGBO(166, 207, 255, 1),
                      ],
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.w),
              child: appbar,
            ),
            body: Padding(
              padding: widget.padding,
              child: widget.body,
            ),
          ),
        ],
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
