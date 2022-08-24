
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class LevelUtil extends StatelessWidget {
  final String level;
  final Color strColor;
  final Color endColor;
  final TextStyle style;
  final double width;
  final double height;
  const LevelUtil({Key key, this.level, this.strColor, this.endColor, this.width, this.height, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [strColor, endColor],
            stops: [0.5,0.8]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "LV" + level,
          style: style,
        ),
      ),
    );
  }
}

class LevelProgress extends StatelessWidget {
  final Color strColor;
  final Color endColor;
  final double value;
  const LevelProgress({Key key, this.strColor, this.endColor, this.value}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
     height: 3.h,
     decoration: BoxDecoration(
       gradient: LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [strColor,Colors.white],
           stops: [value,value]),
       borderRadius: BorderRadius.circular(5),
       boxShadow: [
         BoxShadow(
           offset: Offset(0, 4),
           blurRadius: 10,
           color: Colors.black.withOpacity(0.05),
         ),
       ],
     ),
    );
  }
}
