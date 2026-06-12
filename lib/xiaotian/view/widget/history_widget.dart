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

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({super.key, required this.session});
  final HistorySession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Material(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(10.r),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          splashColor: WpyTheme.of(context)
              .get(WpyColorKey.primaryActionColor)
              .withValues(alpha: 0.15),
          onTap: () async {
            final chatState = context.read<xiaotianChatState>();
            Navigator.of(context).pop();

            chatState.isLoading(true);

            try {
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
                ..setHistorySession(sessions);
            } finally {
              chatState.isLoading(false);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Text(
              session.title,
              style: TextUtil.base.label(context).PingFangSC.w400.sp(17),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

Widget drawerHeader(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(left: 15.w, top: 22.h, bottom: 27.h),
    child: RichText(
      text: TextSpan(
        style: TextUtil.base.label(context).w600.PingFangSC.sp(24),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
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
  }

  Future<void> _refreshHistory() async {
    final chatState = context.read<xiaotianChatState>();
    final sessions = await AiService().getAllSessions(
      CommonPreferences.userNumber.value,
    );
    chatState.setHistorySession(sessions);
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<xiaotianChatState>().historySession;

    final sortedHistory = [...history]..sort((a, b) {
        final da = DateTime.parse(a.creationTime);
        final db = DateTime.parse(b.creationTime);
        return db.compareTo(da);
      });

    final Map<String, List<HistorySession>> grouped = {};
    for (final tab in sortedHistory) {
      final date = DateTime.parse(tab.creationTime);
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(tab);
    }

    final List<Widget> tiles = [];
    grouped.forEach((dateStr, tabs) {
      tiles.add(
        Padding(
          padding: EdgeInsets.only(left: 20.w, top: 16.h, bottom: 4.h),
          child: Text(
            dateStr,
            style: TextUtil.base.PingFangSC.label(context).bold.sp(15),
          ),
        ),
      );
      for (int i = 0; i < tabs.length; i++) {
        tiles.add(HistoryListTile(session: tabs[i]));
      }
    });

    return Drawer(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            drawerHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshHistory,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: tiles,
                ),
              ),
            ),
          ],
        ),
      ),
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
          WpyTheme.of(context).primary ?? Colors.blue,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}
