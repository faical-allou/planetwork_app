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

  stopWaiting() {
    setState(() {
      status = 'Finished';
    });
  }

  wait() {
    setState(() {
      status = 'Waiting';
    });
  }

  reset() {
    setState(() {
      status = 'Not Run Yet';
    });
  }

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
    Map<String, String> fullList = listInput;
    fullList.addAll(listParam);
    fullList.addAll(listData);

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
                                      size: 80,
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
                  //placeholder: status.analysisName,
                ),
                for (var k in listInput.keys)
                  UploadField(
                    filetype: k,
                    humanName: listInput[k] ?? '',
                  ),
                for (var k in listParam.keys)
                  UploadField(
                    filetype: k,
                    humanName: listParam[k] ?? '',
                  ),
                for (var k in listData.keys)
                  UploadField(
                    filetype: k,
                    humanName: listData[k] ?? '',
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
        SizedBoxGrid(
          gs.listFileNames[widget.filetype] == null
              ? Container()
              : Container(
                  child: Button(
                  child: Text("UPLOAD"),
                  onPressed: () {
                    uploadDataFile(
                        gs,
                        gs.listFiles[widget.filetype],
                        gs.listFileNames[widget.filetype],
                        widget.filetype,
                        setState);
                  },
                )),
        ),
        SizedBoxGrid(
          Container(
            margin: EdgeInsets.all(10),
            //show file name here
            child: progress == '0'
                ? Text("")
                : Text(
                    Path.basename("Progress: $progress"),
                  ),
            //show progress status here
          ),
        ),
      ],
    );
  }
}
