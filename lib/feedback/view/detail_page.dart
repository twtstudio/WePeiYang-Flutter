import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

import 'components/post_card.dart';

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
  int currentPage = 1;

  double _previousOffset = 0;
  final launchKey = GlobalKey<CommentInputFieldState>();
  final imageSelectionKey = GlobalKey<ImageSelectAndViewState>();

  var _refreshController = RefreshController(initialRefresh: false);

  _DetailPageState(this.post);

  _onRefresh() {
    currentPage = 1;
    _refreshController.resetNoData();
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

  _onLoadingSelectedPage(int current) {
    print(current + 10000000000000000);
    _getComments(
        onSuccess: (comments) {
          _commentList.removeRange(
              _commentList.length - comments.length, _commentList.length);
          _commentList.addAll(comments);
        },
        onFail: () {
          _refreshController.loadFailed();
        },
        current: current);
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (context.read<NewFloorProvider>().inputFieldEnabled == true &&
        (scrollInfo.metrics.pixels - _previousOffset).abs() >= 20) {
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
    _commentList = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// 如果是从通知栏点进来的
      if (post == null) {
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
        _getComments(
            onSuccess: (comments) {
              _commentList.addAll(comments);
              setState(() {
                status = DetailPageStatus.idle;
              });
            },
            onFail: () {
              setState(() {
                status = DetailPageStatus.idle;
              });
            },
            current: currentPage);
      }
    });
  }

  // 逻辑有点问题
  _initPostAndComments({Function(List<Floor>) onSuccess, Function onFail}) {
    _initPost(onFail).then((success) {
      if (success) {
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
      onResult: (Post p) {
        post = p;
        Provider.of<MessageProvider>(context, listen: false)
            .setFeedbackQuestionRead(p.id);
        success = true;
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
        launchKey.currentState.send();
        setState(() {
          _onLoadingSelectedPage(
              (context.read<NewFloorProvider>().locate / 10).floor() + 1 ?? 0);
        });
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
            PostCard.detail(
              post,
              onLikePressed: (isLike, likeCount) {
                post.isLike = isLike;
                post.likeCount = likeCount;
              },
              onFavoritePressed: (isFav, favCount) {
                post.isFav = isFav;
                post.favCount = favCount;
              },
            ),
            SizedBox(
              height: 100,
              child: Center(child: Loading()),
            )
          ],
        );
      }
    } else if (status == DetailPageStatus.idle) {
      Widget mainList1 = ListView.builder(
        itemCount: _commentList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                PostCard.detail(
                  post,
                  onLikePressed: (isLike, likeCount) {
                    post.isLike = isLike;
                    post.likeCount = likeCount;
                  },
                  onFavoritePressed: (isFav, favCount) {
                    post.isFav = isFav;
                    post.favCount = favCount;
                  },
                ),
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
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset(
                          'assets/images/lake_butt_icons/menu.png',
                          width: 20,
                        ),
                      ),
                    ]),
                SizedBox(
                  height: 10,
                ),
              ],
            );
          }
          index--;

          ///TODO:由于新接口的官方回复和普通回复合在一起了，暂时不知道怎么处理，于是先把以前的删掉了，官方需要用—
          ///_officialCommentList,点赞注释了
          var data = _commentList[index];
          return NCommentCard(
            placeAppeared: index,
            comment: data,
            ancestorId: post.id,
            commentFloor: index + 1,
            isSubFloor: false,
            isFullView: false,
          );
        },
      );

      Widget mainList = Expanded(
        child: NotificationListener<ScrollNotification>(
          child: SmartRefresher(
            physics: BouncingScrollPhysics(),
            controller: _refreshController,
            header: ClassicHeader(),
            footer: ClassicFooter(),
            enablePullDown: true,
            onRefresh: _onRefresh,
            enablePullUp: true,
            onLoading: _onLoading,
            child: mainList1,
          ),
          onNotification: (ScrollNotification scrollInfo) =>
              _onScrollNotification(scrollInfo),
        ),
      );

      var inputField = CommentInputField(postId: post.id, key: launchKey);

      bottomInput = Consumer<NewFloorProvider>(
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
                      offset: Offset(0, -1),
                      blurRadius: 2,
                      spreadRadius: 3),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  inputField,
                                  ImageSelectAndView(key: imageSelectionKey),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SizedBox(width: 4),
                                      IconButton(
                                          icon: Image.asset(
                                            'assets/images/lake_butt_icons/image.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          onPressed: () => imageSelectionKey
                                              .currentState
                                              .loadAssets()),
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
                                  margin: EdgeInsets.fromLTRB(16, 20, 0, 20),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
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
                      PostCard.outSide(
                        post,
                        onLikePressed: (isLike, likeCount) {
                          post.isLike = isLike;
                          post.likeCount = likeCount;
                        },
                        onFavoritePressed: (isFav, favCount) {
                          post.isFav = isFav;
                          post.favCount = favCount;
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
      body = Column(
        children: [mainList, bottomInput],
      );
    } else {
      body = Center(child: Text("error!"));
    }

    // var menuButton = PopupMenuButton(
    //     child: SvgPicture.asset(
    //         'assets/svg_pics/lake_butt_icons/more_vertical.svg'),
    //     splashRadius: 20,
    //     onPressed: () {
    //       showMenu(
    //         context: context,
    //         shape: RacTangle(),
    //         /// 左侧间隔1000是为了离左面尽可能远，从而使popupMenu贴近右侧屏幕
    //         /// MediaQuery...top + kToolbarHeight是状态栏 + AppBar的高度
    //         position: RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
    //         items: <PopupMenuItem<String>>[
    //           new PopupMenuItem<String>(
    //             value: '举报',
    //             child: new Text(
    //               '举报',
    //               style: FontManager.YaHeiRegular.copyWith(
    //                 fontSize: 13,
    //                 color: ColorUtil.boldTextColor,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ).then((value) {
    //         if (value == "举报") {
    //           Navigator.pushNamed(context, FeedbackRouter.report,
    //               arguments: ReportPageArgs(widget.post.id, true));
    //         }
    //       });
    //     });
    var menuButton = PopupMenuButton(

        ///改成了用PopupMenuButton的方式，方便偏移的处理
        shape: RacTangle(),
        offset: Offset(100, 20),
        child: SvgPicture.asset(
            'assets/svg_pics/lake_butt_icons/more_vertical.svg'),
        onSelected: (value) {
          if (value == "举报") {
            Navigator.pushNamed(context, FeedbackRouter.report,
                arguments: ReportPageArgs(widget.post.id, true));
          }
        },
        itemBuilder: (context) {
          return <PopupMenuItem<String>>[
            PopupMenuItem<String>(
              value: '举报',
              child: Center(
                child: new Text(
                  '举报',
                  style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 13,
                    color: ColorUtil.boldTextColor,
                  ),
                ),
              ),
            ),
          ];
        });
    var shareButton = IconButton(
        icon: Icon(Icons.share, size: 23, color: ColorUtil.boldTextColor),
        onPressed: () {
          String weCo =
              '我在微北洋发现了个有趣的问题，你也来看看吧~\n将本条微口令复制到微北洋校务专区打开问题 wpy://school_project/${post.id}\n【${post.title}】';
          ClipboardData data = ClipboardData(text: weCo);
          Clipboard.setData(data);
          CommonPreferences().feedbackLastWeCo.value = post.id.toString();
          ToastProvider.success('微口令复制成功，快去给小伙伴分享吧！');
        });

    var appBar = AppBar(
      backgroundColor: ColorUtil.greyF7F8Color,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context, post),
      ),
      actions: [shareButton, menuButton],
      title: Text(
        S.current.feedback_detail,
        style: TextUtil.base.NotoSansSC.black2A.w500.sp(18),
      ),
      centerTitle: true,
      elevation: 0,
      brightness: Brightness.light,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, post);
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorUtil.backgroundColor,
        appBar: appBar,
        body: body,
      ),
    );
  }
}

var shareChannel = MethodChannel("com.twt.service/share");

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

  void send() {
    if (_textEditingController.text.isNotEmpty) {
      if (context.read<NewFloorProvider>().replyTo == 0) {
        _sendFloor();
      } else {
        _replyFloor();
      }
    } else
      ToastProvider.error('文字不能为空哦');
    Provider.of<NewFloorProvider>(context, listen: false).inputFieldClose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Consumer<NewFloorProvider>(
        builder: (_, data, __) {
          data.focusNode = _commentFocus;
          return TextField(
              style: TextUtil.base.w400.NotoSansSC.sp(16).h(1.4).black00,
              focusNode: _commentFocus,
              controller: _textEditingController,
              maxLength: 200,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                counterText: '',
                hintText: data.replyTo == 0
                    ? '回复冒泡：'
                    : '回复楼层：' + data.replyTo.toString(),
                suffix: Text(
                  _commentLengthIndicator,
                  style: TextUtil.base.w400.NotoSansSC.sp(14).greyAA,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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

  _sendFloor() {
    ToastProvider.running('创建楼层中 q(≧▽≦q)');
    FeedbackService.sendFloor(
      id: widget.postId.toString(),
      content: _textEditingController.text,
      images: context.read<NewFloorProvider>().images,
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

  _replyFloor() {
    ToastProvider.running('回复中 q(≧▽≦)/');
    FeedbackService.replyFloor(
      id: context.read<NewFloorProvider>().replyTo.toString(),
      content: _textEditingController.text,
      images: context.read<NewFloorProvider>().images,
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

class ImageSelectAndView extends StatefulWidget {
  const ImageSelectAndView({Key key}) : super(key: key);

  @override
  ImageSelectAndViewState createState() => ImageSelectAndViewState();
}

class ImageSelectAndViewState extends State<ImageSelectAndView> {
  loadAssets() async {
    XFile xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);
    context.read<NewFloorProvider>().images.add(File(xFile.path));
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
