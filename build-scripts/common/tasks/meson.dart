import '../models/build_context.dart';
import '../models/crossfile.dart';
import '../utils/extensions.dart';
import '../utils/logger.dart';
import 'exec.dart';

void meson({
  required BuildContext context,
  required Crossfile crossfile,
  required List<String> arguments,
}) {
  try {
    Logger.info("CMake [${context.logLabel}]");
    crossfile.writeTo(context.crossFile);
    exec(
      workingDir: context.sourcesDir,
      args: ["meson", "setup", context.intermediatesDir.absolutePath, "--cross-file", context.crossFile.absolutePath, ...arguments],
    );
    exec(
      workingDir: context.intermediatesDir,
      args: ["meson", "compile", "--clean"],
    );
    exec(
      workingDir: context.intermediatesDir,
      args: ["meson", "compile", "--verbose"],
    );
    exec(
      workingDir: context.intermediatesDir,
      args: ["meson", "install"],
    );
    Logger.info("CMake [${context.logLabel}] -> DONE");
  } catch (error) {
    Logger.error("CMake [${context.logLabel}] -> FAILED");
    rethrow;
  }
}
