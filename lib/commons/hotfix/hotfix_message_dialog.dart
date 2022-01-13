import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_cancel_overlay.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

// 推送接收到重要hotfix后，用户点击推送，打开应用，如果是以后版本的推送，则选择升级版本，
// 如果是当前版本的hotfix，则选择提示用户下载hotfix，并询问是否下载完毕后就重启
// TODO: 改
Future<void> showUpdateDialog(int versionCode, int fixCode, String url) async {
  final thisVersionCode = await UpdateUtil.getVersionCode();
  if (thisVersionCode == versionCode && fixCode > 0 && url.isNotEmpty) {
    final context = WePeiYangApp.navigatorState.currentContext;
    if (context != null) {
      final result = await showDialog<LoadHotfixTime>(
        context: context,
        barrierDismissible: false,
        builder: (_) => HotfixMessageDialog(),
      );
      if (result == LoadHotfixTime.now) {
        HotfixManager.getInstance().hotfixDownloadAndLoadNow(versionCode, url,
            fixLoadSoFileSuccess: (restart) {
          // 弹二次防返回窗，倒计时三秒，若不反悔，三秒后重启应用
          OverlayEntry _overlayEntry;
          _overlayEntry = OverlayEntry(
              builder: (_) => HotfixCancelOverlay(
                    restart,
                    cancel: () {
                      _overlayEntry?.remove();
                    },
                  ));
          if (_overlayEntry != null) {
            Overlay.of(context).insert(_overlayEntry);
          }
        });
      } else {
        HotfixManager.getInstance().hotfixDownloadAndLoadNext(versionCode, url,
            loadSuccess: () {
          ToastProvider.success("应用将在重启后加载更新");
        });
      }
    } else {
      ToastProvider.error("弹出弹窗提示hotfix失败，将在后台下载更新");
      HotfixManager.getInstance().hotfixDownloadAndLoadNext(versionCode, url,
          loadSuccess: () {
        ToastProvider.success("即使弹窗失败了，也在后台下载完成更新，下次重启应用将加载更新");
      });
    }
  } else {
    // 说明用户的微北洋落后版本，或者是已安装的热修复，或者是高版本的测试版
    // 如果是低版本的，就检查更新
    if (thisVersionCode < versionCode) {
      // UpdateManager.checkUpdate(context);
    }
  }
}

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
