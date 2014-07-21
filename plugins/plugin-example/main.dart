import 'dart:isolate';
import 'dart:async';
import 'package:plugins/plugin.dart';

void main(_, SendPort port) {
  Receiver rec = new Receiver(port);
  rec.listen((Map<dynamic, dynamic> data) {
    if(data['type'] == 0 && data['side'] == 0) {
      print(data['msg']);
    }
    if(data['type'] == 1 && data['side'] == 0) {
      new Future.delayed(new Duration(seconds: 10)).then((val) {
        print("POW");
        rec.send({
          'type': 0,
          'uid': data['uid'],
          'sid': data['sid'],
          'msg': "JOIN #directcode",
          'side': 0
        });
      });
    }
  });
}
