import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class RegisterDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    var textColor = Color.fromRGBO(98, 103, 124, 1);
    return Container(
        width: GlobalModel().screenWidth - 70,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: 40, vertical: GlobalModel().screenHeight / 10),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(251, 251, 251, 1)),
        child: Column(
          children: [
            Expanded(
              child: DefaultTextStyle(
                textAlign: TextAlign.start,
                style: FontManager.YaHeiRegular.copyWith(
                    color: textColor, fontSize: 13),
                child: ListView(physics: BouncingScrollPhysics(), children: [
                  Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(top: 20, bottom: 18),
                      child: Text(S.current.register_hint2,
                          style: FontManager.YaHeiRegular.copyWith(
                              color: textColor, fontSize: 18))),
                  Text("更新日期：2021年02月26日" + "生效日期：2021年02月26日\n"),
                  Text("一．引言\n" +
                      "微北洋自推出以来连接全校师生，带来学习与生活的便捷。" +
                      "微北洋致力于为用户提供一个绿色、安全、健康、便捷的校园平台，" +
                      "为了实现这一目标，我们基于以下原则制定了《微北洋用户须知》，" +
                      "声明用户的权利与义务，对违规行为进行处理，维护用户及其他主体的合法权益。\n"),
                  Text("为共同营造绿色、安全、健康、清朗的网络环境，请仔细阅读并遵守相关规定。\n"),
                  Text("如果你发现任何违规行为或内容，可以通过天外天微信公众号、用户社群、" +
                      "开发者邮箱等渠道发起投诉。我们收到投诉后，将对相关投诉进行审核。" +
                      "如违反规则，我们可能对帐号或内容停止提供服务。对于违反规则的用户，" +
                      "微北洋将视违规程度，可能停止提供违规内容在微北洋继续展示、传播的服务，" +
                      "予以警告，并可能停止对你的帐号提供服务。\n"),
                  Text("二．微北洋软件使用规范\n" +
                      "用户在使用微北洋软件的过程中不得实施影响其他用户体验、危及平台安全、" +
                      "损害他人权益的行为。一经发现，我们将根据违规程度对帐号采取相应的处理措施，" +
                      "并有权拒绝向违规帐号主体提供服务。如：限制与该主体相关帐号功能、封禁与该主体相关帐号等。"),
                  Text("1. 合理、善意注册使用微北洋\n" +
                      "你应当合理、善意注册并使用微北洋帐号，" +
                      "不得恶意注册或将天外天帐号用于非法或不正当用途。\n" +
                      "1.1 官方渠道注册。用户须通过i.twt.edu.cn注册天外天帐号登录微北洋。\n" +
                      "1.2 不得恶意注册、使用天外天帐号。用户不得实施恶意注册、使用天外天帐号的行为，" +
                      "您不得对账号进行任何形式的许可、出售、租赁、转让、发行或其他商业用途；" +
                      "您不得删除或破坏包含在本产品中的任何版权声明或其他所有权标记。" +
                      "用户不得冒充他人；不得利用他人的名义发布任何信息。\n"),
                  Text("2. 数据获取、使用规范\n" +
                      "2.1 个人隐私\n" +
                      "2.1.1 当您登录办公网使用微北洋服务时，我们会收集您的姓名、学院信息、" +
                      "入学年份、专业、班级。收集这些信息是为了给您提供相应的服务。" +
                      "若您不提供这类信息，您无法正常使用我们提供的所有服务。\n" +
                      "2.1.2 在您使用微北洋校务专区服务期间，您可能会在发布页面中发布照片。" +
                      "在已知的需要上传照片的模块中，当您需要对照片进行选择上传时，" +
                      "我们会收集您通过相册权限主动上传的照片信息，即需要您授权我们读取您的相册权限。" +
                      "如果您拒绝授权仅会使您无法使用该功能，但不影响您正常使用微北洋其他功能。\n" +
                      "2.1.3 当您使用校务专区、失物招领功能时，我们会收集您上传的动图、照片、" +
                      "帖子、评论、点赞信息。您也可以随时删除这些信息。\n" +
                      "2.1.4 当您使用自定义课程、蹭课功能时，我们会收集您编辑的信息。您也可以随时删除这些信息。\n" +
                      "2.1.5 当您使用自习室功能时，若您需要收藏自习室，我们会请求您的手机存储权限" +
                      "并将此信息存储在您的手机本地；若您退出天外天账号，则该信息会自动删除；" +
                      "若您拒绝授权则会影响收藏自习室这一功能的正常使用，但不影响您正常使用自习室查询的功能。\n" +
                      "2.2 数据使用规范\n" +
                      "2.2.1 微北洋保证不对外公开或向第三方透露用户个人隐私信息，或用户在使用服务时存储的非公开内容。\n" +
                      "2.2.2 请您注意，我们不会主动从第三方获取您的个人信息。\n" +
                      "2.2.3 在涉及国家安全与利益、社会公共利益、与犯罪侦查有关的相关活动、" +
                      "您或他人生命财产安全但在特殊情况下无法获得您的及时授权、能够从其他合法公开的渠道、" +
                      "法律法规规定的其他情形下，微北洋可能在不经过您的同意或授权的前提下，向相关部门提供您的个人信息。\n"),
                  Text("3.关于校务专区的使用规范\n" +
                      "3.1 严禁发布法律法规禁止的内容 用户不得制作、复制、发布、" +
                      "传播法律法规禁止的内容。以下规定非常重要，请用户特别留意！\n" +
                      "3.1.1 违反或反对宪法确定的基本原则、社会主义制度的；\n" +
                      "3.1.2 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一、主权和领土完整的；\n" +
                      "3.1.3 损害国家荣誉和利益的；\n" +
                      "3.1.4 煽动民族仇恨、民族歧视，破坏民族团结的；\n" +
                      "3.1.5 破坏国家宗教政策，宣扬邪教和封建迷信的；\n" +
                      "3.1.6 散布谣言，扰乱社会秩序，破坏社会稳定的；\n" +
                      "3.1.7 散布淫秽、色情、赌博、暴力、恐怖或者教唆犯罪的；\n" +
                      "3.1.8 侮辱或者诽谤他人，侵害他人合法权益的；\n" +
                      "3.1.9 煽动非法集会、结社、游行、示威、聚众扰乱社会秩序；\n" +
                      "3.1.10 以非法民间组织名义活动的；\n" +
                      "3.1.11 不符合《即时通信工具公众信息服务发展管理暂行规定》及其他相关法律法规要求的。\n" +
                      "3.1.12 含有法律、行政法规禁止的其他内容的。\n" +
                      "3.2 在您使用微北洋服务的过程中应当遵守相关的法律法规，尊重道德和风俗习惯，" +
                      "维护良好的校园民主建议、民主监督的氛围；热情参与，独立思考，合理审慎地表达的意见与建议。" +
                      "如果你的行为违反了法律法规、道德风俗、校园秩序，你应当为此独立承担责任。\n"),
                  Text("三、免责声明\n" +
                      "微北洋用户明确了解并同意： 微北洋app为用户所提供的课程、GPA、自习室等信息，" +
                      "均来自于天津大学教育信息管理中心、教务网站。我们尽可能保证为您提供最准确、及时、稳定的信息，" +
                      "一切准确信息以以上两个官方网站为准；若有错缺，请用户自行比对注意，" +
                      "由此造成的损失天外天工作室不承担任何责任。\n" +
                      "关于微北洋服务天外天工作室不提供" +
                      "任何种类的明示或暗示担保或条件，你对微北洋服务的使用行为必须自行承担相应风险。\n"),
                  Text("四、联系我们\n" +
                      "微北洋用户社区(QQ群)：738068756\n" +
                      "微北洋用户社区2(QQ群)：738064793")
                ]),
              ),
            ),
            Container(
              height: 1.0,
              margin: const EdgeInsets.symmetric(vertical: 13),
              color: Color.fromRGBO(172, 174, 186, 1),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(S.current.ok,
                    style: FontManager.YaQiHei.copyWith(
                        color: Color.fromRGBO(98, 103, 123, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none)),
              ),
            )
          ],
        ));
  }
}
