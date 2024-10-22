import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';


class LostAndFoundHistoryPage extends StatefulWidget {
  LostAndFoundHistoryPage({Key? key}) : super(key: key);

  @override
  LostAndFoundHistoryPageState createState() => LostAndFoundHistoryPageState();
}

class LostAndFoundHistoryPageState extends State<LostAndFoundHistoryPage> {
  // late LostAndFoundNotifier notifier;
  // late LostAndFoundSearchNotifier searchNotifier;
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    // notifier = Provider.of<LostAndFoundNotifier>(context, listen: false);
    // searchNotifier =
    //     Provider.of<LostAndFoundSearchNotifier>(context, listen: false);
    _refreshController = RefreshController();
    // notifier.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                  WpyTheme.of(context)
                      .get(WpyColorKey.primaryLighterActionColor),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: WButton(
              child: WpyPic(
                'assets/svg_pics/laf_butt_icons/back.svg',
                width: 30.w,
                height: 30.w,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            '历史记录',
            style: TextUtil.base.w500.primary(context).sp(18),
          ),
          centerTitle: true,
        ),
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: () async {
              // await notifier.getHistory();
              _refreshController.refreshCompleted();
            },
            child: Container()));
  }
}
