import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:vocabulingo/learningSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

List<dynamic> getAllTopics() {
  var box = Hive.box('topics');
  if (box.isEmpty) {
    addTopic("All", Icons.abc.codePoint);
  }
  return box.keys.toList();
}
List<dynamic> getAllVocabsInTopic(String topicName) {
  var box = Hive.box('topics');
  return box.get(topicName);
}
bool topicExists(String topicName) {
  var box = Hive.box('topics');
  return box.containsKey(topicName);
}

bool vocabIsInTopic(String topicName, String vocabulary) {
  var box = Hive.box('topics');
  List<dynamic> topicData = box.get(topicName);
  for (dynamic item in topicData) {
    if (item.toString() == [vocabulary].toString()) {
      return true;
    }
  }
  return false;
}

void removeVocabulariesFromTopic(String topicName, List<String>? vocabularies) {
  var box = Hive.box('topics');
  for (String vocabulary in vocabularies!) {
    List<dynamic> list = box.get(topicName);
    list.remove(vocabulary);
    box.delete(topicName);
    box.put(topicName, list);
  }
}
bool topicIsEmpty(String topicName) {
  var box = Hive.box('topics');
  return box.get(topicName).isEmpty;
}
void deleteTopic(String topicName) {
  var box = Hive.box('topics');
  box.delete(topicName);
}
Icon getTopicIcon(String topicName) {
  var box = Hive.box('topicIcons');
  var iconCodePoint = box.get(topicName);
  if (iconCodePoint != null) {
    return Icon(
      IconData(iconCodePoint,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage),
    );
  } else {
    return const Icon(Icons.error);
  }
}

void addTopic(String topicName, int icon) {
  var box = Hive.box('topics');
  var topicIconBox = Hive.box('topicIcons');
  box.put(topicName, []);
  topicIconBox.put(topicName, icon);
}

void addVocabulariesToTopic(String topicName, List<String>? vocabularies) {
  var box = Hive.box('topics');
  for (String vocabulary in vocabularies!) {
    List<dynamic> list = box.get(topicName);
    list.add(vocabulary);
    box.delete(topicName);
    box.put(topicName, list);
  }
}

Future<List<Widget>> getOfficialTopicButtons() async {
  var username = readHive("username");
  var jwt = readHive("jwt");
  var body = jsonEncode(
      {"user": username, "jwt": jwt, "lang": readHive("activeLanguage")});
  List<Widget> children = [];
  var response = await http.post(
      Uri.https(backendAddress(), "get_known_topics"),
      body: body,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json"
      });
  if (response.statusCode == 401) {
    throw "unauthorized";
  }
  List<String> knownTopics = json.decode(response.body).cast<String>();
  for (String topic in knownTopics) {
    children.add(ElevatedButton(
      onPressed: () {},
      child: Text(topic, style: TextStyle(color: Colors.black, fontSize: 20)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    ));
  }
  return children;
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;

  List<Widget> getTopicButtons(BuildContext context) {
    List knownTopics = getAllTopics();
    List<Widget> children = [];
    for (String topic in knownTopics) {
      children.add(Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: Text(topic,
                  style: TextStyle(color: Colors.black, fontSize: 20)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningSession(
                            topic: topic,
                            vocabularies: const [],
                            correctVocabularies: -1,
                            index: -1),
                      ));
                });
              },
            ),
          ),
          getTopicIcon(topic),
        ],
      ));
      children.add(const Divider());
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: defaultAppBar(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(CustomIcons.MyFlutterApp.book_open),
            icon: Icon(CustomIcons.MyFlutterApp.book_open),
            label: 'Vocabularies',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Something other',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Something other',
          ),
        ],
      ),
      body: <Widget>[
        /// Vocabularies page
        ListView(
          children: getTopicButtons(context),
        ),

        /// Messages page
        ListView.builder(
          reverse: true,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hello',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hi!',
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            );
          },
        ),
      ][currentPageIndex],
    );
  }
}
