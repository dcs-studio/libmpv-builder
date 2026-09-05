import 'package:args/args.dart';

import '../common/common.dart';
import 'builders/ass.dart';
import 'builders/dav1d.dart';
import 'builders/dovi.dart';
import 'builders/ffmpeg.dart';
import 'builders/freetype.dart';
import 'builders/fribidi.dart';
import 'builders/harfbuzz.dart';
import 'builders/lcms2.dart';
import 'builders/mbedtls.dart';
import 'builders/moltenvk.dart';
import 'builders/mpv.dart';
import 'builders/placebo.dart';
import 'builders/shaderc.dart';
import 'builders/uchardet.dart';
import 'builders/unibreak.dart';
import 'models/apple_arch.dart';
import 'models/apple_build_context.dart';
import 'models/apple_library_builder.dart';
import 'models/apple_platform.dart';
import 'models/apple_target.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag("help", abbr: "h", negatable: false, help: "Show this help", defaultsTo: false)
    ..addOption(
      /* name: */ "link-type",
      help: "Linkage type",
      allowed: LinkType.values.map( (it) => it.name),
      defaultsTo: LinkType.static.name,
    )
    ..addMultiOption(
      /*name: */ "targets",
      help: "Apple targets (<platform>-<arch>)",
      allowed: allTargets.map( (it) => "${it.platform.name}-${it.arch.name}"),
      defaultsTo: allTargets.map( (it) => "${it.platform.name}-${it.arch.name}"),
    )
    ..addMultiOption(
      /*name: */ "libs",
      allowed: appleLibraries.map( (it) => it.name),
      defaultsTo: appleLibraries.map( (it) => it.name),
    )
    ..addOption(
      /*name:*/ "action",
      allowed: ["build", "bundle"],
    )
    ..addFlag("log", defaultsTo: true, help: "Log processes output");

  final results = parser.parse(args);

  final help      = results.flag("help");
  if (help) {
    stdout.write(parser.usage);
    return;
  }

  final log       = results.flag("log");
  final action    = results.option("action");
  final targets   = results.multiOption("targets")
    .map( (it) {
      final [arg1, arg2] = it.split("-");
      final platform = ApplePlatform.values.byName(arg1);
      final arch     = AppleArch.values.byName(arg2);
      return AppleTarget(platform, arch);
    })
    .toList(growable: false);
  final libraries = results.multiOption("libs")
      .map(appleLibraries.byName)
      .toList(growable: false)
      ..sort( (left, right) {
        final l = appleLibraries.indexOf(left);
        final r = appleLibraries.indexOf(right);
        return l.compareTo(r);
      });
  final linkType = LinkType.values.byName(results.option("link-type")!);



  Logger.enabled = log;

  switch (action) {
    case "build":
      for (final target in targets) {
        for (final lib in libraries) {
          final context = AppleBuildContext(library: lib, target: target, linkType: linkType);
          final builder = appleBuilders[lib]!;
          builder.fetchSources(context: context);
          builder.buildOrSkip(context);
        }
      }
      break;
    case "bundle":
      for (final lib in libraries) {
        appleBuilders[lib]!.assembleFramework(link: linkType, targets: targets);
      }
      final appleArtifact = Directory.current.resolveFile("out/artifacts/apple-binaries-${linkType.name}.zip");
      final originalDir = Directory.current.resolveDir("out/apple/${linkType.name}/xcframeworks");
      if ( appleArtifact.existsSync() ) {
        appleArtifact.deleteSync();
      }
      originalDir.zipTo(destination: appleArtifact);
      if (linkType == LinkType.static) {
        final originalDir = Directory.current.resolveDir("out/apple/${linkType.name}/xcframeworks");
        final xcframeworks = originalDir.listSync(recursive: false).whereType<Directory>();
        for (final f in xcframeworks) {
          if ( !f.name.endsWith(".xcframework") ) continue;
          final destination = Directory.current.resolveFile("out/artifacts/${f.name}.zip");
          if ( destination.existsSync() ) {
            destination.deleteSync();
          }
          f.zipTo(destination: destination, includeRootDir: false);
        }
      }
      break;
    default: throw "Invalid action: $action";
  }

}

List<AppleTarget> get allTargets => const [
  AppleTarget(ApplePlatform.macos, AppleArch.arm64), //macos-arm64
  AppleTarget(ApplePlatform.macos, AppleArch.x86_64), //macos-x86_64
  AppleTarget(ApplePlatform.ios, AppleArch.arm64), //ios-arm64
  AppleTarget(ApplePlatform.iossim, AppleArch.arm64), //iossim-arm64
];

Map<Library, AppleLibraryBuilder> get appleBuilders => const {
  Library.unibreak: UnibreakBuilder(),
  Library.freetype: FreetypeBuilder(),
  Library.fribidi:  FribidiBuilder(),
  Library.harfbuzz: HarfbuzzBuilder(),
  Library.ass:      AssBuilder(),
  Library.moltenvk: MoltenvkBuilder(),
  Library.shaderc:  ShadercBuilder(),
  Library.dav1d:    Dav1dBuilder(),
  Library.lcms2:    Lcms2Builder(),
  Library.dovi:     DoviBuilder(),
  Library.placebo:  PlaceboBuilder(),
  Library.mbedtls:  MbedtlsBuilder(),
  Library.ffmpeg:   FFmpegBuilder(),
  Library.uchardet: UchardetBuilder(),
  Library.mpv:      MpvBuilder(),
};

List<Library> get appleLibraries => appleBuilders.keys.toList(growable: false);