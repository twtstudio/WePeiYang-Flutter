import 'dart:core';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';

class ActivityCard extends StatefulWidget {
  final double width;

  ActivityCard(this.width);

  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  _ActivityCardState();

  SwiperController _swiperController = SwiperController();
  bool offstage = true;
  bool dark = false;

  @override
  void initState() {
    super.initState();
  }

  // 广告卡片的单个个体
  Widget BannerCard(BuildContext context, int index) {
    // 图片， 带有淡入淡出效果
    final banner = WpyPic(
      context.read<FestivalProvider>().nonePopupList[index].image,
      width: widget.width,
      height: widget.width * 0.32,
      fit: BoxFit.cover,
      withHolder: false,
      withCache: true,
    );

    return InkWell(
      onTap: () async {
        final url = context.read<FestivalProvider>().nonePopupList[index].url;
        if (url.isEmpty) return;
        if (url.startsWith('browser:')) {
          final launchUrl = url
              .replaceAll('browser:', '')
              .replaceAll('<token>', '${CommonPreferences.token.value}')
              .replaceAll(
                  '<laketoken>', '${await LakeTokenManager().refreshToken()}');
          if (await canLaunchUrlString(launchUrl)) {
            launchUrlString(launchUrl, mode: LaunchMode.externalApplication);
          } else {
            ToastProvider.error('好像无法打开活动呢，请联系天外天工作室');
          }
        } else {
          Navigator.pushNamed(
            context,
            FeedbackRouter.haitang,
            arguments: FestivalArgs(url,
                context.read<FestivalProvider>().nonePopupList[index].title),
          );
        }

      },
      child: Stack(
        children: [
          if (WpyTheme.of(context).brightness == Brightness.dark)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), // 调整这个透明度值来控制降低亮度的程度
                BlendMode.darken, // 使用darken混合模式来降低亮度
              ),
              child: banner,
            )
          else
            banner,
          Positioned(
              bottom: 4.w,
              right: 4.w,
              child: TextPod(
                  context.read<FestivalProvider>().nonePopupList[index].title)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.width * 0.32,
      child: Consumer<FestivalProvider>(
          builder: (BuildContext context, value, Widget? child) {
        final length = context.read<FestivalProvider>().nonePopupList.length;
        bool canSwipe = length > 1;
        print("==> length: $length, canSwipe: $canSwipe");
        return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            clipBehavior: Clip.hardEdge,
            child: !canSwipe
                ? BannerCard(context, 0)
                : Swiper(
                    controller: _swiperController,
                    autoplay: true,
                    autoplayDelay: 5000,
                    itemCount: length,
                    itemBuilder: (BuildContext context, int index) {
                      // 逆序
                      return BannerCard(context, length - index - 1);
                    },
                    fade: 0.3,
                    viewportFraction: 1,
                    scale: 1,
                    pagination: SwiperCustomPagination(
                      builder: _buildSwiperPagination,
                    ),
                  ));
      }),
    );
  }

  Widget _buildSwiperPagination(
      BuildContext context, SwiperPluginConfig config) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(config.itemCount, (index) {
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                        color: index == config.activeIndex
                            ? Colors.white
                            : Color.fromRGBO(0, 0, 25, 0.22),
                        borderRadius: BorderRadius.circular(100.r)),
                  ));
            })),
      ),
    );
  }
}
