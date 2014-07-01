part of dartboard;
  
class Plugin {
  final String name;
  final String directoryName;
  final String info;
  
  final String version;
  final String author;
  
  String mainFile;
  
  Plugin(this.name, this.directoryName, this.info, {this.version, this.author, this.mainFile : 'bin/start.dart'});
}
 
class Prefix {
  final String prefix;
  final Function getPath;
  final Function create;
  
  Prefix(this.prefix, String this.getPath(String), Future this.create(Prefix, String));
}
 
class PluginLoader {
  Map<String, Prefix> _prefixes = new HashMap<String, Prefix>(); 
  Config _config;
  
  PluginLoader(this._config);
    
  deletePlugin(String pluginName) {
    List<String> config = _config["plugins"];
    config.remove(pluginName);
    _config["plugins"] = config;
  }
   
  Plugin getPluginForPath(String path) {
    Config conf = new Config(path + '/bullseye.json', suffix: "plugins");
    if(!conf.exists)
      throw "Invalid plugin structure.";
    conf.load();
      
    Plugin plugin = new Plugin(conf['name'], conf['directoryName'], conf['info'], version: conf['version'], author: conf['author']);
    if(conf['mainFile'] != null) plugin.mainFile = conf['mainFile'];
    return plugin;
  }
   
  Future initPlugin(Plugin plugin) {
    return new Future((){});
  }
  
  addProtocol(Prefix prefix) {
    _prefixes[prefix.prefix] = prefix;
  }
  
  Prefix getPrefix(String pluginName) {
    return _prefixes[pluginName.split(':')[0]];
  }
  
  Future initPlugins() {
    List<String> plugins = _config["plugins"];
    var group = new FutureGroup();
    
    for(String pluginName in plugins) {
      var completer = new Completer();
      group.add(completer.future);
      
      Future future = () {
        if(!pluginName.contains(':'))
          return null;
        
        var prefix = this.getPrefix(pluginName);
         
        if(prefix != null) {
          if(new File(Directory.current.absolute.path + '/plugins/' + prefix.getPath(pluginName)).existsSync())
            return null;
          
          // Just in case we add something like HTTP, where you use : after you declare the protocol. Like Github branches, etc.
          Future future = _prefixes[prefix].create(prefix, pluginName.split(':').sublist(1).join(':'));
          return future;  
        }
      }();
      
      if(future != null) {
        future.then((resultA) {
          Plugin plugin = getPluginForPath(pluginName);
          initPlugin(plugin).then((resultB) => completer.complete(resultB));
        })
        ..catchError((Error err) {
          print('Plugin ' + pluginName + ' failed to load. Removing from the configuration file.');
          print(Error.safeToString(err));
          deletePlugin(pluginName);
        });
      }
    }
      
    return group.wait(callback: (resultC) {
      _config.save();
    });
  }
}