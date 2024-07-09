import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;

Color appPrimaryColor = Colors.greenAccent.shade700;
Color appSecondaryColor = Colors.blueAccent.shade100;

AppBar defaultAppBar() {
  return AppBar(
    title: const Text("Vocabulingo"),
    backgroundColor: appPrimaryColor,
    centerTitle: true,
  );
}
bool appIsInDebugState(){
  return true;
}
String backendAddress() {
  if (appIsInDebugState()){
    return "10.0.2.2:5000";
  }
  return "85.215.233.210:5000";
}

List<IconData> allIcons() {
  return iconDataList;
}

List<IconData> iconDataList = [
  CupertinoIcons.folder,
  CupertinoIcons.heart_fill,
  CupertinoIcons.star_fill,
  CupertinoIcons.circle_fill,
  CupertinoIcons.square_fill,
  CupertinoIcons.triangle_fill,
  CupertinoIcons.number,
  CupertinoIcons.line_horizontal_3_decrease,
  CupertinoIcons.line_horizontal_3_decrease_circle,
  CupertinoIcons.circle_grid_hex,
  CupertinoIcons.circle_grid_hex_fill,
  CupertinoIcons.gear,
  CupertinoIcons.plus,
  CupertinoIcons.minus,
  CupertinoIcons.arrow_left,
  CupertinoIcons.arrow_right,
  CupertinoIcons.arrow_up,
  CupertinoIcons.arrow_down,
  CupertinoIcons.arrow_up_left,
  CupertinoIcons.arrow_up_right,
  CupertinoIcons.arrow_down_left,
  CupertinoIcons.arrow_down_right,
  CupertinoIcons.book_fill,
  CupertinoIcons.bookmark,
  CupertinoIcons.tag_fill,
  CupertinoIcons.flag_fill,
  CupertinoIcons.info_circle,
  CupertinoIcons.chart_bar,
  CupertinoIcons.chart_bar_alt_fill,
  CupertinoIcons.chart_pie,
  CupertinoIcons.chart_pie_fill,
  CupertinoIcons.eye_fill,
  CupertinoIcons.checkmark,
  CupertinoIcons.checkmark_circle,
  CupertinoIcons.xmark,
  CupertinoIcons.xmark_circle,
  CupertinoIcons.person,
  CupertinoIcons.person_fill,
  CupertinoIcons.person_crop_circle_badge_plus,
  CupertinoIcons.phone,
  CupertinoIcons.phone_fill,
  CupertinoIcons.phone_circle_fill,
  CupertinoIcons.mail,
  CupertinoIcons.mail_solid,
  CupertinoIcons.paperplane_fill,
  CupertinoIcons.bell,
  CupertinoIcons.bell_fill,
  CupertinoIcons.bell_slash_fill,
  CupertinoIcons.home,
  CupertinoIcons.search,
  CupertinoIcons.search_circle,
  CupertinoIcons.shopping_cart,
  CupertinoIcons.music_note,
  CupertinoIcons.music_note_list,
  CupertinoIcons.music_note_2,
  CupertinoIcons.cube,
  CupertinoIcons.cube_fill,
  CupertinoIcons.pencil,
  CupertinoIcons.pencil_circle,
  CupertinoIcons.photo_fill,
  CupertinoIcons.camera_fill,
  CupertinoIcons.camera_on_rectangle_fill,
  CupertinoIcons.camera_rotate,
  CupertinoIcons.camera_rotate_fill,
  CupertinoIcons.battery_0,
  CupertinoIcons.battery_25,
  CupertinoIcons.battery_75_percent,
  CupertinoIcons.battery_100,
  CupertinoIcons.bluetooth,
  CupertinoIcons.wifi,
  CupertinoIcons.wifi_slash,
];
