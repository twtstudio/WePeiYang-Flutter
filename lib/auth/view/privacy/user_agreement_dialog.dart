import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class UserAgreementDialog extends Dialog {
  final ValueNotifier? check;

  UserAgreementDialog({this.check});

  @override
  Widget build(BuildContext context) {
    var textColor = WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
          horizontal: 30, vertical: WePeiYangApp.screenHeight / 10),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
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
                    child: Text('微北洋用户协议',
                        style:
                            TextUtil.base.bold.sp(18).customColor(textColor))),
                Text("更新日期：2022年03月19日\n" + "生效日期：2021年08月13日\n"),
                BoldText("一．引言"),
                Text("微北洋产品和服务的提供者为天津大学（以下简称“我们”）。"
                    "微北洋自推出以来连接全校师生，带来学习与生活的便捷。"
                    "微北洋致力于为用户提供一个绿色、安全、健康、便捷的校园平台，"
                    "为了实现这一目标，我们基于以下原则制定了《微北洋用户须知及隐私政策》（以下简称“本协议”），"
                    "声明用户的权利与义务，对违规行为进行处理，维护用户及其他主体的合法权益。\n"),
                BoldText("为共同营造绿色、安全、健康、清朗的网络环境，请仔细阅读并遵守相关规定。\n"),
                Text("我们一向尊重并会严格保护用户在使用微北洋时的合法权益（包括用户隐私、用户数据等）不受到任何侵犯。"
                    "本协议（包括本文最后部分的隐私政策）是用户（包括通过各种合法途径获取到本产品的自然人、法人或其他组织机构，"
                    "以下简称“用户”或“您”）与我们之间针对本产品相关事项最终的、完整的且排他的协议，"
                    "并取代、合并之前的当事人之间关于上述事项的讨论和协议。\n"),
                Text(
                    "本协议将对用户使用本产品的行为产生法律约束力，您已承诺和保证有权利和能力订立本协议。用户开始使用本产品将视为已经接受本协议，"
                    "请认真阅读并理解本协议中各种条款，包括免除和限制我们的免责条款和对用户的权利限制"
                    "（未成年人审阅时应由法定监护人陪同），如果您不能接受本协议中的全部条款，请勿开始使用本产品。\n"),
                Text("如果你发现任何违规行为或内容，可以通过天外天微信公众号、用户社群、"
                    "开发者邮箱等渠道发起投诉。我们收到投诉后，将对相关投诉进行审核。"
                    "如违反规则，我们可能对帐号或内容停止提供服务。对于违反规则的用户，"
                    "微北洋将视违规程度，可能停止提供违规内容在微北洋继续展示、传播的服务，"
                    "予以警告，并可能停止对你的帐号提供服务。\n"),
                BoldText("二．微北洋软件使用规范"),
                Text("用户在使用微北洋软件的过程中必须承诺：\n"),
                BoldText("您使用本产品的行为必须合法。\n"),
                Text("本产品将会依据本协议“修改和终止”的规定保留或终止您的账户。您必须承诺对您的登录信息保密、"
                    "不被其他人获取与使用，并且对您在本账户下的所有行为负责。您必须将任何有可能触犯法律的、"
                    "未授权使用或怀疑为未授权使用的行为在第一时间通知本产品。本产品不对您因未能遵守上述要求而造成的损失承担法律责任。\n"),
                BoldText("1. 合理、善意注册使用微北洋"),
                Text("你应当合理、善意注册并使用微北洋帐号，"
                    "不得恶意注册或将天外天帐号用于非法或不正当用途。\n"
                    "1.1 官方渠道注册。\n用户须通过i.twt.edu.cn注册天外天帐号登录微北洋。\n"
                    "1.2 不得恶意注册、使用天外天帐号。\n用户不得实施恶意注册、使用天外天帐号的行为，"
                    "您不得对账号进行任何形式的许可、出售、租赁、转让、发行或其他商业用途；"
                    "您不得删除或破坏包含在本产品中的任何版权声明或其他所有权标记。"
                    "用户不得冒充他人；不得利用他人的名义发布任何信息。\n"),
                BoldText("2.用户内容"),
                Text("2.1 用户内容\n"
                    "2.1.1 用户内容是指该用户下载、发布或以其他方式使用本产品时产生的所有内容（例如：您的信息、图片、音乐或其他内容）。\n"
                    "2.1.2 您是您的用户内容唯一的责任人，您将承担因您的用户内容披露而导致的您或任何第三方被识别的风险。\n"
                    "2.1.3 您已同意您的用户内容受到权利限制（详见“权利限制”）。\n"
                    "2.2 权利限制\n"
                    "您已同意通过分享或其他方式使用本产品中的相关服务，"
                    "在使用过程中，您将承担因下述行为所造成的风险而产生的全部法律责任："
                    "2.2.1 违反或反对宪法确定的基本原则、社会主义制度的；\n"
                    "2.2.2 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一、主权和领土完整的；\n"
                    "2.2.3 损害国家荣誉和利益的；\n"
                    "2.2.4 煽动民族仇恨、民族歧视，破坏民族团结的；\n"
                    "2.2.5 破坏国家宗教政策，宣扬邪教和封建迷信的；\n"
                    "2.2.6 散布谣言，扰乱社会秩序，破坏社会稳定的；\n"
                    "2.2.7 散布淫秽、色情、赌博、暴力、恐怖或者教唆犯罪的；\n"
                    "2.2.8 侮辱或者诽谤他人，侵害他人合法权益的；\n"
                    "2.2.9 煽动非法集会、结社、游行、示威、聚众扰乱社会秩序；\n"
                    "2.2.10 以非法民间组织名义活动的；\n"
                    "2.2.11 不符合《即时通信工具公众信息服务发展管理暂行规定》及其他相关法律法规要求的。\n"
                    "2.2.12 含有法律、行政法规禁止的其他内容的。"),
                BoldText("您已经同意不在本产品从事下列行为："),
                Text("发布或分享电脑病毒、蠕虫、恶意代码、故意破坏或改变计算机系统或数据的软件；\n"
                    "未授权的情况下，收集其他用户的信息或数据，例如电子邮箱地址等；\n"
                    "用自动化的方式恶意使用本产品，给服务器造成过度的负担或以其他方式干扰或损害网站服务器和网络链接；\n"
                    "在未授权的情况下，尝试访问本产品的服务器数据或通信数据；\n"
                    "干扰、破坏本产品其他用户的使用。\n"),
                BoldText("3. 终端用户协议"),
                Text("3.1 许可\n"
                    "依据本协议规定，本产品将授予您以下不可转让的、非排他的许可：\n"
                    "3.1.1 使用本产品的权利；\n"
                    "3.1.2 在您所有的网络通信设备、计算机设备和移动通信设备上下载、安装、使用本产品的权利。\n"
                    "3.1.3 注销您的账号的权利。您可以在应用内个人中心->个人信息更改->注销账号处，"
                    "或者前往天外天个人中心(https://i.twt.edu.cn/#/)的账户设置->注销账户处进行注销操作。\n"
                    "当您决定注销账号后，您将无法再以该账号登录和使用我们的产品与服务，"
                    "该账号下的内容、信息、数据、记录等会将被删除或匿名化处理；账号注销完成后，将无法恢复。\n"
                    "3.2 限制性条款\n"
                    "本协议对您的授权将受到以下限制：\n"
                    "3.2.1 您不得对本产品进行任何形式的许可、出售、租赁、转让、发行或其他商业用途；\n"
                    "3.2.2 除非法律禁止此类限制，否则您不得对本产品的任何部分或衍生产品进行修改、翻译、改编、合并、利用、分解、改造或反向编译、反向工程等；\n"
                    "3.2.3 您不得以创建相同或竞争服务为目的使用本产品；\n"
                    "3.2.4 除非法律明文规定，否则您不得对本产品的任何部分以任何形式或方法进行生产、复制、发行、出售、下载或显示等；\n"
                    "3.2.5 您不得删除或破坏包含在本产品中的任何版权声明或其他所有权标记。\n"
                    "3.3 版本\n"
                    "任何本产品的更新版本或未来版本、更新或者其他变更将受到本协议约束。\n"),
                BoldText("4. 遵守法律"),
                Text(
                    "您同意遵守《中华人民共和国合同法》、《中华人民共和国著作权法》及其实施条例、《全国人民代表大会常务委员会关于维护互联网安全的决定》（“人大安全决定”）、"
                    "《中华人民共和国保守国家秘密法》、《中华人民共和国电信条例》（“电信条例“）、《中华人民共和国计算机信息系统安全保护条例》、"
                    "《中华人民共和国计算机信息网络国际联网管理暂行规定》及其实施办法、《计算机信息系统国际联网保密管理规定》、《互联网信息服务管理办法》、"
                    "《计算机信息网络国际联网安全保护管理办法》、《互联网电子公告服务管理规定》（“电子公告规定”）、《中华人民共和国网络安全法》、"
                    "、《中华人民共和国密码法》等相关中国法律法规的任何及所有的规定，并对以任何方式使用您的密码和您的账号使用本服务的任何行为及其结果承担全部责任。"
                    "如违反《人大安全决定》有可能构成犯罪，被追究刑事责任。《电子公告规定》则有明文规定，上网用户使用电子公告服务系统对所发布的信息负责。"
                    "《电信条例》也强调，使用电信网络传输信息的内容及其后果由电信用户负责。在任何情况下，如果本产品有理由认为您的任何行为，"
                    "包括但不限于您的任何言论和其它行为违反或可能违反上述法律和法规的任何规定，本产品可在任何时候不经任何事先通知终止向您提供服务。\n"),
                BoldText("三、联系我们"),
                BoldText("开发者名称：天津大学"),
                Text("微北洋用户社区1(QQ群)：738068756\n"
                    "微北洋用户社区2(QQ群)：738064793\n"
                    "微北洋用户社区3(QQ群)：337647539")
              ]),
            ),
          ),
          SizedBox(height: 13),
          Divider(height: 1, color: ColorUtil.lightBorderColor),
          _detail(context),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context) {
    if (check == null) {
      return WButton(
        onPressed: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(), // 加个这个扩大点击事件范围
          padding: const EdgeInsets.all(16),
          child: Text('确定',
              style: TextUtil.base.bold.noLine.sp(16).oldThirdAction(context)),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WButton(
            onPressed: () {
              check!.value = false;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('拒绝',
                  style: TextUtil.base.bold.unlabeled(context).noLine.sp(16)),
            ),
          ),
          WButton(
            onPressed: () {
              check!.value = true;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('同意',
                  style:
                      TextUtil.base.bold.noLine.sp(16).oldThirdAction(context)),
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
