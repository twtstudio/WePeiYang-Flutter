import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AvatarCropPage extends StatefulWidget {
  @override
  _AvatarCropPageState createState() => _AvatarCropPageState();
}

class _AvatarCropPageState extends State<AvatarCropPage> {
  File file;

  loadAssets() async {
    final List<AssetEntity> assets = await AssetPicker.pickAssets(context,
        maxAssets: 1,
        requestType: RequestType.image,
        themeColor: ColorUtil.blueA6Color);
    File file = await assets[0].file;
    for (int j = 0; file.lengthSync() > 2000 * 1024 && j < 10; j++) {
      file = await FlutterNativeImage.compressImage(file.path, quality: 80);
      if (j == 10) {
        ToastProvider.error('您的头像实在太大了，请自行压缩到2MB内再试吧');
        return;
      }
    }
    File croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      cropStyle: CropStyle.circle,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: '裁剪',
          toolbarColor: Color.fromRGBO(98, 103, 123, 1),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Color.fromRGBO(177, 175, 227, 1.0),
          dimmedLayerColor: Colors.black26,
          statusBarColor: ColorUtil.mainColor,
          backgroundColor: Color.fromRGBO(58, 59, 69, 1.0),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true),
    );
    if (croppedFile == null) return; // 取消裁剪图片的情况
    List<File> update = [croppedFile];
    // 弹出sheet
    Navigator.pop(context);
    FeedbackService.postPic(
        images: update,
        onResult: (result) {
          FeedbackService.uploadAvatars(result[0], onSuccess: () {
            ToastProvider.success("头像上传成功");
          }, onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
    setState(() {
      this.file = croppedFile;
    });
    if (!mounted) return;
  }

  pickAndCropImage(BuildContext context, ImageSource source) async {
    var image = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (image == null) return; // 取消选择图片的情况
    Navigator.pop(context);
    File croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      cropStyle: CropStyle.circle,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: '裁剪',
          toolbarColor: Color.fromRGBO(98, 103, 123, 1),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Color.fromRGBO(177, 175, 227, 1.0),
          dimmedLayerColor: Colors.black26,
          statusBarColor: ColorUtil.mainColor,
          backgroundColor: Color.fromRGBO(58, 59, 69, 1.0),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true),
    );
    if (croppedFile == null) return; // 取消裁剪图片的情况
    List<File> update = [croppedFile];
    FeedbackService.postPic(
        images: update,
        onResult: (result) {
          FeedbackService.uploadAvatars(result[0], onSuccess: () {
            ToastProvider.success("头像上传成功");
          }, onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
    setState(() {
      this.file = croppedFile;
    });
  }

  showActionButtons(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("拍照"),
                  onTap: () async {
                    pickAndCropImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("相册"),
                  onTap: () async {
                    loadAssets();
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget getAvatar() {
    var width = WePeiYangApp.screenWidth - 30;
    if (file != null) {
      return CircleAvatar(
        radius: width / 2,
        backgroundColor: Color.fromRGBO(98, 103, 124, 1),
        backgroundImage: FileImage(file),
        child: SizedBox(width: width, height: width),
      );
    }
    return UserAvatarImage(size: width);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: WButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(CupertinoIcons.back, color: Colors.white),
          ),
          elevation: 0,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              Spacer(),
              Hero(tag: 'avatar', child: getAvatar()),
              Spacer(),
              Divider(height: 1.0, color: Colors.white),
              TextButton(
                onPressed: () => showActionButtons(context),
                child: Text(
                  '修改个人头像',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ));
  }
}
