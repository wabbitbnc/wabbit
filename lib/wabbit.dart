// A simple IRC bouncer written in Dart.
library wabbit;

import 'dart:convert';
import 'dart:collection';
import 'dart:async';
import 'dart:io';

import 'package:wabbit/src/plugins/api.dart';
import 'package:plugins/loader.dart';

part 'src/bouncer.dart';

part 'src/plugins/plugins.dart';

part 'src/utils/colors.dart';
part 'src/utils/config.dart';
part 'src/utils/error.dart';
part 'src/utils/auth.dart';
part 'src/utils/utils.dart';

part 'src/irc/handler.dart';
part 'src/irc/server.dart';
part 'src/irc/client.dart';
part 'src/irc/bot/hub.dart';
