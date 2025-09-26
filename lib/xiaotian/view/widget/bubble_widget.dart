import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/files.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/xiaotian/network/xiaotian_service.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'dart:async';
import '../sendMessage.dart';
import 'back_dialog.dart';

class bubbleFromAi extends StatefulWidget {
  bubbleFromAi({
    super.key,
    this.text,
    required this.messageId,
    required this.index,
    this.trace,
    required this.onFinished,
    this.prompt,
    this.sessionId,
    this.userId,
    this.files,
    this.searchTime,
    this.searchType,
    this.headers,
  });

  String? prompt;
  String? sessionId;
  String? userId;
  List<String>? files;
  String? searchTime;
  String? searchType;
  Map<String, String>? headers;
  final String messageId;
  final String? text;
  final int index;
  final String? trace;
  final Function(String) onFinished;

  @override
  State<bubbleFromAi> createState() => _bubbleFromAiState();
}

class _bubbleFromAiState extends State<bubbleFromAi>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String text = '';
  List<Source> sources = [];
  String? followup;
  String? error;
  String _trace = '';
  bool _streamCompleted = false;

  StreamSubscription<ChatEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<xiaotianChatState>().StreamCompleted(false);
      }
    });
    // 如果已经有历史文本，就直接显示
    if (widget.text != null && widget.text!.isNotEmpty) {
      text = widget.text!;
      _streamCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<xiaotianChatState>().StreamCompleted(true);
        }
      });
    } else {
      // 否则主动发起流请求
      _subscription = AiService().streamChat(
        prompt: widget.prompt ?? '',
        sessionId: widget.sessionId ?? '',
        searchTime: widget.searchTime,
        searchType: widget.searchType,
        headers: widget.headers,
      ).listen(
            (event) {
          setState(() {
            switch (event.type) {
              case 'followup':
                followup = event.data['question'];
                break;
              case 'token':
                text += event.data['token'] ?? '';
                break;
              case 'source':
                sources = List<Source>.from(event.data);
                _streamCompleted = true;
                break;
              case 'trace_id':
                _trace = event.data['trace_id'] ?? '';
                _streamCompleted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<xiaotianChatState>().StreamCompleted(true);
                  }
                });
                widget.onFinished(text);
                break;
              case 'error':
                error = event.data['message'];
                _streamCompleted = true;
                break;

            }
            scrollScreen(context.read<xiaotianInputState>().scrollController);
          });
        },
        onDone: () {
          setState(() => _streamCompleted = true);
          widget.onFinished(text);
        },
        onError: (err) {
          setState(() {
            error = err.toString();
            _streamCompleted = true;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主体文本
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.92,
              ),

              child: text.isEmpty
                  ? Baseline(
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
              )
                  : Markdown(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                data: text,
                selectable: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                  p: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            if(_streamCompleted) aiDeclaration(context),
            // 信息来源
            if (sources.isNotEmpty) CollapsibleSourceList(source: sources),

            // 跟随问题
            if (followup != null && followup!.isNotEmpty)
              followUp(context, followup!, () {
                sendAMessage(followup!, context);
              }),
            // 错误信息
            // if (error != null)
            //   Text("⚠ $error", style: const TextStyle(color: Colors.red)),
            // 底部按钮
            if (_streamCompleted && text.isNotEmpty)
              buttonForAI(text: text, index: widget.index, trace: _trace),
          ],
        ),
      ),
    );
  }
}

//加载历史气泡
class bubbleFromAi_Text extends StatelessWidget {
  const bubbleFromAi_Text({
    super.key,
    required this.text,
    required this.messageId,
    required this.index,
    this.trace,
  });

  final String messageId;
  final String text;
  final int index;
  final String? trace;
  @override
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 主体文本 ---
            Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.92,
                ),
                child: Markdown(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  data: text,
                  selectable: true,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
            ),
            //AI声明
            aiDeclaration(context),
            //底部按钮
            buttonForAI(text: text, index: index, trace: trace)
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
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                text,
                style:
                    TextUtil.base.PingFangSC.bright(context).normal.w400.sp(14),
              ),
            ),
            // 气泡下的按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //复制
                WButton(
                    child: SvgPicture.asset(
                      'assets/svg_pics/ai_icons/copy.svg',
                      width: 20.r,
                      height: 20.r,
                      colorFilter: ColorFilter.mode(
                        WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ToastProvider.success('复制成功');
                    }),
                SizedBox(width: 12.w),
                //重新发送
                WButton(
                  child: SvgPicture.asset(
                    'assets/svg_pics/ai_icons/edit.svg',
                    width: 20.r,
                    height: 20.r,
                    colorFilter: ColorFilter.mode(
                      WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
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
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: WpyTheme.of(context)
                .get(WpyColorKey.primaryActionColor)
                .withOpacity(0.4),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 4.h),
                blurRadius: 10.r,
                color: WpyTheme.of(context)
                    .get(WpyColorKey.reverseBackgroundColor)
                    .withOpacity(0.05))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部行
          Row(
            children: [
              Row(
                children: [
                  Text(
                    '信息来源  ',
                    style: TextUtil.base.label(context).PingFangSC.w500.sp(14),
                  ),
                  Text(
                    '${widget.source.length}',
                    style: TextUtil.base.label(context).PingFangSC.w600.sp(14),
                  ),
                ],
              ),
              SizedBox(width: 4.w),
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
          SizedBox(
            height: 2.h,
          ),
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
                        style: TextUtil.base.PingFangSC.w400.medium
                            .label(context)
                            .sp(12),
                        children: [
                          src.contentType == 'database'
                              ? TextSpan(
                                  text: src.title,
                                )
                              : TextSpan(
                                  text: src.title,
                                  style: TextUtil.base.PingFangSC.w400.medium
                                      .label(context)
                                      .sp(12)
                                      .copyWith(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final link = src.link;
                                      if (link.isEmpty) return;
                                      final Uri uri = Uri.parse(link);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        debugPrint('无法打开链接: $link');
                                      }
                                    },
                              ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Image.asset(
                                src.contentType == 'database'
                                    ? 'assets/images/ai/database.png'
                                    : 'assets/images/ai/form_web.png',
                                width: 12.w,
                                height: 12.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}

Widget followUp(BuildContext context, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    //发送关联问题
    child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: WpyTheme.of(context).get(WpyColorKey.lightPrimaryContainer),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 4.h),
                  blurRadius: 10.r,
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.reverseBackgroundColor)
                      .withOpacity(0.05))
            ]),
        child: RichText(
          text: TextSpan(
            style: TextUtil.base.PingFangSC.label(context).w400.medium.sp(12),
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
        )),
  );
}

Widget aiDeclaration(BuildContext context) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      // color: WpyTheme.of(context).get(WpyColorKey.elegantPostTagColor).withOpacity(0.7),
      color: Colors.transparent,
      border: Border.all(
        // color: WpyTheme.of(context).get(WpyColorKey.elegantLongPostTagColor),
        color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
        width: 1.5,
      ),
    ),
    child: Text(
      '本回答由AI生成，内容仅供参考，请仔细甄别。',
      style: TextUtil.base.label(context).PingFangSC.w500.sp(13),
    ),
  );
}

class buttonForAI extends StatelessWidget {
  const buttonForAI({super.key,required this.text,required this.index,required this.trace});
  final text;
  final index;
  final trace;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //复制
        WButton(
            child: SvgPicture.asset(
              'assets/svg_pics/ai_icons/copy.svg',
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(
                WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ToastProvider.success('复制成功');
            }
        ),
        SizedBox(width: 12.w),
        //重新生成回答
        WButton(
          child:  SvgPicture.asset(
            'assets/svg_pics/ai_icons/resend.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
              WpyTheme.of(context).get(WpyColorKey.labelTextColor),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => reSendQuestion(context,index),
        ),
        SizedBox(width: 12.w),
        //点赞
        WButton(
          child:  SvgPicture.asset(
            'assets/svg_pics/ai_icons/like.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
              WpyTheme.of(context).get(WpyColorKey.labelTextColor),
              BlendMode.srcIn,
            ),
          ),
          onPressed: (){
            final fb = FeedBack(traceId: trace, likeCount: '1');
            feedBackPost(fb);
            ToastProvider.success('点赞成功');
          },
        ),
        SizedBox(width: 12.w),
        //点踩
        WButton(
          child:  SvgPicture.asset(
            'assets/svg_pics/ai_icons/unlike.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
              WpyTheme.of(context).get(WpyColorKey.labelTextColor),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () async {
            final  Map<String,String>? result = await showFeedbackDialog(
              context,
              hint: '请输入你的意见',
            );
            if(result == null) {
              return;
            }
            final fb = FeedBack(traceId: trace, likeCount: '2',feedbackInformation: result['text'],state: result['code']);
            feedBackPost(fb);
            ToastProvider.success('反馈成功');
          },
        ),
      ],
    );
  }
}

