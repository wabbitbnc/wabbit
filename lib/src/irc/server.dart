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

  bool get connected => _handler != null;

  Server(this.bouncer, this.uid, this.sid);

  /**
   * Returns false if already disconnected, otherwise true
   */
  bool disconnect() {
    if (!connected)
      return false;
    _handler.close();
    _handler = null;
    return true;
  }

  /**
   * Returns false if already connected, otherwise true
   */
  bool connect() {
    if (connected)
      return false;
    _handler = new Handler(this);
    _handler.listen();
    return true;
  }

  void messageClients(String msg) {
    for (var c in getClients())
      c.notify(msg);
  }

  void sendToClients(String line) {
    for (var c in getClients())
      c.send(line);
  }

  List<VerifiedClient> getClients() {
    var clients = bouncer.clients[uid];
    return clients != null ? clients : [];
  }
}
