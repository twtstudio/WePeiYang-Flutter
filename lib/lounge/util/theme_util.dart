// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

extension LoungeColorsExt on ThemeData {
  Color get baseBackgroundColor => loungeBackgroundColor;
  Color get baseIconColor => loungePrimaryColor;
  Color get dataUpdateTime => loungePrimaryColor;
}

extension LoungeBuildGridColors on ThemeData {
  Color get buildingIcon => loungeGray5;
  Color get buildingName => loungeGray4;
}

extension LoungeCampusButtonColors on ThemeData {
  Color get campusButtonText => loungePrimaryColor;
}

extension LoungeFavorListColors on ThemeData {
  Color get favorListTitle => loungePrimaryColor;
  Color get favorRoomName => loungePrimaryColor;
  List<Color> get favorRoomIconColors => favorRooms;
  Color get favorRoomItemShadow => loungeGray6;
  Color get favorCardBackground => loungeWhite5;
}

extension LoungeClassroomsPageColors on ThemeData {
  Color get classroomItemShadow => loungeGray6;
  Color get classroomTitle => loungePrimaryColor;
  Color get classroomItemName => loungePrimaryColor;
  Color get classroomFloor => loungePrimaryColor;
  Color get classroomIcon => loungePrimaryColor;
  Color get classroomItemBackground => loungeWhite5;
}

extension LoungeAreaPageColors on ThemeData {
  Color get areaTitle => loungePrimaryColor;
  Color get areaIconColor => baseIconColor;
  Color get areaText => loungeWhite4;
  List<Color> get areaItemColors => areaItems;
}

extension LoungeRoomPageColors on ThemeData {
  Color get coordinateBackground => loungeWhite2;
  Color get coordinateText => loungeGray2;
  Color get coordinateChosenBackground => loungePurple;
  Color get coordinateChosenText => loungeBackgroundColor;
  Color get roomTitle => loungePrimaryColor;
  Color get roomConvertWeek => loungeGray1;
  Color get favorButtonUnfavor => loungePrimaryColor;
  Color get favorButtonFavor => loungeGray3;
  Color get roomPlanItemText => loungeWhite3;
  List<Color> get roomPlanItemColors => roomPlanItems;
}

extension LoungeCalenderColors on ThemeData {
  Color get calenderBaseText => loungePrimaryColor;
  Color get calenderOutsideText => loungeGray2;
  Color get calenderSelectText => loungeWhite4;
  Color get calenderSelectBackground => loungeBlue.withOpacity(0.1);
  Color get calenderTodayBorder => loungeBlue;
  Color get calenderTodayText => loungePrimaryColor;
  Color get calenderTimeTableSelectText => loungeWhite4;
  Color get calenderTimeTableBorder => loungeBlue;
  Color get calenderTimeTableText => loungePrimaryColor;
  Color get calenderOkButton => loungePrimaryColor;
}

extension LoungeSearchPageColors on ThemeData {
  Color get mainPageSearchBarBackground => loungeWhite2;

  Color get searchIcon => loungeGray7;
  Color get searchInputField => loungeGray8;
  Color get searchInputFieldHint => loungeGray8.withAlpha(0x77);
  Color get searchInputFieldButtonLine => loungePurple;
  Color get searchCancelButton => loungePrimaryColor;

  Color get searchHistoryTitle => loungePrimaryColor;
  Color get searchHistoryChipText => loungePrimaryColor;
  Color get searchHistoryChipBackground => loungeWhite4;
  Color get searchClearHistoryDialogTextColor => loungePrimaryColor;
  Color get searchClearHistoryDialogBackground => loungeBackgroundColor;

  Color get searchResultRoomItemShadow => loungeGray6;
  Color get searchResultRoomItemBackground => loungeWhite5;
  Color get searchResultRoomItemText => loungePrimaryColor;

  List<Color> get searchResultAreaItemBackground => areaItems;
  Color get searchResultAreaItemBuildingText => loungeWhite5;
  Color get searchResultAreaItemWaterMark =>
      loungeBackgroundColor.withAlpha(0x25);

  Color get searchErrorPageTitle => loungePurple2;
  Color get searchErrorPageContent => loungeGray9;
}

extension LoadingDotsColors on ThemeData {
  Color get dotOneColor => const Color(0xff57616c);
  Color get dotTwoColor => const Color(0xff9eaab6);
  Color get dotThreeColor => const Color(0xff57616c);
}

const loungeBackgroundColor = Color(0xfff7f7f8);
const loungePrimaryColor = Color(0xff62677b);
const loungeWhite1 = Color(0xfff4f4f5);
const loungeWhite2 = Color(0xffecedef);
const loungeWhite3 = Color(0xfff8f8f9);
const loungeWhite4 = Color(0xffffffff);
const loungeWhite5 = Color(0xfffcfcfa);
const loungeGray1 = Color(0xffcdced3);
const loungeGray2 = Color(0xffcfd0d5);
const loungeGray3 = Color(0xffc3c5c9);
const loungeGray4 = Color(0xff86868f);
const loungeGray5 = Color(0xff9d9da5);
const loungeGray6 = Color(0xffE6E6E6);
const loungeGray7 = Color(0xff848791);
const loungeGray8 = Color(0xff363c54);
const loungeGray9 = Color(0xff7a7d89);
const loungePurple = Color(0xff303c66);
const loungePurple2 = Color(0xff3d486c);
const loungeBlue = ColorUtil.blue2CColor;

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
