import 'package:flutter/material.dart';
import 'package:vocabulingo/main.dart';
class JWT extends StatelessWidget {
  const JWT({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Json Web Token"),
            subtitle: Text("Duolingo makes it very hard to build something around their systems. That's why you can't use a Password and must use a JWT. These Tokens expire and have to be renewed ~1xYear"),
          ),
          ListTile(
            title: Text("How to get a JWT"),
            subtitle: Text("Go to https://www.duolingo.com/learn on your PC->login->Right Click->Inspect->App->Cookies->Search for 'jwt_token'->Send the Value to your phone->Insert it."),
          )
        ]
      ),
    );
  }
}
