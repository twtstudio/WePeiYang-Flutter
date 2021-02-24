import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';

import 'file:///C:/Users/tranced/Documents/Projects/WePeiYang-Flutter/lib/feedback/util/feedback_router.dart';

import 'components/post_card.dart';

/// Almost the same as UserPage
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int userId = 1;

  @override
  void initState() {
    Provider.of<FeedbackNotifier>(context, listen: false).getMyPosts();
    for (Post post in Provider.of<FeedbackNotifier>(context, listen: false)
        .profilePostList) {
      print(post.title);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Stack(
          children: <Widget>[
            Container(height: 350, color: ColorUtil.profileBackgroundColor),
            Consumer<FeedbackNotifier>(
              builder: (context, notifier, widget) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: BlankSpace.height(ScreenUtil.paddingTop),
                    ),
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: BlankSpace.height(23),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15.0),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/user_info'),
                          child: ClipOval(
                              child: Image.asset(
                            'assets/images/user_image.jpg',
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          )),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Text('BOTillya',
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
                    // Buttons of two tabs.
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
                                              color: ColorUtil.lightTextColor),
                                        ),
                                        BlankSpace.height(5),
                                        // TODO: Color should change dynamically.
                                        ClipOval(
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            color: ColorUtil.mainColor,
                                          ),
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                  ),
                                ),
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
                                              color: ColorUtil.lightTextColor),
                                        ),
                                        BlankSpace.height(5),
                                        // TODO: Color should change dynamically.
                                        ClipOval(
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                    print('like!');
                                    notifier.profilePostHitLike(index,
                                        notifier.profilePostList[index].id, 3);
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
                                          PostOrigin.profile),
                                    );
                                  },
                                  onLikePressed: () {
                                    print('like!');
                                    notifier.profilePostHitLike(index,
                                        notifier.profilePostList[index].id, 3);
                                  },
                                );
                        },
                        childCount: notifier.profilePostList.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
