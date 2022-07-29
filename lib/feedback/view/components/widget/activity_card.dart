import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import '../../../feedback_router.dart';

class ActivityCard extends StatefulWidget {
  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  _ActivityCardState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget card(BuildContext context, int index) {
      return InkWell(
        onTap: () async {
          context.read<FestivalProvider>().festivalList[index].url.startsWith('https://photograph.twt.edu.cn/') ?
            await launch('https://photograph.twt.edu.cn/') :
          Navigator.pushNamed(context, FeedbackRouter.haitang,
              arguments: FestivalArgs(
                  context.read<FestivalProvider>().festivalList[index].url,
                  context.read<FestivalProvider>().festivalList[index].title));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                      context
                          .read<FestivalProvider>()
                          .festivalList[index]
                          .image,
                      fit: BoxFit.cover,
                      width: WePeiYangApp.screenWidth - 28,
                      height: 128),
                  Positioned(
                      bottom: 4,
                      right: 8,
                      child: TextPod(context
                          .read<FestivalProvider>()
                          .festivalList[index]
                          .title)),
                ],
              )),
        ),
      );
    }

    return Container(
      height: 140,
      padding: EdgeInsets.fromLTRB(13, 12, 13, 0),
      child: Consumer<FestivalProvider>(
          builder: (BuildContext context, value, Widget child) {
        return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: Swiper(
              autoplay: context.read<FestivalProvider>().festivalList.length != 1,
              autoplayDelay: 5000,
              itemCount:
                  context.read<FestivalProvider>().festivalList.length == 0
                      ? 1
                      : context.read<FestivalProvider>().festivalList.length,
              itemBuilder: (BuildContext context, int index) {
                return context.read<FestivalProvider>().festivalList.length == 0
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
                          children: List.generate(config.itemCount, (index) {
                            return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: index == config.activeIndex
                                          ? Colors.white
                                          : Color.fromRGBO(0, 0, 25, 0.22),
                                      borderRadius: BorderRadius.circular(100)),
                                ));
                          })),
                    ),
                  );
                },
              ),
            ));
      }),
    );
  }
}
