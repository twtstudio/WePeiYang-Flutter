import 'package:flutter/material.dart';
// import 'package:fluwx/fluwx.dart';

class OneStopCommunityWechat extends StatefulWidget {
  const OneStopCommunityWechat({super.key});

  @override
  State<OneStopCommunityWechat> createState() => _OneStopCommunityWechatState();
}

class _OneStopCommunityWechatState extends State<OneStopCommunityWechat> {
  //TODO:暂时用不了，函数不存在？先不管了
  // 保持实例，因为 isWeChatInstalled 是实例成员
  // final Fluwx fluwx = Fluwx();
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _initFluwx();
  // }
  //
  // _initFluwx() async {
  //   // 1. 注册微信 - 使用 fluwx 实例和 registerWxApiIfNeed
  //   await fluwx.registerWxApiIfNeed(
  //     appId: 'wx233cd502f381eef5', // 你的 AppID
  //     doOnAndroid: true,
  //     doOnIOS: true,
  //     universalLink: 'https://your.universal.link/',
  //   );
  //
  //   // 2. 检查微信是否安装 - 使用 fluwx 实例
  //   bool installed = await fluwx.isWeChatInstalled;
  //   debugPrint('微信是否安装: $installed');
  //   if (!installed) {
  //     debugPrint('微信未安装，无法打开小程序');
  //     return;
  //   }
  //
  //   // 3. 打开小程序 - 使用 fluwx 实例和 openWeChatMiniProgram
  //   await fluwx.openWeChatMiniProgram(
  //     userName: 'gh_xxxxxxxxxxxx', // 小程序原始 ID
  //     path: '/pages/login-twt/login-twt', // 可选：小程序页面路径
  //     // 0, 1, 2 可以替换为 WXMiniProgramType.RELEASE, WXMiniProgramType.TEST, WXMiniProgramType.PREVIEW
  //     miniProgramType: WXMiniProgramType.RELEASE,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('正在打开小程序...')),
    );
  }
}