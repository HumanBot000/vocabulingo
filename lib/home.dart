import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http_cache/http_cache.dart';
import 'package:vocabulingo/learningSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:vocabulingo/duolingoLogin.dart';

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

  Future<Widget> _infoBar() async {
    var request = await httpCacheManager("userInfo_${readHive("username")}", "get_user_info");
    var xp = request["language_data"][readHive("activeLanguage")]["points"]
        .toString();
    var streak = request["language_data"][readHive("activeLanguage")]["streak"]
        .toString();
    var dailyXPRequest = await httpCacheManager("dailyXP_${readHive("username")}", "get_daily_xp");
    var dailyXP = dailyXPRequest["xp_today"].toString();
    var lessonsToday = dailyXPRequest["lessons_today"].length.toString();

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text("$xp XP"),
                  Icon(Icons.leaderboard),
                ],
              ),
              Row(
                children: [
                  Text("XP today: $dailyXP"),
                  Icon(Icons.emoji_events, color: Colors.yellow.shade300),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Text("Streak: $streak"),
                  Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                ],
      ),
                Row(
                  children: [
                    Text("Lessons today: $lessonsToday"),
                  ],
              ),
            ],
          ),
        ],
    );
  }



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
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Something other',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.teal.shade100,
            elevation: 200.0,
            title: FutureBuilder(future: _infoBar(), builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                              color: index.isEven
                                  ? appPrimaryColor
                                  : appSecondaryColor,
                              shape: BoxShape.circle),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text(snapshot.error.toString());
                  } else {
                    return snapshot.data!;
                  }
                }),
            toolbarHeight: 50.0,
            scrolledUnderElevation: 20.0,
            floating: true,
            snap: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (currentPageIndex == 0)
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: getTopicButtons(context),
                  ),
                if (currentPageIndex == 1)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                // Füge weitere Seiten für weitere Indizes hinzu
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final Widget child;
  final Widget? label;

  const Badge({required this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        child,
        if (label != null)
          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 10,
              child: label,
            ),
          ),
      ],
    );
  }
}

