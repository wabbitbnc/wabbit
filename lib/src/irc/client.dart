part of wabbit;

class Client {

  final Bouncer bouncer;
  final Socket socket;

  StreamSubscription<List<int>> _ss;

  /**
   * Check whether the client is authenticated
   */
  bool get authenticated => this is VerifiedClient;

  Timer _time;

  Client(this.bouncer, this.socket);

  /**
   * Sends [line] to [Client]
   */
  void send(String line) {
    socket.write(line + "\r\n");
  }

  void handle() {
    runZoned(() {
      _ss = socket.listen(null);
      _initCleanup();

      _ss.onData((List<int> incoming) {
        List<String> data = Bouncer.splitter.convert(Bouncer.decoder.convert(incoming));
        data.forEach((String msg) {
          List<String> matches = Handler.get_matches(msg);
          String command = matches[2];
          if (command != "PASS")
            return;

          var index = matches[3].indexOf(":");
          if ((index == -1) || (index + 1 >= matches[3].length))
            return; // no password provided

          var pass = matches[3].substring(index + 1, matches[3].length);
          var info = matches[3].substring(0, index);

          var auth = new Auth(bouncer);
          index = info.indexOf("/");
          var uid;
          {
            if (index != -1)
              uid = auth.getId(info.substring(0, index), pass);
            else
              uid = auth.getId(info, pass);
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
            var server = auth.getNetwork(uid, network);
            if (server == null) {
              _sendAvailableNetworks(uid);
              return;
            }

            _time.cancel();
            send("NOTICE * :Successfully logged in");

            var client = new VerifiedClient(uid, server, _ss, bouncer, socket);
            auth.authenticated(client);

            if (client.server.connected) {
              client.server.handler.sendServerIntro(client);
              client.server.handler.send("MOTD");
            }
            client.handle();
          }
        });
      });
    }, onError: (err, stacktrace) {
      printError("Client listener (Unauthenticated)", "$err $stacktrace");
      _cleanup();
    });

    _time = new Timer(new Duration(seconds: 15), () {
      socket.destroy();
      _time = null;
    });
  }

  void _sendAvailableNetworks(int uid) {
    send("NOTICE * :Available networks available are:");
    for (var net in bouncer.network_config[uid.toString()].values) {
      send("NOTICE * :${net['name']}");
    }
  }

  void _initCleanup() {
    _ss.onError((err) {
      _cleanup();
    });

    _ss.onDone(() {
      _cleanup();
    });
  }

  void _cleanup() {
    print("Cleaning up disconnected client...");
    _ss.cancel();
    socket.destroy();
  }
}

class VerifiedClient extends Client {

  final int uid;

  final Server server;

  Hub _hub;
  HubNotifications _notifications;

  VerifiedClient(this.uid, this.server, _ss, b, s) : super(b, s) {
    this._ss = _ss;
    _hub = new Hub(this);
    _notifications = new HubNotifications(this);
  }

  void notify(String msg) {
    _notifications.message(msg);
  }

  void sendToServer(String line) {
    if (server.connected)
      server.handler.send(line + "\r\n");
  }

  @override
  void handle() {
    runZoned(() {
      _initCleanup();
      _ss.onData((List<int> incoming) {
        List<String> data = Bouncer.splitter.convert(Bouncer.decoder.convert(incoming));
        data.forEach((String msg) {
          List<String> matches = Handler.get_matches(msg);
          String command = matches[2];

          switch (command) {
            case "USER":
            case "NICK":
              break;
            case "QUIT":
              _cleanup();
              break;
            case "PRIVMSG":
              if (matches[3] != _hub.nickname)
                continue def;
              var info = matches[4].split(" ");
              List<String> args = new List<String>(info.length - 1);
              for (int i = 1; i < info.length; i++)
                args[i - 1] = info[i];
              _hub.handleCommand(info[0], args);
              break;
            def: default:
              sendToServer(msg);
          }
        });
     });
    }, onError: (err) {
      printError("Client listener (Authenticated)", err,
                [
                  "Server ID: ${server.sid}",
                  "Client ID: ${uid}"
                ]);
      _cleanup();
    });
  }

  dynamic getUserConf(String conf) {
    return bouncer.user_config[uid.toString()][conf];
  }

  @override
  void _cleanup() {
    super._cleanup();
    server.getClients().remove(this);
    print("Remaining clients connected: ${server.getClients().length}");
  }
}
