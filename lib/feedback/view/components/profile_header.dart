import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
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
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: ColorUtil.bold42TextColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "我的湖底",
                style: TextStyle(color: ColorUtil.bold42TextColor),
              ),
              centerTitle: true,
              actions: [FeedbackReadAllButton(), FeedbackMailbox()],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatarImage(
                        size: (ScreenUtil.defaultSize.width - 60) / 3,
                        iconColor: Colors.white),
                    SizedBox(width: (ScreenUtil.defaultSize.width - 60) / 10),
                    SizedBox(
                      width: (ScreenUtil.defaultSize.width - 60) / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(CommonPreferences.nickname.value,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtil.base.ProductSans.black2A.w700
                                  .sp(22)),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(CommonPreferences.userNumber.value,
                                textAlign: TextAlign.start,
                                style: TextUtil.base.ProductSans.grey6C.w700
                                    .sp(14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 7.0),
                            child: Text(
                                "MPID: ${CommonPreferences.feedbackUid.value.toString().padLeft(6, '0')}",
                                textAlign: TextAlign.start,
                                style: TextUtil.base.ProductSans.grey6C.w700
                                    .sp(14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text('已经潜水 好几天 了。',
                                textAlign: TextAlign.start,
                                style: TextUtil.base.ProductSans.grey6C.w700
                                    .sp(14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 40)),
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
              type: FeedbackMessageType.total,
              child: Icon(Icons.notifications_none_outlined,
                  color: ColorUtil.bold42TextColor),
            ),
          ),
        ),
      ),
    );
  }
}
