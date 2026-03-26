import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/speech_to_text/API/aliyun_isi_protocol.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../commons/speech_to_text/model/record_controller.dart';
import '../widget/bubble_widget.dart';
import '../../model/xiaotian_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../model/xiaotian_model.dart';
import '../sendMessage.dart';
import '../../network/xiaotian_service.dart';
import '../../../commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'back_dialog.dart';


class openNewSession extends StatelessWidget {
  const openNewSession({super.key});

  @override
  Widget build(BuildContext context) {
    return WButton(
      onPressed: () async {
        context.read<xiaotianChatState>().openNewSession();
        final sessions = await AiService().getAllSessions(CommonPreferences.userNumber.value);
        Provider.of<xiaotianChatState>(context, listen: false)
            .setHistorySession(sessions);
      },
      child: SvgPicture.asset(
        'assets/svg_pics/ai_icons/new.svg',
        width: 28.r,
        height: 28.r,
        colorFilter: ColorFilter.mode(
          WpyTheme.of(context).primary??Colors.blue,
          BlendMode.srcIn,
        ),
      )
    );
  }
}

class Suggestion extends StatelessWidget {
  const Suggestion({super.key});

  @override
  Widget build(BuildContext context) {
    return WButton(
        onPressed: () async {
          final result = await showCustomInputDialog(
            context,
            title: '发送反馈',
            hint: '请输入你的意见',
          );
          if(result == null) return;
          final fb = FeedBack(traceId: context.read<xiaotianChatState>().traceID, likeCount: '2',feedbackInformation: result,state: '');
          feedBackPost(fb);
          ToastProvider.success('反馈成功');
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor).withOpacity(0.9),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/svg_pics/ai_icons/feedback.svg',
                width: 24.r,
                height: 24.r,
              ),
              SizedBox(height: 5.h,),
              Text('意\n见\n反\n馈',style: TextUtil.base.normal.PingFangSC.bold.textButtonPrimary(context).sp(15)),
            ],
          ),
        )
    );
  }
}




//开启新页面的占位贴图和热门话题
class NewChatTile extends StatefulWidget {
  const NewChatTile({super.key});

  @override
  State<NewChatTile> createState() => _NewChatTileState();
}
class _NewChatTileState extends State<NewChatTile> {
  List<HotTopic> _hotTopics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotTopics();
  }


  void _fetchHotTopics() async {
    setState(() {
      _isLoading = true;
    });

    try {

      final topics = await AiService().getHotTopics();


      if (mounted) {
        setState(() {
          _hotTopics = topics;
          _isLoading = false;
        });
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print("在UI层捕获到错误: $e");
      }
    }
  }

  Widget _buildTopicChips() {
    // 加载动画
    if (_isLoading) {
      return const CircularProgressIndicator(strokeWidth: 2.0);
    }
    //如果没有热门话题
    if (_hotTopics.isEmpty) {
      return const Text(
        "暂时没有热门话题哦~",
        style:TextStyle(color: Colors.grey),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _hotTopics.map((hotTopic) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: ActionChip(
            label: Text(
              hotTopic.topic,
              style: TextUtil.base.normal.PingFangSC.textButtonPrimary(context).sp(14)
            ),
            backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            side: BorderSide(color:  WpyTheme.of(context).get(WpyColorKey.beanDarkColor).withOpacity(0.8), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              print('点击了话题: ${hotTopic.topic}');
              sendAMessage(hotTopic.topic, context);
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('Hi，同学你好！\n 我是你们24小时不下线的“小天老师”\n很高兴见到你~',textAlign:TextAlign.center,
                    style: TextUtil.base.label(context).w400.PingFangSC.bold.sp(21)
                ),
              ),
              SizedBox(height: 40.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text('我努力为你提供精准、智能、高效的\n校内信息咨询服务',textAlign:TextAlign.center,
                    style: TextUtil.base.label(context).w400.PingFangSC.normal.sp(15).h(1.4)
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text('因为我也刚刚和大家见面,我的回答仅供参考\n有误的地方请你批评指正哦～\n快来和我一起开启这段超棒的问答旅程吧～',textAlign:TextAlign.center,
                    style: TextUtil.base.label(context).w400.PingFangSC.normal.sp(15).h(1.4)
                ),
              ),
              SizedBox(height: 60.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Align(
                  alignment: Alignment.centerLeft,   // 让chips靠左
                  child: _buildTopicChips(),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  const ChatTile({super.key});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {

  // @override
  // void initState() {
  //   super.initState();
  //
  //   // 安排一个回调，它会在第一帧绘制完成后执行
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // 在这里，我们可以安全地访问 Provider
  //     // listen: false 是一个优化，因为我们只需要获取一次控制器，不需要监听后续变化
  //     final inputState = Provider.of<xiaotianInputState>(context, listen: false);
  //
  //     // 直接调用你已经写好的函数
  //     scrollScreen(inputState.scrollController);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer2<xiaotianChatState, xiaotianInputState>(
        builder: (context, chatState, inputState, _) {
          return ListView.builder(
              controller: inputState.scrollController,
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                final key = ValueKey(msg.id);

                if (msg is UserMessage) {
                  return bubbleFromUser(key:key,text: msg.content);
                }
                else if (msg is AiMessage) {
                  return bubbleFromAi(
                    key: key,
                    messageId: msg.id,
                    index: index,
                    onFinished: (text) {
                      msg.setText(text);
                    },
                    prompt: msg.prompt,
                    searchTime: msg.searchTime,
                    searchType: msg.searchType,
                    sessionId: msg.sessionId,
                    headers: msg.headers,
                    text: msg.text, // 历史消息直接显示
                  );
                }
                else {
                  return const SizedBox.shrink();
                }
              });
        });
  }
}


//输入框
class inputBox extends StatefulWidget {
  const inputBox({super.key});

  @override
  State<inputBox> createState() => _inputBoxState();
}

class _inputBoxState extends State<inputBox> {
  //定义录音控制器
  // todo (强烈建议将 Key 移至服务端或加密存储，不要直接写在前端)
  final _recordController = RecordController(
    accessKeyId: aliyunInfo.accessKeyId,
    accessKeySecret: aliyunInfo.accessKeySecret,
    appKey: aliyunInfo.appKey,
  );
  // 用来记录开始录音时的光标位置或已有文本，视需求而定
  String _textBeforeRecording = "";
  String _prefixText = ""; // 光标前的文字
  String _suffixText = ""; // 光标后的文字
  @override
  void initState() {
    super.initState();
    // 添加监听器，当语音识别有结果时，同步到输入框
    _recordController.addListener(_syncVoiceToInput);
  }

  @override
  void dispose() {
    _recordController.removeListener(_syncVoiceToInput);
    _recordController.dispose();
    super.dispose();
  }

  //同步语音文字的逻辑
  void _syncVoiceToInput() {
    if (!mounted) return;

    final inputState = Provider.of<xiaotianInputState>(context, listen: false);

    // 只有在有结果时才更新
    if (_recordController.state == RecordState.success &&_recordController.resultText.isNotEmpty) {
      // 策略：将语音内容追加到光标处，或者直接覆盖
      // 获取当前的语音结果
      final voiceResult = _recordController.resultText;
      // 1. 拼接新文本： 前段 + 语音 + 后段
      final newText = _prefixText + voiceResult + _suffixText;
      // 2. 计算新光标位置： 前段长度 + 语音长度
      final newCursorIndex = _prefixText.length + voiceResult.length;

      inputState.textController.value = TextEditingValue(
        text: newText,
        // 保持光标在语音文字的后面，方便用户继续输入
        selection: TextSelection.collapsed(offset: newCursorIndex),
      );
    }
    else if(_recordController.state == RecordState.error){
      ToastProvider.error(_recordController.errorMessage);
    }
  }

  // 开始/停止录音的包装方法
  void _toggleRecording() {
    final inputState = Provider.of<xiaotianInputState>(context, listen: false);
    if (!_recordController.isRecording) {
      final controller = inputState.textController;
      final text = controller.text;
      final selection = controller.selection;
      // 处理光标丢失的情况（比如没点输入框就点录音），默认追加到最后
      int start = selection.start;
      int end = selection.end;
      if (start < 0 || end < 0) {
        // 如果没有光标，默认光标在最后
        start = text.length;
        end = text.length;
      }
      // 1. 切割光标前的文字
      _prefixText = text.substring(0, start);
      // 2. 切割光标后的文字 (如果有选中文本，selection.end 会跳过选中的部分，实现“语音替换选中文字”的效果)
      _suffixText = text.substring(end, text.length);
    }

    _recordController.toggleRecording();
  }

  int i1 = 0;
  int i2 = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer2<xiaotianInputState,xiaotianChatState>
      (builder: (context,inputState,chatState,_) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15.h),
        width: 360.w,
        height: 100.h,
        padding: EdgeInsets.only(left:15.w,right: 15.w,top: 15.h,bottom: 5.h),
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          boxShadow: [
            BoxShadow(
                color: WpyTheme.of(context).get(WpyColorKey.beanDarkColor).withOpacity(0.6),
                blurRadius: 8.r,
                offset: Offset(0,0)
            )
          ],
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: inputState.textController,
                focusNode: inputState.node,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextUtil.base.label(context).w500.PingFangSC.medium.sp(14),
                strutStyle: StrutStyle(
                  fontSize: 14.sp,
                  height: 1.2.h,
                  forceStrutHeight: true,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText:chatState.isStreamCompleted ? '给小天老师发消息' : '正在生成答案，请耐心等待',
                  hintStyle:TextUtil.base.labelWithOp(context).w500.PingFangSC.medium.sp(13),
                ),
              ),
            ),
            SizedBox(
              height: 32.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WebSearch(),
                  Row(
                    children: [
                      WButton(
                        onPressed: () {
                          // TODO: 添加链接文件
                        },
                        child: SizedBox.shrink(),
                      ),
                      SizedBox(width: 12.w),
                      // 5. 新增：录音按钮
                      // 使用 ListenableBuilder 监听 controller 状态变化来刷新按钮样式
                      ListenableBuilder(
                        listenable: _recordController,
                        builder: (context, child) {
                          bool isProcessing = _recordController.state == RecordState.processing;
                          bool isRecording = _recordController.isRecording;
                          return WButton(
                            onPressed: isProcessing ? null : _toggleRecording,
                            child: isProcessing
                                ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: CircularProgressIndicator(strokeWidth: 2, color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
                            )
                                : Icon(
                              isRecording ? Icons.mic_rounded : Icons.mic_none, // todo 这里可以换成的 SVG 图片
                              size: 24.r,
                              // 录音时变色
                              color: isRecording
                                  ? Colors.red
                                  : WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                              shadows: isRecording?[
                                Shadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 3,
                                  offset: Offset(2,2),
                                )
                              ]:null,
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12.w),
                      chatState.isStreamCompleted ? WButton(
                        onPressed: () => sendAMessage(inputState.textController.text,context),
                        child:  SvgPicture.asset(
                          'assets/svg_pics/ai_icons/send.svg',
                          width: 24.r,
                          height: 24.r,
                          colorFilter: ColorFilter.mode(
                            WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                            BlendMode.srcIn,
                          ),
                        ),
                      ) : WButton(
                        onPressed: (){},
                        child:  SvgPicture.asset(
                          'assets/svg_pics/ai_icons/stop.svg',
                          width: 28.r,
                          height: 28.r,
                          colorFilter: ColorFilter.mode(
                            WpyTheme.of(context).primary ?? Colors.blue,

                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    );
  }
}



class SearchT {
  static const timeCh = ['不限', '一周内', '一月内', '一年内'];
  static const typeCh = ['官网搜索', '不搜索', '全网搜索'];

  static int nextTime(int current) => (current + 1) % timeCh.length;
  static int nextType(int current) => (current + 1) % typeCh.length;
}

class WebSearch extends StatelessWidget {
  const WebSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final inputState = context.read<xiaotianInputState>();
    return Row(
      children: [
        WButton(
          onPressed: () => inputState.changeOpenSearch(),
          child:  SvgPicture.asset(
            'assets/svg_pics/ai_icons/global.svg',
            width: 24.r,
            height: 24.r,
            color: inputState.openSearch ? WpyTheme.of(context).get(WpyColorKey.primaryActionColor) : WpyTheme.of(context).get(WpyColorKey.labelTextColor),
          ),
        ),
        if (inputState.openSearch)
          Row(
            children: [
              SizedBox(width: 12.w),
              WButton(
                onPressed: () {
                  final next = SearchT.nextTime(inputState.timeIndex);
                  inputState.changeTime(next);
                },
                child: Text(SearchT.timeCh[inputState.timeIndex],style: TextUtil.base.PingFangSC.normal.label(context).sp(13),),
              ),
              SizedBox(width: 12.w),
              WButton(
                onPressed: () {
                  final next = SearchT.nextType(inputState.typeIndex);
                  inputState.changeType(next);
                },
                child: Text(SearchT.typeCh[inputState.typeIndex],style: TextUtil.base.PingFangSC.normal.label(context).sp(13),),
              ),
            ],
          ),
      ],
    );
  }
}


