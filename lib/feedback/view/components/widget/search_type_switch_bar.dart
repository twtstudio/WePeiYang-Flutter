import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class SearchTypeSwitchBar extends StatefulWidget {
  final RefreshController controller;
  final FbHomeListModel provider;

  SearchTypeSwitchBar({this.controller, this.provider});

  @override
  _SearchTypeSwitchBarState createState() => _SearchTypeSwitchBarState();
}

class _SearchTypeSwitchBarState extends State<SearchTypeSwitchBar> {
  @override
  Widget build(BuildContext context) {
    var type = CommonPreferences().feedbackSearchType.value;
    return Column(
      children: [
        Expanded(
          child: ElevatedButton(
            child: Text(
              "时间排序",
              style: FontManager.YaHeiRegular.copyWith(
                color: type == "1" ? ColorUtil.mainColor : ColorUtil.lightTextColor,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
                elevation: 0, primary: ColorUtil.backgroundColor),
            onPressed: () {
              if (type == "1") return;
              CommonPreferences().feedbackSearchType.value = "1";
              widget.provider.initPostList(
                  success: () {
                    widget.controller.refreshCompleted();
                  },
                  failure: (e) {
                    ToastProvider.error(e.error.toString());
                    widget.controller.refreshFailed();
                  },
                  reset: true);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Text(
              "热度排序",
              style: FontManager.YaHeiRegular.copyWith(
                color: type == "2" ? ColorUtil.mainColor : ColorUtil.lightTextColor,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
                elevation: 0, primary: ColorUtil.backgroundColor),
            onPressed: () {
              if (type == "2") return;
              CommonPreferences().feedbackSearchType.value = "2";
              widget.provider.initPostList(
                  success: () {
                    widget.controller.refreshCompleted();
                  },
                  failure: (e) {
                    ToastProvider.error(e.error.toString());
                    widget.controller.refreshFailed();
                  },
                  reset: true);
              setState(() {});
            },
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
