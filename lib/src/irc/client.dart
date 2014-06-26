part of dartboard;

class Client {

  final Bouncer bouncer;
  final Socket socket;

  /**
   * Check whether the client is authenticated
   */
  bool get authenticated => client != null;

  VerifiedClient client;
  Timer time;

  Client(this.bouncer, this.socket);

  /**
   * Sends [line] to [Client]
   */
  void send(String line) {
    socket.write(line + "\r\n");
  }

  /**
   * This method should only be invoked when authenticated.
   */
  void sendToServer(String line) {
    client.server.handler.send(line + "\r\n");
  }

  void authenticate() {
    if (authenticated)
      return;

    var future;
    runZoned(() {
      future = socket.transform(Bouncer.decoder).transform(Bouncer.splitter).listen((String msg) {
        if (!authenticated) {
          List<String> matches = Handler.get_matches(msg);
          String command = matches[2];
          if (command != "PASS")
            return;

          var index = matches[3].indexOf(":");
          if ((index == -1) || (index + 1 >= matches[3].length))
            return; // no password provided

          var pass = matches[3].substring(index + 1, matches[3].length);
          var info = matches[3].substring(0, index);

          index = info.indexOf("/");
          var uid;
          {
            if (index != -1)
              uid = _getAuthId(info.substring(0, index), pass);
            else
              uid = _getAuthId(info, pass);
          }

          if ((index == -1) || (index + 1 >= info.length)) {
            send("NOTICE * :No network provided in username");
            send("NOTICE * :Use /PASS <username>/<network>:<password>");
            if (uid > -1) {
              _sendAvailableNetworks(uid);
            }
            return;
          }

          if (uid > -1) {
            var network = info.substring(index + 1, info.length);
            var server = _getNetwork(uid, network);
            if (server == null) {
              _sendAvailableNetworks(uid);
              return;
            }

            send("NOTICE * :Successfully logged in");
            client = new VerifiedClient(uid, this, server);
            _authenticated(client);

            client.server.handler.sendServerIntro(this);
            client.server.handler.send("MOTD");
          } else {
            send("NOTICE * :Username or password incorrect");
          }
        } else {
          client.handle(msg);
        }
      });
    }, onError: ((err, stacktrace) {
      printError("Client listener (Authenticated: ${authenticated})", err);
      if (authenticated)
        bouncer.clients[client.uid].remove(this);
    }));

    time = new Timer(new Duration(seconds: 15), () {
      if (!authenticated) {
        socket.close();
        future.cancel();
      }
      time = null;
    });
  }

  void _authenticated(VerifiedClient client) {
    List<VerifiedClient> clients = bouncer.clients[client.uid];
    if (clients == null) {
      clients = <VerifiedClient>[];
      bouncer.clients[client.uid] = clients;
    }
    clients.add(client);
  }

  void _sendAvailableNetworks(int uid) {
    send("NOTICE * :Available networks available are:");
    for (var net in bouncer.network_config[uid.toString()].values) {
      send("NOTICE * :${net['name']}");
    }
  }

  int _getAuthId(String user, String pass) {
    for (var i in bouncer.user_config.config.keys) {
      var conf = bouncer.user_config.config[i];
      if ((conf['username'] == user) && (conf['password'] == pass))
        return int.parse(i);
    }
    return -1;
  }

  Server _getNetwork(int uid, String name) {
    var map = bouncer.network_config[uid.toString()];
    for (var ssid in map.keys) {
      var conf = bouncer.network_config[uid.toString()][ssid];
      if (conf['name'] == name) {
        var sid = int.parse(ssid);
        for (var server in bouncer.servers[uid]) {
          if (server.sid == sid)
            return server;
        }
      }
    }
    return null;
  }
}

class VerifiedClient {

  /**
   * The user ID
   * -1 means unauthenticated
   */
  final int uid;

  final Server server;
  final Client client;

  VerifiedClient(this.uid, this.client, this.server);

  void handle(String msg) {
    List<String> matches = Handler.get_matches(msg);
    String command = matches[2];

    switch (command) {
      case "USER":
      case "NICK":
        return;
      default:
        client.sendToServer(msg);
    }
  }
}
