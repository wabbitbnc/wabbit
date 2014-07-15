part of wabbit;

class Handler {

  /**
   * Regex for parsing IRC messages
   */
  static final REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");
  static final HOSTMASK_REGEX = new RegExp(r"!~|!|@");

  final Server server;

  Socket _socket;
  Socket get socket => _socket;
  StreamSubscription _ss;

  String networkName;
  bool _softDisconnect = true;

  bool _received = false;
  List<String> intro = [];
  List<String> channels = [];

  Handler(this.server);

  void init(VerifiedClient client) {
    var conf = server.bouncer.network_config["${server.uid}"]["${server.sid}"];

    // Send intro
    for (String s in intro)
      client.send(s);

    // Send MOTD
    send("MOTD");

    // Send channels
    for (String s in channels) {
      client.send(":${conf['nickname']} JOIN $s");
      send("TOPIC $s");
      send("NAMES $s");
      send("WHO $s");
    }
  }

  void listen() {
    var conf = server.bouncer.network_config["${server.uid}"]["${server.sid}"];
    runZoned(() {
      Socket.connect(conf['address'], conf['port']).then((Socket socket) {
        _socket = socket;
        _ss = _socket.transform(Bouncer.decoder).transform(Bouncer.splitter).listen((String msg) {
          if (!_received) {
            _received = true;
            send("NICK ${conf['nickname']}");
            send("USER ${conf['username']} 8 * :${conf['realname']}");
            networkName = conf['name'];
          }

          var matches = getMatches(msg);
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
            case "KICK":
              var parsed = matches[3].split(" ");
              if (parsed[1] == conf['nickname'])
                channels.remove(parsed[0]);
              continue def;
            case "PART":
              var parsed = parseHostMask(matches[1]);
              if (parsed[0] == conf['nickname'])
                channels.remove(matches[3]);
              continue def;
            case "JOIN":
              var parsed = parseHostMask(matches[1]);
              if (parsed[0] == conf['nickname'])
                channels.add(matches[3]);
              continue def;
            def: default:
              server.sendToClients(msg);
          }
        });
        _ss.onDone(_cleanup);
        _ss.onError(_cleanup);
      });
    }, onError: (err) {
      printError("bouncer->server handler connection", err,
                [
                  "Server ID: ${server.sid}",
                  "Client ID: ${server.uid}",
                  "Connected clients: ${server.getClients().length}"
                ]);
      _cleanup();
    });
  }

  void send(String line) {
    socket.write(line + "\r\n");
  }

  /**
   * Once closed, destroy this instance.
   * Overrides [_cleanup] handlers on [_ss]. The override is to ensure the
   * client doesn't get messaged twice about a disconnection.
   */
  void close() {
    _ss.onError((err) {});
    _ss.onDone(() {});

    _socket.destroy();
  }

  void _cleanup([_]) {
    server.notifyClients("Disconnected!");
    server.disconnect();
  }

  static List<String> getMatches(String line) {
    var match = new List<String>(5);
    var parsed = REGEX.firstMatch(line);
    for (int i = 0; i <= parsed.groupCount; i++)
      match[i] = parsed.group(i);
    return match;
  }

  static List<String> parseHostMask(String hostmask) {
    return hostmask.split(HOSTMASK_REGEX);
  }
}
