import 'dart:io';

import '../utils/extensions.dart';

void exec({
  required Directory workingDir,
  required List<String> args,
  Map<String, String> env = const {},
}) {
  final result = Process.runSync(
    args[0],
    args.sublist(1),
    workingDirectory: workingDir.absolutePath,
    environment: env,
    runInShell: false,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    throw ProcessException(
      args.first,
      args.sublist(1),
      result.stderr.toString(),
      result.exitCode,
    );
  }
}

ProcessResult execAndGet({
  required Directory workingDir,
  required List<String> args,
  Map<String, String> env = const {},
}) {
  return Process.runSync(
    args.first,
    args.sublist(1),
    workingDirectory: workingDir.absolutePath,
    environment: env,
  );
}
