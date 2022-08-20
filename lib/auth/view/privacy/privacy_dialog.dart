import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';

class PrivacyDialog extends Dialog {
  final ValueNotifier check;

  PrivacyDialog({this.check});

  @override
  Widget build(BuildContext context) {
    var textColor = Color.fromRGBO(98, 103, 124, 1);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
          horizontal: 30, vertical: WePeiYangApp.screenHeight / 10),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(251, 251, 251, 1)),
      child: Column(
        children: [
          Expanded(
            child: DefaultTextStyle(
              textAlign: TextAlign.start,
              style: TextUtil.base.regular.sp(13).customColor(textColor),
              child: ListView(physics: BouncingScrollPhysics(), children: [
                Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 20, bottom: 18),
                    child: Text(
                      '微北洋用户隐私政策',
                      style: TextUtil.base.bold.sp(18).customColor(textColor),
                    )),
                Text("更新日期：2022年03月19日\n" + "生效日期：2021年08月13日\n"),
                BoldText("一、隐私政策"),
                Text("请您在开始使用我们的产品微北洋（以下简称“本产品”）之前请务必仔细阅读并理解《隐私政策》（以下简称“本政策”）。"
                    " 您可以通过多种不同的方式使用我们的服务。基于此目的，我们将向您解释我们对信息的收集和使用方式，"
                    "以及您可采用什么方式来保护自己的隐私权。 我们的隐私政策包括了以下几个方面的问题：\n"
                    "1. 我们收集哪些信息\n"
                    "2. 我们如何收集和使用信息\n"
                    "3. 您如何访问和控制自己的个人信息\n"
                    "4. 信息的分享、安全以及隐私政策的使用范围和变更\n"
                    "5. 密码均以密文形式存储在数据库中，即使是相关人员也无法直接查看您的密码，且不会导致您的密码等重要信息泄露\n"
                    "6. 身份认证采用token加时间戳签名验证，以保证接口调用的安全性\n"
                    "7. 为了保证您的个人账号安全，我们不会请求除学号，身份证号以外的其它信息；且会与学校的录取信息进行对比认证来确定您本人的身份\n"),
                BoldText("1. 个人隐私"),
                Text("1.1 当您登录办公网使用微北洋服务时，我们会收集您的姓名、学院信息、"
                    "入学年份、专业、班级，以及办公网的账号密码信息。收集这些信息是为了给您提供相应的服务。"
                    "若您不提供这类信息，您无法正常使用我们提供的所有服务。\n"
                    "1.2 在您使用微北洋求实论坛服务期间，您可能会在发布页面中发布照片：\n"
                    "在已知的需要上传照片的模块中，当您选择上传照片时，"
                    "我们会收集您通过相册主动上传的照片信息，即需要您授权我们读取您的相册权限。\n"
                    "当您选择拍摄照片时，我们会申请访问您的相机，因此需要您授权相机和录音权限。\n"
                    "如果您拒绝授权仅会使您无法使用该功能，但不影响您正常使用微北洋其他功能。\n"
                    "1.3 当您使用求实论坛功能时，我们会收集您上传的动图、照片、帖子、评论、点赞信息。您也可以随时删除这些信息。"
                    "当您使用自定义课程、蹭课功能时，我们会收集您编辑的信息。您也可以随时删除这些信息。\n"
                    "1.4 当您使用自习室功能时，若您需要收藏自习室，我们会请求您的手机存储权限"
                    "并将此信息存储在您的手机本地；若您退出天外天账号，则该信息会自动删除；"
                    "若您拒绝授权则会影响收藏自习室这一功能的正常使用，但不影响您正常使用自习室查询的功能。\n"
                    "1.5 当您使用本应用并同意本隐私政策后，我们会采集您的唯一设备识别码（IMEI）以及设备的Mac地址，"
                    "对用户进行唯一标识，以便提供统计分析服务（详见：2.3 第三方SDK信息）。\n"),
                BoldText("2. 数据使用规范"),
                Text("2.1 微北洋保证不对外公开或向第三方透露用户个人隐私信息，或用户在使用服务时存储的非公开内容。\n"
                    "2.2 请您注意，我们不会主动从第三方获取您的个人信息。\n"
                    "2.3 在涉及国家安全与利益、社会公共利益、与犯罪侦查有关的相关活动、"
                    "您或他人生命财产安全但在特殊情况下无法获得您的及时授权、能够从其他合法公开的渠道、"
                    "法律法规规定的其他情形下，微北洋可能在不经过您的同意或授权的前提下，向相关部门提供您的个人信息。\n"),
                BoldText("3. 第三方SDK信息"),
                Text("3.1 微北洋使用了友盟+(Umeng)SDK，通过采集唯一设备识别码（IMEI）对用户进行唯一标识，"
                    "以便进行用户新增等统计分析服务。在特殊情况下（如用户使用平板设备或电视盒子时），"
                    "无法通过唯一设备识别码标识设备，我们会将设备Mac地址作为用户的唯一标识，以便正常提供统计分析服务。"
                    "详细内容请访问《【友盟+】隐私政策》(https://www.umeng.com/page/policy)。\n"
                    "3.2 微北洋使用了个推SDK，我们可能会将您的设备平台、设备厂商及品牌、设备型号及系统版本、设备识别码、设备序列号等设备信息、"
                    "应用列表信息、网络信息以及位置相关信息提供给每日互动股份有限公司，用于为您提供推送技术服务。"
                    "我们在向您推送消息时，我们可能会授权每日互动股份有限公司进行链路调节，相互促活被关闭的SDK推送进程，"
                    "保障您可以及时接收到我们向您推送的消息。详细内容请访问《个推用户隐私政策》(https://docs.getui.com/privacy)。\n"
                    "3.3 微北洋使用了高德地图SDK，通过采集用户的位置信息来方便用户提交健康防控信息。详情内容请访问《高德地图开放平台隐私权政策》(https://lbs.amap.com/pages/privacy)。\n"),
                BoldText("二、免责声明"),
                Text("微北洋用户明确了解并同意：\n"
                    "微北洋app为用户所提供的课程、GPA、自习室等信息，均来自于天津大学教育信息管理中心、教务网站。"
                    "我们尽可能保证为您提供最准确、及时、稳定的信息，一切准确信息以以上两个官方网站为准；"
                    "若有错缺，请用户自行比对注意，由此造成的损失天外天工作室不承担任何责任。\n"
                    "关于微北洋服务天外天工作室不提供"
                    "任何种类的明示或暗示担保或条件，你对微北洋服务的使用行为必须自行承担相应风险。\n"),
                BoldText("三、联系我们"),
                BoldText("开发者名称：天津大学"),
                Text("微北洋用户社区1(QQ群)：738068756\n"
                    "微北洋用户社区2(QQ群)：738064793\n"
                    "微北洋用户社区3(QQ群)：337647539")
              ]),
            ),
          ),
          SizedBox(height: 13),
          Divider(height: 1, color: Color.fromRGBO(172, 174, 186, 1)),
          _detail(context),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context) {
    if (check == null) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(), // 加个这个扩大点击事件范围
          padding: const EdgeInsets.all(16),
          child: Text('确定',
              style: TextUtil.base.bold.noLine
                  .sp(16)
                  .customColor(Color.fromRGBO(98, 103, 123, 1))),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              check.value = false;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('拒绝', style: TextUtil.base.bold.greyA6.noLine.sp(16)),
            ),
          ),
          GestureDetector(
            onTap: () {
              check.value = true;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('同意',
                  style: TextUtil.base.bold.noLine
                      .sp(16)
                      .customColor(Color.fromRGBO(98, 103, 123, 1))),
            ),
          ),
        ],
      );
    }
  }
}

class BoldText extends StatelessWidget {
  final String text;

  BoldText(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}
