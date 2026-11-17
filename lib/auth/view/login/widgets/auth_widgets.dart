import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

/// 登录/注册流程通用的 UI 组件。
///
/// 这里刻意不使用 ScreenUtil 的 `.sp/.w`：它按 390x844 的设计稿等比放大，
/// 在桌面端大窗口下会把字号放大到 2~3 倍。登录流程的内容区限定了最大宽度
/// ([AuthLayout.maxContentWidth])，字号只在 [0.9, 1.15] 的范围内轻微缩放，
/// 这样在手机、平板、桌面任意宽度下比例都正常。
class AuthLayout {
  AuthLayout._();

  static const double maxContentWidth = 440;
  static const double radius = 16;
  static const double fieldHeight = 52;

  /// 根据窗口尺寸算出的缩放系数（以 390 宽的手机为 1.0）
  static double scale(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = math.min(size.width, maxContentWidth + 48);
    final s = math.min(w / 390, size.height / 760);
    return s.clamp(0.9, 1.15);
  }

  static double font(BuildContext context, double size) =>
      size * scale(context);
}

extension _AuthColors on BuildContext {
  Color c(WpyColorKey key) => WpyTheme.of(this).get(key);
}

TextStyle authText(BuildContext context, double size,
        {FontWeight weight = FontWeight.w400, Color? color}) =>
    TextUtil.base.NotoSansSC.copyWith(
      fontSize: AuthLayout.font(context, size),
      fontWeight: weight,
      color: color ?? context.c(WpyColorKey.basicTextColor),
      height: 1.4,
    );

/// 登录流程的页面骨架：
/// - 主题渐变背景 + 装饰光斑
/// - 顶部可选返回按钮
/// - 标题/副标题写在渐变上，表单放在下方圆角卡片里
/// - 内容最大宽度 [AuthLayout.maxContentWidth]，水平居中；高度不够时整体可滚动
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.header,
    required this.children,
    this.footer,
    this.showBack = true,
    this.useCard = true,
  });

  final String title;
  final String? subtitle;

  /// 标题上方的额外内容（例如步骤指示器）
  final Widget? header;
  final List<Widget> children;

  /// 固定在内容底部的区域（例如用户协议），空间足够时贴底显示
  final Widget? footer;
  final bool showBack;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final bright = context.c(WpyColorKey.brightTextColor);
    final canPop = showBack && Navigator.of(context).canPop();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          body: AuthBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // 返回按钮固定在左上角，不随内容滚动/居中
                  SizedBox(
                    height: 56,
                    child: canPop
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _BackButton(color: bright),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    // 内容在剩余空间内水平、垂直居中；空间不够（窄屏 + 键盘、
                    // 桌面端矮窗口、横屏）时整体滚动，而不是溢出
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: AuthLayout.maxContentWidth),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (header != null) ...[
                                      header!,
                                      const SizedBox(height: 16),
                                    ],
                                    Text(title,
                                        style: authText(context, 30,
                                            weight: FontWeight.w700,
                                            color: bright)),
                                    if (subtitle != null) ...[
                                      const SizedBox(height: 6),
                                      Text(subtitle!,
                                          style: authText(context, 14,
                                              color: bright.withValues(
                                                  alpha: 0.82))),
                                    ],
                                    const SizedBox(height: 24),
                                    useCard
                                        ? AuthCard(children: children)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: children),
                                    if (footer != null) ...[
                                      const SizedBox(height: 20),
                                      footer!,
                                    ],
                                    // 与顶部返回栏等高，使内容视觉上居中
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: color),
        ),
      ),
    );
  }
}

/// 主题渐变背景，叠加两个柔和的光斑增加层次
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glow = context.c(WpyColorKey.brightTextColor);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: WpyTheme.of(context)
            .getGradient(WpyColorSetKey.primaryGradientAllScreen),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(size: 320, color: glow.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _Glow(size: 380, color: glow.withValues(alpha: 0.05)),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

/// 表单卡片
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: context.c(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// 卡片内的输入框：圆角填充样式，带前置图标，聚焦时显示主题色描边
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hint,
    this.icon,
    this.label,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.trailing,
  });

  final String hint;
  final IconData? icon;
  final String? label;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  /// 为 true 时显示可切换明文的眼睛图标
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  /// 输入框右侧的附加组件（例如“获取验证码”按钮）
  final Widget? trailing;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final accent = context.c(WpyColorKey.primaryActionColor);
    final hintColor = context.c(WpyColorKey.secondaryTextColor);
    final fill = context.c(WpyColorKey.secondaryBackgroundColor);
    final border = context.c(WpyColorKey.lightBorderColor);

    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLayout.radius),
          borderSide: BorderSide(color: color, width: width),
        );

    Widget? suffix;
    if (widget.obscure) {
      suffix = IconButton(
        tooltip: _hidden ? '显示密码' : '隐藏密码',
        splashRadius: 20,
        icon: Icon(
          _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: hintColor,
        ),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    } else if (widget.trailing != null) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 6),
        child: widget.trailing,
      );
    }

    final field = TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _hidden,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction ??
          (widget.nextFocus != null
              ? TextInputAction.next
              : TextInputAction.done),
      cursorColor: accent,
      style: authText(context, 15),
      onChanged: widget.onChanged,
      onSubmitted: (v) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
        widget.onSubmitted?.call(v);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: authText(context, 15, color: hintColor),
        filled: true,
        fillColor: fill,
        isDense: true,
        constraints: const BoxConstraints(minHeight: AuthLayout.fieldHeight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, size: 20, color: hintColor),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIcon: suffix,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 48, minHeight: 40),
        enabledBorder: outline(border, 1),
        focusedBorder: outline(accent, 1.5),
        border: outline(border, 1),
      ),
    );

    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label!,
              style: authText(context, 13,
                  weight: FontWeight.w500,
                  color: context.c(WpyColorKey.infoTextColor))),
        ),
        field,
      ],
    );
  }
}

/// 主按钮：撑满宽度，支持加载状态
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final accent = context.c(WpyColorKey.primaryActionColor);
    return SizedBox(
      height: AuthLayout.fieldHeight,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          disabledBackgroundColor: accent.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuthLayout.radius)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              )
            : Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: authText(context, 16,
                    weight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

/// 在渐变背景上的按钮（欢迎页使用）
class AuthOnGradientButton extends StatelessWidget {
  const AuthOnGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.filled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bright = context.c(WpyColorKey.brightTextColor);
    // 浅色底 + 加深的主题色文字：亮色主题下是白底蓝字，暗色主题下是浅灰底深蓝字，
    // 避免暗色主题里 primaryBackgroundColor（近黑）在渐变上对比度过低
    final surface = bright;
    final accent = Color.lerp(
        context.c(WpyColorKey.primaryActionColor), Colors.black, 0.2)!;
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuthLayout.radius));
    final textStyle = authText(context, 16,
        weight: FontWeight.w600, color: filled ? accent : bright);
    final child = Text(text, maxLines: 1, style: textStyle);
    return SizedBox(
      height: AuthLayout.fieldHeight,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                  backgroundColor: surface,
                  foregroundColor: accent,
                  shape: shape,
                  elevation: 0),
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                  foregroundColor: bright,
                  side: BorderSide(
                      color: bright.withValues(alpha: 0.7), width: 1.2),
                  shape: shape),
              child: child,
            ),
    );
  }
}

/// 文字按钮（卡片内）
class AuthTextButton extends StatelessWidget {
  const AuthTextButton(
      {super.key, required this.text, required this.onPressed, this.color});

  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.c(WpyColorKey.primaryActionColor);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: c,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text,
          style: authText(context, 14, weight: FontWeight.w500, color: c)),
    );
  }
}

/// “获取验证码”按钮，内置 60 秒倒计时。
/// [onFetch] 发请求，请求成功后调用传入的 `start` 开始倒计时。
class CaptchaButton extends StatefulWidget {
  const CaptchaButton({super.key, required this.onFetch, this.seconds = 60});

  final void Function(VoidCallback start) onFetch;
  final int seconds;

  @override
  State<CaptchaButton> createState() => _CaptchaButtonState();
}

class _CaptchaButtonState extends State<CaptchaButton> {
  Timer? _timer;
  int _left = 0;

  void _start() {
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _left = widget.seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counting = _left > 0;
    return AuthTextButton(
      text: counting ? '${_left}s 后重试' : '获取验证码',
      color: counting ? context.c(WpyColorKey.secondaryTextColor) : null,
      onPressed: counting ? null : () => widget.onFetch(_start),
    );
  }
}

/// 6 位验证码输入：一组方块 + 隐藏的输入框
class AuthCodeInput extends StatefulWidget {
  const AuthCodeInput({super.key, required this.onChanged, this.length = 6});

  final ValueChanged<String> onChanged;
  final int length;

  @override
  State<AuthCodeInput> createState() => _AuthCodeInputState();
}

class _AuthCodeInputState extends State<AuthCodeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final accent = context.c(WpyColorKey.primaryActionColor);
    final fill = context.c(WpyColorKey.secondaryBackgroundColor);
    final border = context.c(WpyColorKey.lightBorderColor);
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 隐藏的真实输入框，负责键盘和粘贴
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                LengthLimitingTextInputFormatter(widget.length),
                FilteringTextInputFormatter.digitsOnly,
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (v) {
                setState(() {});
                widget.onChanged(v);
              },
            ),
          ),
          IgnorePointer(
            child: Row(
              children: List.generate(widget.length * 2 - 1, (i) {
                if (i.isOdd) return const SizedBox(width: 8);
                final index = i ~/ 2;
                final active = _focus.hasFocus &&
                    (index == code.length ||
                        (index == widget.length - 1 &&
                            code.length == widget.length));
                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.9,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(maxHeight: 60),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: active ? accent : border,
                            width: active ? 1.5 : 1),
                      ),
                      child: Text(
                        index < code.length ? code[index] : '',
                        style: authText(context, 20, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 分段切换（密码登录 / 短信登录）
class AuthSegmented extends StatelessWidget {
  const AuthSegmented(
      {super.key,
      required this.items,
      required this.index,
      required this.onChanged});

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final fill = context.c(WpyColorKey.secondaryBackgroundColor);
    final surface = context.c(WpyColorKey.primaryBackgroundColor);
    final accent = context.c(WpyColorKey.primaryActionColor);
    final secondary = context.c(WpyColorKey.secondaryTextColor);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
                items.length == 1 ? 0 : -1 + 2 * index / (items.length - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(i),
                  child: Center(
                    child: Text(items[i],
                        style: authText(context, 14,
                            weight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? accent : secondary)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 注册步骤指示器
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator(
      {super.key, required this.step, required this.total, this.labels});

  /// 从 1 开始
  final int step;
  final int total;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final bright = context.c(WpyColorKey.brightTextColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(total * 2 - 1, (i) {
            if (i.isOdd) return const SizedBox(width: 6);
            final done = i ~/ 2 < step;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                decoration: BoxDecoration(
                  color: bright.withValues(alpha: done ? 0.95 : 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '第 $step / $total 步${labels != null ? ' · ${labels![step - 1]}' : ''}',
          style: authText(context, 12, color: bright.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}

/// 用户协议勾选行。用 Text.rich 实现，窄屏时自动换行而不是溢出。
class AuthAgreement extends StatefulWidget {
  const AuthAgreement({super.key, required this.checked});

  final ValueNotifier<bool> checked;

  @override
  State<AuthAgreement> createState() => _AuthAgreementState();
}

class _AuthAgreementState extends State<AuthAgreement> {
  String _privacyMd = '';
  late final TapGestureRecognizer _agreementTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('privacy/privacy_content.md').then((str) {
      if (mounted) setState(() => _privacyMd = str);
    });
    _agreementTap = TapGestureRecognizer()
      ..onTap = () => showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => UserAgreementDialog());
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => PrivacyDialog(_privacyMd, check: widget.checked));
  }

  @override
  void dispose() {
    _agreementTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bright = context.c(WpyColorKey.brightTextColor);
    final base = authText(context, 12, color: bright.withValues(alpha: 0.85));
    final link = base.copyWith(
        color: bright,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: bright);
    return ValueListenableBuilder<bool>(
      valueListenable: widget.checked,
      builder: (context, value, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: (v) => widget.checked.value = v ?? false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: bright, width: 1.5),
              checkColor: context.c(WpyColorKey.primaryActionColor),
              fillColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? bright
                      : Colors.transparent),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.checked.value = !value,
                child: Text.rich(TextSpan(style: base, children: [
                  const TextSpan(text: '我已阅读并同意 '),
                  TextSpan(
                      text: '《用户协议》', style: link, recognizer: _agreementTap),
                  const TextSpan(text: ' 与 '),
                  TextSpan(
                      text: '《隐私政策》', style: link, recognizer: _privacyTap),
                ])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 给回调式的 AuthService 接口加上加载状态。
/// 回调可能因异常路径不被调用，因此加一个超时兜底，避免按钮一直转圈。
mixin AuthLoadingMixin<T extends StatefulWidget> on State<T> {
  bool loading = false;
  Timer? _loadingGuard;

  void startLoading() {
    _loadingGuard?.cancel();
    _loadingGuard = Timer(const Duration(seconds: 20), stopLoading);
    if (mounted) setState(() => loading = true);
  }

  void stopLoading() {
    _loadingGuard?.cancel();
    if (mounted && loading) setState(() => loading = false);
  }

  @override
  void dispose() {
    _loadingGuard?.cancel();
    super.dispose();
  }
}
