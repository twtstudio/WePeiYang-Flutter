// @dart = 2.12
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class HotfixCancelOverlay extends StatefulWidget {
  final Function restart;
  final Function cancel;

  const HotfixCancelOverlay(this.restart, {required this.cancel, Key? key})
      : super(key: key);

  @override
  _HotfixCancelOverlayState createState() => _HotfixCancelOverlayState();
}

class _HotfixCancelOverlayState extends State<HotfixCancelOverlay> {
  late double dx;
  late double dy;
  late double height;
  late double width;
  int _countdownNum = 3;
  Timer? _countdownTimer;
  String _codeCountdownStr = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    height = 40.0;
    width = 80.0;
    final size = MediaQuery.of(context).size;
    dy = size.height - height * 1.5;
    dx = (size.width / 2) - width / 2;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdownNum > 0) {
            _codeCountdownStr = '${_countdownNum--}s';
          } else {
            cancel();
            widget.cancel();
            widget.restart();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  void cancel() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('即将重启：'),
        Text(_codeCountdownStr),
        TextButton(
          onPressed: () {
            cancel();
            ToastProvider.success("将在下次重启应用时加载更新");
            widget.cancel();
          },
          child: Text('取消'),
        ),
      ],
    );

    return Positioned(
      left: dx,
      top: dy,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 6),
          color: Colors.lightGreen,
        ),
        alignment: Alignment.center,
        child: row,
      ),
    );
  }
}
