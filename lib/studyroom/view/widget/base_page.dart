import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/time_picker_widget.dart';

import '../../../commons/widgets/w_button.dart';

class StudyroomBasePage extends StatefulWidget {
  final Widget body;
  final EdgeInsets padding;
  final bool isOutside;
  final bool showTimeButton;

  const StudyroomBasePage({
    Key? key,
    required this.body,
    this.showTimeButton = true,
    this.padding = EdgeInsets.zero,
    this.isOutside = false,
  }) : super(key: key);

  @override
  State<StudyroomBasePage> createState() => _StudyroomBasePageState();
}

class _StudyroomBasePageState extends State<StudyroomBasePage> {
  @override
  Widget build(BuildContext context) {
    Widget timeButton = Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: SizedBox(
          width: 43.w,
          child: WButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.w),
                    topRight: Radius.circular(20.w),
                  ),
                ),
                builder: (_) => TimePickerWidget(),
              );
            },
            child: Image.asset(
              'assets/images/studyroom_icons/schedule.png',
            ),
          )),
    );

    Widget appbar = AppBar(
      titleSpacing: 0,
      leadingWidth: 50.w,
      elevation: 0,
      toolbarHeight: 60.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: WButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Image.asset(
            'assets/images/studyroom_icons/pop.png',
            width: 20.w,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: [if (widget.showTimeButton) timeButton],
    );

    final heroAppbar = Hero(
      tag: 'appbar',
      transitionOnUserGestures: true,
      child: appbar,
    );

    return Builder(builder: (context) {
      return Stack(
        children: [
          Container(
            width: WePeiYangApp.screenWidth,
            height: WePeiYangApp.screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isOutside
                    ? [
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor),
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryLightestActionColor),
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor),
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryBackgroundColor),
                      ]
                    : [
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor),
                        WpyTheme.of(context)
                            .get(WpyColorKey.primaryLighterActionColor),
                      ],
                stops: widget.isOutside ? [0, 0.5, 0.5, 1] : null,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.w),
              child: heroAppbar,
            ),
            body: Padding(
              padding: widget.padding,
              child: widget.body,
            ),
          ),
        ],
      );
    });
  }
}
