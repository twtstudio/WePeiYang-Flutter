// @dart = 2.12

part of "share.dart";

Future<void> shareImgFromUrlToQQ(String url) async {
  try {
    final path = await WbyImageSave.saveImageFromUrl(url, album: false);
    await _shareChannel.invokeMethod("shareImgToQQ", {"path": path});
  } catch (e) {
    ToastProvider.error(e.toString());
  }
}