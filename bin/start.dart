import '../lib/src/core/core.dart';

import "dart:io";

_print_help() {
  print("Incorrect usage!\ndartboard {config_path}\n");
  exit(0);
}

main(List<String> args) {
  if(args.length > 1)
    _print_help();

  String path = "dartboard.ini";
  if(args.length == 1)
    path = args[0];

  Core core = new Core(path);
  core.serve();
}