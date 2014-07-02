part of wabbit;

class Plugin {

  final String name;
  final Isolate isolate;
  final ReceivePort rp;
  final SendPort sp;

  Plugin(this.name, this.isolate, this.rp, this.sp);
}

class PluginManager {

  Map<String, Plugin> _plugins = new Map();

  bool add(Plugin p) {
    if (_plugins.containsKey(p.name))
      return false;
    _plugins[p.name] = p;
    return true;
  }

  bool loaded(String name) {
    return _plugins.containsKey(name);
  }
}

class PluginLoader {

  final PluginManager manager = new PluginManager();
  final Config conf;
  Directory _dir;

  PluginLoader(this.conf) {
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
      return new Future.sync(() { return []; });
    }

    List<String> globalPlugins = conf['global'];
    List<Future<Isolate>> futures = [];
    List<FileSystemEntity> plugins = _dir.listSync();
    plugins.forEach((FileSystemEntity entity) {
      if (entity is File || entity is Link)
        return;
      Directory d = entity.absolute;
      var sep = Platform.pathSeparator;

      var infoFile = new File(d.path + sep + "bin" + sep + "info.json");
      var info = JSON.decode(infoFile.readAsStringSync());

      if (info['name'] == null) {
        throw new Exception("Missing name field in ${infoFile.path}");
      } else if (!globalPlugins.contains(info['name'])) {
        print("Skipping found plugin '${info['name']}', but not configured to load");
        return;
      }

      ReceivePort port = new ReceivePort();

      var mainFile = new File(d.path + sep + "bin" + sep + "main.dart");
      Future<Isolate> fut = Isolate.spawnUri(new Uri.file(mainFile.path), [], port.sendPort);

      Completer completer = new Completer();
      fut.then((Isolate iso) {
        StreamSubscription ss;
        var time = new Timer(new Duration(seconds: 5), () {
          print("Plugin '${info['name']}' did not register as a plugin in time, skipping");
          if (ss != null)
            ss.cancel();
        });

        ss = port.listen((data) {
          if (data is SendPort) {
            time.cancel();
            time = null;

            manager.add(new Plugin(info['name'], iso, port, data));
            print("Plugin '${info['name']}' was loaded successfully");
            completer.complete();
          }
        });
      });
      futures.add(completer.future);
    });
    return Future.wait(futures);
  }

  Future _loadGit() {
    // TODO: handle git cloning and loading
    return new Future.sync(() {});
  }

}
