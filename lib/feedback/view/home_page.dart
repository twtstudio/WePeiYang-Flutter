import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/model/tag.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/post_card.dart';

class FeedbackHomePage extends StatefulWidget {
  @override
  _FeedbackHomePageState createState() => _FeedbackHomePageState();
}

class _FeedbackHomePageState extends State<FeedbackHomePage> {
  List<Tag> _tagList = List();
  List<Post> _postList = List();

  /// Get tags using Dio.
  Future _getTags() async {
    try {
      await HttpUtil().get('tag/get/all').then((value) {
        if (0 != value['data'][0]['children'].length) {
          _tagList.clear();
          for (Map<String, dynamic> json in value['data'][0]['children']) {
            _tagList.add(Tag.fromJson(json));
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  /// Get posts using Dio.
  // TODO: Loading and pull-to-refresh not implemented yet.
  Future _getPosts(tagId, page) async {
    try {
      await HttpUtil().get(
        'question/search',
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
    _getTags().then((_) {
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
      /// Click and jump to NewPostPage.
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorUtil.mainColor,
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Jump to NewPostPage.
        },
      ),
      body: CustomScrollView(
        slivers: [
          /// Header.
          SliverPadding(
            padding: EdgeInsets.only(top: ScreenUtil.paddingTop),
            sliver: SliverPersistentHeader(
              delegate: HomeHeaderDelegate(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(1080),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '搜索问题',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(1080),
                                ),
                                contentPadding: EdgeInsets.zero,
                                fillColor: ColorUtil.searchBarBackgroundColor,
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: ColorUtil.mainColor,
                                ),
                              ),
                              enabled: false,
                            ),
                            onTap: () {
                              // TODO: Jump to SearchPage
                              Navigator.pushNamed(context, 'feedback/search');
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        color: ColorUtil.mainColor,
                        icon: Icon(
                          Icons.person_outlined,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            FeedbackRouter.profile,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              pinned: false,
              // TODO: Opacity issue here.
              floating: false,
            ),
          ),

          /// The list of posts.
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _postList[index].topImgUrl != '' &&
                        _postList[index].topImgUrl != null
                    ? PostCard.image(
                        _postList[index],
                        onContentPressed: () {
                          Navigator.pushNamed(context, FeedbackRouter.detail,
                              arguments: _postList[index]);
                        },
                      )
                    : PostCard(
                        _postList[index],
                        onContentPressed: () {
                          Navigator.pushNamed(context, FeedbackRouter.detail,
                              arguments: _postList[index]);
                        },
                      );
              },
              childCount: _postList.length,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  HomeHeaderDelegate({@required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => AppBar().preferredSize.height;

  @override
  double get minExtent => AppBar().preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
