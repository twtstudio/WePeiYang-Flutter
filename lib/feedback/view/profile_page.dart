import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/blank_space.dart';

import 'components/post_card.dart';

/// Almost the same as UserPage
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int userId = 1;
  List<Post> _postList = List();

  Future _getId(studentCardId, name) async {
    try {
      await HttpUtil()
          .get('userId?student_id=$studentCardId&name=$name')
          .then((value) {
        userId = value['data']['user_id'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future _getPosts(tagId, page) async {
    try {
      await HttpUtil().get(
        'question/get/myQuestion?user_id=&limits=20',
        {
          'searchString': '',
          'tagList': '[$tagId]',
          'limits': '20',
          'user_id': '3',
          'page': '$page',
        },
      ).then((value) {
        for (Map<String, dynamic> json in value['data']['data']) {
          _postList.add(Post.fromJson(json));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _getId(CommonPreferences().userNumber.value,
            CommonPreferences().tjuuname.value)
        .then((_) {
      print(CommonPreferences().nickname.value);
      setState(() {});
    });
    _getPosts('', 1).then((_) {
      setState(() {});
    });
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
            CustomScrollView(
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
                      onTap: () => Navigator.pushNamed(context, '/user_info'),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                      return _postList[index].topImgUrl != '' &&
                              _postList[index].topImgUrl != null
                          ? PostCard.image(_postList[index])
                          : PostCard(_postList[index]);
                    },
                    childCount: _postList.length,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
