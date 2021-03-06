import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:planetwork_app/models/ModelData.dart';
import 'package:provider/provider.dart';

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
  bool isReady = false;
  Map<String, Uint8List?> listFiles = {};
  Map<String, String?> listFileNames = {};

  void checkIfReady() {
    isReady = listFiles.length == fullList.length;
    notifyListeners();
  }

  void saveFile(String key, Uint8List? file, String? name) {
    listFiles[key] = file;
    listFileNames[key] = name;
    checkIfReady();
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
