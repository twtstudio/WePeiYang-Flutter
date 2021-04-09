import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/profile_page.dart';

import 'blank_space.dart';

class ProfileHeader extends StatelessWidget {
  final Widget child;

  const ProfileHeader({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 350,
          child: Image.asset(
            'assets/images/user_back.png',
            fit: BoxFit.cover,
          ),
        ),
        CustomScrollView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: AppBar().preferredSize.height,
              backgroundColor: Color.fromARGB(0, 255, 255, 255),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text('个人中心'),
              centerTitle: true,
              actions: [FeedbackMailbox()],
            ),
            SliverToBoxAdapter(
              child: BlankSpace.height(23),
            ),
            SliverToBoxAdapter(
              child: Text(CommonPreferences().nickname.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            SliverToBoxAdapter(
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(CommonPreferences().userNumber.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorUtil.profileNameColor,
                          fontSize: 13.0))),
            ),
            child,
          ],
        ),
      ],
    );
  }
}
