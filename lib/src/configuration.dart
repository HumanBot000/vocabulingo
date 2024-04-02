import 'package:flutter/material.dart';
import 'package:vocabulingo/main.dart';

Color appPrimaryColor = Colors.greenAccent.shade700;
Color appSecondaryColor = Colors.blueAccent.shade100;

AppBar defaultAppBar() {
  return AppBar(
    title: const Text("Vocabulingo"),
    backgroundColor: appPrimaryColor,
    centerTitle: true,
  );
}