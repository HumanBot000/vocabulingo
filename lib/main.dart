import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocabulingo/duolingoLogin.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:vocabulingo/googleLogin.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
Color appPrimaryColor = Colors.greenAccent.shade700;
Color appSecondaryColor = Colors.blueAccent.shade100;
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
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
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? firstOpen = prefs.getBool('firstOpen');
  final String? jwt = prefs.getString('jwt_aes');
  final String? username = prefs.getString('username_aes');
  if (firstOpen == null || jwt == null || username == null) {
    return true;
  }
  return false;
}

AppBar defaultAppBar() {
  return AppBar(
    title: const Text("Vocabulingo"),
    backgroundColor: appPrimaryColor,
    centerTitle: true,
  );
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
              icon: Icon(CustomIcons.MyFlutterApp.duolingo_bird),
              label: const Text("Log in with Duolingo")),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GoogleLogin()));
                });
              },
              icon: Icon(CustomIcons.MyFlutterApp.google),
              label: const Text("Log in with Google"))
        ],
      ),
    );
  }
}
