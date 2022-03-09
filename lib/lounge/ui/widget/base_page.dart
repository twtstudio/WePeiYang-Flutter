import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/ui/colors.dart';
import 'date_picker.dart';
import 'package:flutter_screenutil/size_extension.dart';

class StudyRoomPage extends StatelessWidget {
  final Widget body;

  const StudyRoomPage({this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoungeColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35.w),
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
              leading: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
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
    );
  }
}