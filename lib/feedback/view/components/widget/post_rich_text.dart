import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/person_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';

/// 把 @uid:123 里的 uid 解析成昵称的缓存。
///
/// 当前后端没有「按 uid 查昵称」的公开接口（posts/user 属于 b 端、需管理员权限，
/// 不能用），所以这里只预留一个 [resolver] 钩子：等正式接口就绪后，外部赋值
/// 即可，例如
/// ```
/// MentionNames.instance.resolver = (uid) => SomeService.nicknameByUid(uid);
/// ```
/// 未设置 [resolver] 时，@uid:123 就原样显示成 @123。解析到昵称后会 notify，
/// 让正在显示 @提及 的文本重新渲染、把 uid 换成昵称。
class MentionNames extends ChangeNotifier {
  MentionNames._();

  static final MentionNames instance = MentionNames._();

  /// 待接入：uid → 昵称（解析不到返回 null）。
  Future<String?> Function(String uid)? resolver;

  final Map<String, String> _cache = {};
  final Set<String> _inFlight = {};

  /// 同步取昵称缓存；没有时返回 null，并在后台发起一次解析（若已配置 resolver）。
  String? nameOf(String uid) {
    final cached = _cache[uid];
    if (cached != null) return cached;
    _ensure(uid);
    return null;
  }

  void _ensure(String uid) {
    final r = resolver;
    if (r == null || _inFlight.contains(uid) || _cache.containsKey(uid)) return;
    _inFlight.add(uid);
    r(uid).then((name) {
      _inFlight.remove(uid);
      if (name != null && name.isNotEmpty) {
        _cache[uid] = name;
        notifyListeners();
      }
    }).catchError((_) {
      _inFlight.remove(uid);
    });
  }
}

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

/// Inline sticker rendered with Flutter's built-in WidgetSpan.
class StickerImageSpan extends WidgetSpan {
  final Size imageSize;

  StickerImageSpan({required String asset, required this.imageSize})
      : super(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox.fromSize(
            size: imageSize,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        );
}

class PostRichText {
  /// 预置表情：短代码 → Unicode 表情。纯文本渲染，无需图片资源。
  static const Map<String, String> emojis = {
    '[微笑]': '🙂',
    '[呲牙]': '😁',
    '[偷笑]': '😏',
    '[大笑]': '😄',
    '[笑哭]': '😂',
    '[哭]': '😭',
    '[委屈]': '🥺',
    '[爱心]': '❤️',
    '[赞]': '👍',
    '[踩]': '👎',
    '[doge]': '🐶',
    '[滑稽]': '🙃',
    '[思考]': '🤔',
    '[吃惊]': '😲',
    '[怒]': '😡',
    '[ok]': '👌',
    '[抱抱]': '🤗',
    '[星星眼]': '🤩',
    '[汗]': '😓',
    '[捂脸]': '🤦',
    '[鼓掌]': '👏',
    '[庆祝]': '🎉',
    '[加油]': '💪',
    '[咖啡]': '☕',
    '[月亮]': '🌙',
    '[太阳]': '☀️',
    '[彩虹]': '🌈',
    '[问号]': '❓',
    '[感叹]': '❗',
    '[火]': '🔥',
  };

  static const Map<String, String> stickerAssets = {
    '[w1_happy]': 'assets/images/emojis/wpn/w1_happy.png',
    '[w2_yay]': 'assets/images/emojis/wpn/w2_yay.png',
    '[w3_wordless]': 'assets/images/emojis/wpn/w3_wordless.png',
    '[w4_sleepy]': 'assets/images/emojis/wpn/w4_sleepy.png',
    '[w5_angry]': 'assets/images/emojis/wpn/w5_angry.png',
    '[w6_amazed]': 'assets/images/emojis/wpn/w6_amazed.png',
    '[w7_love]': 'assets/images/emojis/wpn/w7_love.png',
    '[w8_confused]': 'assets/images/emojis/wpn/w8_confused.png',
    '[w9_cool]': 'assets/images/emojis/wpn/w9_cool.png',
    '[c1_smile]': 'assets/images/emojis/cloud/c1_smile.png',
    '[c2_wink]': 'assets/images/emojis/cloud/c2_wink.png',
    '[c3_laugh]': 'assets/images/emojis/cloud/c3_laugh.png',
    '[c4_sleepy]': 'assets/images/emojis/cloud/c4_sleepy.png',
    '[c5_angry]': 'assets/images/emojis/cloud/c5_angry.png',
    '[c6_surprised]': 'assets/images/emojis/cloud/c6_surprised.png',
    '[c7_happy]': 'assets/images/emojis/cloud/c7_happy.png',
    '[c8_sad]': 'assets/images/emojis/cloud/c8_sad.png',
    '[c9_cool]': 'assets/images/emojis/cloud/c9_cool.png',
  };

  static final String _knownStickerPattern =
      stickerAssets.keys.map(RegExp.escape).join('|');

  static final RegExp stickerToken = RegExp(_knownStickerPattern);

  static final String _knownEmojiPattern =
      [...emojis.keys, ...stickerAssets.keys].map(RegExp.escape).join('|');

  static int countCharacters(String text) {
    var count = 0;
    var offset = 0;
    for (final match in stickerToken.allMatches(text)) {
      count += text.substring(offset, match.start).characters.length + 1;
      offset = match.end;
    }
    return count + text.substring(offset).characters.length;
  }

  static StickerImageSpan stickerImageSpan(
    String shortcode,
    TextStyle style, {
    int start = 0,
  }) {
    final size = (style.fontSize ?? 14) * 1.45;
    return StickerImageSpan(
      asset: stickerAssets[shortcode]!,
      imageSize: Size(size + 2, size),
    );
  }

  /// Converts sticker shortcodes to inline image spans while preserving source
  /// offsets for editable fields and rendered offsets for text selection.
  static RichSpanResult buildStickerSpans(
    String text,
    TextStyle style, {
    int sourceOffset = 0,
    bool preserveSourceLength = false,
  }) {
    final spans = <InlineSpan>[];
    var renderedLength = 0;
    var last = 0;
    for (final match in stickerToken.allMatches(text)) {
      if (match.start > last) {
        final plain = text.substring(last, match.start);
        spans.add(TextSpan(text: plain, style: style));
        renderedLength += plain.length;
      }
      final shortcode = match.group(0)!;
      spans.add(stickerImageSpan(
        shortcode,
        style,
        start: sourceOffset + match.start,
      ));
      if (preserveSourceLength) {
        spans.add(TextSpan(
          text: shortcode.substring(1),
          style: style.copyWith(
            color: Colors.transparent,
            fontSize: 0.01,
            height: 0.01,
            letterSpacing: 0,
          ),
        ));
        renderedLength += shortcode.length;
      } else {
        renderedLength++;
      }
      last = match.end;
    }
    if (last < text.length) {
      final plain = text.substring(last);
      spans.add(TextSpan(text: plain, style: style));
      renderedLength += plain.length;
    }
    return RichSpanResult(spans, renderedLength);
  }

  /// Replace known sticker tokens inside an existing rich-text tree, such as
  /// HTML formatted official comments, while retaining the surrounding styles.
  static InlineSpan renderStickersInSpan(
    InlineSpan span, {
    required TextStyle fallbackStyle,
  }) {
    if (span is! TextSpan) return span;

    final children = <InlineSpan>[];
    var changed = false;
    if (span.text != null) {
      final pieces = buildStickerSpans(
        span.text!,
        span.style ?? fallbackStyle,
      ).spans;
      changed = pieces.any((piece) => piece is StickerImageSpan);
      for (final piece in pieces) {
        if (piece is TextSpan && span.recognizer != null) {
          children.add(TextSpan(
            text: piece.text,
            style: piece.style,
            recognizer: span.recognizer,
            mouseCursor: span.mouseCursor,
            onEnter: span.onEnter,
            onExit: span.onExit,
          ));
        } else {
          children.add(piece);
        }
      }
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      final rendered = renderStickersInSpan(
        child,
        fallbackStyle: span.style ?? fallbackStyle,
      );
      changed = changed || !identical(rendered, child);
      children.add(rendered);
    }
    if (!changed) return span;

    return TextSpan(
      style: span.style,
      children: children,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  /// 各类内联标记的统一分词器。顺序即优先级（同一起点按列出的先后匹配）。
  static final RegExp _token = RegExp(
    r'(\*\*(?=\S)(?<bold>[^*]+?)(?<=\S)\*\*)'
    r'|(~~(?=\S)(?<strike>.+?)(?<=\S)~~)'
    r'|(`(?<code>[^`]+?)`)'
    r'|(?<postref>#[Mm][Pp]-?\d+)'
    r'''|(?<url>https?://[^\s<>"'，。！？；：、”’」』》〉]+)'''
    r'|(\*(?=\S)(?<ital>[^*\n]+?)(?<=\S)\*)'
    r'|(?<mentionuid>@uid:\d+)'
    '|(?<emoji>$_knownEmojiPattern)'
    r'|(?<topic>#[^\s#<]+)',
  );

  /// 从正则命中的候选串中裁掉句末标点和未配对的右括号
  static String _normalizeUrl(String candidate) {
    const opening = {
      '(': ')',
      '[': ']',
      '{': '}',
      '（': '）',
      '【': '】',
      '《': '》'
    };
    const closing = {
      ')': '(',
      ']': '[',
      '}': '{',
      '）': '（',
      '】': '【',
      '》': '《'
    };
    final brackets = <String>[];
    var end = candidate.length;

    for (var i = 0; i < candidate.length; i++) {
      final char = candidate[i];
      if (opening.containsKey(char)) {
        brackets.add(char);
      } else if (closing.containsKey(char)) {
        if (brackets.isEmpty || brackets.last != closing[char]) {
          end = i;
          break;
        }
        brackets.removeLast();
      }
    }

    // 普通域名后直接连接中文正文时，在首个中文字符前结束链接；中文路径仍然允许。
    final authorityStart = candidate.indexOf('://') + 3;
    final separator = candidate.indexOf(RegExp(r'[/#?]'), authorityStart);
    final authorityEnd = separator < 0 ? candidate.length : separator;
    final Chinese = RegExp(r'[\u3400-\u9fff]')
        .firstMatch(candidate.substring(authorityStart, authorityEnd));
    if (Chinese != null) {
      final ChineseStart = authorityStart + Chinese.start;
      if (ChineseStart < end) end = ChineseStart;
    }

    const trailingPunctuation = '.,!?;:';
    while (end > 0 && trailingPunctuation.contains(candidate[end - 1])) {
      end--;
    }
    return candidate.substring(0, end);
  }

  static bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  /// @uid:123 的展示文本：解析到昵称就显示 @昵称，否则暂时显示 @uid
  /// （解析完成后 [MentionNames] 会通知监听者重渲染）。
  static String mentionLabel(String uid) =>
      '@${MentionNames.instance.nameOf(uid) ?? uid}';

  /// 点击 @uid:123 时跳转到该用户主页（仅凭 uid）。
  static void openPerson(BuildContext context, String uid) {
    final id = int.tryParse(uid);
    if (id == null) return;
    Navigator.pushNamed(
      context,
      FeedbackRouter.person,
      // postOrCommentId 传 0 → PersonPage 进入「仅 uid」模式，不去按帖子/楼层拉头部
      arguments: PersonPageArgs(0, true, 0, id, '', '', '0', 'mention_$uid'),
    );
  }

  /// 是否是帖子号 #MP123（大小写无关）。
  static bool isPostRef(String value) =>
      value.length > 3 &&
      value.substring(0, 3).toUpperCase() == '#MP' &&
      RegExp(r'^-?\d+$').hasMatch(value.substring(3));

  /// 帖子号里的数字部分（含可能的负号），如 #mp-12 → "-12"。
  static String postRefId(String value) => value.substring(3);

  /// 点击 #xxx：先把名字解析成标签 id，按「标签」搜索该 tag（而不是搜索这段文字）；
  /// 找不到同名标签时再退回到对正文的模糊文字搜索。[tag] 可带或不带开头的 '#'。
  static void openTagSearch(BuildContext context, String tag) {
    final t = tag.startsWith('#') ? tag.substring(1) : tag;
    if (t.isEmpty) return;
    final nav = Navigator.of(context);

    void byTag(int id) => nav.pushNamed(
          FeedbackRouter.searchResult,
          arguments: SearchResultPageArgs('', '$id', '', '标签 #$t', 0, 0),
        );
    void byText() => nav.pushNamed(
          FeedbackRouter.searchResult,
          arguments: SearchResultPageArgs(t, '', '', '模糊搜索#$t', 2, 0),
        );

    FeedbackService.searchTags(
      name: t,
      onResult: (List<SearchTag> tags) {
        SearchTag? exact;
        for (final tg in tags) {
          if (tg.name.toLowerCase() == t.toLowerCase()) {
            exact = tg;
            break;
          }
        }
        if (exact != null) {
          byTag(exact.id);
        } else {
          byText();
        }
      },
      onFailure: (_) => byText(),
    );
  }

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
    required void Function(String uid) onMention,
  }) {
    final codeStyle = baseStyle.copyWith(
      fontFamily: 'monospace',
      background: Paint()
        ..color = (baseStyle.color ?? Colors.grey).withValues(alpha: 0.12),
    );
    return _scan(text, baseStyle, linkStyle, mentionStyle, codeStyle,
        recognizers, onLink, onMention);
  }

  static RichSpanResult _scan(
    String text,
    TextStyle base,
    TextStyle linkStyle,
    TextStyle mentionStyle,
    TextStyle codeStyle,
    List<TapGestureRecognizer> recognizers,
    void Function(String) onLink,
    void Function(String) onMention,
  ) {
    final spans = <InlineSpan>[];
    int rendered = 0;
    int last = 0;

    void addText(String s, TextStyle style) {
      if (s.isEmpty) return;
      spans.add(TextSpan(text: s, style: style));
      rendered += s.length;
    }

    // 26.8.6 暂时注释 Markdown 相关（与屏蔽词相关功能冲突，等待后端协调 --26.8.6）：
    // 粗体/斜体/删除线内部可能再含 @提及、表情、链接，递归处理
    // void recurse(String inner, TextStyle style) {
    //   final r = _scan(inner, style, linkStyle, mentionStyle, codeStyle,
    //       recognizers, onLink, onMention);
    //   spans.addAll(r.spans);
    //   rendered += r.renderedLength;
    // }

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
        // 26.8.6 暂时注释部分 Markdown 渲染（与屏蔽词相关功能冲突，等待后端协调 --26.8.6）：
        // recurse(g!, base.copyWith(fontWeight: FontWeight.bold));
        addText(m.group(0)!, base);
      } else if ((g = m.namedGroup('strike')) != null) {
        // recurse(g!, base.copyWith(decoration: TextDecoration.lineThrough));
        addText(m.group(0)!, base);
      } else if ((g = m.namedGroup('ital')) != null) {
        // recurse(g!, base.copyWith(fontStyle: FontStyle.italic));
        addText(m.group(0)!, base);
      } else if ((g = m.namedGroup('code')) != null) {
        // addText(g!, codeStyle);
        addText(m.group(0)!, base);
      } else if ((g = m.namedGroup('postref')) != null) {
        addLink(g!);
      } else if ((g = m.namedGroup('url')) != null) {
        final candidate = g!;
        final url = _normalizeUrl(candidate);
        if (_isValidUrl(url)) {
          addLink(url);
          addText(candidate.substring(url.length), base);
        } else {
          addText(candidate, base);
        }
      } else if ((g = m.namedGroup('topic')) != null) {
        addLink(g!);
      } else if ((g = m.namedGroup('mentionuid')) != null) {
        // 26.8.6 暂时注释 @提及 渲染（缺少相关接口，等待后端协调 --26.8.6）：
        // final uid = g!.substring(5); // 去掉 '@uid:'
        // final label = mentionLabel(uid);
        // final rec = TapGestureRecognizer()..onTap = () => onMention(uid);
        // recognizers.add(rec);
        // spans.add(TextSpan(text: label, style: mentionStyle, recognizer: rec));
        // rendered += label.length;
        addText(g!, base);
      } else if ((g = m.namedGroup('emoji')) != null) {
        final asset = stickerAssets[g];
        if (asset != null) {
          spans.add(stickerImageSpan(g!, base, start: rendered));
          rendered++;
        } else {
          addText(emojis[g] ?? g!, base);
        }
      }
      last = m.end;
    }
    if (last < text.length) addText(text.substring(last), base);
    return RichSpanResult(spans, rendered);
  }
}
