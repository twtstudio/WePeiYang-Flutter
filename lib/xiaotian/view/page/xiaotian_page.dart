import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import '../widget/loading_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
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
    // AiTjuApi().setupDio();
    //第一次打开之后写入本地存储
    CommonPreferences.firstUseAI.value = false;

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
    final sessions = await AiTjuApi().getAllSessions(CommonPreferences.userNumber.value);

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
            backgroundColor: Colors.transparent,
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
            body: PageControl(context)
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
      children: [
        Expanded(
          child: Consumer<xiaotianChatState>(
            builder: (context, chatState, _) {
              return chatState.sessionId == '0'
                  ? const newChatTile()
                  : const ChatTile();
            },
          ),
        ),
        //输入框
        const SafeArea(child: inputBox()),
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