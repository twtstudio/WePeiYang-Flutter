import 'package:flutter/material.dart' hide Element;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' hide Text;

/// 识别常见行内公式
class AiLatexInlineSyntax extends InlineSyntax {
  AiLatexInlineSyntax()
      : super(
          r'(?<!\\)(?:'
          r'\$\$(?:\\.|[^\\\n])*?(?<!\\)\$\$'
          r'|(?<!\$)\$(?!\$)(?:\\.|[^\\\n])*?(?<!\\)\$(?!\$)'
          r'|\\\((?:\\.|[^\\\n])*?\\\)'
          r'|\\\[(?:\\.|[^\\\n])*?\\\]'
          r')',
        );

  @override
  bool onMatch(InlineParser parser, Match match) {
    final raw = match.group(0)!;
    final display = raw.startsWith(r'$$') || raw.startsWith(r'\[');
    final delimiterLength =
        raw.startsWith(r'$') && !raw.startsWith(r'$$') ? 1 : 2;
    final equation =
        raw.substring(delimiterLength, raw.length - delimiterLength).trim();
    if (equation.isEmpty) return false;

    final element = Element.text('latex', equation);
    element.attributes['MathStyle'] = display ? 'display' : 'text';
    parser.addNode(element);
    return true;
  }
}

/// 适配AI回答的块级公式，允许分隔符两侧有空白，并严格匹配结束符。
class AiLatexBlockSyntax extends BlockSyntax {
  static final _openingPattern = RegExp(r'^[ \t]*(?:\$\$|\\\[)[ \t]*$');

  @override
  RegExp get pattern => _openingPattern;

  @override
  Node parse(BlockParser parser) {
    final opening = parser.current.content.trim();
    final closing = opening == r'$$' ? r'$$' : r'\]';
    final lines = <String>[];
    parser.advance();

    var closed = false;
    while (!parser.isDone) {
      final line = parser.current.content;
      if (line.trim() == closing) {
        closed = true;
        parser.advance();
        break;
      }
      lines.add(line);
      parser.advance();
    }

    // 流式回答尚未收到结束符时先显示原文，避免渲染半截公式。
    if (!closed) {
      return Element.text('p', [opening, ...lines].join('\n'));
    }

    final latex = Element.text('latex', lines.join('\n').trim());
    latex.attributes['MathStyle'] = 'display';
    return Element('p', [latex]);
  }
}

/// 公式无法解析时回退为原始文本
class AiLatexElementBuilder extends MarkdownElementBuilder {
  AiLatexElementBuilder({this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final source = element.textContent;
    if (source.isEmpty) return const SizedBox.shrink();

    final display = element.attributes['MathStyle'] == 'display';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        source,
        mathStyle: display ? MathStyle.display : MathStyle.text,
        textStyle: textStyle,
        onErrorFallback: (_) => Text(
          display ? '\$\$\n$source\n\$\$' : '\$$source\$',
          style: textStyle,
        ),
      ),
    );
  }
}
