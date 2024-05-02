import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vocabulingo/home.dart';
import 'package:vocabulingo/main.dart';
import 'package:vocabulingo/src/configuration.dart';
import 'package:vocabulingo/src/icons/my_flutter_app_icons.dart' as CustomIcons;
import 'package:http/http.dart' as http;
import 'package:swipable_stack/swipable_stack.dart';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';

class LearningSession extends StatefulWidget {
  const LearningSession({
    Key? key,
    required this.topic,
    required this.vocabularies,
    required this.correctVocabularies,
    required this.index
  }) : super(key: key);

  final String topic;
  final List<dynamic> vocabularies;
  final int correctVocabularies;
  final int index;
  @override
  State<LearningSession> createState() => _LearningSessionState();
}

class _LearningSessionState extends State<LearningSession> {
  List<dynamic>? vocabularies;
  int index = 0;
  bool cardExpanded = false;
  int allVocabs = 0;
  int successfulVocabs = 0;
  final audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    if (widget.correctVocabularies == -1) {
      loadVocabularies();
    }
    else{
      index = widget.index;
      allVocabs = widget.vocabularies.length;
      successfulVocabs = widget.correctVocabularies;
    }
  }

  Future<void> loadVocabularies() async {
    var username = readHive("username");
    var jwt = readHive("jwt");
    var lang = readHive("activeLanguage");
    var body = jsonEncode({"user": username, "jwt": jwt, "lang": lang});
    var response = await http.post(
      Uri.https(backendAddress(), "get_vocabularies"),
      body: body,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
    );
    if (response.statusCode == 401) {
      throw "unauthorized";
    }
    List<dynamic> fetchedVocabularies = json.decode(response.body);
    fetchedVocabularies.shuffle();
    allVocabs = fetchedVocabularies.length;
    setState(() {
      vocabularies = fetchedVocabularies;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vocabularies == null) {
      return Scaffold(
        appBar: defaultAppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: defaultAppBar(),
        body: allVocabSession(),
      );
    }
  }

  Widget allVocabSession() {
    return vocabCard(vocabularies![index]);
  }

  Widget getSourceLanguageSVGPath({double width = 20.0, double height = 20.0}) {
    var language = readHive("sourceLanguage");
    List<String> supportedLanguages = [
      "ae",
      "ch",
      "de",
      "cz",
      "dk",
      "es",
      "fr",
      "gr",
      "gb",
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
      return SvgPicture.asset(
        "lib/src/svg/${language}.svg",
        height: height,
        width: width,
      );
    }
    return SvgPicture.asset(
      "lib/src/svg/xx.svg",
      height: width,
      width: height,
    );
  }

  Widget getActiveLanguageSVGPath({double width = 20.0, double height = 20.0}) {
    var language = readHive("activeLanguage");
    List<String> supportedLanguages = [
      "ae",
      "de",
      "ch",
      "cz",
      "dk",
      "es",
      "fr",
      "gr",
      "gb",
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
      return SvgPicture.asset(
        "lib/src/svg/${language}.svg",
        height: height,
        width: width,
      );
    }
    return SvgPicture.asset(
      "lib/src/svg/xx.svg",
      height: width,
      width: height,
    );
  }

  Widget vocabCard(dynamic vocab) {
    List<Widget> children = [];
    if (cardExpanded == false) {
      children = [
        Text("$successfulVocabs / $allVocabs"),
        getActiveLanguageSVGPath(width: 100.0, height: 100.0),
        ListTile(
          title: Text(vocab["text"]),
          subtitle: Text(
            'Do you know how to translate this?',
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
      ];
    } else {
      children = [
        Text("$successfulVocabs / $allVocabs"),
        getActiveLanguageSVGPath(width: 100.0, height: 100.0),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vocab["text"]),
              IconButton(
                  onPressed: () {
                    audioPlayer.setUrl(vocab["audioURL"]);
                    audioPlayer.play();
                  },
                  icon: Icon(Icons.play_arrow_rounded),
                  color: Color.fromRGBO(41, 59, 51, 1.0))
            ],
          ),
          subtitle: Text(
            'Did you know how to translate this?',
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
      ];
    }
    List<String> translations = [];

    if (cardExpanded) {
      for (var translation in vocab["translations"]) {
        translations.add(translation);
      }
      children.add(
        getSourceLanguageSVGPath(width: 40.0, height: 40.0),
      );
      children.add(
        ListTile(
          title: Text(translations.join(",")),
        ),
      );
      children.add(ButtonBar(alignment: MainAxisAlignment.center, children: [
        IconButton(
            onPressed: () {
              setState(() {
                if (vocabularies!.length == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Home()));
                } else {
                  successfulVocabs++;
                  vocabularies!.removeAt(index);
                  cardExpanded = !cardExpanded;
                  index = Random().nextInt(vocabularies!.length);
                }
              });
            },
            icon: Icon(Icons.check),
            color: Color.fromRGBO(70, 195, 120, 1)),
        IconButton(
            onPressed: () {
              setState(() {
                cardExpanded = !cardExpanded;
                index = Random().nextInt(vocabularies!.length);
              });
            },
            icon: Icon(Icons.close),
            color: Color.fromRGBO(220, 90, 108, 1)),
      ]));
    }
    if (cardExpanded) {
      return SwipableStack(
        overlayBuilder: (context, properties) {
          final opacity = min(properties.swipeProgress, 1.0);
          final isRight = properties.direction == SwipeDirection.right;
          final isLeft = properties.direction == SwipeDirection.left;
          final isUp = properties.direction == SwipeDirection.up;
          final isDown = properties.direction == SwipeDirection.down;
          if (isRight) {
            return Opacity(
              opacity: isRight ? opacity : 0,
              child: CardLabel.right(),
            );
          }
          else if (isLeft) {
            return Opacity(
              opacity: isLeft ? opacity : 0,
              child: CardLabel.left(),
            );
          }
            else if (isUp) {
              return Opacity(

                opacity: isUp ? opacity : 0,
                child: CardLabel.up(),
              );
            }
          else if (isDown) {
            return Opacity(
              opacity: isDown ? opacity : 0,
              child: CardLabel.down(),
            );
          }
          return Opacity(
            opacity: isRight ? 0 : opacity,
            child: CardLabel.left(),
          );
        },
        builder: (context, properties) {
          return InkWell(
            onTap: () {
              setState(() {
                cardExpanded = !cardExpanded;
              });
            },
            child: Card(
              elevation: 1.0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: appPrimaryColor, width: 2.0),
              ),
              child: Column(
                children: children,
              ),
            ),
          );
        },
        onSwipeCompleted: (swipeIndex, direction) {
          setState(() {
            if (direction == SwipeDirection.right) {
              if (vocabularies!.length == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              } else {
                successfulVocabs++;
                vocabularies!.removeAt(index);
              }
            }
            cardExpanded = !cardExpanded;
            index = Random().nextInt(vocabularies!.length);
          });
        },
        detectableSwipeDirections: const {
          SwipeDirection.right,
          SwipeDirection.left,
          SwipeDirection.down,
        },
      );
    } else {
      return InkWell(
        onTap: () {
          setState(() {
            cardExpanded = !cardExpanded;
          });
        },
        child: Card(
          elevation: 1.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: appPrimaryColor, width: 2.0),
          ),
          child: Column(
            children: children,
          ),
        ),
      );
    }
  }
}

class SwipeDirectionColor {
  static const right = Color.fromRGBO(70, 195, 120, 1);
  static const left = Color.fromRGBO(220, 90, 108, 1);
  static const up = Color.fromRGBO(83, 170, 232, 1);
  static const down = Color.fromRGBO(41, 59, 51, 1.0);
}

const _labelAngle = math.pi / 2 * 0.2;

class CardLabel extends StatelessWidget {
  const CardLabel._({
    required this.color,
    required this.label,
    required this.angle,
    required this.alignment,
  });

  factory CardLabel.right() {
    return const CardLabel._(
      color: SwipeDirectionColor.right,
      label: 'CORRECT',
      angle: -_labelAngle,
      alignment: Alignment.topLeft,
    );
  }

  factory CardLabel.left() {
    return const CardLabel._(
      color: SwipeDirectionColor.left,
      label: 'WRONG',
      angle: _labelAngle,
      alignment: Alignment.topRight,
    );
  }

  factory CardLabel.up() {
    return const CardLabel._(
      color: SwipeDirectionColor.up,
      label: 'SAVE',
      angle: _labelAngle,
      alignment: Alignment(0, 0.5),
    );
  }

  factory CardLabel.down() {
    return const CardLabel._(
      color: SwipeDirectionColor.down,
      label: 'DOWN',
      angle: -_labelAngle,
      alignment: Alignment(0, -0.75),
    );
  }

  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 36,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 4,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
