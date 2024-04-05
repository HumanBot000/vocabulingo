import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

Future<List<Widget>> getTopicButtons() async {
  var username = readHive("username");
  var jwt = readHive("jwt");
  var body = jsonEncode({
    "user": username,
    "jwt": jwt,
    "lang": readHive("activeLanguage")
  });
  List<Widget> children = [];
  var response = await http.post(
      Uri.parse('https://10.0.2.2:5000/get_known_topics'),
      body: body, headers: {
    "Accept": "application/json",
    "content-type": "application/json"
  });
  if (response.statusCode == 401) {
    throw "unauthorized";
  }
  List<String> knownTopics = json.decode(response.body).cast<String>();
  for (String topic in knownTopics) {
    children.add(
        ElevatedButton(onPressed: () {},
          child: Text(
              topic, style: TextStyle(color: Colors.black, fontSize: 20)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),)
    );
  }
  return children;
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  int currentPageIndex = 0;

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
        destinations: <Widget>[
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
              label: Text('2'),
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Something other',
          ),
        ],
      ),
      body: <Widget>[

        /// Vocabularies page
        FutureBuilder<List<Widget>>(
          future: getTopicButtons(),
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
              print(snapshot.error.toString());
              return Text(snapshot.error.toString());
            } else {
              return ListView(children: snapshot.data!);
            }
          },
        ),


        /// Messages page
        ListView.builder(
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
      ][currentPageIndex],
    );
  }
}
