import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/speech_to_text/API/aliyun_isi_protocol.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/masked_rich_text.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/normal_sub_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/schedule/page/course_page.dart';
import '../../commons/speech_to_text/model/record_controller.dart';
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
  bool _managerDialogVisible = false;

  int preChangeId = 0;

  // 录音控制器
  late final RecordController _recordController;
  String _prefixText = ""; // 光标前的文字
  String _suffixText = ""; // 光标后的文字

  ///判断管理员权限
  bool get hasAdmin =>
      CommonPreferences.isSchAdmin.value ||
      CommonPreferences.isStuAdmin.value ||
      CommonPreferences.isSuper.value;

  @override
  void initState() {
    super.initState();
    FeedbackService.visitPost(id: widget.post.id, onFailure: (_) {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadInitialData();
    });
    order.addListener(() {
      _refreshController.requestRefresh();
      CommonPreferences.feedbackFloorSortType.value = order.value;
      // _refreshController.requestRefresh();
    });
    _getIOSShowBlock();

    //初始化录音控制器
    _recordController = RecordController(
      accessKeyId: aliyunInfo.accessKeyId,
      accessKeySecret: aliyunInfo.accessKeySecret,
      appKey: aliyunInfo.appKey,
    );
    _recordController.addListener(_syncVoiceToInput);
  }

  void _loadInitialData() {
    if (widget.post.fromNotify) {
      _initCommentsOnly(onSuccess: (comments) {
        if (!mounted) return;
        setState(() {
          _commentList = comments;
          status = DetailPageStatus.idle;
        });
      }, onFail: () {
        if (!mounted) return;
        setState(() {
          status = DetailPageStatus.error;
        });
      });
      return;
    }
    initWhileChangingPost();
  }

  void initWhileChangingPost() {
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = 0;
    _onRefresh(isInitial: true, updatePageStatus: true);
  }

  /// iOS显示拉黑按钮
  bool _showBlockButton = false;

  _onRefresh({
    bool isInitial = false,
    bool updatePageStatus = false,
  }) {
    currentPage = 1;
    _refreshController.resetNoData();
    setState(() {
      _showPostCard = isInitial;
      _commentList.clear();
      if (updatePageStatus) status = DetailPageStatus.loading;
    });
    _initPostAndComments(
      onSuccess: (comments) {
        if (!mounted) return;
        setState(() {
          _showPostCard = true;
          _commentList = comments;
          if (updatePageStatus) status = DetailPageStatus.idle;
        });
        _refreshController.refreshCompleted();
      },
      onFail: () {
        if (!mounted) return;
        setState(() {
          _showPostCard = true;
          if (updatePageStatus) status = DetailPageStatus.error;
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

  void _refreshAfterCommentSent() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _refreshController.isRefresh ||
          _refreshController.isLoading) {
        return;
      }
      _refreshController.requestRefresh();
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
    _initPost(onFail, rebuild: false).then((success) {
      if (success) {
        _getOfficialComment(onFail: onFail, rebuild: false);
        _getComments(
          onSuccess: onSuccess,
          onFail: onFail,
          current: 1,
          rebuild: false,
        );
      }
    });
  }

  _initCommentsOnly(
      {required Function(List<Floor>) onSuccess, required Function onFail}) {
    _getOfficialComment(onFail: onFail, rebuild: false);
    _getComments(
      onSuccess: onSuccess,
      onFail: onFail,
      current: 1,
      rebuild: false,
    );
  }

  Future<bool> _initPost(Function onFail, {bool rebuild = true}) async {
    bool success = false;
    await FeedbackService.getPostById(
      id: widget.post.id,
      onResult: (Post result) {
        success = true;
        widget.post = result;
        rating = widget.post.rating;
        if (!mounted) return;
        if (rebuild) setState(() {});
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
      int? current,
      bool rebuild = true}) {
    FeedbackService.getComments(
      id: widget.post.id,
      page: current ?? currentPage,
      order: order.value,
      onlyOwner: onlyOwner.value,
      onSuccess: (comments, totalFloor) {
        onSuccess.call(comments);
        if (rebuild && mounted) setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        onFail.call();
      },
    );
  }

  _getOfficialComment({Function? onFail, bool rebuild = true}) {
    // 非官方贴不请求
    if (widget.post.type != 1) return;
    FeedbackService.getOfficialComment(
      id: widget.post.id,
      onSuccess: (floor) {
        _officialCommentList = floor;
        if (rebuild && mounted) setState(() {});
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
    //录音销毁控制器
    _recordController.removeListener(_syncVoiceToInput);
    _recordController.dispose();
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

  Widget _buildCommentCard(BuildContext context, int i) {
    if (i == 0) {
      return Column(
        children: [
          if (_showPostCard)
            PostCardNormal(
              widget.post,
              outer: false,
              screenshotController: screenshotController,
              expandAll: screenshotting.value,
            )
          else ...[
            PostSkeleton(),
            Divider(),
          ],
          SizedBox(height: SplitUtil.h * 10),
          _buildSortSelection(context),
          SizedBox(height: 10), //topCard,
        ],
      );
    }
    i--;
    if (!_showPostCard) {
      // 连续5个PostSkeleton
      return PostSkeleton();
    }

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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            // color: ColorUtil.greyShade300,
                          ),
                          child: ListenableBuilder(
                              listenable: screenshotList,
                              builder: (context, _) => Checkbox(
                                    activeColor: WpyTheme.of(context).get(
                                        WpyColorKey.oldSecondaryActionColor),
                                    focusColor: WpyTheme.of(context)
                                        .get(WpyColorKey.oldHintColor),
                                    hoverColor: WpyTheme.of(context)
                                        .get(WpyColorKey.oldSwitchBarColor),
                                    checkColor: WpyTheme.of(context)
                                        .get(WpyColorKey.reverseTextColor),
                                    side: WidgetStateBorderSide.resolveWith(
                                        (_) => BorderSide(
                                              color: WpyTheme.of(context).get(
                                                  WpyColorKey.infoTextColor),
                                              width: 2,
                                            )),
                                    value:
                                        screenshotList.list.contains(data.id),
                                    onChanged: (value) {
                                      if (value!)
                                        screenshotList.list.add(data.id);
                                      else
                                        screenshotList.list.remove(data.id);
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
  }

  Widget _buildLoadedCommentList() {
    final contentList = ListView.builder(
      itemBuilder: _buildCommentCard,
      controller: _controller,
      itemCount: _showPostCard
          ? _officialCommentList.length + _commentList.length + 1
          : 5,
    );

    return NotificationListener<ScrollNotification>(
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
        child: screenshotting.value
            ? Screenshot(
                child: Container(
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.primaryBackgroundColor),
                    child: contentList),
                controller: selectedScreenshotController)
            : contentList,
      ),
      onNotification: (ScrollNotification scrollInfo) =>
          _onScrollNotification(scrollInfo),
    );
  }

  Widget _buildPageContent() {
    final Widget content = switch (status) {
      DetailPageStatus.loading => _buildLoadingPlaceholder(context),
      DetailPageStatus.idle => _buildLoadedCommentList(),
      DetailPageStatus.error => Center(child: Text("error!")),
    };

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(status),
                    child: content,
                  ),
                ),
              ),
              SizedBox(height: SplitUtil.h * 60),
            ],
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            opacity: status == DetailPageStatus.idle ? 1 : 0,
            child: IgnorePointer(
              ignoring: status != DetailPageStatus.idle,
              child: _buildBottomActionBar(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (preChangeId != (widget.changeId ?? preChangeId)) {
      preChangeId = widget.changeId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) initWhileChangingPost();
      });
    }

    var appBar = AppBar(
      toolbarHeight: SplitUtil.h * 40,
      titleSpacing: 0,
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          (widget.split ?? false) ? Icons.clear : Icons.arrow_back,
          color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
        ),
        onPressed: () => Navigator.pop(context, widget.post),
      ),
      actions: [
        if (hasAdmin) _adminButton(context),
        _screenshotCancel(),
        _screenshotConfirm(context),
        SizedBox(width: 10),
      ],
      centerTitle: true,
      title: WButton(
        onPressed: () => _refreshController.requestRefresh(),
        child: Text(
          widget.post.type == 1 ? '校务提问：实名' : '冒泡',
          style: TextUtil.base.NotoSansSC.label(context).w600.sp(18),
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
        onPopInvokedWithResult: (didPop, _) {
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
              resizeToAvoidBottomInset: false,
              backgroundColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              appBar: appBar,
              body: _buildPageContent(),
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

  ListView _buildLoadingPlaceholder(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        PostCardNormal(
          widget.post,
          outer: false,
        ),
        SizedBox(height: SplitUtil.h * 10),
        _buildSortSelection(context),
        SizedBox(height: 10), //t
        for (int i = 0; i < 5; i++) PostSkeleton(),
      ],
    );
  }

  IconButton _adminButton(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.admin_panel_settings,
            size: SplitUtil.w * 23,
            color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
        onPressed: () => _showManageDialog());
  }

  ListenableBuilder _screenshotConfirm(BuildContext context) {
    return ListenableBuilder(
      listenable: screenshotSelecting,
      child: _buildActionButton(context),
      builder: (context, child) {
        if (screenshotSelecting.value)
          return IconButton(
              onPressed: () async {
                screenshotSelecting.value = false;
                screenshotting.value = true;
                setState(() {});
                //TODO:等待图片加载完成
                await Future.delayed(Duration(milliseconds: 888));
                await takeScreenshot(selectedScreenshotController);
                screenshotting.value = false;
                setState(() {});
                screenshotList.empty();
              },
              icon: Icon(Icons.add_a_photo_outlined,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)));
        ;
        return child!;
      },
    );
  }

  ListenableBuilder _screenshotCancel() {
    return ListenableBuilder(
      listenable: screenshotSelecting,
      builder: (context, child) {
        if (screenshotSelecting.value)
          return IconButton(
              onPressed: () {
                screenshotList.empty();
                screenshotSelecting.value = false;
              },
              icon: Icon(Icons.cancel_outlined,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)));
        return SizedBox.shrink();
      },
    );
  }

  IconButton _buildActionButton(BuildContext context) {
    return IconButton(
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
                        screenshotting.value = true;
                        setState(() {});
                        await Future.delayed(Duration(milliseconds: 300));
                        await takeScreenshot(screenshotController);
                        screenshotting.value = false;
                        setState(() {});
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
                                  LakeUtil.currentController.refreshController
                                      ?.requestRefresh();
                                  ToastProvider.success('删除成功');
                                  Navigator.of(context).popAndPushNamed(
                                      FeedbackRouter.home,
                                      arguments: 3);
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
  }

  Row _buildSortSelection(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: SplitUtil.w * 15),
        // 这里是‘默认’选项即根据点赞数量 ： order.value = 2
        GestureDetector(
            onTap: () {
              if (order.value != 2) {
                order.value = 2;
                _refreshController.requestRefresh();
              }
            },
            child: ValueListenableBuilder<int>(
              valueListenable: order,
              builder: (context, value, _) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text('默认',
                      style: value == 2
                          ? TextUtil.base.w700.sp(14).primaryAction(context)
                          : TextUtil.base.label(context).w500.sp(14)),
                );
              },
            )),
        SizedBox(width: SplitUtil.w * 15),
        // 这里为时间⇅
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // 逻辑：如果当前是0 -> 1, 当前是1 或 2 -> 0
            if (order.value == 0) {
              order.value = 1;
            } else {
              order.value = 0;
            }
            ;
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: ValueListenableBuilder<int>(
              valueListenable: order,
              builder: (context, value, _) {
                String text = '时间 ⇅';
                if (value == 0) text = '时间 ↓'; // 时间降序
                if (value == 1) text = '时间 ↑'; // 时间升序

                bool isTimeSort = (value == 0 || value == 1);
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(text,
                      style: isTimeSort
                          ? TextUtil.base.w700.sp(14).primaryAction(context)
                          : TextUtil.base.label(context).w500.sp(14)),
                );
              },
            ),
          ),
        ),
        Spacer(),
        ValueListenableBuilder(
          // 只看楼主
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
                          style: TextUtil.base.reverse(context).w400.sp(14)),
                    )
                  : Container(
                      padding: EdgeInsets.fromLTRB(
                          0, SplitUtil.h * 2, 0, SplitUtil.h * 1),
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text('  只看楼主  ',
                          style: TextUtil.base.label(context).w400.sp(14)),
                    ),
            );
          },
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  //同步语音文字的逻辑
  void _syncVoiceToInput() {
    if (!mounted) return;

    final inputState = launchKey.currentState;

    // 只有在有结果时才更新
    if (_recordController.state == RecordState.success &&
        _recordController.resultText.isNotEmpty) {
      // 策略：将语音内容追加到光标处，或者直接覆盖
      // 获取当前的语音结果
      final voiceResult = _recordController.resultText;
      // 1. 拼接新文本： 前段 + 语音 + 后段
      final newText = _prefixText + voiceResult + _suffixText;
      // 2. 计算新光标位置： 前段长度 + 语音长度
      final newCursorIndex = _prefixText.length + voiceResult.length;

      inputState?.textEditingController.value = TextEditingValue(
        text: newText,
        // 保持光标在语音文字的后面，方便用户继续输入
        selection: TextSelection.collapsed(offset: newCursorIndex),
      );

      // 更新字数统计
      inputState?.setState(() {
        inputState.commentLengthIndicator = '${newText.length}/200';
      });
    } else if (_recordController.state == RecordState.error) {
      ToastProvider.error(_recordController.errorMessage);
    }
  }

  //切换录音状态
  void _toggleRecording() {
    final inputState = launchKey.currentState;
    if (inputState == null) return;

    if (!_recordController.isRecording) {
      final controller = inputState.textEditingController;
      final text = controller.text;
      final selection = controller.selection;
      // 处理光标丢失的情况（比如没点输入框就点录音），默认追加到最后
      int start = selection.start;
      int end = selection.end;
      if (start < 0 || end < 0) {
        // 如果没有光标，默认光标在最后
        start = text.length;
        end = text.length;
      }
      // 1. 切割光标前的文字
      _prefixText = text.substring(0, start);
      // 2. 切割光标后的文字 (如果有选中文本，selection.end 会跳过选中的部分，实现“语音替换选中文字”的效果)
      _suffixText = text.substring(end, text.length);
    }
    _recordController.toggleRecording();
  }

  GestureDetector _buildBottomActionBar() {
    final checkButton = WButton(
      onPressed: () {
        // 点击校务的官方回复时，应当进入official_reply_detail_page而不是在底部弹出输入框，所以这里一定是普通楼层的回复
        FocusScope.of(context).unfocus(); // 收起键盘
        launchKey.currentState?.send(false);
        setState(() {});
      },
      child: SvgPicture.asset(
        'assets/svg_pics/lake_butt_icons/send.svg',
        width: SplitUtil.w * 20,
        colorFilter: ColorFilter.mode(
          WpyTheme.of(context).get(WpyColorKey.basicTextColor),
          BlendMode.srcIn,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild, // 确保点击事件被捕获，即使是空白区域
      onTap: () {
        // 空白区域点击时，不执行任何操作，防止键盘收起
      },
      child: Column(
        children: [
          Spacer(),
          Consumer<NewFloorProvider>(builder: (BuildContext context, value, _) {
            final keyboardInset = _managerDialogVisible
                ? 0.0
                : MediaQuery.viewInsetsOf(context).bottom;
            final keyboardVisible = keyboardInset > 0;
            return Padding(
              padding: EdgeInsets.only(
                bottom: keyboardInset,
              ),
              child: AnimatedSize(
                clipBehavior: Clip.antiAlias,
                duration: keyboardVisible
                    ? Duration.zero
                    : Duration(milliseconds: 300),
                curve: Curves.easeOutSine,
                child: Container(
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.iconAnimationStartColor),
                        offset: Offset(0, 1),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
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
                                      CommentInputField(
                                        postId: widget.post.id,
                                        onCommentSent: _refreshAfterCommentSent,
                                        key: launchKey,
                                      ),
                                      ImageSelectAndView(key: imageSelectionKey),
                                      SizedBox(height: SplitUtil.h * 4),
                                      Row(
                                        children: [
                                          SizedBox(width: SplitUtil.h * 4),
                                          if (value.images.isEmpty)
                                            IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/image.png',
                                                width: SplitUtil.w * 24,
                                                height: SplitUtil.w * 24,
                                                color: WpyTheme.of(context).get(
                                                    WpyColorKey.basicTextColor),
                                              ),
                                              onPressed: () => imageSelectionKey
                                                  .currentState
                                                  ?.loadAssets(),
                                            ),
                                          if (value.images.isEmpty)
                                            IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/camera.png',
                                                width: SplitUtil.w * 24,
                                                height: SplitUtil.w * 24,
                                                color: WpyTheme.of(context).get(
                                                    WpyColorKey.basicTextColor),
                                              ),
                                              onPressed: () => imageSelectionKey
                                                  .currentState
                                                  ?.shotPic(),
                                            ),
                                          IconButton(
                                            icon: Image.asset(
                                              'assets/images/lake_butt_icons/paste.png',
                                              width: SplitUtil.w * 24,
                                              height: SplitUtil.w * 24,
                                              color: WpyTheme.of(context).get(
                                                  WpyColorKey.basicTextColor),
                                            ),
                                            onPressed: () => launchKey
                                                .currentState
                                                ?.getClipboardData(),
                                          ),
                                          // 录音按钮
                                          // 使用 ListenableBuilder 监听 controller 状态变化来刷新按钮样式
                                          ListenableBuilder(
                                            listenable: _recordController,
                                            builder: (context, child) {
                                              bool isProcessing =
                                                  _recordController.state ==
                                                      RecordState.processing;
                                              bool isRecording =
                                                  _recordController.isRecording;
                                              return WButton(
                                                onPressed: isProcessing
                                                    ? null
                                                    : _toggleRecording,
                                                child: isProcessing
                                                    ? SizedBox(
                                                        width: 24.r,
                                                        height: 24.r,
                                                        child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: WpyTheme.of(
                                                                    context)
                                                                .get(WpyColorKey
                                                                    .primaryActionColor)),
                                                      )
                                                    : Icon(
                                                        isRecording
                                                            ? Icons.mic_rounded
                                                            : Icons
                                                                .mic_none, // todo 这里可以换成的 SVG 图片
                                                        size: 24.r,
                                                        // 录音时变色
                                                        color: isRecording
                                                            ? Colors.red
                                                            : WpyTheme.of(
                                                                    context)
                                                                .get(WpyColorKey
                                                                    .labelTextColor),
                                                        shadows: isRecording
                                                            ? [
                                                                Shadow(
                                                                  color: Colors
                                                                      .red
                                                                      .withValues(
                                                                          alpha:
                                                                              0.5),
                                                                  blurRadius: 3,
                                                                  offset:
                                                                      Offset(
                                                                          2, 2),
                                                                )
                                                              ]
                                                            : null,
                                                      ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Image.asset(
                                              'assets/images/lake_butt_icons/x.png',
                                              width: SplitUtil.w * 24,
                                              height: SplitUtil.w * 24,
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
                                                    ?.setState(
                                                  () {
                                                    launchKey.currentState
                                                            ?.commentLengthIndicator =
                                                        '清空成功';
                                                  },
                                                );
                                              } else {
                                                value.clearAndClose();
                                              }
                                            },
                                          ),
                                          Spacer(),
                                          checkButton,
                                          SizedBox(width: SplitUtil.w * 16),
                                        ],
                                      ),
                                      SizedBox(height: SplitUtil.h * 10),
                                    ],
                                  ),
                                ),
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
                                            ? Text(
                                                '校务帖子为实名发言!!!',
                                                style: TextUtil
                                                    .base.NotoSansSC.w500
                                                    .dangerousRed(context)
                                                    .sp(12),
                                              )
                                            : Text(
                                                '友善回复，真诚沟通',
                                                style: TextUtil
                                                    .base.NotoSansSC.w500
                                                    .secondaryInfo(context)
                                                    .sp(12),
                                              ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18.r),
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey
                                                .secondaryBackgroundColor),
                                      ),
                                    ),
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
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<bool?> _showManageDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    final inputProvider = context.read<NewFloorProvider>();
    if (inputProvider.inputFieldEnabled) {
      inputProvider.inputFieldClose();
    }
    final fixedMediaQuery =
        MediaQuery.of(context).removeViewInsets(removeBottom: true);
    setState(() => _managerDialogVisible = true);
    return showDialog<bool>(
        context: context,
        useSafeArea: false,
        builder: (context) {
          return MediaQuery(
            data: fixedMediaQuery,
            child: RepaintBoundary(
              child: Stack(
                children: [
                  ManagerPopUp(post: widget.post),
                ],
              ),
            ),
          );
        }).whenComplete(() {
      if (mounted) setState(() => _managerDialogVisible = false);
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
  final VoidCallback? onCommentSent;

  const CommentInputField({
    Key? key,
    required this.postId,
    this.onCommentSent,
  }) : super(key: key);

  @override
  CommentInputFieldState createState() => CommentInputFieldState();
}

class CommentInputFieldState extends State<CommentInputField> {
  var textEditingController = MaskTextEditingController();
  FocusNode _commentFocus = FocusNode();
  String commentLengthIndicator = '0/200';

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// 把选中的文字用 <mask></mask> 包起来，评论渲染时显示为马赛克
  void _wrapWithMask() {
    final sel = textEditingController.selection;
    if (!sel.isValid || sel.isCollapsed) return;
    final text = textEditingController.text;
    final wrapped = '$kMaskOpenTag${sel.textInside(text)}$kMaskCloseTag';
    final newText = text.replaceRange(sel.start, sel.end, wrapped);
    textEditingController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + wrapped.length),
    );
    setState(() => commentLengthIndicator = '${newText.characters.length}/200');
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
        contextMenuBuilder: (context, editableState) {
          final items = List<ContextMenuButtonItem>.of(
              editableState.contextMenuButtonItems);
          final sel = textEditingController.selection;
          if (sel.isValid && !sel.isCollapsed) {
            items.insert(
              0,
              ContextMenuButtonItem(
                label: '马赛克',
                onPressed: () {
                  ContextMenuController.removeAny();
                  _wrapWithMask();
                },
              ),
            );
          }
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableState.contextMenuAnchors,
            buttonItems: items,
          );
        },
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
    FeedbackService.sendFloor(
      id: widget.postId.toString(),
      content: textEditingController.text,
      images: list.isEmpty ? [''] : list,
      onSuccess: () {
        setState(() => commentLengthIndicator = '0/200');
        FocusManager.instance.primaryFocus?.unfocus();
        context.read<NewFloorProvider>().clearAndClose();
        textEditingController.text = '';
        widget.onCommentSent?.call();
      },
      onFailure: (e) => ToastProvider.error(
        '好像出错了(っ °Д °;)っ...错误信息：' + e.error.toString(),
      ),
    );
  }

  _replyFloor(List<String> list, bool isOfficial) {
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
          widget.onCommentSent?.call();
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
          widget.onCommentSent?.call();
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
      final targetPath = '${file.path}_compressed.jpg';
      final r = await FlutterImageCompress.compressAndGetFile(
          file.path, targetPath,
          quality: 80);
      if (r != null) file = File(r.path);
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
        final targetPath = '${file.path}_compressed.jpg';
        final r = await FlutterImageCompress.compressAndGetFile(
            file.path, targetPath,
            quality: 80);
        if (r != null) file = File(r.path);
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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        try {
          LakeUtil.currentController.refreshController?.requestRefresh();
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 22,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '帖子管理',
                        style:
                            TextUtil.base.label(context).NotoSansSC.w600.sp(19),
                      ),
                      const Spacer(),
                      WButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryInfoTextColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 帖子信息卡片
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.base
                              .label(context)
                              .NotoSansSC
                              .w600
                              .sp(15),
                        ),
                        const SizedBox(height: 10),
                        _infoRow('楼主昵称', widget.post.nickname),
                        _infoRow('楼主 ID', '${widget.post.uid}'),
                        _infoRow('帖子 ID', '${widget.post.id}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOption(
                    origin: originTag == 0,
                    id: widget.post.id,
                    color1: WpyTheme.of(context)
                        .get(WpyColorKey.pinedPostTagBColor),
                    color2: WpyTheme.of(context)
                        .get(WpyColorKey.pinedPostTagCColor),
                    icon: Icons.push_pin_rounded,
                    title: '置顶帖子',
                    subtitle: '将帖子固定在版块顶部',
                    activeLabel: '已置顶',
                    action: 0,
                  ),
                  AnimatedOption(
                    origin: originTag == 1,
                    id: widget.post.id,
                    color1: WpyTheme.of(context)
                        .get(WpyColorKey.elegantPostTagBColor),
                    color2: WpyTheme.of(context)
                        .get(WpyColorKey.elegantPostTagCColor),
                    icon: Icons.auto_awesome_rounded,
                    title: '精华帖子',
                    subtitle: '标记为优质精华内容',
                    activeLabel: '已加精',
                    action: 1,
                  ),
                  AnimatedOption(
                    origin: originTag == 2,
                    id: widget.post.id,
                    color1: WpyTheme.of(context)
                        .get(WpyColorKey.activityPostBColor),
                    color2: WpyTheme.of(context)
                        .get(WpyColorKey.activityPostTagCColor),
                    icon: Icons.celebration_rounded,
                    title: '活动帖子',
                    subtitle: '标记为活动相关帖子',
                    activeLabel: '活动中',
                    action: 2,
                  ),
                  AnimatedOption(
                    origin: false,
                    id: widget.post.id,
                    color1:
                        WpyTheme.of(context).get(WpyColorKey.deletePostAColor),
                    color2:
                        WpyTheme.of(context).get(WpyColorKey.deletePostBColor),
                    icon: Icons.delete_outline_rounded,
                    title: '删除帖子',
                    subtitle: '永久删除该帖，需填写原因',
                    activeLabel: '',
                    action: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              key,
              style: TextUtil.base.secondary(context).NotoSansSC.w400.sp(12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextUtil.base.label(context).NotoSansSC.w400.sp(12),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedOption extends StatefulWidget {
  final bool origin;
  final Color color1;
  final Color color2;
  final IconData icon;
  final String title;
  final String subtitle;
  final String activeLabel;
  final int id;
  final int? action;

  const AnimatedOption({
    Key? key,
    required this.origin,
    this.action,
    required this.color1,
    required this.color2,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.activeLabel,
    required this.id,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedOptionState(origin);
}

class _AnimatedOptionState extends State<AnimatedOption>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  bool origin;
  final TextEditingController tc = TextEditingController();
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  _AnimatedOptionState(this.origin);

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    tc.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => isSelected = !isSelected);
    if (isSelected) {
      _expandController.forward();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDelete = widget.action == 100;
    final accent =
        isDelete ? widget.color1 : (origin ? widget.color2 : widget.color1);
    final reverseColor = WpyTheme.of(context).get(WpyColorKey.reverseTextColor);
    final secondaryColor =
        WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor);

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, 13, 14, isSelected ? 14 : 13),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            border: Border.all(
              color: accent.withValues(alpha: origin ? 0.42 : 0.22),
              width: origin ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [widget.color1, widget.color2],
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: reverseColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextUtil.base
                                    .label(context)
                                    .NotoSansSC
                                    .w600
                                    .sp(15),
                              ),
                            ),
                            if (origin && widget.activeLabel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: accent.withValues(alpha: 0.14),
                                ),
                                child: Text(
                                  widget.activeLabel,
                                  style: TextUtil.base.normal.NotoSansSC.w500
                                      .sp(10)
                                      .customColor(accent),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.base
                              .secondary(context)
                              .NotoSansSC
                              .w400
                              .sp(12),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: isSelected ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                alignment: Alignment.topLeft,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: IgnorePointer(
                    ignoring: !isSelected,
                    child: Column(
                      children: [
                        if (widget.action == 0 && !widget.origin) ...[
                          const SizedBox(height: 12),
                          Divider(
                            height: 1,
                            color: secondaryColor.withValues(alpha: 0.18),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: tc,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: '置顶数值',
                              helperText: '0 为取消置顶，支持 0~30000',
                              hintStyle: TextUtil.base
                                  .secondary(context)
                                  .NotoSansSC
                                  .w400
                                  .sp(13),
                              helperStyle: TextUtil.base
                                  .secondary(context)
                                  .NotoSansSC
                                  .w400
                                  .sp(11),
                              filled: true,
                              fillColor: accent.withValues(alpha: 0.08),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: accent.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: accent.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: accent),
                              ),
                            ),
                            style: TextUtil.base.label(context).medium.sp(15),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: WButton(
                            onPressed: _inkWellOnTap,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [widget.color1, widget.color2],
                                ),
                              ),
                              child: Text(
                                origin
                                    ? '取消当前状态'
                                    : (isDelete ? '确认删除' : '确认设置'),
                                textAlign: TextAlign.center,
                                style: TextUtil.base
                                    .customColor(reverseColor)
                                    .NotoSansSC
                                    .w600
                                    .sp(14),
                              ),
                            ),
                          ),
                        ),
                      ],
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
              LakeUtil.currentController.refreshController?.requestRefresh();
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
                    LakeUtil.currentController.refreshController
                        ?.requestRefresh();
                  });
                  Navigator.of(context).pop();
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
                backgroundColor: WidgetStateProperty.all(
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
