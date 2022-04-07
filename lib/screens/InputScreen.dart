//import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:planetwork_app/io/Analysis.dart';
import 'package:provider/provider.dart';
import 'package:planetwork_app/main.dart';
import 'package:planetwork_app/models/ModelData.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:typed_data';
import 'dart:core';

import 'package:planetwork_app/screens/Templates.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;

class InputScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InputScreenState();
  }
}

class InputScreenState extends State<InputScreen> {
  final myController = TextEditingController();
  String status = 'Not Run Yet';
  String dropZoneState = '';

  handleHover() {
    setState(() {
      dropZoneState = 'Hovering';
      print(dropZoneState);
    });
  }

  handleLeaveHover() {
    setState(() {
      dropZoneState = '';
    });
  }

  startUploading() {
    setState(() {
      status = 'Uploading';
    });
  }

  stopWaiting() {
    setState(() {
      status = 'Done';
    });
  }

  startWaiting() {
    setState(() {
      status = 'Waiting';
    });
  }

  reset() {
    setState(() {
      status = "Not Run Yet";
    });
  }

  void handleDrop(htmlFile, controller, gs, setState) async {
    final bytes = await controller.getFileData(htmlFile);
    String name = await controller.getFilename(htmlFile);
    String type = detectFileType(htmlFile, controller, name);
    gs.saveFile(type, bytes, name);
    setState(() {
      dropZoneState = '';
    }); //update the UI so that file name is shown;
  }

  String detectFileType(htmlFile, controller, name) {
    RegExp splitter = new RegExp('[.-]', caseSensitive: false);
    var listSplit = name.split(splitter);

    for (var i = 0; i < listSplit.length; i++) {
      print("Listsplit==  " + listSplit[i]);
      for (var k in fullList.keys) {
        print("k==  " + k);
        if (k == listSplit[i]) {
          return k;
        }
      }
    }
    return 'type not found';
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
    late DropzoneViewController dropController;

    return ScaffoldPage(
        header: Text("Select File and Upload"),
        content: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(40),
            child: ListView(
              children: [
                SizedBox(
                    height: 150,
                    width: 600,
                    child: Stack(
                      children: [
                        DropzoneView(
                          operation: DragOperation.copy,
                          cursor: CursorType.grab,
                          onCreated: (ctrl) => dropController = ctrl,
                          onError: (String? ev) => print('Error: $ev'),
                          onHover: () => handleHover(),
                          onDrop: (ev) =>
                              handleDrop(ev, dropController, gs, setState),
                          onLeave: () => handleLeaveHover(),
                        ),
                        dropZoneState == ''
                            ? Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    Icon(
                                      FluentIcons.upload,
                                      size: 60,
                                      color: Color.fromARGB(255, 60, 60, 61),
                                    ),
                                    Text(
                                      'Drop Files Here',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ]))
                            : Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    Icon(
                                      FluentIcons.add_field,
                                      size: 80,
                                      color: Color.fromARGB(255, 60, 60, 61),
                                    ),
                                    Text(
                                      ' ',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ]))
                      ],
                    )),
                TextBox(
                  controller: myController,
                  onChanged: (text) {
                    gs.setAnalysisName(text);
                    reset();
                  },
                  header: 'Name your Analysis here',
                ),
                for (var k in fullList.keys)
                  UploadField(
                    filetype: k,
                    humanName: listInput[k] ?? '',
                  ),
                Button(
                    child: WaitingButtonText(status),
                    onPressed: () async {
                      startUploading();
                      for (var k in fullList.keys) {
                        await uploadDataFile(gs, k, setState);
                      }
                      startWaiting();
                      await launchSim(gs.analysisName, stopWaiting);
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

class UploadField extends StatefulWidget {
  final String filetype;
  final String humanName;

  UploadField({Key? key, required this.filetype, required this.humanName})
      : super(key: key);

  @override
  State<UploadField> createState() => UploadFieldState();
}

class UploadFieldState extends State<UploadField> {
  late String progress = '0';
  FilePickerResult? selectedfile;
  Uint8List? selectedfilebytes;
  String? selectedfilename;

  selectFile(gs) async {
    selectedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      //allowed extension to choose
    );
    selectedfilebytes = selectedfile?.files.first.bytes;
    selectedfilename = selectedfile?.files.first.name;

    gs.saveFile(widget.filetype, selectedfilebytes, selectedfilename);
    setState(() {}); //update the UI so that file name is shown
  }

  Widget build(BuildContext context) {
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    selectedfilebytes = gs.listFiles[widget.filetype];

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: [
        SizedBoxGrid(Text(
          widget.humanName,
        )),
        SizedBoxGrid(Text("(" + widget.filetype + ")")),
        SizedBoxGrid(
          Container(
            //show file name here
            child: gs.listFileNames[widget.filetype] == null
                ? Text("Choose File")
                : Text(gs.listFileNames[widget.filetype] ?? ''),
          ),
        ),
        SizedBoxGrid(
          Container(
              child: Button(
            child: gs.listFileNames[widget.filetype] == null
                ? Text("CHOOSE FILE")
                : Text("REPLACE FILE"),
            onPressed: () {
              selectFile(gs);
            },
          )),
        ),
      ],
    );
  }
}

class Waiting extends StatelessWidget {
  final String status;
  Waiting(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Not Run Yet':
        return Container();
      case 'Done':
        return Icon(FluentIcons.check_mark);
      case 'Waiting':
        return ProgressRing();
      case 'Uploading':
        return ProgressBar();
      default:
        return Container();
    }
  }
}

class WaitingButtonText extends StatelessWidget {
  final String status;
  WaitingButtonText(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Not Run Yet':
        return Text("Upload all files and Run");
      case 'Done':
        return Text("Results available in the Output Page - Click to rerun");
      case 'Waiting':
        return Text("Running Simulation ...");
      case 'Uploading':
        return Text("Uploading ... ");
      default:
        return Text("Upload all files and Run");
    }
  }
}
