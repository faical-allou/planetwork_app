//import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:planetwork_app/screens/InputScreen.dart';
import 'package:planetwork_app/screens/OutputScreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: NavigationView(
        appBar: NavigationAppBar(
            automaticallyImplyLeading: false,
            title: Text(
                "PlaNetWork, where you work your plan for the network for the planet")),
        content: NavigationBody(
          index: index,
          children: [InputScreen(), OutputScreen()],
        ),
        pane: NavigationPane(
          displayMode: PaneDisplayMode.top,
          selected: index,
          onChanged: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
          items: [
            PaneItem(icon: Icon(FluentIcons.code), title: Text("Input Page")),
            PaneItem(
                icon: Icon(FluentIcons.desktop_flow),
                title: Text("Output Page"))
          ],
        ),
      ),
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.blue,
          iconTheme: const IconThemeData(size: 24)),
    );
  }
}

class GlobalState with ChangeNotifier {
  bool isLoggedIn = false;
  String analysisName = '';
  Map<String, FilePickerResult?> listFiles = {};

  void saveFile(String key, FilePickerResult? file) {
    listFiles[key] = file;
    notifyListeners();
  }

  void logOut() {
    isLoggedIn = false;
    notifyListeners();
  }

  void logIn() {
    isLoggedIn = true;
    notifyListeners();
  }

  void toggleLogIn() {
    isLoggedIn = !isLoggedIn;
    notifyListeners();
  }

  void setAnalysisName(name) {
    analysisName = name;
    notifyListeners();
  }
}
