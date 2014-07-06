import 'dart:isolate';
import 'package:plugins/plugin.dart';

void main(_, SendPort port) {
  Receiver rec = new Receiver(port);
  rec.listen((Map<dynamic, dynamic> data) {

  });
}
