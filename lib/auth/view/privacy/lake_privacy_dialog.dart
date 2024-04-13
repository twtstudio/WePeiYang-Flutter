import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class LakePrivacyDialog extends Dialog {
  final ValueNotifier? check;

  LakePrivacyDialog({this.check});

  @override
  Widget build(BuildContext context) {
    var textColor = WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
          horizontal: 30, vertical: WePeiYangApp.screenHeight / 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
      child: Column(
        children: [
          Expanded(
            child: DefaultTextStyle(
              textAlign: TextAlign.start,
              style: TextUtil.base.regular.sp(13).customColor(textColor),
              child: ListView(children: [
                Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 20, bottom: 18),
                    child: Text("求实论坛社区规范",
                        style: TextUtil.base.regular
                            .sp(18)
                            .customColor(textColor))),
                Text("更新时间：2022-03-03\n" + "生效日期：2022-03-03\n"),
                Text(
                    "求实论坛致力于提供一个由用户和学校共同创造的高质量问答社区。为了保护用户合法权益，营造一个多元、向上、真实的社区氛围，求实论坛团队根据法律法规，包括但不限于《中华人民共和国网络安全法》、《互联网信息服务管理办法》、《互联网直播服务管理规定》、《互联网危险物品信息发布管理规定》、《网络短视频内容审核标准细则》、《网络信息内容生态治理规定》等相关内容的规定，并结合普通高等学校相关管理规定。对用户发布的信息和用户行为，进行合规审核和管理。为了保障您的使用体验，您应当在使用求实论坛提供的服务前完整、充分阅读本规范。\n"),
                Text(
                  "一．定义\n",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                    "2.“内容” 指用户在使用社区功能的过程中上传、发布的任何内容，包括但不限于文字、图片、链接、媒体等；包括发帖和评论。\n"),
                Text("3.“账户” 指一组具有访问社区权限的身份信息。\n"),
                Text(
                    "4.“社区管理团队” （或管理团队）指对求实论坛进行运营和管理的团队。管理团队成员称为“社区管理员”，简称为“管理员”。\n"),
                Text(
                  "二．违规行为界定\n",
                  style: TextStyle(fontSize: 20),
                ),
                RichText(
                    text: TextSpan(
                        text: "1.违反法律法规：发布违反国家",
                        style:
                            TextUtil.base.regular.sp(13).customColor(textColor),
                        children: [
                      TextSpan(
                        text: "相关法律法规",
                        style: TextUtil.base.normal.NotoSansSC
                            .sp(14)
                            .w400
                            .textButtonPrimary(context),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url =
                                'https://link.zhihu.com/?target=http://www.cac.gov.cn/2016-06/25/c_1119109085.htm';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              ToastProvider.error('请检查网络状态');
                            }
                          },
                      ),
                      TextSpan(text: "及"),
                      TextSpan(
                        text: "「七条底线」",
                        style: TextUtil.base.normal.NotoSansSC
                            .sp(14)
                            .w400
                            .textButtonPrimary(context),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url =
                                'https://link.zhihu.com/?target=http://www.isc.org.cn/zxzx/xhdt/listinfo-27187.html';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              ToastProvider.error('请检查网络状态');
                            }
                          },
                      ),
                      TextSpan(text: "、"),
                      TextSpan(
                        text: "「九不准」",
                        style: TextUtil.base.normal.NotoSansSC
                            .sp(14)
                            .w400
                            .textButtonPrimary(context),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url =
                                'https://link.zhihu.com/?target=http://www.cac.gov.cn/2000-09/30/c_126193701.htm';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              ToastProvider.error('请检查网络状态');
                            }
                          },
                      ),
                      TextSpan(text: "管理规定的信息，主要表现为：\n"),
                    ])),
                Text("•反对宪法所确定的基本原则。\n"
                    "•危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一。\n"
                    "•损害国家荣誉和利益。\n"
                    "•煽动民族仇恨、民族歧视，破坏民族团结。\n"
                    "•侮辱、滥用英烈形象，否定英烈事迹，美化粉饰侵略战争行为的。\n"
                    "•破坏国家宗教政策，宣扬邪教和封建迷信。\n"
                    "•散布谣言，扰乱社会秩序，破坏社会稳定。\n"
                    "•宣扬淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪。\n"
                    "•煽动非法集会、结社、游行、示威、聚众扰乱社会秩序。\n"
                    "•诽谤他人，泄露他人隐私，侵害他人合法权益。\n"
                    "•含有法律、行政法规禁止的其他内容的信息。\n"
                    "•含有法律、行政法规禁止的其他内容的信息。\n"),
                Text(
                  "发表违反国家法律法规的内容将根据严重程度受到禁言7天/14天/30天/永久封禁的处罚。\n",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("2.不友善行为，主要表现为：\n"
                    "•人身攻击及辱骂他人。\n"
                    "•针对以下群体发表诅咒、歧视、漠视生命尊严等性质的言论，群体包括：国籍、地域、性别、性别认同、性倾向、种族、疾病、宗教、残障群体等。\n"
                    "•对他人进行诅咒、恐吓或威胁，尤其是死亡威胁。\n"
                    "•针对其他用户的私德、观点立场、素质、能力等方面的贬低或不尊重。\n"
                    "•讽刺其他用户，阴阳怪气地表达批评。\n"
                    "•对其他用户创作的内容直接进行贬低性的评论。\n"
                    "•对其他用户使用粗俗用语，并产生了冒犯。\n"
                    "•针对以下群体发表偏见性质的言论，群体包括：国籍、地域、性别、性别认同、性倾向、种族、疾病、宗教、残疾人群体等。\n"),
                Text(
                  "有以上行为者将根据严重程度受到禁言3天/7天/14天/30天或永久封禁的处罚。\n",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("3.发布垃圾广告信息：用户以推广曝光为目的，发布影响用户体验、扰乱求实论坛社区秩序的内容，或进行相关行为。\n"
                    "•多次发布包含售卖产品、提供服务、宣传推广内容的垃圾广告。包括但不限于以下几种形式：\n"
                    " ￮单个帐号多次发布包含垃圾广告的内容；\n"
                    " ￮多个广告帐号互相配合发布包含垃圾广告的内容；\n"
                    " ￮多次发布包含欺骗性外链的内容，如未注明的淘宝客链接、跳转网站等，诱骗用户点击链接；\n"),
                RichText(
                    text: TextSpan(
                        text: " ￮发布大量包含 SEO 推广链接、产品、品牌等内容获取",
                        style:
                            TextUtil.base.regular.sp(13).customColor(textColor),
                        children: [
                      TextSpan(
                        text: "搜索引擎",
                      ),
                      TextSpan(text: "中的不正当曝光。\n"),
                    ])),
                Text("•购买或出售帐号之间虚假地互动，发布干扰社区秩序的推广内容及相关交易。包括但不限于以下几种形式：\n"
                    " ￮购买机器注册帐号，或人工操控帐号的关注，伪造在社区内的影响力；\n"
                    " ￮购买机器注册帐号，或人工操控帐号点击赞同，谋求回答的不正当曝光；\n"
                    " ￮使用机器、恶意程序手段或人为有组织性地操控帐号进行点赞、回答等扰乱秩序的行为。\n"
                    "使用严重影响用户体验的违规手段进行恶意营销。包括但不限于以下几种形式：\n"
                    " ￮不规范转载或大篇幅转载他人内容同时加入推广营销内容；\n"
                    " ￮发布包含欺骗性的恶意营销内容，如通过伪造经历、冒充他人等方式进行恶意营销。\n"
                    "•使用特殊符号、图片等方式规避垃圾广告内容审核的广告内容。\n"
                    "•恶意注册使用天外天帐号，包括但不限于机器注册、频繁注册、批量注册、滥用多个天外天帐号。\n"),
                Text(
                  "发布垃圾广告信息将受到禁言1天/3天/7天的处罚，屡发不止或是频繁发布同一商业推广内容的，将受到永久封禁处罚。\n",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                RichText(
                    text: TextSpan(
                        text: "4.恶意行为：滥用产品功能，进行影响用户体验，危及平台安全及损害他人权益的行为。主要表现为：\n"
                            "•",
                        style:
                            TextUtil.base.regular.sp(13).customColor(textColor),
                        children: [
                      TextSpan(
                        text: "恶意编辑",
                      ),
                      TextSpan(
                          text: "，指清空或删除有效内容，添加无关信息，破坏内容结构等降低公共编辑内容质量的编辑。\n"),
                    ])),
                Text("•冒充他人，通过头像、用户名等个人信息暗示自己与他人或机构相等同或有关联。\n"
                    "•重复发布干扰正常用户体验的内容。包括但不限于以下几种形式：\n"
                    " ￮重复的回答内容多次发布在不同问题下；\n"
                    " ￮频繁发布难以辨识涵义影响阅读体验的字符、数字等无意义乱码；\n"
                    " ￮骚扰他人，以评论、@他人、私信等方式对他人反复发送重复或者相似的诉求。\n"
                    "法律法规规定的其他情形下，微北洋可能在不经过您的同意或授权的前提下，向相关部门提供您的个人信息。\n"
                    "•制作及传播外挂或者用于操作帐号功能的恶意程序或相关教程。\n"
                    "•发布含有潜在危险的内容，或使用第三方网站伪造跳转链接，如钓鱼网站、木马、病毒网站等。\n"
                    "•恶意对抗行为，包括但不限于使用变体、谐音等方式规避安全审查，明知相关行为违反法律法规和社区规范仍然多次发布等。\n"
                    "•引战行为，包括但不限于通过敏感话题带节奏，误导大众，引导舆论风向，或者对用户调拨离间，蓄意破坏用户间和谐，故意发布具有引战行为的内容。\n"),
                Text(
                  "有以上行为者将根据情节严重程度受到禁言3天/7天/14天或永久封禁的处罚。\n",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  "三、违规处理\n",
                  style: TextStyle(fontSize: 20),
                ),
                Text("1.用户发布的主题帖或回复帖，经判定为违反所述管理规范的，将予以删除。\n"),
                RichText(
                    text: TextSpan(
                        text: "2.违规用户将受",
                        style:
                            TextUtil.base.regular.sp(13).customColor(textColor),
                        children: [
                      TextSpan(
                        text: "禁言1天/禁言3天/禁言7天/14天/30天或永久封禁",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: "的禁言处罚，禁言即禁止发帖和评论，其他微北洋功能不受此限制影响。\n"),
                      TextSpan(
                          text:
                              "3.在禁言期间有另一内容被删除，处罚时间累加计算，即处罚时间在最后一次期满时间基础上计算。\n"
                              "4.屡次违反求实论坛规范、超出一定累计封禁次数的用户，社区管理团队有权"),
                      TextSpan(
                          text: "永久封禁",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: "该用户。\n"),
                      TextSpan(text: "5.严重违反求实论坛规范，大量发布违规信息的用户，社区管理团队有权"),
                      TextSpan(
                          text: "永久封禁",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: "该用户。\n"),
                      TextSpan(text: "6.当用户出现以下行为时，将会受到"),
                      TextSpan(
                          text: "加重处罚",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: "：\n"),
                    ])),
                Text(" •含有本规范所述多个违规行为；\n"
                    " •通过作弊手段注册、使用的帐号；\n"
                    " •滥用多个天外天帐号。\n"
                    " •恶意冒充天外天有关人员（官方管理团队、开发者等）。\n"
                    "7.用户被处罚后，有权获取具体的处罚信息，包括决定的依据、处罚时间。\n"
                    "8.管理团队有权对任何处罚进行调整，并保留解释权。\n"
                    "四、附则\n"
                    "1.本规范适用于求实论坛（包括APP板块和小程序）全体用户。\n"
                    "2.求实论坛社区管理团队承担管理具体职责，依据本规范对社区进行管理。\n"
                    "3.用户在注册和使用中产生的身份信息，管理团队未经用户允许，不主动查询、使用、透露、公开用户个人信息，如学号、姓名、专业等，但以下特定情形除外：\n"
                    " •用户转让、出租、出售个人或者个人账户导致的个人信息泄露。\n"
                    " •为维护社会公共利益、校园安全稳定以及个人人身安全。\n"
                    " •根据相关法律法规或政策的要求。\n"
                    "4.天外天账号仅供本人使用。使用天外天工作室提供的任何网络服务即同意:\n"
                    " •天外天账号的持有者为天津大学相关用户，包括但不限于在校学生、教师、职工等；用户离开天津大学时（如毕业等情况），即同意天外天工作室有权冻结、注销相关账号访问权限。\n"
                    " •用户不得以任何形式出借、出租、转让天外天账号。\n"
                    " •不得使用非官方的客户端、脚本等访问方式，未经天外天工作室明确许可，访问天外天的相关服务、下载天外天工作室服务提供的相关内容；使用非官方途径访问天外天工作室的服务的用户经查实且对天外天工作室造成不利影响时，天外天工作室有权封禁账号相关使用权限，并追究法律责任。\n"
                    " •任何人未经工作室团队许可，不得擅自将求实论坛内容向天津大学校外人员或求实论坛用户以外的用户传播。违者造成恶劣影响的，天外天工作室有权调查、封禁传播人账户，并追究法律责任。\n"
                    "5.本规范由求实论坛管理团队负责解释。\n"
                    "6.本规范不构成对相关法律法规和高校规章的任何有效修改，如有冲突，应以相关法律法规与制度文件为准。\n"
                    "7. 本规定自发布之日（2022年03月03日）起施行。\n"),
              ]),
            ),
          ),
          SizedBox(height: 13),
          Divider(
              height: 1,
              color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
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
          child: Text('ok',
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
