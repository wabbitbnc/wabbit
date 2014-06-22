import "../lib/src/core/network.dart";

import "dart:io";

_print_help() {
  printToConsole("Incorrect usage!\ndartboard {config_path}");
  exit(0);
}

main(List<String> args) {
  if(args.length > 1)
    _print_help();

  String path = "dartboard.ini";
  if(args.length == 1)
    path = args[0];

  Network network = new Network(path);
  network.serve();
}