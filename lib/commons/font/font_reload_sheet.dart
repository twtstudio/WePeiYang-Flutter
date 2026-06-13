import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

import 'font_reload_controller.dart';

/// 打开「重新加载字体文件」的底部弹层（带下载进度、文件位置）。
Future<void> showFontReloadSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FontReloadSheet(),
  );
}

class FontReloadSheet extends StatefulWidget {
  const FontReloadSheet({super.key});

  @override
  State<FontReloadSheet> createState() => _FontReloadSheetState();
}

class _FontReloadSheetState extends State<FontReloadSheet> {
  late final FontReloadController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FontReloadController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dragHandle(theme),
                  SizedBox(height: 16.h),
                  _header(context, theme),
                  SizedBox(height: 14.h),
                  _locationCard(context, theme),
                  SizedBox(height: 16.h),
                  for (final entry in _controller.entries) ...[
                    _FontEntryTile(entry: entry),
                    SizedBox(height: 14.h),
                  ],
                  SizedBox(height: 2.h),
                  _footer(context, theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dragHandle(WpyTheme theme) {
    return Center(
      child: Container(
        width: 38.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: theme.get(WpyColorKey.secondaryInfoTextColor),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, WpyTheme theme) {
    final String subtitle;
    if (_controller.finished) {
      subtitle = _controller.hasFailure
          ? '${_controller.successCount} 个成功，${_controller.failedCount} 个失败'
          : '全部字体已重新加载完成';
    } else {
      subtitle = '正在重新下载并加载字体，请稍候…';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '重新加载字体文件',
          style: TextUtil.base.PingFangSC.bold.label(context).sp(18),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextUtil.base.PingFangSC.normal
              .sp(12)
              .customColor(theme.get(WpyColorKey.secondaryInfoTextColor)),
        ),
      ],
    );
  }

  Widget _locationCard(BuildContext context, WpyTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined,
                  size: 16.r, color: theme.get(WpyColorKey.secondaryInfoTextColor)),
              SizedBox(width: 6.w),
              Text(
                '文件保存位置',
                style: TextUtil.base.PingFangSC.bold.label(context).sp(13),
              ),
              const Spacer(),
              WButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _controller.directory));
                  ToastProvider.success('已复制路径');
                },
                child: Text(
                  '复制',
                  style: TextUtil.base.PingFangSC.medium
                      .sp(12)
                      .customColor(theme.get(WpyColorKey.primaryActionColor)),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            _controller.directory,
            style: TextUtil.base.PingFangSC.normal
                .sp(11)
                .customColor(theme.get(WpyColorKey.secondaryInfoTextColor)),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, WpyTheme theme) {
    if (!_controller.finished) {
      return _ActionButton(
        label: '正在加载…',
        filled: true,
        enabled: false,
        onTap: null,
      );
    }
    return Row(
      children: [
        if (_controller.hasFailure) ...[
          Expanded(
            child: _ActionButton(
              label: '重试',
              filled: false,
              enabled: true,
              onTap: () => _controller.start(),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: _ActionButton(
            label: '完成',
            filled: true,
            enabled: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final action = theme.get(WpyColorKey.primaryActionColor);
    final bg = filled
        ? action.withValues(alpha: enabled ? 1 : 0.4)
        : theme.get(WpyColorKey.primaryBackgroundColor);
    final fg = filled
        ? theme.get(WpyColorKey.primaryBackgroundColor)
        : action;
    return WButton(
      onPressed: enabled ? onTap : null,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
          border: filled
              ? null
              : Border.all(color: action.withValues(alpha: 0.6), width: 1),
        ),
        child: Text(
          label,
          style: TextUtil.base.PingFangSC.bold.sp(15).customColor(fg),
        ),
      ),
    );
  }
}

class _FontEntryTile extends StatelessWidget {
  const _FontEntryTile({required this.entry});

  final FontReloadEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final failed = entry.status == FontLoadStatus.failed;
    final barColor =
        failed ? theme.get(WpyColorKey.dangerousRed) : theme.primary ?? Colors.blue;
    final value = entry.status == FontLoadStatus.pending ? 0.0 : entry.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.name,
                style: TextUtil.base.PingFangSC.medium.label(context).sp(14),
              ),
            ),
            SizedBox(width: 8.w),
            _statusLabel(context, theme),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          entry.fileName,
          style: TextUtil.base.PingFangSC.normal
              .sp(11)
              .customColor(theme.get(WpyColorKey.secondaryInfoTextColor)),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6.h,
            backgroundColor: theme.get(WpyColorKey.oldSwitchBarColor),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        if (failed && entry.reason != null) ...[
          SizedBox(height: 6.h),
          Text(
            entry.reason!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextUtil.base.PingFangSC.normal
                .sp(11)
                .customColor(theme.get(WpyColorKey.dangerousRed)),
          ),
        ],
      ],
    );
  }

  Widget _statusLabel(BuildContext context, WpyTheme theme) {
    late final String text;
    late final Color color;
    switch (entry.status) {
      case FontLoadStatus.pending:
        text = '等待中';
        color = theme.get(WpyColorKey.secondaryInfoTextColor);
        break;
      case FontLoadStatus.downloading:
        text = '${(entry.progress * 100).toStringAsFixed(0)}%';
        color = theme.primary ?? Colors.blue;
        break;
      case FontLoadStatus.loading:
        text = '加载中';
        color = theme.primary ?? Colors.blue;
        break;
      case FontLoadStatus.success:
        text = '已完成';
        color = theme.get(WpyColorKey.primaryActionColor);
        break;
      case FontLoadStatus.failed:
        text = '失败';
        color = theme.get(WpyColorKey.dangerousRed);
        break;
    }
    return Text(
      text,
      style: TextUtil.base.PingFangSC.medium.sp(12).customColor(color),
    );
  }
}
