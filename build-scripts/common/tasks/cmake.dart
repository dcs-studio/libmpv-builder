import '../models/build_context.dart';
import '../utils/extensions.dart';
import '../utils/logger.dart';
import 'exec.dart';

void cmake({
  required BuildContext context,
  required List<String> arguments,
}) {
  try {
    Logger.info("CMake [${context.logLabel}]");
    exec(
      workingDir: context.intermediatesDir,
      args: [
        "cmake", context.sourcesDir.absolutePath,
        "-DCMAKE_VERBOSE_MAKEFILE=0",
        "-DCMAKE_BUILD_TYPE=Release",
        ...context.defaultCmakeArgs,
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
        ...arguments,
      ],
    );
    Logger.info("CMake [${context.logLabel}] -> DONE");
  } catch (e) {
    Logger.error("CMake [${context.logLabel}] -> FAILED");
    rethrow;
  }
}
