import 'package:flutter/material.dart';

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
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text("您好！请联系辅导员进行密码重置！若有疑问，请", style: _hintStyle),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text("加入天外天用户社区qq群：\n\n1群群号：738068756\n2群群号：738064793",
                      style: _hintStyle, textAlign: TextAlign.center),
                )
              ],
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close,
                    color: Color.fromRGBO(210, 210, 210, 1), size: 23),
              ),
            )
          ],
        ),
      ),
    );
  }
}
