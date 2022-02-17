import 'package:fluent_ui/fluent_ui.dart';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:planetwork_app/main.dart';

class UploadField extends StatefulWidget {
  final String filetype;
  final String humanName;

  UploadField({Key? key, required this.filetype, required this.humanName})
      : super(key: key);

  @override
  State<UploadField> createState() => UploadFieldState();
}

class UploadFieldState extends State<UploadField> {
  late Response response;
  late String progress = '0';
  Dio dio = new Dio();
  FilePickerResult? selectedfile;

  selectFile(gs) async {
    selectedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      //allowed extension to choose
    );
    gs.saveFile(widget.filetype, selectedfile);
    setState(() {}); //update the UI so that file name is shown
  }

  uploadFile(gs) async {
    String uploadurl = "http://localhost:8080/upload/file";

    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromBytes(
          selectedfile?.files.first.bytes ?? [0],
          filename: selectedfile?.files.first.name ?? ''),
      "analysisName": gs.analysisName,
    });
    response = await dio.post(
      uploadurl,
      data: formdata,
      onSendProgress: (int sent, int total) {
        String percentage = (sent / total * 100).toStringAsFixed(2);
        setState(() {
          progress = percentage + "%";
          //update the progress
        });
      },
    );

    if (response.statusCode == 200) {
      print(response.toString());
      //print response from server
    } else {
      print("Error during connection to server.");
    }
  }

  Widget build(BuildContext context) {
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    selectedfile = gs.listFiles[widget.filetype];

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        SizedBoxInput(Text(
          widget.humanName,
        )),
        SizedBoxInput(
          Container(
            //show file name here
            child: selectedfile == null
                ? Text("Choose File")
                : Text(selectedfile?.files.first.name ?? ''),
          ),
        ),
        SizedBoxInput(
          Container(
              child: Button(
            child: selectedfile == null
                ? Text("CHOOSE FILE")
                : Text("REPLACE FILE"),
            onPressed: () {
              selectFile(gs);
            },
          )),
        ),
        SizedBoxInput(
          selectedfile == null
              ? Container()
              : Container(
                  child: Button(
                  child: Text("UPLOAD"),
                  onPressed: () {
                    uploadFile(gs);
                  },
                )),
        ),
        SizedBoxInput(
          Container(
            margin: EdgeInsets.all(10),
            //show file name here
            child: progress == '0'
                ? Text("")
                : Text(
                    basename("Progress: $progress"),
                  ),
            //show progress status here
          ),
        ),
      ],
    );
  }
}

class SizedBoxInput extends StatelessWidget {
  final Widget w;
  SizedBoxInput(this.w);

  Widget build(BuildContext context) {
    return SizedBox(width: 150, height: 50, child: Center(child: this.w));
  }
}
