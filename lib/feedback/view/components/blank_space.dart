import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BlankSpace extends StatelessWidget {
  double width;
  double height;

  BlankSpace.width(this.width);

  BlankSpace.height(this.height);

  BlankSpace(this.width, this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
    );
  }
}
