import 'dart:async';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PowerPrint {
  PowerPrint(){}
  int c=0;
  print(BuildContext context, String message, Color color){
    OverlayEntry _overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message+" "+(c++).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
    Future.delayed(Duration(milliseconds: 1000), () {
      _overlayEntry.remove();
    });
  }
}
