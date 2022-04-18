import 'package:fluent_ui/fluent_ui.dart';

import 'package:planetwork_app/io/AnalysisIO.dart';

class SizedBoxGrid extends StatelessWidget {
  final Widget w;
  SizedBoxGrid(this.w);

  Widget build(BuildContext context) {
    return SizedBox(width: 150, height: 50, child: Center(child: this.w));
  }
}

class ResultElement extends StatelessWidget {
  final String name;
  final Function refresh;
  ResultElement(this.name, this.refresh);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBoxGrid(
        Text(name),
      ),
      SizedBoxGrid(Padding(
        padding: EdgeInsets.all(4),
        child: Button(
          child: Text("Download Route"),
          onPressed: () {
            downloadRPFile(name);
          },
        ),
      )),
      SizedBoxGrid(
        Padding(
          padding: EdgeInsets.all(4),
          child: Button(
            child: Text("Download All data"),
            onPressed: () {
              downloadZIPResult(name);
            },
          ),
        ),
      ),
      SizedBoxGrid(
        Padding(
          padding: EdgeInsets.all(4),
          child: SizedBoxGrid(
            Button(
              child: Text("Delete"),
              onPressed: () async {
                await clearResults(name);
                refresh();
              },
            ),
          ),
        ),
      ),
    ]);
  }
}

Color customGrey = Color.fromARGB(255, 112, 112, 112);
