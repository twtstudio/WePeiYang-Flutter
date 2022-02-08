// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

abstract class UpdateDialogState<T extends StatefulWidget> extends State<T> {
  @protected
  Version get version;

  late double dialogWidth;
  late double horizontalPadding;
  late double dialogRadius;

  late Widget title;
  late Widget detail;
  late Widget updateButtons;
  late Widget checkbox;

  @protected
  String get okButtonText;

  @protected
  String get cancelButtonText;

  @protected
  void okButtonTap();

  @protected
  void cancelButtonTap();

  bool todayNotShowAgain = false;

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    dialogWidth = windowWidth * 0.77;
    horizontalPadding = dialogWidth * 0.1;
    dialogRadius = dialogWidth * 0.077;
    final buttonWidth = dialogWidth * 0.36;
    final buttonHeight = buttonWidth * 0.368;
    final buttonRadius = buttonWidth * 0.08;

    title = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "版本更新",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        FutureBuilder(
          future: UpdateUtil.getVersion(),
          builder: (_, snapshot) {
            String versionChange;
            if (snapshot.hasData) {
              versionChange = '${snapshot.data} -> ${version.version}';
            } else {
              versionChange = '将更新到${version.version}';
            }
            return Text(
              versionChange,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            );
          },
        ),
      ],
    );

    detail = Text(
      updateDetail(version),
      style: const TextStyle(
        fontSize: 10,
        height: 2,
      ),
    );

    final cancelButton = InkWell(
      onTap: cancelButtonTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              offset: Offset(0, 2),
              blurRadius: 20,
            )
          ],
        ),
        child: Text(
          cancelButtonText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final okButton = InkWell(
      onTap: okButtonTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: const Color(0xff62677b),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              offset: Offset(0, 2),
              blurRadius: 20,
            )
          ],
        ),
        child: Text(
          okButtonText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );

    updateButtons = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            cancelButton,
            okButton,
          ],
        ),
      ],
    );

    final checkboxLeftPadding = horizontalPadding;
    const checkboxElsePadding = 10.0;
    final checkboxHeight = buttonHeight * 0.4;

    const checkboxTextWidget = Padding(
      padding: EdgeInsets.only(top: 0),
      child: Text(
        '今日不再弹出',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xffdedede),
        ),
      ),
    );

    checkbox = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              todayNotShowAgain = !todayNotShowAgain;
              if(todayNotShowAgain){
                CommonPreferences().todayShowUpdateAgain.value = DateTime.now().toString();
              }else {
                CommonPreferences().todayShowUpdateAgain.value = '';
              }
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              left: checkboxLeftPadding,
              top: checkboxElsePadding,
              bottom: checkboxElsePadding * 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                todayNotShowAgain
                    ? Icon(
                  Icons.check_circle,
                  size: checkboxHeight,
                  color: Colors.black,
                )
                    : Icon(
                  Icons.panorama_fish_eye,
                  size: checkboxHeight,
                  color: const Color(0xffdedede),
                ),
                const SizedBox(width: checkboxElsePadding - 4),
                checkboxTextWidget,
              ],
            ),
          ),
        ),
      ],
    );

    return const SizedBox.shrink();
  }

  String updateDetail(Version version) {
    String versionDetail = '';
    int index = 1;
    version.content.split("-").forEach((item) {
      if (item.isNotEmpty) {
        versionDetail = versionDetail + '$index.' + item.trim() + '\n';
      }
      index++;
    });
    return versionDetail;
  }
}
