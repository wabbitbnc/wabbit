part of wabbit;

class WabbitPluginManager extends PluginManager {
  final Config conf;
  List<Plugin> plugins;
  Map<int, StreamController> type_listeners;

  WabbitPluginManager(this.conf) : super() {
    type_listeners = new HashMap<int, StreamController>();
  }

  Stream<Map<dynamic, dynamic>> eventType(int type) {
    var controller = new StreamController<Map<dynamic, dynamic>>();
    type_listeners[type] = controller;
    return controller.stream;
  }

  void init(List<Plugin> plugins) {
    this.plugins = plugins;
    this.listenAll((String plugin, data) {
      List<String> plugin_names = conf['user'][data['uid'].toString()];
      if(!type_listeners.containsKey(data['type']) || !plugin_names.contains(plugin))
        return;

      type_listeners[data['type']].add(data);
    });
  }

  @override
  void sendAll(Map<String, dynamic> data, [int type = PluginManager.NORMAL]) {
    for(Plugin plugin in plugins) {
      List<String> plugin_names = conf['user'][data['uid'].toString()];
      if(plugin_names.contains(plugin.name)) {
        this.send(plugin.name, data, type);
      }
    }
  }
  
}

class Plugins {

  static WabbitPluginManager manager;

  Directory _dir;

  Plugins(Config conf) {
    manager = new WabbitPluginManager(conf);
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
