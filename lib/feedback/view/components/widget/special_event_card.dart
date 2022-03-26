import 'dart:core';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';

//北洋热搜
class SpecialEventCard extends StatefulWidget {
  @override
  _SpecialEventCardState createState() => _SpecialEventCardState();
}

class _SpecialEventCardState extends State<SpecialEventCard> {
  _SpecialEventCardState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WePeiYangApp.screenWidth * 0.3,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
