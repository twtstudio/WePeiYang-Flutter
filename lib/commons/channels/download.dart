// @dart = 2.12
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/download/download_item.dart';

const _downloadChannel = MethodChannel('com.twt.service/download');

MethodChannel get downloadChannel => _downloadChannel;

Future<void> startDownload(DownloadList list) async {
  _downloadChannel.invokeMethod(
    "addDownloadTask",
    {
      "downloadList": list.toJson(),
    },
  );
}