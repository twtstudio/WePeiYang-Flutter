import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';

extension StudyRoomColorsExt on ThemeData {
  Color get baseBackgroundColor => StudyRoomBackgroundColor;

  Color get baseIconColor => StudyRoomPrimaryColor;

  Color get dataUpdateTime => StudyRoomPrimaryColor;
}

extension StudyRoomBuildGridColors on ThemeData {
  Color get buildingIcon => StudyRoomGray5;

  Color get buildingName => StudyRoomGray4;
}

extension StudyRoomCampusButtonColors on ThemeData {
  Color get campusButtonText => StudyRoomPrimaryColor;
}

extension StudyRoomFavorListColors on ThemeData {
  Color get favorListTitle => StudyRoomPrimaryColor;

  Color get favorRoomName => StudyRoomPrimaryColor;

  List<Color> get favorRoomIconColors => favorRooms;

  Color get favorRoomItemShadow => StudyRoomGray6;

  Color get favorCardBackground => StudyRoomWhite5;
}

extension StudyRoomClassroomsPageColors on ThemeData {
  Color get classroomItemShadow => StudyRoomGray6;

  Color get classroomTitle => StudyRoomPrimaryColor;

  Color get classroomItemName => StudyRoomPrimaryColor;

  Color get classroomFloor => StudyRoomPrimaryColor;

  Color get classroomIcon => StudyRoomPrimaryColor;

  Color get classroomItemBackground => StudyRoomWhite5;
}

extension StudyRoomAreaPageColors on ThemeData {
  Color get areaTitle => StudyRoomPrimaryColor;

  Color get areaIconColor => baseIconColor;

  Color get areaText => StudyRoomWhite4;

  List<Color> get areaItemColors => areaItems;
}

extension StudyRoomRoomPageColors on ThemeData {
  Color get coordinateBackground => Colors.white.withOpacity(0.2);

  Color get coordinateText => ColorUtil.greyCAColor;

  Color get coordinateChosenBackground => Colors.white;

  Color get roomTitle => StudyRoomPrimaryColor;

  Color get roomConvertWeek => ColorUtil.greyCAColor;

  Color get favorButtonUnfavor => StudyRoomPrimaryColor;

  Color get favorButtonFavor => StudyRoomGray3;

  Color get roomPlanItemText => StudyRoomWhite3;

  List<Color> get roomPlanItemColors => roomPlanItems;
}

extension StudyRoomCalenderColors on ThemeData {
  Color get calenderBaseText => StudyRoomPrimaryColor;

  Color get calenderOutsideText => StudyRoomGray2;

  Color get calenderSelectText => StudyRoomWhite4;

  Color get calenderTodayText => StudyRoomPrimaryColor;

  Color get calenderTimeTableSelectText => StudyRoomWhite4;

  Color get calenderTimeTableText => StudyRoomPrimaryColor;

  Color get calenderOkButton => StudyRoomPrimaryColor;
}

extension StudyRoomSearchPageColors on ThemeData {
  Color get mainPageSearchBarBackground => StudyRoomWhite2;

  Color get searchIcon => StudyRoomGray7;

  Color get searchInputField => StudyRoomGray8;

  Color get searchInputFieldHint => StudyRoomGray8.withAlpha(0x77);

  Color get searchInputFieldButtonLine => StudyRoomPurple;

  Color get searchCancelButton => StudyRoomPrimaryColor;

  Color get searchHistoryTitle => StudyRoomPrimaryColor;

  Color get searchHistoryChipText => StudyRoomPrimaryColor;

  Color get searchHistoryChipBackground => StudyRoomWhite4;

  Color get searchClearHistoryDialogTextColor => StudyRoomPrimaryColor;

  Color get searchClearHistoryDialogBackground => StudyRoomBackgroundColor;

  Color get searchResultRoomItemShadow => StudyRoomGray6;

  Color get searchResultRoomItemBackground => StudyRoomWhite5;

  Color get searchResultRoomItemText => StudyRoomPrimaryColor;

  List<Color> get searchResultAreaItemBackground => areaItems;

  Color get searchResultAreaItemBuildingText => StudyRoomWhite5;

  Color get searchResultAreaItemWaterMark =>
      StudyRoomBackgroundColor.withAlpha(0x25);

  Color get searchErrorPageTitle => StudyRoomPurple2;

  Color get searchErrorPageContent => StudyRoomGray9;
}

const StudyRoomBackgroundColor = Color(0xfff7f7f8);
const StudyRoomPrimaryColor = Color(0xff62677b);
const StudyRoomWhite1 = Color(0xfff4f4f5);
const StudyRoomWhite2 = Color(0xffecedef);
const StudyRoomWhite3 = Color(0xfff8f8f9);
const StudyRoomWhite4 = Color(0xffffffff);
const StudyRoomWhite5 = Color(0xfffcfcfa);
const StudyRoomGray1 = Color(0xffcdced3);
const StudyRoomGray2 = Color(0xffcfd0d5);
const StudyRoomGray3 = Color(0xffc3c5c9);
const StudyRoomGray4 = Color(0xff86868f);
const StudyRoomGray5 = Color(0xff9d9da5);
const StudyRoomGray6 = Color(0xffE6E6E6);
const StudyRoomGray7 = Color(0xff848791);
const StudyRoomGray8 = Color(0xff363c54);
const StudyRoomGray9 = Color(0xff7a7d89);
const StudyRoomPurple = Color(0xff303c66);
const StudyRoomPurple2 = Color(0xff3d486c);

const List<Color> roomPlanItems = [
  Color.fromRGBO(114, 117, 136, 1), // #727588
  Color.fromRGBO(143, 146, 165, 1), // #8F92A5
  Color.fromRGBO(122, 119, 138, 1), // #7A778A
  Color.fromRGBO(142, 122, 150, 1), // #8E7A96
  Color.fromRGBO(130, 134, 161, 1), // #8286A1
];

const List<Color> areaItems = [
  Color(0xff363c54),
  Color(0xff74788a),
  Color(0xff676f96),
];

const List<Color> favorRooms = [
  Color(0xffcccccc),
  Color(0xffb6b6c0),
  Color(0xffe5ddc8),
];

const List<Color> areasColor = [
  Color(0xff363c54),
  Color(0xff74788a),
  Color(0xff676f96)
];
