import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';

/// 联系人列表项组件
class ContactTileWidget extends StatelessWidget {
  final PrivateChatContact contact;
  final VoidCallback onTap;

  const ContactTileWidget({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = contact.formattedLastMsgTime;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 40.w, height: 40.w,
          child: contact.avatarUrl.isNotEmpty
              ? WpyPic(contact.avatarUrl, width: 40.w, height: 40.w, fit: BoxFit.cover, withCache: true)
              : CircleAvatar(
                  backgroundColor:
                      WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                  child: Text(
                    contact.username.length > 2
                        ? contact.username.substring(contact.username.length - 2)
                        : contact.username,
                    style: TextUtil.base.regular.sp(14).reverse(context),
                  ),
                ),
        ),
      ),
      title: Text(
        contact.username,
        style: TextUtil.base.w600.sp(16).label(context),
      ),
      subtitle: Text(
        contact.lastMsg.isEmpty ? '暂无消息' : contact.lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextUtil.base.regular.sp(13).secondary(context),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timeStr.isNotEmpty)
            Text(
              timeStr,
              style: TextUtil.base.regular.sp(12).secondary(context),
            ),
          if (contact.unreadCount > 0) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color:
                    WpyTheme.of(context).get(WpyColorKey.dangerousRed),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                contact.unreadCount > 99
                    ? '99+'
                    : '${contact.unreadCount}',
                style: TextUtil.base.regular.sp(11).reverse(context),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
