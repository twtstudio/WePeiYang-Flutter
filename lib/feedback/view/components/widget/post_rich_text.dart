import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 帖子正文的内联富文本渲染。在原有的 链接 / 帖子号(#MP) / 话题(#xxx) 之上，
/// 增加：@提及、基础 Markdown（**粗体** *斜体* ~~删除线~~ `代码`）、预置表情 [xxx]。
///
/// 关键点：返回 [RichSpanResult.renderedLength]——渲染后文本的字符数（UTF-16）。
/// MaskedRichText 依赖字符下标给马赛克块定位，而表情/Markdown 会改变文本长度，
/// 必须用「渲染后长度」推进下标，否则遮罩会错位。
class RichSpanResult {
  final List<InlineSpan> spans;
  final int renderedLength;

  const RichSpanResult(this.spans, this.renderedLength);
}

class PostRichText {
  /// 预置表情：短代码 → Unicode 表情。纯文本渲染，无需图片资源。
  static const Map<String, String> emojis = {
    '[微笑]': '🙂', '[呲牙]': '😁', '[偷笑]': '😏', '[大笑]': '😄', '[笑哭]': '😂',
    '[哭]': '😭', '[委屈]': '🥺', '[爱心]': '❤️', '[赞]': '👍', '[踩]': '👎',
    '[doge]': '🐶', '[滑稽]': '🙃', '[思考]': '🤔', '[吃惊]': '😲', '[怒]': '😡',
    '[ok]': '👌', '[抱抱]': '🤗', '[星星眼]': '🤩', '[汗]': '😓', '[捂脸]': '🤦',
    '[鼓掌]': '👏', '[庆祝]': '🎉', '[加油]': '💪', '[咖啡]': '☕', '[月亮]': '🌙',
    '[太阳]': '☀️', '[彩虹]': '🌈', '[问号]': '❓', '[感叹]': '❗', '[火]': '🔥',
  };

  /// 各类内联标记的统一分词器。顺序即优先级（同一起点按列出的先后匹配）。
  static final RegExp _token = RegExp(
    r'(\*\*(?=\S)(?<bold>[^*]+?)(?<=\S)\*\*)' // **粗体**
    r'|(~~(?=\S)(?<strike>.+?)(?<=\S)~~)' // ~~删除线~~
    r'|(`(?<code>[^`]+?)`)' // `代码`
    r'|(?<postref>#MP-?\d+)' // #MP123 帖子号
    r'|(?<url>https?://[^\s<]+)' // 链接
    r'|(\*(?=\S)(?<ital>[^*\n]+?)(?<=\S)\*)' // *斜体*
    r'|(?<mention>@[一-龥A-Za-z0-9_]{1,20})' // @提及
    r'|(?<emoji>\[[^\[\]\s]{1,12}\])' // [表情]
    r'|(?<topic>#[^\s#<]+)', // #话题
  );

  /// [onLink] 在点击 帖子号/链接/话题 时回调（传入原始串，由调用方决定如何跳转）。
  /// [recognizers] 由调用方持有并负责 dispose。
  static RichSpanResult build(
    BuildContext context,
    String text, {
    required TextStyle baseStyle,
    required TextStyle linkStyle,
    required TextStyle mentionStyle,
    required List<TapGestureRecognizer> recognizers,
    required void Function(String value) onLink,
  }) {
    final codeStyle = baseStyle.copyWith(
      fontFamily: 'monospace',
      background: Paint()
        ..color = (baseStyle.color ?? Colors.grey).withValues(alpha: 0.12),
    );
    return _scan(
        text, baseStyle, linkStyle, mentionStyle, codeStyle, recognizers, onLink);
  }

  static RichSpanResult _scan(
    String text,
    TextStyle base,
    TextStyle linkStyle,
    TextStyle mentionStyle,
    TextStyle codeStyle,
    List<TapGestureRecognizer> recognizers,
    void Function(String) onLink,
  ) {
    final spans = <InlineSpan>[];
    int rendered = 0;
    int last = 0;

    void addText(String s, TextStyle style) {
      if (s.isEmpty) return;
      spans.add(TextSpan(text: s, style: style));
      rendered += s.length;
    }

    // 粗体/斜体/删除线内部可能再含 @提及、表情、链接，递归处理
    void recurse(String inner, TextStyle style) {
      final r = _scan(
          inner, style, linkStyle, mentionStyle, codeStyle, recognizers, onLink);
      spans.addAll(r.spans);
      rendered += r.renderedLength;
    }

    void addLink(String value) {
      final rec = TapGestureRecognizer()..onTap = () => onLink(value);
      recognizers.add(rec);
      spans.add(TextSpan(text: value, style: linkStyle, recognizer: rec));
      rendered += value.length;
    }

    for (final m in _token.allMatches(text)) {
      if (m.start > last) addText(text.substring(last, m.start), base);
      String? g;
      if ((g = m.namedGroup('bold')) != null) {
        recurse(g!, base.copyWith(fontWeight: FontWeight.bold));
      } else if ((g = m.namedGroup('strike')) != null) {
        recurse(g!, base.copyWith(decoration: TextDecoration.lineThrough));
      } else if ((g = m.namedGroup('ital')) != null) {
        recurse(g!, base.copyWith(fontStyle: FontStyle.italic));
      } else if ((g = m.namedGroup('code')) != null) {
        addText(g!, codeStyle);
      } else if ((g = m.namedGroup('postref')) != null) {
        addLink(g!);
      } else if ((g = m.namedGroup('url')) != null) {
        addLink(g!);
      } else if ((g = m.namedGroup('topic')) != null) {
        addLink(g!);
      } else if ((g = m.namedGroup('mention')) != null) {
        // 高亮但不跳转：从纯文本无法可靠解析到用户 uid
        addText(g!, mentionStyle);
      } else if ((g = m.namedGroup('emoji')) != null) {
        addText(emojis[g!] ?? g!, base);
      }
      last = m.end;
    }
    if (last < text.length) addText(text.substring(last), base);
    return RichSpanResult(spans, rendered);
  }
}
