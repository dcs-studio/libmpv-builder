import '../common.dart';

void configure({
  required BuildContext context,
  required Map<String, String> environment,
  required List<String> arguments,
}) {
  final configureFile = context.sourcesDir.resolveFile("configure");
  final bootstrapFile = context.sourcesDir.resolveFile("bootstrap");
  if (!configureFile.existsSync() && bootstrapFile.existsSync()) {
    bootstrap(context, bootstrapFile);
  }
  if ( !configureFile.existsSync() ) {
    throw "No build system found for dependency: [${context.library.name}]";
  }
  try {
    Logger.error("Configure [${context.logLabel}]");
    exec(
      workingDir: context.intermediatesDir,
      args: [configureFile.absolutePath, "--prefix=${context.prefixDir.absolutePath}", ...arguments],
      env: environment,
    );
    Logger.error("Configure [${context.logLabel}] -> DONE");
  } catch (_) {
    Logger.error("Configure [${context.logLabel}] -> FAILED");
    rethrow;
  }
}

void bootstrap(BuildContext context, File file) {
  try {
    Logger.error("Bootstrap [${context.logLabel}]");
    exec(
      workingDir: context.sourcesDir,
      args: [file.absolutePath],
    );
    Logger.error("Bootstrap [${context.logLabel}] -> DONE");
  } catch (_) {
    Logger.error("Bootstrap [${context.logLabel}] -> FAILED");
    rethrow;
  }
}
