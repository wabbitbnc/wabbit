import "dart:io";
import "dart:async";
import "dart:collection";

import "../../dartboard.dart";

import "package:ini/ini.dart";

class Network {

  final String _bnc_name = "dartboard";

  int _server_port = 6667;

  Map<String, User> _users = new HashMap<String, User>();

  Network(String configLocation) {
    Config conf = Config.readFileSync(new File(configLocation));
    if(conf.get("server", "port") != null) _server_port = int.parse(conf.get("serve", "port"));

    for(String section in conf.sections()) {
      if(section.startsWith("user-")) {
        _users[section.substring(5)] = new User(new Server(conf.get(section + "-server", "address"), int.parse(conf.get(section + "-server", "port")), conf.get(section + "-server", "nickname"), conf.get(section + "-server", "realname")), conf.get(section, "password"));
      }
    }
  }

  _invalid_password(Socket socket, String user) {
    socket.writeln(_bnc_name + ": You supplied an incorrect password for the user " + user + "! Connection refused!");
    socket.close();
  }

  _handle_connection(Socket socket, User user) {
    // TODO tomorrow.
  }

  _handle_pass(Socket socket, String pass) {
    String user = pass.split(":")[0];
    String user_pass = pass.split(":")[1];

    if(_users.containsKey(user)) {
      if(_users[user].password != user_pass) {
        _invalid_password(socket,user);
      }

      _handle_connection(socket, _users[user]);
    }
  }

  serve() {
    ServerSocket.bind(new InternetAddress("127.0.0.1"), _server_port).then((ServerSocket socket) {
      socket.listen((Socket client) {
        client.listen((List<int> data) {
          String message = String.fromCharCode(data);
          message = message.trim();

          String cmd = message.split(" ")[0];
          if(cmd.contains("PASS")) {
            _handle_pass(client, message.split(" ")[1]);
          }
        });
      });
    });
  }

}
