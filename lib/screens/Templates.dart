import 'package:fluent_ui/fluent_ui.dart';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

class UploadField extends StatefulWidget {
  const UploadField({Key? key}) : super(key: key);

  @override
  State<UploadField> createState() => UploadFieldState();
}

class UploadFieldState extends State<UploadField> {
  FilePickerResult? selectedfile;
  late Response response;
  late String progress = '0';
  Dio dio = new Dio();

  selectFile() async {
    selectedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      //allowed extension to choose
    );

    setState(() {}); //update the UI so that file name is shown
  }

  uploadFile() async {
    String uploadurl = "http://localhost:8080/upload/file";

    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromBytes(
          selectedfile?.files.first.bytes ?? [0],
          filename: selectedfile?.files.first.name ?? ''),
      "analysisName": "flutter"
    });

    response = await dio.post(
      uploadurl,
      data: formdata,
      onSendProgress: (int sent, int total) {
        String percentage = (sent / total * 100).toStringAsFixed(2);
        setState(() {
          progress = percentage + " % uploaded";
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
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          //show file name here
          child: selectedfile == null
              ? Text("Choose File")
              : Text(selectedfile?.files.first.name ?? ''),
        ),

        Container(
            child: Button(
          child:
              selectedfile == null ? Text("CHOOSE FILE") : Text("REPLACE FILE"),
          onPressed: () {
            selectFile();
          },
        )),

        //if selectedfile is null then show empty container
        //if file is selected then show upload button
        selectedfile == null
            ? Container()
            : Container(
                child: Button(
                child: Text("UPLOAD"),
                onPressed: () {
                  uploadFile();
                },
              )),
        Container(
          margin: EdgeInsets.all(10),
          //show file name here
          child: progress == '0'
              ? Text("")
              : Text(
                  basename("Progress: $progress"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
          //show progress status here
        ),
      ],
    );
  }
}
