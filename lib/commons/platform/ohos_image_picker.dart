import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper_platform_interface/image_cropper_platform_interface.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:we_pei_yang_flutter/commons/widgets/ohos_avatar_crop.dart';

const _media = MethodChannel('com.twt.service/saveImg');

void registerOhosImagePicker(GlobalKey<NavigatorState> navigatorKey) {
  ImagePickerPlatform.instance = _OhosImagePicker();
  ImageCropperPlatform.instance = _OhosImageCropper(navigatorKey);
}

class _OhosImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final path = switch (source) {
      ImageSource.camera => await _media.invokeMethod<String>('takePhoto', {
          'quality': options.imageQuality,
        }),
      ImageSource.gallery =>
        (await _media.invokeListMethod<String>('pickImages', {'limit': 1}))
            ?.firstOrNull,
    };
    return path == null ? null : XFile(path);
  }
}

class _OhosImageCropper extends ImageCropperPlatform {
  _OhosImageCropper(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Future<CroppedFile?> cropImage({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    List<PlatformUiSettings>? uiSettings,
  }) async {
    final cropped = await navigatorKey.currentState?.push<File>(
      MaterialPageRoute(
          builder: (_) => OhosAvatarCrop(source: File(sourcePath))),
    );
    return cropped == null ? null : CroppedFile(cropped.path);
  }
}
