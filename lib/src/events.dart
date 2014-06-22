part of dartboard;

EventDispatcher server_dispatcher = new EventDispatcher();
EventDispatcher bouncer_dispatcher = new EventDispatcher();

class RawMessageEvent {
  Socket socket;
  User user;
  String message;

  RawMessageEvent(this.socket, this.user, this.message);
}