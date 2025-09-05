import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../model/xiaotian_dio.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';



class bubbleFromAi extends StatefulWidget {
  const bubbleFromAi({
    super.key,
    this.text,
    this.stream,
    required this.messageId,
  }) : assert(
  (text != null && stream == null) || (text == null && stream != null),
  'Provide either a text or a stream, but not both.',
  );

  final String messageId;
  final String? text;
  final Stream<ChatEvent>? stream;

  @override
  State<bubbleFromAi> createState() => _bubbleFromAiState();
}

class _bubbleFromAiState extends State<bubbleFromAi> {
  final _textNotifier = ValueNotifier<String>(''); // token 拼接结果
  final _sourceNotifier = ValueNotifier<List<Source>>([]);
  final _followupNotifier = ValueNotifier<String?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);

  StreamSubscription<ChatEvent>? _streamSubscription;

  bool _isStreamCompleted = false;

  @override
  void initState() {
    super.initState();

    if (widget.stream != null) {
      _isStreamCompleted = false;
      _streamSubscription = widget.stream!.listen(
            (event) {
          switch (event.type) {
            case 'token':
              final token = event.data['token'] as String;
              _textNotifier.value += token;
              break;
            case 'source':
            /// event.data 是 List<Source>
              final list = (event.data as List<Source>);
              _sourceNotifier.value = list;
              break;
            case 'followup':
              _followupNotifier.value = event.data['question'] as String;
              break;
            case 'error':
              _errorNotifier.value = event.data['message'] as String;
              break;
            case 'trace_id':
              debugPrint("trace_id: ${event.data['trace_id']}");
              break;
          }
        },
        onError: (error) {
          if (mounted) {
            _errorNotifier.value = error.toString();
            setState(() {
              _isStreamCompleted = true;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isStreamCompleted = true;
            });
            context.read<xiaotianChatState>().completeMessageStream(
              widget.messageId,
              _textNotifier.value,
            );
          }
        },
      );
    } else if (widget.text != null) {
      _textNotifier.value = widget.text!;
      _isStreamCompleted = true;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _textNotifier.dispose();
    _sourceNotifier.dispose();
    _followupNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 主体文本 ---
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: _textNotifier,
                builder: (context, text, child) {
                  if (text.isEmpty && widget.stream != null) {
                    return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  return Markdown(
                    data: text,
                    selectable: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),

            // --- source ---
            ValueListenableBuilder<List<Source>>(
              valueListenable: _sourceNotifier,
              builder: (context, sources, child) {
                if (sources.isEmpty) return const SizedBox.shrink();
                return CollapsibleSourceList(source: sources);
              },
            ),

            // --- followup ---
            ValueListenableBuilder<String?>(
              valueListenable: _followupNotifier,
              builder: (context, followup, child) {
                if (followup == null || followup.isEmpty) {
                  return const SizedBox.shrink();
                }
                return followUp(followup, () {});
              },
            ),

            // --- 错误信息 ---
            ValueListenableBuilder<String?>(
              valueListenable: _errorNotifier,
              builder: (context, error, child) {
                if (error == null) return const SizedBox.shrink();
                return Text(
                  "⚠ $error",
                  style: const TextStyle(color: Colors.red),
                );
              },
            ),

            // --- 按钮 ---
            ValueListenableBuilder<String>(
              valueListenable: _textNotifier,
              builder: (context, text, child) {
                // 判断 stream 是否结束（如果结束就显示按钮）
                if (!_isStreamCompleted || text.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WButton(
                      child: Icon(Icons.copy_rounded, size: 20.r),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: text)),
                    ),
                    SizedBox(width: 12.w),
                    WButton(
                      child: Icon(Icons.refresh_rounded, size: 20.r),
                      onPressed: () {
                        // TODO: 重新生成回答
                      },
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}


//用户发言的气泡
class bubbleFromUser extends StatelessWidget {
  final String text;            // 消息内容

  const bubbleFromUser({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 聊天气泡
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                text,
                style: TextUtil.base.PingFangSC.normal.w400.sp(14),
              ),
            ),
            // 气泡下的按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WButton(
                  child: Icon(Icons.copy_rounded, size: 20.r),
                  onPressed: () =>Clipboard.setData(ClipboardData(text: text)),
                ),
                SizedBox(width: 12.w),
                WButton(
                  child: Icon(Icons.edit, size: 20.r),
                  onPressed: (){
                    //TODO:重新编辑问题
                    context.read<xiaotianInputState>().onEdit(text);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//可展开的信息组件
class CollapsibleSourceList extends StatefulWidget {
  final List<Source> source; // 数据源

  const CollapsibleSourceList({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<CollapsibleSourceList> createState() => _CollapsibleSourceListState();
}

class _CollapsibleSourceListState extends State<CollapsibleSourceList> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.blueAccent.shade100,
      ),
      child: Column(
        children: [
          // 头部行
          Row(
            children: [
              Text('信息来源 ${widget.source.length}'),
              IconButton(
                onPressed: () {
                  setState(() {
                    _open = !_open;
                  });
                },
                icon: Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
            ],
          ),
          // 展开部分
          if (_open)
            Column(
              children: widget.source.map((src) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 来源标题
                      Text(src.title ?? ''),
                      SizedBox(width: 4.w),
                      // 来源类型
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          src.contentType == 'web' ? '网络' : '知识库',
                          style: TextStyle(
                            color: Colors.deepPurple.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

Widget followUp(String title,VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
      //发送关联问题
    child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(vertical:10.h,horizontal: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.grey.shade200
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextUtil.base.PingFangSC.w400.medium.sp(12),
            ),
            const Icon(Icons.chevron_right)
          ],
        )
    ),
  );
}