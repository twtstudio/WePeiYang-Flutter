import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class UpdateDetail extends StatelessWidget {
  const UpdateDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final version = context.read<UpdateManager>().version;

    String content = version.content;
    // 更新内容的测试可以在这里修改
    // TODO 测试结束后记得注释
    //content = "1.修复由于办公网系统更新，无法获取GPA的bug。\n2.修复了部分安卓用户无法打开图片选择器的问题。\n3.新增了回复校务帖子的功能，解决问题更高效！\n4.修复了IOS桌面小组件的显示bug。\n来自开发者的提示：部分安卓用户由于版本问题，可能会更新失败。可以点击[论坛首页的轮播图]，跳转网站下载最新版微北洋。感谢各位用户对天外天工作室的大力支持和诚恳建议，我们一定不遗余力开发出用户满意的产品!\n";

    return Text(
      content,
      style: TextUtil.base.sp(10).h(2),
    );
  }
}
