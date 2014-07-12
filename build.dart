import 'package:grinder/grinder.dart';
import 'dart:io';

void main([List<String> args]) {
  defineTask('build', taskFunction: build);

  startGrinder(args);
}

void build(GrinderContext gc) {
  var dir = new Directory("build");
  if (!dir.existsSync())
    dir.createSync();
  List<String> args = ["--snapshot=build/wabbit.snapshot", "bin/start.dart"];
  runSdkBinary(gc, "dart", arguments: args);
}
