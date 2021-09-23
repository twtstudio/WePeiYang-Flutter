import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/feedback_set_read_all.dart';

import 'blank_space.dart';

class ProfileHeader extends StatelessWidget {
  final Widget child;

  const ProfileHeader({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: Stack(
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
                title: Text(S.current.feedback_profile),
                centerTitle: true,
                actions: [FeedbackReadAllButton(),FeedbackMailbox()],
              ),
              SliverToBoxAdapter(
                child: BlankSpace.height(23),
              ),
              SliverToBoxAdapter(
                child: Text(CommonPreferences().nickname.value,
                    textAlign: TextAlign.center,
                    style: FontManager.YaHeiRegular.copyWith(
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
                        style: FontManager.YaHeiRegular.copyWith(
                            color: ColorUtil.profileNameColor,
                            fontSize: 13.0))),
              ),
              child,
            ],
          ),
        ],
      ),
    );
  }
}
