import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/shield_uid.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/util/toast_provider.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../feedback/util/shield_feed_sync.dart';
import '../../model/block_list_item.dart';
import '../../network/blocklist_service.dart';

class ShieldSettingPage extends StatefulWidget {
  const ShieldSettingPage({super.key});

  @override
  State<ShieldSettingPage> createState() => _ShieldSettingPageState();
}

class _ShieldSettingPageState extends State<ShieldSettingPage> {
  List<String> _shieldComment = [];
  List<BlockListItem> _bannedUsers = [];
  bool _isLoadingBanned = true;

  @override
  void initState() {
    _shieldComment = CommonPreferences.shieldComment.value;
    _loadBannedUsers();
    super.initState();
  }

  ///已注销或被删除的用户，后端返回的昵称可能是空串，这里兜一个占位名
  String _bannedName(BlockListItem item) =>
      item.userInfo.nickname.isEmpty ? '已注销用户' : item.userInfo.nickname;

  // ========== 加载屏蔽用户名单（服务端为唯一事实来源） ==========
  Future<void> _loadBannedUsers() async {
    setState(() => _isLoadingBanned = true);
    await BlockListService.getBlockList(
      onSuccess: (list) {
        //同步一份到本地缓存，供帖子/评论/消息列表过滤时同步判断
        ShieldUid.replaceAll(list.map((item) => item.uid));
        if (!mounted) return;
        setState(() {
          _bannedUsers = list;
          _isLoadingBanned = false;
        });
      },
      onFailure: (e) {
        if (!mounted) return;
        setState(() => _isLoadingBanned = false);
        ToastProvider.error(e.error.toString());
      },
    );
  }

  // ========== 屏蔽词相关 ==========
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

  // ========== 屏蔽用户相关 ==========
  Future<void> _addBannedUser() async {
    final String? uidStr = await showShieldDialog(
      context,
      hint: '请输入要屏蔽的用户UID',
      title: '添加屏蔽用户',
      type: 0,
    );
    if (uidStr == null) return;
    final int? uid = int.tryParse(uidStr);
    if (uid == null || uid <= 0) {
      ToastProvider.error('请输入有效的数字UID');
      return;
    }

    await BlockListService.addBlock(
      uid,
      onSuccess: () async {
        ShieldUid.block(uid);
        //把 TA 已缓存在湖底列表里的帖子立刻摘掉，否则回到湖底还是旧列表
        ShieldFeedSync.removeShieldedPosts();
        await _loadBannedUsers();
        ToastProvider.success('屏蔽成功，TA 的内容将不再显示');
      },
      //「不能屏蔽自己」「该用户已被屏蔽」「屏蔽列表已满100人」等由后端给出
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  Future<void> _removeBannedUser(BlockListItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认解除屏蔽'),
        content: Text('确定要解除对 ${_bannedName(item)} 的屏蔽吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await BlockListService.deleteBlock(
      item.uid,
      onSuccess: () async {
        ShieldUid.unblock(item.uid);
        //之前被摘掉的帖子要靠重新拉取才能恢复
        ShieldFeedSync.reloadLoadedPosts();
        await _loadBannedUsers();
        ToastProvider.success('解除屏蔽成功');
      },
      onFailure: (e) => ToastProvider.error(e.error.toString()),
    );
  }

  // ========== UI组件 ==========
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
              // ========== 屏蔽词模块 ==========
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
                                child: Text('添加屏蔽评论词', style: mainTextStyle)),
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
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 15.w, 12.h),
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

              // ========== 屏蔽用户模块 ==========
              SizedBox(height: 30.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('屏蔽用户', style: titleTextStyle),
              ),
              SizedBox(height: 8.h),
              Text('屏蔽后，TA 发布的帖子、评论及相关消息通知都不会再显示，最多可屏蔽 100 人',
                  style: hintTextStyle),
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
                      onPressed: _addBannedUser,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 18.h, 15.w, 18.h),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('添加屏蔽用户', style: mainTextStyle)),
                            add,
                            SizedBox(width: 15.w),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoadingBanned) ...[
                      _divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.oldListActionColor),
                            ),
                          ),
                        ),
                      ),
                    ] else if (_bannedUsers.isNotEmpty) ...[
                      for (int index = 0;
                      index < _bannedUsers.length;
                      index++) ...[
                        _divider(),
                        Padding(
                          padding:
                          EdgeInsets.fromLTRB(20.w, 12.h, 15.w, 12.h),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                      '${_bannedName(_bannedUsers[index])}'
                                      '（UID ${_bannedUsers[index].uid}）',
                                      style: mainTextStyle)),
                              WButton(
                                onPressed: () =>
                                    _removeBannedUser(_bannedUsers[index]),
                                child: Icon(Icons.delete_rounded,
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.oldListActionColor),
                                    size: 22),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      _divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Text('还没有屏蔽用户，点击上方添加吧~', style: hintTextStyle),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== 弹窗 ==========
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
                TextField(
                  controller: _ctrl,
                  autofocus: true,
                  maxLines: widget.type == 0 ? 1 : 2,
                  //UID 不设长度上限：UID 只有 5 位，限 8 位既无意义还会多出一个
                  //"0/8" 字数统计。屏蔽词仍保留 20 字上限。
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