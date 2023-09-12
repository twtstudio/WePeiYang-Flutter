import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/normal_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';

class ReplyDetailPage extends StatefulWidget {
  final ReplyDetailPageArgs args;

  ReplyDetailPage(this.args);

  @override
  _ReplyDetailPageState createState() => _ReplyDetailPageState();
}

class ReplyDetailPageArgs {
  final Floor floor;
  final int uid;
  final bool isMessage;

  ReplyDetailPageArgs(this.floor, this.uid, {this.isMessage = false});
}

class _ReplyDetailPageState extends State<ReplyDetailPage>
    with SingleTickerProviderStateMixin {
  int currentPage = 1;
  List<Floor>? floors;

  double _previousOffset = 0;
  final launchKey = GlobalKey<CommentInputFieldState>();
  final imageSelectionKey = GlobalKey<ImageSelectAndViewState>();

  var _refreshController = RefreshController(initialRefresh: false);

  _onRefresh() {
    currentPage = 1;
    _refreshController.resetNoData();
    _getComment(
        onResult: (comments) {
          setState(() {
            floors = comments;
          });
          _refreshController.refreshCompleted();
        },
        onFail: () {
          _refreshController.refreshFailed();
        },
        page: 0);
  }

  _onLoading() {
    currentPage++;
    _getComment(
        onResult: (comments) {
          if (comments.length == 0) {
            _refreshController.loadNoData();
            currentPage--;
          } else {
            floors?.addAll(comments);
            _refreshController.loadComplete();
          }
        },
        onFail: () {
          _refreshController.loadFailed();
        },
        page: currentPage);
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (context.read<NewFloorProvider>().inputFieldEnabled == true &&
        scrollInfo.metrics.pixels - _previousOffset >= 20) {
      context.read<NewFloorProvider>().clearAndClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = 0;
    _getComment(
      onResult: (comments) {
        setState(() {
          floors = comments;
        });
      },
      onFail: () {
        ToastProvider.error('获取回复失败');
      },
      page: 0,
    );
  }

  Future<bool> _getComment(
      {required Function(List<Floor>) onResult,
      required Function onFail,
      required int page}) async {
    bool success = false;
    FeedbackService.getFloorReplyById(
      floorId: widget.args.floor.id,
      page: page,
      onResult: (comments) {
        onResult.call(comments);
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        onFail.call();
      },
    );
    return success;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Widget checkButton = InkWell(
      onTap: () {
        launchKey.currentState?.send(false);
        setState(() {
          _onRefresh();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0, bottom: 12.0),
        child: SvgPicture.asset('assets/svg_pics/lake_butt_icons/send.svg',
            width: 20),
      ),
    );
    Widget mainList1 = ListView.builder(
      itemCount: floors != null ? floors!.length + 1 : 0 + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              NCommentCard(
                comment: widget.args.floor,
                uid: widget.args.uid,
                ancestorUId: widget.args.floor.postId,
                ancestorName: widget.args.floor.nickname,
                commentFloor: index + 1,
                isSubFloor: false,
                isFullView: true,
              ),
              Container(
                width: WePeiYangApp.screenWidth - 30.w,
                height: 1,
                color: Colors.black12,
              ),
              SizedBox(height: 6.h)
            ],
          );
        }
        index--;

        var data = floors![index];
        return Column(
          children: [
            NCommentCard(
              comment: data,
              uid: widget.args.uid,
              ancestorName: widget.args.floor.nickname,
              ancestorUId: widget.args.floor.id,
              commentFloor: index + 1,
              isSubFloor: true,
              isFullView: true,
            ),
          ],
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

    var inputField =
        CommentInputField(postId: widget.args.floor.postId, key: launchKey);

    body = Column(
      children: [
        mainList,
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
                        color: Colors.black12,
                        offset: Offset(0, -1),
                        blurRadius: 2,
                        spreadRadius: 3),
                  ],
                  color: ColorUtil.whiteF8Color),
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
                                      ?.loadAssets()),
                              if (context
                                      .read<NewFloorProvider>()
                                      .images
                                      .length ==
                                  0)
                                IconButton(
                                    icon: Image.asset(
                                      'assets/images/lake_butt_icons/paste.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: () => launchKey.currentState
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
                                      launchKey
                                          .currentState?.textEditingController
                                          .clear();
                                      launchKey.currentState?.setState(() {
                                        launchKey.currentState
                                            ?.commentLengthIndicator = '清空成功';
                                      });
                                    } else {
                                      Provider.of<NewFloorProvider>(context,
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
                        Provider.of<NewFloorProvider>(context, listen: false)
                            .inputFieldOpenAndReplyTo(widget.args.floor.id);
                        FocusScope.of(context).requestFocus(
                            Provider.of<NewFloorProvider>(context,
                                    listen: false)
                                .focusNode);
                      },
                      child: Container(
                          height: 22,
                          margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('友善回复，真诚沟通',
                                style: TextUtil.base.NotoSansSC.w500.grey97
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
          );
        })
      ],
    );

    var postButton = GestureDetector(
      child: Center(
          child: Text(
        '查看原帖',
        style: TextUtil.base.black2A.bold,
      )),
      onTap: () async {
        await FeedbackService.getPostById(
            id: widget.args.floor.postId,
            onResult: (post) {
              Navigator.pushNamed(
                context,
                FeedbackRouter.detail,
                arguments: post,
              );
              MessageService.setPostFloorMessageRead(post.id);
              context.read<MessageProvider>().refreshFeedbackCount();
            },
            onFailure: (e) {
              ToastProvider.error(e.message ?? '获取帖子失败');
            });
      },
    );

    var menuButton = IconButton(
      icon:
          SvgPicture.asset('assets/svg_pics/lake_butt_icons/more_vertical.svg'),
      splashRadius: 20,
      onPressed: () {
        showMenu(
          context: context,

          /// 左侧间隔1000是为了离左面尽可能远，从而使popupMenu贴近右侧屏幕
          /// MediaQuery...top + kToolbarHeight是状态栏 + AppBar的高度
          position: RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
          items: <PopupMenuItem<String>>[
            new PopupMenuItem<String>(
                value: '举报',
                child:
                    Text('举报', style: TextUtil.base.regular.blue303C.sp(13))),
          ],
        ).then((value) {
          if (value == "举报") {
            Navigator.pushNamed(context, FeedbackRouter.report,
                arguments: ReportPageArgs(widget.args.floor.id, true));
          }
        });
      },
    );

    var appBar = AppBar(
      titleSpacing: 0,
      backgroundColor: ColorUtil.greyF7F8Color,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorUtil.mainColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [if (widget.args.isMessage) postButton, menuButton],
      title: InkWell(
        onTap: () => _refreshController.requestRefresh(),
        child: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '回复',
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
        context.read<NewFloorProvider>().clearAndClose();
        Navigator.pop(context);
        return true;
      },
      child: GestureDetector(
        child: Scaffold(
            appBar: appBar,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: body,
            )),
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dx > 20) {
            context.read<NewFloorProvider>().clearAndClose();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
