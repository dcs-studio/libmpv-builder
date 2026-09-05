import 'package:args/args.dart';

import '../common/common.dart';
import 'builders/ass.dart';
import 'builders/dav1d.dart';
import 'builders/ffmpeg.dart';
import 'builders/freetype.dart';
import 'builders/fribidi.dart';
import 'builders/harfbuzz.dart';
import 'builders/mbedtls.dart';
import 'builders/mpv.dart';
import 'builders/placebo.dart';
import 'builders/unibreak.dart';
import 'models/android_abi.dart';
import 'models/android_build_context.dart';
import 'models/android_library_builder.dart';

export 'models/android_abi.dart';
export 'models/android_build_context.dart';
export 'models/android_library_builder.dart';
export 'utils/android_crossfile.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag("help", abbr: "h", negatable: false, help: "Show this help", defaultsTo: false)
    ..addOption(
      /*name:*/ "action",
      allowed: ["build", "bundle"],
    )
    ..addMultiOption(
      /*name: */ "abis",
      allowed: AndroidAbi.values.map( (it) => it.name),
      defaultsTo: AndroidAbi.values.map( (it) => it.name),
    )
    ..addMultiOption(
      /*name: */ "libs",
      allowed: androidLibraries.map( (it) => it.name),
      defaultsTo: androidLibraries.map( (it) => it.name),
    )
    ..addFlag("log", defaultsTo: true, help: "Log processes output");

  final results = parser.parse(args);

  final help      = results.flag("help");
  if (help) {
    stdout.write(parser.usage);
    return;
  }
  final action    = results.option("action");
  final log       = results.flag("log");
  final bundle    = results.flag("bundle");
  final abis      = results.multiOption("abis").map(AndroidAbi.values.byName).toList(growable: false);
  final libraries = results.multiOption("libs")
      .map(androidLibraries.byName)
      .toList(growable: false)
      ..sort( (left, right) {
        final l = androidLibraries.indexOf(left);
        final r = androidLibraries.indexOf(right);
        return l.compareTo(r);
      });



  Logger.enabled = log;

  switch (action) {
    case "build":
      for (final abi in abis) {
        for (final lib in libraries) {
          final context = AndroidBuildContext(library: lib, abi: abi);
          final builder = androidBuilders[lib]!;
          builder.fetchSources(context: context);
          builder.buildOrSkip(context);
        }
      }
      break;
    case "bundle":
      final tempDir = Directory.systemTemp.createTempSync("android-binaries.zip");
      try {
        final outputDir = Directory.current.absolute.resolveDir("out/android");
        final archive   = Directory.current.absolute.resolveFile("out/artifacts/android-binaries.zip");
        for (final abi in abis) {
          final prefixDir  = outputDir.resolveDir("${abi.androidName}/prefix");
          final binaries   = prefixDir.resolveDir("lib").listSync();
          final mpvHeaders = prefixDir.resolveDir("include/mpv");
          final jniHeader  = prefixDir.resolveFile("include/libavcodec/jni.h");
          mpvHeaders.copyToRecursively(
            tempDir.resolveDir("${abi.androidName}/include/mpv"),
          );
          jniHeader.copyTo(
            tempDir.resolveFile("${abi.androidName}/include/libavcodec/jni.h"),
          );
          for (final bin in binaries) {
            if (bin is! File) continue;
            if (bin.extension != "so") continue;
            final destination = tempDir.resolveFile("${abi.androidName}/lib/${bin.name}");
            bin.copyTo(destination);
          }
        }
        archive.parent.mkdirs();
        tempDir.zipTo(destination: archive);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
      break;
    default: throw "Invalid action: $action";
  }

}


Map<Library, AndroidLibraryBuilder> get androidBuilders => const {
  Library.unibreak : UnibreakBuilder(),
  Library.freetype : FreetypeBuilder(),
  Library.fribidi  : FribidiBuilder(),
  Library.harfbuzz : HarfbuzzBuilder(),
  Library.ass      : AssBuilder(),
  Library.dav1d    : Dav1dBuilder(),
  Library.placebo  : PlaceboBuilder(),
  Library.mbedtls  : MbedtlsBuilder(),
  Library.ffmpeg   : FFmpegBuilder(),
  Library.mpv      : MpvBuilder(),
};

List<Library> get androidLibraries => androidBuilders.keys.toList(growable: false);