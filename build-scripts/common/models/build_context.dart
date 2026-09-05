import 'dart:io';

import 'library.dart';

abstract class BuildContext {

  abstract final Directory buildDirectory;
  abstract final Directory sourcesDir;
  abstract final Directory intermediatesDir;
  abstract final Directory prefixDir;
  abstract final Library library;
  abstract final File crossFile;

  abstract final List<String> defaultCmakeArgs;
  abstract final Map<String, String> configureTaskEnv;

  abstract final String logLabel;

}
