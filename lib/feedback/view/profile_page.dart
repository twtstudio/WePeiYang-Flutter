import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/message/feedback_badge_widget.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/profile_dialog.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/message/feedback_banner_widget.dart';
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

extension _CurrentTabExtension on _CurrentTab {
  String get text {
    switch (this) {
      case _CurrentTab.myFavorite:
        return '我的收藏';
      case _CurrentTab.myPosts:
        return '我的提问';
    }
  }

  String get image {
    switch (this) {
      case _CurrentTab.myFavorite:
        return 'lib/feedback/assets/img/my_favorite.png';
      case _CurrentTab.myPosts:
        return 'lib/feedback/assets/img/my_post.png';
    }
  }

  getPostListOfCategory(
      FeedbackNotifier feedbackNotifier, MessageProvider messageProvider) {
    switch (this) {
      case _CurrentTab.myPosts:
        feedbackNotifier.getMyPosts(messageProvider.feedbackQs);
        break;
      case _CurrentTab.myFavorite:
        feedbackNotifier.getMyFavoritePosts(messageProvider.feedbackFs);
        break;
    }
  }

  FeedbackMessageType get messageType {
    switch (this) {
      case _CurrentTab.myFavorite:
        return FeedbackMessageType.detail_favourite;
      case _CurrentTab.myPosts:
        return FeedbackMessageType.detail_post;
    }
  }
}

class _ProfilePageState extends State<ProfilePage> {
  _CurrentTab _currentTab = _CurrentTab.myPosts;

  bool _deleteLock = false;

  ValueNotifier<_CurrentTab> category = ValueNotifier(_CurrentTab.myPosts);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .clearProfilePostList();
      getMyPosts(onSuccess: (list) {
        Provider.of<FeedbackNotifier>(context, listen: false).addProfilePosts(
            Provider.of<MessageProvider>(context, listen: false).feedbackQs ==
                    null
                ? list
                : list.sortWithMessage(
                    Provider.of<MessageProvider>(context, listen: false)
                        .feedbackQs));
      }, onFailure: () {
        ToastProvider.error('校务专区获取帖子失败，请重试');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Consumer<FeedbackNotifier>(
        builder: (context, feedbackNotifier, widget) {
          Widget sliverHeader = SliverToBoxAdapter(
            child: _profileHeader(
              SliverToBoxAdapter(
                child: Container(
                  height: 140.0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // My posts tab.
                          _PostListCategory(category: _CurrentTab.myPosts),
                          // My favorite posts tab.
                          _PostListCategory(category: _CurrentTab.myFavorite),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          Widget sliverList = SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var item = feedbackNotifier.profilePostList[index];
                return item.topImgUrl != '' && item.topImgUrl != null
                    ? _cardWithImage(
                        context,
                        feedbackNotifier,
                        index,
                      )
                    : _cardWithoutImage(
                        context,
                        feedbackNotifier,
                        index,
                      );
              },
              childCount: feedbackNotifier.profilePostList.length,
            ),
          );

          return ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              showLeading: true,
              showTrailing: false,
              color: Color.fromRGBO(0, 0, 0, 0),
              axisDirection: AxisDirection.down,
              child: CustomScrollView(
                slivers: [
                  sliverHeader,
                  SliverToBoxAdapter(child: BlankSpace.height(5)),
                  sliverList,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(Widget tab) => Stack(
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
                actions: [
                  FeedbackMailbox(),
                ],
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
              tab,
            ],
          ),
        ],
      );

  Widget _dialog(BuildContext context, FeedbackNotifier notifier, int index) =>
      Center(
        child: Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(237, 240, 244, 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text("您确定要删除问题吗？",
                    style: TextStyle(
                        color: Color.fromRGBO(79, 88, 107, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消",
                        style: TextStyle(
                          color: ColorUtil.boldTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  Container(width: 30),
                  GestureDetector(
                    onTap: () {
                      notifier.deletePost(index, () {
                        _deleteLock = false;
                        setState(() {});
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text("确定",
                          style: TextStyle(
                            color: ColorUtil.boldTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _cardWithImage(
    BuildContext context,
    FeedbackNotifier feedbackNotifier,
    int index,
  ) =>
      PostCard.image(
        feedbackNotifier.profilePostList[index],
        onContentPressed: () {
          Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: DetailPageArgs(feedbackNotifier.profilePostList[index],
                index, PostOrigin.profile),
          );
        },
        onLikePressed: () {
          feedbackNotifier.profilePostHitLike(
              index, feedbackNotifier.profilePostList[index].id);
        },
        onContentLongPressed: () {
          if (_currentTab == _CurrentTab.myPosts) {
            if (!_deleteLock) {
              _deleteLock = true;
              // TODO: Pop alert dialog here.
              showDialog(
                  context: context,
                  builder: (context) {
                    return;
                  }).then((value) {
                _deleteLock = false;
              });
            }
          }
        },
        showBanner: true,
      );

  Widget _cardWithoutImage(
    BuildContext context,
    FeedbackNotifier feedbackNotifier,
    int index,
  ) =>
      PostCard(
        feedbackNotifier.profilePostList[index],
        onContentPressed: () {
          Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: DetailPageArgs(
              feedbackNotifier.profilePostList[index],
              index,
              PostOrigin.profile,
            ),
          ).then((value) async {
            print(value);
            if (value == false) {
              feedbackNotifier.removeProfilePost(index);
            }
          });
        },
        onLikePressed: () {
          feedbackNotifier.profilePostHitLike(
              index, feedbackNotifier.profilePostList[index].id);
        },
        onContentLongPressed: () {
          if (_currentTab == _CurrentTab.myPosts) {
            if (!_deleteLock) {
              _deleteLock = true;
              showDialog(
                  context: context,
                  builder: (context) {
                    return _dialog(context, feedbackNotifier, index);
                  }).then((value) {
                _deleteLock = false;
              });
            }
          }
        },
        showBanner: true,
      );
}

class _PostListCategory extends StatelessWidget {
  final _CurrentTab category;

  const _PostListCategory({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MessageProvider, FeedbackNotifier>(
        builder: (_, messageProvider, feedbackNotifier, __) {
      return Expanded(
        child: ValueListenableBuilder(
          valueListenable:
              context.findAncestorStateOfType<_ProfilePageState>().category,
          builder: (_, _CurrentTab value, __) {
            return InkWell(
              child: Column(
                children: [
                  FeedbackBadgeWidget(
                    type: category.messageType,
                    child: Image.asset(
                      category.image,
                      height: 30,
                    ),
                  ),
                  BlankSpace.height(5),
                  Text(
                    category.text,
                    style:
                        TextStyle(height: 1, color: ColorUtil.lightTextColor),
                  ),
                  BlankSpace.height(5),
                  ClipOval(
                    child: Container(
                      width: 5,
                      height: 5,
                      color: value == category
                          ? ColorUtil.mainColor
                          : Colors.white,
                    ),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              onTap: () {
                if (value != category) {
                  feedbackNotifier.clearProfilePostList();
                  context
                      .findAncestorStateOfType<_ProfilePageState>()
                      .category
                      .value = category;
                  category.getPostListOfCategory(
                      feedbackNotifier, messageProvider);
                }
              },
            );
          },
        ),
      );
    });
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
