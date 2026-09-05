import '../models/library.dart';
import '../models/versions.dart';

String projectVersion() => Versions.PROJECT;

String librariesMarkdownTable() {
  final buffer = StringBuffer();
  buffer.writeln('| Library | Version | Repository |');
  buffer.writeln('| :--- | :--- | :--- |');
  for (final lib in Library.values) {
    final repo = _prettyRepo(lib.url);
    buffer.writeln('| ${lib.name} | `${lib.version}` | [${_repoLabel(repo)}]($repo) |');
  }
  return buffer.toString();
}

String releaseNotesMarkdown() {
  final buffer = StringBuffer();
  buffer.writeln('# libmpv ${Versions.PROJECT}');
  buffer.writeln();
  buffer.writeln('## Bundled libraries');
  buffer.writeln();
  buffer.write(librariesMarkdownTable());
  return buffer.toString();
}

String _prettyRepo(String url) {
  var cleaned = url.trim();
  if (cleaned.endsWith('.git')) {
    cleaned = cleaned.substring(0, cleaned.length - 4);
  }
  return cleaned;
}

String _repoLabel(String url) => url.replaceFirst(RegExp(r'^https?://'), '');
