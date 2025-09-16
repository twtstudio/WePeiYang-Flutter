import 'package:flutter/material.dart';
import 'xiaotian_model.dart';


class xiaotianInputState extends ChangeNotifier {
  List<String> files = [];

  final _time = ['noLimit','oneWeek','oneMonth','oneYear'];
  final _type = ['precise','no','all'];

  bool openSearch = false;
  int timeIndex = 0;
  int typeIndex = 0;

  String searchTime = 'noLimit';         //搜索时间范围
  String searchType = 'no';         //搜索类型

  void changeTime(int i) {
    timeIndex = i;
    searchTime = _time[i];
    notifyListeners();
  }

  void changeType(int i) {
    typeIndex = i;
    searchType = _type[i];
    notifyListeners();
  }

  void changeOpenSearch() {
    openSearch = !openSearch;
    if (openSearch == false) {
      resetSearch();
    }
    else {
      onSearch();
    }
    notifyListeners();
  }

  void onSearch() {
    timeIndex = 0;
    typeIndex = 0;
    searchTime = 'noLimit';
    searchType = 'precise';
  }

  void resetSearch() {
    timeIndex = 0;
    typeIndex = 1;
    searchTime = 'noLimit';
    searchType = 'no';
  }


  final FocusNode node = FocusNode();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();


  //发送完之后清除输入状态
  void clear() {
    files = [];
    searchType = 'no';
    searchTime = 'onLimit';
    node.unfocus();
    textController.clear();
    notifyListeners();
  }

  //让焦点失焦
  void unFocus() {
    node.unfocus();
  }

  void scrollToEnd()
  {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //返回一个message
  UserMessage makeMessage() {

    final user_message = UserMessage(content: textController.text.trim(),files: files);
    return user_message;
  }

  //重新编辑
  void onEdit(String content) {
    textController.text = content;
    node.requestFocus();
  }


  xiaotianInputState();

}



class xiaotianChatState extends ChangeNotifier {

  static final xiaotianChatState _instance = xiaotianChatState._internal();
  factory xiaotianChatState()=>_instance;
  xiaotianChatState._internal();

  bool _isStreamCompleted = true;
  bool get isStreamCompleted => _isStreamCompleted;

  void StreamCompleted(bool b) {
    _isStreamCompleted = b;
    notifyListeners();
  }


  //储存的会话
  final Map<String, List<ChatMessage>> _sessions = {};
  //历史记录
  List<HistorySession> _historySession = [];
  //当前会话id
  String _sessionId = '0';

  String _traceID = '';
  String get traceID => _traceID;
  void saveLastTraceID(String trace) {
    _traceID = trace;
  }

  bool _hasLoading = false;
  bool get firstLoad => _hasLoading;
  void save() {
    _hasLoading = true;
    notifyListeners();
  }

  //判断是否正在加载
  bool _loading = false;
  bool get historyLoading => _loading;

  //改变加载状态
  void isLoading(bool b) {
    _loading = b;
    notifyListeners();
  }

  // 获取当前会话消息
  List<ChatMessage> get messages => _sessions[_sessionId] ?? [];

  //获得历史会话记录
  List<HistorySession> get historySession => _historySession;

  // 获取当前 sessionId
  String get sessionId => _sessionId;

  //获取历史会话记录
  void setHistorySession(List<HistorySession> history) {
    _historySession = history;
    notifyListeners();
  }

  //点击新会话后将会话id变成0，并通知页面更新,只有在第一次发消息的时候才申请会话id并申请会话
  void openNewSession() {
    _sessionId = '0';
    notifyListeners();
  }

  // 切换会话
  void setSessionId(String id) {
    _sessionId = id;
    _sessions.putIfAbsent(id, () => []); // 如果会话不存在则创建
    notifyListeners();
  }

  // 往当前会话中添加消息
  void messageAdd(ChatMessage cm) {
    _sessions.putIfAbsent(_sessionId, () => []);
    _sessions[_sessionId]!.add(cm);
    notifyListeners();
  }

  // 覆盖当前会话的消息（用于从后端拉取历史）
  void messageSet(List<ChatMessage> l_cm) {
    _sessions[_sessionId] = l_cm;
    notifyListeners();
  }

  ChatMessage fromHistoryToCurrent(HistoryChatMessage history_message_api) {
    if (history_message_api.role == 'user') {
      return UserMessage(content: history_message_api.content);
    } else {
      return AiMessage(
        text: history_message_api.content,
        likeCount: history_message_api.likeCount,
        traceId: history_message_api.traceId!,
        //源和追问不返回传null
      );
    }
  }

  //检查已完成的流，缓存为text，防止重复监听流
  void completeMessageStream(String messageId, String finalText) {
    for (var session in _sessions.values) {
      try {
        final message = session.firstWhere(
              (m) => m.id == messageId && m is AiMessage,
        ) as AiMessage;
        message.text = finalText;
        return;
      } catch (e) {
      }
    }
  }



}
