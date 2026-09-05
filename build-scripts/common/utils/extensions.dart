import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../common.dart';

extension GroupBy<T> on Iterable<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final Map<K, List<T>> result = {};
    for (final element in this) {
      (result[keyOf(element)] ??= []).add(element);
    }
    return result;
  }
}

extension StringUtils on String {

  String removePrefix(String prefix) => startsWith(prefix) ? substring(prefix.length) : this;

  String removeSuffix(String suffix) => endsWith(suffix) ? substring(0, length - suffix.length) : this;

  String substringBefore(String delimiter, [String? missingDelimiterValue]) {
    final int i = indexOf(delimiter);
    return i == -1 ? (missingDelimiterValue ?? this) : substring(0, i);
  }

  String substringAfter(String delimiter, [String? missingDelimiterValue]) {
    final int i = indexOf(delimiter);
    return i == -1 ? (missingDelimiterValue ?? this) : substring(i + delimiter.length);
  }

  String substringBeforeLast(String delimiter, [String? missingDelimiterValue]) {
    final int i = lastIndexOf(delimiter);
    return i == -1 ? (missingDelimiterValue ?? this) : substring(0, i);
  }

  String substringAfterLast(String delimiter, [String? missingDelimiterValue]) {
    final int i = lastIndexOf(delimiter);
    return i == -1 ? (missingDelimiterValue ?? this) : substring(i + delimiter.length);
  }

}

extension FileSystemutils on FileSystemEntity {
  String get name => basename(this.path);
  String get extension => p.extension(this.path).replaceFirst(".", "");
  String get absolutePath => this.absolute.path;
}

extension FileUtils on File {

  void zipTo({
    required File destination,
    int level = DeflateLevel.bestCompression,
  }) {
    destination.parent.mkdirs();
    final encoder = ZipFileEncoder();
    encoder.create(destination.absolutePath, level: level);
    try {
      encoder.addFileSync(this, this.name, level);
    } finally {
      encoder.closeSync();
    }
  }

  void copyTo(File destination) {
    destination.parent.mkdirs();
    this.copySync(destination.path);
  }

}

extension DirectoryUtils on Directory {

  static Directory cwd() => Directory(Directory.current.absolutePath);

  void copyToRecursively(Directory destination) {
    destination.createSync(recursive: true);
    for (final entity in listSync(recursive: true, followLinks: false)) {
      final String target = join(destination.path, relative(entity.path, from: path));
      switch (entity) {
        case File f:
          Directory( dirname(target) ).createSync(recursive: true);
          f.copySync(target);
        case Directory _:
          Directory(target).createSync(recursive: true);
        case Link l:
          Link(target).createSync(l.targetSync(), recursive: true);
      }
    }
  }

  Directory resolveDir(String path) {
    final p = join(this.path, path);
    return Directory(p);
  }

  File resolveFile(String path) {
    final p = join(this.path, path);
    return File(p);
  }

  void mkdirs() {
    this.createSync(recursive: true);
  }

  void zipTo({
    required File destination,
    bool includeRootDir = false,
    int level = DeflateLevel.bestCompression,
    bool followLinks = false,
  }) {
    destination.parent.mkdirs();
    final encoder = ZipFileEncoder();
    encoder.create(destination.absolutePath, level: level);
    try {
      encoder.addDirectorySync(
        this,
        includeDirName: includeRootDir,
        level: level,
        followLinks: followLinks,
      );
    } finally {
      encoder.closeSync();
    }
  }

}

extension BuilderUtils<C extends BuildContext> on LibraryBuilder<C> {

  void buildOrSkip(C context) {
    final marker = context.intermediatesDir.resolveFile(".marker");
    if ( marker.existsSync() ) {
      Logger.info("Skipping build for [${context.logLabel}]");
      return;
    }
    if ( context.intermediatesDir.existsSync() ) {
      context.intermediatesDir.deleteSync(recursive: true);
    }
    context.intermediatesDir.mkdirs();
    context.prefixDir.mkdirs();
    build(context: context);
    final now = DateTime.now().toIso8601String();
    marker.createSync();
    marker.writeAsStringSync(now);
  }

}