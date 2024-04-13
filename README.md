# 微北洋APP

![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/twtstudio/WePeiYang-Flutter?color=green)
![GitHub contributors](https://img.shields.io/github/contributors-anon/twtstudio/WePeiYang-Flutter?color=blue)
![GitHub Repo stars](https://img.shields.io/github/stars/twtstudio/WePeiYang-Flutter?logo=star&color=yellow)

## 项目背景

微北洋是由天津大学天外天工作室(移动组)开发运维的校园APP，面向天津大学全体师生，集课表查询、自习室查询、校园公告，GPA查询、失物招领为一体,是每个天大学子都在用的校园掌中宝。

天津大学天外天工作室主页：[微北洋主页](https://mobile.twt.edu.cn/wpy/index.html)（仅限校园网访问）

## 安装 (Installation)

- **正式版**: [官网下载(需要校园网)](https://mobile.twt.edu.cn/wpy/index.html)
- **Preview 通道**:  请访问[Github Action](https://github.com/twtstudio/WePeiYang-Flutter/actions),
  找到最新Build, 选择Summary中的Artifact下载

## 主要功能列表

| 功能                | 描述             |
| ------------------- | ---------------- |
| schedule            | 课程表           |
| map_calender        | 地图校历         |
| wiki                | 北洋wiki入口     |
| gpa                 | GPA查询          |
| lake                | 青年湖底（论坛） |
| studyroom           | 自习室           |
| 考试信息（开发中……) | 考试信息         |
| lost_and_found      | 失物招领         |

## Android 原生内容

## 安装运行

### 运行问题汇总：

[     【教程】在运行WePeiYang - Flutter项目时可能遇到的问题 (持续更新)         ](https://www.cnblogs.com/ZzTzZ/p/17344002.html)

## 开发指南

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

## 当前版本：4。4.1

本期更新内容：

### 比较大的更新记录：

## Git规范

## 其他资源

### 古早版本：

[ WePeiYang-Android 微北洋（安卓版） ](https://github.com/twtstudio/WePeiYang-Android)

[ WePeiYang-iOS-Everest 微北洋（IOS版本）](https://github.com/twtstudio/WePeiYang-iOS-Everest)

## 版权声明

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
