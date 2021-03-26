import 'package:flutter/material.dart';

class MessageDialog extends Dialog {
  final data;

  const MessageDialog(this.data);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              shape: BoxShape.rectangle,
              color: Colors.white),
          height: 200,
          width: 200,
          child: Center(
            child: Text(data),
          ),
        ),
      ),
    );
  }
}
