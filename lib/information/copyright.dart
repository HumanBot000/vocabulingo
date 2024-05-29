import 'package:flutter/material.dart';
import 'package:vocabulingo/src/configuration.dart';
class Copyright extends StatefulWidget {
  const Copyright({super.key});

  @override
  State<Copyright> createState() => _CopyrightState();
}

class _CopyrightState extends State<Copyright> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: Stack(
        children: [Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
              children: [const Text(
                """
        Vocabulingo is an unofficial enthusiast project based on Duolingo public data. "Duolingo" trademark, graphics and logos used in this website do indeed belong to duolingo.com and its respective owners.
        Should duolingo.com ever decide to shut Vocabulingo down, then so be it. I do believe though that Vocabulingo falls under the fair use concept and everything I do - I do with a great deal of respect.
        """,
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              ]
          ),
        ),
        ]
      ),
    );
  }
}