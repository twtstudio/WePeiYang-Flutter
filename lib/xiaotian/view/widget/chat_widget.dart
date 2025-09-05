import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/xiaotian/model/xiaotian_dio.dart';
import '../widget/bubble_widget.dart';
import '../../model/xiaotian_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../../model/xiaotian_model.dart';

class openNewSession extends StatelessWidget {
  const openNewSession({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: (){
          context.read<xiaotianChatState>().openNewSession();
        },
        icon: const Icon(Icons.add)
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
                child: Text('Hi，同学你好！我是你们24小时不下线的“小天老师”～很高兴见到你',textAlign:TextAlign.center,
                    style: TextUtil.base.label(context).w400.PingFangSC.bold.sp(22)
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text('我努力为你提供精准、智能、高效的校内信息咨询服务',textAlign:TextAlign.start,
                    style: TextUtil.base.label(context).w400.PingFangSC.medium.sp(16)
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text('因为我也刚刚和大家见面,我的回答仅供参考,有误的地方请你批评指正哦～快来和我一起开启这段超棒的问答旅程吧～',textAlign:TextAlign.start,
                    style: TextUtil.base.label(context).w400.PingFangSC.medium.sp(16)
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
                  if (msg.text != null && msg.text!.isNotEmpty) {
                    return bubbleFromAi(
                      key: key,
                      messageId: msg.id,
                      text: msg.text,
                    );
                  } else {
                    return bubbleFromAi(
                      key: key,
                      messageId: msg.id,
                      stream: msg.stream,
                    );
                  }
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
  int i1 = 0;
  int i2 = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer2<xiaotianInputState,xiaotianChatState>
      (builder: (context,inputState,chatState,_) {
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          width: 360.w,
          height: 100.h,
          padding: EdgeInsets.only(left:15.w,right: 15.w,top: 15.h,bottom: 5.h),
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            boxShadow: [
              BoxShadow(
                color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor).withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0,4.h)
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
                  onTapOutside: (_) => inputState.unfocus(),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(fontSize: 14.sp, height: 1.2.h),
                  strutStyle: StrutStyle(
                    fontSize: 14.sp,
                    height: 1.2.h,
                    forceStrutHeight: true,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '给小天老师发消息',
                    hintStyle: TextStyle(height: 1.2.h),
                  ),
                ),
              ),
              SizedBox(
                height: 32.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WebSearch(inputState),
                    Row(
                      children: [
                        WButton(
                          onPressed: () {
                            // TODO: 添加链接文件
                          },
                          child: Icon(Icons.link_off_rounded, size: 20.r),
                        ),
                        SizedBox(width: 12.w),
                        WButton(
                          onPressed: () {
                            if (inputState.textController.text.isEmpty) return;

                            final _inputState = inputState;

                            if (chatState.sessionId == '0') {
                              final id = getSessionId();
                              chatState.setSessionId(id);
                            }

                            chatState.messageAdd(_inputState.makeMessage());

                            Stream<ChatEvent> sseStream = AiTjuApi().streamChat(
                              prompt: _inputState.textController.text.trim(),
                              sessionId: chatState.sessionId,
                              userId: CommonPreferences.userNumber.value,
                              files: _inputState.files,
                              searchTime: _inputState.searchTime,
                              searchType: _inputState.searchType,
                            );

                            final ai_ans = AiMessage(stream: sseStream);
                            chatState.messageAdd(ai_ans);

                            final currentText = _inputState.textController.text;
                            _inputState.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (inputState.scrollController.hasClients) {
                                inputState.scrollController.animateTo(
                                  inputState.scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                          child: Icon(Icons.send_rounded, size: 20.r),
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

Widget WebSearch(xiaotianInputState inputState) {
  return Row(
    children: [
      WButton(
        onPressed: () => inputState.changeOpenSearch(),
        child: Icon(
          Icons.language_rounded,
          color: inputState.openSearch ? Colors.blue : Colors.grey,
          size: 20.r,
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
              child: Text(SearchT.timeCh[inputState.timeIndex]),
            ),
            SizedBox(width: 12.w),
            WButton(
              onPressed: () {
                final next = SearchT.nextType(inputState.typeIndex);
                inputState.changeType(next);
              },
              child: Text(SearchT.typeCh[inputState.typeIndex]),
            ),
          ],
        ),
    ],
  );
}
