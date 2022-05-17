import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'components/official_comment_card.dart';
import 'components/post_card.dart';
import 'components/widget/pop_menu_shape.dart';
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
    with SingleTickerProviderStateMixin {
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
      ValueNotifier<int>(CommonPreferences().feedbackFloorSortType.value);

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
      CommonPreferences().feedbackFloorSortType.value = order.value;
    });
  }

  // 逻辑有点问题
  _initPostAndComments({Function(List<Floor>) onSuccess, Function onFail}) {
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
                SizedBox(
                  height: 10,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          '回复 ' + post.commentCount.toString(),
                          style:
                              TextUtil.base.ProductSans.black2A.medium.sp(18),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                      ),
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
                                      border: Border.all(
                                        color: ColorUtil.boldTag54, //边框颜色
                                        width: 1, //宽度
                                      ),
                                    ),
                                    child: Text('  只看楼主  ',
                                        style: TextUtil.base.white.w500.sp(14)),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: ColorUtil.whiteF8Color,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: ColorUtil.boldTag54, //边框颜色
                                        width: 1, //宽度
                                      ),
                                    ),
                                    child: Text('  只看楼主  ',
                                        style:
                                            TextUtil.base.black2A.w500.sp(14)),
                                  ),
                          );
                        },
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        child: PopupMenuButton(
                            shape: RacTangle(),
                            offset: Offset(0, 0),
                            child: Image.asset(
                              'assets/images/lake_butt_icons/menu.png',
                              width: 20,
                            ),
                            onSelected: (value) async {
                              if (value == "时间正序") {
                                order.value = 1;
                              } else if (value == '时间倒序') {
                                order.value = 0;
                              }
                            },
                            itemBuilder: (context) {
                              return <PopupMenuItem<String>>[
                                PopupMenuItem<String>(
                                  value: '时间正序',
                                  child: Center(
                                    child: Text('    时间正序',
                                        style: order.value == 1
                                            ? TextUtil.base.black2A.w700.sp(14)
                                            : TextUtil.base.black2A.w500
                                                .sp(14)),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: '时间倒序',
                                  child: Center(
                                    child: Text('    时间倒序',
                                        style: order.value == 0
                                            ? TextUtil.base.black2A.w700.sp(14)
                                            : TextUtil.base.black2A.w500
                                                .sp(14)),
                                  ),
                                ),
                              ];
                            }),
                      ),
                    ]),
                SizedBox(
                  height: 10,
                ),
                //topCard,
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

                    ///楼中楼显示
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
                    : SizedBox(width: 0, height: 0);
          } else {
            var data = _commentList[i - _officialCommentList.length];
            return NCommentCard(
              uid: post.uid,
              comment: data,
              ancestorUId: post.id,
              commentFloor: i + 1,
              isSubFloor: false,
              isFullView: false,
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
              vsync: this,
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
                    color: ColorUtil.whiteF8Color),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                        child: Text('友善回复，真诚沟通',
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
            children: [Expanded(child: mainList), SizedBox(height: 60)],
          ),
          bottomInput
        ],
      );
    } else {
      body = Center(child: Text("error!"));
    }

    var menuButton = PopupMenuButton(

        ///改成了用PopupMenuButton的方式，方便偏移的处理
        shape: RacTangle(),
        offset: Offset(0, 20.w),
        child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_vertical.svg'),
        onSelected: (value) async {
          if (value == "举报") {
            Navigator.pushNamed(context, FeedbackRouter.report,
                arguments: ReportPageArgs(widget.post.id, true));
          } else if (value == '删除') {
            bool confirm = await _showDeleteConfirmDialog('删除');
            if (confirm) {
              FeedbackService.deletePost(
                id: widget.post.id,
                onSuccess: () {
                  context
                      .read<LakeModel>()
                      .lakeAreas[context
                          .read<LakeModel>()
                          .tabList[context.read<LakeModel>().currentTab]
                          .id]
                      .refreshController
                      .requestRefresh();
                  ToastProvider.success(S.current.feedback_delete_success);
                  Navigator.of(context).pop(post);
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
            }
          } else if (value == '删帖') {
            bool confirm = await _showDeleteConfirmDialog('摧毁');
            if (confirm) {
              FeedbackService.adminDeletePost(
                id: widget.post.id,
                onSuccess: () {
                  context
                      .read<LakeModel>()
                      .lakeAreas[context
                          .read<LakeModel>()
                          .tabList[context.read<LakeModel>().currentTab]
                          .id]
                      .refreshController
                      .requestRefresh();
                  ToastProvider.success(S.current.feedback_delete_success);
                  Navigator.of(context).pop(post);
                },
                onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                },
              );
            }
          } else if (value == '加精') {
            bool confirm = await _showDeleteConfirmDialog('加精');
            if (confirm) {
              bool doubleConfirm = await _showAddNumDialog();
              if (doubleConfirm) Navigator.of(context).pop(post);
            }
          }
        },
        itemBuilder: (context) {
          return <PopupMenuItem<String>>[
            if (!(widget.post.isOwner ?? false))
              PopupMenuItem<String>(
                value: '举报',
                child: Center(
                  child:
                      new Text('举报', style: TextUtil.base.black2A.w500.sp(14)),
                ),
              ),
            if (widget.post.isOwner ?? false)
              PopupMenuItem<String>(
                value: '删除',
                child: Center(
                  child:
                      new Text('删除', style: TextUtil.base.black2A.w500.sp(14)),
                ),
              ),
            if ((CommonPreferences().isSuper.value ||
                    CommonPreferences().isStuAdmin.value) ??
                false)
              PopupMenuItem<String>(
                value: '删帖',
                child: Center(
                  child: new Text('删帖',
                      style: TextUtil.base.dangerousRed.w600.sp(14)),
                ),
              ),
            if ((CommonPreferences().isSuper.value ||
                    CommonPreferences().isStuAdmin.value) ??
                false)
              PopupMenuItem<String>(
                value: '加精',
                child: Center(
                  child: new Text('加精',
                      style: TextUtil.base.mainOrange.w600.sp(14)),
                ),
              ),
          ];
        });
    var shareButton = IconButton(
        icon: Icon(Icons.share, size: 23, color: ColorUtil.boldTextColor),
        onPressed: () {
          if (!_refreshController.isLoading && !_refreshController.isRefresh) {
            String weCo =
                '我在微北洋发现了个有趣的问题【${post.title}】\n#MP${post.id} ，你也来看看吧~\n将本条微口令复制到微北洋求实论坛打开问题 wpy://school_project/${post.id}';
            ClipboardData data = ClipboardData(text: weCo);
            Clipboard.setData(data);
            CommonPreferences().feedbackLastWeCo.value = post.id.toString();
            ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
          }
        });

    var appBar = AppBar(
      titleSpacing: 0,
      backgroundColor: CommonPreferences().isSkinUsed.value
          ? Color(CommonPreferences().skinColorB.value)
          : ColorUtil.greyF7F8Color,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context, post),
      ),
      actions: [shareButton, menuButton],
      title: InkWell(
        onTap: () => _refreshController.requestRefresh(),
        child: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '冒泡',
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
        backgroundColor: CommonPreferences().isSkinUsed.value
            ? Color(CommonPreferences().skinColorB.value)
            : ColorUtil.backgroundColor,
        appBar: appBar,
        body: body,
      ),
    );
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
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w600,
              confirmText: "确认",
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () {
                Navigator.of(context).pop(true);
              });
        });
  }

  Future<bool> _showAddNumDialog() {
    TextEditingController tc = new TextEditingController();
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '加精数值',
              content: Column(
                children: [
                  Text('0为取消加精，只能为0~30000'),
                  TextField(controller: tc, keyboardType: TextInputType.number),
                ],
              ),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(16).w600,
              confirmText: "确认",
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () async {
                if (tc != null && tc.text != '') {
                  await FeedbackService.adminTopPost(
                    id: widget.post.id,
                    hotIndex: tc.text,
                    onSuccess: () {
                      ToastProvider.success('加精成功');
                      context
                          .read<LakeModel>()
                          .lakeAreas[context
                              .read<LakeModel>()
                              .tabList[context.read<LakeModel>().currentTab]
                              .id]
                          .refreshController
                          .requestRefresh();
                      Navigator.of(context).pop(post);
                    },
                    onFailure: (e) {
                      ToastProvider.error(e.error.toString());
                    },
                  );
                  Navigator.of(context).pop(true);
                } else
                  ToastProvider.error('请输入数值！');
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
  var _textEditingController = TextEditingController();
  FocusNode _commentFocus = FocusNode();
  String _commentLengthIndicator = '0/200';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void send(bool isOfficial) {
    if (_textEditingController.text.isNotEmpty ||
        (_textEditingController.text.isEmpty &&
            context.read<NewFloorProvider>().images.isNotEmpty)) {
      if (context.read<NewFloorProvider>().images.isNotEmpty) {
        FeedbackService.postPic(
            images: context.read<NewFloorProvider>().images,
            onResult: (images) {
              context.read<NewFloorProvider>().floorSentContent =
                  _textEditingController.text;
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
        controller: _textEditingController,
        maxLength: 200,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          counterText: '',
          hintText:
              data.replyTo == 0 ? '回复冒泡：' : '回复楼层：' + data.replyTo.toString(),
          suffix: Text(
            _commentLengthIndicator,
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
          _commentLengthIndicator = '${text.characters.length}/200';
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

  _sendFloor(List<String> list) {
    ToastProvider.running('创建楼层中 q(≧▽≦q)');
    FeedbackService.sendFloor(
      id: widget.postId.toString(),
      content: _textEditingController.text,
      images: list == [] ? '' : list,
      onSuccess: () {
        setState(() => _commentLengthIndicator = '0/200');
        FocusManager.instance.primaryFocus.unfocus();
        Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
        _textEditingController.text = '';
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
        content: _textEditingController.text,
        images: list == [] ? '' : list,
        onSuccess: () {
          setState(() => _commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus.unfocus();
          Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
          _textEditingController.text = '';
          ToastProvider.success("回复成功 (❁´3`❁)");
        },
        onFailure: (e) => ToastProvider.error(
          '好像出错了（；´д｀）ゞ...错误信息：' + e.error.toString(),
        ),
      );
    } else {
      FeedbackService.replyOfficialFloor(
        id: context.read<NewFloorProvider>().replyTo.toString(),
        content: _textEditingController.text,
        images: list == [] ? '' : list,
        onSuccess: () {
          setState(() => _commentLengthIndicator = '0/200');
          FocusManager.instance.primaryFocus.unfocus();
          Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
          _textEditingController.text = '';
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
