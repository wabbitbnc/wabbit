library dartboard._core.irc_client;

import "dart:async";
import "dart:io";

import "package:dartboard/dartboard.dart";

_handle_client(Connection connection) {
  connection.write("USER " + connection.user.server.username + " 8 * :" + connection.user.server.realname);
  connection.write("NICK " + connection.user.server.nickname);

  connection.listen((String message) {
    print(message);
    irc_client_dispatcher.post(new MessageEvent(connection, message));
  });
  
  irc_client_dispatcher.register((ConnectionAccessEvent client) {
    if(client.address != null && client.address != connection.socket.address.address)
      return;
    if(connection.user == client.user) {
      client.callback(connection);
    }
  });
  
  bnc_dispatcher.register((MessageEvent event) {
    if(connection.user == event.connection.user) {
      if(!event.message.startsWith("PASS") && !event.message.startsWith("USER") && !event.message.startsWith("QUIT"))
        connection.write(event.message);
    }
  });
  
}

bool _client_status = true;
_client_future() {
  while(_client_status) {}
}

client_start() {
  List<Future<Socket>> sockets = new List<Future<Socket>>();
  for(User user in Settings.users.values) {
     Socket.connect(user.server.address, user.server.port).then((Socket socket) {
       _handle_client(new Connection(socket, user));
     });
  }

}