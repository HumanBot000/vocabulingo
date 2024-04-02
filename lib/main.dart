import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocabulingo/duolingoLogin.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:vocabulingo/googleLogin.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulingo/src/configuration.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


void main() async{
  //http
  HttpOverrides.global = MyHttpOverrides();
  //hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  //app
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

Future<String?> readHive(String key) async{
  var _settingsBox = Hive.box('settings');
  return _settingsBox.get(key);
}
void writeHive(String key, String value) async{
  var _settingsBox = Hive.box('settings');
  await _settingsBox.put(key, value);
}

class AppState extends ChangeNotifier {
  int selectedIndex = 0;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<bool>(
          future: isFirstOpen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitFadingCircle(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                        color:
                            index.isEven ? appPrimaryColor : appSecondaryColor,
                        shape: BoxShape.circle),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final isFirstOpen = snapshot.data!;
              ThemeData apptheme = ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: appPrimaryColor),
                useMaterial3: true,
              );
              return MaterialApp(
                title: 'Vocabulingo',
                debugShowCheckedModeBanner: false,
                darkTheme: ThemeData.dark(useMaterial3: true),
                theme: apptheme,
                home: isFirstOpen ? const FirstOpen() : const Home(),
              );
            }
          },
        ));
  }
}

Future<bool> isFirstOpen() async {
  if (await readHive("firstOpen") == null || await readHive("username") == null || await readHive("jwt") == null) {
    return true;
  }
  var username = await readHive("username").then((value) => value.toString());
  var jwt = await readHive("jwt").then((value) => value.toString());
  if (await checkDuolingoCredentials(username,jwt)) {
    return false;
  }
  return true;
}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppState appState;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: defaultAppBar(),
      body: const Text('Home'),
    );
  }
}

class FirstOpen extends StatefulWidget {
  const FirstOpen({super.key});

  @override
  State<FirstOpen> createState() => _FirstOpenState();
}

class _FirstOpenState extends State<FirstOpen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Important Notice"),
            subtitle: Text(
                "This App is in development and there might have critical issues. Use at your own risk."),
          ),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  DuolingoLogin()));
                });

              },
              icon: const Icon(CustomIcons.MyFlutterApp.duolingo_bird),
              label: const Text("Log in with Duolingo")),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GoogleLogin()));
                });
              },
              icon: const Icon(CustomIcons.MyFlutterApp.google),
              label: const Text("Log in with Google"))
        ],
      ),
    );
  }
}
