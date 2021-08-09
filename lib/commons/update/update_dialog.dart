import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateDialog {
  bool _isShowing = false;
  BuildContext _context;
  UpdateWidget _widget;

  UpdateDialog(BuildContext context,
      {double width = 0.0,
      @required String title,
      @required String updateContent,
      @required VoidCallback onUpdate,
      double titleTextSize = 16.0,
      double contentTextSize = 14.0,
      double buttonTextSize = 14.0,
      double progress = -1.0,
      Color progressBackgroundColor = const Color(0xFFFFCDD2),
      Image topImage,
      double extraHeight = 5.0,
      double radius = 4.0,
      Color themeColor = Colors.red,
      bool enableIgnore = false,
      VoidCallback onIgnore,
      bool isForce = false,
      String updateButtonText,
      String ignoreButtonText,
      VoidCallback onClose,
      Version version}) {
    _context = context;
    _widget = UpdateWidget(
      width: width,
      title: title,
      updateContent: updateContent,
      onUpdate: onUpdate,
      titleTextSize: titleTextSize,
      contentTextSize: contentTextSize,
      buttonTextSize: buttonTextSize,
      progress: progress,
      topImage: topImage,
      extraHeight: extraHeight,
      radius: radius,
      themeColor: themeColor,
      progressBackgroundColor: progressBackgroundColor,
      enableIgnore: enableIgnore,
      onIgnore: onIgnore,
      isForce: isForce,
      updateButtonText: updateButtonText ?? '点击更新',
      ignoreButtonText: ignoreButtonText ?? '忽略此版本',
      onClose: onClose != null ? onClose : () => {dismiss()},
      version: version,
    );
  }

  /// 显示弹窗
  Future<bool> show() {
    try {
      if (isShowing()) {
        return Future.value(false);
      }
      showDialog(
          context: _context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _widget;
          });
      _isShowing = true;
      return Future.value(true);
    } catch (err) {
      _isShowing = false;
      return Future.value(false);
    }
  }

  /// 隐藏弹窗
  Future<bool> dismiss() {
    try {
      if (_isShowing) {
        _isShowing = false;
        Navigator.pop(_context);
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (err) {
      return Future.value(false);
    }
  }

  /// 是否显示
  bool isShowing() {
    return _isShowing;
  }

  /// 更新进度
  void update(double progress) {
    if (isShowing()) {
      _widget.update(progress);
    }
  }

  /// 显示版本更新提示框
  static UpdateDialog showUpdate(
    BuildContext context, {
    double width = 0.0,
    @required String title,
    @required String updateContent,
    @required VoidCallback onUpdate,
    double titleTextSize = 16.0,
    double contentTextSize = 14.0,
    double buttonTextSize = 14.0,
    double progress = -1.0,
    Color progressBackgroundColor = const Color(0xFFFFCDD2),
    Image topImage,
    double extraHeight = 5.0,
    double radius = 4.0,
    Color themeColor = Colors.red,
    bool enableIgnore = false,
    VoidCallback onIgnore,
    String updateButtonText,
    String ignoreButtonText,
    bool isForce = false,
    Version version,
  }) {
    UpdateDialog dialog = UpdateDialog(
      context,
      width: width,
      title: title,
      updateContent: updateContent,
      onUpdate: onUpdate,
      titleTextSize: titleTextSize,
      contentTextSize: contentTextSize,
      buttonTextSize: buttonTextSize,
      progress: progress,
      topImage: topImage,
      extraHeight: extraHeight,
      radius: radius,
      themeColor: themeColor,
      progressBackgroundColor: progressBackgroundColor,
      enableIgnore: enableIgnore,
      isForce: isForce,
      updateButtonText: updateButtonText,
      ignoreButtonText: ignoreButtonText,
      onIgnore: onIgnore,
      version: version,
    );
    dialog.show();
    return dialog;
  }
}

// ignore: must_be_immutable
class UpdateWidget extends StatefulWidget {
  /// 对话框的宽度
  final double width;

  /// 升级标题
  final String title;

  /// 更新内容
  final String updateContent;

  /// 标题文字的大小
  final double titleTextSize;

  /// 更新文字内容的大小
  final double contentTextSize;

  /// 按钮文字的大小
  final double buttonTextSize;

  /// 顶部图片
  final Widget topImage;

  /// 拓展高度(适配顶部图片高度不一致的情况）
  final double extraHeight;

  /// 边框圆角大小
  final double radius;

  /// 主题颜色
  final Color themeColor;

  /// 更新事件
  final VoidCallback onUpdate;

  /// 可忽略更新
  final bool enableIgnore;

  /// 更新事件
  final VoidCallback onIgnore;

  double progress;

  /// 进度条的背景颜色
  final Color progressBackgroundColor;

  /// 更新事件
  final VoidCallback onClose;

  /// 是否是强制更新
  final bool isForce;

  /// 更新按钮内容
  final String updateButtonText;

  /// 忽略按钮内容
  final String ignoreButtonText;

  final Version version;

  UpdateWidget({
    Key key,
    this.width = 0.0,
    @required this.title,
    @required this.updateContent,
    @required this.onUpdate,
    this.titleTextSize = 16.0,
    this.contentTextSize = 14.0,
    this.buttonTextSize = 14.0,
    this.progress = -1.0,
    this.progressBackgroundColor = const Color(0xFFFFCDD2),
    this.topImage,
    this.extraHeight = 5.0,
    this.radius = 4.0,
    this.themeColor = Colors.red,
    this.enableIgnore = false,
    this.onIgnore,
    this.isForce = false,
    this.updateButtonText = '点击更新',
    this.ignoreButtonText = '忽略此版本',
    this.onClose,
    this.version,
  }) : super(key: key);

  _UpdateWidgetState _state = _UpdateWidgetState();

  update(double progress) {
    _state.update(progress);
  }

  @override
  _UpdateWidgetState createState() => _state;
}

class _UpdateWidgetState extends State<UpdateWidget> {
  update(double progress) {
    if (!mounted) {
      return;
    }
    setState(() {
      widget.progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = getFitWidth(context) * 0.7;
    // double dialogHeight = dialogWidth * 0.82;
    List<Widget> contentList = [];
    widget.version.content.split("-").forEach((item) {
      if (item.isNotEmpty) {
        contentList.add(Text(
          "${contentList.length + 1}.${item.trim()}",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF62677b),
          ),
        ));
      }
    });
    Widget contents = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentList,
    );

    Widget versionText = Row(
      children: [
        Text(
          "版本：",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF62677b),
          ),
        ),
        FutureBuilder(
          future: CommonUtils.getVersion(),
          builder: (_, AsyncSnapshot<String> snapshot) {
            Widget versionText;
            if (snapshot.hasData) {
              versionText = Text(
                // widget.updateContent,
                "${snapshot.data} => ${widget.version.version}",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF62677b),
                ),
              );
            } else {
              versionText = Container();
            }
            return versionText;
          },
        ),
      ],
    );

    Widget updateButton = FractionallySizedBox(
      widthFactor: 1,
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 0,
        highlightElevation: 0,
        child: Text(
          widget.updateButtonText,
          style: TextStyle(
            fontSize: widget.buttonTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        color: Colors.transparent,
        textColor: Color(0xff62677b),
        onPressed: widget.onUpdate,
      ),
    );

    return Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: dialogWidth,
              // constraints: BoxConstraints(minHeight: dialogHeight),
              // height: dialogHeight,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.radius + 10),
                  image: DecorationImage(
                      image: AssetImage('assets/images/account/rocket.png'),
                      fit: BoxFit.none)),
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    Positioned(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/account/close.png',
                            width: 20,
                          ),
                        ),
                      ),
                      right: 0,
                      top: 10,
                    ),
                    SizedBox(
                      width: dialogWidth * 0.66,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "版本更新",
                              style: TextStyle(
                                fontSize: widget.titleTextSize,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4f586b),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "更新内容",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF62677b),
                                ),
                              ),
                              contents,
                              versionText,
                            ],
                          ),
                          SizedBox(height: 15),
                          Divider(
                            height: 3,
                            thickness: 3,
                            color: Color(0xffACAEBA),
                          ),
                          SizedBox(height: 5),
                          widget.progress < 0
                              ? updateButton
                              : NumberProgress(
                                  value: widget.progress,
                                  backgroundColor:
                                      widget.progressBackgroundColor,
                                  valueColor: widget.themeColor,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  double getFitWidth(BuildContext context) {
    return getScreenWidth(context);
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}

class NumberProgress extends StatelessWidget {
  /// 进度条的高度
  final double height;

  /// 进度
  final double value;

  /// 进度条的背景颜色
  final Color backgroundColor;

  /// 进度条的色值
  final Color valueColor;

  /// 文字的颜色
  final Color textColor;

  /// 文字的大小
  final double textSize;

  /// 文字的对齐方式
  final AlignmentGeometry textAlignment;

  /// 边距
  final EdgeInsetsGeometry padding;

  NumberProgress(
      {Key key,
      this.height = 10.0,
      this.value = 0.0,
      this.backgroundColor,
      this.valueColor,
      this.textColor = Colors.white,
      this.textSize = 8.0,
      this.padding = EdgeInsets.zero,
      this.textAlignment = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(height)),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                ),
              ),
            ),
            Container(
              height: height,
              alignment: textAlignment,
              child: Text(
                value >= 1 ? '100%' : '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: textColor,
                  fontSize: textSize,
                ),
              ),
            ),
          ],
        ));
  }
}
