part of dartboard;

EventDispatcher irc_client_dispatcher = new EventDispatcher();
EventDispatcher bnc_dispatcher = new EventDispatcher();

class MessageEvent {
  Connection connection;
  String message;

  MessageEvent(this.connection, this.message);
}

class ConnectionAccessEvent {
  User user;
  Function callback;
  String address = null;
  
  ConnectionAccessEvent(this.user, this.callback, {this.address});
}

class ConnectionEvent {
  Connection connection;
  
  ConnectionEvent(this.connection);
}

class ConnectionAuthEvent extends ConnectionEvent {
  ConnectionAuthEvent(Connection connection) : super(connection);
}