import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/linkify_text.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/long_text_shower.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';

class FeedbackNoticePage extends StatelessWidget {
  final NoticeMessage notice;

  const FeedbackNoticePage(this.notice, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBar = PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: AppBar(
        titleSpacing: 0,
        leadingWidth: 25,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title:
            Text('湖底通知', style: TextUtil.base.black2A.w500.NotoSansSC.sp(18)),
        leading: IconButton(
          icon:
              Image.asset('assets/images/lake_butt_icons/back.png', width: 14),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    var id = Text(
      '#TZ' + notice.id.toString().padLeft(6, '0'),
      style: TextUtil.base.w400.normal.grey6C.ProductSans.sp(14),
    );

    var createTime = Text(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(notice.createdAt.toLocal()),
      textAlign: TextAlign.right,
      style: TextUtil.base.grey6C.normal.ProductSans.sp(14),
    );

    var topWidget = Row(
      children: [id, Spacer(), createTime],
    );

    var title = Text(
      notice.title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextUtil.base.w500.NotoSansSC.sp(18).black2A,
    );

    var content = InkWell(
      onLongPress: () {
        Clipboard.setData(
            ClipboardData(text: '【' + notice.title + '】 ' + notice.content));
        ToastProvider.success('复制通知内容成功');
      },
      child: SizedBox(
        width: double.infinity,
        child: ExpandableText(
          text: notice.content,
          maxLines: 8,
          style: TextUtil.base.NotoSansSC.w400.sp(16).black2A.h(1.2),
          expand: false,
          buttonIsShown: true,
          isHTML: false,
        ),
      ),
    );

    var middleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        SizedBox(height: 8.w),
        content
      ],
    );

    var bottomWidget = LinkText(
      text: notice.url,
      style: TextUtil.base.NotoSansSC.w400.sp(16).black2A.h(1.2),
    );

    var mainWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        topWidget,
        SizedBox(height: 8.w),
        middleWidget,
        SizedBox(height: 8.w),
        if (notice.url != '') bottomWidget,
      ],
    );

    var noticeCard = Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: ColorUtil.whiteFDFE,
              boxShadow: [
                BoxShadow(
                    blurRadius: 5,
                    color: ColorUtil.greyF7F8Color,
                    offset: Offset(0, 0),
                    spreadRadius: 3),
              ],
            ),
            child: mainWidget,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: ColorUtil.greyF7F8Color,
      appBar: appBar,
      body: noticeCard,
    );
  }
}
