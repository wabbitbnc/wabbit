import 'package:grinder/grinder.dart';
import 'dart:io';

void main([List<String> args]) {
  defineTask('build', taskFunction: build);
  defineTask('analyze', taskFunction: analyze);

  startGrinder(args);
}

void analyze(GrinderContext gc) {
  runSdkBinary(gc, "dartanalyzer", arguments: ["bin/start.dart"]);
  runSdkBinary(gc, "dartanalyzer", arguments: ["lib/wabbit.dart"]);
}

void build(GrinderContext gc) {
  var dir = new Directory("build");
  if (!dir.existsSync())
    dir.createSync();
  List<String> args = ["--snapshot=build/wabbit.snapshot", "bin/start.dart"];
  runSdkBinary(gc, "dart", arguments: args);
}
