import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ResetDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          SizedBox(height: 180),
          Center(
            child: Text(S.current.reset_password_done,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 55,
            width: 140,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AuthRouter.login, (route) => false),
              child: Text(S.current.login3,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return Color.fromRGBO(103, 110, 150, 1);
                  return Color.fromRGBO(53, 59, 84, 1);
                }),
                backgroundColor:
                    MaterialStateProperty.all(Color.fromRGBO(53, 59, 84, 1)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
