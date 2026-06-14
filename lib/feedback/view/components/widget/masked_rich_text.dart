import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/SpoilerMask.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/post_rich_text.dart';

/// 文字马赛克标签，发帖时用它包裹要打码的文字
const String kMaskOpenTag = '<mask>';
const String kMaskCloseTag = '</mask>';

final RegExp _maskReg = RegExp(r'<mask>(.*?)</mask>', dotAll: true);

/// 输入框里识别 @uid:123 提及，用于「未编辑时按渲染样式显示」。
final RegExp _mentionUidReg = RegExp(r'@uid:\d+');

/// 去掉 mask 标签，用于测量行数和统计字数
String stripMaskTags(String text) =>
    text.replaceAll(kMaskOpenTag, '').replaceAll(kMaskCloseTag, '');

bool hasMask(String text) => text.contains(kMaskOpenTag);

/// 一段被马赛克遮住的文字在去标签后的纯文本里的字符区间
class _MaskRange {
  final int index;
  final int start;
  final int end;

  const _MaskRange(this.index, this.start, this.end);
}

class MaskedRichText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLine;
  final double fontSize;

  /// 是否可交互（粒子动画 + 点击揭开）。列表缩略预览传 false，用静态遮挡块即可。
  final bool interactive;

  const MaskedRichText({
    super.key,
    required this.text,
    required this.style,
    this.maxLine = 100,
    this.fontSize = 16,
    this.interactive = true,
  });

  @override
  State<MaskedRichText> createState() => _MaskedRichTextState();
}

class _MaskedRichTextState extends State<MaskedRichText>
    with SingleTickerProviderStateMixin {
  /// 已经被点开的遮罩段
  final Set<int> _revealed = {};
  final List<TapGestureRecognizer> _recognizers = [];

  late final AnimationController _revealCtrl;

  /// 正在做揭开动画的遮罩段
  int? _animSeg;
  Offset? _animCenter;
  List<Rect> _animRects = const [];
  double _animRadius = 0;
  double _animMaxRadius = 0;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320))
      ..addListener(() {
        setState(() => _animRadius = _revealCtrl.value * _animMaxRadius);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            if (_animSeg != null) _revealed.add(_animSeg!);
            _resetAnim();
          });
        }
      });
    _syncMentionListener(null);
  }

  /// 含 @uid: 提及时才监听昵称解析，解析到后重渲染把 uid 换成昵称
  void _syncMentionListener(String? oldText) {
    final had = oldText?.contains('@uid:') ?? false;
    final has = widget.text.contains('@uid:');
    if (had == has) return;
    if (has) {
      MentionNames.instance.addListener(_onMentionNames);
    } else {
      MentionNames.instance.removeListener(_onMentionNames);
    }
  }

  void _onMentionNames() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant MaskedRichText old) {
    super.didUpdateWidget(old);
    // 列表里 State 会被复用，正文一变就要清掉上一条帖子的揭开状态
    if (old.text != widget.text) {
      _revealed.clear();
      if (_revealCtrl.isAnimating) _revealCtrl.stop();
      _resetAnim();
      _syncMentionListener(old.text);
    }
  }

  void _resetAnim() {
    _animSeg = null;
    _animCenter = null;
    _animRects = const [];
    _animRadius = 0;
  }

  @override
  void dispose() {
    MentionNames.instance.removeListener(_onMentionNames);
    _revealCtrl.dispose();
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) r.dispose();
    _recognizers.clear();
  }

  void _startReveal(int seg, Offset center, List<Rect> rects) {
    if (_revealCtrl.isAnimating) return;
    _animSeg = seg;
    _animCenter = center;
    _animRects = rects;
    _animRadius = 0;
    // 半径要够大，能从点击点覆盖到这一段所有矩形的最远角
    double maxR = 0;
    for (final r in rects) {
      for (final c in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
        maxR = maxR < (c - center).distance ? (c - center).distance : maxR;
      }
    }
    _animMaxRadius = maxR + 4;
    _revealCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final style = widget.style.NotoSansSC.w400.sp(widget.fontSize);
    final linkStyle = widget.style.link(context).w500.sp(widget.fontSize);
    final mentionStyle = style.copyWith(
        color: WpyTheme.of(context).primary ?? linkStyle.color,
        fontWeight: FontWeight.w600);

    // 把正文拆成真实的 TextSpan（遮罩段也是真实文字，只是上面会盖一层），
    // 同时记录每个遮罩段在纯文本里的字符区间，供 getBoxesForSelection 用。
    final spans = <InlineSpan>[];
    final ranges = <_MaskRange>[];
    int plain = 0;
    int last = 0;
    int seg = 0;
    for (final m in _maskReg.allMatches(widget.text)) {
      if (m.start > last) {
        final chunk = widget.text.substring(last, m.start);
        final res = PostRichText.build(context, chunk,
            baseStyle: style,
            linkStyle: linkStyle,
            mentionStyle: mentionStyle,
            recognizers: _recognizers,
            onLink: _onTapLink,
            onMention: (uid) => PostRichText.openPerson(context, uid));
        spans.addAll(res.spans);
        // 用渲染后长度推进，保证 mask 区间下标与实际渲染文本对齐
        plain += res.renderedLength;
      }
      final inner = m.group(1) ?? '';
      // 被遮住时文字不渲染（透明），点开或正在揭开的那一段才显示真实文字
      final visible = _revealed.contains(seg) || _animSeg == seg;
      spans.add(TextSpan(
        text: inner,
        style: visible ? style : style.copyWith(color: Colors.transparent),
      ));
      ranges.add(_MaskRange(seg++, plain, plain + inner.length));
      plain += inner.length;
      last = m.end;
    }
    if (last < widget.text.length) {
      final chunk = widget.text.substring(last);
      final res = PostRichText.build(context, chunk,
          baseStyle: style,
          linkStyle: linkStyle,
          mentionStyle: mentionStyle,
          recognizers: _recognizers,
          onLink: _onTapLink,
          onMention: (uid) => PostRichText.openPerson(context, uid));
      spans.addAll(res.spans);
      plain += res.renderedLength;
    }

    final rootSpan = TextSpan(style: style, children: spans);
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(builder: (context, constraints) {
      // 用一个布局参数完全一致的 TextPainter 复算出遮罩文字的字形矩形。
      // 文字换行时同一段会得到多个矩形（每行一个），逐个盖遮罩即可实现换行。
      final painter = TextPainter(
        text: rootSpan,
        textDirection: TextDirection.ltr,
        maxLines: widget.maxLine,
        textScaler: textScaler,
      )..layout(maxWidth: constraints.maxWidth);

      // 收集所有未揭开遮罩段的矩形
      final coverRects = <Rect>[];
      final segRectsByIndex = <int, List<Rect>>{};
      for (final r in ranges) {
        if (_revealed.contains(r.index)) continue;
        final rects = painter
            .getBoxesForSelection(
              TextSelection(baseOffset: r.start, extentOffset: r.end),
              boxHeightStyle: ui.BoxHeightStyle.max,
              boxWidthStyle: ui.BoxWidthStyle.max,
            )
            .map((b) => b.toRect())
            .where((rect) => rect.width > 0 && rect.height > 0)
            .toList();
        if (rects.isEmpty) continue;
        coverRects.addAll(rects);
        segRectsByIndex[r.index] = rects;
      }
      final textHeight = painter.height;
      painter.dispose();

      final children = <Widget>[
        // 底层：真实文字，自动换行，链接照常可点
        RichText(
          text: rootSpan,
          maxLines: widget.maxLine,
          overflow: TextOverflow.ellipsis,
          textScaler: textScaler,
        ),
      ];

      if (coverRects.isNotEmpty) {
        children.add(Positioned.fill(
          child: IgnorePointer(
            child: ClipPath(
              clipper: _SpoilerClipper(
                cover: coverRects,
                revealCenter: _animCenter,
                revealRects: _animRects,
                revealRadius: _animRadius,
              ),
              child: ParticleSimulation(
                width: constraints.maxWidth,
                height: textHeight,
                particleCount: _particleCount(coverRects),
                maxParticleSize: 1.2,
                maxParticleSpeed: 0.6,
                particleColor: style.color,
              ),
            ),
          ),
        ));
        // 静态预览不需要点击
        if (widget.interactive) {
          segRectsByIndex.forEach((index, rects) {
            for (final rect in rects) {
              children.add(Positioned.fromRect(
                rect: rect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) =>
                      _startReveal(index, rect.topLeft + d.localPosition, rects),
                ),
              ));
            }
          });
        }
      }

      return Stack(clipBehavior: Clip.none, children: children);
    });
  }

  int _particleCount(List<Rect> rects) {
    double area = 0;
    for (final r in rects) area += r.width * r.height;
    return (area / 28).round().clamp(16, 320);
  }

  void _onTapLink(String value) {
    if (PostRichText.isPostRef(value)) {
      _checkPostId(PostRichText.postRefId(value));
    } else if (value.startsWith('http')) {
      _checkUrl(value);
    } else if (value.startsWith('#')) {
      PostRichText.openTagSearch(context, value);
    } else {
      ToastProvider.error('无效的帖子编号！');
    }
  }

  bool _checkBili(String url) =>
      url.contains('b23.tv') || url.contains('bilibili.com');

  void _checkPostId(String id) {
    FeedbackService.getPostById(
      id: int.parse(id),
      onResult: (post) {
        Navigator.pushNamed(context, FeedbackRouter.detail, arguments: post);
      },
      onFailure: (e) {
        ToastProvider.error('无法找到对应帖子，报错信息：${e.error}');
        return;
      },
    );
  }

  void _checkUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LakeDialogWidget(
                title: '天外天工作室提示您',
                titleTextStyle: TextUtil.base.normal
                    .infoText(context)
                    .NotoSansSC
                    .sp(22)
                    .w600,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' 你即将离开微北洋，去往：',
                      style: TextStyle(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.basicTextColor)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 6),
                      child: Text(url,
                          style: _checkBili(url)
                              ? TextUtil.base.NotoSansSC
                                  .biliPink(context)
                                  .w600
                                  .h(1.6)
                              : TextUtil.base.NotoSansSC
                                  .link(context)
                                  .w600
                                  .h(1.6)),
                    ),
                    Text(
                      ' 请注意您的账号和财产安全\n',
                      style: TextStyle(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.basicTextColor)),
                    ),
                  ],
                ),
                cancelText: "取消",
                confirmTextStyle:
                    TextUtil.base.normal.bright(context).NotoSansSC.sp(16).w600,
                confirmButtonColor: _checkBili(url)
                    ? WpyTheme.of(context).get(WpyColorKey.biliPink)
                    : WpyTheme.of(context)
                        .get(WpyColorKey.primaryTextButtonColor),
                cancelTextStyle:
                    TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
                confirmText: "继续",
                cancelFun: () {
                  Navigator.pop(context);
                },
                confirmFun: () async {
                  await launchUrl(Uri.parse(url),
                      mode: _checkBili(url)
                          ? LaunchMode.externalNonBrowserApplication
                          : LaunchMode.externalApplication);
                  Navigator.pop(context);
                });
          });
    } else {
      ToastProvider.error('请检查网址是否有误或检查网络状态');
    }
  }
}

/// 把遮罩层裁到所有未揭开矩形的并集；揭开动画进行时，从点击点扩散一个圆
/// 并只在被点的那一段范围内挖掉，做出波纹消散的效果。
class _SpoilerClipper extends CustomClipper<Path> {
  final List<Rect> cover;
  final Offset? revealCenter;
  final List<Rect> revealRects;
  final double revealRadius;

  const _SpoilerClipper({
    required this.cover,
    required this.revealCenter,
    required this.revealRects,
    required this.revealRadius,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    for (final r in cover) path.addRect(r);

    if (revealCenter != null && revealRadius > 0 && revealRects.isNotEmpty) {
      final circle = Path()
        ..addOval(Rect.fromCircle(center: revealCenter!, radius: revealRadius));
      final segPath = Path();
      for (final r in revealRects) segPath.addRect(r);
      final hole = Path.combine(PathOperation.intersect, circle, segPath);
      path = Path.combine(PathOperation.difference, path, hole);
    }
    return path;
  }

  @override
  bool shouldReclip(_SpoilerClipper old) {
    return old.revealRadius != revealRadius ||
        old.revealCenter != revealCenter ||
        old.cover.length != cover.length;
  }
}

/// 发帖/评论输入框用的 controller：把 <mask>…</mask> 的标签淡化，
/// 让用户在输入时就能看出哪段会被打码。
///
/// [hideMasked] 为 true 时把被遮文字渲染成透明（配合 [MaskInputParticles] 在
/// 上面盖粒子，做出 Telegram 那种边输入边马赛克的效果）；为 false 时用灰底高亮，
/// 文字仍可见，适合没有粒子层的输入框。
class MaskTextEditingController extends TextEditingController {
  final bool hideMasked;

  MaskTextEditingController({super.text, this.hideMasked = false});

  @override
  set value(TextEditingValue newValue) {
    final old = value;
    var v = _repairMaskEdit(old, newValue);
    v = _autoExpandMention(old, v);
    super.value = v;
  }

  /// 在输入框里键入「@」时，自动展开成「@uid:」，让用户接着输入 uid。
  /// 只在行首或空白后触发，避免邮箱等被误展开。删除时按字符逐个删，
  /// 所以用户可以退格回单独的「@」、或删干净「不 @」。
  TextEditingValue _autoExpandMention(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    if (!newValue.composing.isCollapsed) return newValue;
    // 仅处理「插入了单个字符」且为 @ 的情况
    if (newText.length != oldText.length + 1) return newValue;
    final sel = newValue.selection;
    if (!sel.isCollapsed) return newValue;
    final caret = sel.baseOffset;
    if (caret <= 0 || caret > newText.length) return newValue;
    if (newText[caret - 1] != '@') return newValue;
    // 确认是「插入」而非替换：去掉这个 @ 后应与旧文本一致
    final without =
        newText.substring(0, caret - 1) + newText.substring(caret);
    if (without != oldText) return newValue;
    // 只在行首/空白后触发
    if (caret - 1 > 0) {
      final prev = newText[caret - 2];
      if (prev != ' ' && prev != '\n' && prev != '\t') return newValue;
    }
    const insert = '@uid:';
    final expanded =
        newText.substring(0, caret - 1) + insert + newText.substring(caret);
    return TextEditingValue(
      text: expanded,
      selection: TextSelection.collapsed(offset: caret - 1 + insert.length),
    );
  }

  /// 把 <mask>…</mask> 当作一个整体处理：当一次删除“吃”到了不可见的标签字符上
  /// （例如在马赛克块边缘退格），就把整段 mask 一起删掉，而不是留下半个损坏的
  /// 标签。这样用户感知到的就是「mask 被整体删除」。块内文字的正常增删不受影响。
  TextEditingValue _repairMaskEdit(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    // 文本未变（仅移动光标）、原文没有 mask、或正在输入法组词时，直接放行
    if (newText == oldText ||
        !hasMask(oldText) ||
        !newValue.composing.isCollapsed) {
      return newValue;
    }

    // 计算 old→new 的最小改动区间：old[start, oldEnd) 被替换为 new[start, newEnd)
    final minLen =
        oldText.length < newText.length ? oldText.length : newText.length;
    int start = 0;
    while (start < minLen && oldText[start] == newText[start]) start++;
    int oldEnd = oldText.length;
    int newEnd = newText.length;
    while (oldEnd > start &&
        newEnd > start &&
        oldText[oldEnd - 1] == newText[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    // 只处理“纯删除”：插入/替换（含输入法上屏）保持原生行为
    if (newEnd != start) return newValue;

    // 改动区间是否吃到了某个 mask 块的标签字符；若是，整块一起删
    int delStart = start, delEnd = oldEnd;
    bool touchedTag = false;
    for (final m in _maskReg.allMatches(oldText)) {
      final openEnd = m.start + kMaskOpenTag.length;
      final closeStart = m.end - kMaskCloseTag.length;
      final hitOpen = m.start < oldEnd && start < openEnd;
      final hitClose = closeStart < oldEnd && start < m.end;
      if (hitOpen || hitClose) {
        touchedTag = true;
        if (m.start < delStart) delStart = m.start;
        if (m.end > delEnd) delEnd = m.end;
      }
    }
    if (!touchedTag) return newValue;

    final repaired = oldText.substring(0, delStart) + oldText.substring(delEnd);
    return TextEditingValue(
      text: repaired,
      selection: TextSelection.collapsed(offset: delStart),
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final base = style ?? const TextStyle();
    // 中文输入法 composing 阶段交回默认实现，避免破坏候选下划线
    if (withComposing &&
        value.isComposingRangeValid &&
        !value.composing.isCollapsed) {
      return super
          .buildTextSpan(context: context, style: style, withComposing: true);
    }

    // 标签彻底隐藏：透明 + 近似 0 字号，不留可见空隙
    final tagStyle = base.copyWith(
      color: Colors.transparent,
      fontSize: 0.01,
      letterSpacing: 0,
    );
    // 被遮文字默认不可见（hideMasked，靠上层粒子盖）或灰底高亮（无粒子层时）
    final hiddenStyle = hideMasked
        ? base.copyWith(color: Colors.transparent)
        : base.copyWith(
            background: Paint()
              ..color = (base.color ?? Colors.grey).withValues(alpha: 0.18));
    // 光标落在这一段里时：露出淡淡的文字 + 一点底色，方便编辑
    final activeStyle = base.copyWith(
      color: (base.color ?? Colors.black).withValues(alpha: 0.5),
      background: Paint()
        ..color = (base.color ?? Colors.grey).withValues(alpha: 0.1),
    );

    final cursor =
        value.selection.isValid ? value.selection.extentOffset : null;

    final spans = <InlineSpan>[];
    final t = text;
    int last = 0;
    for (final m in _maskReg.allMatches(t)) {
      if (m.start > last) {
        _appendMentionStyled(
            t.substring(last, m.start), last, base, tagStyle, cursor, context, spans);
      }
      final active = cursor != null && cursor >= m.start && cursor <= m.end;
      spans.add(TextSpan(text: kMaskOpenTag, style: tagStyle));
      spans.add(TextSpan(
          text: m.group(1), style: active ? activeStyle : hiddenStyle));
      spans.add(TextSpan(text: kMaskCloseTag, style: tagStyle));
      last = m.end;
    }
    if (last < t.length) {
      _appendMentionStyled(
          t.substring(last), last, base, tagStyle, cursor, context, spans);
    }
    return TextSpan(style: base, children: spans);
  }

  /// 在非 mask 文本里把 @uid:123 按「渲染样式」显示：未编辑时 uid: 隐藏、整体变色
  /// （看起来像 @123 的提及）；光标落在其中时还原成可编辑的 @uid:123。
  /// 不改变字符数量，保证 TextField 光标定位正确（与 mask 同理）。
  void _appendMentionStyled(String chunk, int chunkStart, TextStyle base,
      TextStyle tagStyle, int? cursor, BuildContext context, List<InlineSpan> out) {
    final mentionStyle = base.copyWith(
        color: WpyTheme.of(context).primary ?? base.color,
        fontWeight: FontWeight.w600);
    int last = 0;
    for (final m in _mentionUidReg.allMatches(chunk)) {
      if (m.start > last) {
        out.add(TextSpan(text: chunk.substring(last, m.start), style: base));
      }
      final gStart = chunkStart + m.start;
      final gEnd = chunkStart + m.end;
      final active = cursor != null && cursor >= gStart && cursor <= gEnd;
      if (active) {
        out.add(TextSpan(text: m.group(0), style: base));
      } else {
        out.add(TextSpan(text: '@', style: mentionStyle));
        out.add(TextSpan(text: 'uid:', style: tagStyle));
        out.add(TextSpan(text: m.group(0)!.substring(5), style: mentionStyle));
      }
      last = m.end;
    }
    if (last < chunk.length) {
      out.add(TextSpan(text: chunk.substring(last), style: base));
    }
  }
}

/// 盖在输入框上的粒子层：跟随 [controller] 的文字，实时在 <mask> 区间画粒子，
/// 实现「文字还在输入框里就被马赛克」的效果。需要和 [MaskTextEditingController]
/// (hideMasked: true) 一起用，并 Stack 在 TextField 上方（外面套 IgnorePointer）。
///
/// [padding] 要和 TextField 的 contentPadding 一致，[style] 要和 TextField 的
/// style 一致，否则粒子和文字对不齐。
class MaskInputParticles extends StatefulWidget {
  final TextEditingController controller;
  final TextStyle style;
  final EdgeInsets padding;

  const MaskInputParticles({
    super.key,
    required this.controller,
    required this.style,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<MaskInputParticles> createState() => _MaskInputParticlesState();
}

class _MaskInputParticlesState extends State<MaskInputParticles> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant MaskInputParticles old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    if (!hasMask(text)) return const SizedBox.shrink();

    final cursor = widget.controller.value.selection.isValid
        ? widget.controller.value.selection.extentOffset
        : null;

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(builder: (context, constraints) {
        // 用 controller 实际渲染的 span（标签已缩成近 0 字号）来测量，保证对齐
        final painter = TextPainter(
          text: widget.controller.buildTextSpan(
              context: context, style: widget.style, withComposing: false),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        final rects = <Rect>[];
        for (final m in _maskReg.allMatches(text)) {
          // 光标在这一段里时不盖粒子，露出文字给用户编辑
          if (cursor != null && cursor >= m.start && cursor <= m.end) continue;
          // 被遮文字在整段（含标签）里的字符区间
          final start = m.start + kMaskOpenTag.length;
          final end = m.end - kMaskCloseTag.length;
          if (end <= start) continue;
          rects.addAll(painter
              .getBoxesForSelection(
                TextSelection(baseOffset: start, extentOffset: end),
                boxHeightStyle: ui.BoxHeightStyle.max,
                boxWidthStyle: ui.BoxWidthStyle.max,
              )
              .map((b) => b.toRect())
              .where((r) => r.width > 0 && r.height > 0));
        }
        final height = painter.height;
        painter.dispose();
        if (rects.isEmpty) return const SizedBox.shrink();

        double area = 0;
        for (final r in rects) area += r.width * r.height;

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: ClipPath(
            clipper: _SpoilerClipper(
              cover: rects,
              revealCenter: null,
              revealRects: const [],
              revealRadius: 0,
            ),
            child: ParticleSimulation(
              width: constraints.maxWidth,
              height: height,
              particleCount: (area / 28).round().clamp(16, 320),
              maxParticleSize: 1.2,
              maxParticleSpeed: 0.6,
              particleColor: widget.style.color,
            ),
          ),
        );
      }),
    );
  }
}
