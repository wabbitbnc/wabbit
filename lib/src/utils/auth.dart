part of dartboard;

class Auth {

  final Bouncer bouncer;

  Auth(this.bouncer);

  int getId(String user, String pass) {
    for (var i in bouncer.user_config.config.keys) {
      var conf = bouncer.user_config.config[i];
      if ((conf['username'] == user) && (conf['password'] == pass))
        return int.parse(i);
    }
    return -1;
  }

  void authenticated(VerifiedClient client) {
    List<VerifiedClient> clients = bouncer.clients[client.uid];
    if (clients == null) {
      clients = <VerifiedClient>[];
      bouncer.clients[client.uid] = clients;
    }
    clients.add(client);
  }

  Server getNetwork(int uid, String name) {
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
