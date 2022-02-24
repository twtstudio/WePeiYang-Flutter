import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

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
        ? Icon(Icons.account_circle_rounded, size: size, color: iconColor)
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: Color.fromRGBO(98, 103, 124, 1),
            backgroundImage: NetworkImage('https://api.twt.edu.cn' + avatar),
            child: SizedBox(width: size, height: size),
          );
  }
}
