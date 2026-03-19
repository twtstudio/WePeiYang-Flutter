import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/xiaotian_state.dart';
import '../../network/xiaotian_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../../model/xiaotian_model.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class historyTab extends StatelessWidget {
  const historyTab({super.key,required this.session});
  final HistorySession session;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final chatState = context.read<xiaotianChatState>();
        Navigator.of(context).pop();

        chatState.isLoading(true);

        final hisMes = await AiService().getConversation(
          sessionId: session.sessionId,
          userId: CommonPreferences.userNumber.value,
        );

        final hisToCurMes = List.generate(
          hisMes.length,
              (i) => chatState.fromHistoryToCurrent(hisMes[i]),
        );

        final sessions = await AiService().getAllSessions(
          CommonPreferences.userNumber.value,
        );
          chatState
            ..setSessionId(session.sessionId)
            ..messageSet(hisToCurMes)
            ..setHistorySession(sessions)
            ..isLoading(false);


      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r)
        ),
        child: Text(session.title,style: TextUtil.base.label(context).PingFangSC.w400.sp(14),maxLines: 1,),
      ),
    );
  }
}



Widget drawerHeader(BuildContext context) {
  return Container(
    // height: 100.h, // 控制整体高度
    padding: EdgeInsets.only(left: 15.w, top: 22.h,bottom: 27.h),
    child: RichText(
      text: TextSpan(
        style: TextUtil.base.label(context).w600.PingFangSC.sp(24),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle, // 中线对齐
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Image.asset(
                'assets/images/ai/image130.png',
                width: 28.w,
                height: 28.h,
              ),
            ),
          ),
          TextSpan(text: '小天老师'),
        ],
      ),
    )
  );
}


class historyDrawer extends StatefulWidget {
  const historyDrawer({super.key});

  @override
  State<historyDrawer> createState() => _historyDrawerState();
}

class _historyDrawerState extends State<historyDrawer> {

  @override
  void initState() {
    super.initState();
    ///加载history改成从保存的history中获取
    // _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<xiaotianChatState>().historySession;

    //时间从新到旧排序
    final sortedHistory = [...history]..sort((a, b) {
      final da = DateTime.parse(a.creationTime);
      final db = DateTime.parse(b.creationTime);
      return db.compareTo(da);
    });

    //日期分组
    final Map<String, List<HistorySession>> grouped = {};
    for (final tab in sortedHistory) {
      final date = DateTime.parse(tab.creationTime);
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(tab);
    }

    //构建 children
    final List<Widget> children = [];
    children.add(drawerHeader(context));

    grouped.forEach((dateStr, tabs) {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // 日期标题
            Padding(
              padding: EdgeInsets.only(left: 25.w,bottom: 4.h,top: 4.h),
              child: Text(
                dateStr,
                style: TextUtil.base.PingFangSC.label(context).bold.sp(14),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8.h,left: 15.w,right: 15.w),
              padding:EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor).withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0,4.h)
                  )
                ],
                color: WpyTheme.of(context).get(WpyColorKey.skeletonEndBColor),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当天的所有 tab
                  ...tabs.map((tab) => historyTab(session: tab)),
                ],
              ),
            ),
          ],
        )
      );
    });

    return Drawer(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.lighterPrimaryBackGround),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: children,
        ),
      )
    );
  }
}

class openHistory extends StatelessWidget {
  const openHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return WButton(
      child: SvgPicture.asset(
        'assets/svg_pics/ai_icons/more.svg',
        width: 28.r,
        height: 28.r,
        colorFilter: ColorFilter.mode(
          WpyTheme.of(context).primary??Colors.blue,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );;
  }
}
