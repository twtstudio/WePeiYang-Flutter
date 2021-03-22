import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';

import 'components/post_card.dart';

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
      Provider.of<FeedbackNotifier>(context, listen: false).getMyPosts();
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
                    child: _profileHeader(
                      SliverToBoxAdapter(
                        child: Container(
                          height: 140.0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // My posts tab.
                                  Expanded(
                                    child: InkWell(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'lib/feedback/assets/img/my_post.png',
                                            height: 30,
                                          ),
                                          BlankSpace.height(5),
                                          Text(
                                            '我的提问',
                                            style: TextStyle(
                                                height: 1,
                                                color:
                                                    ColorUtil.lightTextColor),
                                          ),
                                          BlankSpace.height(5),
                                          ClipOval(
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              color: _currentTab ==
                                                      _CurrentTab.myPosts
                                                  ? ColorUtil.mainColor
                                                  : Colors.white,
                                            ),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                      onTap: () {
                                        if (_currentTab ==
                                            _CurrentTab.myFavorite) {
                                          notifier.clearProfilePostList();
                                          _currentTab = _CurrentTab.myPosts;
                                          notifier.getMyPosts();
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
                                                height: 1,
                                                color:
                                                    ColorUtil.lightTextColor),
                                          ),
                                          BlankSpace.height(5),
                                          ClipOval(
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              color: _currentTab ==
                                                      _CurrentTab.myFavorite
                                                  ? ColorUtil.mainColor
                                                  : Colors.white,
                                            ),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                      onTap: () {
                                        if (_currentTab ==
                                            _CurrentTab.myPosts) {
                                          notifier.clearProfilePostList();
                                          _currentTab = _CurrentTab.myFavorite;
                                          notifier.getMyFavoritePosts();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                                  notifier.profilePostHitLike(index,
                                      notifier.profilePostList[index].id);
                                },
                                onContentLongPressed: () {
                                  if (_currentTab == _CurrentTab.myPosts) {
                                    if (!_deleteLock) {
                                      _deleteLock = true;
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Center(
                                              child: Container(
                                                height: 150,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Color.fromRGBO(
                                                        237, 240, 244, 1)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10),
                                                      child: Text("您确定要删除问题吗？",
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      79,
                                                                      88,
                                                                      107,
                                                                      1),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text("取消",
                                                              style: TextStyle(
                                                                color: ColorUtil
                                                                    .boldTextColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              )),
                                                        ),
                                                        Container(width: 30),
                                                        GestureDetector(
                                                          onTap: () {
                                                            notifier.deletePost(
                                                                index, () {
                                                              _deleteLock =
                                                                  false;
                                                              setState(() {});
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Text("确定",
                                                                style:
                                                                    TextStyle(
                                                                      color: ColorUtil
                                                                      .boldTextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).then((value) {
                                        _deleteLock = false;
                                      });
                                    }
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
                                  ).then((value) async {
                                    print(value);
                                    if (value == false) {
                                      notifier.removeProfilePost(index);
                                    }
                                  });
                                },
                                onLikePressed: () {
                                  notifier.profilePostHitLike(index,
                                      notifier.profilePostList[index].id);
                                },
                                onContentLongPressed: () {
                                  if (_currentTab == _CurrentTab.myPosts) {
                                    if (!_deleteLock) {
                                      _deleteLock = true;
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Center(
                                              child: Container(
                                                height: 150,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Color.fromRGBO(
                                                        237, 240, 244, 1)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10),
                                                      child: Text("您确定要删除问题吗？",
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      79,
                                                                      88,
                                                                      107,
                                                                      1),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            "取消",
                                                            style: TextStyle(
                                                              color: ColorUtil
                                                                  .boldTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(width: 30),
                                                        GestureDetector(
                                                          onTap: () {
                                                            notifier.deletePost(
                                                                index, () {
                                                              _deleteLock =
                                                                  false;
                                                              setState(() {});
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Text(
                                                              "确定",
                                                              style: TextStyle(
                                                                color: ColorUtil
                                                                    .boldTextColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).then((value) {
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
}
