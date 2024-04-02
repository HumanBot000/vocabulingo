import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocabulingo/main.dart';


class GoogleLogin extends StatelessWidget {
  const GoogleLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: defaultAppBar(), body: Text(
      "We don't support this at the Moment. If you logged into duolingo with google, you can try to set a password in your duolingo settings. (IDK if this works this is untested)",
      style: TextStyle(color: Colors.red, fontSize: 20))
    );
  }
}
