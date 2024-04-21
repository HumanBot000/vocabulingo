import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;

class LearningSession extends StatefulWidget {
  const LearningSession({
    Key? key,
    required this.topic,
  }) : super(key: key);

  final String topic;

  @override
  State<LearningSession> createState() => _LearningSessionState();
}

class _LearningSessionState extends State<LearningSession> {
  List<dynamic>? vocabularies;
  int index = 0;
  bool cardExpanded = false;
  @override
  void initState() {
    super.initState();
    loadVocabularies();
  }

  Future<void> loadVocabularies() async {
    var username = readHive("username");
    var jwt = readHive("jwt");
    var lang = readHive("activeLanguage");
    var body = jsonEncode({"user": username, "jwt": jwt, "lang": lang});
    var response = await http.post(
      Uri.parse('${backendAddress()}/get_vocabularies'),
      body: body,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
    );
    if (response.statusCode == 401) {
      throw "unauthorized";
    }
    List<dynamic> fetchedVocabularies = json.decode(response.body);
    fetchedVocabularies.shuffle();
    setState(() {
      vocabularies = fetchedVocabularies;
      index = Random().nextInt(vocabularies!.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vocabularies == null) {
      return Scaffold(
        appBar: defaultAppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: defaultAppBar(),
        body: allVocabSession(),
      );
    }
  }

  Widget allVocabSession() {
    return vocabCard(vocabularies![index]);
  }

  Widget getActiveLanguageSVGPath({double width = 20.0, double height = 20.0}) {
    var language = readHive("activeLanguage");
    List<String> supportedLanguages = [
      "ae",
      "ch",
      "cz",
      "dk",
      "es",
      "fr",
      "gr",
      "gb-wls",
      "it",
      "nl",
      "ie",
      "il",
      "in",
      "jp",
      "kr",
      "no",
      "pl",
      "pt",
      "ro",
      "ru",
      "se",
      "ch",
      "tr",
      "ua",
      "us",
      "vn"
    ];
    if (supportedLanguages.contains(language)) {
      return SvgPicture.asset(
        "lib/src/svg/${language}.svg",
        height: height,
        width: width,
      );
    }
    return SvgPicture.asset(
      "lib/src/svg/unknown.svg",
      height: width,
      width: height,
    );
  }

  Widget vocabCard(dynamic vocab) {
    var children = [
      getActiveLanguageSVGPath(width: 100.0, height: 100.0),
      ListTile(
        title: Text(vocab["text"]),
        subtitle: Text(
          'Do you know how to translate this?',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ),
    ];
    if (cardExpanded) {
      String translations = "";
      for (var translation in vocab["translations"]) {
        translations += translation["translation"] + ",";
      }
      children.add(
        ListTile(
          title: Text(translations),
        )
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          cardExpanded = !cardExpanded;
        });
      },
      child: Card(
        elevation: 1.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: appPrimaryColor, width: 2.0),
        ),
        child: Column(
          children:children
        ),
      ),
    );
  }
}
