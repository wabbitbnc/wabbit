// dartboard - A simple IRC bouncer written in Dart.
library dartboard;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

part 'src/bouncer.dart';

part 'src/utils/colors.dart';
part 'src/utils/config.dart';
part 'src/utils/error.dart';
part 'src/utils/auth.dart';

part 'src/irc/handler.dart';
part 'src/irc/server.dart';
part 'src/irc/client.dart';

part 'src/irc/bot/hub.dart';
