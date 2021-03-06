import 'package:fluent_ui/fluent_ui.dart';
import 'package:planetwork_app/io/AnalysisIO.dart';
import 'package:planetwork_app/screens/Templates.dart';

class OutputScreen extends StatefulWidget {
  State createState() => new OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Text('    Available Results'),
      content: Center(
        child: FutureBuilder<List<String>>(
            future: fetchListResults(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.length == 0
                    ? Text('no results')
                    : Align(
                        child: ListView(children: [
                          for (var i = 0;
                              i <= snapshot.data!.length - 1;
                              i += 1)
                            ResultElement((snapshot.data![i]), refresh)
                        ]),
                      );
              } else {
                return ProgressRing();
              }
            }),
      ),
    );
  }
}
