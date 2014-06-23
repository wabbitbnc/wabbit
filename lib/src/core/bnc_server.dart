library dartboard._core.bnc_server;

import "dart:io";
import "dart:async";

import "package:dartboard/dartboard.dart";

_invalid_password(BncConnection connection, String user) {
  connection.write("NOTICE :You supplied an incorrect password for the user " + user + "! Connection refused!");
  print("Client at address " + connection.socket.remoteAddress.address + " was rejected, due to an invalid username or password.");
  connection.close();
}

_handle_connection(BncConnection connection, String message) {
   print(message);
   if(!connection.authenticated && message.startsWith("USER"))
     connection.write("NOTICE :You need to supply a password! Try '/PASS username:password'.");
   else
     bnc_dispatcher.post(new MessageEvent(connection, message));
}

_on_authenticated_connection(BncConnection connection) {
  bnc_dispatcher.post(new ConnectionAuthEvent(connection));
  
  irc_client_dispatcher.register((MessageEvent event) {
    if(connection.user == event.connection.user) {
      if(!event.message.startsWith("PING"))
        connection.write(event.message);
    }
  });
  
  bnc_dispatcher.register((ConnectionAccessEvent event) {
    if(event.address != null && event.address != connection.socket.address.address)
      return;
    if(connection.user == event.user) {
      event.callback(connection);
    }
  });
  
  irc_client_dispatcher.post(new ConnectionAccessEvent(connection.user, (Connection client) {
    client.write("MOTD");
  }));
}

bool _handle_pass(BncConnection connection, String pass) {
  String user = pass.split(":")[0];
  String user_pass = pass.split(":")[1];

  if(Settings.users.containsKey(user) && pass.contains(":") && pass.split(":").length == 2) {
    if(Settings.users[user].password == user_pass) {
      return true;
    }
  }
  
  _invalid_password(connection, user);
  return false;
}

server_start() {
  ServerSocket.bind(new InternetAddress("127.0.0.1"), Settings.server_port).then((ServerSocket socket) {
    print("Successfully started server on port " + Settings.server_port.toString());
    socket.listen((Socket client) {
      BncConnection connection = new BncConnection(client, null);
      
      print("Client at address " + connection.socket.remoteAddress.address + " is attempting to connect.");
      client.timeout(new Duration(seconds: 30), onTimeout: (EventSink sink) {
        connection.write("PING :" + Settings.server_addr);
        
        bool pong = false;
        connection.listen((String message) {
          if(message.startsWith("PONG")) {
            pong = true;
          }
        });
        
        (new Future.delayed(new Duration(seconds: 10))).then((par) {
          if(!pong)
            connection.close();
        });
      });
      
      connection.listen((String message) {
        String cmd = message.split(" ")[0];
                
        if(cmd.startsWith("PASS") && !connection.authenticated) {
          String pass = message.split(" ")[1];
          if(_handle_pass(connection, pass)) {
            connection.user = Settings.users[pass.split(":")[0]];
            _on_authenticated_connection(connection);
          }
        } else
          _handle_connection(connection, message);
      });
    });
  });
}