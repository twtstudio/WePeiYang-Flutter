import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';

Future<String> showRequestNotificationDialog() async {
  final context = WePeiYangApp.navigatorState.currentContext;
  if (context != null) {
    final result = await showDialog<RequestPushResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RequestPushDialog(),
    );
    return (result ?? RequestPushResult.unknown).text;
  } else {
    return RequestPushResult.unknown.text;
  }
}

class RequestPushDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          height: 200,
          width: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              color: Colors.white),
          child: Column(
            children: [
              Text("请同意打开推送"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context,RequestPushResult.ok);
                },
                child: Text("ok"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context,RequestPushResult.refuse);
                },
                child: Text("refuse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum RequestPushResult { refuse, ok, unknown }

extension RequestPushResultExt on RequestPushResult {
  String get text => ['refuse', 'ok', 'unknown'][index];
}
