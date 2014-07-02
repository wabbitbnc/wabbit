part of wabbit;

class Bouncer {

  static final Utf8Decoder decoder = new Utf8Decoder(allowMalformed: true);
  static final LineSplitter splitter = new LineSplitter();

  final Config user_config;
  final Config network_config;
  final Config server_config;

  final Map<int, List<Server>> servers = new Map<int, List<Server>>();
  final Map<int, List<VerifiedClient>> clients = new Map<int, List<VerifiedClient>>();

  var address;
  var port;

  /**
   * The [Config] objects must already be loaded in.
   */
  Bouncer(this.user_config, this.network_config, this.server_config);

  /**
   * Initiates all connections to IRC
   */
  void connect() {
    network_config.config.forEach((uid, config) {
      var id = int.parse(uid);
      runZoned(() {
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
    var addr = server_config['bind_address'];
    var port = server_config['port'];
    addr = addr == "any" ? InternetAddress.ANY_IP_V4 : addr;
    ServerSocket.bind(addr, port).then((ServerSocket socket) {
      print("Listening to ${server_config['bind_address']} on port $port");
      this.address = socket.address.host;
      this.port = port;
      socket.handleError((err) {
        printError("ServerSocket binding", err);
      }).listen((Socket sock) {
        // Client will be added to the clients list when authenticated
        Client c = new Client(this, sock);
        c.send("NOTICE * :Authentication required (/PASS <user>/<network>:<pass>)");
        c.handle();
      }).onError((err) {
        printError("client->server connection", err);
      });
    });
  }


}