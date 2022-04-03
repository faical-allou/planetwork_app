import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

late Response response;
late String progress = '0';
Dio dio = new Dio();

void uploadDataFile(
    gs, selectedfilebytes, selectedfilename, filetype, setState) async {
  String uploadurl = "http://localhost:8080/upload/" + filetype;

  FormData formdata = FormData.fromMap({
    filetype: await MultipartFile.fromBytes(selectedfilebytes ?? [0],
        filename: selectedfilename ?? ''),
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

Future<String> launchSim(analysisName, runWhenDone) async {
  String runURL = "http://localhost:8080/run/" + analysisName;
  response = await dio.get(runURL);
  if (response.statusCode == 200) {
    runWhenDone();
    return response.toString();
  } else {
    throw Exception('Failed to launch Sim');
  }
}

void downloadFile(String url) {
  html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}

Future<List<String>> fetchListResults() async {
  String url = "http://localhost:8080/resultlist/";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Iterable l = jsonDecode(response.body);
    List<String> listResults =
        List<String>.from(l.map((item) => item.toString()));

    return listResults;
  } else {
    throw Exception('Failed to load chef');
  }
}
