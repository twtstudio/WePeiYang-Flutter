import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            child: SizedBox(
                width: size,
                height: size,
                // child: Image.network('https://api.twt.edu.cn' + avatar),
              child: Image.network('https://i0.hdslb.com/bfs/banner/386a2fb0b94d481946a02538704a1d6ae3fbad9b.jpg@976w_550h_1c.webp', fit: BoxFit.cover),
            ),
          );
  }
}
