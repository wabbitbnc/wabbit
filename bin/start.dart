import 'package:dartboard/src/core/core.dart';

import "dart:io";

import "package:args/args.dart";

_print_help() {
  print("Incorrect usage!\ndartboard {config_path}\n");
  exit(0);
}

main(List<String> args) {
  var parser = new ArgParser()
  ..addOption("config", help: "The path to the YAML configuration file.");
  
  var parsed = parser.parse(args);

  String path = "dartboard.yaml";
  if(parsed["config"] != null)
    path = parsed["config"];

  Core core = new Core(path);
}