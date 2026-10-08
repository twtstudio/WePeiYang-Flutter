import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/network/wpy_dio.dart';
import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/util/toast_provider.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../feedback/view/lake_home_page/lake_notifier.dart';
import '../../model/block_list_item.dart';
import '../../network/blocklist_service.dart';

class ShieldSettingPage extends StatefulWidget {
  const ShieldSettingPage({super.key});

  @override
  State<ShieldSettingPage> createState() => _ShieldSettingPageState();
}

class _ShieldSettingPageState extends State<ShieldSettingPage> {
  List<String> _shieldComment = [];
  List<BlockListItem> _blockedUsers = [];
  late final String _account;
  bool _loadingUsers = true;
  bool _changingUser = false;
  String? _usersError;

  // 页面关闭或切换账号后，忽略尚未完成的操作。
  bool get _isCurrentAccount => mounted &&
      CommonPreferences.isLogin.value &&
      CommonPreferences.userNumber.value == _account;

  @override
  void initState() {
    super.initState();
    _shieldComment = CommonPreferences.shieldComment.value;
    _account = CommonPreferences.userNumber.value;
    _loadBlockedUsers();
  }

  String _errorMessage(Object error) => error is DioException
      ? error.error?.toString() ?? '请求失败，请稍后重试'
      : '屏蔽数据处理失败，请重试';

  Future<void> _loadBlockedUsers() async {
    if (!_isCurrentAccount) return;
    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });
    try {
      final users = await BlockListService.getBlockList();
      if (!_isCurrentAccount) return;
      setState(() => _blockedUsers = users);
    } catch (error) {
      if (!_isCurrentAccount) return;
      setState(() => _usersError = _errorMessage(error));
    } finally {
      if (_isCurrentAccount) setState(() => _loadingUsers = false);
    }
  }

  Future<void> _addBlockedUser() async {
    if (!_isCurrentAccount || _changingUser || _loadingUsers) return;
    setState(() => _changingUser = true);
    try {
      final input = await showShieldDialog(context,
          title: '添加屏蔽用户', hint: '请输入用户UID', type: 0);
      if (!_isCurrentAccount || input == null) return;
      final uid = int.tryParse(input);
      if (!RegExp(r'^[0-9]+$').hasMatch(input) || uid == null || uid <= 0) {
        ToastProvider.error('请输入有效的用户UID喵');
        return;
      }
      if (_blockedUsers.any((user) => user.uid == uid)) {
        ToastProvider.error('该用户已被屏蔽喵');
        return;
      }
      final user = await BlockListService.addBlock(uid);
      if (!_isCurrentAccount) return;
      setState(() => _blockedUsers.insert(0, user));
      LakeUtil.refreshAfterBlockChange().catchError(
          (_) => ToastProvider.error('屏蔽列表已更新，请手动刷新帖子'));
      ToastProvider.success('屏蔽成功');
    } catch (error) {
      if (_isCurrentAccount) ToastProvider.error(_errorMessage(error));
    } finally {
      if (_isCurrentAccount) setState(() => _changingUser = false);
    }
  }

  Future<void> _removeBlockedUser(BlockListItem user) async {
    if (!_isCurrentAccount || _changingUser || _loadingUsers) return;
    setState(() => _changingUser = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: WpyTheme.of(context)
              .get(WpyColorKey.primaryBackgroundColor),
          title: Text('取消屏蔽',
              style: TextUtil.base.bold.oldThirdAction(context)),
          content: Text('确定取消屏蔽 ${user.nickname}（UID ${user.uid}）吗？',
              style: TextUtil.base.oldThirdAction(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('返回', style: TextUtil.base.oldHint(context)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('确定', style: TextUtil.base.oldActionColor(context)),
            ),
          ],
        ),
      );
      if (!_isCurrentAccount || confirmed != true) return;
      await BlockListService.deleteBlock(user.uid);
      if (!_isCurrentAccount) return;
      setState(() => _blockedUsers.removeWhere((item) => item.uid == user.uid));
      LakeUtil.refreshAfterBlockChange().catchError(
          (_) => ToastProvider.error('屏蔽列表已更新，请手动刷新帖子'));
      ToastProvider.success('已取消屏蔽喵');
    } catch (error) {
      if (_isCurrentAccount) ToastProvider.error(_errorMessage(error));
    } finally {
      if (_isCurrentAccount) setState(() => _changingUser = false);
    }
  }

  Widget _blockedUsersSection() {
    final textStyle = TextUtil.base.bold.sp(14).oldThirdAction(context);
    final hintStyle = TextUtil.base.regular.sp(12).oldHint(context);
    final color = WpyTheme.of(context).get(WpyColorKey.oldListActionColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('屏蔽用户',
            style: TextUtil.base.bold.sp(14).oldListGroupTitle(context)),
        SizedBox(height: 8.h),
        Text('屏蔽后不再显示对方的帖子和评论，最多可屏蔽100人喵', style: hintStyle),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              if (_loadingUsers || _changingUser)
                LinearProgressIndicator(color: color),
              if (_loadingUsers)
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text('正在加载屏蔽名单喵', style: hintStyle),
                )
              else if (_usersError != null)
                WButton(
                  onPressed: _loadBlockedUsers,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 15.w, 18.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('$_usersError\n点击重试', style: hintStyle),
                        ),
                        Icon(Icons.refresh, color: color, size: 24),
                        SizedBox(width: 15.w),
                      ],
                    ),
                  ),
                )
              else ...[
                WButton(
                  onPressed: _changingUser ? null : _addBlockedUser,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 15.w, 18.h),
                    child: Row(
                      children: [
                        Expanded(child: Text('添加屏蔽用户', style: textStyle)),
                        Icon(Icons.add, color: color, size: 24),
                        SizedBox(width: 15.w),
                      ],
                    ),
                  ),
                ),
                for (final user in _blockedUsers) ...[
                  _divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 15.w, 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.nickname, style: textStyle),
                              Text('UID ${user.uid}', style: hintStyle),
                            ],
                          ),
                        ),
                        WButton(
                          onPressed: _changingUser
                              ? null
                              : () => _removeBlockedUser(user),
                          child: Icon(Icons.delete_rounded,
                              color: color, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (!_loadingUsers && _usersError == null && _blockedUsers.isEmpty) ...[
          SizedBox(height: 40.h),
          Center(child: Text('暂无屏蔽用户喵', style: hintStyle)),
        ],
      ],
    );
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
              _blockedUsersSection(),
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
                  maxLength: widget.type == 0 ? null : 20,
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
