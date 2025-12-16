import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import '../widget/loading_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';
import '../../network/xiaotian_service.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../widget/water_mark.dart';
import 'package:shimmer/shimmer.dart';


class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  @override
  void initState() {
    super.initState();

    final state = context.read<xiaotianChatState>();

    if(state.firstLoad) {return;}

    WidgetsBinding.instance.addPostFrameCallback((_) {

      // state.isLoading(true);
      _loadHistory().then((_) {
        // state.isLoading(false);
        state.setSessionId('0');
        state.save();
      });

    });

  }
  Future<void> _loadHistory() async {
    final sessions = await AiService().getAllSessions(CommonPreferences.userNumber.value);

    if (mounted) {
      Provider.of<xiaotianChatState>(context, listen: false)
          .setHistorySession(sessions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => xiaotianInputState(),
        child: WatermarkBg(
          text:  CommonPreferences.userNumber.value,
          child:Scaffold(
            backgroundColor: WpyTheme.of(context).get(WpyColorKey.lighterPrimaryBackGround),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text('小天老师',style: TextUtil.base.PingFangSC.label(context).w400.bold.sp(18),),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return openHistory();
                },
              ),
              actions: [const openNewSession(),SizedBox(width: 15.w)],
            ),
            drawer: const historyDrawer(),
              body: Stack(
                children: [
                  PageControl(context),
                  if(context.read<xiaotianChatState>().sessionId != '0')
                    Positioned(
                        bottom: 250.h,
                        right: 16.w,
                        child: const Suggestion()
                    )
                ],
              )
          )
        )
    );
  }
}



class bodyPage extends StatelessWidget {
  const bodyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Consumer<xiaotianChatState>(
            builder: (context, chatState, _) {
              return chatState.sessionId == '0'
                  ? const NewChatTile()
                  : const ChatTile();
            },
          ),
        ),
        //输入框
        SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            inputBox(),
            // 临时把字号调大/颜色调明显以便调试
            Text(
              '内容由 AI 生成，请仔细甄别',
              style: TextUtil.base.labelWithOp(context).PingFangSC.normal.sp(10),
              textAlign: TextAlign.center,
            ),
            Text(
              '向 “小天老师” 发送消息即表示，您同意我们的用户条款并已阅读我们的隐私协议。',
              style: TextUtil.base.labelWithOp(context).PingFangSC.normal.sp(10),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h,)
          ],
        ),)
      ],
    );
  }
}




Widget PageControl(BuildContext context) {
  final chatState = context.watch<xiaotianChatState>();

  Widget child;
  if (!chatState.firstLoad) {
    child = mainLoad();
  } else if (chatState.historyLoading) {
    child = HistoryState();
  } else {
    child = bodyPage();
  }

  return child;
}



class ShimmerOverlayIcon extends StatelessWidget {
  final Widget icon;
  final Widget? badge;
  final Duration duration;
  final double offset;

  const ShimmerOverlayIcon({
    Key? key,
    required this.icon,
    this.badge,
    this.duration = const Duration(seconds: 2),
    this.offset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 把 icon + badge 放一起
    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        if (badge != null)
          Positioned(
            top: -offset,
            right: -offset,
            child: badge!,
          ),
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        stack, // 原始内容（正常可点击）
        IgnorePointer(
          child: Shimmer.fromColors(
            baseColor: Colors.transparent,
            highlightColor: Colors.white.withOpacity(0.8),
            period: duration,
            child: stack,
          ),
        ),
      ],
    );
  }
}