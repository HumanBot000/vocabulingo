import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/home.dart';
import 'package:vocabulingo/learningSession.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class AddTopic extends StatefulWidget {
  final bool showCreated;
  final String? translation;
  const AddTopic(
      {Key? key,
      required this.vocabulary,
      this.name,
      this.showCreated = true,
      this.translation})
      : super(key: key);

  final List<String> vocabulary;
  final String? name;

  @override
  State<AddTopic> createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  late TextEditingController textFieldController;
  late IconData currentSelectedIcon;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
    currentSelectedIcon = allIcons()[0];

    if (widget.name != null) {
      textFieldController.text = widget.name!;
    }
  }

  List<Widget> _getTopicButtons() {
    List<Widget> children = [];
    if (widget.showCreated) {
      for (String topic in getAllTopics()) {
        children.add(Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700),
                onPressed: () {
                  setState(() {
                    if (vocabIsInTopic(
                        topic,
                        widget.vocabulary.toString().substring(
                            1, widget.vocabulary.toString().length - 1))) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: const Text(
                                      "This vocabulary is already in this topic"),
                                  content: const Text(
                                      "Do you want to remove it from that topic?"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel")),
                                    ElevatedButton(
                                        onPressed: () {
                                          removeVocabulariesFromTopic(topic,
                                              [widget.vocabulary.toString()]);
                                          if (topicIsEmpty(topic)) {
                                            deleteTopic(topic);
                                          }
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Remove")),
                                  ]));
                    } else {
                      if (widget.translation == null) {
                        addVocabulariesToTopic(
                            topic, [widget.vocabulary.toString()]);
                        Navigator.pop(context);
                      } else {
                        addCustomVocabularyToTopic(topic, widget.vocabulary[0],
                            widget.translation.toString());
                        if (topic != "All") {
                          addCustomVocabularyToTopic(
                              "All",
                              widget.vocabulary[0],
                              widget.translation.toString());
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }
                  });
                },
                child: Text(topic,
                    style: TextStyle(color: Colors.black, fontSize: 20)),
              ),
            ),
            getTopicIcon(topic),
            const Divider()
          ],
        ));
      }
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
            value: currentSelectedIcon,
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
              setState(() {
                currentSelectedIcon = selectedIcon!;
              });
            },
          ),
          const Divider(),
        ],
      ),
    ));
    children.add(FloatingActionButton(
      tooltip: "Add new Topic",
      onPressed: () {
        if (textFieldController.text.isNotEmpty) {
          if (topicExists(textFieldController.text)) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Topic already exists"),
                        actions: [
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Ok")),
                          ElevatedButton(
                              onPressed: () {
                                if (widget.translation == null) {
                                  addVocabulariesToTopic(
                                      textFieldController.text,
                                      [widget.vocabulary.toString()]);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  addCustomVocabularyToTopic(
                                      textFieldController.text,
                                      widget.vocabulary[0],
                                      widget.translation.toString());
                                  if (textFieldController.text != "All") {
                                    addCustomVocabularyToTopic(
                                        "All",
                                        widget.vocabulary[0],
                                        widget.translation.toString());
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Add to Topic"))
                        ]));
          } else {
            if (widget.translation == null) {
              addTopic(textFieldController.text, currentSelectedIcon.codePoint);
              addVocabulariesToTopic(
                  textFieldController.text, [widget.vocabulary.toString()]);
              Navigator.pop(context);
            } else {
              addCustomVocabularyToTopic(textFieldController.text,
                  widget.vocabulary[0], widget.translation.toString());
              if (textFieldController.text != "All") {
                addCustomVocabularyToTopic(
                    "All", widget.vocabulary[0], widget.translation.toString());
              }
              Navigator.pop(context);
              Navigator.pop(context);
            }
          }
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Please enter a topic name"),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Ok"))
                      ]));
        }
      },
      child: const Icon(Icons.add),
    ));
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
