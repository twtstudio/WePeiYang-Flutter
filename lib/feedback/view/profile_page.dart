import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/profile_dialog.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/message/feedback_badge_widget.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .clearProfilePostList();
      getMyPosts(
          onSuccess: (list) {
            Provider.of<FeedbackNotifier>(context, listen: false)
                .addProfilePosts(list.sortWithMessage(
                    Provider.of<MessageProvider>(context, listen: false)
                        .feedbackQs));
          },
          onFailure: () {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Consumer<FeedbackNotifier>(
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
                                    id: notifier.homePostList[index].id,
                                    isLiked:
                                        notifier.homePostList[index].isLiked,
                                    onSuccess: () {
                                      notifier
                                          .changeProfilePostLikeState(index);
                                    },
                                    onFailure: () {
                                      ToastProvider.error('校务专区点赞失败，请重试');
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
                                              setState(() {});
                                              Navigator.pop(context);
                                              ToastProvider.success('删除成功');
                                            },
                                            onFailure: () {
                                              ToastProvider.error(
                                                  '校务专区删帖失败，请重试');
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
                                    id: notifier.homePostList[index].id,
                                    isLiked:
                                        notifier.homePostList[index].isLiked,
                                    onSuccess: () {
                                      notifier
                                          .changeProfilePostLikeState(index);
                                    },
                                    onFailure: () {
                                      ToastProvider.error('校务专区点赞失败，请重试');
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
                                                setState(() {});
                                                Navigator.pop(context);
                                                ToastProvider.success('删除成功');
                                              },
                                              onFailure: () {
                                                ToastProvider.error(
                                                    '校务专区删帖失败，请重试');
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
                        ),
                        BlankSpace.height(5),
                        Text(
                          '我的提问',
                          style: TextStyle(
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
                          notifier.addProfilePosts(list);
                        }, onFailure: () {
                          ToastProvider.error('校务专区获取帖子失败，请刷新');
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
                        Image.asset(
                          'lib/feedback/assets/img/my_favorite.png',
                          height: 30,
                        ),
                        BlankSpace.height(5),
                        Text(
                          '我的收藏',
                          style: TextStyle(
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
                          notifier.addProfilePosts(list);
                        }, onFailure: () {
                          ToastProvider.error('校务专区获取帖子失败, 请刷新');
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
