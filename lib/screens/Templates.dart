import 'package:fluent_ui/fluent_ui.dart';

import 'package:planetwork_app/io/Analysis.dart';

class SizedBoxGrid extends StatelessWidget {
  final Widget w;
  SizedBoxGrid(this.w);

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
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text(name),
      Padding(
        padding: EdgeInsets.all(16),
        child: SizedBoxGrid(
          Button(
            child: Text("Download Route Prof for " + name),
            onPressed: () {
              downloadFile("http://localhost:8080/download_rp/" + name);
            },
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(16),
        child: SizedBoxGrid(
          Button(
            child: Text("Download All data for " + name),
            onPressed: () {
              downloadFile("http://localhost:8080/download/" + name + ".zip");
            },
          ),
        ),
      ),
    ]);
  }
}
