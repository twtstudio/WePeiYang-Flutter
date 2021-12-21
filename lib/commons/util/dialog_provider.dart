import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class DialogWidget extends Dialog {
  final String title; //标题
  final String content; //内容
  final String cancelText; //是否需要"取消"按钮
  final String confirmText; //是否需要"确定"按钮
  final Function cancelFun; //取消回调
  final Function confirmFun; //确定回调
  DialogWidget( {
    @required Key key,
    @required this.title,
    @required this.content,
    @required this.cancelText,
    @required this.confirmText,
    @required this.cancelFun,
    @required this.confirmFun
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding:EdgeInsets.all(28),
              decoration: ShapeDecoration(
                color: Color(0xfff2f2f2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Row(
                      children: [
                        Text(title, style: TextStyle(color: Color(0xff666666),fontSize: 18)),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 100),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IntrinsicHeight(
                        child:  Text(content, style: TextStyle(color: Color(0xff666666))),
                      ),
                    ),
                  ),
                  this._buildBottomButtonGroup()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtonGroup() {
    var widgets = <Widget>[];
    if (cancelText != null && cancelText.isNotEmpty) widgets.add(SizedBox(width: 13,));
    if (cancelText != null && cancelText.isNotEmpty) widgets.add(_buildBottomCancelButton());
    if (confirmText != null && confirmText.isNotEmpty && confirmText != null && confirmText.isNotEmpty) widgets.add(_buildBottomOnline());
    if (confirmText != null && confirmText.isNotEmpty && confirmText != null && confirmText.isNotEmpty) widgets.add(SizedBox(width: 30,));
    if (confirmText != null && confirmText.isNotEmpty) widgets.add(_buildBottomPositiveButton());

    return Flex(
      direction: Axis.horizontal,
      children: widgets,
    );
  }
  Widget _buildBottomOnline() {
    return Container(
      color: Color(0xffeeeeee),
    );
  }
  Widget _buildBottomCancelButton() {
    return Container(
      height: 44,
      width: 136,
      child: TextButton(
        onPressed: () => this.cancelFun,
        child: Text(cancelText,
            style: TextStyle(
                color: Color.fromRGBO(54, 60, 84, 1), fontSize: 13)),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(3),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed))
              return Color.fromRGBO(79, 88, 107, 1);
            return  ColorUtil.backgroundColor;
          }),
          backgroundColor:
          MaterialStateProperty.all(ColorUtil.backgroundColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }

  Widget _buildBottomPositiveButton() {
    return Container(
      height: 44,
      width: 136,
      child: TextButton(
        onPressed: () => this.confirmFun,
        child: Text(confirmText,
            style: TextStyle(
                color: Color.fromRGBO(54, 60, 84, 1), fontSize: 13)),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(3),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed))
              return Color.fromRGBO(79, 88, 107, 1);
            return  ColorUtil.backgroundColor;
          }),
          backgroundColor:
          MaterialStateProperty.all(ColorUtil.backgroundColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}