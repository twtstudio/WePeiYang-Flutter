import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../commons/themes/template/wpy_theme_data.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import '../../schedule/page/course_page.dart';
import 'components/official_comment_card.dart';
import 'components/post_card.dart';
import 'lake_home_page/lake_notifier.dart';

enum DetailPageStatus {
  loading,
  idle,
  error,
}

// ignore: must_be_immutable
class PostDetailPage extends StatefulWidget {
  Post post;
  int? changeId;

  double get searchBarHeight => 42.h;
  bool? split = false;

  PostDetailPage(this.post, {this.split, this.changeId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with TickerProviderStateMixin {
  DetailPageStatus status = DetailPageStatus.loading;
  List<Floor> _commentList = [];
  List<Floor> _officialCommentList = [];
  bool _showPostCard = true;
  int currentPage = 1;
  int rating = 0;
  final onlyOwner = ValueNotifier<int>(0);
  final order =
      ValueNotifier<int>(CommonPreferences.feedbackFloorSortType.value);

  double _previousOffset = 0;
  final launchKey = GlobalKey<CommentInputFieldState>();
  final imageSelectionKey = GlobalKey<ImageSelectAndViewState>();

  var _refreshController = RefreshController(initialRefresh: false);
  var _controller = ScrollController();

  int preChangeId = 0;

  ///判断管理员权限
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// 如果是从通知栏点进来的
      if (widget.post.fromNotify) {
        _initCommentsOnly(onSuccess: (comments) {
          _commentList.addAll(comments);
          setState(() {
            status = DetailPageStatus.idle;
          });
        }, onFail: () {
          setState(() {
            status = DetailPageStatus.error;
          });
        });
      } else {
        _getOfficialComment();
        _getComments(
            onSuccess: (comments) {
              _commentList.addAll(comments);
            },
            onFail: () {},
            current: currentPage);
        status = DetailPageStatus.idle;
      }
    });
    order.addListener(() {
      _refreshController.requestRefresh();
      CommonPreferences.feedbackFloorSortType.value = order.value;
    });
    _getIOSShowBlock();
    initWhileChangingPost();
  }

  void initWhileChangingPost() {
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = 0;
    _onRefresh(isInitial: true);
  }

  /// iOS显示拉黑按钮
  bool _showBlockButton = false;

  _onRefresh({
    bool isInitial = false,
  }) {
    currentPage = 1;
    _refreshController.resetNoData();
    setState(() {
      _showPostCard = isInitial;
    });
    _commentList.clear();
    _initPostAndComments(
      onSuccess: (comments) {
        setState(() {
          _showPostCard = true;
        });
        _commentList = comments;
        _refreshController.refreshCompleted();
      },
      onFail: () {
        setState(() {
          _showPostCard = true;
        });
        _refreshController.refreshFailed();
      },
    );
  }

  _onLoading() {
    currentPage++;
    _getComments(onSuccess: (comments) {
      if (comments.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _commentList.addAll(comments);
        _refreshController.loadComplete();
      }
    }, onFail: () {
      _refreshController.loadFailed();
      currentPage--;
    });
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (context.read<NewFloorProvider>().inputFieldEnabled == true &&
        (scrollInfo.metrics.pixels - _previousOffset).abs() >= 20) {
      context.read<NewFloorProvider>().inputFieldEnabled = false;
      context.read<NewFloorProvider>().clearAndClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
    return true;
  }

  // 逻辑有点问题
  _initPostAndComments(
      {required Function(List<Floor>) onSuccess, required Function onFail}) {
    _initPost(onFail).then((success) {
      if (success) {
        _getOfficialComment(onFail: onFail);
        _getComments(
          onSuccess: onSuccess,
          onFail: onFail,
          current: 1,
        );
      }
    });
  }

  _initCommentsOnly(
      {required Function(List<Floor>) onSuccess, required Function onFail}) {
    _getOfficialComment(onFail: onFail);
    _getComments(
      onSuccess: onSuccess,
      onFail: onFail,
      current: 1,
    );
  }

  Future<bool> _initPost(Function onFail) async {
    bool success = false;
    await FeedbackService.getPostById(
      id: widget.post.id,
      onResult: (Post result) {
        success = true;
        widget.post = result;
        rating = widget.post.rating;
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        success = false;
        onFail.call();
        return;
      },
    );
    return success;
  }

  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController selectedScreenshotController = ScreenshotController();

  _getComments(
      {required Function(List<Floor>) onSuccess,
      required Function onFail,
      int? current}) {
    FeedbackService.getComments(
      id: widget.post.id,
      page: current ?? currentPage,
      order: order.value,
      onlyOwner: onlyOwner.value,
      onSuccess: (comments, totalFloor) {
        onSuccess.call(comments);
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        onFail.call();
      },
    );
  }

  _getOfficialComment({Function? onFail}) {
    // 非官方贴不请求
    if (widget.post.type != 1) return;
    FeedbackService.getOfficialComment(
      id: widget.post.id,
      onSuccess: (floor) {
        _officialCommentList = floor;
        setState(() {});
      },
      onFailure: (e) {
        onFail?.call();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  _getIOSShowBlock() async {
    _showBlockButton = await FeedbackService.getIOSShowBlock();
    setState(() {});
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  final screenshotList = ScreenshotNotifier();
  final screenshotSelecting = ValueNotifier(false);
  final screenshotting = ValueNotifier(false);

  Future<void> takeScreenshot(
    ScreenshotController _controller,
    // String name,
    // Widget? widget,
  ) async {
    ToastProvider.running("生成截图中");
    ui.Image? image = await _controller.captureAsUiImage(pixelRatio: 4.0);
    double? photoWidth = image?.width.toDouble();
    print(photoWidth);
    await _controller
        .captureFromLongWidget(Column(
      children: [
        Container(
          width: photoWidth,
          height: image?.height.toDouble(),
          child: CustomPaint(
            painter: CustomImagePainter(image!),
          ),
        ),
        Container(
          width: photoWidth,
          height: photoWidth! * 1220 / 5892,
          child: Image.asset(
            WpyTheme.of(context).brightness == Brightness.dark
                ? "assets/images/bottom_bar_black.png"
                : "assets/images/bottom_bar_white.png",
            fit: BoxFit.fitWidth,
          ),
        )
      ],
    ))
        .then((value) async {
      final fullPath = await saveImageToPath(value);
      GallerySaver.saveImage(fullPath!, albumName: "微北洋");
      ToastProvider.success("图片保存成功");
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Widget bottomInput;

    Widget checkButton = WButton(
      onPressed: () {
        // 点击校务的官方回复时，应当进入official_reply_detail_page而不是在底部弹出输入框，所以这里一定是普通楼层的回复
        launchKey.currentState?.send(false);
        setState(() {});
      },
      child: SvgPicture.asset(
        'assets/svg_pics/lake_butt_icons/send.svg',
        width: SplitUtil.w * 20,
        colorFilter: ColorFilter.mode(
            WpyTheme.of(context).get(WpyColorKey.basicTextColor),
            BlendMode.srcIn),
      ),
    );

    if (preChangeId != (widget.changeId ?? preChangeId)) {
      initWhileChangingPost();
      print("pre: $preChangeId, change: ${widget.changeId}");
      preChangeId = widget.changeId!;
    }

    if (status == DetailPageStatus.loading) {
      body = ListView(
        children: [
          PostCardNormal(
            widget.post,
            outer: false,
          ),
          SizedBox(
            height: SplitUtil.h * 120,
            child: Center(child: Loading()),
          )
        ],
      );
    } else if (status == DetailPageStatus.idle) {
      Widget contentList = ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            return Column(
              children: [
                if (_showPostCard)
                  PostCardNormal(
                    widget.post,
                    outer: false,
                    screenshotController: screenshotController,
                    expandAll: screenshotting.value,
                  ),
                SizedBox(height: SplitUtil.h * 10),
                Row(
                  children: [
                    SizedBox(width: SplitUtil.w * 15),
                    GestureDetector(
                      onTap: () {
                        order.value = 1;
                      },
                      child: Text('时间正序',
                          style: order.value == 1
                              ? TextUtil.base.w700.sp(14).primaryAction(context)
                              : TextUtil.base.label(context).w500.sp(14)),
                    ),
                    SizedBox(width: SplitUtil.w * 15),
                    GestureDetector(
                      onTap: () {
                        order.value = 0;
                      },
                      child: Text('时间倒序',
                          style: order.value == 0
                              ? TextUtil.base.w700.sp(14).primaryAction(context)
                              : TextUtil.base.label(context).w500.sp(14)),
                    ),
                    Spacer(),
                    ValueListenableBuilder(
                      valueListenable: onlyOwner,
                      builder: (context, value, _) {
                        return WButton(
                          onPressed: () {
                            onlyOwner.value = 1 - onlyOwner.value;
                            _refreshController.requestRefresh();
                          },
                          child: value == 1
                              ? Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0, SplitUtil.h * 2, 0, SplitUtil.h * 1),
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryActionColor),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text('  只看楼主  ',
                                      style: TextUtil.base
                                          .reverse(context)
                                          .w400
                                          .sp(14)),
                                )
                              : Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0, SplitUtil.h * 2, 0, SplitUtil.h * 1),
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context).get(
                                        WpyColorKey.secondaryBackgroundColor),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text('  只看楼主  ',
                                      style: TextUtil.base
                                          .label(context)
                                          .w400
                                          .sp(14)),
                                ),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
                SizedBox(height: 10), //topCard,
              ],
            );
          }
          i--;
          if (i < _officialCommentList.length) {
            if (i > 2) i--;
            var data = _officialCommentList[i];
            var list = _officialCommentList;
            if (i == 0) {
              return OfficialReplyCard.reply(
                tag: widget.post.department?.name ?? '',
                comment: data,
                placeAppeared: i,
                ratings: widget.post.rating,
                ancestorId: widget.post.uid,
                onContentPressed: (refresh) async {
                  refresh.call(list);
                },
              );
            } else if (i == 1) {
              return OfficialReplyCard.subFloor(
                comment: data,
                placeAppeared: i,
                ratings: widget.post.rating,
                ancestorId: widget.post.uid,
                onContentPressed: (refresh) async {
                  refresh.call(list);
                },
              );
            } else {
              return SizedBox.shrink();
            }
          } else {
            var data = _commentList[i - _officialCommentList.length];
            if (screenshotting.value && !screenshotList.list.contains(data.id))
              return SizedBox.shrink();
            return LayoutBuilder(
              builder: (context, constraints) {
                var _commentBody = ListenableBuilder(
                    listenable: screenshotSelecting,
                    child: ConstrainedBox(
                        constraints: constraints,
                        child: NCommentCard(
                          type: widget.post.type,
                          uid: widget.post.uid,
                          comment: data,
                          ancestorUId: widget.post.id,
                          ancestorName: widget.post.nickname,
                          commentFloor: i + 1,
                          isSubFloor: false,
                          isFullView: false,
                          showBlockButton: _showBlockButton,
                          expandAll: screenshotting.value,
                        )),
                    builder: (context, comment) {
                      return Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (screenshotSelecting.value)
                              Container(
                                margin: EdgeInsets.only(left: 8.w),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  // color: ColorUtil.greyShade300,
                                ),
                                child: ListenableBuilder(
                                    listenable: screenshotList,
                                    builder: (context, _) => Checkbox(
                                          activeColor: WpyTheme.of(context).get(
                                              WpyColorKey
                                                  .oldSecondaryActionColor),
                                          focusColor: WpyTheme.of(context)
                                              .get(WpyColorKey.oldHintColor),
                                          hoverColor: WpyTheme.of(context).get(
                                              WpyColorKey.oldSwitchBarColor),
                                          checkColor: WpyTheme.of(context).get(
                                              WpyColorKey.reverseTextColor),
                                          side: MaterialStateBorderSide
                                              .resolveWith((_) => BorderSide(
                                                    color: WpyTheme.of(context)
                                                        .get(WpyColorKey
                                                            .infoTextColor),
                                                    width: 2,
                                                  )),
                                          value: screenshotList.list
                                              .contains(data.id),
                                          onChanged: (value) {
                                            if (value!)
                                              screenshotList.list.add(data.id);
                                            else
                                              screenshotList.list
                                                  .remove(data.id);
                                            screenshotList.update();
                                          },
                                        )),
                              ),
                            comment ?? SizedBox.shrink(),
                          ],
                        ),
                      );
                    });

                return SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: _commentBody,
                );
              },
            );
          }
        },
        controller: _controller,
        itemCount: _officialCommentList.length + _commentList.length + 1,
      );

      Widget mainList = NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
            idleText: '下拉以刷新 (乀*･ω･)乀',
            releaseText: '下拉以刷新',
            refreshingText: '正在刷新中，请稍等 (*￣3￣)/',
            completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
            failedText: '刷新失败（；´д｀）ゞ',
          ),
          enablePullDown: true,
          onRefresh: _onRefresh,
          footer: ClassicFooter(
            idleText: '下拉以刷新',
            noDataText: '这个冒泡到底啦 (*･ω･)',
            loadingText: '加载中，请稍等  ;P',
            failedText: '加载失败（；´д｀）ゞ',
          ),
          enablePullUp: true,
          onLoading: _onLoading,
          child: ListenableBuilder(
              listenable: screenshotting,
              builder: (context, _) {
                if (screenshotting.value)
                  return Screenshot(
                      child: Container(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          child: contentList),
                      controller: selectedScreenshotController);
                return Container(child: contentList);
              }),
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );

      var inputField =
          CommentInputField(postId: widget.post.id, key: launchKey);

      bottomInput = Column(
        children: [
          Spacer(),
          Consumer<NewFloorProvider>(builder: (BuildContext context, value, _) {
            return AnimatedSize(
              clipBehavior: Clip.antiAlias,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutSine,
              child: Container(
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.iconAnimationStartColor),
                        offset: Offset(0, 1),
                        blurRadius: 6,
                        spreadRadius: 0),
                  ],
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Offstage(
                                  offstage: !value.inputFieldEnabled,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      inputField,
                                      ImageSelectAndView(
                                          key: imageSelectionKey),
                                      SizedBox(height: SplitUtil.h * 4),
                                      Row(
                                        children: [
                                          SizedBox(width: SplitUtil.h * 4),
                                          if (value.images.length == 0)
                                            IconButton(
                                                icon: Image.asset(
                                                  'assets/images/lake_butt_icons/image.png',
                                                  width: SplitUtil.w * 24,
                                                  height: SplitUtil.w * 24,
                                                  color: WpyTheme.of(context)
                                                      .get(WpyColorKey
                                                          .basicTextColor),
                                                ),
                                                onPressed: () =>
                                                    imageSelectionKey
                                                        .currentState
                                                        ?.loadAssets()),
                                          if (value.images.length == 0)
                                            IconButton(
                                                icon: Image.asset(
                                                  'assets/images/lake_butt_icons/camera.png',
                                                  width: SplitUtil.w * 24,
                                                  height: SplitUtil.w * 24,
                                                  fit: BoxFit.contain,
                                                  color: WpyTheme.of(context)
                                                      .get(WpyColorKey
                                                          .basicTextColor),
                                                ),
                                                onPressed: () =>
                                                    imageSelectionKey
                                                        .currentState
                                                        ?.shotPic()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/paste.png',
                                                width: SplitUtil.w * 24,
                                                height: SplitUtil.w * 24,
                                                fit: BoxFit.contain,
                                                color: WpyTheme.of(context).get(
                                                    WpyColorKey.basicTextColor),
                                              ),
                                              onPressed: () => launchKey
                                                  .currentState
                                                  ?.getClipboardData()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/x.png',
                                                width: SplitUtil.w * 24,
                                                height: SplitUtil.w * 24,
                                                fit: BoxFit.fitWidth,
                                                color: WpyTheme.of(context).get(
                                                    WpyColorKey.basicTextColor),
                                              ),
                                              onPressed: () {
                                                if (launchKey
                                                    .currentState!
                                                    .textEditingController
                                                    .text
                                                    .isNotEmpty) {
                                                  launchKey.currentState!
                                                      .textEditingController
                                                      .clear();
                                                  launchKey.currentState
                                                      ?.setState(() {
                                                    launchKey.currentState
                                                            ?.commentLengthIndicator =
                                                        '清空成功';
                                                  });
                                                } else {
                                                  value.clearAndClose();
                                                }
                                              }),
                                          Spacer(),
                                          checkButton,
                                          SizedBox(width: SplitUtil.w * 16),
                                        ],
                                      ),
                                      SizedBox(height: SplitUtil.h * 10)
                                    ],
                                  )),
                              Offstage(
                                offstage: value.inputFieldEnabled,
                                child: InkWell(
                                  onTap: () {
                                    context
                                        .read<NewFloorProvider>()
                                        .inputFieldEnabled = true;
                                    value.inputFieldOpenAndReplyTo(0);
                                    FocusScope.of(context)
                                        .requestFocus(value.focusNode);
                                  },
                                  child: Container(
                                      height: SplitUtil.h * 36,
                                      margin: EdgeInsets.fromLTRB(
                                          SplitUtil.w * 8,
                                          SplitUtil.h * 13,
                                          0,
                                          SplitUtil.h * 13),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: SplitUtil.w * 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: widget.post.type == 1
                                            ? Text('校务帖子为实名发言!!!',
                                                style: TextUtil
                                                    .base.NotoSansSC.w500
                                                    .dangerousRed(context)
                                                    .sp(12))
                                            : Text('友善回复，真诚沟通',
                                                style: TextUtil
                                                    .base.NotoSansSC.w500
                                                    .secondaryInfo(context)
                                                    .sp(12)),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18.r),
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey
                                                .secondaryBackgroundColor),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!value.inputFieldEnabled)
                          BottomLikeFavDislike(widget.post),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
      body = SafeArea(
        child: Stack(
          key: ValueKey("loaded"),
          children: [
            Column(
              children: [
                Expanded(child: mainList),
                SizedBox(height: SplitUtil.h * 60),
              ],
            ),
            bottomInput
          ],
        ),
      );
    } else {
      body = Center(child: Text("error!"));
    }

    var menuButton = IconButton(
        icon: SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
          width: SplitUtil.w * 25,
          colorFilter: ColorFilter.mode(
              WpyTheme.of(context).get(WpyColorKey.basicTextColor),
              BlendMode.srcIn),
        ),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: WpyTheme.of(context).brightness,
                ),
                child: CupertinoActionSheet(
                  actions: [
                    // 拉黑按钮
                    if (Platform.isIOS && _showBlockButton)
                      // 分享按钮
                      CupertinoActionSheetAction(
                        onPressed: () {
                          ToastProvider.success('拉黑用户成功');
                          Navigator.pop(context);
                        },
                        child: Text(
                          '拉黑',
                          style: TextUtil.base.normal.w400.NotoSansSC
                              .primary(context)
                              .sp(16),
                        ),
                      ),
                    // 分享按钮
                    CupertinoActionSheetAction(
                      onPressed: () {
                        if (!_refreshController.isLoading &&
                            !_refreshController.isRefresh) {
                          String weCo =
                              '我在微北洋发现了个有趣的问题【${widget.post.title}】\n#MP${widget.post.id} ，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${widget.post.id}';
                          ClipboardData data = ClipboardData(text: weCo);
                          Clipboard.setData(data);
                          CommonPreferences.feedbackLastWeCo.value =
                              widget.post.id.toString();
                          ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
                          FeedbackService.postShare(
                              id: widget.post.id.toString(),
                              type: 0,
                              onSuccess: () {},
                              onFailure: () {});
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        '分享',
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
                      ),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () async {
                        await takeScreenshot(screenshotController);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '截图分享',
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
                      ),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () async {
                        screenshotSelecting.value = true;
                        ToastProvider.running("点击右上角保存或取消");
                        Navigator.pop(context);
                      },
                      child: Text(
                        '选择评论截图',
                        style: TextUtil.base.normal.w400.NotoSansSC
                            .primary(context)
                            .sp(16),
                      ),
                    ),
                    if (widget.post.isOwner == false)
                      CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pushNamed(context, FeedbackRouter.report,
                                arguments:
                                    ReportPageArgs(widget.post.id, true));
                          },
                          child: Text(
                            '举报',
                            style: TextUtil.base.normal.w400.NotoSansSC
                                .primary(context)
                                .sp(16),
                          ))
                    else
                      CupertinoActionSheetAction(
                          onPressed: () async {
                            bool? confirm =
                                await _showDeleteConfirmDialog('删除');
                            if (confirm ?? false) {
                              FeedbackService.deletePost(
                                id: widget.post.id,
                                onSuccess: () {
                                  // final lake = context.read<LakeModel>();
                                  // lake
                                  //     .lakeAreas[
                                  //         lake.tabList[lake.currentTab].id]!
                                  //     .refreshController
                                  //     .requestRefresh();
                                  ToastProvider.success('删除成功');
                                  Navigator.of(context).popAndPushNamed(
                                      FeedbackRouter.home,
                                      arguments: 2);
                                },
                                onFailure: (e) {
                                  ToastProvider.error(e.error.toString());
                                },
                              );
                            }
                          },
                          child: Text(
                            '删除',
                            style: TextUtil.base.normal.w400.NotoSansSC
                                .primary(context)
                                .sp(16),
                          )),
                    // TODO: 这个收藏并没有用 先注释了
                    // CupertinoActionSheetAction(
                    //   onPressed: () => Navigator.pop(context),
                    //   child: Text(
                    //     '收藏',
                    //     style: TextUtil.base.normal.w400.NotoSansSC
                    //         .primary(context)
                    //         .sp(16),
                    //   ),
                    // ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    // 取消按钮
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: TextUtil.base.normal.w400.NotoSansSC
                          .primary(context)
                          .sp(16),
                    ),
                  ),
                ),
              );
            },
          );
        });
    var manageButton = IconButton(
        icon: Icon(Icons.admin_panel_settings,
            size: SplitUtil.w * 23,
            color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
        onPressed: () => _showManageDialog());

    var confirmScreenshot = IconButton(
        onPressed: () async {
          screenshotSelecting.value = false;
          screenshotting.value = true;
          //TODO:等待图片加载完成
          await Future.delayed(Duration(milliseconds: 888));
          await takeScreenshot(selectedScreenshotController);
          screenshotting.value = false;
          screenshotList.empty();
        },
        icon: Icon(Icons.add_a_photo_outlined,
            color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)));

    var cancelScreenshot = IconButton(
        onPressed: () {
          screenshotList.empty();
          screenshotSelecting.value = false;
        },
        icon: Icon(Icons.cancel_outlined,
            color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)));

    var appBar = AppBar(
      toolbarHeight: SplitUtil.h * 40,
      titleSpacing: 0,
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      leading: IconButton(
        icon: Icon(
          (widget.split ?? false) ? Icons.clear : Icons.arrow_back,
          color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
        ),
        onPressed: () => (widget.split ?? false)
            ? context.read<LakeModel>().clearAndSetSplitPost(Post.empty())
            : Navigator.pop(context, widget.post),
      ),
      actions: [
        if (hasAdmin) manageButton,
        // confirmScreenshot,
        ListenableBuilder(
          listenable: screenshotSelecting,
          builder: (context, child) {
            if (screenshotSelecting.value) return cancelScreenshot;
            return SizedBox.shrink();
          },
        ),
        ListenableBuilder(
          listenable: screenshotSelecting,
          child: menuButton,
          builder: (context, child) {
            if (screenshotSelecting.value) return confirmScreenshot;
            return child!;
          },
        ),

        SizedBox(width: 10),
      ],
      title: WButton(
        onPressed: () => _refreshController.requestRefresh(),
        child: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.post.type == 1 ? '校务提问：实名' : '冒泡',
              style: TextUtil.base.NotoSansSC.label(context).w600.sp(18),
            ),
          ),
        ),
      ),
      elevation: 0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (() {
        return (WpyTheme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light)
            .copyWith(
                systemNavigationBarColor: WpyTheme.of(context)
                    .get(WpyColorKey.secondaryBackgroundColor));
      })(),
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.pop(context, widget.post);
        },
        child: GestureDetector(
          child: Padding(
            padding: widget.split ?? false
                ? EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top <
                            widget.searchBarHeight
                        ? widget.searchBarHeight
                        : MediaQuery.of(context).padding.top)
                : EdgeInsets.zero,
            child: Scaffold(
              backgroundColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              appBar: appBar,
              body: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  if (child.key != ValueKey("loaded")) {
                    return child;
                  } else {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  }
                },
                child: body,
              ),
            ),
          ),
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (details.delta.dx > 20) {
              Navigator.pop(context, widget.post);
            }
          },
        ),
      ),
    );
  }

  Future<bool?> _showManageDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Stack(
            children: [
              ManagerPopUp(post: widget.post),
            ],
          );
        });
  }

  Future<bool?> _showDeleteConfirmDialog(String quote) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '$quote冒泡',
              content: Text(
                '您确定要$quote这条冒泡吗？',
                style: TextStyle(
                    color:
                        WpyTheme.of(context).get(WpyColorKey.basicTextColor)),
              ),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.bright(context).NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.infoText(context).NotoSansSC.sp(16).w600,
              confirmText: "确认",
              gradient: LinearGradient(
                  colors: [
                    WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                    WpyTheme.of(context)
                        .get(WpyColorKey.primaryLightActionColor),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // 在0.7停止同理
                  stops: [0, 0.99]),
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () {
                Navigator.of(context).pop(true);
              });
        });
  }
}

class CommentInputField extends StatefulWidget {
  final int postId;

  const CommentInputField({Key? key, required this.postId}) : super(key: key);

  @override
  CommentInputFieldState createState() => CommentInputFieldState();
}

class CommentInputFieldState extends State<CommentInputField> {
  var textEditingController = TextEditingController();
  FocusNode _commentFocus = FocusNode();
  String commentLengthIndicator = '0/200';

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void send(bool isOfficial) {
    if (textEditingController.text.isNotEmpty ||
        (textEditingController.text.isEmpty &&
            context.read<NewFloorProvider>().images.isNotEmpty)) {
      if (context.read<NewFloorProvider>().images.isNotEmpty) {
        FeedbackService.postPic(
            images: context.read<NewFloorProvider>().images,
            onResult: (images) {
              context.read<NewFloorProvider>().floorSentContent =
                  textEditingController.text;
              context.read<NewFloorProvider>().images.clear();
              if (context.read<NewFloorProvider>().replyTo == 0) {
                _sendFloor(images);
              } else {
                _replyFloor(images, isOfficial);
              }
            },
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            });
      } else if (context.read<NewFloorProvider>().replyTo == 0) {
        context.read<NewFloorProvider>().images.clear();
        _sendFloor([]);
      } else {
        _replyFloor([], isOfficial);
      }
    } else
      ToastProvider.error('评论/回复不能为空哦');
    Provider.of<NewFloorProvider>(context, listen: false).inputFieldClose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Consumer<NewFloorProvider>(builder: (_, data, __) {
      data.focusNode = _commentFocus;
      return TextField(
        style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).primary(context),
        focusNode: _commentFocus,
        controller: textEditingController,
        maxLength: 200,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          counterText: '',
          hintText:
              data.replyTo == 0 ? '回复冒泡：' : '回复楼层：' + data.replyTo.toString(),
          suffix: Text(
            commentLengthIndicator,
            style: TextUtil.base.w400.NotoSansSC.sp(14).replySuffix(context),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: SplitUtil.h * 8, horizontal: SplitUtil.w * 20),
          fillColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          hintStyle: TextStyle(
            color: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
          ),
          filled: true,
          isDense: true,
        ),
        onChanged: (text) {
          commentLengthIndicator = '${text.characters.length}/200';
          setState(() {});
        },
        minLines: 1,
        maxLines: 10,
      );
    });

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: SplitUtil.h * 8, horizontal: SplitUtil.w * 10),
      child: inputField,
    );
  }

  getClipboardData() async {
    var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      ///将获取的粘贴板的内容进行展示
      textEditingController.text += clipboardData.text!;
      setState(() {
        commentLengthIndicator = '${clipboardData.text!.length}/200';
      });
    }
  }

  _sendFloor(List<String> list) {
    ToastProvider.running('创建楼层中 q(≧▽≦q)');
    FeedbackService.sendFloor(
      id: widget.postId.toString(),
      content: textEditingController.text,
      images: list.isEmpty ? [''] : list,
      onSuccess: () {
        setState(() => commentLengthIndicator = '0/200');
        FocusManager.instance.primaryFocus?.unfocus();
        context.read<NewFloorProvider>().clearAndClose();
        textEditingController.text = '';
        ToastProvider.success("评论成功 (❁´◡`❁)");
      },
      onFailure: (e) => ToastProvider.error(
        '好像出错了(っ °Д °;)っ...错误信息：' + e.error.toString(),
      ),
    );
  }

  _replyFloor(List<String> list, bool isOfficial) {
    ToastProvider.running('回复中 q(≧▽≦)/');
    if (isOfficial == false) {
      FeedbackService.replyFloor(
        id: context.read<NewFloorProvider>().replyTo.toString(),
        content: textEditingController.text,
        images: list.isEmpty ? [''] : list,
        onSuccess: () {
          setState(() => commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus?.unfocus();
          context.read<NewFloorProvider>().clearAndClose();
          textEditingController.text = '';
          ToastProvider.success("回复成功 (❁´3`❁)");
        },
        onFailure: (e) => ToastProvider.error(
          '好像出错了（；´д｀）ゞ...错误信息：' + e.error.toString(),
        ),
      );
    } else {
      FeedbackService.replyOfficialFloor(
        id: context.read<NewFloorProvider>().replyTo.toString(),
        content: textEditingController.text,
        images: list.isEmpty ? [''] : list,
        onSuccess: () {
          setState(() => commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus?.unfocus();
          context.read<NewFloorProvider>().clearAndClose();
          textEditingController.text = '';
          ToastProvider.success("回复成功 (❁´3`❁)");
        },
        onFailure: (e) => ToastProvider.error(
          '好像出错了（；´д｀）ゞ...错误信息：' + e.error.toString(),
        ),
      );
    }
  }
}

class ImageSelectAndView extends StatefulWidget {
  const ImageSelectAndView({Key? key}) : super(key: key);

  @override
  ImageSelectAndViewState createState() => ImageSelectAndViewState();
}

class ImageSelectAndViewState extends State<ImageSelectAndView> {
  shotPic() async {
    final asset = await ImagePicker().pickImage(source: ImageSource.camera);
    if (asset == null) return;
    File file = await File(asset.path);
    for (int j = 0; file.lengthSync() > 2000 * 1024 && j < 10; j++) {
      file = await FlutterNativeImage.compressImage(file.path, quality: 80);
      if (j == 10) {
        ToastProvider.error('您的图片实在太大了，请自行压缩到2MB内再试吧');
        return;
      }
    }
    Provider.of<NewFloorProvider>(context, listen: false).images.add(file);
    if (!mounted) return 0;
    setState(() {});
  }

  loadAssets() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          themeColor:
              WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor)),
    );
    if (assets == null) return; // 取消选择的情况
    for (int i = 0; i < assets.length; i++) {
      File? file = await assets[i].file;
      if (file == null) {
        ToastProvider.error('选取图片异常，请重新尝试');
        return;
      }
      for (int j = 0; file!.lengthSync() > 2000 * 1024 && j < 10; j++) {
        file = await FlutterNativeImage.compressImage(file.path, quality: 80);
        if (j == 10) {
          ToastProvider.error('您的图片实在太大了，请自行压缩到2MB内再试吧');
          return;
        }
      }
      Provider.of<NewFloorProvider>(context, listen: false).images.add(file);
    }
    if (!mounted) return 0;
    setState(() {});
  }

  Future<String?> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('是否要删除此图片'),
        actions: [
          WButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text('取消')),
          WButton(
              onPressed: () {
                Navigator.of(context).pop('ok');
              },
              child: Text('确定')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: SplitUtil.w * 400),
      child: Consumer<NewFloorProvider>(
        builder: (_, data, __) => data.images.isEmpty
            ? SizedBox()
            : SizedBox(
                height: SplitUtil.w * 80,
                width: SplitUtil.w * 100,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: WButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          FeedbackRouter.localImageView,
                          arguments:
                              LocalImageViewPageArgs(data.images, [], 1, 0),
                        ),
                        child: Container(
                          height: SplitUtil.w * 80,
                          width: SplitUtil.w * 80,
                          margin: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                                width: 1,
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.dislikeSecondary)),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              image: FileImage(
                                data.images[0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: WButton(
                        onPressed: () async {
                          var result = await _showDialog();
                          if (result == 'ok') {
                            data.images.removeAt(0);
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: SplitUtil.w * 20,
                          height: SplitUtil.w * 20,
                          decoration: BoxDecoration(
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.dislikeSecondary),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: Icon(
                            Icons.close,
                            size: SplitUtil.w * 14,
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.secondaryBackgroundColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ManagerPopUp extends StatefulWidget {
  final Post post;

  const ManagerPopUp({Key? key, required this.post}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ManagerPopUpState();
}

class _ManagerPopUpState extends State<ManagerPopUp>
    with SingleTickerProviderStateMixin {
  late final int originTag;

  static const originTagMap = {
    'top': 0,
    'recommend': 1,
    'theme': 2,
  };

  @override
  void initState() {
    originTag = originTagMap[widget.post.eTag] ?? 3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) return;
        try {
          context
              .read<LakeModel>()
              .lakeAreas[context
                  .read<LakeModel>()
                  .tabList[context.read<LakeModel>().currentTab]
                  .id]
              ?.refreshController
              .requestRefresh();
        } catch (e) {}
        Navigator.pop(context);
      },
      canPop: false,
      // onWillPop: () async {
      //   try {
      //     context
      //         .read<LakeModel>()
      //         .lakeAreas[context
      //             .read<LakeModel>()
      //             .tabList[context.read<LakeModel>().currentTab]
      //             .id]
      //         ?.refreshController
      //         .requestRefresh();
      //   } catch (e) {
      //     //TODO:FIX: Try not to call requestRefresh() before build,please call after the ui was rendered
      //   }
      //   return true;
      // },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: EdgeInsets.all(WePeiYangApp.screenWidth / 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 4),
              Text(
                ' 帖子：' + widget.post.title,
                style: TextUtil.base.ProductSans.label(context).medium.sp(18),
              ),
              Text(
                ' 楼主昵称：${widget.post.nickname}\n 楼主id：${widget.post.uid}\n 帖子id：${widget.post.id}',
                style: TextUtil.base.ProductSans.label(context).medium.sp(18),
              ),
              AnimatedOption(
                origin: originTag == 0,
                id: widget.post.id,
                color1:
                    WpyTheme.of(context).get(WpyColorKey.pinedPostTagBColor),
                color2:
                    WpyTheme.of(context).get(WpyColorKey.pinedPostTagCColor),
                title: originTag == 0 ? '× 已置顶' : '将此帖置顶',
                action: 0,
              ),
              AnimatedOption(
                  origin: originTag == 1,
                  id: widget.post.id,
                  color1: WpyTheme.of(context)
                      .get(WpyColorKey.elegantPostTagBColor),
                  color2: WpyTheme.of(context)
                      .get(WpyColorKey.elegantPostTagCColor),
                  title: originTag == 1 ? '× 已加精' : '加入精华帖',
                  action: 1),
              AnimatedOption(
                  origin: originTag == 2,
                  id: widget.post.id,
                  color1:
                      WpyTheme.of(context).get(WpyColorKey.activityPostBColor),
                  color2: WpyTheme.of(context)
                      .get(WpyColorKey.activityPostTagCColor),
                  title: originTag == 2 ? '× 正在活动状态' : '变为活动帖',
                  action: 2),
              AnimatedOption(
                  origin: false,
                  id: widget.post.id,
                  color1:
                      WpyTheme.of(context).get(WpyColorKey.deletePostAColor),
                  color2:
                      WpyTheme.of(context).get(WpyColorKey.deletePostBColor),
                  title: '⚠ 删帖',
                  action: 100),
            ]),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
      ),
    );
  }
}

class AnimatedOption extends StatefulWidget {
  final bool origin;
  final Color color1;
  final Color color2;
  final String title;
  final int id;
  final int? action;

  const AnimatedOption(
      {Key? key,
      required this.origin,
      this.action,
      required this.color1,
      required this.color2,
      required this.title,
      required this.id})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedOptionState(origin);
}

class _AnimatedOptionState extends State<AnimatedOption>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  bool origin;
  TextEditingController tc = TextEditingController();

  _AnimatedOptionState(this.origin);

  @override
  Widget build(BuildContext context) {
    return WButton(
      onPressed: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutQuad,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 20, vertical: isSelected ? 12 : 20),
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.4, 1.6),
              colors: [widget.color1, widget.color2],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextUtil.base.reverse(context).medium.sp(20),
              ),
              // 置顶动作
              if (isSelected && widget.action == 0 && !widget.origin)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '0为取消置顶，只能为0~30000',
                        style: TextUtil.base.reverse(context).medium.sp(10),
                      ),
                    ),
                    TextField(
                      controller: tc,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelStyle: TextUtil.base
                            .bright(context)
                            .NotoSansSC
                            .w400
                            .sp(16),
                        hintStyle: TextUtil.base
                            .bright(context)
                            .NotoSansSC
                            .w800
                            .sp(16),
                        hintText: '置顶数值',
                        contentPadding: const EdgeInsets.all(0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextUtil.base.bright(context).medium.sp(16),
                    ),
                    Container(
                        height: 1.5,
                        width: double.infinity,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor)),
                  ],
                ),
              if (isSelected)
                WButton(
                  onPressed: _inkWellOnTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          origin ? '取消' : '确认',
                          style: TextUtil.base.reverse(context).medium.sp(18),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  _inkWellOnTap() async {
    if (widget.action == null) return;
    switch (widget.action) {
      // 加精处理
      case 0:
        if (widget.origin) {
          // 如果是已经置顶的状态
          await FeedbackService.adminTopPost(
            id: widget.id,
            hotIndex: 0,
            onSuccess: () {
              ToastProvider.success('取消成功');
            },
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            },
          );
          // 退出帖子
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        } else {
          if (tc.text != '') {
            await FeedbackService.adminTopPost(
              id: widget.id,
              hotIndex: tc.text,
              onSuccess: () {
                ToastProvider.success('加精成功');
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              },
            );
            // 退出帖子
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          } else {
            ToastProvider.error('请输入数值！');
          }
        }
        break;
      // 删帖
      case 100:
        final reason = await showDialog(
          context: context,
          builder: (context) {
            return SearchableDropdownDialog();
          },
        );
        if (reason == null) return;
        FeedbackService.adminDeletePost(
          id: widget.id.toString(),
          reason: reason == "" ? null : reason,
          onSuccess: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<LakeModel>()
                  .lakeAreas[context
                      .read<LakeModel>()
                      .tabList[context.read<LakeModel>().currentTab]
                      .id]
                  ?.refreshController
                  .requestRefresh();
            });
            ToastProvider.success('删除成功');
            Navigator.of(context).popMultiple(2);
          },
          onFailure: (e) {
            Navigator.of(context).pop();
            ToastProvider.error(e.error.toString());
          },
        );

        break;
      default:
        // 修改etag
        // 如果是已加精、和活动状态
        var val = origin ? 0 : widget.action;
        FeedbackService.adminChangeETag(
            id: widget.id,
            value: val,
            onSuccess: () => setState(() {
                  isSelected = false;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context
                        .read<LakeModel>()
                        .lakeAreas[context
                            .read<LakeModel>()
                            .tabList[context.read<LakeModel>().currentTab]
                            .id]
                        ?.refreshController
                        .requestRefresh();
                  });
                  for (int i = 0; i < 3; i++) {
                    Navigator.of(context).pop();
                  }
                  ToastProvider.running('成功');
                }),
            onFailure: (e) => ToastProvider.error(e.message ?? '失败'));
    }
  }
}

extension NavigatorStateExtension on NavigatorState {
  void popMultiple(int count) {
    for (int i = 0; i < count; i++) {
      pop();
    }
  }
}

class SearchableDropdownDialog extends StatefulWidget {
  @override
  _SearchableDropdownDialogState createState() =>
      _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<SearchableDropdownDialog> {
  List<String> violations = [
    "诽谤他人，泄露他人隐私，侵害他人合法权益",
    "人身攻击及辱骂他人",
    "发表诅咒、歧视、漠视生命尊严等性质的言论",
    "对他人进行诅咒、恐吓或威胁，尤其是死亡威胁",
    "讽刺其他用户，阴阳怪气地表达批评",
    "对其他用户使用粗俗用语，并产生了冒犯",
    "对其他用户创作的内容直接进行贬低性的评论",
    "针对其他用户的私德、观点立场、素质、能力等方面的贬低或不尊重",
    "引战行为，包括但不限于通过敏感话题带节奏，误导大众，引导舆论风向，或者对用户调拨离间，蓄意破坏用户间和谐，故意发布具有引战行为的内容",
    "散布谣言，扰乱社会秩序，破坏社会稳定",
    "重复发布干扰正常用户体验的内容。包括但不限于以下几种形式：",
    "重复的回答内容多次发布在不同问题下",
    "频繁发布难以辨识涵义影响阅读体验的字符、数字等无意义乱码",
    "宣扬淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪",
    "冒充他人，通过头像、用户名等个人信息暗示自己与他人或机构相等同或有关联",
    "冒充他人，通过头像、用户名等个人信息暗示自己与他人或机构相等同或有关联",
    "使用特殊符号、图片等方式规避垃圾广告内容审核的广告内容",
    "不规范转载或大篇幅转载他人内容同时加入推广营销内容",
    "发布包含欺骗性的恶意营销内容，如通过伪造经历、冒充他人等方式进行恶意营销",
    "发布含有潜在危险的内容，或使用第三方网站伪造跳转链接，如钓鱼网站、木马、病毒网站等",
    "煽动民族仇恨、民族歧视，破坏民族团结",
    "侮辱、滥用英烈形象，否定英烈事迹，美化粉饰侵略战争行为的",
    "破坏国家宗教政策，宣扬邪教和封建迷信",
    "反对宪法所确定的基本原则",
    "损害国家荣誉和利益",
    "煽动非法集会、结社、游行、示威、聚众扰乱社会秩序",
    "危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一",
    "含有法律、行政法规禁止的其他内容的信息",
    "恶意对抗行为，包括但不限于使用变体、谐音等方式规避安全审查，明知相关行为违反法律法规和社区规范仍然多次发布等"
  ];

  final selectedItem = ValueNotifier("");
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      titlePadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
      ),
      actionsPadding: EdgeInsets.all(10),
      title: Center(child: Text('删帖原因')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return violations;
              } else {
                final lowerCaseText = textEditingValue.text.toLowerCase();
                return violations.where((String item) {
                  return item.toLowerCase().contains(lowerCaseText);
                });
              }
            },
            onSelected: (String selection) {
              selectedItem.value = selection;
              focusNode.unfocus();
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              this.focusNode = focusNode;
              this.textEditingController = textEditingController;
              textEditingController.addListener(() {
                selectedItem.value = textEditingController.text;
              });
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: '原因',
                  labelStyle: TextStyle(
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryInfoTextColor),
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.primaryTextButtonColor),
                      width: 2.0,
                    ),
                  ),
                ),
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: Container(
                      width: 300,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(
            '取消',
            style: TextStyle(
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: selectedItem,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop("");
            },
            child: Text(
              '直接删除',
              style: TextStyle(
                color: WpyTheme.of(context).get(WpyColorKey.dangerousRed),
              ),
            ),
          ),
          builder: (ctx, old) {
            if (selectedItem.value == "") return old!;
            return ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
              ),
              onPressed: () async {
                if (selectedItem.value == "") {
                  ToastProvider.error('请选择删帖原因');
                  return;
                }
                Navigator.of(context).pop(selectedItem.value);
              },
              child: Text(
                '确定',
                style: TextStyle(
                  color: WpyTheme.of(context).get(WpyColorKey.brightTextColor),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
