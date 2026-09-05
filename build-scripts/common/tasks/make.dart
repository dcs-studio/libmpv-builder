import '../models/build_context.dart';
import '../utils/current_host.dart';
import '../utils/logger.dart';
import 'exec.dart';

void make(BuildContext context) {
  try {
    Logger.info("CMake [${context.logLabel}]");
    exec(
      workingDir: context.intermediatesDir,
      args: ["make", "-j${CurrentHost.cores}", "V=1"],
    );
    exec(
      workingDir: context.intermediatesDir,
      args: ["make", "-j${CurrentHost.cores}", "V=1", "install"],
    );
    Logger.info("CMake [${context.logLabel}] -> DONE");
  } catch (error) {
    Logger.error("CMake [${context.logLabel}] -> FAILED");
    rethrow;
  }
}
