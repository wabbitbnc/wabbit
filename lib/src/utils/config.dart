part of dartboard;

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

  final Config users_config;
  final Config networks_config;
  final Config server_config;
  final Config plugins_config;

  ConfigGenerator(this.users_config,
                  this.networks_config,
                  this.server_config,
                  this.plugins_config);

  bool get needsGeneration => !(users_config.exists
                              && networks_config.exists
                              && server_config.exists
                              && plugins_config.exists);

  void configure() {
    print("Setup user details for logging in");
    users_config['0'] = new Map<String, String>();
    users_config['0']['username'] = _ask("Enter username: ");
    users_config['0']['password'] = _ask("Enter password: ");

    print("");
    print("Setup your first network");
    networks_config['0'] = new Map<String, dynamic>(); // Networks under user ID 0
    networks_config['0']['0'] = new Map<String, dynamic>(); // Represents network ID
    networks_config['0']['0']['name'] = _ask("Enter network name: ");
    networks_config['0']['0']['address'] = (_ask("Enter network address: "));
    networks_config['0']['0']['port'] = _ask("Enter network port [6667]: ", 6667);
    networks_config['0']['0']['username'] = _ask("Enter network username: ");
    networks_config['0']['0']['nickname'] = _ask("Enter network nickname: ");
    networks_config['0']['0']['realname'] = _ask("Enter network realname: ");

    print("");
    print("Setup server configuration");
    server_config['bind_address'] = _ask("Enter bind address [any]: ", "any");
    server_config['port'] = _ask("Enter listening port [6667]: ", 6667);

    plugins_config['global'] = [];
    plugins_config['user'] = new Map<String, List<String>>();
    plugins_config['user']['0'] = [];
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

  void save() {
    users_config.save();
    networks_config.save();
    server_config.save();
    plugins_config.save();
  }
}
