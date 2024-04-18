import 'dart:convert';
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
  @override
  Widget build(BuildContext context) {
    if (widget.topic == "All") {
      return Scaffold(
        appBar: defaultAppBar(),
        body: allVocabSession(),
      );
    } else {
      return Placeholder();
    }
  }

  FutureBuilder<List<dynamic>> allVocabSession() {
    return FutureBuilder(
      future: getAllVocabularies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitFadingCircle(
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? appPrimaryColor : appSecondaryColor,
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(40),
            child: Text(snapshot.error.toString()),
          );
        } else {
          return vocabCard((snapshot.data!.toList()..shuffle()).first);
        }
      },
    );
  }
  Widget getActiveLanguageSVGPath({width = 20.0, height = 20.0}) {
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
      return SvgPicture.asset("lib/src/svg/${language}.svg",
          height: height as double, width: width as double);
    }
    return SvgPicture.asset("lib/src/svg/unknown.svg",
        height: width, width: height);
  }
  Card vocabCard(dynamic vocab) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: appPrimaryColor, width: 2.0),
      ),
      child: Column(
        children: [
          getActiveLanguageSVGPath(width: 100.0, height: 100.0),
          ListTile(
            title: Text(vocab["text"]),
            subtitle: Text(
              'Do you know how to translate this?',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.u_turn_right_rounded, color: appPrimaryColor)),
            ],
          )

        ],
      ),
    );
  }

  Future<List<dynamic>> getAllVocabularies() async {
    var username = readHive("username");
    var jwt = readHive("jwt");
    var lang = readHive("activeLanguage");
    var body = jsonEncode({"user": username, "jwt": jwt, "lang": lang});
    var response = await http.post(
      Uri.parse('https://10.0.2.2:5000/get_vocabularies'),
      body: body,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
    );
    if (response.statusCode == 401) {
      throw "unauthorized";
    }
    List<dynamic> vocabularies = json.decode(response.body);
    return vocabularies;
  }
}
