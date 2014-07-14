import 'package:plugins/loader.dart';
import 'package:wabbit/wabbit.dart';
import "package:args/args.dart";

import "dart:io";

main(List<String> args) {
  var parser = new ArgParser()
  ..addOption("working-dir", abbr: "d", help: "The working directory to run")
  ..addFlag("help", abbr: "h", help: "Displays this help menu");

  var parsed = parser.parse(args);

  if (parsed['help']) {
    print(parser.getUsage());
    return;
  }

  if(parsed["working-dir"] != null)
    Directory.current = new Directory(parsed["working-dir"]);

  var user_config = new Config("users.json");
  var network_config = new Config("networks.json");
  var server_config = new Config("server.json");
  var plugins_config = new Config("plugins.json");

  var gen = new ConfigGenerator(user_config, network_config,
                                server_config, plugins_config);
  if (gen.needsGeneration) {
    gen.configure();
    gen.save();
  } else {
    user_config.load();
    network_config.load();
    server_config.load();
    plugins_config.load();
  }

  var loader = new Plugins(plugins_config);
  loader.load().then((List<List<Plugin>> _pl) {
    {
      List<Plugin> plugins = new List();
      plugins.addAll(_pl[0]);
      plugins.addAll(_pl[1]);
      print("Registered plugins: ${plugins.join(", ")}");
    }
    Bouncer server = new Bouncer(user_config, network_config, server_config);
    server.connect();
    server.start();
  });
}
