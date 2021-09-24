import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/urgent_report/base_page.dart';

class ReportMainPage extends StatefulWidget {
  const ReportMainPage({Key key}) : super(key: key);

  @override
  _ReportMainPageState createState() => _ReportMainPageState();
}

enum _Page { report, list }

class _ReportMainPageState extends State<ReportMainPage> {
  List<ValueNotifier<Color>> _partBackgroundColor = List.generate(
      _ReportPart.values.length, (index) => ValueNotifier(Colors.transparent));

  _Page _page;
  Widget _action;

  @override
  void initState() {
    super.initState();
    _checkPageShowType();
  }

  _toReportPage() {
    _page = _Page.report;
    _action = FlatButton(
      minWidth: 40,
      onPressed: () =>
          setState(() {
            _toListPage();
          }),
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
    );
  }

  _toListPage() {
    _page = _Page.list;
    _action = FlatButton(
      minWidth: 40,
      onPressed: () =>
          setState(() {
            _toReportPage();
          }),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  _checkPageShowType() {
    try {
      if (_checkTodayHasReportedOrNot()) {
        // has reported
        _toListPage();
      } else {
        // no
        _toReportPage();
      }
    } catch (e) {
      _toReportPage();
    }
  }

  bool _checkTodayHasReportedOrNot() {
    try {
      var lastTime = DateTime.parse(CommonPreferences().reportTime.value);
      var lastDay = DateTime(lastTime.year, lastTime.month, lastTime.day);
      var difference = lastDay
          .difference(DateTime.now())
          .inDays;
      return difference == 0;
    } catch (_) {
      return false;
    }
  }

  _reportButtonOnTap(BuildContext c) {
    var model = Provider.of<ReportDataModel>(c, listen: false);
    var unSelected = model.check();
    unSelected = model.check();
    if (unSelected.isEmpty) {
      ToastProvider.running('上传中');
      _partBackgroundColor.forEach((element) {
        element.value = Colors.transparent;
      });
      model.report().then((value) {
        if (value) {
          CommonPreferences().reportTime.value = DateTime.now().toString();
          ToastProvider.success('上传成功');
          _showReportDialog();
        } else {
          ToastProvider.error('上传失败');
        }
      });
    } else {
      ToastProvider.error('请检查所填内容是否完整');
      /**
       * TODO: 未填写的项目底色变红
       * unSelected.forEach((element) {
          _partBackgroundColor[element.index].value = Colors.red;
          });
          List.generate(_ReportPart.values.length, (index) {
          if (!unSelected.map((e) => e.index).toList().contains(index))
          _partBackgroundColor[index].value = Colors.transparent;
          });
       */
    }
  }

  _showReportDialog() =>
      showDialog<int>(
        // 传入 context
          context: context,
          // 构建 Dialog 的视图
          builder: (_) {
            var width = MediaQuery
                .of(context)
                .size
                .width * 0.8;
            var height = MediaQuery
                .of(context)
                .size
                .height * 0.17;
            return _ReportResultDialog(width: width, height: height);
          }).then((value) {
        switch (value) {
          case 0:
            Navigator.pop(context);
            break;
          case 1:
            setState(() {
              _toListPage();
            });
            break;
          default:
            break;
        }
      });

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_page) {
      case _Page.report:
        body = Center(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                TodayTemp(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PickImage(image: _Image.healthCode),
                    PickImage(image: _Image.itineraryCode),
                  ],
                ),
                CurrentPlace(),
                CurrentState(),
                Builder(
                  builder: (c) =>
                      ReportButton(onTap: () => _reportButtonOnTap(c)),
                )
              ],
            ));
        break;
      case _Page.list:
        body = FutureBuilder<List<_ReportItem>>(
            future: _getReportHistoryList(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      '当前无填报记录，请新建填报记录',
                      style: TextStyle(
                        color: Color(0xff63677b),
                      ),
                    ),
                  );
                } else {
                  var list = snapshot.data.reversed.toList();
                  return ListView.builder(
                    itemExtent: 150,
                    itemCount: list.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (_, index) {
                      return _ReportListItem(data: list[index]);
                    },
                  );
                }
              } else {
                return Container();
              }
            });
        break;
      default:
        break;
    }

    return ReportBasePage(
        action: _action,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: body,
        ));
  }
}

class _ReportResultDialog extends StatelessWidget {
  const _ReportResultDialog({
    Key key,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    var rightButton = _button('查看填报记录', 1, context);
    var leftButton = _button('返回', 0, context);

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xfffbfbfb),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '已完成今日填报',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff63677b),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [leftButton, rightButton],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _button(String name, int popType, BuildContext c) =>
      FlatButton(
        onPressed: () {
          Navigator.pop(c, popType);
        },
        child: Text(
          name,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xff63677b),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

String tryParseMonthAndDay(String text) {
  try {
    var date = DateTime.parse(text);
    var month = date.month.toString();
    var day = date.day.toString();
    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
    return '$month/$day';
  } catch (e) {
    return '00/00';
  }
}

class _ReportListItem extends StatelessWidget {
  final _ReportItem data;

  const _ReportListItem({this.data, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var cardWidth = width * 0.88;
    var codeWidth = width * 0.18;
    var codeHeight = codeWidth * 0.371;
    var iconWidth = width * 0.0407;

    var cardH = (width - cardWidth) / 2;
    var cardV = cardH / 2;

    var monthAndDay = tryParseMonthAndDay(data.time);

    var backgroundDatetime = Align(
      alignment: Alignment.center,
      child: Container(
        // color: Colors.green,
        child: Text(
          monthAndDay,
          style: FontManager.Gilroy.copyWith(
              color: Color(0xffD9DEEA),
              fontWeight: FontWeight.w800,
              fontSize: 60),
        ),
      ),
    );

    var iconBetweenText = iconWidth * 0.64;
    var iconDifference = 2;
    var linePadding = iconWidth * 0.705;

    var surfaceInformation = Align(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Color(0xff63677b),
          fontSize: 11,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/account/thermometer.png',
                  height: iconWidth,
                  color: Color(0xff4f586b),
                ),
                SizedBox(width: iconBetweenText),
                Text(data.temperature + "℃"),
              ],
            ),
            SizedBox(height: linePadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/account/direction2.png',
                  width: iconWidth - iconDifference,
                  color: Color(0xff4f586b),
                ),
                SizedBox(width: iconBetweenText + iconDifference),
                SizedBox(
                  width: 150,
                  child: Text(
                    data.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                )
              ],
            ),
            SizedBox(height: linePadding / 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: iconWidth + iconBetweenText),
                Text(_State.values[data.state].name),
              ],
            )
          ],
        ),
      ),
    );

    var textStack = Stack(
      children: [backgroundDatetime, surfaceInformation],
    );

    var healthCode = data.healthCode != null
        ? _code('健康码', Colors.green, codeHeight, codeWidth)
        : SizedBox.shrink();
    var travelCode = data.travelCode != null
        ? _code('行程码', Colors.green, codeHeight, codeWidth)
        : SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardH, vertical: cardV),
      child: Card(
        elevation: 0.2,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Row(
              children: [
                Expanded(child: textStack),
                SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [healthCode, travelCode],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _code(String name, Color c, double h, double w) =>
      Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.circular(30 / 2),
          ),
          color: c,
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class TodayTemp extends StatefulWidget {
  @override
  _TodayTempState createState() => _TodayTempState();
}

class _TodayTempState extends State<TodayTemp> {
  TextEditingController _temperature;

  @override
  void initState() {
    super.initState();
    _temperature = TextEditingController();
  }

  _reportTemperature() {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(_ReportPart.temperature, _temperature.text);
  }

  @override
  Widget build(BuildContext context) {
    var textFieldWidth = MediaQuery
        .of(context)
        .size
        .width * 0.654;

    return BackgroundColorListener(
      part: _ReportPart.temperature,
      builder: (_, backgroundColor, __) =>
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.only(top: 40.0, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "今日体温",
                  style: TextStyle(
                    color: Color(0xff63677b),
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 15),
                Container(
                  width: textFieldWidth,
                  padding: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.6, //宽度
                        color: Color(0xff63677b), //边框颜色
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          buildCounter: null,
                          controller: _temperature,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          style: FontManager.YaHeiRegular.copyWith(
                            color: Color(0xff63677b),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          inputFormatters: [
                            _MyNumberTextInputFormatter(digit: 1)
                          ],
                          onChanged: (result) => _reportTemperature(),
                        ),
                      ),
                      Container(width: 3),
                      Text(
                        "℃",
                        style: FontManager.YaHeiRegular.copyWith(
                          color: Color(0xff63677b),
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
    );
  }
}

//https://blog.csdn.net/oZhuiMeng123/article/details/105123273/
// 限制小数位数
class _MyNumberTextInputFormatter extends TextInputFormatter {
  static const defaultDouble = 0.1;

  ///允许的小数位数，-1代表不限制位数
  int digit;

  ///允许的整数位数, -1代表不限制位数
  static int integer = 2;

  _MyNumberTextInputFormatter({this.digit = -1});

  static double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  ///获取目前的小数位数
  static int getValueDigit(String value) {
    if (value.contains(".")) {
      return value.split(".")[1].length;
    } else {
      return -1;
    }
  }

  ///获取目前的整数位数
  static int getValueInteger(String value) {
    if (integer != -1) {
      return value.split(".")[0].length;
    } else {
      return integer;
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == ".") {
      value = "0.";
      selectionIndex++;
    } else if (value == "-") {
      value = "-";
      selectionIndex++;
    } else if (value != "" &&
        value != defaultDouble.toString() &&
        strToFloat(value, defaultDouble) == defaultDouble ||
        getValueDigit(value) > digit ||
        getValueInteger(value) > integer) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

enum _Image {
  healthCode,
  itineraryCode,
}

extension _Name on _Image {
  String get name => ['健康码', '行程码'][this.index];

  _ReportPart get key =>
      [_ReportPart.healthCode, _ReportPart.itineraryCode][this.index];
}

class PickImage extends StatefulWidget {
  final _Image image;

  const PickImage({Key key, this.image}) : super(key: key);

  @override
  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File _image;

  _imgFromGallery() async {
    PickedFile pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _reportImage(pickedFile);
      }
    });
  }

  _reportImage(PickedFile pickedFile) async {
    var _bytes = await pickedFile.readAsBytes();
    Provider.of<ReportDataModel>(context, listen: false)
        .add(widget.image.key, _bytes);
  }

  @override
  Widget build(BuildContext context) {
    var imageWidth = MediaQuery
        .of(context)
        .size
        .width * 0.296;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            '上传${widget.image.name}',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xff63677b),
            ),
          ),
          height: 50,
        ),
        GestureDetector(
          onTap: () {
            _imgFromGallery();
          },
          child: _image != null
              ? Image.file(
            _image,
            width: imageWidth,
            height: imageWidth,
            fit: BoxFit.fitHeight,
          )
              : DottedBorder(
            borderType: BorderType.Rect,
            color: Color(0xffd0d1d6),
            child: Container(
              width: imageWidth,
              height: imageWidth,
              child: Icon(
                Icons.add_circle,
                size: 40,
                color: Color(0xffd0d1d6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final placeChannel = MethodChannel('com.twt.service/place');

class CurrentPlace extends StatefulWidget {
  @override
  _CurrentPlaceState createState() => _CurrentPlaceState();
}

class _CurrentPlaceState extends State<CurrentPlace> {
  String currentPlace = "";

  _checkAllPermissions() async {
    await Permission.contacts.shouldShowRequestRationale;

    await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();

    if (await Permission.location.isDenied) {
      ToastProvider.error("位置权限未启用");
      return;
    }
    if (await Permission.location.isLimited) {
      ToastProvider.error("位置权限未启用"); // iOS
      return;
    }
    if (await Permission.location.isPermanentlyDenied) {
      ToastProvider.error("位置权限被禁用");
      openAppSettings();
      return;
    }
    if (await Permission.location.isRestricted) {
      ToastProvider.error("位置权限被禁用"); // iOS
      return;
    }
    if (await Permission.location.isUndetermined) {
      ToastProvider.error("位置权限未启用");
      return;
    }

    placeChannel.invokeMethod("getLocation");
  }

  _reportLocation(LocationData data) {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(_ReportPart.currentLocation, data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      placeChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'showResult':
            String preJson = await call.arguments;
            Map<String, dynamic> json = jsonDecode(preJson);
            LocationData data = LocationData.fromJson(json);
            _reportLocation(data);
            setState(() {
              currentPlace = data.address;
            });
            return 'success';
          case 'showError':
          // String result = await call.arguments;
            ToastProvider.error("获取位置信息失败");
            return 'success';
          default:
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var placeWidth = MediaQuery
        .of(context)
        .size
        .width - 80;

    var placeText = Container(
      padding: EdgeInsets.only(top: 15, left: 3),
      width: placeWidth,
      child: Text(
        currentPlace,
        softWrap: true,
        style: TextStyle(
          fontSize: 13,
          color: Color(0xff63677b),
        ),
      ),
    );

    var chosePlaceButton = RaisedButton(
      elevation: 0,
      padding: EdgeInsets.zero,
      onPressed: _checkAllPermissions,
      child: Row(
        children: [
          Text(
            '选择地区',
            style: TextStyle(fontSize: 13, color: Color(0xff63677b)),
          ),
          Icon(Icons.chevron_right, size: 20, color: Color(0xff63677b)),
        ],
      ),
      color: Colors.transparent,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 15.0, right: 3),
            child: Icon(Icons.place, size: 20, color: Color(0xff63677b)),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [if (currentPlace != '') placeText, chosePlaceButton],
          ),
        ],
      ),
    );
  }
}

enum _State { home, school, travel }

extension _SState on _State {
  String get name => ['在家', '在校', '在游'][this.index];
}

class CurrentState extends StatefulWidget {
  @override
  _CurrentStateState createState() => _CurrentStateState();
}

class _CurrentStateState extends State<CurrentState> {
  List<_State> states = [_State.home, _State.school, _State.travel];
  _State currentState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "当前状态",
            style: TextStyle(fontSize: 13, color: Color(0xff63677b)),
          ),
          ...states
              .map((state) =>
              StateItem(
                state: state,
                isSelected: currentState == state,
                onclick: () async {
                  _updateGroupValue(state);
                  _reportCurrentState();
                },
              ))
              .toList()
        ],
      ),
    );
  }

  _updateGroupValue(_State c) {
    setState(() {
      currentState = c;
    });
  }

  _reportCurrentState() {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(_ReportPart.currentState, currentState);
  }
}

class StateItem extends StatelessWidget {
  final _State state;
  final bool isSelected;
  final VoidCallback onclick;

  const StateItem({
    @required this.state,
    @required this.isSelected,
    @required this.onclick,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemWidth = MediaQuery
        .of(context)
        .size
        .width * 0.18;
    var itemHeight = itemWidth * 0.371;
    return InkWell(
      onTap: onclick,
      borderRadius: BorderRadius.circular(12.5),
      child: Container(
        height: itemHeight,
        width: itemWidth,
        decoration: isSelected
            ? BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12.5),
            color: Color(0XFF62677B))
            : BoxDecoration(
            borderRadius: BorderRadius.circular(12.5),
            border: Border.all(
              color: Color(0XFF62677B),
              width: 1,
            )),
        child: Center(
          child: Text(
            state.name,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Color(0XFF62677B),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportButton extends StatefulWidget {
  final VoidCallback onTap;

  ReportButton({this.onTap, Key key}) : super(key: key);

  @override
  _ReportButtonState createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  final height = 50.0;

  final width = 90.0;

  bool _isCan = true;

  _buttonClick() {
    if (widget.onTap != null && _isCan) {
      widget.onTap();
      _isCan = false;
      // 500 毫秒内 不能多次点击
      Future.delayed(Duration(milliseconds: 500), () {
        _isCan = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height / 2)),
            onPressed: _buttonClick,
            color: Color(0XFF62677B),
            height: height,
            minWidth: width,
            child: Center(
              child: Text(
                '提交',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ReportPart {
  temperature,
  healthCode,
  itineraryCode,
  currentLocation,
  currentState,
}

class ReportDataModel {
  final Map<_ReportPart, dynamic> _data = {};

  UnmodifiableMapView get data => UnmodifiableMapView(_data);

  void add(_ReportPart k, dynamic v) {
    _data[k] = v;
    if (v == null || v == '') {
      _data.remove(k);
    }
  }

  List<_ReportPart> check() {
    return _ReportPart.values
        .where((element) => !data.containsKey(element))
        .toList();
  }

  Future<bool> report() async {
    try {
      var token = CommonPreferences().token.value;
      var id = CommonPreferences().userNumber.value;
      var location = _data[_ReportPart.currentLocation] as LocationData;
      var state = _data[_ReportPart.currentState] as _State;
      FormData data = FormData.fromMap({
        'provinceName': location.province,
        'cityName': location.city,
        'regionName': location.district,
        'address': location.address,
        'longitude': location.longitude,
        'latitude': location.latitude,
        'healthCodeScreenshot': MultipartFile.fromBytes(
          _data[_ReportPart.healthCode],
          filename: 'h${DateTime
              .now()
              .millisecondsSinceEpoch}code$id.jpg',
          contentType: MediaType('image', 'jpg'),
        ),
        'travelCodeScreenshot': MultipartFile.fromBytes(
          _data[_ReportPart.itineraryCode],
          filename: 't${DateTime
              .now()
              .millisecondsSinceEpoch}code$id.jpg',
          contentType: MediaType('image', 'jpg'),
        ),
        'curStatus': state.index,
        'temperature': _data[_ReportPart.temperature],
      });
      var dio = Dio()
        ..interceptors.add(LogInterceptor(responseBody: true));
      var result = await dio.post(
        "https://api.twt.edu.cn/api/returnSchool/record",
        options: Options(
          headers: {
            "DOMAIN": AuthDio.DOMAIN,
            "ticket": AuthDio.ticket,
            "token": token,
          },
        ),
        data: data,
      );
      var responseData = ReportState.fromJson(result.data);
      return responseData.errorCode == 0 ? true : false ;
    } catch (e) {
      return false;
    }
  }
}

class LocationData {
  final double longitude;
  final double latitude;
  final String nation;
  final String province;
  final String city;
  final String cityCode;
  final String district;
  final String address;
  final int time;

  LocationData({this.longitude,
    this.latitude,
    this.nation,
    this.province,
    this.city,
    this.cityCode,
    this.district,
    this.address,
    this.time});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      longitude: json['longitude'],
      latitude: json['latitude'],
      nation: json['nation'],
      province: json['province'],
      city: json['city'],
      cityCode: json['cityCode'],
      district: json['district'],
      address: json['address'],
      time: json['time'],
    );
  }
}

class BackgroundColorListener extends StatelessWidget {
  final _ReportPart part;
  final ValueWidgetBuilder<Color> builder;

  const BackgroundColorListener({Key key, this.part, this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: context
            .findAncestorStateOfType<_ReportMainPageState>()
            ._partBackgroundColor[part.index],
        builder: builder);
  }
}

Future<List<_ReportItem>> _getReportHistoryList() async {
  try {
    var token = CommonPreferences().token.value;
    var response = await Dio().get(
      "https://api.twt.edu.cn/api/returnSchool/record",
      options: Options(
        headers: {
          "DOMAIN": AuthDio.DOMAIN,
          "ticket": AuthDio.ticket,
          "token": token,
        },
      ),
    );
    var data = _ReportList.fromJson(response.data);
    return data.result;
  } catch (e) {
    return null;
  }
}

Future<bool> getTodayHasReported() async {
  try {
    var token = CommonPreferences().token.value;
    var response = await Dio().get(
      "https://api.twt.edu.cn/api/returnSchool/status",
      options: Options(
        headers: {
          "DOMAIN": AuthDio.DOMAIN,
          "ticket": AuthDio.ticket,
          "token": token,
        },
      ),
    );
    var data = ReportState.fromJson(response.data);
    return data.result == 1 ? true : false;
  } catch (e) {
    return false;
  }
}

// TODO: 上传数据的接口返回类型和这个相似，只是result为null，先用这个代替
class ReportState {
  final int errorCode;
  final String message;
  final int result;

  ReportState({this.errorCode, this.message, this.result});

  factory ReportState.fromJson(Map<String, dynamic> json) {
    return ReportState(
      errorCode: json['error_code'],
      message: json['message'],
      result: json['result'],
    );
  }

  Map toJson() =>
      {
        "errorCode": errorCode,
        "message": message,
        "result": result,
      };
}

class _ReportList {
  final int errorCode;
  final String message;
  final List<_ReportItem> result;

  _ReportList({this.errorCode, this.message, this.result});

  factory _ReportList.fromJson(Map<String, dynamic> json) {
    return _ReportList(
      errorCode: json['error_code'],
      message: json['message'],
      result: List()
        ..addAll(
            (json['result'] as List ?? []).map((e) => _ReportItem.fromJson(e))),
    );
  }
}

class _ReportItem {
  final String longitude;
  final String latitude;
  final String province;
  final String city;
  final String district;
  final String address;
  final String time;
  final String temperature;
  final String healthCode;
  final String travelCode;
  final int state;

  _ReportItem({this.longitude,
    this.latitude,
    this.province,
    this.city,
    this.district,
    this.address,
    this.time,
    this.temperature,
    this.healthCode,
    this.travelCode,
    this.state});

  factory _ReportItem.fromJson(Map<String, dynamic> json) {
    return _ReportItem(
      longitude: json['longitude'],
      latitude: json['latitude'],
      province: json['provinceName'],
      city: json['cityName'],
      district: json['regionName'],
      address: json['address'],
      time: json['uploadAt'],
      temperature: json['temperature'],
      healthCode: json['healthCodeUrl'],
      travelCode: json['travelCodeUrl'],
      state: json['curStatus'],
    );
  }

  Map toJson() =>
      {
        "longitude": longitude,
        "latitude": latitude,
        "province": province,
        "city": city,
        "district": district,
        "address": address,
        "time": time,
        "temperature": temperature,
        "healthCode": healthCode,
        "travelCode": travelCode,
        "state": state,
      };
}
