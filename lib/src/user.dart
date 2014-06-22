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

  Server(this.address, this.port, this.nickname, this.realname);
}