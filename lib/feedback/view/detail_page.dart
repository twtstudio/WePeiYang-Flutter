import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'components/official_comment_card.dart';
import 'components/post_card.dart';
import 'lake_home_page/lake_notifier.dart';

enum DetailPageStatus {
  loading,
  idle,
  error,
}

enum PostOrigin { home, profile, favorite, mailbox }

class DetailPage extends StatefulWidget {
  final Post post;

  DetailPage(this.post);

  @override
  _DetailPageState createState() => _DetailPageState(this.post);
}

class _DetailPageState extends State<DetailPage>
    with TickerProviderStateMixin {
  Post post;
  DetailPageStatus status;
  List<Floor> _commentList;
  List<Floor> _officialCommentList;
  bool _bottomIsOpen;
  int currentPage = 1;
  int rating = 0;
  Widget topCard;
  final onlyOwner = ValueNotifier<int>(0);
  final order =
      ValueNotifier<int>(CommonPreferences.feedbackFloorSortType.value);

  double _previousOffset = 0;
  final launchKey = GlobalKey<CommentInputFieldState>();
  final imageSelectionKey = GlobalKey<ImageSelectAndViewState>();

  var _refreshController = RefreshController(initialRefresh: false);
  var _controller = ScrollController();

  _DetailPageState(this.post);

  _onRefresh() {
    currentPage = 1;
    _refreshController.resetNoData();
    _commentList.clear();
    _initPostAndComments(
      onSuccess: (comments) {
        _commentList = comments;
        _refreshController.refreshCompleted();
      },
      onFail: () {
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

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (_bottomIsOpen ?? false) if (context
                .read<NewFloorProvider>()
                .inputFieldEnabled ==
            true &&
        (scrollInfo.metrics.pixels - _previousOffset).abs() >= 20) {
      _bottomIsOpen = false;
      Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
  }

  @override
  void initState() {
    super.initState();
    status = DetailPageStatus.loading;
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = 0;
    _officialCommentList = [];
    _commentList = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// 如果是从通知栏点进来的
      if (post == null || post.isLike == null || post.isOwner == null) {
        _initPostAndComments(onSuccess: (comments) {
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
  }

  // 逻辑有点问题
  _initPostAndComments({Function(List<Floor>) onSuccess, Function onFail}) {
    _initPost(onFail).then((success) {
      if (success) {
        if (widget.post.type == 1)
        _getOfficialComment(onFail: onFail);
        _getComments(
          onSuccess: onSuccess,
          onFail: onFail,
          current: 1,
        );
      }
    });
  }

  Future<bool> _initPost([Function onFail]) async {
    bool success = false;
    await FeedbackService.getPostById(
      id: post.id,
      onResult: (Post result) {
        success = true;
        post = result;
        rating = post.rating;
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        success = false;
        onFail?.call();
        return;
      },
    );
    return success;
  }

  _getComments(
      {Function(List<Floor>) onSuccess, Function onFail, int current}) {
    FeedbackService.getComments(
      id: post.id,
      page: current ?? currentPage,
      order: order.value,
      onlyOwner: onlyOwner.value,
      onSuccess: (comments, totalFloor) {
        onSuccess?.call(comments);
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        onFail?.call();
      },
    );
  }

  _getOfficialComment({Function onSuccess, Function onFail}) {
    FeedbackService.getOfficialComment(
      id: post.id,
      onSuccess: (floor) {
        _officialCommentList = floor;
        onSuccess?.call();
        setState(() {});
      },
      onFailure: (e) {
        onFail?.call();
        ToastProvider.error(e.error.toString());
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Widget bottomInput;

    Widget checkButton = InkWell(
      onTap: () {
        launchKey.currentState.send(false);
        setState(() {});
      },
      child: SvgPicture.asset('assets/svg_pics/lake_butt_icons/send.svg',
          width: 20),
    );

    if (status == DetailPageStatus.loading) {
      if (post == null) {
        body = Center(child: Loading());
      } else {
        body = ListView(
          children: [
            PostCard.detail(post),
            SizedBox(
              height: 120,
              child: Center(child: Loading()),
            )
          ],
        );
      }
    } else if (status == DetailPageStatus.idle) {
      Widget contentList = ListView.builder(
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            return Column(
              children: [
                PostCard.detail(post),
                Divider(
                  height: 2,
                  indent: 15,
                  endIndent: 15,
                  color: ColorUtil.grey229,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        order.value = 1;
                      },
                      child: Text('时间正序',
                          style: order.value == 1
                              ? TextUtil.base.black2A.w700.sp(14).blue2C
                              : TextUtil.base.black2A.w500.sp(14)),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        order.value = 0;
                      },
                      child: Text('时间倒序',
                          style: order.value == 0
                              ? TextUtil.base.black2A.w700.sp(14).blue2C
                              : TextUtil.base.black2A.w500.sp(14)),
                    ),
                    Spacer(),
                    ValueListenableBuilder(
                      valueListenable: onlyOwner,
                      builder: (context, value, _) {
                        return GestureDetector(
                          onTap: () {
                            onlyOwner.value = 1 - onlyOwner.value;
                            _refreshController.requestRefresh();
                          },
                          child: value == 1
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: ColorUtil.boldTag54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('  只看楼主  ',
                                      style: TextUtil.base.white.w400.sp(14)),
                                )
                              : Container(
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
            return i == 0
                ? OfficialReplyCard.reply(
                    tag: post.department.name ?? '',
                    comment: data,
                    placeAppeared: i,
                    ratings: post.rating,
                    ancestorId: post.uid,
                    detail: false,
                    onContentPressed: (refresh) async {
                      refresh.call(list);
                    },
                  )
                : i == 1
                    // 楼中楼显示
                    ? OfficialReplyCard.subFloor(
                        tag: "",
                        comment: data,
                        placeAppeared: i,
                        ratings: post.rating,
                        ancestorId: post.uid,
                        detail: true,
                        onContentPressed: (refresh) async {
                          refresh.call(list);
                        },
                      )
                    : SizedBox();
          } else {
            var data = _commentList[i - _officialCommentList.length];
            return NCommentCard(
              uid: post.uid,
              comment: data,
              ancestorUId: post.id,
              commentFloor: i + 1,
              isSubFloor: false,
              isFullView: false,
              type: post.type,
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
          child: contentList,
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );

      var inputField = CommentInputField(postId: post.id, key: launchKey);

      bottomInput = Column(
        children: [
          Spacer(),
          Consumer<NewFloorProvider>(
              builder: (BuildContext context, value, Widget child) {
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
                        color: Colors.black12,
                        offset: Offset(0, 1),
                        blurRadius: 6,
                        spreadRadius: 0),
                  ],
                  color: ColorUtil.whiteF8Color,
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
                                          if (context
                                                  .read<NewFloorProvider>()
                                                  .images
                                                  .length ==
                                              0)
                                            IconButton(
                                                icon: Image.asset(
                                                  'assets/images/lake_butt_icons/image.png',
                                                  width: 24,
                                                  height: 24,
                                                ),
                                                onPressed: () =>
                                                    imageSelectionKey
                                                        .currentState
                                                        .loadAssets()),
                                          if (context
                                                  .read<NewFloorProvider>()
                                                  .images
                                                  .length ==
                                              0)
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
                                                        .shotPic()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/paste.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              onPressed: () => launchKey
                                                  .currentState
                                                  .getClipboardData()),
                                          IconButton(
                                              icon: Image.asset(
                                                'assets/images/lake_butt_icons/x.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              onPressed: () {
                                                if (launchKey
                                                    .currentState
                                                    .textEditingController
                                                    .text
                                                    .isNotEmpty) {
                                                  launchKey.currentState
                                                      .textEditingController
                                                      .clear();
                                                  launchKey.currentState
                                                      .setState(() {
                                                    launchKey.currentState
                                                            .commentLengthIndicator =
                                                        '清空成功';
                                                  });
                                                } else {
                                                  Provider.of<NewFloorProvider>(
                                                          context,
                                                          listen: false)
                                                      .clearAndClose();
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
                                child: InkWell(
                                  onTap: () {
                                    _bottomIsOpen = true;
                                    Provider.of<NewFloorProvider>(context,
                                            listen: false)
                                        .inputFieldOpenAndReplyTo(0);
                                    FocusScope.of(context).requestFocus(
                                        Provider.of<NewFloorProvider>(context,
                                                listen: false)
                                            .focusNode);
                                  },
                                  child: Container(
                                      height: 22,
                                      margin:
                                          EdgeInsets.fromLTRB(16, 20, 0, 20),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: post.type == 1
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
                                        borderRadius: BorderRadius.circular(11),
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!context.read<NewFloorProvider>().inputFieldEnabled)
                          PostCard.outSide(post),
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
          color: Colors.black,
        ),
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: <Widget>[
                  // 分享按钮
                  CupertinoActionSheetAction(
                    onPressed: () {
                      if (!_refreshController.isLoading &&
                          !_refreshController.isRefresh) {
                        String weCo =
                            '我在微北洋发现了个有趣的问题【${post.title}】\n#MP${post.id} ，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${post.id}';
                        ClipboardData data = ClipboardData(text: weCo);
                        Clipboard.setData(data);
                        CommonPreferences.feedbackLastWeCo.value =
                            post.id.toString();
                        ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      '分享',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                    ),
                  ),
                  (widget.post.isOwner == false)
                      ? CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pushNamed(context, FeedbackRouter.report,
                                arguments:
                                    ReportPageArgs(widget.post.id, true));
                          },
                          child: Text(
                            '举报',
                            style: TextUtil.base.normal.w400.NotoSansSC.black00
                                .sp(16),
                          ))
                      : CupertinoActionSheetAction(
                          onPressed: () async {
                            bool confirm = await _showDeleteConfirmDialog('删除');
                            if (confirm) {
                              FeedbackService.deletePost(
                                id: widget.post.id,
                                onSuccess: () {
                                  context
                                      .read<LakeModel>()
                                      .lakeAreas[context
                                          .read<LakeModel>()
                                          .tabList[context
                                              .read<LakeModel>()
                                              .currentTab]
                                          .id]
                                      .refreshController
                                      .requestRefresh();
                                  ToastProvider.success(
                                      S.current.feedback_delete_success);
                                  Navigator.of(context).pop(post);
                                },
                                onFailure: (e) {
                                  ToastProvider.error(e.error.toString());
                                },
                              );
                            }
                          },
                          child: Text(
                            '删除',
                            style: TextUtil.base.normal.w400.NotoSansSC.black00
                                .sp(16),
                          )),
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '收藏',
                      style:
                          TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
                    ),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  // 取消按钮
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextUtil.base.normal.w400.NotoSansSC.black00.sp(16),
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

    var appBar = AppBar(
      toolbarHeight: 40,
      titleSpacing: 0,
      backgroundColor: CommonPreferences.isSkinUsed.value
          ? Color(CommonPreferences.skinColorB.value)
          : Colors.white,
      leading: IconButton(
        icon: Image.asset(
          "assets/images/lake_butt_icons/back.png",
          color: ColorUtil.mainColor,
          
        ),
        onPressed: () => Navigator.pop(context, post),
      ),
      actions: [
        if ((CommonPreferences.isSuper.value ||
                CommonPreferences.isSchAdmin.value) ??
            false)
          manageButton,
        menuButton,
        SizedBox(width: 10)
      ],
      title: InkWell(
        onTap: () => _refreshController.requestRefresh(),
        child: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              post.type == 1 ? '校务提问：实名' : '冒泡',
              style: TextUtil.base.NotoSansSC.black2A.w600.sp(18),
            ),
          ),
        ),
      ),
      elevation: 0,
      brightness: Brightness.light,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, post);
        return true;
      },
      child: Scaffold(
        backgroundColor: CommonPreferences.isSkinUsed.value
            ? Color(CommonPreferences.skinColorB.value)
            : Colors.white,
        appBar: appBar,
        body: body,
      ),
    );
  }

  Future<bool> _showManageDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Stack(
            children: [
              ManagerPopUp(post: post),
            ],
          );
        });
  }

  Future<bool> _showDeleteConfirmDialog(String quote) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '$quote冒泡',
              content: Text('您确定要$quote这条冒泡吗？'),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.white.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.greyA8.NotoSansSC.sp(16).w600,
              confirmText: "确认",
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF2C7EDF),
                    Color(0xFFA6CFFF),
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

  const CommentInputField({Key key, this.postId}) : super(key: key);

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
        style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).black00,
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
    if (clipboardData != null) {
      ///将获取的粘贴板的内容进行展示
      textEditingController.text += clipboardData.text;
      setState(() {
        commentLengthIndicator = '${clipboardData.text.length}/200';
      });
    }
  }

  _sendFloor(List<String> list) {
    ToastProvider.running('创建楼层中 q(≧▽≦q)');
    FeedbackService.sendFloor(
      id: widget.postId.toString(),
      content: textEditingController.text,
      images: list == [] ? '' : list,
      onSuccess: () {
        setState(() => commentLengthIndicator = '0/200');
        FocusManager.instance.primaryFocus.unfocus();
        Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
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
        images: list == [] ? '' : list,
        onSuccess: () {
          setState(() => commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus.unfocus();
          Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
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
        images: list == [] ? '' : list,
        onSuccess: () {
          setState(() => commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus.unfocus();
          Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
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
  const ImageSelectAndView({Key key}) : super(key: key);

  @override
  ImageSelectAndViewState createState() => ImageSelectAndViewState();
}

class ImageSelectAndViewState extends State<ImageSelectAndView> {
  shotPic() async {
    final asset = await ImagePicker().pickImage(source: ImageSource.camera);
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
    final List<AssetEntity> assets = await AssetPicker.pickAssets(
      context,
      maxAssets: 1,
      requestType: RequestType.image,
      themeColor: ColorUtil.selectionButtonColor,
    );
    for (int i = 0; i < assets.length; i++) {
      File file = await assets[i].file;
      for (int j = 0; file.lengthSync() > 2000 * 1024 && j < 10; j++) {
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

  Future<String> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.feedback_delete_image_content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          TextButton(
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
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(
                            context, FeedbackRouter.localImageView, arguments: {
                          "uriList": data.images,
                          "uriListLength": 1,
                          "indexNow": 0
                        }),
                        child: Container(
                          height: 80,
                          width: 82,
                          margin: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(width: 1, color: Colors.black26),
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
                      child: InkWell(
                        onTap: () async {
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
                            color: Colors.black26,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: ColorUtil.searchBarBackgroundColor,
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
  @required
  final Post post;

  @required
  const ManagerPopUp({Key key, this.post}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ManagerPopUpState();
  }
}

class _ManagerPopUpState extends State<ManagerPopUp>
    with SingleTickerProviderStateMixin {
  _ManagerPopUpState();

  int originTag;

  @override
  void initState() {
    originTag = widget.post.eTag == 'recommend'
        ? 1
        : widget.post.eTag == 'theme'
            ? 2
            : widget.post.eTag == 'top'
                ? 0
                : 3;
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
            .refreshController
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
              if (CommonPreferences.isSuper.value)
                AnimatedOption(
                    origin: false,
                    id: widget.post.uid,
                    color1: Color.fromRGBO(95, 127, 0, 1.0),
                    color2: Color.fromRGBO(8, 96, 0, 1.0),
                    title: '开盒楼主',
                    action: 200),
              if (originTag != 3)
                AnimatedOption(
                    origin: false,
                    id: widget.post.id,
                    color1: Color.fromRGBO(159, 159, 159, 1.0),
                    color2: Color.fromRGBO(107, 107, 107, 1.0),
                    title: '恢复正常帖子',
                    action: 0),
              AnimatedOption(
                  origin: originTag == 0,
                  id: widget.post.id,
                  color1: Color.fromRGBO(223, 108, 171, 1.0),
                  color2: Color.fromRGBO(243, 16, 73, 1.0),
                  title: originTag == 0 ? '× 已置顶' : '将此帖置顶'),
              AnimatedOption(
                  origin: originTag == 1,
                  id: widget.post.id,
                  color1: Color.fromRGBO(232, 178, 27, 1.0),
                  color2: Color.fromRGBO(236, 120, 57, 1.0),
                  title: originTag == 1 ? '× 已加精' : '加入精华帖',
                  action: 1),
              AnimatedOption(
                  origin: originTag == 2,
                  id: widget.post.id,
                  color1: Color.fromRGBO(66, 161, 225, 1.0),
                  color2: Color.fromRGBO(57, 90, 236, 1.0),
                  title: originTag == 2 ? '× 正在活动状态' : '变为活动帖',
                  action: 2),
              AnimatedOption(
                  origin: false,
                  id: widget.post.id,
                  color1: Color.fromRGBO(127, 0, 0, 1.0),
                  color2: Color.fromRGBO(66, 0, 96, 1.0),
                  title: '⚠ 删帖',
                  action: 100),
            ]),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), color: Colors.white),
      ),
    );
  }
}

class AnimatedOption extends StatefulWidget {
  @required
  final bool origin;
  final Color color1;
  final Color color2;
  final String title;
  final int id;
  final int action;

  @required
  const AnimatedOption(
      {Key key,
      this.origin,
      this.action,
      this.color1,
      this.color2,
      this.title,
      this.id})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedOptionState(origin);
  }
}

class _AnimatedOptionState extends State<AnimatedOption>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  bool origin;
  TextEditingController tc;

  _AnimatedOptionState(this.origin);

  @override
  void initState() {
    tc = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (!origin)
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
              borderRadius: BorderRadius.circular(18),
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
                  style: TextUtil.base.white.medium.sp(20),
                ),
                if (isSelected && widget.title == '将此帖置顶')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '0为取消置顶，只能为0~30000',
                      style: TextUtil.base.white.medium.sp(10),
                    ),
                  ),
                if (isSelected && widget.title == '将此帖置顶')
                  TextField(
                    controller: tc,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelStyle: TextStyle().white.NotoSansSC.w400.sp(16),
                      hintStyle: TextStyle().white.NotoSansSC.w800.sp(16),
                      hintText: '置顶数值',
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextUtil.base.white.medium.sp(16),
                  ),
                if (isSelected && widget.title == '将此帖置顶')
                  Container(
                      height: 1.5, width: double.infinity, color: Colors.white),
                if (isSelected)
                  InkWell(
                      onTap: widget.action == null
                          ? () async {
                              if (tc != null && tc.text != '') {
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
                                Navigator.of(context).pop(true);
                              } else
                                ToastProvider.error('请输入数值！');
                            }
                          : widget.action == 100
                              ? () async {
                                  FeedbackService.adminDeletePost(
                                    id: widget.id.toString(),
                                    onSuccess: () {
                                      context
                                          .read<LakeModel>()
                                          .lakeAreas[context
                                              .read<LakeModel>()
                                              .tabList[context
                                                  .read<LakeModel>()
                                                  .currentTab]
                                              .id]
                                          .refreshController
                                          .requestRefresh();
                                      ToastProvider.success(
                                          S.current.feedback_delete_success);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    onFailure: (e) {
                                      Navigator.of(context).pop();
                                      ToastProvider.error(e.error.toString());
                                    },
                                  );
                                }
                              : widget.action == 200
                                  ? () => Navigator.popAndPushNamed(
                                      context, FeedbackRouter.openBox,
                                      arguments: widget.id)
                                  : () async {
                                      FeedbackService.adminChangeETag(
                                          id: widget.id.toString(),
                                          value: widget.action.toString(),
                                          onSuccess: () => setState(() {
                                                isSelected = false;
                                                context
                                                    .read<LakeModel>()
                                                    .lakeAreas[context
                                                        .read<LakeModel>()
                                                        .tabList[context
                                                            .read<LakeModel>()
                                                            .currentTab]
                                                        .id]
                                                    .refreshController
                                                    .requestRefresh();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                ToastProvider.running('成功');
                                              }),
                                          onFailure: (e) =>
                                              ToastProvider.error(e.message));
                                    },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Spacer(),
                            Text(
                              '确认',
                              style: TextUtil.base.white.medium.sp(18),
                            ),
                          ],
                        ),
                      ))
              ],
            ),
          ),
        ));
  }
}
