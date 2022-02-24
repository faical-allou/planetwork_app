//import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:planetwork_app/io/Analysis.dart';
import 'package:provider/provider.dart';
import 'package:planetwork_app/main.dart';

import 'package:planetwork_app/screens/Templates.dart';

class InputScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InputScreenState();
  }
}

class InputScreenState extends State<InputScreen> {
  final myController = TextEditingController();
  String status = 'Not Run Yet';

  stopWaiting() {
    setState(() {
      status = 'Finished';
      print(status);
    });
  }

  wait() {
    setState(() {
      status = 'Waiting';
      print(status);
    });
  }

  reset() {
    setState(() {
      status = 'Not Run Yet';
      print(status);
    });
  }

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
            child: ListView(
              children: [
                TextBox(
                  controller: myController,
                  onChanged: (text) {
                    gs.setAnalysisName(text);
                    reset();
                  },
                  header: 'Name your Analysis here',
                  //placeholder: status.analysisName,
                ),
                UploadField(
                  filetype: 'sked',
                  humanName: 'Your Schedule',
                ),
                UploadField(
                  filetype: 'comp_sked',
                  humanName: 'Competition Schedule',
                ),
                UploadField(
                  filetype: 'demand',
                  humanName: 'Demand',
                ),
                UploadField(
                  filetype: 'demand_curve',
                  humanName: 'Demand Curve',
                ),
                UploadField(
                  filetype: 'preferences',
                  humanName: 'Market Preferences',
                ),
                UploadField(
                  filetype: 'connections',
                  humanName: 'Connections',
                ),
                UploadField(
                  filetype: 'route_cost',
                  humanName: 'Route cost',
                ),
                UploadField(
                  filetype: 'airport_cost',
                  humanName: 'Airport Cost',
                ),
                UploadField(
                  filetype: 'aircraft_cost',
                  humanName: 'Aircraft Cost',
                ),
                Button(
                    child: Text('run'),
                    onPressed: () {
                      setState(() {
                        status = 'Waiting';
                      });
                      launchSim(gs.analysisName, stopWaiting);
                    }),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Waiting(status),
                    ),
                  ),
                ),
              ],
            )));
  }
}
