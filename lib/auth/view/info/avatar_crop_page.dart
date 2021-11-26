import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class AvatarCropPage extends StatefulWidget {
  @override
  _AvatarCropPageState createState() => _AvatarCropPageState();
}

class _AvatarCropPageState extends State<AvatarCropPage> {
  File file;

  pickAndCropImage(BuildContext context, ImageSource source) async {
    var image = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (image == null) return; // 取消选择图片的情况
    Navigator.pop(context);
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      cropStyle: CropStyle.circle,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: '图片裁剪',
          toolbarColor: Color.fromRGBO(98, 103, 123, 1),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
    );
    if (croppedFile == null) return; // 取消裁剪图片的情况
    AuthService.uploadAvatar(croppedFile, onSuccess: () {
      setState(() {
        this.file = croppedFile;
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
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
                  title: Text("相机拍照"),
                  onTap: () async {
                    pickAndCropImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("相册选择"),
                  onTap: () async {
                    pickAndCropImage(context, ImageSource.gallery);
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
    return Container(
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
    );
  }
}
