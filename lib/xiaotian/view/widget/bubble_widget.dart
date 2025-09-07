import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import '../../util/sendMessage.dart';



class bubbleFromAi extends StatefulWidget {
  const bubbleFromAi({
    super.key,
    this.text,
    this.stream,
    required this.messageId,
    required this.index,
  }) : assert(
  (text != null && stream == null) || (text == null && stream != null),
  'Provide either a text or a stream, but not both.',
  );

  final String messageId;
  final String? text;
  final Stream<ChatEvent>? stream;
  final int index;
  @override
  State<bubbleFromAi> createState() => _bubbleFromAiState();
}

class _bubbleFromAiState extends State<bubbleFromAi> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _textNotifier = ValueNotifier<String>(''); // token 拼接结果
  final _sourceNotifier = ValueNotifier<List<Source>>([]);
  final _followupNotifier = ValueNotifier<String?>(null);
  final _errorNotifier = ValueNotifier<String?>(null);

  StreamSubscription<ChatEvent>? _streamSubscription;
  @override
  void initState() {
    super.initState();

    final chatState = context.read<xiaotianChatState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.stream != null) {
        chatState.changeStreamState(false);
      } else if (widget.text != null) {
        chatState.changeStreamState(true);
      }
    });

    if (widget.stream != null) {
      chatState.changeStreamState(false);
      _streamSubscription = widget.stream!.listen(
            (event) {
          switch (event.type) {
            case 'token':
              final token = event.data['token'] as String;
              if (mounted) {
                _textNotifier.value += token;
              }
              break;
            case 'source':
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
              chatState.changeStreamState(true);
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              chatState.changeStreamState(true);
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
    super.build(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 主体文本 ---
            //TODO:为什么会一口气显示？
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.92,
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: _textNotifier,
                builder: (context, text, child) {
                  if (text.isEmpty && widget.stream != null) {
                    return Baseline(
                      baseline: 20,
                      baselineType: TextBaseline.alphabetic,
                      child: SizedBox(
                        width: 25.w,
                        height: 25.h,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Loading(),
                        ),
                      ),
                    );
                  }
                  return Markdown(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
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

            //信息来源
            ValueListenableBuilder<List<Source>>(
              valueListenable: _sourceNotifier,
              builder: (context, sources, child) {
                if (sources.isEmpty) return const SizedBox.shrink();
                return CollapsibleSourceList(source: sources);
              },
            ),

            //跟随问题
            ValueListenableBuilder<String?>(
              valueListenable: _followupNotifier,
              builder: (context, followup, child) {
                if (followup == null || followup.isEmpty) {
                  return const SizedBox.shrink();
                }
                return followUp(context,followup, () {
                  sendAMessage(followup, context);
                });
              },
            ),

            //错误信息
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

            //按钮
            ValueListenableBuilder<String>(
              valueListenable: _textNotifier,
              builder: (context, text, child) {
                // 判断 stream 是否结束（如果结束就显示按钮）
                if (!context.read<xiaotianChatState>().isStreamCompleted || text.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //复制
                    WButton(
                      child: SvgPicture.asset(
                        'assets/svg_pics/ai_icons/copy.svg',
                        width: 16.r,
                        height: 16.r,
                      ),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: text)),
                    ),
                    SizedBox(width: 12.w),
                    //重新生成回答
                    WButton(
                      child:  SvgPicture.asset(
                      'assets/svg_pics/ai_icons/resend.svg',
                      width: 16.r,
                      height: 16.r,
                      ),
                      onPressed: () => reSendQuestion(context,widget.index),
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
  final String text;

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
                color: WpyTheme.of(context).get(WpyColorKey.lightPrimaryContainerColor),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                text,
                style: TextUtil.base.PingFangSC.label(context).normal.w400.sp(14),
              ),
            ),
            // 气泡下的按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WButton(
                  child:  SvgPicture.asset(
                  'assets/svg_pics/ai_icons/copy.svg',
                    width: 16.r,
                    height: 16.r,
                  ),
                  onPressed: () =>Clipboard.setData(ClipboardData(text: text)),
                ),
                SizedBox(width: 12.w),
                WButton(
                  child:  SvgPicture.asset(
                  'assets/svg_pics/ai_icons/edit.svg',
                  width: 16.r,
                  height: 16.r,
                  ),
                  onPressed: (){
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: WpyTheme.of(context).get(WpyColorKey.labelTextColor).withOpacity(0.4),
          width: 2.r,
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0,4.h),
            blurRadius: 10.r,
            color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor).withOpacity(0.05)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部行
          Row(
            children: [
              Text('信息来源 ${widget.source.length}',style: TextUtil.base.label(context).PingFangSC.w500.sp(14),),
              SizedBox(width: 6.w),
              WButton(
                onPressed: () {
                  setState(() {
                    _open = !_open;
                  });
                },
                child: Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h,),
          // 展开部分
          if (_open)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.source.map((src) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: TextUtil.base.PingFangSC.w400.medium.label(context).sp(12),
                        children: [
                          TextSpan(text: src.title ?? ''),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Image.asset(
                                src.contentType == 'database'? 'assets/images/ai/database.png': 'assets/images/ai/form_web.png',
                                width: 12.w,
                                height: 12.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}

Widget followUp(BuildContext context,String title,VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
      //发送关联问题
    child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(vertical:10.h,horizontal: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            gradient: WpyTheme.of(context).getGradient(WpyColorSetKey.primaryGradient),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0,4.h),
                  blurRadius: 10.r,
                  color: WpyTheme.of(context).get(WpyColorKey.reverseBackgroundColor).withOpacity(0.05)
              )
            ]
        ),
        child: RichText(
          text: TextSpan(
            style: TextUtil.base.PingFangSC.bright(context).w400.medium.sp(12),
            children: [
              TextSpan(text: title),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Image.asset(
                    'assets/images/ai/arrow.png',
                    width: 12.w,
                    height: 12.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        )
    ),
  );
}