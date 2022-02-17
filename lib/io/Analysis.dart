import 'package:dio/dio.dart';
import 'dart:html' as html;

late Response response;
late String progress = '0';
Dio dio = new Dio();

void uploadDataFile(gs, selectedfile, filetype, setState) async {
  String uploadurl = "http://localhost:8080/upload/" + filetype;

  FormData formdata = FormData.fromMap({
    filetype: await MultipartFile.fromBytes(
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
    throw Exception('Failed to upload file');
  }
}

Future<String> launchSim(analysisName) async {
  String runURL = "http://localhost:8080/run/" + analysisName;
  response = await dio.get(runURL);
  if (response.statusCode == 200) {
    return response.toString();
  } else {
    throw Exception('Failed to launch Sim');
  }
}

void downloadFile(String url) {
  String url = "http://localhost:8080/download/test-route_prof.csv";
  html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}
