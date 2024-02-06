import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/home/view/lost_and_found_home_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_service.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../feedback/feedback_router.dart';

class LostAndFoundDetailAppBar extends LostAndFoundAppBar {
  LostAndFoundDetailAppBar({
    Key? key,
    required Widget leading,
    required Widget action,
    required Widget title,
    required double height,
  }) : super(
          key: key,
          leading: leading,
          action: action,
          title: title,
          height: height,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      color: Colors.white, // Change the background color to white
      child: Stack(
        children: [
          Positioned(
            left: 0.w,
            bottom: 0.h,
            child: leading,
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: title,
          ),
          Positioned(
            right: 0.w,
            bottom: 0.h,
            child: action,
          )
        ],
      ),
    );
  }
}

class LostAndFoundDetailPage extends StatefulWidget {
  final int postId;
  final bool findOwner;

  LostAndFoundDetailPage({required this.postId, required this.findOwner});

  @override
  _LostAndFoundDetailPageState createState() => _LostAndFoundDetailPageState();
}

class _LostAndFoundDetailPageState extends State<LostAndFoundDetailPage> {
  bool isMine = false;
  bool polished = false;
  String phoneNum = '';
  bool isLimited = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPost(widget.postId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildDetailUI(context, snapshot.data!, widget.findOwner);
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: LostAndFoundDetailAppBar(
              height: 65.h,
              leading: Padding(
                padding: EdgeInsets.only(top: 46.h, left: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WButton(
                    child: WpyPic(
                      'assets/images/back.png',
                      width: 30.w,
                      height: 30.w,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    // Other onPressed logic goes here
                  ),
                ),
              ),
              action: Padding(
                padding: EdgeInsets.only(top: 46.h, right: 16.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: WButton(
                    child: WpyPic(
                      'assets/images/more-horizontal.png',
                      width: 30.w,
                      height: 30.w,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              title: Text('   '),
            ),
          );
        }
      },
    );
  }

  Future<LostAndFoundPost?> fetchPost(int id) {
    Completer<LostAndFoundPost?> completer = Completer();
    try {
      LostAndFoundService.getLostAndFoundPostDetail(
          id: id,
          onResult: (p) {
            completer.complete(p);
          },
          onFailure: (e) {
            // 处理错误
          });
    } catch (e) {
      // 处理错误
    }
    return completer.future;
  }

  Widget MultipleImage(LostAndFoundPost post) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          post.coverPhotoPathInDetail.length,
          (index) => GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              FeedbackRouter.imageView,
              arguments: ImageViewPageArgs(post.coverPhotoPathInDetail,
                  post.coverPhotoPathInDetail.length, index, false),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              child: WpyPic(post.coverPhotoPathInDetail[index],
                  fit: BoxFit.cover,
                  width: (1.sw -
                          40.w -
                          (post.coverPhotoPathInDetail.length - 1) * 10.w) /
                      post.coverPhotoPathInDetail.length,
                  height: (1.sw -
                          40.w -
                          (post.coverPhotoPathInDetail.length - 1) * 10.w) /
                      post.coverPhotoPathInDetail.length,
                  withHolder: true),
            ),
          ),
        ),
      );

  // 构建UI
  Widget buildDetailUI(BuildContext context, LostAndFoundPost post, findOwner) {
    //判断是否是自己的帖子，暂时只能用这个来判断了
    if (CommonPreferences.lakeNickname.value.toString() == post.author) {
      isMine = true;
    }

    void _showConfirmationDialog() {
      var now = DateTime.now();
      var formatter = DateFormat('yyyyMMdd');
      String formattedDate = formatter.format(now);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            content: Flexible(
              child: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    child: Image.asset(
                      'assets/images/tip.png',
                      width: 30.w,
                      height: 30.h,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Flexible(
                    child: Text(
                      isLimited
                          ? '今日已达上限了哦，明天再来吧'
                          : (phoneNum != '' && !isLimited
                              ? "联系方式为：" + phoneNum + '\n'
                              : (findOwner
                                  ? '确定是你遗失的吗？\n每天最多只能获取三次联系方式哦'
                                  : '确定找到了吗？\n每天最多只能获取三次联系方式哦')),
                      style: TextUtil.base.sp(14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110.w, 40.h)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            child: Text(
                              '取消',
                              style: TextUtil.base.bold.primary(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.h),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: phoneNum != '' || isLimited
                                ? null
                                : () {
                                    LostAndFoundService.getRecordNum(
                                      yyyymmdd: formattedDate,
                                      user: CommonPreferences.lakeNickname.value
                                          .toString(),
                                      onResult: (num) {
                                        if (num >= 3) {
                                          setState(() {
                                            isLimited = true;
                                          });
                                          Navigator.of(context).pop();
                                          _showConfirmationDialog();
                                        } else {
                                          setState(() {
                                            phoneNum = post.phone;
                                          });

                                          LostAndFoundService.locationAddRecord(
                                            yyyymmdd: formattedDate,
                                            user: CommonPreferences
                                                .lakeNickname.value
                                                .toString(),
                                            onSuccess: () {},
                                            onFailure: (e) {},
                                          );
                                          Navigator.of(context).pop();
                                          _showConfirmationDialog();
                                        }
                                      },
                                      onFailure: (e) {},
                                    );
                                  },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110.w, 40.h)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  WpyTheme.of(context)
                                      .get(WpyThemeKeys.primaryActionColor)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            child: Text(
                              '确定',
                              style: TextUtil.base.normal.reverse(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      );
    }

    // 删除弹窗
    void _showDeleteDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            content: Flexible(
              child: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    child: Image.asset(
                      'assets/images/tip.png',
                      width: 30.w,
                      height: 30.h,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Flexible(
                    child: Text(
                      '确定要删除吗？',
                      style: TextUtil.base.normal.sp(14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110.w, 40.h)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            child: Text(
                              '取消',
                              style: TextUtil.base.bold.primary(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () =>
                                LostAndFoundService.deleteLostAndFoundPost(
                                    id: post.id,
                                    onSuccess: () {
                                      ToastProvider.success('删除成功');
                                      Navigator.pop(context);
                                    },
                                    onFailure: (e) {
                                      ToastProvider.error('删除失败');
                                    }),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(110, 40)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  WpyTheme.of(context)
                                      .get(WpyThemeKeys.primaryActionColor)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            child: Text(
                              '确定',
                              style: TextUtil.base.normal.reverse(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      );
    }

    String _formatDate(String originalString) {
      if (originalString.length != 14) {
        throw FormatException('Invalid input length');
      }
      return '${originalString.substring(0, 4)}-${originalString.substring(4, 6)}-${originalString.substring(6, 8)} ${originalString.substring(8, 10)}:${originalString.substring(10, 12)}:${originalString.substring(12, 14)}';
    }

    void _showMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: InkWell(
                                onTap: () {
                                  String weCo =
                                      '我在微北洋发现了个有趣的问题【${post.title}】\n#MP${post.id} ，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${post.id}';
                                  ClipboardData data =
                                      ClipboardData(text: weCo);
                                  Clipboard.setData(data);
                                  CommonPreferences.feedbackLastWeCo.value =
                                      post.id.toString();
                                  ToastProvider.success('微口令复制成功，快去分享加快寻找吧！');
                                  FeedbackService.postShare(
                                      id: post.id.toString(),
                                      type: 0,
                                      onSuccess: () {},
                                      onFailure: () {});
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 30.h,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '分享',
                                    style: TextUtil.base.bold
                                        .primary(context)
                                        .sp(15),
                                  ),
                                ),
                              )),
                          Divider(
                              color: WpyTheme.of(context).get(WpyThemeKeys
                                  .primaryBackgroundColor)), // 添加分隔线
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.h),
                            child: InkWell(
                              onTap: () {
                                if (isMine) {
                                  _showDeleteDialog();
                                } else {
                                  Navigator.pushNamed(
                                      context, FeedbackRouter.report,
                                      arguments: ReportPageArgs(post.id, true));
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 30.h,
                                alignment: Alignment.center,
                                child: Text(
                                  isMine ? '删除' : '举报',
                                  style: TextStyle(
                                    fontSize: 15.h,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 35.h,
                          alignment: Alignment.center,
                          child: Text(
                            '取消',
                            style: TextUtil.base.bold.primary(context).sp(15),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20.h,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    var Images = post.coverPhotoPathInDetail.length == 1
        ? SingleImageWidget(post.coverPhotoPathInDetail[0])
        : MultipleImage(post);

    // 使用post数据构建UI
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LostAndFoundDetailAppBar(
        height: 65.h,
        leading: Padding(
          padding: EdgeInsets.only(top: 46.h, left: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: WButton(
              child: WpyPic(
                'assets/images/back.png',
                width: 30.w,
                height: 30.w,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              // Other onPressed logic goes here
            ),
          ),
        ),
        action: Padding(
          padding: EdgeInsets.only(top: 46.h, right: 16.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: WButton(
              child: WpyPic(
                'assets/images/more-horizontal.png',
                width: 30.w,
                height: 30.w,
              ),
              onPressed: () {
                _showMenu();
              },
              // Other onPressed logic goes here
            ),
          ),
        ),
        title: Text('   '),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 91.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/school.png',
                              width: 32.w,
                              height: 32.h,
                            ),
                            SizedBox(width: 13.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: TextUtil.base.normal
                                      .primary(context)
                                      .sp(14),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(post.detailedUploadTime),
                                      style: TextUtil.base.normal.grey90.sp(8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '#MP${post.id.toString().padLeft(6, '0')}',
                          style: TextUtil.base.normal.grey90.sp(12),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      post.title,
                      style: TextUtil.base.w900.sp(17),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(height: 5.h),
                    (post.coverPhotoPathInDetail.isNotEmpty)
                        ? Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Images,
                          )
                        : Container(),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: ColorUtil.whiteF8Color,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.r),
                                decoration: BoxDecoration(
                                  color: WpyTheme.of(context)
                                      .get(WpyThemeKeys.primaryBackgroundColor),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#',
                                  style: TextUtil.base.normal
                                      .primary(context)
                                      .sp(10),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                post.category + '  ',
                                style: TextUtil.base.normal.grey90.sp(10),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '11445次浏览' + '  ',
                          style: TextUtil.base.normal.grey90.sp(9),
                        )
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.all(7.r),
                      child: Text(
                        post.text,
                        style: TextUtil.base.normal.black42.sp(15).h(1.5),
                      ),
                    ),
                    SizedBox(height: 45.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('丢失日期',
                              style:
                                  TextUtil.base.w600.primary(context).sp(14)),
                          SizedBox(width: 15.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 3.h),
                              Text(
                                  "${post.uploadTime.substring(0, 4)}-${post.uploadTime.substring(4, 6)}-${post.uploadTime.substring(6, 8)}",
                                  style: TextUtil.base.w600
                                      .primaryAction(context)
                                      .sp(14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '丢失地点',
                            style: TextUtil.base.w600.primary(context).sp(14),
                          ),
                          SizedBox(width: 15.w),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 3.h),
                                Text(
                                  post.location,
                                  style: TextUtil.base.w600
                                      .primaryAction(context)
                                      .sp(14),
                                ),
                              ])
                        ],
                      ),
                    ),
                    SizedBox(height: 85.h),
                    Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                            width: 110.w,
                            height: 40.h,
                            margin: EdgeInsets.only(left: 30.w),
                            decoration: BoxDecoration(
                              color: WpyTheme.of(context)
                                  .get(WpyThemeKeys.primaryActionColor),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: WButton(
                              child: Text(
                                findOwner ? '我遗失的' : '我找到了',
                                style: TextUtil.base.reverse(context).sp(16),
                              ),
                              onPressed: _showConfirmationDialog,
                            )),
                        SizedBox(
                          width: 30.w,
                        ),
                        Container(
                            width: 110.w,
                            height: 40.h,
                            margin: EdgeInsets.only(left: 30.w),
                            decoration: BoxDecoration(
                              color: polished
                                  ? Colors.grey[200]
                                  : WpyTheme.of(context)
                                      .get(WpyThemeKeys.primaryBackgroundColor),
                              borderRadius: BorderRadius.circular(20.r),
                              border: polished
                                  ? null
                                  : Border.all(
                                      color: WpyTheme.of(context)
                                          .get(WpyThemeKeys.primaryActionColor),
                                      width: 1.w,
                                    ),
                            ),
                            child: WButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    polished
                                        ? 'assets/images/octicon_light-bulb-24-dark.png'
                                        : 'assets/images/octicon_light-bulb-24.png',
                                    width: 24.w,
                                    height: 20.h,
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Text(
                                    polished ? '已擦亮' : '擦亮',
                                    style: polished
                                        ? TextUtil.base.oldListAction(context).sp(16)
                                        : TextUtil.base
                                            .primaryAction(context)
                                            .sp(16),
                                  ),
                                ],
                              ),
                              onPressed: polished
                                  ? null
                                  : () async {
                                      setState(() {
                                        polished = true;
                                      });

                                      await LostAndFoundService.polish(
                                        id: post.id,
                                        user: post.author,
                                        onSuccess: () {
                                          ToastProvider.success('成功擦亮');
                                        },
                                        onFailure: (e) {
                                          // 在此处理请求失败的情况
                                        },
                                      );
                                    },
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleImageWidget extends StatefulWidget {
  final String imageUrl;

  SingleImageWidget(this.imageUrl);

  @override
  State<SingleImageWidget> createState() => _SingleImageWidgetState();
}

class _SingleImageWidgetState extends State<SingleImageWidget> {
  bool _picFullView = false;

  @override
  Widget build(BuildContext context) {
    Completer<ui.Image> completer = Completer<ui.Image>();
    Image image = Image.network(
      widget.imageUrl,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    );
    if (!completer.isCompleted) {
      image.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (!completer.isCompleted) completer.complete(info.image);
      }));
    }

    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        return Container(
          width: 350.w,
          child: snapshot.hasData
              ? snapshot.data!.height / snapshot.data!.width > 2.0
                  ? _picFullView
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.r)),
                              child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                        context,
                                        FeedbackRouter.imageView,
                                        arguments: ImageViewPageArgs(
                                            [widget.imageUrl], 1, 0, true),
                                      ),
                                  child: image),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                    alignment: Alignment.topRight,
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () {
                                  setState(() {
                                    _picFullView = false;
                                  });
                                },
                                child: Text('收起',
                                    style: TextUtil.base
                                        .textButtonPrimary(context)
                                        .w600
                                        .NotoSansSC
                                        .sp(14))),
                          ],
                        )
                      : SizedBox(
                          height: WePeiYangApp.screenWidth * 1.2,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.r)),
                            child: Stack(children: [
                              GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                        context,
                                        //暂时用的湖底的
                                        FeedbackRouter.imageView,
                                        arguments: ImageViewPageArgs(
                                            [widget.imageUrl], 1, 0, true),
                                      ),
                                  child: image),
                              Positioned(
                                  top: 8.h, left: 8.w, child: TextPod('长图')),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _picFullView = true;
                                        });
                                      },
                                      child: Container(
                                          height: 60.h,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(0, -0.7),
                                              end: Alignment(0, 1),
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54,
                                              ],
                                            ),
                                          ),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                SizedBox(width: 10.w),
                                                Text(
                                                  '点击展开\n',
                                                  style: TextUtil
                                                      .base.w600.reverse(context)
                                                      .sp(14)
                                                      .h(0.6),
                                                ),
                                                Spacer(),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black38,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        16.r))),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            12.w,
                                                            4.h,
                                                            10.w,
                                                            6.h),
                                                    child: Text(
                                                      '长图模式',
                                                      style: TextUtil.base.w300
                                                          .reverse(context)
                                                          .sp(12),
                                                    ))
                                              ]))))
                            ]),
                          ))
                  : ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                                context,
                                FeedbackRouter.imageView,
                                arguments: ImageViewPageArgs(
                                    [widget.imageUrl], 1, 0, false),
                              ),
                          child: image),
                    )
              : Icon(
                  Icons.refresh,
                  color: ColorUtil.black54,
                ),
          color: snapshot.hasData
              ? ColorUtil.transparent
              : WpyTheme.of(context).get(WpyThemeKeys.iconAnimationStartColor),
        );
      },
    );
  }
}
