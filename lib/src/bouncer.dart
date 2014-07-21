part of wabbit;

class Bouncer {

  static final Utf8Decoder decoder = new Utf8Decoder(allowMalformed: true);
  static final LineSplitter splitter = new LineSplitter();

  final ConfigBundle config;

  final Map<int, List<Server>> servers = new Map<int, List<Server>>();
  final Map<int, List<VerifiedClient>> clients = new Map<int, List<VerifiedClient>>();

  var address;
  var port;

  /**
   * The [Config] must already be loaded.
   */
  Bouncer(this.config) {
    Plugins.manager.eventType(EventType.MESSAGE).listen((Map<String, dynamic> data) {
      if(data['side'] == EventSide.CLIENT) {
        for(VerifiedClient client in clients[data['uid']]) {
          if(client.server.sid == data['sid']) {
            client.send(data['msg']);
          }
        }
      } else if(data['side'] == EventSide.SERVER) {
        for(Server server in servers[data['uid']]) {
          if(server.sid == data['sid']) {
            server.handler.send(data['msg']);
          }
        }
      }
    });

    Plugins.manager.eventType(EventType.LEAVE).listen((Map<String, dynamic> data) {
      if(data['side'] == EventSide.CLIENT) {
        for(VerifiedClient client in clients[data['uid']]) {
          if(client.server.sid == data['sid']) {
            client.disconnect();
          }
        }
      } else if(data['side'] == EventSide.SERVER) {
        for(Server server in servers[data['uid']]) {
          if(server.sid == data['sid']) {
            server.disconnect();
          }
        }
      }
    });
  }

  /**
   * Initiates all connections to IRC
   */
  void connect() {
    config.network_config.config.forEach((uid, config) {
      runZoned(() {
        var id = int.parse(uid);
        config.forEach((sid, conf) {
          List<Server> serve = servers[id];
          if (serve == null) {
            serve = <Server>[];
            servers[id] = serve;
          }
          var server = new Server(this, id, int.parse(sid));
          serve.add(server);
          server.connect();
        });
      }, onError: (err, stacktrace) {
        printError("bouncer->server connection iterator", "$err $stacktrace");
      });
    });
  }

  /**
   * Starts accepting clients
   */
  void start() {
    var addr = config.server_config['bind_address'];
    var port = config.server_config['port'];
    var resolvedAddr = addr == "any" ? InternetAddress.ANY_IP_V4 : addr;
    runZoned(() {
      ServerSocket.bind(resolvedAddr, port).then((ServerSocket socket) {
        print("Listening to $addr on port $port");
        this.address = socket.address.host;
        this.port = port;
        socket.handleError((err) {
          printError("ServerSocket binding", err);
        }).listen((Socket sock) {
          // Client will be added to the clients list when authenticated
          new Client(this, sock)
            ..send("NOTICE * :Authentication required (/PASS <user>/<network>:<pass>)")
            ..handle();
        }).onError((err) {
          printError("client->server connection", err);
        });
      });
    }, onError: (err) {
      printError("ServerSocket listener", err);
    });
  }
}
