import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

class UserAvatarImage extends StatelessWidget {
  final double size;

  UserAvatarImage({@required this.size});

  @override
  Widget build(BuildContext context) {
    var avatar = CommonPreferences().avatar.value;
    return avatar == ''
        ? Icon(
            Icons.account_circle_rounded,
            size: size,
            color: Color.fromRGBO(98, 103, 124, 1),
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: Color.fromRGBO(98, 103, 124, 1),
            backgroundImage: NetworkImage('https://api.twt.edu.cn' + avatar),
            child: SizedBox(width: size, height: size),
          );
  }
}
