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
      ),
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

//开启新页面的占位贴图
class newChatTile extends StatelessWidget {
  const newChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
          SizedBox(height: 20.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Text('因为我也刚刚和大家见面,我的回答仅供参考\n有误的地方请你批评指正哦～\n快来和我一起开启这段超棒的问答旅程吧～',textAlign:TextAlign.center,
                style: TextUtil.base.label(context).w400.PingFangSC.normal.sp(15).h(1.4)
            ),
          ),
        ],
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
  // 1. 定义录音控制器
  // todo (强烈建议将 Key 移至服务端或加密存储，不要直接写在前端)
  final _recordController = RecordController(
    accessKeyId: aliyunInfo.accessKeyId,
    accessKeySecret: aliyunInfo.accessKeySecret,
    appKey: aliyunInfo.appKey,
  );
  // 用来记录开始录音时的光标位置或已有文本，视需求而定
  String _textBeforeRecording = "";
  @override
  void initState() {
    super.initState();
    // 2. 初始化录音权限
    _recordController.init();

    // 3. 添加监听器，当语音识别有结果时，同步到输入框
    _recordController.addListener(_syncVoiceToInput);
  }

  @override
  void dispose() {
    _recordController.removeListener(_syncVoiceToInput);
    _recordController.dispose();
    super.dispose();
  }

  // 4. 同步语音文字的逻辑
  void _syncVoiceToInput() {
    // 获取当前的 inputState (需要 context)
    // 注意：这里假设 context 可用。如果在 dispose 后调用会报错，所以上面要在 dispose 移除监听
    if (!mounted) return;

    final inputState = Provider.of<xiaotianInputState>(context, listen: false);

    // 只有在有结果时才更新
    if (_recordController.state == RecordState.success &&_recordController.resultText.isNotEmpty) {
      // 策略：将语音内容追加到光标处，或者直接覆盖
      // 这里采用简单的逻辑：如果是录音中，将当前文本替换为 "录音前的文本 + 识别结果"
      // 这样用户在说话时能看到实时上屏

      String newText = _textBeforeRecording + _recordController.resultText;

      inputState.textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        ),
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
      // 开始录音前，记录当前输入框已有的内容
      _textBeforeRecording = inputState.textController.text;
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
                onTapOutside: (_) => inputState.unFocus(),
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
                          final boxShadow = isRecording
                              ? [BoxShadow( // 录音时添加阴影
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8.r,
                            spreadRadius: 2.r,
                            offset: Offset(0, 2.r),
                          )]
                              : []; // 非录音时无阴影
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


