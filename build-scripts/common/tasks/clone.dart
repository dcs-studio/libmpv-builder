import 'dart:io';

import '../models/library.dart';
import '../utils/extensions.dart';
import '../utils/logger.dart';
import 'exec.dart';

void clone({
  required Directory destination,
  required Library library,
  required Directory patchesDir,
}) {
  if ( destination.existsSync() ) {
    Logger.info("Clone [${library.name}] -> SKIPPED");
    return;
  }
  try {
    Logger.info("Clone [${library.name}] -> STARTING");
    destination.parent.mkdirs();
    exec(
      workingDir: destination.parent,
      args: ["git", "-c", "advice.detachedHead=false", "clone", "--depth", "1", "--branch", library.version, ...library.args, library.url, destination.name],
    );
    final libraryPatchesDir = patchesDir.resolveDir(library.name);
    if (libraryPatchesDir.existsSync()) {
      final patches = libraryPatchesDir
          .listSync()
          .whereType<File>()
          .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
      for (final patch in patches) {
        try {
          Logger.info("Patch [${library.name}, ${patch.name}] -> STARTING");
          exec(
            workingDir: destination,
            args: ["git", "apply", patch.absolutePath],
          );
          Logger.info("Patch [${library.name}, ${patch.name}] -> DONE");
        } catch (_) {
          Logger.error("Patch [${library.name}, ${patch.name}] -> FAILED");
          rethrow;
        }
      }
    }
    Logger.info("Clone [${library.name}] -> DONE");
  } catch (error) {
    Logger.error("Clone [${library.name}] -> FAILED");
    destination.deleteSync(recursive: true);
    rethrow;
  }
}
