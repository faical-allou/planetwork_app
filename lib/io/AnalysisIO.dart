import 'dart:convert' show jsonDecode;
import 'dart:html' as html;

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:planetwork_app/GlobalConfig.dart';

late Response response;
late String progress = '0';
Dio dio = new Dio();

Future<String> uploadDataFile(gs, filetype) async {
  String uploadurl = serverURL + "upload/" + filetype;

  FormData formdata = FormData.fromMap({
    filetype: await MultipartFile.fromBytes(gs.listFiles[filetype] ?? [0],
        filename: gs.listFileNames[filetype] ?? ''),
    "analysisName": gs.analysisName,
  });
  response = await dio.post(
    uploadurl,
    data: formdata,
    onSendProgress: (int sent, int total) {
      String percentage = (sent / total * 100).toStringAsFixed(2);
    },
  );

  if (response.statusCode == 200) {
    return response.toString();
  } else {
    return 'Failed to upload file';
  }
}

Future<String> launchSim(analysisName, runWhenDone, runWhenFail) async {
  String runURL = serverURL + "run/" + analysisName;
  try {
    response = await dio.get(runURL);
  } catch (e) {
    return 'failed';
  }
  if (response.statusCode == 200) {
    if (response.toString() == "done") {
      runWhenDone();
    } else {
      runWhenFail();
    }
    return response.toString();
  } else {
    return 'server failed';
  }
}

void downloadFile(String url) {
  html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}

void downloadTemplateFile(String filetype) {
  String url = serverURL + "download_template/" + filetype;
  downloadFile(url);
}

void downloadRPFile(String name) {
  String url = serverURL + "download_rp/" + name;
  downloadFile(url);
}

void downloadZIPResult(String name) {
  String url = serverURL + "download_resultzip/" + name;
  downloadFile(url);
}

Future<List<String>> fetchListResults() async {
  String url = serverURL + "resultlist/";
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

Future<String> clearResults(analysisName) async {
  String runURL = serverURL + "clear_result/" + analysisName;
  response = await dio.get(runURL);
  if (response.statusCode == 200) {
    //runWhenDone();
    return response.toString();
  } else {
    throw Exception('Failed to launch Sim');
  }
}

class FetchDataException implements Exception {
  final _message;
  FetchDataException([this._message]);

  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }
}
