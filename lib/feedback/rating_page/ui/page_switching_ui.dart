import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/ui/page_switching_data.dart';

import '../../../commons/util/text_util.dart';


class PageSwitchingButton extends StatefulWidget {
  @override
  State<PageSwitchingButton> createState() => _PageSwitchingButtonState();
}

class _PageSwitchingButtonState extends State<PageSwitchingButton> {

  @override
  Widget build(BuildContext context) {

    context.read<PageSwitchingData>().init();
    context.read<RatingPageData>().init();
    context.read<RatingUserData>().init();

    var a = ValueListenableBuilder<String>(
      valueListenable: context.read<PageSwitchingData>().nowButtonTextString,
      builder: (BuildContext context, String nowButtonText, Widget? child) {
        //下拉菜单按钮实现
        return DropdownButton<String>(

          value: nowButtonText,

          icon: Icon(Icons.arrow_drop_down),

          onChanged: (String? newValue) {
            if (newValue != null) {
              // 更新当前页面类型
              context.read<PageSwitchingData>().nowPageTypeString.value = newValue;
            }
          },

          items: context.read<PageSwitchingData>().pageTypeList.value
              .map<DropdownMenuItem<String>>((String value) {

            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextUtil.base.blue2C.w600.sp(16),
              ),
            );

          }).toList(),

          //消除下划线
          underline: Container(),
        );
      },
    );


    ///限制成正方形
    var b = Container(
      height: 42.h-8,
      child: a,
    );

    return b;
  }
}
