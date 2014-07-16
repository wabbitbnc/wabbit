part of wabbit;

class WabbitPluginManager extends PluginManager {
  final Config conf;
  List<Plugin> plugins;
  
  WabbitPluginManager(this.conf) : super();
    
  @override
  void listen(String type, void callback(String plugin, Map<String, dynamic> data)) {
    this.listenAll((name, data) {
      if(data['type'] == type && conf['users'][data['data']['user']]['plugins'].contains(name)) {
        callback(name, data['data']); 
      }
    });
  }
  
  @override
  void sendAll(Map<String, dynamic> data, [int type = PluginManager.NORMAL]) {
    for(Plugin plugin in plugins) {
      if(conf['users'][data['data']['user']]['plugins'].contains(plugin.name)) {
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
