import 'package:fluent_ui/fluent_ui.dart';

import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:planetwork_app/main.dart';
import 'package:planetwork_app/io/Analysis.dart';

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

  selectFile(gs) async {
    selectedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      //allowed extension to choose
    );
    gs.saveFile(widget.filetype, selectedfile);
    setState(() {}); //update the UI so that file name is shown
  }

  Widget build(BuildContext context) {
    GlobalState gs = Provider.of<GlobalState>(context, listen: false);
    selectedfile = gs.listFiles[widget.filetype];

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: [
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
                    uploadDataFile(gs, selectedfile, widget.filetype, setState);
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

class Waiting extends StatelessWidget {
  final String status;
  Waiting(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Not Run Yet':
        return Container();
      case 'Finished':
        return Icon(FluentIcons.check_mark);
      case 'Waiting':
        return ProgressRing();
      default:
        return Container();
    }
  }
}

class ResultElement extends StatelessWidget {
  final String name;
  ResultElement(this.name);

  @override
  Widget build(BuildContext context) {
    return Wrap(alignment: WrapAlignment.spaceBetween, children: [
      Text(name),
      Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 150,
          height: 50,
          child: Center(
            child: Button(
              child: Text("Download Route Prof for " + name),
              onPressed: () {
                downloadFile("http://localhost:8080/download/" +
                    name +
                    "-route_prof.csv");
              },
            ),
          ),
        ),
      )
    ]);
  }
}
