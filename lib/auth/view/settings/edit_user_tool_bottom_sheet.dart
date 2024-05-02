import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';
import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import 'package:http/http.dart' as http;

class EditUserToolBottomSheet extends StatefulWidget {
  @override
  _EditUserToolBottomSheetState createState() =>
      _EditUserToolBottomSheetState();
}

class _EditUserToolBottomSheetState extends State<EditUserToolBottomSheet> {
  var eng = '';
  var label = '';
  var url = '';
  bool a = true;
  int num = 1;
  List<double?> iconSizeList = [24.w, 24.w, 24.w, 24.w];

  Future<void> _submit() async {
    ToastProvider.running("新建中……");
    if (eng == '' || label == '' || url == '')
      ToastProvider.error("请将信息填写完整喵~");
    else {
      setState(() {
        CommonPreferences.userTool.value.add(CardBean(
            "assets/svg_pics/lake_butt_icons/example${num % 4 + 1}.png",
            iconSizeList[num % 4 + 1],
            label,
            eng,
            url));
      });
      await Future.delayed(Duration(seconds: 1));
      ToastProvider.success("创建成功喵~");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Container(
          height: 460.h,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          decoration: BoxDecoration(
            color:
                WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  WButton(
                    onPressed: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.oldActionColor),
                        size: 25.r),
                  ),SizedBox(width:10.w),
                  Text('新建个性化工具',
                      style:
                          TextUtil.base.PingFangSC.bold.label(context).sp(18)),
                  Spacer(),
                  WButton(
                    onPressed: () => _submit(),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text('确认',
                          style: TextUtil.base.medium.sp(16).bright(context)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              CardWidget(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InputWidget(
                    onChanged: (text) => label = text,
                    title: '标签名称',
                    hintText: '请输入标签名称喵',
                    initText: label,
                    inputFormatter: [LengthLimitingTextInputFormatter(10)],
                  ),
                  InputWidget(
                    onChanged: (text) => eng = text,
                    title: '标签副标题',
                    hintText: '请输入合适长度的副标题喵',
                    initText: eng,
                    inputFormatter: [LengthLimitingTextInputFormatter(20)],
                  )
                ],
              )),
              CardWidget(
                child: Column(
                  children: [
                    InputWidget(
                      onChanged: (text) => url = text,
                      title: '跳转坐标',
                      hintText: '请输入正确有效的网址喵',
                      initText: url,
                      inputFormatter: [LengthLimitingTextInputFormatter(20)],
                    ),
                    Container(
                      height: 48.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("微北洋内打开/跳转浏览器",
                              style: TextUtil.base.PingFangSC.bold
                                  .label(context)
                                  .sp(14)),
                          Switch(
                            value: a,
                            onChanged: (value) {},
                            activeColor: WpyTheme.of(context)
                                .get(WpyColorKey.oldSecondaryActionColor),
                            inactiveThumbColor: WpyTheme.of(context)
                                .get(WpyColorKey.oldHintColor),
                            activeTrackColor: WpyTheme.of(context)
                                .get(WpyColorKey.oldSwitchBarColor),
                            inactiveTrackColor: WpyTheme.of(context)
                                .get(WpyColorKey.oldSwitchBarColor),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CardWidget(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("请选择图标喵",
                        style: TextUtil.base.PingFangSC.bold
                            .label(context)
                            .sp(14)),
                    Container(
                      height: 50.r,
                      width: 150.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WButton(
                            onPressed: () {
                              setState(() {
                                num--;
                              });
                            },
                            child: Container(
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.oldSwitchBarColor),
                                  border: Border.all(
                                      color: WpyTheme.of(context)
                                          .get(WpyColorKey.oldHintColor)),
                                  borderRadius: BorderRadius.circular(15.w)),
                              child: Icon(
                                Icons.arrow_left_rounded,
                                size: 40.r,
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.oldSecondaryActionColor),
                              ),
                            ),
                          ),
                          Container(
                            width: 50.r,
                            padding: EdgeInsets.all(1.r),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.oldSwitchBarColor),
                                border: Border.all(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.oldHintColor)),
                                borderRadius: BorderRadius.circular(15.w)),
                            child: ColoredIcon(
                              "assets/svg_pics/lake_butt_icons/example${num % 4 + 1}.png",
                              width: iconSizeList[1],
                              color: WpyTheme.of(context).primary,
                            ),
                          ),
                          WButton(
                            onPressed: () {
                              setState(() {
                                num++;
                              });
                            },
                            child: Container(
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.oldSwitchBarColor),
                                  border: Border.all(
                                      color: WpyTheme.of(context)
                                          .get(WpyColorKey.oldHintColor)),
                                  borderRadius: BorderRadius.circular(15.w)),
                              child: Icon(
                                Icons.arrow_right_rounded,
                                size: 40.r,
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.oldSecondaryActionColor),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w)
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
