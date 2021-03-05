import 'package:flutter/material.dart';
import 'date_picker.dart';

class StudyRoomPage extends StatelessWidget {
  final Widget body;

  const StudyRoomPage({this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff7f7f8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(35),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Hero(
              tag: 'appbar',
              transitionOnUserGestures: true,
              child: AppBar(
                titleSpacing: 0,
                leadingWidth: 30,
                brightness: Brightness.light,
                elevation: 0,
                leading: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Color(0XFF62677B),
                  ),
                ),
                backgroundColor: Colors.transparent,
                actions: [
                  TimeCheckWidget(),
                ],
              ),
            ),
          ),
        ),
        body: body,
      ),
    );
  }
}
