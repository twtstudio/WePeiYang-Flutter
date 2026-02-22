import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';

/// 消息气泡组件
class MessageBubbleWidget extends StatelessWidget {
  final PrivateChatMsgVO msg;
  final bool isMine;
  final VoidCallback? onLongPress;

  const MessageBubbleWidget({
    super.key,
    required this.msg,
    required this.isMine,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = msg.formattedTime;

    // 消息状态文本
    String statusText = '';
    if (isMine && !msg.isRecalled) {
      statusText = msg.msgStatus == 0
          ? '未读'
          : msg.msgStatus == 1
              ? '已读'
              : '';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) _buildAvatar(context, '${msg.senderId ?? '?'}'),
          if (!isMine) SizedBox(width: 8.w),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: msg.isRecalled
                      ? WpyTheme.of(context)
                          .get(WpyColorKey.secondaryBackgroundColor)
                      : isMine
                          ? WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor)
                          : WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: Radius.circular(isMine ? 18.r : 4.r),
                    bottomRight: Radius.circular(isMine ? 4.r : 18.r),
                  ),
                  boxShadow: [
                    if (!isMine && !msg.isRecalled)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // 消息内容
                    Text(
                      msg.isRecalled
                          ? '⚠️ ${msg.content ?? "消息已撤回"}'
                          : msg.content ?? '',
                      style: msg.isRecalled
                          ? TextUtil.base.regular
                              .sp(15)
                              .secondary(context)
                              .copyWith(fontStyle: FontStyle.italic)
                          : isMine
                              ? TextUtil.base.regular.sp(15).reverse(context)
                              : TextUtil.base.regular.sp(15).label(context),
                    ),
                    SizedBox(height: 4.h),
                    // 时间 + 状态
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timeStr.isNotEmpty)
                          Text(
                            timeStr,
                            style: TextUtil.base.regular.sp(11).copyWith(
                                  color: isMine && !msg.isRecalled
                                      ? Colors.white70
                                      : WpyTheme.of(context)
                                          .get(WpyColorKey.secondaryTextColor),
                                ),
                          ),
                        if (statusText.isNotEmpty) ...[
                          SizedBox(width: 4.w),
                          Text(
                            statusText,
                            style: TextUtil.base.regular.sp(10).copyWith(
                                  color: isMine
                                      ? Colors.white60
                                      : WpyTheme.of(context)
                                          .get(WpyColorKey.secondaryTextColor),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMine) SizedBox(width: 8.w),
          if (isMine) _buildMyAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String idStr) {
    final displayStr =
        idStr.length > 2 ? idStr.substring(idStr.length - 2) : idStr;
    return CircleAvatar(
      radius: 16.r,
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryLightActionColor),
      child: Text(
        displayStr,
        style: TextUtil.base.regular.sp(11).reverse(context),
      ),
    );
  }

  Widget _buildMyAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 16.r,
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
      child: Text(
        '我',
        style: TextUtil.base.regular.sp(12).reverse(context),
      ),
    );
  }
}
