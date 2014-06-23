part of dartboard;

String _formatting = "\r\n";

class Connection {
  Socket socket;
  User user;
  
  bool closed = false;
  
  Connection(this.socket, this.user) {
    socket.done.then((val) {
      closed = true;
    });
  }
  
  write(String message) {
    socket.write(message + _formatting);
  }
  
  listen(void method(String)) {
    socket.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((String message) {
      method(message);
    });
  }
  
  close() {
    if(closed)
      return;
    
    socket.close();
    closed = true;
  }
}

class BncConnection extends Connection {
  bool authenticated = false;
  
  BncConnection(Socket socket, User user) : super(socket, user);
}