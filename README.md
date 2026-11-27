# 微北洋APP

![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/twtstudio/WePeiYang-Flutter?color=green)
![GitHub contributors](https://img.shields.io/github/contributors-anon/twtstudio/WePeiYang-Flutter?color=blue)
![GitHub Repo stars](https://img.shields.io/github/stars/twtstudio/WePeiYang-Flutter?logo=star&color=yellow)
![GitHub](https://img.shields.io/github/license/twtstudio/WePeiYang-Flutter)

## 项目背景

微北洋是由天津大学天外天工作室(移动组)开发运维的校园APP，面向天津大学全体师生，集课表查询、自习室查询、校园公告，GPA查询、失物招领为一体,是每个天大学子都在用的校园掌中宝。

天津大学天外天工作室主页：[微北洋主页](https://mobile.twt.edu.cn/wpy/index.html)（仅限校园网访问）

## 安装 (Installation)

- **正式版**: [官网下载(需要校园网)](https://mobile.twt.edu.cn/wpy/index.html)
- **Preview 通道**:  请访问[Github Action](https://github.com/twtstudio/WePeiYang-Flutter/actions),
  找到最新Build, 选择Summary中的Artifact下载

## 主要功能列表

| 功能             | 描述       |
|----------------|----------|
| schedule       | 课程表      |
| map_calender   | 地图校历     |
| wiki           | 北洋wiki入口 |
| gpa            | GPA查询    |
| lake           | 青年湖底（论坛） |
| studyroom      | 自习室      |
| 考试信息（开发中……)    | 考试信息     |
| lost_and_found | 失物招领     |
| xiaotian       | 小天AI     |

## Android 原生内容

## 安装运行

### 运行问题汇总：

[     【教程】在运行WePeiYang - Flutter项目时可能遇到的问题 (持续更新)         ](https://www.cnblogs.com/ZzTzZ/p/17344002.html)

## 开发指南

### HarmonyOS

鸿蒙宿主位于 `ohos/`，入口为 `EntryAbility`。各平台共用根目录的
`lib/`、`assets/` 和应用版本。鸿蒙包名沿用 `com.weipeiyang.cn`。

在 Flutter OHOS SDK 环境下，用根目录的 `pubspec.yaml` 解析依赖后运行
`python scripts/prepare_ohos.py`，再执行 `flutter build hap`。
脚本在 `.dart_tool/ohos/` 生成公式渲染依赖的兼容副本。运行
`python scripts/prepare_ohos.py --clear` 可清除脚本生成的依赖覆盖文件。

鸿蒙通过 `@getui/push` 获取个推 CID，并和 Android 一样向 `notification/cid`
提交 `cid`。发布时在 `ohos/entry/src/main/module.json5` 配置
`GETUI_APPID`。启用个推的鸿蒙离线通道还需要配置厂商 `client_id`，
并在个推控制台开通鸿蒙厂商通道。
服务端投递鸿蒙通知时需设置 `push_channel.harmony`，用 `Want` 传已有的微北洋深链，
例如 `wpy://wpy.app/post?id=123` 或 `wpy://wpy.app/mailbox`。
签名和厂商推送配置由发布环境提供。

友盟统计在 `ohos/AppScope/resources/rawfile/umconfig.json` 填写鸿蒙应用的
`appKey` 和渠道，用户同意隐私协议后才启动采集。
鸿蒙页面停留时长以 `wpy_page_view` 自定义事件上报。

在 `ohos/entry/src/main/resources/rawfile/wpy_services.json` 配置两个接口后可启用对应能力。

- `entryQrUrl` 是 `https://api.twt.edu.cn` 上经授权的取码接口，接收
  `Authorization: Bearer <当前会话令牌>`，从会话识别用户并返回
  `{"code":"...","expiresAt":<Unix 毫秒时间戳>}`。未配置时，刷新按钮打开
  应用内校园码页面，卡片会接收该页面最近一次成功取到的有效码。
- `webViewsUrl` 是 HTTPS 接口，返回由 `page`、`url`、`channels`
  组成的 JSON 数组，`channels` 为逗号分隔字符串。拉取失败时使用上一次有效配置；
  未配置接口或没有可用缓存时使用内置 H5 配置。

### [分模块信息](twtstudio/WePeiYang-Flutter/tree/master/lib)

| 文件                                                         | 基建                                             | 常用修改                                           |
| :----------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------- |
| [auth](twtstudio/WePeiYang-Flutter/tree/master/lib/auth)     | 注册登录绑定、个人信息页、设置页面               | 头像框、信息更新重设置、                           |
| [commons](twtstudio/WePeiYang-Flutter/tree/master/lib/commons) | 与手机关联设置、当地缓存、网络请求               | 规定了页面主要外观、字体格式颜色、图标弹窗信息展示 |
| [feedback](twtstudio/WePeiYang-Flutter/tree/master/lib/feedback) | 请求回显                                         | 请求回显                                           |
| [gpa](twtstudio/WePeiYang-Flutter/tree/master/lib/gpa)       | GPA显示                                          | 曲线显示、饼状显示                                 |
| [home](twtstudio/WePeiYang-Flutter/tree/master/lib/home)     | 主页                                             | 主要功能展示、活动弹窗                             | 
| [message](twtstudio/WePeiYang-Flutter/tree/master/lib/message) | 消息列表                                         | 一键已读                                           |
| [schedule](twtstudio/WePeiYang-Flutter/tree/master/lib/schedule) | 小窗展示、主页面展示课程安排、课程细节、考试信息 | 夜猫子模式、考试信息                               |
| [studyroom](twtstudio/WePeiYang-Flutter/tree/master/lib/studyroom) | 自习室信息                                       |                                                    |
| [main.dart](twtstudio/WePeiYang-Flutter/blob/master/lib/main.dart) | 程序入口、初始化，启动！                         | 启动页设置                                         |

目前代码质量较高的模块有xx 。里面的代码涵盖了xx的用法，xx的高级使用方式，架构的抽象封装，自定义 View 等。 如果不知道从哪里做起，可以先从xx看起，然后一步步追溯到 xxx，看处理方式。

看代码可以用两种方法：自顶向下和自下而上。

### 应用依赖关系

多个模块需要使用的依赖放在 `commons` 模块里，使用 api 关键字添加依赖，以暴露给其他模块。

`app` 模块依赖包括 `commons` 模块在内的其他所有模块，其他模块依赖  `commons` 模块，以获取应用内框架的依赖和公共依赖。

### 应用内框架

应用内框架集中在 `commons` 模块中

### 网络请求

微北洋中网络请求统一使用xxx

### 泛型包装

## 开发规范

### 架构

| 文件分类  |                  |
| --------- | ---------------- |
| extension | 延申条件         |
| model     | 定义元素结构行为 |
| network   | 网络请求部分     |
| util      | 使用工具打包     |
| page      | 展示信息         |
| view      | 页面布局         |
| …         |                  |

### 依赖规范

### 命名规范

## 当前版本：4.4.8

本期更新内容：

### 比较大的更新记录：

## Git规范

## 其他资源

### 古早版本：

[ WePeiYang-Android 微北洋（安卓版） ](https://github.com/twtstudio/WePeiYang-Android)

[ WePeiYang-iOS-Everest 微北洋（IOS版本）](https://github.com/twtstudio/WePeiYang-iOS-Everest)

## 版权声明

本项目采用 [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)（GPL-3.0-or-later）开源许可。

- 本软件为自由软件：您可以自由地使用、复制、修改、分发，并可在遵守许可证条款的前提下将其用于商业用途。
- 任何对本软件的修改或衍生作品，必须同样以 GPL 许可证发布，并向使用者公开源代码。
- 本软件按"原样"提供，不附带任何明示或暗示的担保，包括但不限于适销性和特定用途适用性的担保。详情请参阅 [LICENSE](./LICENSE) 文件。

Copyright (C) 天津大学天外天工作室（移动组）。

## Star History

<a href="https://star-history.com/#twtstudio/WePeiYang-Flutter&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=twtstudio/WePeiYang-Flutter&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=twtstudio/WePeiYang-Flutter&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=twtstudio/WePeiYang-Flutter&type=Date" />
  </picture>
</a>

## 备案号

津ICP备05004358号-18A(https://beian.miit.gov.cn/)       



## 一些没有用的东西
Here is the 7th flag:
flag7{bmcgQzMwMSBhbnl0aW1lISBX}
