library dartboard._core.irc_client;

import "dart:async";
import "dart:io";
import "dart:convert";

import "package:dartboard/dartboard.dart";

_handle_client(Socket socket, User user) {
  socket.write("USER " + user.server.username + " 0 * :" + user.server.realname + "\r\n");
  socket.write("NICK " + user.server.nickname + "\r\n");

  socket.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((String message) {
    print(message);
    server_dispatcher.post(new RawMessageEvent(socket, user, message));
  });
  
  bouncer_dispatcher.register((RawMessageEvent event) {
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