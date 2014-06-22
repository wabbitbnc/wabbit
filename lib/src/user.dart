part of dartboard;

class User {
  final Server server;
  final String password;
  
  bool identified = false;

  User(this.server, this.password);
}

class Server {
  final String address;
  final int port;

  String nickname;
  String realname;
  String username;
  
  Server(this.address, this.port, this.nickname, this.realname, this.username);
}