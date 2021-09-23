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

class _ProfilePageState extends State<ProfilePage> {
  _CurrentTab _currentTab = _CurrentTab.myPosts;

  bool _deleteLock = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .clearProfilePostList();
      await getMyPosts(onSuccess: (list) {
        Provider.of<FeedbackNotifier>(context, listen: false).addProfilePosts(
            Provider.of<MessageProvider>(context, listen: false).feedbackQs ==
                    null
                ? list.sortNormal()
                : list.sortWithMessage(
                    Provider.of<MessageProvider>(context, listen: false)
                        .feedbackQs));
      }, onFailure: () {
        ToastProvider.error(S.current.feedback_get_post_error);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: DefaultTextStyle(
        style: FontManager.YaHeiRegular,
        child: Consumer<FeedbackNotifier>(
          builder: (context, notifier, widget) {
            return ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                showLeading: true,
                showTrailing: false,
                color: Color.fromRGBO(0, 0, 0, 0),
                axisDirection: AxisDirection.down,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProfileHeader(
                        child: SliverToBoxAdapter(
                          child: _tabs(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: BlankSpace.height(5)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return notifier.profilePostList[index].topImgUrl !=
                                      '' &&
                                  notifier.profilePostList[index].topImgUrl !=
                                      null
                              ? PostCard.image(
                                  notifier.profilePostList[index],
                                  onContentPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      FeedbackRouter.detail,
                                      arguments: DetailPageArgs(
                                          notifier.profilePostList[index],
                                          index,
                                          PostOrigin.profile),
                                    );
                                  },
                                  onLikePressed: () {
                                    postHitLike(
                                      id: notifier.profilePostList[index].id,
                                      isLiked:
                                          notifier.profilePostList[index].isLiked,
                                      onSuccess: () {
                                        notifier
                                            .changeProfilePostLikeState(index);
                                      },
                                      onFailure: () {
                                        ToastProvider.error(
                                            S.current.feedback_like_error);
                                      },
                                    );
                                  },
                                  onContentLongPressed: () {
                                    if (_currentTab == _CurrentTab.myPosts) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ProfileDialog(
                                          onConfirm: () {
                                            deletePost(
                                              id: notifier
                                                  .profilePostList[index].id,
                                              onSuccess: () {
                                                setState(() {
                                                  notifier.removeProfilePost(index);
                                                });
                                                Navigator.pop(context);
                                                ToastProvider.success(S.current
                                                    .feedback_delete_success);
                                              },
                                              onFailure: () {
                                                ToastProvider.error(S.current
                                                    .feedback_delete_error);
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  showBanner: true,
                                )
                              : PostCard(
                                  notifier.profilePostList[index],
                                  onContentPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      FeedbackRouter.detail,
                                      arguments: DetailPageArgs(
                                        notifier.profilePostList[index],
                                        index,
                                        PostOrigin.profile,
                                      ),
                                    );
                                  },
                                  onLikePressed: () {
                                    postHitLike(
                                      id: notifier.profilePostList[index].id,
                                      isLiked:
                                          notifier.profilePostList[index].isLiked,
                                      onSuccess: () {
                                        notifier
                                            .changeProfilePostLikeState(index);
                                     },
                                      onFailure: () {
                                        ToastProvider.error(
                                            S.current.feedback_like_error);
                                      },
                                    );
                                  },
                                  onContentLongPressed: () {
                                    if (_currentTab == _CurrentTab.myPosts) {
                                      if (!_deleteLock) {
                                        _deleteLock = true;
                                        showDialog(
                                          context: context,
                                          builder: (context) => ProfileDialog(
                                            onConfirm: () {
                                              deletePost(
                                                id: notifier
                                                    .profilePostList[index].id,
                                                onSuccess: () {
                                                  setState(() {
                                                    notifier.removeProfilePost(index);
                                                  });
                                                  Navigator.pop(context);
                                                  ToastProvider.success(S
                                                      .current
                                                      .feedback_delete_success);
                                                },
                                                onFailure: () {
                                                  ToastProvider.error(S.current
                                                      .feedback_delete_error);
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ).then((value) {
                                          _deleteLock = false;
                                        });
                                      }
                                    }
                                  },
                                  showBanner: true,
                                );
                        },
                        childCount: notifier.profilePostList.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _tabs() => Container(
        height: 140.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // My posts tab.
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        FeedbackBadgeWidget(
                          child: Image.asset(
                            'lib/feedback/assets/img/my_post.png',
                            height: 30,
                          ),
                          type: FeedbackMessageType.detail_post,
                        ),
                        BlankSpace.height(5),
                        Text(
                          S.current.feedback_my_post,
                          style: FontManager.YaHeiRegular.copyWith(
                              height: 1, color: ColorUtil.lightTextColor),
                        ),
                        BlankSpace.height(5),
                        ClipOval(
                          child: Container(
                            width: 5,
                            height: 5,
                            color: _currentTab == _CurrentTab.myPosts
                                ? ColorUtil.mainColor
                                : Colors.white,
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    onTap: () {
                      if (_currentTab == _CurrentTab.myFavorite) {
                        notifier.clearProfilePostList();
                        _currentTab = _CurrentTab.myPosts;
                        getMyPosts(onSuccess: (list) {
                          notifier.addProfilePosts(list.sortNormal());
                        }, onFailure: () {
                          ToastProvider.error(
                              S.current.feedback_get_post_error);
                        });
                      }
                    },
                  ),
                ),
                // My favorite posts tab.
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        FeedbackBadgeWidget(
                          type: FeedbackMessageType.detail_favourite,
                          child: Image.asset(
                            'lib/feedback/assets/img/my_favorite.png',
                            height: 30,
                          ),
                        ),
                        BlankSpace.height(5),
                        Text(
                          S.current.feedback_my_favorite,
                          style: FontManager.YaHeiRegular.copyWith(
                              height: 1, color: ColorUtil.lightTextColor),
                        ),
                        BlankSpace.height(5),
                        ClipOval(
                          child: Container(
                            width: 5,
                            height: 5,
                            color: _currentTab == _CurrentTab.myFavorite
                                ? ColorUtil.mainColor
                                : Colors.white,
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    onTap: () {
                      if (_currentTab == _CurrentTab.myPosts) {
                        notifier.clearProfilePostList();
                        _currentTab = _CurrentTab.myFavorite;
                        getFavoritePosts(onSuccess: (list) {
                          notifier.addProfilePosts(list.sortNormal());
                        }, onFailure: () {
                          ToastProvider.error(
                              S.current.feedback_get_post_error);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class FeedbackMailbox extends StatefulWidget {
  @override
  _FeedbackMailboxState createState() => _FeedbackMailboxState();
}

class _FeedbackMailboxState extends State<FeedbackMailbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: FeedbackBadgeWidget(
          type: FeedbackMessageType.mailbox,
          child: InkWell(
            child: Icon(Icons.mail_outline),
            onTap: () {
              Navigator.pushNamed(context, FeedbackRouter.mailbox);
            },
          ),
        ),
      ),
    );
  }
}
