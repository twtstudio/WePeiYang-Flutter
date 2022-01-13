import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/like_widget.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

typedef LikeCallback = void Function(bool, int);

class NCommentCard extends StatefulWidget {
  final Floor comment;
  final int commentFloor;
  final LikeCallback likeSuccessCallback;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard({this.comment, this.commentFloor, this.likeSuccessCallback});
}

class _NCommentCardState extends State<NCommentCard> {

  Future<bool> _showDeleteConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('您确定要删除这条评论吗?'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = SizedBox(height: 8);

    var topWidget = Row(
      children: [
        Icon(Icons.account_circle_rounded,
            size: 34, color: Color.fromRGBO(98, 103, 124, 1.0)),
        SizedBox(height: 8),
       Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.comment.nickname ?? S.current.feedback_anonymous,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextUtil.base.black2A.w400.NotoSansSC.sp(14),
            ),
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.comment.createAt),
              style: TextUtil.base.ProductSans.grey97.regular.sp(10),
            ),
          ],
        ),),
        IconButton(
          icon: Icon(Icons.more_horiz),
          iconSize: 16,
          onPressed: () {},
          constraints: BoxConstraints(),
          padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
        )
      ],
    );

    var commentContent = Text(
      widget.comment.content,
      style: TextUtil.base.w400.NotoSansSC.normal.black2A.sp(14),
    );

    var floor = IconButton(
      icon: Icon(Icons.chat),
      iconSize: 16,
      constraints: BoxConstraints(),
      onPressed: (){},
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
      color: ColorUtil.boldLakeTextColor,
    );

    var deleteButton = TextButton(
      onPressed: () async {
        bool confirm = await _showDeleteConfirmDialog();
        if(confirm) {
          FeedbackService.deleteFloor(
            id: widget.comment.id,
            onSuccess: () {
              ToastProvider.success(S.current.feedback_delete_success);
              setState(() {});
            },
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            },
          );
        }
      },
      child: Text(
        '删除',
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 12,
          color: ColorUtil.lightTextColor,
        ),
      ),
    );

    // var reportWidget = IconButton(
    //     iconSize: 20,
    //     padding: const EdgeInsets.all(2),
    //     constraints: BoxConstraints(),
    //     icon: Icon(
    //       Icons.warning_amber_rounded,
    //       color: ColorUtil.lightTextColor,
    //     ),
    //     onPressed: () {
    //       Navigator.pushNamed(context, FeedbackRouter.report,
    //           arguments: ReportPageArgs(widget.comment.id, false));
    //     });

    var likeWidget = LikeWidget(
      count: widget.comment.likeCount,
      onLikePressed: (isLiked, count,success,failure) async {
        await FeedbackService.commentHitLike(
          id: widget.comment.id,
          isLike: widget.comment.isLike,
          onSuccess: () {
            widget.likeSuccessCallback?.call(!isLiked, count);
            success.call();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
            failure.call();
          },
        );
      },
      isLike: widget.comment.isLike
    );

    var bottomWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        likeWidget,
        if(CommonPreferences().feedbackUid.value == widget.comment.uid.toString())deleteButton,
        floor,
      ],
    );

    var body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box,
        topWidget,
        box,
        box,
        commentContent,
        bottomWidget,
      ],
    );

    return DefaultTextStyle(
      style: FontManager.YaHeiRegular,
      child: ClipCopy(
        copy: widget.comment.content,
        toast: '复制评论成功',
        // 这个padding其实起到的是margin的效果，因为Ink没有margin属性
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          // 这个Ink是为了确保body -> bottomWidget -> reportWidget的波纹效果正常显示
          child: Ink(
            padding: const EdgeInsets.fromLTRB(20, 8, 15, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    blurRadius: 5,
                    color: Color.fromARGB(64, 236, 237, 239),
                    offset: Offset(0, 0),
                    spreadRadius: 3),
              ],
            ),
            child: body,
          ),
        ),
      ),
    );
  }
}
