import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../widget/water_mark.dart';


class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<xiaotianChatState>();
      state.isLoading(true);
      _loadHistory().then((_) {
        state.isLoading(false);
      });
      state.setSessionId('0');
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
          child: !context.watch<xiaotianChatState>().loading ? Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text('小天老师',style: TextUtil.base.PingFangSC.label(context).w400.bold.sp(18),),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return WButton(
                    child: Icon(Icons.dashboard_rounded,size: 28.r,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              actions: [const openNewSession(),SizedBox(width: 15.w)],
            ),
            drawer: const historyDrawer(),
            body: Column(
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
            ),
          ) : //TODO:加载动画
          Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )
        )
    );
  }
}
