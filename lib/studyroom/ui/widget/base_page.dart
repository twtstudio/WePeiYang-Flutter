import 'package:flutter/material.dart';

import 'date_picker.dart';

class StudyRoomPage extends StatelessWidget {
  final Widget body;

  const StudyRoomPage({this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff7f7f8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(35),
            child: AppBar(
              brightness: Brightness.light,
              elevation: 0,
              leading: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0XFF62677B),
                ),
                iconSize: 30,
                onPressed: () {},
              ),
              backgroundColor: Colors.transparent,
              actions: [
                TimeCheckWidget(),
              ],
            ),
          ),
          body: body,
        ),
      ),
    );
  }
}
