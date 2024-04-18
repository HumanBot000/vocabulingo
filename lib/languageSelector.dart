import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocabulingo/home.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

void setLanguage(String language, context) {
  writeHive("activeLanguage", language);
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => const Home()));
}



class _LanguageSelectorState extends State<LanguageSelector> {
  bool _isSupported(String language) {
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
    ]; //todo check if duolingo returns actually these codes
    return supportedLanguages.contains(language);
  }

  Future<Widget> _buildContainer() async {
    var username = readHive("username");
    var jwt = readHive("jwt");
    var body = jsonEncode({"user": username, "jwt": jwt});
    var response = await http.post(
        Uri.parse('https://10.0.2.2:5000/get_full_language_info'),
        body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });
    if (response.statusCode == 401) {
      throw "unauthorized";
    }
    List<String> languages = json.decode(response.body)[0].cast<String>();
    List<String> fullName = json.decode(response.body)[1].cast<String>();
    List<Widget> children = [];
    for (String language in languages) {
      children.add(
        ElevatedButton.icon(
          onPressed: () {
            setLanguage(language, context);
          },
          icon: _isSupported(language)
              ? SvgPicture.asset("lib/src/svg/${language}.svg",
                  height: 20, width: 20)
              : SvgPicture.asset(height: 20, width: 20, "lib/src/svg/xx.svg"),
          label: Text(fullName[languages.indexOf(language)]),
        ),
      );
    }
    return ListView(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: Stack(
        children: [
          FutureBuilder<Widget>(
              future: _buildContainer(),
              builder: (context, snapshot) {
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
              })
        ],
      ),
    );
  }
}
