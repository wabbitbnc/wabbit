part of wabbit;

class FutureGroup<E> {
  Completer _completer = new Completer();
  Set<Future<E>> _futures = new Set<Future<E>>();
    
  bool add(Future<E> future) => _futures.add(future);
  
  Future<E> wait({void callback(result)}) {
    Future.wait(_futures)
    .then((List<E> result) {
      if(callback != null)
        callback(result);
      _completer.complete(result);
    })
    ..catchError((err) => _completer.completeError(err));
    
    return _completer.future;
  }
}