import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/xiaotian_dio.dart';
import '../model/xiaotian_state.dart';
import '../model/xiaotian_model.dart';
import '../../../commons/preferences/common_prefs.dart';

void reSendQuestion(BuildContext context) {
  final inputState = context.read<xiaotianInputState>();
  final chatState = context.read<xiaotianChatState>();

  Stream<ChatEvent> sseStream = AiTjuApi().streamChat(
    prompt: inputState.last,
    sessionId: chatState.sessionId,
    userId: CommonPreferences.userNumber.value,
    files: inputState.files,
    searchTime: inputState.searchTime,
    searchType: inputState.searchType,
  );

  final ai_ans = AiMessage(stream: sseStream);
  chatState.messageAdd(ai_ans);

  scrollScreen(inputState.scrollController);
}

void sendAMessage(String text,BuildContext context) {
  if (text.isEmpty) return;

  final inputState = context.read<xiaotianInputState>();
  final chatState = context.read<xiaotianChatState>();

  final _inputState = inputState;
  _inputState.textController.text = text;

  if (chatState.sessionId == '0') {
    final id = getSessionId();
    chatState.setSessionId(id);
  }

  chatState.messageAdd(_inputState.makeMessage());

  Stream<ChatEvent> sseStream = AiTjuApi().streamChat(
    prompt: text.trim(),
    sessionId: chatState.sessionId,
    userId: CommonPreferences.userNumber.value,
    files: _inputState.files,
    searchTime: _inputState.searchTime,
    searchType: _inputState.searchType,
  );

  final ai_ans = AiMessage(stream: sseStream);
  print(ai_ans.stream);
  chatState.messageAdd(ai_ans);

  final currentText = text;
  inputState.saveLast(currentText);
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