import 'dart:io';
import 'dart:convert' show jsonDecode;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:location_permissions/location_permissions.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/urgent_report/base_page.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

enum _Page { report, list }

enum ReportPart {
  temperature,
  healthCode,
  itineraryCode,
  currentLocation,
  currentState,
}

final placeChannel = MethodChannel('com.twt.service/place');

enum LocationState { home, school, travel }

extension _SState on LocationState {
  String get name => ['在家', '在校', '在游'][this.index];
}

class ReportMainPage extends StatefulWidget {
  const ReportMainPage({Key key}) : super(key: key);

  @override
  _ReportMainPageState createState() => _ReportMainPageState();
}

class _ReportMainPageState extends State<ReportMainPage> {
  List<ValueNotifier<Color>> _partBackgroundColor = List.generate(
      ReportPart.values.length, (index) => ValueNotifier(Colors.transparent));

  ValueNotifier<bool> clearAll = ValueNotifier(true);

  _Page _page;
  Widget _action;

  @override
  void initState() {
    super.initState();
    _checkPageShowType();
  }

  _toReportPage() {
    _page = _Page.report;
    _action = IconButton(
      onPressed: () => setState(() {
        _toListPage();
      }),
      iconSize: 25,
      icon: Icon(Icons.list, color: Colors.white),
    );
  }

  _toListPage() {
    _page = _Page.list;
    _action = IconButton(
      onPressed: () => setState(() {
        _toReportPage();
      }),
      iconSize: 25,
      icon: Icon(Icons.add, color: Colors.white),
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
      var difference = lastDay.difference(DateTime.now()).inDays;
      return difference == 0;
    } catch (_) {
      return false;
    }
  }

  _reportButtonOnTap() {
    var model = Provider.of<ReportDataModel>(context, listen: false);
    var unSelected = model.check();
    unSelected = model.check();
    LocationData locationData = model.data[ReportPart.currentLocation];
    if (unSelected.isEmpty && locationData.address.isNotEmpty) {
      ToastProvider.running('上传中');
      _partBackgroundColor.forEach((element) {
        element.value = Colors.transparent;
      });
      reportDio.report(
          data: model.data,
          onResult: () {
            CommonPreferences().reportTime.value = DateTime.now().toString();
            ToastProvider.success('上传成功');
            clearAll.value = !clearAll.value;
            model.clearAll();
            _showReportDialog();
          },
          onFailure: (e) {
            ToastProvider.error('上传失败:${e.error.toString()}');
          });
    } else {
      ToastProvider.error('请检查所填内容是否完整');
      /**
       * TODO: 未填写的项目底色变红
       * unSelected.forEach((element) {
          _partBackgroundColor[element.index].value = Colors.red;
          });
          List.generate(ReportPart.values.length, (index) {
          if (!unSelected.map((e) => e.index).toList().contains(index))
          _partBackgroundColor[index].value = Colors.transparent;
          });
       */
    }
  }

  _showReportDialog() => showDialog<int>(
          // 传入 context
          context: context,
          // 构建 Dialog 的视图
          builder: (_) {
            var width = MediaQuery.of(context).size.width * 0.8;
            var height = MediaQuery.of(context).size.height * 0.17;
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
              builder: (_) => ReportButton(onTap: () => _reportButtonOnTap()),
            ),
            SizedBox(height: 40),
          ],
        ));
        break;
      case _Page.list:
        body = FutureBuilder<List<ReportItem>>(
            future: reportDio.getReportHistoryList(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      '当前无填报记录，请新建填报记录',
                      style: TextStyle(color: Color(0xff63677b)),
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
              borderRadius: BorderRadius.circular(10),
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
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [leftButton, rightButton],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _button(String name, int popType, BuildContext c) => TextButton(
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

class _ReportListItem extends StatelessWidget {
  final ReportItem data;

  const _ReportListItem({this.data, Key key}) : super(key: key);

  String _tryParseMonthAndDay(String text) {
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var cardWidth = width * 0.88;
    var codeWidth = width * 0.18;
    var codeHeight = codeWidth * 0.371;
    var iconWidth = width * 0.0407;

    var cardH = (width - cardWidth) / 2;
    var cardV = cardH / 2;

    var monthAndDay = _tryParseMonthAndDay(data.time);

    var iconBetweenText = iconWidth * 0.64;
    var iconDifference = 2;
    var linePadding = iconWidth * 0.705;
    var codeColumnRightPadding = width * 0.1;
    var informColumnLeftPadding = width * 0.1;
    var avoidOverflow = 15;
    var locationWidth = cardWidth -
        codeColumnRightPadding -
        informColumnLeftPadding -
        codeWidth -
        iconWidth -
        iconBetweenText -
        avoidOverflow;
    var datetimeLeftPadding = informColumnLeftPadding;

    var backgroundDatetime = Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: datetimeLeftPadding),
      child: Text(
        monthAndDay,
        maxLines: 1,
        style: FontManager.Gilroy.copyWith(
            color: Color(0xffD9DEEA),
            fontWeight: FontWeight.w800,
            fontSize: 60),
      ),
    );

    var healthCode = data.healthCode != null
        ? _code('健康码', Color(0xc14caf50), codeHeight, codeWidth)
        : SizedBox.shrink();
    var travelCode = data.travelCode != null
        ? _code('行程码', Color(0xc14caf50), codeHeight, codeWidth)
        : SizedBox.shrink();

    var codeColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [healthCode, travelCode],
    );

    Widget temperature = Row(
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
    );

    Widget location = Row(
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
          width: locationWidth,
          child: Text(
            data.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        )
      ],
    );

    Widget state = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: iconWidth + iconBetweenText),
        Text(LocationState.values[data.state].name),
      ],
    );

    var informationColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        temperature,
        SizedBox(height: linePadding),
        location,
        SizedBox(height: linePadding / 2),
        state,
      ],
    );

    var surfaceInformation = Align(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: TextStyle(color: Color(0xff63677b), fontSize: 11),
        child: Padding(
          padding: EdgeInsets.only(
            left: informColumnLeftPadding,
            right: codeColumnRightPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [informationColumn, codeColumn],
          ),
        ),
      ),
    );

    var textStack = Stack(
      children: [backgroundDatetime, surfaceInformation],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardH, vertical: cardV),
      child: Card(
        elevation: 0.2,
        margin: EdgeInsets.zero,
        child: textStack,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }

  Widget _code(String name, Color c, double h, double w) => Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(30 / 2),
          color: c,
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(fontSize: 10, color: Colors.white),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .findAncestorStateOfType<_ReportMainPageState>()
          .clearAll
          .addListener(() {
        _setText("");
      });
      _initTemperatureData();
    });
  }

  _initTemperatureData() {
    var data = Provider.of<ReportDataModel>(context, listen: false).data;
    if (data.containsKey(ReportPart.temperature)) {
      _setText(data[ReportPart.temperature]);
    }
  }

  _setText(String value) {
    setState(() {
      _temperature.text = value;
    });
  }

  _reportTemperature() {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(ReportPart.temperature, _temperature.text);
  }

  @override
  Widget build(BuildContext context) {
    var textFieldWidth = MediaQuery.of(context).size.width * 0.645;

    return BackgroundColorListener(
      part: ReportPart.temperature,
      builder: (_, backgroundColor, __) => Container(
        color: backgroundColor,
        padding: const EdgeInsets.only(top: 40, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "今日体温",
              style: TextStyle(color: Color(0xff63677b), fontSize: 13),
            ),
            SizedBox(width: 15),
            Container(
              width: textFieldWidth,
              padding: const EdgeInsets.only(bottom: 5),
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
                      inputFormatters: [_MyNumberTextInputFormatter(digit: 1)],
                      onChanged: (result) => _reportTemperature(),
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    "℃",
                    style: FontManager.YaHeiRegular.copyWith(
                      color: Color(0xff63677b),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// https://blog.csdn.net/oZhuiMeng123/article/details/105123273/
/// 限制小数位数
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
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

enum _Image {
  healthCode,
  itineraryCode,
}

extension _Name on _Image {
  String get name => ['健康码', '行程码'][this.index];

  ReportPart get key =>
      [ReportPart.healthCode, ReportPart.itineraryCode][this.index];
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
    XFile xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (xFile != null) {
      _setImg(File(xFile.path));
      _reportImage(xFile);
    }
  }

  _reportImage(XFile file) async {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(widget.image.key, file.path);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .findAncestorStateOfType<_ReportMainPageState>()
          .clearAll
          .addListener(() {
        _setImg(null);
      });
      _initFileData();
    });
  }

  _initFileData() {
    var data = Provider.of<ReportDataModel>(context, listen: false).data;
    if (data.containsKey(widget.image.key)) {
      _setImg(File(data[widget.image.key]));
    }
  }

  _setImg(File value) {
    setState(() {
      _image = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var imageWidth = MediaQuery.of(context).size.width * 0.296;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            '上传${widget.image.name}',
            style: TextStyle(fontSize: 13, color: Color(0xff63677b)),
          ),
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
                  child: SizedBox(
                    width: imageWidth,
                    height: imageWidth,
                    child: Icon(Icons.add_circle,
                        size: 40, color: Color(0xffd0d1d6)),
                  ),
                ),
        ),
      ],
    );
  }
}

class CurrentPlace extends StatefulWidget {
  @override
  _CurrentPlaceState createState() => _CurrentPlaceState();
}

class _CurrentPlaceState extends State<CurrentPlace> {
  bool canInputAddress = false;
  TextEditingController _controller = TextEditingController();

  _allowLocationPermission() async {
    switch (await LocationPermissions().requestPermissions()) {
      case PermissionStatus.granted:
        return true;
      default:
        _inputLocationBySelf();
        return false;
    }
  }

  _inputLocationBySelf() {
    _allowInputAddress();
    ToastProvider.error("请手动填写您当前所在位置");
  }

  _checkLocationPermissions() async {
    switch (await LocationPermissions().checkPermissionStatus()) {
      case PermissionStatus.denied:
        if (!await _allowLocationPermission()) return;
        break;
      case PermissionStatus.granted:
        // continue
        break;
      default:
        _inputLocationBySelf();
        return;
    }
    switch (await LocationPermissions().checkServiceStatus()) {
      case ServiceStatus.disabled:
        ToastProvider.error("请打开手机定位服务或手动填写");
        _allowInputAddress();
        break;
      case ServiceStatus.enabled:
        placeChannel.invokeMethod("getLocation");
        break;
      default:
        _inputLocationBySelf();
        return;
    }
  }

  _reportLocation(LocationData data) {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(ReportPart.currentLocation, data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .findAncestorStateOfType<_ReportMainPageState>()
          .clearAll
          .addListener(() {
        canInputAddress = false;
        _setLocation("");
      });
      _initLocationData();
      placeChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'showResult':
            String preJson = await call.arguments;
            Map<String, dynamic> json = jsonDecode(preJson);
            LocationData data = LocationData.fromJson(json);
            _reportLocation(data);
            _setLocation(data.address);
            return 'success';
          case 'showError':
            // String result = await call.arguments;
            ToastProvider.error("获取位置信息失败");
            _allowInputAddress();
            return 'success';
          default:
        }
      });
    });
  }

  _initLocationData() {
    var data = Provider.of<ReportDataModel>(context, listen: false).data;
    if (data.containsKey(ReportPart.currentLocation)) {
      LocationData location = data[ReportPart.currentLocation];
      _setLocation(location.address);
    }
  }

  _setLocation(String value) {
    setState(() {
      _controller.text = value;
    });
  }

  _allowInputAddress() {
    setState(() {
      canInputAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var placeWidth = MediaQuery.of(context).size.width * 0.72;

    Widget placeText = Container(
      padding: const EdgeInsets.only(left: 4, top: 15),
      width: placeWidth,
      child: TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          minLines: 1,
          maxLines: 10,
          buildCounter: null,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xff626774),
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          decoration: InputDecoration(
              hintText: "点击此处填写当前位置",
              hintStyle: TextStyle(
                  color: Color(0x9f626774),
                  fontWeight: FontWeight.normal,
                  fontSize: 15),
              isCollapsed: true,
              isDense: true,
              // contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none)),
          onChanged: (input) {
            _reportLocation(LocationData.onlyAddress(input));
          }),
    );

    var chosePlaceButton = ElevatedButton(
      onPressed: _checkLocationPermissions,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Row(
        children: [
          Text(
            '选择地区',
            style: TextStyle(fontSize: 13, color: Color(0xff63677b)),
          ),
          Icon(Icons.chevron_right, size: 20, color: Color(0xff63677b)),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 3),
            child: Icon(Icons.place, size: 20, color: Color(0xff63677b)),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_controller.text != '' || canInputAddress) placeText,
              chosePlaceButton
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentState extends StatefulWidget {
  @override
  _CurrentStateState createState() => _CurrentStateState();
}

class _CurrentStateState extends State<CurrentState> {
  List<LocationState> states = [
    LocationState.home,
    LocationState.school,
    LocationState.travel
  ];
  LocationState currentState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .findAncestorStateOfType<_ReportMainPageState>()
          .clearAll
          .addListener(() {
        _setState(null);
      });
      _initStateData();
    });
  }

  _initStateData() {
    var data = Provider.of<ReportDataModel>(context, listen: false).data;
    if (data.containsKey(ReportPart.currentState)) {
      _setState(data[ReportPart.currentState]);
    }
  }

  _setState(LocationState value) {
    setState(() {
      currentState = value;
    });
  }

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
              .map((state) => StateItem(
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

  _updateGroupValue(LocationState c) {
    setState(() {
      currentState = c;
    });
  }

  _reportCurrentState() {
    Provider.of<ReportDataModel>(context, listen: false)
        .add(ReportPart.currentState, currentState);
  }
}

class StateItem extends StatelessWidget {
  final LocationState state;
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
    var itemWidth = MediaQuery.of(context).size.width * 0.18;
    var itemHeight = MediaQuery.of(context).size.height * 0.042;
    return InkWell(
      onTap: onclick,
      borderRadius: BorderRadius.circular(itemHeight / 2),
      child: Container(
        height: itemHeight,
        width: itemWidth,
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(itemHeight / 2),
                color: Color(0XFF62677B))
            : BoxDecoration(
                borderRadius: BorderRadius.circular(itemHeight / 2),
                border: Border.all(color: Color(0XFF62677B), width: 1)),
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
  static const height = 50.0;
  static const width = 90.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: widget.onTap,
            child: Center(
              child: Text(
                '提交',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height / 2))),
                backgroundColor: MaterialStateProperty.all(Color(0XFF62677B)),
                minimumSize: MaterialStateProperty.all(Size(width, height))),
          ),
        ],
      ),
    );
  }
}

class BackgroundColorListener extends StatelessWidget {
  final ReportPart part;
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
