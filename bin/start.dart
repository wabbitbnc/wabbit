import 'package:dartboard/dartboard.dart';

import "dart:io";

import "package:args/args.dart";

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
<<<<<<< HEAD

=======
  var plugins_config = new Config("plugins.json");
  
>>>>>>> branch 'master' of git@github.com:DirectMyFile/dartboard.git
  var gen = new ConfigGenerator(user_config, network_config, server_config);
  if (gen.needsGeneration) {
    gen.configure();
    gen.save();
  } else {
    user_config.load();
    network_config.load();
    server_config.load();
    plugins_config.load();
  }
<<<<<<< HEAD

  Bouncer server = new Bouncer(user_config, network_config, server_config);
  server.connect();
  server.start();
=======
  
  var plugin_loader = new PluginLoader(plugins_config);
  plugin_loader.initPlugins().then((result) {
    Bouncer server = new Bouncer(user_config, network_config, server_config);
    server.connect();
    server.start();
  });
>>>>>>> branch 'master' of git@github.com:DirectMyFile/dartboard.git
}
