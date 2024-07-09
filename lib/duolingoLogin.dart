import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/information/JWT.dart';
import 'package:vocabulingo/languageSelector.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:vocabulingo/information/dataStorageInformation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/home.dart';
class DuolingoLogin extends StatefulWidget {
  DuolingoLogin({super.key});

  @override
  State<DuolingoLogin> createState() => _DuolingoLoginState();
}
Future<bool> checkBackendConnection() async {
  try {
    var request = await http.get(Uri.https(backendAddress(), "test"));
    return request.statusCode == 200;
  }
  catch (e){
    return false;
  }
}
Future<dynamic> httpCacheManager(String cacheKey, String urlEndpoint,
    {int deletionProbability = 10,
      bool returnResponseCode = false,
      bool formatAsJson = true,
      customBody = null}) async {
  var username = readHive("username");
  var jwt = readHive("jwt");
  var language = readHive("activeLanguage");
  final cacheManager = DefaultCacheManager();
  if (appIsInDebugState()){
    await cacheManager.removeFile(cacheKey);
  }


  if ((deletionProbability == 0 ||
      Random().nextInt(deletionProbability) == 1) &&
      await checkBackendConnection()) {
    await cacheManager.removeFile(cacheKey);
  }

  var fileInfo = await cacheManager.getFileFromCache(cacheKey);

  if (fileInfo != null) {
    final cachedData = await fileInfo.file.readAsString();
    if (returnResponseCode) {
      return 200;
    }
    if (formatAsJson) {
      return json.decode(cachedData);
    }
    return cachedData;
  } else {
    var body = jsonEncode({"user": username, "jwt": jwt, "lang": language});
    var response = await http.post(
      Uri.https(backendAddress(), urlEndpoint),
      body: customBody ?? body,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json"
      },
    );

    if (returnResponseCode) {
      return response.statusCode;
    }

    if (response.statusCode == 200) {
      print('Caching response for $cacheKey');
      await cacheManager.putFile(
        cacheKey,
        response.bodyBytes,
        fileExtension: 'json',
        eTag: DateTime.now().toIso8601String(),
      );
    } else {
    }

    if (formatAsJson) {
      return json.decode(response.body);
    }
    return response.body;
  }
}

Future<bool> checkDuolingoCredentials(String username, String jwt,{bool uiLanguage=false,int deletionProbability = 20}) async {
  var response = await http.post(Uri.https(backendAddress(), "check_credentials"), body: jsonEncode({"user": username, "jwt": jwt}),headers: {"Accept": "application/json", "content-type": "application/json"});
  if (response.statusCode == 200 || response.statusCode == 408) {
    if (uiLanguage){
        var sourceLanguage = await httpCacheManager("source_language", "get_ui_language",deletionProbability: deletionProbability,customBody: jsonEncode({"user": username, "jwt": jwt}));
        writeHive("sourceLanguage", sourceLanguage["ui_language"]);
    }
    return true;
  } else {
    return false;
  }
}

class _DuolingoLoginState extends State<DuolingoLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void loginSuccess(String username, String jwt) {
      writeHive("firstOpen", "false");
      writeHive("username", username);
      writeHive("jwt", jwt);
      Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSelector()));
    }
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
        appBar: defaultAppBar(),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Duolingo Login",
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.1),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Enter your duolingo Username",
                              labelText: "Username",
                              border: UnderlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                              )),
                          controller: _usernameController,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Enter your JW Token",
                              labelText: "Json Web Token",
                              border: UnderlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                              )),
                          controller: _passwordController,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        child: const Text("What is my JW Token?",
                            style: TextStyle(height: 10)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const JWT()));
                        })
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            "I have read and accepted these terms. (How we store this data)",
                            style: TextStyle(color: Colors.orange.shade300)),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DataStorageInformation()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.15),
                FloatingActionButton(
                  onPressed: () {
                    if (_usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      checkDuolingoCredentials(uiLanguage: true,
                          _usernameController.text, _passwordController.text,deletionProbability: 0)
                          .then((value) {
                        if (value) {
                          loginSuccess(_usernameController.text, _passwordController.text);
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  AlertDialog(
                                      title: const Text("Error"),
                                      content:
                                      const Text("Wrong Username or JWT"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Ok"))
                                      ]));
                        }
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                  title: const Text("Error"),
                                  content:
                                  const Text("Please fill in all fields"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Ok"))
                                  ]));
                    }
                  },
                  tooltip: "Continue",
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          )
        ]));
  }
}
