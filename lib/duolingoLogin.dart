import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulingo/JWT.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:vocabulingo/dataStorageInformation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DuolingoLogin extends StatefulWidget {
  DuolingoLogin({super.key});

  @override
  State<DuolingoLogin> createState() => _DuolingoLoginState();
}

Future<bool> checkCredentials(String username, String jwt) async {
  print("Checking");
  var body = jsonEncode({
    "user": username,
    "jwt": jwt
  });
  var response = await http
      .post(
      Uri.parse('https://10.0.2.2:5000/check_credentials'), body: body,headers: {
  "Accept": "application/json",
  "content-type": "application/json"
  });
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

class _DuolingoLoginState extends State<DuolingoLogin> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
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
                        controller: usernameController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
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
                        controller: passwordController,
                      ),
                    ),
                  ],
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
                      child: Text(
                          "I have read and accepted these terms. (How we store this data)",
                          style: TextStyle(
                              height: 10, color: Colors.orange.shade300)),
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
                    if (!usernameController.text.isEmpty &&
                        !passwordController.text.isEmpty) {
                      checkCredentials(
                          usernameController.text, passwordController.text)
                          .then((value) {
                        if (value) {
                          print("Passed");
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
