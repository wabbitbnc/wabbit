// dartboard - A simple IRC bouncer written in Dart.
library dartboard;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:quiver/pattern.dart' show escapeRegex;

part 'src/utils/colors.dart';
part 'src/utils/config.dart';
part 'src/utils/error.dart';
part 'src/irc/handler.dart';
part 'src/irc/server.dart';
part 'src/irc/client.dart';
part 'src/bouncer.dart';
