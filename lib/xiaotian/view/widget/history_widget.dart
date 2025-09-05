import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../../model/xiaotian_model.dart';

class historyTab extends StatelessWidget {
  const historyTab({super.key,required this.session});
  final HistorySession session;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final chatState = context.read<xiaotianChatState>();
        Navigator.of(context).pop();

        final hisMes = await AiTjuApi().getConversation(
          sessionId: session.sessionId,
          userId: CommonPreferences.userNumber.value,
        );

        final hisToCurMes = List.generate(
          hisMes.length,
              (i) => chatState.fromHistoryToCurrent(hisMes[i]),
        );

        final sessions = await AiTjuApi().getAllSessions(
          CommonPreferences.userNumber.value,
        );
          chatState
            ..setSessionId(session.sessionId)
            ..messageSet(hisToCurMes)
            ..setHistorySession(sessions);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r)
        ),
        child: Text(session.title,style: TextUtil.base.PingFangSC.w400.sp(14),),
      ),
    );
  }
}



Widget drawerHeader(BuildContext context) {
  return Container(
    height: 100.h, // 控制整体高度
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
    child: Row(
      children: [
        Image.asset(
            'assets/images/ai/image130.png',
          width: 28.w,
          height: 28.h,
        ),
        SizedBox(width: 16),
        Text(
          '小天老师',
          style: TextUtil.base.label(context).w400.PingFangSC.sp(24)
        ),
      ],
    ),
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
        Container(
          margin: EdgeInsets.only(bottom: 8.h,left: 15.w,right: 15.w),
          padding:EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期标题
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  dateStr,
                  style: TextUtil.base.PingFangSC.bright(context).w400.sp(14),
                ),
              ),
              // 当天的所有 tab
              ...tabs.map((tab) => historyTab(session: tab)),
            ],
          ),
        ),
      );
    });

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

