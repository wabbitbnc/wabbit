part of dartboard;

class User {
  String password;
  Server server;

  User(Server serv, String pass) {
    this.password = pass;
    this.server = serv;
  }
}

class Server {
  String address;
  int port;

  String nickname;
  String realname;

  Server(String addr, int serv_port, String nick, String real) {
    this.address = addr;
    this.port = serv_port;

    this.nickname = nick;
    this.realname = real;
  }
}