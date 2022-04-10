import 'package:fluent_ui/fluent_ui.dart';

class SizedBoxGrid extends StatelessWidget {
  final Widget w;
  SizedBoxGrid(this.w);

  Widget build(BuildContext context) {
    return SizedBox(width: 150, height: 50, child: Center(child: this.w));
  }
}
