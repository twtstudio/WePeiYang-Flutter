import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';

class FindPwDialog extends Dialog {
  static const _hintStyle = TextStyle(
      fontSize: 12,
      color: Color.fromRGBO(79, 88, 107, 1),
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.none);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 120,
        width: GlobalModel().screenWidth - 40,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10, top: 15),
                    child: Text("您好！请联系辅导员进行密码重置！若有疑问，请加入天外天用户社区qq群：",
                        style: _hintStyle, textAlign: TextAlign.center),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, top: 2),
                    child: Text("\n1群群号：738068756\n2群群号：738064793",
                        style: _hintStyle, textAlign: TextAlign.center),
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close,
                    color: Color.fromRGBO(210, 210, 210, 1), size: 25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
