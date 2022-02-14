//import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:planetwork_app/screens/Templates.dart';

class InputScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InputScreenState();
  }
}

class InputScreenState extends State<InputScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: Text("Select File and Upload"),
        content: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                UploadField(),
                UploadField(),
                UploadField(),
                UploadField(),
                UploadField(),
                UploadField(),
              ],
            )));
  }
}
