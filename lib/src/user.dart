part of dartboard;

class User {
  final Server server;
  final String password;
  
  User(this.server, this.password);
}

class Server {
  final String address;
  final int port;

  String nickname;
  String realname;
  String username;
  
  List<String> channels = new List<String>();
    
  Server(this.address, this.port, this.nickname, this.realname, this.username);
  
  updateChannels(BncConnection connection) {
    for(String channel in channels) {
      connection.write(":" + nickname + "JOIN " + channel);
      irc_client_dispatcher.post(new ConnectionAccessEvent(connection.user, (Connection client) {
        print("half.");
        client.write("NAMES " + channel);
        client.write("TOPIC " + channel);
      }));
    }
  }
  
}