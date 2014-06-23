library dartboard._core.irc_client;

import "dart:async";
import "dart:io";
import "dart:convert";

import "package:dartboard/dartboard.dart";

_handle_client(Socket socket, User user) {
  socket.write("USER " + user.server.username + " 8 * :" + user.server.realname + "\r\n");
  socket.write("NICK " + user.server.nickname + "\r\n");

  socket.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((String message) {
    print(message);
    irc_client_dispatcher.post(new RawMessageEvent(socket, user, message));
  });
  
  irc_client_dispatcher.register((SocketAccessEvent event) {
    if(user == event.user) {
      event.callback(socket);
    }
  });
  
  bnc_dispatcher.register((RawMessageEvent event) {
    if(event.address != null && event.address != socket.address.address)
      return;
    if(user == event.user) {
      if(!event.message.startsWith("PASS") && !event.message.startsWith("USER") && !event.message.startsWith("QUIT"))
        socket.write(event.message + "\r\n");
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
       _handle_client(socket, user);
     });
  }

}