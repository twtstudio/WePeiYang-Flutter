import 'package:flutter/material.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/refresh_header.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import '../feedback_router.dart';
import '../util/color_util.dart';
import 'components/change_nickname_dialog.dart';
import 'components/post_card.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> _postList = [];
  MessageProvider messageProvider;
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  _getMyPosts({Function(List<Post>) onSuccess, Function onFail, int current}) {
    FeedbackService.getMyPosts(
        page: current ?? currentPage,
        page_size: 10,
        onResult: (list) {
          setState(() {
            onSuccess?.call(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail?.call();
        });
  }

  //刷新
  _onRefresh() {
    FeedbackService.getUserInfo(
        onSuccess: () {},
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
    _postList.clear();
    currentPage = 1;
    _refreshController.resetNoData();
    _getMyPosts(onSuccess: (list) {
      _postList.addAll(list);
      _refreshController.refreshCompleted();
    }, onFail: () {
      _refreshController.refreshFailed();
    });
    setState(() {});
  }

//下拉加载
  _onLoading() {
    currentPage++;
    _getMyPosts(onSuccess: (list) {
      if (list.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _postList.addAll(list);
        _refreshController.loadComplete();
      }
    }, onFail: () {
      currentPage--;
      _refreshController.loadFailed();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var postLists = (List.generate(
      _postList.length,
      (index) {
        Widget post = PostCardNormal(
          _postList[index],
        );
        return post;
      },
    ));
    var postListShow;
    if (_postList.length.isZero) {
      postListShow = Container(
          height: 430,
          alignment: Alignment.center,
          child: Text("暂无冒泡", style: TextStyle(color: Color(0xff62677b))));
    } else {
      postListShow = Column(
        children: postLists,
      );
    }
//静态header，头像和资料以及appbar
    Widget appBar = Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            SizedBox(
              height: 144.h - 0.125.sw,
              child: Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.mailbox),
                    child: Icon(
                      Icons.email_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AuthRouter.setting)
                            .then((_) => this.setState(() {})),
                    child: Image.asset(
                      'assets/images/setting.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            SizedBox(
              height: 0.125.sw,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 30.w + 0.25.sw),
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 0.33.sw,
                          ),
                          child: Text(CommonPreferences.lakeNickname.value,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style:
                                  TextUtil.base.ProductSans.white.w700.sp(20))),
                      SizedBox(width: 10.w),
                      LevelUtil(
                        width: 44,
                        height: 20,
                        style: TextUtil.base.white.w100.sp(12),
                        level: CommonPreferences.level.value.toString(),
                      ),
                      SizedBox(width: 5.w),
                      InkWell(
                        onTap: () {
                          return showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  ChangeNicknameDialog());
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: SvgPicture.asset(
                            'assets/svg_pics/lake_butt_icons/edit.svg',
                            width: 18.w,
                            color: ColorUtil.mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.w),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 0.125.sw + 12.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 30.w + 0.25.sw),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(CommonPreferences.userNumber.value,
                                    textAlign: TextAlign.start,
                                    style: TextUtil
                                        .base.ProductSans.black4E.w900
                                        .sp(14)),
                                SizedBox(width: 20.w),
                                Text(
                                    "MPID: ${CommonPreferences.lakeUid.value.toString().padLeft(6, '0')}",
                                    textAlign: TextAlign.start,
                                    style: TextUtil
                                        .base.ProductSans.black4E.w900
                                        .sp(14)),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            LevelProgress(
                              value: CommonPreferences.curLevelPoint.value
                                      .toDouble() /
                                  (CommonPreferences.curLevelPoint.value +
                                          CommonPreferences
                                              .nextLevelPoint.value)
                                      .toDouble(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Spacer(),
                      CustomCard(
                        image: 'assets/images/mymsg.png',
                        text: '消息中心',
                        onPressed: () {
                          Navigator.pushNamed(context, FeedbackRouter.mailbox);
                        },
                      ),
                      SizedBox(width: 10.w),
                      CustomCard(
                        image: 'assets/images/mylike.png',
                        text: '我的点赞',
                        onPressed: () {
                          Navigator.pushNamed(context, FeedbackRouter.mailbox);
                        },
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      CustomCard(
                        image: 'assets/images/myfav.png',
                        text: '我的收藏',
                        onPressed: () {
                          Navigator.pushNamed(
                              context, FeedbackRouter.collection);
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 16.h)
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 148.h - 0.125.sw,
          child: GestureDetector(
            onTap: () {
              // 进之前request出来之后就可以刷新
              Navigator.pushNamed(context, AuthRouter.avatarCrop)
                  .then((_) => _refreshController.requestRefresh());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Hero(
                tag: 'avatar',
                child: UserAvatarImage(
                  size: 0.25.sw,
                  iconColor: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );

    Widget body = ListView(
      children: [
        appBar,
        Container(
          color: Colors.white,
          child: postListShow,
        )
      ],
    );

    return Container(
      //改背景色用
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFF2C7EDF),
                Color(0xFFA6CFFF),
                // 用来挡下面圆角左右的空
                Colors.white
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // 在0.7停止同理
              stops: [0, 0.23, 0.4])),
      child: SafeArea(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: RefreshHeader(),
          footer: ClassicFooter(
            idleText: '没有更多数据了:>',
            idleIcon: Icon(Icons.check),
          ),
          enablePullDown: true,
          onRefresh: _onRefresh,
          enablePullUp: true,
          onLoading: _onLoading,
          child: body,
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String image;
  final String text;
  final Function onPressed;

  const CustomCard({Key key, this.image, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call();
      },
      child: Container(
        width: 113.w,
        height: 90.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  image,
                  width: 24.w,
                ),
              ],
            ),
            SizedBox(height: 7.h),
            Text(text,
                maxLines: 1, style: TextUtil.base.w400.black2A.sp(12).medium),
          ],
        ),
      ),
    );
  }
}
