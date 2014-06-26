part of dartboard;

/**
 * Handles Bouncer -> IRC server connections.
 */
class Server {

  /**
   * The user ID this connection is related to
   */
  final int uid;

  /**
   * The server ID this connection is related to
   */
  final int sid;

  /**
   * Bouncer object needed to communicate with the configuration
   */
  final Bouncer bouncer;

  /**
   * For handling messages as they get received
   */
  Handler _handler;
  Handler get handler => _handler;

  /**
   * Must be provided with a server socket
   */
  Server(this.bouncer, this.uid, this.sid, Socket socket) {
    _handler = new Handler(this, socket);
  }

  void listen() {
    _handler.listen();
  }

  void messageClients(String msg) {
      var conf = bouncer.network_config["${uid}"]["${sid}"];
      msg = ":*status!bnc@dartboard PRIVMSG ${conf['nickname']} :$msg";
      sendToClients(msg);
    }

  void sendToClients(String line) {
    List<VerifiedClient> cs = bouncer.clients[uid];
    if (cs == null)
      return;
    for (var c in cs) {
      c.client.send(line);
    }
  }
}
