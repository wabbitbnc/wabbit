import 'dart:isolate';

void main(_, SendPort port) {
  port.send(new ReceivePort().sendPort);
}
