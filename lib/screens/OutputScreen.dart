import 'package:fluent_ui/fluent_ui.dart';

class OutputScreen extends StatefulWidget {
  State createState() => new OutputScreenState();
}

class OutputScreenState extends State<OutputScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Text(
        "Output",
        style: TextStyle(fontSize: 60),
      ),
      content: Center(
        child: Text("Welcome to output page!"),
      ),
    );
  }
}
