// @dart=2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:we_pei_yang_flutter/auth/model/banner_pic.dart';
import 'package:we_pei_yang_flutter/auth/network/theme_service.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';

/// 活动弹窗
class ActivityDialog extends Dialog {
  final SwiperController controller = SwiperController();

  ActivityDialog();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeService.getBanner(),
      builder: (context, AsyncSnapshot<List<BannerPic>> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data.isEmpty) {
            Navigator.pop(context);
            return SizedBox.shrink();
          }
          return Column(
            children: [
              Spacer(),
              data.length == 1
                  ? SizedBox(
                      width: 0.81.sw,
                      height: 1.08.sw,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, FeedbackRouter.haitang,
                                arguments: FestivalArgs(data[0].url, '活动'));
                          },
                          child: WpyPic(
                            data[0].picUrl,
                            fit: BoxFit.cover,
                            withHolder: true,
                          ),
                        ),
                      ),
                    )
                  : Swiper(
                      controller: controller,
                      loop: true,
                      autoplay: true,
                      autoplayDelay: 4000,
                      itemWidth: 0.81.sw,
                      itemHeight: 1.08.sw,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (data.length == 0) return SizedBox();
                        return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, FeedbackRouter.haitang,
                                  arguments:
                                      FestivalArgs(data[index].url, '活动'));
                            },
                            child: WpyPic(
                              data[index].picUrl,
                              fit: BoxFit.cover,
                              withHolder: false,
                            ),
                          ),
                        );
                      },
                    ),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 1.sw,
                    height: 0.55.sh - 0.54.sw,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/lake_butt_icons/x.png',
                        width: 50.w,
                        height: 100.w,
                        color: Colors.white70,
                      ),
                    ),
                  ))
            ],
          );
        } else if (snapshot.hasError) {
          Navigator.pop(context);
          return SizedBox.shrink();
        } else {
          return Loading();
        }
      },
    );
  }
}
