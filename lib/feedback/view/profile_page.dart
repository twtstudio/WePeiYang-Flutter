import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/blank_space.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/profile_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/view/detail_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

import 'components/post_card.dart';
import 'components/profile_header.dart';

/// Almost the same as [UserPage].
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum _CurrentTab {
  myPosts,
  myFavorite,
}

extension _CurrentTabb on _CurrentTab {
  _CurrentTab get change {
    var next = (this.index + 1) % 2;
    return _CurrentTab.values[next];
  }

  FeedbackMessageType get messageType {
    switch (this.index) {
      case 0:
        return FeedbackMessageType.detail_post;
      case 1:
        return FeedbackMessageType.detail_favourite;
    }
  }
}

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<_CurrentTab> _currentTab = ValueNotifier(_CurrentTab.myPosts);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .clearProfilePostList();
      await FeedbackService.getMyPosts(onResult: (list) {
        Provider.of<FeedbackNotifier>(context, listen: false).addProfilePosts(
            Provider.of<MessageProvider>(context, listen: false).feedbackQs ==
                    null
                ? list.sortNormal()
                : list.sortWithMessage(
                    Provider.of<MessageProvider>(context, listen: false)
                        .feedbackQs));
      }, onFailure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Consumer<FeedbackNotifier>(
      builder: (context, notifier, widget) {
        ProfileTabButton myPost = ProfileTabButton(
          type: _CurrentTab.myPosts,
          img: 'lib/feedback/assets/img/my_post.png',
          text: S.current.feedback_my_post,
          onTap: () {
            notifier.clearProfilePostList();
            FeedbackService.getMyPosts(onResult: (list) {
              notifier.addProfilePosts(list.sortNormal());
            }, onFailure: (e) {
              ToastProvider.error(e.error.toString());
            });
          },
        );

        ProfileTabButton myFavor = ProfileTabButton(
          type: _CurrentTab.myFavorite,
          img: 'lib/feedback/assets/img/my_favorite.png',
          text: S.current.feedback_my_favorite,
          onTap: () {
            notifier.clearProfilePostList();
            FeedbackService.getFavoritePosts(onResult: (list) {
              notifier.addProfilePosts(list.sortNormal());
            }, onFailure: (e) {
              ToastProvider.error(e.error.toString());
            });
          },
        );

        Widget tabs = Container(
          height: 140.0,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [myPost, myFavor],
              ),
            ),
          ),
        );

        Widget appBar = SliverToBoxAdapter(
          child: ProfileHeader(
            child: SliverToBoxAdapter(
              child: tabs,
            ),
          ),
        );

        Widget blankBeyondList =
            SliverToBoxAdapter(child: BlankSpace.height(5));

        Widget list;
        if (notifier.profilePostList.length.isZero) {
          Widget emptyText =
              Text("暂无提问", style: TextStyle(color: Color(0xff62677b)));
          list = SliverToBoxAdapter(
            child: SizedBox(height: 200, child: Center(child: emptyText)),
          );
        } else {
          list = SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Function goToDetailPage = () {
                  Navigator.pushNamed(
                    context,
                    FeedbackRouter.detail,
                    arguments: DetailPageArgs(notifier.profilePostList[index],
                        index, PostOrigin.profile),
                  );
                };

                Function hitLike = () {
                  FeedbackService.postHitLike(
                    id: notifier.profilePostList[index].id,
                    isLiked: notifier.profilePostList[index].isLiked,
                    onSuccess: () {
                      notifier.changeProfilePostLikeState(index);
                    },
                    onFailure: (e) {
                      ToastProvider.error(e.error.toString());
                    },
                  );
                };

                Function deletePostOnLongPressed = () {
                  if (_currentTab.value == _CurrentTab.myPosts)
                    showDialog(
                      context: context,
                      builder: (context) => ProfileDialog(
                        onConfirm: () {
                          FeedbackService.deletePost(
                            id: notifier.profilePostList[index].id,
                            onSuccess: () {
                              notifier.removeProfilePost(index);
                              Navigator.pop(context);
                              ToastProvider.success(
                                  S.current.feedback_delete_success);
                            },
                            onFailure: (e) {
                              ToastProvider.error(e.error.toString());
                              Navigator.pop(context);
                            },
                          );
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                };

                Widget postWithImage = PostCard.image(
                  notifier.profilePostList[index],
                  onContentPressed: goToDetailPage,
                  onLikePressed: hitLike,
                  onContentLongPressed: deletePostOnLongPressed,
                  showBanner: true,
                );

                Widget postWithoutImage = PostCard(
                  notifier.profilePostList[index],
                  onContentPressed: goToDetailPage,
                  onLikePressed: hitLike,
                  onContentLongPressed: deletePostOnLongPressed,
                  showBanner: true,
                );

                return notifier.profilePostList[index].topImgUrl != '' &&
                        notifier.profilePostList[index].topImgUrl != null
                    ? postWithImage
                    : postWithoutImage;
              },
              childCount: notifier.profilePostList.length,
            ),
          );
        }

        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            slivers: [appBar, blankBeyondList, list],
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: DefaultTextStyle(
        style: FontManager.YaHeiRegular,
        child: body,
      ),
    );
  }
}

class ProfileTabButton extends StatefulWidget {
  final _CurrentTab type;
  final VoidCallback onTap;
  final String text;
  final String img;

  const ProfileTabButton({Key key, this.type, this.onTap, this.text, this.img})
      : super(key: key);

  @override
  _ProfileTabButtonState createState() => _ProfileTabButtonState();
}

class _ProfileTabButtonState extends State<ProfileTabButton> {
  @override
  Widget build(BuildContext context) {
    var currentType =
        context.findAncestorStateOfType<_ProfilePageState>()._currentTab;

    return Expanded(
      child: InkWell(
        child: Column(
          children: [
            FeedbackBadgeWidget(
              type: widget.type.messageType,
              child: Image.asset(
                widget.img,
                height: 30,
              ),
            ),
            BlankSpace.height(5),
            Text(
              widget.text,
              style: FontManager.YaHeiRegular.copyWith(
                  height: 1, color: ColorUtil.lightTextColor),
            ),
            BlankSpace.height(5),
            ClipOval(
              child: Container(
                width: 5,
                height: 5,
                color: currentType.value == widget.type
                    ? ColorUtil.mainColor
                    : Colors.white,
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onTap: () {
          if (currentType.value == widget.type.change) {
            currentType.value = widget.type;
            widget.onTap();
          }
        },
      ),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return GlowingOverscrollIndicator(
      child: child,
      showLeading: false,
      showTrailing: true,
      color: Color(0XFF62677B),
      axisDirection: AxisDirection.down,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}
