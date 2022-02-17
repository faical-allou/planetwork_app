import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:planetwork_app/main.dart';

class OutputScreen extends StatefulWidget {
  State createState() => new OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Consumer<GlobalState>(
        builder: (context, status, child) {
          var status = context.read<GlobalState>();
          return Text(
            //status.analysisName,
            status.listFiles['sked']?.files.first.name ?? '',
            style: TextStyle(fontSize: 60),
          );
        },
      ),
      content: Center(
        child: Text("Welcome to output page!"),
      ),
    );
  }
}
