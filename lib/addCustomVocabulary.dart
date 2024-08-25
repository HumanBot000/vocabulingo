import 'package:flutter/material.dart';
import 'package:vocabulingo/addTopic.dart';
import 'package:vocabulingo/learningSession.dart';
import 'package:vocabulingo/src/configuration.dart';

class AddCustomVocabulary extends StatefulWidget {
  const AddCustomVocabulary({super.key});

  @override
  State<AddCustomVocabulary> createState() => _AddCustomVocabularyState();
}

class _AddCustomVocabularyState extends State<AddCustomVocabulary> {
  late TextEditingController vocabularyController;
  late TextEditingController translationController;

  @override
  void initState() {
    super.initState();
    vocabularyController = TextEditingController();
    translationController = TextEditingController();
  }

  @override
  void dispose() {
    vocabularyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(),
        body: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Add Custom Vocabulary",
                style: TextStyle(fontSize: 30),
              ),
              const Text(
                "Please enter the vocabulary and the translations separated by a comma.",
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: vocabularyController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Vocabulary',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: getActiveLanguageSVGPath(),
                    )
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_downward,
                size: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: translationController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Translation',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: getSourceLanguageSVGPath(),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    if (vocabularyController.text == "" ||
                        translationController.text == "") {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      "Please add a vocabulary and a translation."),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK")),
                                  ]));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddTopic(
                                    vocabulary: [vocabularyController.text],
                                    translation: translationController.text,
                                  )));
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Add"),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.save,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ]));
  }
}
