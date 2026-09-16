import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../commons/themes/template/wpy_theme_data.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/util/text_util.dart';
import '../../commons/util/toast_provider.dart';
import '../../commons/widgets/w_button.dart';
import '../model/course_provider.dart';
import '../model/schedule_day_rules.dart';

Future<DateTime?> _showScheduleDatePicker(
  BuildContext context, {
  required String helpText,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final wpyTheme = WpyTheme.of(context);
  final action = wpyTheme.get(WpyColorKey.primaryActionColor);
  return showDatePicker(
    context: context,
    helpText: helpText,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: action,
          brightness: wpyTheme.brightness,
          primary: action,
          surface: wpyTheme.get(WpyColorKey.secondaryBackgroundColor),
          onSurface: wpyTheme.get(WpyColorKey.basicTextColor),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: wpyTheme.get(WpyColorKey.secondaryBackgroundColor),
        ),
      ),
      child: child!,
    ),
  );
}

Future<void> showDayOverrideSheet(BuildContext context,
    {DateTime? date}) async {
  final provider = context.read<CourseProvider>();
  final rules = provider.dayRules;
  final target = date ??
      await _showScheduleDatePicker(
        context,
        helpText: '选择要调整课程的日期喵',
        initialDate:
            rules.contains(DateTime.now()) ? DateTime.now() : rules.firstDay,
        firstDate: rules.firstDay,
        lastDate: rules.lastDay,
      );
  if (target == null || !context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DayOverrideSheet(provider: provider, date: target),
  );
}

class _DayOverrideSheet extends StatefulWidget {
  final CourseProvider provider;
  final DateTime date;

  const _DayOverrideSheet({required this.provider, required this.date});

  @override
  State<_DayOverrideSheet> createState() => _DayOverrideSheetState();
}

class _DayOverrideSheetState extends State<_DayOverrideSheet> {
  late String _type;
  DateTime? _source;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.provider.dayRules.ruleFor(widget.date);
    _type = rule == null
        ? 'default'
        : rule.isOff
            ? 'off'
            : 'replace';
    _source = rule?.sourceDate;
  }

  Future<void> _pickSource() async {
    final rules = widget.provider.dayRules;
    final date = await _showScheduleDatePicker(
      context,
      helpText: '选择原课表来源日期',
      initialDate: _source ?? widget.date,
      firstDate: rules.firstDay,
      lastDate: rules.lastDay,
    );
    if (date == null || !mounted) return;
    if (scheduleDate(date) == scheduleDate(widget.date)) {
      ToastProvider.error('请选择另一天，或选择恢复原课表');
    } else if (!rules.hasOriginalCourses(date, widget.provider.schoolCourses)) {
      ToastProvider.error('所选日期没有学校课程，请重新选择喵');
    } else {
      setState(() => _source = date);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_type == 'replace' && _source == null) {
      ToastProvider.error('请先选择课表来源日期');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.provider.setDayOverride(
          widget.date,
          _type == 'off'
              ? const ScheduleDayOverride.off()
              : _type == 'replace'
                  ? ScheduleDayOverride.replace(_source!)
                  : null);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) ToastProvider.error('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final action = theme.get(WpyColorKey.primaryActionColor);
    final basicText = theme.get(WpyColorKey.basicTextColor);
    final secondaryText = theme.get(WpyColorKey.secondaryInfoTextColor);
    return Container(
      decoration: BoxDecoration(
        color: theme.get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20.w, 12.h, 20.w, 20.h + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: secondaryText,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '调整 ${scheduleDateKey(widget.date)} 的课表',
                style:
                    TextUtil.base.PingFangSC.bold.sp(18).customColor(basicText),
              ),
              SizedBox(height: 6.h),
              Text(
                '仅调整学校课程，自定义课程不受影响喵',
                style: TextUtil.base.PingFangSC.normal
                    .sp(12)
                    .customColor(secondaryText),
              ),
              SizedBox(height: 16.h),
              _OptionTile(
                label: '恢复原课表',
                selected: _type == 'default',
                enabled: !_saving,
                onTap: () => setState(() => _type = 'default'),
              ),
              SizedBox(height: 8.h),
              _OptionTile(
                label: '当天休息',
                selected: _type == 'off',
                enabled: !_saving,
                onTap: () => setState(() => _type = 'off'),
              ),
              SizedBox(height: 8.h),
              _OptionTile(
                label: '使用另一天的课表',
                selected: _type == 'replace',
                enabled: !_saving,
                onTap: () => setState(() => _type = 'replace'),
              ),
              if (_type == 'replace') ...[
                SizedBox(height: 12.h),
                WButton(
                  onPressed: _saving ? null : _pickSource,
                  child: Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: theme.get(WpyColorKey.primaryBackgroundColor),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, size: 18.r, color: action),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _source == null
                                ? '选择来源日期'
                                : '使用 ${scheduleDateKey(_source!)} 的原课表',
                            style: TextUtil.base.PingFangSC.medium
                                .sp(13)
                                .customColor(action),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20.r, color: action),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '替换当天学校课程。若来源日被手动调整过，仍使用来源日的原课表喵',
                  style: TextUtil.base.PingFangSC.normal
                      .sp(11)
                      .customColor(secondaryText),
                ),
              ],
              SizedBox(height: 18.h),
              WButton(
                onPressed: _saving ? null : _save,
                child: Container(
                  height: 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: action.withValues(alpha: _saving ? 0.4 : 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _saving ? '保存中…' : '保存',
                    style: TextUtil.base.PingFangSC.bold
                        .sp(15)
                        .customColor(theme.get(WpyColorKey.brightTextColor)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final action = theme.get(WpyColorKey.primaryActionColor);
    final textColor = theme.get(WpyColorKey.basicTextColor);
    return WButton(
      onPressed: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected
              ? action.withValues(alpha: 0.12)
              : theme.get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.circular(12.r),
          border: selected
              ? Border.all(color: action.withValues(alpha: 0.7))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextUtil.base.PingFangSC.medium
                    .sp(14)
                    .customColor(selected ? action : textColor),
              ),
            ),
            Container(
              width: 18.r,
              height: 18.r,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected
                        ? action
                        : theme.get(WpyColorKey.secondaryInfoTextColor),
                    width: 1.5),
              ),
              child: selected
                  ? DecoratedBox(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: action),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
