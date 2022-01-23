import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_cancel_overlay.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

// 推送接收到重要hotfix后，用户点击推送，打开应用，如果是以后版本的推送，则选择升级版本，
// 如果是当前版本的hotfix，则选择提示用户下载hotfix，并询问是否下载完毕后就重启
// TODO: 改

class HotfixMessageDialog extends Dialog {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("有重要更新，请允许下载"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, LoadHotfixTime.now);
                },
                child: Text("now"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, LoadHotfixTime.next);
                },
                child: Text("next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum LoadHotfixTime { next, now }

extension LoadHotfixTimeExt on LoadHotfixTime {
  String get text => [
        'next',
        'now',
      ][index];
}
