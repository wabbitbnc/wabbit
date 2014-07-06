part of wabbit;

class Plugins {

  final PluginManager manager = new PluginManager();
  final Config conf;
  Directory _dir;

  Plugins(this.conf) {
    var sep = Platform.pathSeparator;
    var cur = Directory.current.absolute.path;
    _dir = new Directory(cur + sep + "plugins");
  }

  Future load() {
    List<Future> futures = new List(2);
    futures[0] = _loadDirectory();
    futures[1] = _loadGit();
    return Future.wait(futures);
  }

  Future _loadDirectory() {
    if (!_dir.existsSync()) {
      _dir.createSync();
      return new Future.sync(() => []);
    }
    return manager.loadAll(_dir);
  }

  Future _loadGit() {
    // TODO: handle git cloning and loading
    return new Future.sync(() => []);
  }

}
