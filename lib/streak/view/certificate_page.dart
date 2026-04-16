import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class CertificatePage extends StatelessWidget {
  const CertificatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    // Use current date (precision to day) for the issue date display
    final now = DateTime.now();
    final String issueDate = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: WButton(
          child: Icon(Icons.close, color: Colors.black87, size: 28.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text('成就奖励', style: TextUtil.base.bold.sp(26).copyWith(color: primaryColor)),
            SizedBox(height: 8.h),
            Text('见证你的每一次自律与跨越', style: TextUtil.base.regular.sp(14).copyWith(color: Colors.black54)),
            SizedBox(height: 40.h),

            // 证书卡片主体
            Container(
              width: 300.w,
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Text('TJU ORBIT', style: TextUtil.base.bold.sp(12).copyWith(color: Colors.grey, letterSpacing: 2)),
                  SizedBox(height: 15.h),
                  Text('北洋圆 · 圆满完成', style: TextUtil.base.bold.sp(20).copyWith(color: Colors.black87)),
                  SizedBox(height: 30.h),

                  // 中央徽章
                  Container(
                    width: 140.w, height: 140.w,
                    alignment: Alignment.center,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.85),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //todo 这里的数字应该从接口里来
                          Text('21', style: TextUtil.base.bold.sp(48).copyWith(color: Colors.white, height: 1.1)),
                          Text('DAYS STREAK', style: TextUtil.base.bold.sp(10).copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                  Text('恭喜获得连续达标证书', style: TextUtil.base.bold.sp(16).copyWith(color: Colors.black87)),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.verified_user, color: Colors.grey[400], size: 24.r),
                      Column(
                        children: [
                          Text('ISSUE DATE', style: TextUtil.base.bold.sp(10).copyWith(color: Colors.grey)),
                          Text(issueDate, style: TextUtil.base.bold.sp(14).copyWith(color: Colors.black87)),
                        ],
                      ),
                      Text('CERTIFIED BY\nTWT STUDIO', textAlign: TextAlign.right, style: TextUtil.base.regular.sp(8).copyWith(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 50.h),

            // 底部按钮
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: WButton(
                onPressed: () {
                  // 保存图片或分享逻辑
                },
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20.r),
                      SizedBox(width: 8.w),
                      Text('保存并分享成就', style: TextUtil.base.bold.sp(16).copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}