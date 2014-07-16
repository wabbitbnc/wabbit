part of wabbit;

class ConfigBundle {

  final Config user_config;
  final Config network_config;
  final Config server_config;
  final Config plugins_config;

  ConfigBundle(this.user_config, this.network_config,
                this.server_config, this.plugins_config);

  void load() {
    user_config.load();
    network_config.load();
    server_config.load();
    plugins_config.load();
  }

  void save() {
    user_config.save();
    network_config.save();
    server_config.save();
    plugins_config.save();
  }
}

class Config {

  File _file;
  var config = new Map<dynamic, dynamic>();

  Config(String path, {String suffix : "config"}) {
    var sep = Platform.pathSeparator;
    var abs = Directory.current.absolute.path + sep + suffix;
    var configDir = new Directory(abs);
    if (!configDir.existsSync())
      configDir.createSync();
    _file = new File(abs + sep + path);
  }

  operator []=(dynamic arg, dynamic obj) => config[arg] = obj;
  dynamic operator [](dynamic arg) => config[arg];

  bool get exists => _file.existsSync();
  int get length => config.length;

  /**
   * Returns whether the file was loaded based on if the
   * file exists.
   */
  bool load() {
    if (exists)
      config = JSON.decode(_file.readAsStringSync()); ;
    return exists;
  }

  void save() {
    if (!exists)
      _file.createSync();
    var enc = new JsonEncoder.withIndent("  ");
    _file.writeAsStringSync(enc.convert(config));
  }

}

class ConfigGenerator {

  final ConfigBundle config;

  ConfigGenerator(this.config);

  bool get needsGeneration => !(config.user_config.exists
                              && config.network_config.exists
                              && config.server_config.exists
                              && config.plugins_config.exists);

  void configure() {
    print("Setup user details for logging in");
    config.user_config
    ..['0'] = new Map<String, String>()
    ..['0']['username'] = _ask("Enter username: ")
    ..['0']['password'] = _ask("Enter password: ");

    print("");
    print("Setup your first network");
    config.network_config
    ..['0'] = <String, dynamic>{} // Networks under user ID 0
    ..['0']['0'] = <String, dynamic>{} // Represents network ID
    ..['0']['0']['name'] = _ask("Enter network name: ")
    ..['0']['0']['address'] = _ask("Enter network address: ")
    ..['0']['0']['port'] = _ask("Enter network port [6667]: ", 6667)
    ..['0']['0']['username'] = _ask("Enter network username: ")
    ..['0']['0']['nickname'] = _ask("Enter network nickname: ")
    ..['0']['0']['realname'] = _ask("Enter network realname: ");

    print("");
    print("Setup server configuration");
    config.server_config
    ..['bind_address'] = _ask("Enter bind address [any]: ", "any")
    ..['port'] = _ask("Enter listening port [6667]: ", 6667);

    config.plugins_config
    ..['global'] = []
    ..['user'] = new Map<String, List<String>>()
    ..['user']['0'] = [];
  }

  dynamic _ask(String question, [dynamic def]) {
    var encoding = Encoding.getByName("UTF-8");
    String data = "";
    while (data.isEmpty) {
        stdout.write(question);
        data = stdin.readLineSync(encoding: encoding).trim();

        if (def != null && data.isEmpty) {
          return def;
        }

        // Check if input must be an integer
        if (def is int) {
          try {
            return int.parse(data);
          } catch (e) {
            data = "";
          }
        }
    }
    return data;
  }
}
