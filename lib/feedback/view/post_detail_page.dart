import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../commons/widgets/w_button.dart';
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

  PostDetailPage(this.post);

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

  ///判断管理员权限
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  void initState() {
    super.initState();
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = 0;
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
    _getIOSShowBlock();
    order.addListener(() {
      _refreshController.requestRefresh();
      CommonPreferences.feedbackFloorSortType.value = order.value;
    });
  }

  /// iOS显示拉黑按钮
  bool _showBlockButton = false;

  _onRefresh() {
    currentPage = 1;
    _refreshController.resetNoData();
    setState(() {
      _showPostCard = false;
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
    String name,
    // Widget? widget,
  ) async {
    ToastProvider.running("生成截图中");
    final dir = StorageUtil.tempDir.path;
    final fullPath = path.join(dir, name);
    await _controller.captureAndSave(dir,
        fileName: name, delay: Duration(seconds: 1));
    await GallerySaver.saveImage(fullPath, albumName: "微北洋");
    await File(fullPath).delete();
    ToastProvider.success("图片保存成功");
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
      child: SvgPicture.asset('assets/svg_pics/lake_butt_icons/send.svg',
          width: 20),
    );
    if (status == DetailPageStatus.loading) {
      body = ListView(
        children: [
          PostCardNormal(
            widget.post,
            outer: false,
          ),
          SizedBox(
            height: 120,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    WButton(
                      onPressed: () {
                        order.value = 1;
                      },
                      child: Text('时间正序',
                          style: order.value == 1
                              ? TextUtil.base.black2A.w700.sp(14).primaryAction
                              : TextUtil.base.black2A.w500.sp(14)),
                    ),
                    const SizedBox(width: 15),
                    WButton(
                      onPressed: () {
                        order.value = 0;
                      },
                      child: Text('时间倒序',
                          style: order.value == 0
                              ? TextUtil.base.black2A.w700.sp(14).primaryAction
                              : TextUtil.base.black2A.w500.sp(14)),
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
                                  padding: EdgeInsets.fromLTRB(0, 2, 0, 1),
                                  decoration: BoxDecoration(
                                    color: ColorUtil.blue2CColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('  只看楼主  ',
                                      style: TextUtil.base.reverse.w400.sp(14)),
                                )
                              : Container(
                                  padding: EdgeInsets.fromLTRB(0, 2, 0, 1),
                                  decoration: BoxDecoration(
                                    color: ColorUtil.whiteF8Color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('  只看楼主  ',
                                      style: TextUtil.base.black2A.w400.sp(14)),
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
              return SizedBox();
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
                        color: ColorUtil.transparent,
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
                                    builder: (context, _) {
                                      return Checkbox(
                                        activeColor: ColorUtil.blue105,
                                        focusColor: ColorUtil.hintWhite205,
                                        hoverColor: ColorUtil.white240,
                                        value: screenshotList.list
                                            .contains(data.id),
                                        onChanged: (value) {
                                          if (value!)
                                            screenshotList.list.add(data.id);
                                          else
                                            screenshotList.list.remove(data.id);
                                          screenshotList.update();
                                        },
                                      );
                                    }),
                              ),
                            comment ?? SizedBox.shrink(),
                          ],
                        ),
                      );
                    });

                return SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: _commentBody);
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
                          color: ColorUtil.primaryBackgroundColor, child: contentList),
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: ColorUtil.black12,
                        offset: Offset(0, 1),
                        blurRadius: 6,
                        spreadRadius: 0),
                  ],
                  color: ColorUtil.primaryBackgroundColor,
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
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          SizedBox(width: 4),
                                          if (value.images.length == 0)
                                            IconButton(
                                                icon: Image.asset(
                                                  'assets/images/lake_butt_icons/image.png',
                                                  width: 24,
                                                  height: 24,
                                                ),
                                                onPressed: () =>
                                                    imageSelectionKey
                                                        .currentState
                                                        ?.loadAssets()),
                                          if (value.images.length == 0)
                                            IconButton(
                                                icon: Image.asset(
                                                  'assets/images/lake_butt_icons/camera.png',
                                                  width: 24,
                                                  height: 24,
                                                  fit: BoxFit.contain,
                                                ),
                                                onPressed: () =>
                                                    imageSelectionKey
                                                        .currentState
                                                        ?.shotPic()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/paste.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              onPressed: () => launchKey
                                                  .currentState
                                                  ?.getClipboardData()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/x.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.fitWidth,
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
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  )),
                              Offstage(
                                offstage: value.inputFieldEnabled,
                                child: WButton(
                                  onPressed: () {
                                    context
                                        .read<NewFloorProvider>()
                                        .inputFieldEnabled = true;
                                    value.inputFieldOpenAndReplyTo(0);
                                    FocusScope.of(context)
                                        .requestFocus(value.focusNode);
                                  },
                                  child: Container(
                                      height: 36,
                                      margin:
                                          EdgeInsets.fromLTRB(16, 13, 0, 13),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: widget.post.type == 1
                                            ? Text('校务帖子为实名发言!!!',
                                                style: TextUtil.base.NotoSansSC
                                                    .w500.dangerousRed
                                                    .sp(12))
                                            : Text('友善回复，真诚沟通',
                                                style: TextUtil
                                                    .base.NotoSansSC.w500.grey97
                                                    .sp(12)),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: ColorUtil.whiteF8Color,
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
      body = Stack(
        children: [
          Column(
            children: [
              Expanded(child: mainList),
              SizedBox(height: 60),
            ],
          ),
          bottomInput
        ],
      );
    } else {
      body = Center(child: Text("error!"));
    }

    var menuButton = IconButton(
        icon: SvgPicture.asset(
          'assets/svg_pics/lake_butt_icons/more_horizontal.svg',
          width: 25,
          color: ColorUtil.black00Color,
        ),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
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
                        style:
                            TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
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
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () async {
                      await takeScreenshot(screenshotController,
                          "wpy_post_${widget.post.id}_${DateTime.now().millisecondsSinceEpoch}.png");
                      Navigator.pop(context);
                    },
                    child: Text(
                      '截图分享',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
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
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
                    ),
                  ),
                  if (widget.post.isOwner == false)
                    CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pushNamed(context, FeedbackRouter.report,
                              arguments: ReportPageArgs(widget.post.id, true));
                        },
                        child: Text(
                          '举报',
                          style: TextUtil.base.normal.w400.NotoSansSC.primary
                              .sp(16),
                        ))
                  else
                    CupertinoActionSheetAction(
                        onPressed: () async {
                          bool? confirm = await _showDeleteConfirmDialog('删除');
                          if (confirm ?? false) {
                            FeedbackService.deletePost(
                              id: widget.post.id,
                              onSuccess: () {
                                final lake = context.read<LakeModel>();
                                lake
                                    .lakeAreas[
                                        lake.tabList[lake.currentTab].id]!
                                    .refreshController
                                    .requestRefresh();
                                ToastProvider.success(
                                    S.current.feedback_delete_success);
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
                          style: TextUtil.base.normal.w400.NotoSansSC.primary
                              .sp(16),
                        )),
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '收藏',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
                    ),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  // 取消按钮
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextUtil.base.normal.w400.NotoSansSC.primary.sp(16),
                  ),
                ),
              );
            },
          );
        });
    var manageButton = IconButton(
        icon: Icon(Icons.admin_panel_settings,
            size: 23, color: ColorUtil.black2AColor),
        onPressed: () => _showManageDialog());

    var confirmScreenshot = IconButton(
        onPressed: () async {
          screenshotSelecting.value = false;
          screenshotting.value = true;
          await takeScreenshot(selectedScreenshotController,
              "wpy_post_${widget.post.id}_${DateTime.now().millisecondsSinceEpoch}.png");
          screenshotting.value = false;
          screenshotList.empty();
        },
        icon: Icon(Icons.add_a_photo_outlined, color: ColorUtil.black2AColor));

    var cancelScreenshot = IconButton(
        onPressed: () {
          screenshotList.empty();
          screenshotSelecting.value = false;
        },
        icon: Icon(Icons.cancel_outlined, color: ColorUtil.black2AColor));

    var appBar = AppBar(
      toolbarHeight: 40,
      titleSpacing: 0,
      backgroundColor: ColorUtil.primaryBackgroundColor,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          color: ColorUtil.black25Color,
        ),
        onPressed: () => Navigator.pop(context, widget.post),
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
              style: TextUtil.base.NotoSansSC.black2A.w600.sp(18),
            ),
          ),
        ),
      ),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.post);
        return true;
      },
      child: GestureDetector(
        child: Scaffold(
          backgroundColor: ColorUtil.primaryBackgroundColor,
          appBar: appBar,
          body: body,
        ),
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dx > 20) {
            Navigator.pop(context, widget.post);
          }
        },
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
              content: Text('您确定要$quote这条冒泡吗？'),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.reverse.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.greyA8.NotoSansSC.sp(16).w600,
              confirmText: "确认",
              gradient: LinearGradient(
                  colors: [
                    ColorUtil.blue2CColor,
                    ColorUtil.blueA6Color,
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
        style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).primary,
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
            style: TextUtil.base.w400.NotoSansSC.sp(14).greyAA,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          fillColor: ColorUtil.whiteF8Color,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          themeColor: ColorUtil.primaryTextButtonColor),
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
        title: Text(S.current.feedback_delete_image_content),
        actions: [
          WButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          WButton(
              onPressed: () {
                Navigator.of(context).pop('ok');
              },
              child: Text(S.current.feedback_ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Consumer<NewFloorProvider>(
        builder: (_, data, __) => data.images.isEmpty
            ? SizedBox()
            : SizedBox(
                height: 80,
                width: 100,
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
                          height: 80,
                          width: 82,
                          margin: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border:
                                Border.all(width: 1, color: ColorUtil.black26),
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
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: ColorUtil.black26,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: ColorUtil.secondaryBackgroundColor,
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
    return WillPopScope(
      onWillPop: () async {
        context
            .read<LakeModel>()
            .lakeAreas[context
                .read<LakeModel>()
                .tabList[context.read<LakeModel>().currentTab]
                .id]
            ?.refreshController
            .requestRefresh();
        return true;
      },
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
                style: TextUtil.base.ProductSans.black2A.medium.sp(18),
              ),
              Text(
                ' 楼主昵称：${widget.post.nickname}\n 楼主id：${widget.post.uid}\n 帖子id：${widget.post.id}',
                style: TextUtil.base.ProductSans.black2A.medium.sp(18),
              ),
              AnimatedOption(
                origin: originTag == 0,
                id: widget.post.id,
                color1: ColorUtil.pink208,
                color2: ColorUtil.red134,
                title: originTag == 0 ? '× 已置顶' : '将此帖置顶',
                action: 0,
              ),
              AnimatedOption(
                  origin: originTag == 1,
                  id: widget.post.id,
                  color1: ColorUtil.yellow190,
                  color2: ColorUtil.orange157,
                  title: originTag == 1 ? '× 已加精' : '加入精华帖',
                  action: 1),
              AnimatedOption(
                  origin: originTag == 2,
                  id: widget.post.id,
                  color1: ColorUtil.blue124,
                  color2: ColorUtil.blue72,
                  title: originTag == 2 ? '× 正在活动状态' : '变为活动帖',
                  action: 2),
              AnimatedOption(
                  origin: false,
                  id: widget.post.id,
                  color1: ColorUtil.red43,
                  color2: ColorUtil.red42,
                  title: '⚠ 删帖',
                  action: 100),
            ]),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: ColorUtil.primaryBackgroundColor),
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
                style: TextUtil.base.reverse.medium.sp(20),
              ),
              // 置顶动作
              if (isSelected && widget.action == 0 && !widget.origin)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '0为取消置顶，只能为0~30000',
                        style: TextUtil.base.reverse.medium.sp(10),
                      ),
                    ),
                    TextField(
                      controller: tc,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelStyle: TextUtil.base.reverse.NotoSansSC.w400.sp(16),
                        hintStyle: TextUtil.base.reverse.NotoSansSC.w800.sp(16),
                        hintText: '置顶数值',
                        contentPadding: const EdgeInsets.all(0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextUtil.base.reverse.medium.sp(16),
                    ),
                    Container(
                        height: 1.5,
                        width: double.infinity,
                        color: ColorUtil.primaryBackgroundColor),
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
                          style: TextUtil.base.reverse.medium.sp(18),
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
        FeedbackService.adminDeletePost(
          id: widget.id.toString(),
          onSuccess: () {
            context
                .read<LakeModel>()
                .lakeAreas[context
                    .read<LakeModel>()
                    .tabList[context.read<LakeModel>().currentTab]
                    .id]
                ?.refreshController
                .requestRefresh();
            ToastProvider.success(S.current.feedback_delete_success);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
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
                  context
                      .read<LakeModel>()
                      .lakeAreas[context
                          .read<LakeModel>()
                          .tabList[context.read<LakeModel>().currentTab]
                          .id]
                      ?.refreshController
                      .requestRefresh();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ToastProvider.running('成功');
                }),
            onFailure: (e) => ToastProvider.error(e.message ?? '失败'));
    }
  }
}
