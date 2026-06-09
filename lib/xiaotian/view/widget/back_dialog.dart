import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';


Future<Map<String, String>?> showFeedbackDialog(
    BuildContext context, {
      String? hint,
    }) =>
    showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: _FeedbackSheet(hint: hint),
      ),
    );

class _FeedbackSheet extends StatefulWidget {
  final String? hint;
  const _FeedbackSheet({this.hint});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _labels = const ['有害', '不准确', '没有帮助', '其他'];
  final Map<String, String> _codeMap = const {
    '有害': '1',
    '不准确': '2',
    '没有帮助': '3',
    '其他': '4',
  };
  String? _selectedLabel;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('反馈', style: TextUtil.base.PingFangSC.w400.bold.label(context).sp(16), textAlign: TextAlign.center),
          SizedBox(height: 20.h),
          Text('反馈类型', style: TextUtil.base.label(context).PingFangSC.w400.sp(14)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _labels.map((label) {
              final selected = _selectedLabel == label;
              return ChoiceChip(
                label: SizedBox(
                  width: 68.w,
                  child: Center(
                    child: Text(label, style: TextUtil.base.label(context).PingFangSC.normal.sp(13)),
                  ),
                ),
                selected: selected,
                showCheckmark: true,
                pressElevation: 0,
                selectedColor: selected
                    ? WpyTheme.of(context).get(WpyColorKey.primaryActionColor).withOpacity(0.2)
                    : WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                side: BorderSide(
                  color: selected
                      ? WpyTheme.of(context).get(WpyColorKey.primaryActionColor)
                      : WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                  width: 1,
                ),
                onSelected: (v) => setState(() => _selectedLabel = v ? label : null),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            minLines: 5,
            textInputAction: TextInputAction.send,
            cursorColor: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
            style: TextUtil.base.label(context).PingFangSC.normal.sp(14),
            decoration: InputDecoration(
              filled: true,
              fillColor: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
              hintText: widget.hint ?? '请输入你的意见',
              hintStyle: TextUtil.base.label(context).PingFangSC.normal.sp(14).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '你的对话内容会被包含在反馈中帮助改进模型',
              style: TextUtil.base.labelWithOp(context).PingFangSC.normal.sp(11),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 120.h),
          WButton(
            onPressed: () => _submit(),
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text('发送', style: TextUtil.base.bright(context).PingFangSC.bold.sp(16)),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (_selectedLabel == null) return;
    Navigator.of(context).pop({
      'text': text,
      'code': _codeMap[_selectedLabel]!,
    });
  }
}


Future<String?> showCustomInputDialog(
    BuildContext context, {
      String? title,
      String? hint,
      String? initial,
    }) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: false,
          colorScheme: Theme.of(context).colorScheme.copyWith(
            surfaceTint: Colors.transparent,
            surface: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            onSurface: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
          ),
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            fillColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            filled: true,
          ),
        ),
        child: _CustomInputSheet(
          title: title,
          hint: hint,
          initial: initial,
        ),
      ),
    );

class _CustomInputSheet extends StatefulWidget {
  final String? title;
  final String? hint;
  final String? initial;

  const _CustomInputSheet({this.title, this.hint, this.initial});

  @override
  State<_CustomInputSheet> createState() => _CustomInputSheetState();
}

class _CustomInputSheetState extends State<_CustomInputSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          if (widget.title != null)
            Text(widget.title!, style: TextUtil.base.PingFangSC.w400.bold.label(context).sp(16), textAlign: TextAlign.center),
          if (widget.title != null) SizedBox(height: 16.h),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            cursorColor: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
            style: TextUtil.base.label(context).PingFangSC.normal.sp(14),
            decoration: InputDecoration(
              filled: true,
              fillColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              hintText: widget.hint ?? '请输入',
              hintStyle: TextUtil.base.label(context).PingFangSC.normal.sp(14).copyWith(
                color: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Container(
                  width: 82.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                    border: Border.all(
                      color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text('取消', style: TextUtil.base.label(context).PingFangSC.bold.sp(14)),
                  ),
                ),
              ),
              WButton(
                onPressed: () => _submit(),
                child: Container(
                  width: 82.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text('发送', style: TextUtil.base.bright(context).PingFangSC.bold.sp(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }
}
