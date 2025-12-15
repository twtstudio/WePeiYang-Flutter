import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/preferences/common_prefs.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/util/toast_provider.dart';
import '../../../commons/widgets/w_button.dart';
import '../../network/blocklist_service.dart';

class ShieldSettingPage extends StatefulWidget {
  const ShieldSettingPage({super.key});

  @override
  State<ShieldSettingPage> createState() => _ShieldSettingPageState();
}

class _ShieldSettingPageState extends State<ShieldSettingPage> {

  List<String> _shieldUserUid = [];
  List<String> _shieldComment = [];

  @override
  void initState() {
    // _loadShield();
    _shieldComment = CommonPreferences.shieldComment.value;
    super.initState();
  }

  // void _loadShield() async {
  //   _shieldUserUid = await BlockListService.getBlockList(onFailure: (e){
  //     print(e);
  //     ToastProvider.error('获取屏蔽用户失败');
  //   });
  //   _shieldComment = CommonPreferences.shieldComment.value;
  // }

  @override
  Widget build(BuildContext context) {
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

        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 15.h)),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () {
                    ToastProvider.success('正在开发哦');
                    // final  String? uid = await showShieldDialog(
                    //   context,
                    //   hint: '请输入屏蔽用户uid',
                    //   title: '添加uid',
                    //   type:0,
                    // );
                    // if(uid == null) {
                    //   return;
                    // }
                    // BlockListService.addBlock(uid, onSuccess: () {
                    //   ToastProvider.success('添加成功');
                    //   setState(() {
                    //     _loadShield();
                    //   });
                    // }, onFailure: (e){
                    //   print(e);
                    //   ToastProvider.success('添加失败');
                    // });
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text('添加屏蔽用户uid', style: mainTextStyle)),
                      add,
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8.h)),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                // padding: EdgeInsets.symmetric(vertical: 10.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: List.generate(_shieldUserUid.length, (index) {
                    final uid = _shieldUserUid[index];
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                          child: Row(
                            children: [
                              Expanded(child: Text(uid, style: mainTextStyle)),
                              WButton(
                                onPressed:(){
                                  // setState(() {
                                  //   _shieldUserUid.removeAt(index);
                                  // });
                                  // BlockListService.deleteBlock(uid, onSuccess: (){
                                  //   ToastProvider.success('删除成功');
                                  //   setState(() {
                                  //     _loadShield();
                                  //   });
                                  // }, onFailure: (e){
                                  //   print(e);
                                  //   ToastProvider.error('删除失败');
                                  // });
                                },
                                child: Icon(Icons.delete_rounded,
                                    color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
                                    size: 22),
                              )
                            ],
                          ),
                        ),
                        if (index != _shieldUserUid.length - 1)
                          Container(
                            height: 0.5,
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.oldHintColor)
                                .withOpacity(1),
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () async {
                    final  String? word = await showShieldDialog(
                      context,
                      hint: '请输入屏蔽词(支持正则表达式)',
                      title: '添加屏蔽词',
                      type:1,
                    );
                    if(word == null) {
                      return;
                    }
                    _shieldComment.add(word);
                    CommonPreferences.shieldComment.value = _shieldComment;
                    ToastProvider.success('屏蔽词添加成功');
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text('添加屏蔽评论词', style: mainTextStyle)),
                      add,
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8.h)),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                // padding: EdgeInsets.symmetric(vertical: 10.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: List.generate(_shieldComment.length, (index) {
                    final uid = _shieldComment[index];
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                          child: Row(
                            children: [
                              Expanded(child: Text(uid, style: mainTextStyle)),
                              WButton(
                                onPressed:(){
                                  setState(() {
                                    _shieldComment.removeAt(index);
                                  });
                                  CommonPreferences.shieldComment.value = _shieldComment;
                                  ToastProvider.success('删除成功');
                                },
                                child: Icon(Icons.delete_rounded,
                                    color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
                                    size: 22),
                              )
                            ],
                          ),
                        ),
                        if (index != _shieldComment.length - 1)
                          Container(
                            height: 0.5,
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.oldHintColor)
                                .withOpacity(1),
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showShieldDialog(
    BuildContext context, {
      String? hint,
      String? title,
      int? type
    }) =>
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ShieldAddDialog(title: title,hint: hint,type:type),
    );

class ShieldAddDialog extends StatefulWidget {
  final String? hint;
  final String? title;
  final int? type;
  const ShieldAddDialog({this.hint,this.title,this.type});

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
        color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        borderRadius: BorderRadius.circular(16.r),
        ),
      child:
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(widget.title ?? "   ",
                    style: TextUtil.base.PingFangSC.w400.bold.label(context).sp(
                        16)),
              ),
              SizedBox(height: 16.h),
              /* 输入框 */
              TextField(
                controller: _ctrl,
                autofocus: true,
                maxLines: widget.type ==  0 ? 1 : 2,
                maxLength: widget.type ==  0 ? 8 : 20,
                keyboardType: widget.type ==  0 ? TextInputType.number : TextInputType.text,
                textInputAction: TextInputAction.send,
                cursorColor: WpyTheme.of(context).get(
                    WpyColorKey.secondaryInfoTextColor),
                style: TextUtil.base
                    .label(context)
                    .PingFangSC
                    .normal
                    .sp(14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: WpyTheme.of(context).get(
                      WpyColorKey.primaryBackgroundColor),
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
                          color: WpyTheme.of(context).get(
                              WpyColorKey.primaryBackgroundColor),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text('取消', style: TextUtil.base
                              .label(context)
                              .PingFangSC
                              .bold
                              .sp(14),),
                        )
                    ),
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
                          color: WpyTheme.of(context).get(
                              WpyColorKey.primaryBackgroundColor),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text('确定', style: TextUtil.base
                              .label(context)
                              .PingFangSC
                              .bold
                              .sp(14),),
                        )
                    ),
                  )
                ],
              ),
            ],
          ),
        ),)
    );
  }
}

