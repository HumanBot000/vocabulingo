import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:vocabulingo/addCustomVocabulary.dart';
import 'package:vocabulingo/addTopic.dart';
import 'package:vocabulingo/learningSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;
import 'package:vocabulingo/duolingoLogin.dart';
import 'package:vocabulingo/information/copyright.dart';
import 'package:vocabulingo/learningSession.dart';

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
    if (item.toString() == vocabulary.toString() ||
        item.toString() == [vocabulary].toString()) {
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

Future<void> autoAddAllVocabulariesToTopic() async {
  var response = await httpCacheManager("vocabularies", "get_vocabularies",
      formatAsJson: false);
  if (response == null || response.isEmpty) {
    //todo show error
    return;
  }
  List<dynamic> fetchedVocabularies = json
      .decode(response.replaceAll("True", "true").replaceAll("False", "false"));
  for (var vocab in fetchedVocabularies) {
    if (!vocab.containsKey("related_skills")) {
      continue;
    }
    for (var topic in vocab["related_skills"]) {
      if (!topicExists(topic)) {
        addTopic(topic,
            iconDataList[Random().nextInt(iconDataList.length)].codePoint);
      }
      if (!vocabIsInTopic(topic, vocab["text"])) {
        addVocabulariesToTopic(topic, [vocab["text"]]);
      }
    }
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
      child: Text(topic,
          style: const TextStyle(color: Colors.black, fontSize: 20)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    ));
  }
  return children;
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  late TabController tabController;

  Future<Widget> _infoBar() async {
    bool isConnected = await checkBackendConnection();
    if (!isConnected) {
      return const Row(
        children: [
          Text(
            "Offline, currently using cached data",
            style: TextStyle(color: Colors.red),
          ),
        ],
      );
    }
    var request = await httpCacheManager(
        "userInfo_${readHive("username")}", "get_user_info");
    var xp = request["language_data"][readHive("activeLanguage")]["points"]
        .toString();
    var streak = request["language_data"][readHive("activeLanguage")]["streak"]
        .toString();
    var dailyXPRequest = await httpCacheManager(
        "dailyXP_${readHive("username")}", "get_daily_xp");
    var dailyXP = dailyXPRequest["xp_today"].toString();
    var lessonsToday = dailyXPRequest["lessons_today"].length.toString();

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text("$xp XP"),
                  const Icon(Icons.leaderboard),
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
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orange),
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
      ),
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
                  style: const TextStyle(color: Colors.black, fontSize: 20)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningSession(
                            topic: topic,
                            vocabularies: const [],
                            correctVocabulariesCount: -1,
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
  void initState() {
    super.initState();
    checkResumeSession();
  }

  void checkResumeSession() async {
    if (await sessionIsResumeable()) {
      var _sessionData = await sessionResumeData();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Resume your last session? (${_sessionData["topic"]})"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LearningSession(
                              topic: _sessionData["topic"],
                              vocabularies:
                                  _sessionData["remainingVocabularies"],
                              correctVocabulariesCount:
                                  _sessionData["correctVocabularies"],
                              index: _sessionData["index"],
                            )));
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (currentPageIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text('Add a new Topic'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTopic(
                              vocabulary: [], showCreated: false),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Add a Vocabulary to a Topic'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCustomVocabulary(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }

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
        destinations: <Widget>[
          const NavigationDestination(
            icon: Icon(CustomIcons.MyFlutterApp.book_open),
            label: 'Vocabularies',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(
                Icons.add,
                size: 40,
                color: Colors.greenAccent.shade200,
              ),
            ),
            label: 'Add Vocabularies',
          ),
          const NavigationDestination(
            icon: Badge(
              child: Icon(Icons.settings),
            ),
            label: 'Settings',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.teal.shade100,
            elevation: 200.0,
            title: FutureBuilder(
              future: _infoBar(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SpinKitFadingCircle(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? appPrimaryColor
                              : appSecondaryColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return snapshot.data!;
                }
              },
            ),
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
                    physics: const NeverScrollableScrollPhysics(),
                    children: getTopicButtons(context),
                  ),
                if (currentPageIndex == 1) const SizedBox(),
                // Empty placeholder to ensure the bottom sheet is shown
                if (currentPageIndex == 2)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      buildSettingsButtonRow(
                        context: context,
                        label: "Copyright",
                        icon: Icons.copyright,
                        destination: const Copyright(),
                      ),
                      buildSettingsButtonRow(
                        context: context,
                        label: "Auto-Add Vocabularies to topic",
                        icon: Icons.add,
                        onPressed: autoAddAllVocabulariesToTopic,
                      ),
                      buildSettingsButtonRow(
                        context: context,
                        label: "Resume my last Learning Session",
                        icon: Icons.play_arrow,
                        onPressed: () async {
                          await handleResumeSession(context);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsButtonRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    Widget? destination,
    VoidCallback? onPressed,
  }) {
    return Row(
      children: [
        ElevatedButton(
          child: Text(label),
          onPressed: onPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination!),
                );
              },
        ),
        Icon(icon),
      ],
    );
  }

  Future<void> handleResumeSession(BuildContext context) async {
    if (!await sessionIsResumeable()) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("There is no Session to resume"),
              ));
    } else {
      var sessionData = await sessionResumeData();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Resume your last session? (${sessionData["topic"]})"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LearningSession(
                              topic: sessionData["topic"],
                              vocabularies:
                                  sessionData["remainingVocabularies"],
                              correctVocabulariesCount:
                                  sessionData["correctVocabularies"],
                              index: sessionData["index"],
                            )));
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        ),
      );
    }
  }
}

class Badge extends StatelessWidget {
  final Widget child;
  final Widget? label;
  final int radius;

  const Badge({super.key, required this.child, this.label, this.radius = 10});

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
              radius: radius.toDouble(),
              child: label,
            ),
          ),
      ],
    );
  }
}
