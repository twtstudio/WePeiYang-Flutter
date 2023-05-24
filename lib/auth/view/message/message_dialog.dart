import 'package:flutter/material.dart';

class MessageDialog extends Dialog {
  final data;

  const MessageDialog(this.data);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 200,
        width: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
            color: Colors.white),
        child: Center(child: Text(data)),
      ),
    );
  }
}
