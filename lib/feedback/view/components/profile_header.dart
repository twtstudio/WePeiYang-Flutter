import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
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
        CustomScrollView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,color: ColorUtil.bold42TextColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(S.current.feedback_profile,style: TextStyle(color: ColorUtil.bold42TextColor),),
              centerTitle: true,
              actions: [FeedbackReadAllButton(), FeedbackMailbox()],
            ),
            SliverToBoxAdapter(child: SizedBox(height: 23)),
            SliverToBoxAdapter(
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserAvatarImage(size: 96, iconColor: Colors.white),
                  SizedBox(width: 67,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Text(CommonPreferences().nickname.value,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: FontManager.YaHeiRegular.copyWith(
                              color: ColorUtil.bold42TextColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.5),
                          child: Text(CommonPreferences().userNumber.value,
                              textAlign: TextAlign.start,
                              style: FontManager.YaHeiRegular.copyWith(
                                  color: ColorUtil.tagTextColor,
                                  fontSize: 15))),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.5),
                          child: Text("MPID: ${CommonPreferences().feedbackUid.value}",
                              textAlign: TextAlign.start,
                              style: FontManager.YaHeiRegular.copyWith(
                                  color: ColorUtil.tagTextColor,
                                  fontSize: 15))),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.5),
                          child: Text('已经潜水{12}天了。',
                              textAlign: TextAlign.start,
                              style: FontManager.YaHeiRegular.copyWith(
                                  color: ColorUtil.tagTextColor,
                                  fontSize: 15))),
                    ],
                  ),
                ],
              ),

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
          radius: 25,
          child: Center(
            child: FeedbackBadgeWidget(
              type: FeedbackMessageType.mailbox,
              child: Icon(Icons.notifications_none_outlined,color: ColorUtil.bold42TextColor),
            ),
          ),
        ),
      ),
    );
  }
}
