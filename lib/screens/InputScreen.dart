import 'package:fluent_ui/fluent_ui.dart';

class InputScreen extends StatefulWidget {
  State createState() => new InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Text(
        "Input",
        style: TextStyle(fontSize: 60),
      ),
      content: Center(
        child: TextBox(
          controller: TextEditingController(),
          header: 'Name your analysis',
          placeholder: 'analysis name',
        ),
      ),
    );
  }
}
