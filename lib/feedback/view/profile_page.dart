import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/refresh_header.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import '../feedback_router.dart';
import 'components/change_nickname_dialog.dart';
import 'components/post_card.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> _postList = [];
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  _getMyPosts(
      {required Function(List<Post>) onSuccess, required Function onFail}) {
    FeedbackService.getMyPosts(
        page: currentPage,
        page_size: 10,
        onResult: (list) {
          if (!mounted) return;
          setState(() {
            onSuccess.call(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail.call();
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
    print(CommonPreferences.curLevelPoint.value.toDouble());
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
          child: Text("暂无冒泡", style: TextUtil.base.oldThirdAction(context)));
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
                  WButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AuthRouter.mailbox),
                    child: Icon(
                      Icons.email_outlined,
                      size: 28,
                      color:
                          WpyTheme.of(context).get(WpyColorKey.brightTextColor),
                    ),
                  ),
                  SizedBox(width: 15),
                  WButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AuthRouter.setting)
                          ..then((_) => _refreshController.requestRefresh()),
                    child: Image.asset(
                      'assets/images/setting.png',
                      width: 24,
                      height: 24,
                      color:
                          WpyTheme.of(context).get(WpyColorKey.brightTextColor),
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
                      SizedBox(width: 18.w + 0.3.sw),
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 0.33.sw,
                          ),
                          child: Text(CommonPreferences.lakeNickname.value,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextUtil.base.ProductSans
                                  .bright(context)
                                  .w700
                                  .sp(20))),
                      SizedBox(width: 10.w),
                      LevelUtil(
                        big: true,
                        style: TextUtil.base.bright(context).w100.sp(12),
                        level: CommonPreferences.level.value.toString(),
                      ),
                      SizedBox(width: 5.w),
                      WButton(
                        onPressed: () {
                          showDialog(
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
                            colorFilter: ColorFilter.mode(
                                WpyTheme.of(context)
                                    .get(WpyColorKey.brightTextColor),
                                BlendMode.srcIn),
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
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
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
                        SizedBox(width: 18.w + 0.3.sw),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(CommonPreferences.userNumber.value,
                                    textAlign: TextAlign.start,
                                    style: TextUtil.base.ProductSans
                                        .infoText(context)
                                        .w900
                                        .sp(14)),
                                SizedBox(width: 20.w),
                                Text(
                                    "MPID: ${CommonPreferences.lakeUid.value.toString().padLeft(6, '0')}",
                                    textAlign: TextAlign.start,
                                    style: TextUtil.base.ProductSans
                                        .infoText(context)
                                        .w900
                                        .sp(14)),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            LevelProgress(
                              value: (CommonPreferences.levelPoint.value )
                                      .toDouble() /
                                  (CommonPreferences.nextLevelPoint.value )
                                      .toDouble(),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "还需 ${CommonPreferences.nextLevelPoint.value - CommonPreferences.levelPoint.value} 点经验升至下一级",
                                  style: TextUtil.base.ProductSans
                                      .secondary(context)
                                      .sp(9),
                                ),
                                Text(
                                  " (${CommonPreferences.levelPoint.value.toString()}/${CommonPreferences.nextLevelPoint.value.toString()})",
                                  style: TextUtil.base.ProductSans
                                      .secondary(context)
                                      .bold
                                      .sp(9),
                                ),
                              ],
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
                      // TODO: 等后端修好再打开
                      // SizedBox(width: 10.w),
                      // CustomCard(
                      //   image: 'assets/images/history.png',
                      //   text: '历史浏览',
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, FeedbackRouter.history);
                      //   },
                      // ),
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
          top: 148.h - 0.15.sw,
          left: 12.w,
          child: WButton(
            onPressed: () {
              // 进之前request出来之后就可以刷新
              Navigator.pushNamed(context, AuthRouter.avatarCrop)
                  .then((_) => _refreshController.requestRefresh());
            },
            child: Hero(
              tag: 'avatar',
              child: UserAvatarImage(
                size: 0.3.sw,
                iconColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                context: context,
              ),
            ),
          ),
        )
      ],
    );

    Widget body = ListView(
      children: [
        appBar,
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_refreshController.isRefresh),
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            child: postListShow,
          ),
        )
      ],
    );

    return Container(
      //改背景色用
      decoration: BoxDecoration(
          gradient: WpyTheme.of(context)
              .getGradient(WpyColorSetKey.backgroundGradient)),
      child: SafeArea(
        bottom: true,
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: RefreshHeader(context),
          footer: ClassicFooter(
            textStyle: TextStyle(
                color:
                    WpyTheme.of(context).get(WpyColorKey.secondaryTextColor)),
            idleText: '没有更多数据了:>',
            idleIcon: Icon(Icons.check,
                color:
                    WpyTheme.of(context).get(WpyColorKey.secondaryTextColor)),
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

  const CustomCard(
      {Key? key,
      required this.image,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WButton(
      onPressed: () {
        onPressed.call();
      },
      child: Container(
        width: 113.w,
        height: 90.h,
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 8,
              color: WpyTheme.of(context)
                  .get(WpyColorKey.basicTextColor)
                  .withOpacity(0.1),
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
                maxLines: 1,
                style: TextUtil.base.w400.primary(context).sp(12).medium),
          ],
        ),
      ),
    );
  }
}
