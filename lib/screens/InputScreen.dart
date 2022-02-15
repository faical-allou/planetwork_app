//import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:planetwork_app/screens/Templates.dart';
import 'package:provider/provider.dart';
import 'package:planetwork_app/main.dart';

class InputScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InputScreenState();
  }
}

class InputScreenState extends State<InputScreen> {
  final myController = TextEditingController();
  @override
  void initState() {
    super.initState();
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    myController.text = gs.analysisName;
  }

  @override
  Widget build(BuildContext context) {
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    return ScaffoldPage(
        header: Text("Select File and Upload"),
        content: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                TextBox(
                  controller: myController,
                  onChanged: (text) {
                    gs.setAnalysisName(text);
                    myController.selection = TextSelection.collapsed(offset: 3);
                  },
                  header: 'Name your Analysis here',
                  //placeholder: status.analysisName,
                ),
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
