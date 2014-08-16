part of wabbit;

class Hub {

  static const String prefix = "*";

  final VerifiedClient client;
  String _nick = "hub";

  String get nickname => prefix + _nick;

  Hub(this.client);

  void message(String msg) {
    client.send(":${prefix}${_nick}!bnc@wabbit.bnc PRIVMSG ${client.getUserConf('nickname')} :$msg");
  }

  void handleCommand(String command, List<String> args) {
    switch (command) {
      case "connect":
        if (client.server.connect())
          message("Connecting to server");
        else
          message("Already connected");
        break;
      case "disconnect":
        if (client.server.disconnect())
          message("Disconnected from server");
        else
          message("Already disconnected");
        break;
      default:
        message("$command does not exist");
        break;
    }
  }
}

class HubNotifications extends Hub {

  HubNotifications(VerifiedClient client) : super(client) {
    _nick = "notifications";
  }

  @override
  void message(String msg) {
    super.message(msg);
  }

  @override
  void handleCommand(String command, List<String> args) {
    // Do nothing
  }
}
