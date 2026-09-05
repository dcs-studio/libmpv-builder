
import '../common.dart';

final class Logger {

  Logger._();

  static var enabled = true;

  static void info(String message) {
    if (!Logger.enabled) return;
    stdout.writeln(message);
  }

  static void error(String message) {
    stderr.writeln(message);
  }

}