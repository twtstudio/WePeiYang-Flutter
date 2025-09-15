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
    showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _FeedbackDialog(hint: hint),
    );

class _FeedbackDialog extends StatefulWidget {
  final String? hint;
  const _FeedbackDialog({this.hint});

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
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
    return Dialog(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.lighterPrimaryBackGround),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 17.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text('反馈', style: TextUtil.base.PingFangSC.w400.bold.label(context).sp(16)),
            ),
            SizedBox(height: 16.h),
            /* 输入框 */
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,

              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _trace_submit(),
              cursorColor: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
              style:TextUtil.base.label(context).PingFangSC.normal.sp(14),
              decoration: InputDecoration(
                filled: true,
                fillColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                hintText: widget.hint ?? '请输入',
                hintStyle: TextUtil.base
                    .label(context)
                    .PingFangSC
                    .normal
                    .sp(14)
                    .copyWith(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),
            /* ChoiceChip 区域 */
            Wrap(
              spacing: 8.w,
              children: _labels.map((label) {
                final isSelected = _selectedLabel == label;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (val) => setState(() {
                    _selectedLabel = val ? label : null;
                  }),
                  showCheckmark: false,
                  selectedColor: WpyTheme.of(context).get(WpyColorKey.primaryActionColor).withOpacity(0.5),
                  backgroundColor: Colors.transparent,
                  labelStyle: TextUtil.base
                      .label(context)
                      .PingFangSC
                      .normal
                      .sp(13)
                      .copyWith(
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            /* 按钮组 */
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
                        child: Text('取消',style: TextUtil.base.label(context).PingFangSC.bold.sp(14),),
                      )
                  ),
                ),
                WButton(
                  onPressed: ()=> _trace_submit(),
                  child: Container(
                      width: 82.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text('发送',style: TextUtil.base.bright(context).PingFangSC.bold.sp(14),),
                      )
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _trace_submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return; // 简单拦截
    if (_selectedLabel == null) return; // 必须选一个标签
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
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _CustomInputDialog(
        title: title,
        hint: hint,
        initial: initial,
      ),
    );

class _CustomInputDialog extends StatefulWidget {
  final String? title;
  final String? hint;
  final String? initial;

  const _CustomInputDialog({this.title, this.hint, this.initial});

  @override
  State<_CustomInputDialog> createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<_CustomInputDialog> {
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
    return Dialog(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.lighterPrimaryBackGround),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text('反馈', style: TextUtil.base.PingFangSC.w400.bold.label(context).sp(16)),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              cursorColor: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
              style:TextUtil.base.label(context).PingFangSC.normal.sp(14),
              decoration: InputDecoration(
                filled: true,
                fillColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
                hintText: widget.hint ?? '请输入',
                hintStyle: TextUtil.base
                    .label(context)
                    .PingFangSC
                    .normal
                    .sp(14)
                    .copyWith(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 20.h),

            // 按钮组
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
                        child: Text('取消',style: TextUtil.base.label(context).PingFangSC.bold.sp(14),),
                      )
                  ),
                ),
                WButton(
                  onPressed: ()=> _submit(),
                  child: Container(
                      width: 82.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text('发送',style: TextUtil.base.bright(context).PingFangSC.bold.sp(14),),
                      )
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return; // 简单拦截
    Navigator.of(context).pop(text);
  }
}
