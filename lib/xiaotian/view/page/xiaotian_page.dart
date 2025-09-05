import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
import '../../../commons/preferences/common_prefs.dart';


class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  @override
  void initState() {
    //刚打开时打开新页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<xiaotianChatState>().setSessionId('0');
    });
    ///提前获取历史会话记录，防止打开侧边栏时卡顿
    _loadHistory();
    super.initState();
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text('小天老师',style: TextUtil.base.PingFangSC.label(context).w400.bold.sp(18),),
            centerTitle: true,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.dashboard_rounded),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            actions: const [openNewSession()],
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
        ),
    );
  }
}
