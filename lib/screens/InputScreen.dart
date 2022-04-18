import 'dart:typed_data';
import 'dart:core';

import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:planetwork_app/io/AnalysisIO.dart';
import 'package:planetwork_app/main.dart';
import 'package:planetwork_app/models/ModelData.dart';
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
  String dropZoneState = '';
  String progress = "0%";

  handleHover() {
    setState(() {
      dropZoneState = 'Hovering';
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

  getReady(readinessFromGS) {
    if (readinessFromGS) {
      setState(() {
        status = 'Files Ready';
      });
    }
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

  refresh() {
    setState(() {});
  }

  void handleDrop(htmlFile, controller, gs, handleLeaveHover) async {
    final bytes = await controller.getFileData(htmlFile);
    String name = await controller.getFilename(htmlFile);
    String type = detectFileType(htmlFile, controller, name);
    gs.saveFile(type, bytes, name);
    getReady(gs.isReady);
    handleLeaveHover();
  }

  String detectFileType(htmlFile, controller, name) {
    RegExp splitter = new RegExp('[.-]', caseSensitive: false);
    var listSplit = name.split(splitter);

    for (var i = 0; i < listSplit.length; i++) {
      for (var k in fullList.keys) {
        if (k == listSplit[i]) {
          return k;
        }
      }
    }
    return 'type not found';
  }

  Future<void> showAlert(titleText, contentText, actionText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ContentDialog(
          title: Text(titleText),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contentText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(actionText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    myController.text = gs.analysisName;
    getReady(gs.isReady);
  }

  @override
  Widget build(BuildContext context) {
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    late DropzoneViewController dropController;

    return ScaffoldPage(
        content: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(40),
            child: ListView(
              children: [
                SizedBox(
                    height: 120,
                    width: 600,
                    child: Stack(
                      children: [
                        DropzoneView(
                          operation: DragOperation.copy,
                          cursor: CursorType.grab,
                          onCreated: (ctrl) => dropController = ctrl,
                          onError: (String? ev) => print('Error: $ev'),
                          onHover: () => handleHover(),
                          onDrop: (ev) => handleDrop(
                              ev, dropController, gs, handleLeaveHover),
                          onLeave: () => handleLeaveHover(),
                        ),
                        dropZoneState == ''
                            ? Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    Icon(
                                      FluentIcons.upload,
                                      size: 40,
                                      color: customGrey,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Drop files here to upload',
                                          style: TextStyle(fontSize: 14),
                                        )),
                                  ]))
                            : Center(
                                child: DottedBorder(
                                    color: customGrey,
                                    padding: EdgeInsets.only(
                                        top: 24.0, left: 200, right: 200),
                                    dashPattern: [2, 1],
                                    strokeWidth: 2,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(FluentIcons.add,
                                              size: 40, color: customGrey),
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "yes, here, we'll assign them",
                                                style: TextStyle(fontSize: 14),
                                              )),
                                        ])))
                      ],
                    )),
                Container(height: 30),
                TextBox(
                  controller: myController,
                  onChanged: (text) {
                    gs.setAnalysisName(text);
                    reset();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[ 0-9a-zA-Z_-]')),
                  ],
                  header:
                      'Name your Analysis here (only letters, numbers and " ","-","_" )',
                ),
                Wrap(alignment: WrapAlignment.spaceAround, children: [
                  SizedBoxGrid(Text(
                    'Template',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SizedBoxGrid(Text(
                    'File content',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SizedBoxGrid(Text(
                    'File type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SizedBoxGrid(Text(
                    'File name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SizedBoxGrid(Text(' ')),
                ]),
                for (var k in fullList.keys)
                  UploadField(
                    filetype: k,
                    humanName: listInput[k] ?? '',
                  ),
                SizedBoxGrid(
                  gs.isReady
                      ? FilledButton(
                          child: WaitingButtonText(status),
                          onPressed: () async {
                            int counter = 0;
                            if (gs.analysisName.length > 0) {
                              startUploading();
                              for (var k in fullList.keys) {
                                String res = await uploadDataFile(gs, k);
                                if (res == 'done') {
                                  counter += 1;
                                }
                              }
                              if (counter == fullList.length) {
                                startWaiting();
                                String res2 = await launchSim(
                                    gs.analysisName, stopWaiting, reset);
                                print(res2);
                              } else {
                                showAlert(
                                    'Problem while uploading',
                                    'Your files could not be uploaded',
                                    'Check files and try again');
                                reset();
                              }
                            } else {
                              showAlert('Missing Analysis Name',
                                  'Your analysis needs a name', 'Add name');
                            }
                          })
                      : Container(),
                ),
                status == 'Done'
                    ? ResultElement(gs.analysisName, refresh)
                    : Container(),
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
        SizedBoxGrid(
          Container(
              child: IconButton(
            icon: Icon(FluentIcons.download),
            onPressed: () {
              downloadTemplateFile(widget.filetype);
            },
          )),
        ),
        SizedBoxGrid(Text(
          widget.humanName,
        )),
        SizedBoxGrid(Text("(" + widget.filetype + ")")),
        SizedBoxGrid(
          Container(
            //show file name here
            child: gs.listFileNames[widget.filetype] == null
                ? Text("--")
                : Text(gs.listFileNames[widget.filetype] ?? ''),
          ),
        ),
        SizedBoxGrid(
          Container(
              child: gs.listFileNames[widget.filetype] == null
                  ? Button(
                      child: Text("CHOOSE FILE"),
                      onPressed: () {
                        selectFile(gs);
                      },
                    )
                  : FilledButton(
                      child: Text("REPLACE FILE"),
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
        return Text("Select all files");
      case 'Files Ready':
        return Text("Upload and Run");
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
