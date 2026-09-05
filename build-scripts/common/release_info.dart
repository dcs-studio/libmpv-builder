import 'dart:io';

import 'utils/report.dart';

void main(List<String> args) {
  final command = args.isEmpty ? '' : args.first;
  switch (command) {
    case 'version':
      stdout.write(projectVersion());
    case 'table':
      stdout.write(librariesMarkdownTable());
    case 'notes':
      stdout.write(releaseNotesMarkdown());
    default:
      stderr.writeln('Usage: dart run release_info.dart <version|table|notes>');
      exit(64);
  }
}
