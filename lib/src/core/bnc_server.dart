library dartboard._core.bnc_server;

import "dart:io";
import "dart:convert";

import "package:dartboard/dartboard.dart";

_invalid_password(Socket socket, String user) {
  socket.writeln("NOTICE :You supplied an incorrect password for the user " + user + "! Connection refused!\r\n");
  print("Client at address " + socket.remoteAddress.address + " was rejected, due to an invalid username or password.");
  socket.close();
}

_handle_connection(Socket socket, User user, String message) {
   print(message);
   if(user == null)
     socket.write("NOTICE :You need to supply a password! Try '/PASS username:password'.\r\n");
   else
     bnc_dispatcher.post(new RawMessageEvent(socket, user, message));
}

_on_verified_connection(Socket socket, User user) {
  irc_client_dispatcher.register((RawMessageEvent event) {
    if(user == event.user) {
      if(!event.message.startsWith("PING"))
        socket.write(event.message + "\r\n");
    }
  });
  
  bnc_dispatcher.register((SocketAccessEvent event) {
    if(event.address != null && event.address != socket.address.address)
      return;
    if(user == event.user) {
      event.callback(socket);
    }
  });
  
  irc_client_dispatcher.post(new SocketAccessEvent(user, (Socket sock) {
    sock.write("MOTD\r\n");
  }));
}

bool _handle_pass(Socket socket, String pass) {
  String user = pass.split(":")[0];
  String user_pass = pass.split(":")[1];

  if(Settings.users.containsKey(user) && pass.contains(":") && pass.split(":").length == 2) {
    if(Settings.users[user].password == user_pass) {
      return true;
    }
  }
  
  _invalid_password(socket, user);
  return false;
}

server_start() {
  ServerSocket.bind(new InternetAddress("127.0.0.1"), Settings.server_port).then((ServerSocket socket) {
    print("Successfully started server on port " + Settings.server_port.toString());
    socket.listen((Socket client) {
      print("Client at address " + client.remoteAddress.address + " is attempting to connect.");
      User user = null;

      client.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((String message) {
        String cmd = message.split(" ")[0];
        String pass = message.split(" ")[1];
                
        if(cmd.contains("PASS") && user == null) {
          if(_handle_pass(client, pass)) {
            user = Settings.users[pass.split(":")[0]];
            _on_verified_connection(client, user);
          }
        } else
          _handle_connection(client, user, message);
      });
    });
  });
}