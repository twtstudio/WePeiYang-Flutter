import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_set_read_all.dart';

class ProfileHeader extends StatelessWidget {
  final Widget child;

  const ProfileHeader({this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
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
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(S.current.feedback_profile),
              centerTitle: true,
              actions: [FeedbackReadAllButton(), FeedbackMailbox()],
            ),
            SliverToBoxAdapter(child: SizedBox(height: 23)),
            SliverToBoxAdapter(
              child: Text(CommonPreferences().nickname.value,
                  textAlign: TextAlign.center,
                  style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            SliverToBoxAdapter(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(CommonPreferences().userNumber.value,
                      textAlign: TextAlign.center,
                      style: FontManager.YaHeiRegular.copyWith(
                          color: ColorUtil.profileNameColor,
                          fontSize: 13))),
            ),
            child,
          ],
        ),
      ],
    );
  }
}

class FeedbackMailbox extends StatefulWidget {
  @override
  _FeedbackMailboxState createState() => _FeedbackMailboxState();
}

class _FeedbackMailboxState extends State<FeedbackMailbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 45,
        child: InkResponse(
          onTap: () => Navigator.pushNamed(context, FeedbackRouter.mailbox),
          radius: 40,
          child: Center(
            child: FeedbackBadgeWidget(
              type: FeedbackMessageType.mailbox,
              child: Icon(Icons.mail_outline),
            ),
          ),
        ),
      ),
    );
  }
}
