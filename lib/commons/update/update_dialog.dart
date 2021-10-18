import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/main.dart';

class UpdateDialog {
  bool isShowing = false;
  BuildContext _context;
  UpdateWidget _widget;

  /// 显示弹窗
  Future<bool> show() {
    try {
      if (isShowing) {
        return Future.value(false);
      }
      showDialog(
          context: _context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _widget;
          });
      isShowing = true;
      return Future.value(true);
    } catch (err) {
      isShowing = false;
      return Future.value(false);
    }
  }

  /// 隐藏弹窗
  Future<bool> dismiss() {
    try {
      if (isShowing) {
        isShowing = false;
        Navigator.pop(_context);
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (err) {
      return Future.value(false);
    }
  }

  /// 更新进度
  void update(double progress) {
    if (isShowing) {
      _widget.update(progress);
    }
  }

  UpdateDialog(BuildContext context,
      {@required VoidCallback onUpdate,
      @required VoidCallback onInstall,
      Version version}) {
    _context = context;
    _widget = UpdateWidget(
      onUpdate: onUpdate,
      onInstall: onInstall,
      version: version,
    );
  }

  /// 显示版本更新提示框
  static UpdateDialog showUpdate(
    BuildContext context, {
    @required VoidCallback onUpdate,
    @required VoidCallback onInstall,
    Version version,
  }) {
    UpdateDialog dialog = UpdateDialog(
      context,
      onUpdate: onUpdate,
      onInstall: onInstall,
      version: version,
    );
    dialog.show();
    return dialog;
  }
}

class UpdateWidget extends StatefulWidget {
  /// 更新事件
  final VoidCallback onUpdate;

  final VoidCallback onInstall;

  /// 更新按钮内容
  final String updateButtonText;

  final String installButtonText;

  final Version version;

  UpdateWidget({
    @required this.onUpdate,
    this.updateButtonText = '点击更新',
    this.installButtonText = '安装',
    this.version,
    this.onInstall,
  });

  final _UpdateWidgetState _state = _UpdateWidgetState();

  update(double progress) => _state.update(progress);

  @override
  _UpdateWidgetState createState() => _state;
}

class _UpdateWidgetState extends State<UpdateWidget> {
  double progress = -1.0;

  update(double progress) {
    if (!mounted) return;
    setState(() {
      this.progress = progress;
    });
  }

  static const titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xff4f586b),
  );

  static const normalStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF62677b),
  );

  static const detailStyle = TextStyle(
    fontSize: 12,
    color: const Color(0xFF62677b),
  );

  @override
  Widget build(BuildContext context) {
    double dialogWidth = WePeiYangApp.screenWidth * 0.7;
    String versionDetail = '更新内容:';
    int index = 0;
    widget.version.content.split("-").forEach((item) {
      if (item.isNotEmpty) {
        versionDetail =
            versionDetail + '\n' + (index > 0 ? '$index. ' : '') + item.trim();
      }
      index++;
    });

    var updateButton = FractionallySizedBox(
      widthFactor: 1,
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 0,
        highlightElevation: 0,
        child: Text(widget.updateButtonText, style: normalStyle),
        color: Colors.transparent,
        onPressed: widget.onUpdate,
      ),
    );

    var installButton = FractionallySizedBox(
      widthFactor: 1,
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 0,
        highlightElevation: 0,
        child: Text(widget.installButtonText, style: normalStyle),
        color: Colors.transparent,
        onPressed: widget.onInstall,
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: dialogWidth,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20),
                        Center(child: Text("版本更新", style: titleStyle)),
                        SizedBox(height: 15),
                        Text(versionDetail, style: detailStyle),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Text("版本: ", style: detailStyle),
                            FutureBuilder(
                                future: CommonUtils.getVersion(),
                                builder: (_, AsyncSnapshot<String> snapshot) =>
                                    snapshot.hasData
                                        ? Text(
                                            "${snapshot.data} => ${widget.version.version}",
                                            style: detailStyle)
                                        : Container()),
                          ],
                        ),
                        SizedBox(height: 3),
                        Divider(
                          height: 3,
                          thickness: 3,
                          color: const Color(0xffACAEBA),
                        ),
                        SizedBox(height: 5),
                        progress < 0
                            ? updateButton
                            : progress == 0
                                ? Center(child: Text("请稍等", style: normalStyle))
                                : progress >= 1.0
                                    ? installButton
                                    : NumberProgress(progress),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberProgress extends StatelessWidget {
  /// 进度
  final double value;

  /// 进度条的高度
  final double height = 10;

  /// 进度条的背景颜色
  final Color backgroundColor = const Color(0xFFFFCDD2);

  /// 进度条的色值
  final Color valueColor = Colors.red;

  NumberProgress(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              ),
            ),
          ),
          Container(
            height: height,
            alignment: Alignment.center,
            child: Text(
              value >= 1 ? '100%' : '${(value * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
