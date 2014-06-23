part of dartboard;

EventDispatcher irc_client_dispatcher = new EventDispatcher();
EventDispatcher bnc_dispatcher = new EventDispatcher();

class RawMessageEvent {
  Socket socket;
  User user;
  String message;

  RawMessageEvent(this.socket, this.user, this.message);
}

class SocketAccessEvent {
  User user;
  Function callback;
  String address = null;
  
  SocketAccessEvent(this.user, this.callback, {this.address});
}