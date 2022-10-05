import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/widgets/wpy_pic.dart';

class UserAvatarImage extends StatelessWidget {
  final double size;
  final Color iconColor;

  UserAvatarImage(
      {@required this.size,
      this.iconColor = const Color.fromRGBO(98, 103, 124, 1)});

  @override
  Widget build(BuildContext context) {
    var avatar = CommonPreferences.avatar.value;
    return avatar == ''
        //? Icon(Icons.account_box_rounded, size: size, color: iconColor)
        ? ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.r)),
            child: WpyPic(
              'assets/images/default_image.png',
              withHolder: true,
            ))
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.r)),
            child: WpyPic(
              'https://qnhdpic.twt.edu.cn/download/origin/' + avatar,
              withHolder: true,
              width: size,
              height: size,
            ),
          );
  }
}
