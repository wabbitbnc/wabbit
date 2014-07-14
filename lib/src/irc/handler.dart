part of wabbit;

class Handler {

  /**
   * Regex for parsing IRC messages
   */
  static final REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  final Server server;

  Socket _socket;
  Socket get socket => _socket;

  String networkName;
  bool _received = false;
  List<String> intro = [];

  Handler(this.server);

  /**
   * Once closed, destroy this instance
   */
  void close() {
    _socket.close();
  }

  void listen() {
    var conf = server.bouncer.network_config["${server.uid}"]["${server.sid}"];
    runZoned(() {
      Socket.connect(conf['address'], conf['port']).then((Socket socket) {
        _socket = socket;
        _socket.transform(Bouncer.decoder).transform(Bouncer.splitter).listen((String msg) {
          if (!_received) {
            _received = true;
            send("NICK ${conf['nickname']}");
            send("USER ${conf['username']} 8 * :${conf['realname']}");
            networkName = conf['name'];
          }

          var matches = get_matches(msg);
          var command = matches[2];
          switch (command) {
            case "PING":
              send("PONG :${matches[4]}");
              break;
            case "001":
            case "002":
            case "005":
              intro.add(msg);
              break;
            default:
              server.sendToClients(msg);
          }
        }).onError((err) {
          server.messageClients("Disconnected!");
          server.disconnect();
        });
      });
    }, onError: (err) {
      printError("bouncer->server handler connection", err,
                [
                  "Server ID: ${server.sid}",
                  "Client ID: ${server.uid}",
                  "Connected clients: ${server.bouncer.clients[server.uid].length}"
                ]);
      server.messageClients("Disconnected!");
      server.disconnect();
    });
  }

  void send(String line) {
    socket.write(line + "\r\n");
  }

  /**
   * Method called by [Client] manually
   * upon authentication
   */
  void sendServerIntro(Client client) {
    for (String s in intro)
      client.send(s);
  }

  static List<String> get_matches(String line) {
    var match = new List<String>(5);
    var parsed = REGEX.firstMatch(line);
    for (int i = 0; i <= parsed.groupCount; i++)
      match[i] = parsed.group(i);
    return match;
  }
}
