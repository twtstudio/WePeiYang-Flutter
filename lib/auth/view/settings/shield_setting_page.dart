import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/util/toast_provider.dart';
import '../../../commons/widgets/w_button.dart';

class ShieldSettingPage extends StatefulWidget {
  const ShieldSettingPage({super.key});

  @override
  State<ShieldSettingPage> createState() => _ShieldSettingPageState();
}

class _ShieldSettingPageState extends State<ShieldSettingPage> {
  List<String> _shieldComment = [];

  @override
  void initState() {
    _shieldComment = CommonPreferences.shieldComment.value;
    super.initState();
  }

  Future<void> _addShieldWord() async {
    final String? word = await showShieldDialog(
      context,
      hint: '请输入屏蔽词(支持正则表达式)',
      title: '添加屏蔽词',
      type: 1,
    );
    if (word == null) return;
    setState(() => _shieldComment.add(word));
    CommonPreferences.shieldComment.value = _shieldComment;
    ToastProvider.success('屏蔽词添加成功');
  }

  void _removeShieldWord(int index) {
    setState(() => _shieldComment.removeAt(index));
    CommonPreferences.shieldComment.value = _shieldComment;
    ToastProvider.success('删除成功');
  }

  Widget _divider() => Container(
        height: 0.5,
        color: WpyTheme.of(context)
            .get(WpyColorKey.oldHintColor)
            .withValues(alpha: 1),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
      );

  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        TextUtil.base.bold.sp(14).oldListGroupTitle(context);
    final hintTextStyle = TextUtil.base.regular.sp(12).oldHint(context);
    final mainTextStyle = TextUtil.base.bold.sp(14).oldThirdAction(context);
    final add = Icon(Icons.add,
        color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
        size: 24);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: WpyTheme.of(context).brightness.uiOverlay.copyWith(
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('屏蔽设置',
              style: TextUtil.base.bold.sp(16).oldActionColor(context)),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: WButton(
              child: Icon(Icons.arrow_back,
                  color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                  size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('屏蔽评论词', style: titleTextStyle),
              ),
              SizedBox(height: 8.h),
              Text('命中下列关键词（支持正则表达式）的评论将被自动隐藏', style: hintTextStyle),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    WButton(
                      onPressed: _addShieldWord,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 18.h, 15.w, 18.h),
                        child: Row(
                          children: [
                            Expanded(
                                child:
                                    Text('添加屏蔽评论词', style: mainTextStyle)),
                            add,
                            SizedBox(width: 15.w),
                          ],
                        ),
                      ),
                    ),
                    for (int index = 0;
                        index < _shieldComment.length;
                        index++) ...[
                      _divider(),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(20.w, 12.h, 15.w, 12.h),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(_shieldComment[index],
                                    style: mainTextStyle)),
                            WButton(
                              onPressed: () => _removeShieldWord(index),
                              child: Icon(Icons.delete_rounded,
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.oldListActionColor),
                                  size: 22),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_shieldComment.isEmpty) ...[
                SizedBox(height: 40.h),
                Center(
                  child: Text('还没有屏蔽词，点击上方添加吧~', style: hintTextStyle),
                ),
              ],
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showShieldDialog(BuildContext context,
        {String? hint, String? title, int? type}) =>
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ShieldAddDialog(title: title, hint: hint, type: type),
    );

class ShieldAddDialog extends StatefulWidget {
  final String? hint;
  final String? title;
  final int? type;
  const ShieldAddDialog({this.hint, this.title, this.type});

  @override
  State<ShieldAddDialog> createState() => _ShieldAddDialogState();
}

class _ShieldAddDialogState extends State<ShieldAddDialog> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          decoration: BoxDecoration(
            color:
                WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(widget.title ?? "   ",
                      style: TextUtil.base.PingFangSC.w400.bold
                          .label(context)
                          .sp(16)),
                ),
                SizedBox(height: 16.h),
                /* 输入框 */
                TextField(
                  controller: _ctrl,
                  autofocus: true,
                  maxLines: widget.type == 0 ? 1 : 2,
                  maxLength: widget.type == 0 ? 8 : 20,
                  keyboardType: widget.type == 0
                      ? TextInputType.number
                      : TextInputType.text,
                  textInputAction: TextInputAction.send,
                  cursorColor: WpyTheme.of(context)
                      .get(WpyColorKey.secondaryInfoTextColor),
                  style: TextUtil.base.label(context).PingFangSC.normal.sp(14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: WpyTheme.of(context)
                        .get(WpyColorKey.primaryBackgroundColor),
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
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.oldListActionColor),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '取消',
                              style: TextUtil.base
                                  .label(context)
                                  .PingFangSC
                                  .bold
                                  .sp(14),
                            ),
                          )),
                    ),
                    WButton(
                      onPressed: () {
                        final text = _ctrl.text.trim();
                        if (text.isEmpty) return;
                        Navigator.of(context).pop(text);
                      },
                      child: Container(
                          width: 82.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.oldListActionColor),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '确定',
                              style: TextUtil.base
                                  .label(context)
                                  .PingFangSC
                                  .bold
                                  .sp(14),
                            ),
                          )),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
