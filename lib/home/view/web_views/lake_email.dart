import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/text_util.dart';
import '../../../commons/util/toast_provider.dart';
import '../../../commons/widgets/loading.dart';
import '../../../message/model/message_model.dart';
import '../../../message/model/message_provider.dart';
import '../../../message/network/message_service.dart';

// class LakeEmailPage extends WbyWebView {
//   //TODO:改成前端实现
//   LakeEmailPage({Key? key, required BuildContext context})
//       : super(
//             page: '湖底通知',
//             backgroundColor: WpyColorKey.primaryBackgroundColor,
//             fullPage: true,
//             key: key);
//
//   @override
//   _FestivalPageState createState() => _FestivalPageState();
// }
//
// class _FestivalPageState extends WbyWebViewState {
//   _FestivalPageState();
//
//   @override
//   Future<String> getInitialUrl(BuildContext context) async {
//     // 获取token
//     var token = await LakeTokenManager().token;
//
//     // 检查是否合格
//     if (token == null || token.isEmpty) {
//       debugPrint("Error：Token 不存在");
//       //如果验证错误可以检查是否需要回到主页登录
//       // return 'https://qnhd.twt.edu.cn/login';
//       return ''; //
//     }
//
//     // Debug 使用
//     String finalUrl =
//         'https://qnhd.twt.edu.cn/message/#/?type=default&token=$token';
//     debugPrint("URL WebView: $finalUrl");
//
//     return finalUrl;
//
//     // ///测试qpi，正式为https://www.qnhd.twt.edu.cn/message/#/?type=default&token=${CommonPreferences.lakeToken.value}
//     // return 'https://qnhd.twt.edu.cn/message/#/?type=default&token=${await LakeTokenManager().token}';
//   }
// }

class LakeEmailPage extends StatefulWidget {
  LakeEmailPage({Key? key}) : super(key: key);

  @override
  _LakeEmailPageState createState() => _LakeEmailPageState();
}

class _LakeEmailPageState extends State<LakeEmailPage>
    with AutomaticKeepAliveClientMixin {
  List<LakeEmailMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
    // monitor network fetch
    try {
      await MessageService.getLakeMessages(
          page: 1,
          onSuccess: (list, total) {
            items.clear();
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });

      if (mounted) {
        if (refreshCount) {
          context.read<MessageProvider>().refreshFeedbackCount();
        }
        setState(() {});
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  _onLoading() async {
    try {
      await MessageService.getLakeMessages(
          page: (items.length / 20).ceil() + 1,
          onSuccess: (list, total) {
            items.addAll(list);
            if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) setState(() {});
    } catch (e) {
      _refreshController.loadFailed();
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_refreshController.isRefresh) {
      child = Center(
        child: Loading(),
      );
    } else if (items.isEmpty) {
      child = Center(
        child: Text("无未读消息"),
      );
    } else {
      child = ListView.builder(
        itemBuilder: (c, i) {
          return LakeMessageItem(
            data:items[i]
          );
        },
        itemCount: items.length,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text('加载完成:)');
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text('加载失败！点击重试！');
          } else if (mode == LoadStatus.canLoading) {
            body = Text('松手,加载更多!');
          } else {
            body = Text('没有更多数据了!');
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LakeMessageItem extends StatelessWidget {
  final LakeEmailMessage data;
  const LakeMessageItem({super.key,required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w,vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context)
            .get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor).withOpacity(0.4),
              blurRadius: 8.r,
              offset: Offset(0,0)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title,
            style: TextUtil.base.bold.sp(25).label(context)),
          SizedBox(height: 8.h),
          Text(data.content,
              style: TextUtil.base.bold.sp(14).label(context).w400),
          SizedBox(height: 8.h),
          Text(data.sender,
              style: TextUtil.base.bold.sp(12).labelWithOp(context).w400),
        ],
      ),
    );
  }
}
