import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/home.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class AddTopic extends StatefulWidget {
  const AddTopic({super.key});

  @override
  State<AddTopic> createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  late TextEditingController textFieldController = TextEditingController();

  List<Widget> _getTopicButtons() {
    List<Widget> children = [];
    for (String topic in getAllTopics()) {
      children.add(Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700),
              onPressed: () {},
              child: Text(topic,
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            ),
          ),
          getTopicIcon(topic),
          const Divider()
        ],
      ));
    }
    children.add(Container(
      padding: const EdgeInsets.all(50.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: false,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Topic Name',
              ),
              controller: textFieldController,
            ),
          ),
          DropdownButton<IconData>(
            items: allIcons().map((iconData) {
              return DropdownMenuItem<IconData>(
                value: iconData,
                child: Row(
                  children: [
                    Icon(iconData),
                  ],
                ),
              );
            }).toList(),
            onChanged: (selectedIcon) {
              print('Selected Icon: $selectedIcon');
            },
          )
        ],
      ),
    ));
    children.add(FloatingActionButton(
      tooltip: "Add new Topic",
      onPressed: () {},
      child: const Icon(Icons.add),
    )
    );
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: ListView(
        children: _getTopicButtons(),
      ),
    );
  }
}
