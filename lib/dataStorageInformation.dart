import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;

class DataStorageInformation extends StatelessWidget {
  const DataStorageInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: ListView(
        children: const [
          ListTile(
            title: Text("How we Store this Data"),
            subtitle: Text("We don't store this data on our servers. It is saved on your device's memory (unencrypted)."),
          ),
          ListTile(
            title: Text("How we Transfer and Use the Data"),
            subtitle: Text("The Data is being transferred to our server with the help of our https api. There it is being decrypted and transfered to the https://pypi.org/project/duolingo-api/ library and the duolingo API. Note that we don't ensure 100% safety on the whole way from your device to the Duolingo API."),
          ),
          ListTile(
            title: Text("Legal Notice"),
            subtitle: Text("We are not responsible for the safety of your data. We do our best to protect your data but you are responsible in the end."),
          )
        ]
      ),
    );
  }
}
