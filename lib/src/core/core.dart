library dartboard._core;

import "dart:async";
import "dart:io";

import "package:dartboard/dartboard.dart";
import "package:yaml/yaml.dart";

import "./bnc_server.dart";
import "./irc_client.dart";

class Core {

  Core(String configLocation) {
    File file = new File(configLocation);
    if(!file.existsSync())
      file.createSync();

    var conf = loadYaml(file.readAsStringSync());

    if(conf["server"] != null && conf["server"]["port"] != null) Settings.server_port = conf["server"]["port"];

    if(conf["users"] != null) {
      Map users = conf["users"];
      for(String section in users.keys) {
        Settings.users[section] = new User(new Server(conf["users"][section]["server"]["address"],
                                                        conf["users"][section]["server"]["port"],
                                                        conf["users"][section]["server"]["nickname"],
                                                        conf["users"][section]["server"]["realname"],
                                                        conf["users"][section]["server"]["username"]),
                                                        conf["users"][section]["password"]);
      }
    }
    
    irc_client_dispatcher.register((RawMessageEvent event) {
      if(event.message.trim().startsWith("PING")) {
        event.socket.write("PONG " + event.message.substring(5) + "\r\n");
      }
    });

    client_start();
    server_start();
  }

}
