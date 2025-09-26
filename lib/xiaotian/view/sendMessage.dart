import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../network/xiaotian_service.dart';
import '../model/xiaotian_state.dart';
import '../model/xiaotian_model.dart';
import '../../../commons/preferences/common_prefs.dart';

void reSendQuestion(BuildContext context, int index) {
  final chatState = context.read<xiaotianChatState>();
  String question = '';

  //找到该消息的前一个用户消息
  for (int i = index; i >= 0; i--) {
    final msg = chatState.messages[i];
    if (msg is UserMessage) {
      question = msg.content;
      break;
    }
  }

  sendAMessage(question, context);
}

void sendAMessage(String text, BuildContext context) {
  if (text.isEmpty) return;

  final inputState = context.read<xiaotianInputState>();
  final chatState = context.read<xiaotianChatState>();

  final _inputState = inputState;
  _inputState.textController.text = text;

  if (chatState.sessionId == '0') {
    final id = getSessionId();
    chatState.setSessionId(id);
  }

  //这是用户消息
  chatState.messageAdd(_inputState.makeMessage());

  //请求ai回复

  //添加ai消息
  final ai_ans = AiMessage(
    prompt: text.trim(),
    sessionId: chatState.sessionId,
    userId: CommonPreferences.userNumber.value,
    files: _inputState.files,
    searchTime: _inputState.searchTime,
    searchType: _inputState.searchType,
  );
  print('ai_ans.stream - start');
  print(ai_ans.stream);
  print('ai_ans.stream - end');
  chatState.messageAdd(ai_ans);

  _inputState.clear();

  scrollScreen(inputState.scrollController);
}

void scrollScreen(ScrollController controller) {
  //把屏幕滚到最下面
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

void feedBackPost(FeedBack fb) async {
  try {
    final response = await AiService().updateLikeStatus(
        traceId: fb.traceId,
        likeCount: fb.likeCount,
        state: fb.state ?? '',
        feedbackInformation: fb.feedbackInformation ?? '');
    print("请求成功: ${response.data}");
  } catch (e) {
    print('error:$e');
  }
}
