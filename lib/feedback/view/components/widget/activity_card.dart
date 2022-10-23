// @dart = 2.12
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';
import 'package:we_pei_yang_flutter/main.dart';


class ActivityCard extends StatefulWidget {
  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  _ActivityCardState();

  SwiperController sp = SwiperController();
  bool offstage = true;
  bool dark = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget card(BuildContext context, int index) {
      return InkWell(
        onTap: () async {
          final url = context.read<FestivalProvider>().festivalList[index].url;
          if (url.isEmpty) {
            sp.stopAutoplay();
            setState(() {
              dark = true;
              offstage = false;
            });
            Future.delayed(Duration(milliseconds: 1000)).then((value) {
              setState(() {
                dark = false;
              });
              Future.delayed(Duration(milliseconds: 400)).then((value) {
                setState(() {
                  offstage = true;
                });
                sp.startAutoplay();
              });
            });
          } else if (url.startsWith('browser:')) {
            final launchUrl = url
                .replaceAll('browser:', '')
                .replaceAll('<token>', '${CommonPreferences.token.value}')
                .replaceAll(
                    '<laketoken>', '${CommonPreferences.lakeToken.value}');
            if (await canLaunchUrlString(launchUrl)) {
              launchUrlString(launchUrl, mode: LaunchMode.externalApplication);
            } else {
              ToastProvider.error('好像无法打开活动呢，请联系天外天工作室');
            }
          } else
            Navigator.pushNamed(context, FeedbackRouter.haitang,
                arguments: FestivalArgs(
                    url,
                    context
                        .read<FestivalProvider>()
                        .festivalList[index]
                        .title));
        },
        child: Stack(
          children: [
            Image.network(
                context.read<FestivalProvider>().festivalList[index].image,
                fit: BoxFit.cover,
                width: WePeiYangApp.screenWidth - 28,
                height: 0.32 * WePeiYangApp.screenWidth),
            Positioned(
                bottom: 4,
                right: 4,
                child: TextPod(context
                    .read<FestivalProvider>()
                    .festivalList[index]
                    .title)),
          ],
        ),
      );
    }

    return Container(
      height: 0.32 * WePeiYangApp.screenWidth,
      child: Consumer<FestivalProvider>(
          builder: (BuildContext context, value, Widget? child) {
        return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                context.read<FestivalProvider>().festivalList.length == 1
                    ? card(context, 0)
                    : Swiper(
                        controller: sp,
                        autoplay: context
                                .read<FestivalProvider>()
                                .festivalList
                                .length !=
                            1,
                        autoplayDelay: 5000,
                        itemCount: context
                                    .read<FestivalProvider>()
                                    .festivalList
                                    .length ==
                                0
                            ? 1
                            : context
                                .read<FestivalProvider>()
                                .festivalList
                                .length,
                        itemBuilder: (BuildContext context, int index) {
                          return context
                                      .read<FestivalProvider>()
                                      .festivalList
                                      .length ==
                                  0
                              ? SizedBox()
                              : card(context, index);
                        },
                        fade: 0.3,
                        viewportFraction: 1,
                        scale: 1,
                        pagination: SwiperCustomPagination(
                          builder: (context, config) {
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(config.itemCount,
                                        (index) {
                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                                color:
                                                    index == config.activeIndex
                                                        ? Colors.white
                                                        : Color.fromRGBO(
                                                            0, 0, 25, 0.22),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                          ));
                                    })),
                              ),
                            );
                          },
                        ),
                      ),
                Offstage(
                  offstage: offstage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    color: dark ? Colors.black38 : Colors.transparent,
                    child: Center(
                        child: Text('是未知领域！\n没有可跳转的网页喵(っ °Д °;)っ',
                            style: TextUtil.base.white.w700.sp(17))),
                  ),
                )
              ],
            ));
      }),
    );
  }
}
