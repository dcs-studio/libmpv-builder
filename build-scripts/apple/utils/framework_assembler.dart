
import '../../common/common.dart';
import '../apple.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../models/apple_platform.dart';
import '../models/apple_target.dart';
import 'apple_utils.dart';

const List<String> _rpathEntries = [
  "@executable_path/Frameworks",
  "@loader_path/Frameworks",
  "@loader_path/..",
];

extension FrameworkAssembler on AppleLibraryBuilder {

  void assembleFrameworks(
    LinkType link,
    List<AppleTarget> targets,
  ) {
    if (frameworks.isEmpty) return;
    final perPlatform = targets.groupBy( (it) => it.platform);
    for (final framework in frameworks) {
      final platformFrameworks = perPlatform.entries
          .map( (entry) => assembleFatFramework(framework, link, entry.key, entry.value) )
          .toList(growable: false);
      if (platformFrameworks.isEmpty) {
        Logger.error("assembleFrameworks: no platform slices produced for ${framework.name}, skipping xcframework");
        continue;
      }
      assembleXcFramework(framework, link, platformFrameworks);
    }
  }

  Directory assembleFatFramework(
    AppleFramework framework,
    LinkType link,
    ApplePlatform platform,
    List<AppleTarget> targets,
  ) {
    final shared = link == LinkType.shared && library.canBeShared;
    final libFileName = shared ? framework.sharedLib : framework.staticLib;
    final extension = shared ? "dylib" : "a";
    final binaries = targets
        .map( (target) {
          final context = AppleBuildContext(library: library, target: target, linkType: link);
          final file = context.prefixDir.resolveFile("lib/$libFileName.$extension");
          return file.existsSync() ? file : null;
        })
        .nonNulls
        .toList(growable: false);
    if (binaries.isEmpty) {
      throw "assembleFatFramework: no ${libFileName}.$extension for ${framework.name} on ${platform.slug}";
    }
    final frameworkDir = fatFrameworkDir(framework, link, platform);
    if ( frameworkDir.existsSync() ) {
      frameworkDir.deleteSync(recursive: true);
    }
    frameworkDir.mkdirs();
    final binaryFile = frameworkDir.resolveFile(framework.name);
    _lipoCreate(binaries, binaryFile);
    final hasHeaders = _copyHeaders(this.library, framework, link, targets.first, frameworkDir.resolveDir("Headers"));
    if (framework.modular && hasHeaders) {
      _writeModulemap(framework, frameworkDir.resolveFile("Modules/module.modulemap"));
    }
    _writeInfoPlist(framework, platform, frameworkDir.resolveFile("Info.plist"));
    if (shared) {
      _rewriteSharedLoadCommands(framework, binaryFile);
    }
    return frameworkDir;
  }


  void assembleXcFramework(
    AppleFramework framework,
    LinkType link,
    List<Directory> platformFrameworks,
  ) {
    final out = xcFrameworkDir(framework, link);
    if ( out.existsSync() ) {
      out.deleteSync(recursive: true);
    }
    out.parent.mkdirs();
    exec(
      workingDir: Directory.current,
      args: [
        "xcodebuild",
        "-create-xcframework",
        for (final dir in platformFrameworks) ...["-framework", dir.absolutePath],
        "-output", out.absolutePath,
      ]
    );
  }

  Directory fatFrameworkDir(
    AppleFramework framework,
    LinkType link,
    ApplePlatform platform,
  ) {
    final frameworksRoot = Directory.current.resolveDir("out/apple/${link.name}/frameworks");
    return frameworksRoot.resolveDir("${platform.slug}/${framework.name}.framework");
  }


  Directory xcFrameworkDir(
    AppleFramework framework,
    LinkType link,
  ) {
    final xcframeworksRoot = Directory.current.resolveDir("out/apple/${link.name}/xcframeworks");
    return xcframeworksRoot.resolveDir("${framework.name}.xcframework");
  }

}


void _lipoCreate(List<File> binaries, File output) {
  exec(
    workingDir: Directory.current,
    args: [
      "lipo", "-create",
      ...binaries.map((b) => b.absolutePath),
      "-output", output.absolutePath,
    ],
  );
}

void _rewriteSharedLoadCommands(AppleFramework framework, File binary) {
  final ownId = "@rpath/${framework.name}.framework/${framework.name}";
  exec(
    workingDir: Directory.current,
    args: ["install_name_tool", "-id", ownId, binary.absolutePath],
  );

  final allFrameworks = appleBuilders.values.expand((b) => b.frameworks).toList(growable: false);
  final deps = _readDylibDeps(binary);
  final candidates = allFrameworks
      .expand((fw) => [fw.sharedLib, ...fw.sharedAliases].map((alias) => (fw: fw, alias: alias)))
      .toList()
    ..sort((a, b) => b.alias.length.compareTo(a.alias.length));

  for (final dep in deps) {
    if (dep == ownId) continue;
    final basename = File(dep).name;
    if (!basename.endsWith(".dylib")) continue;
    final hit = candidates.where((c) => basename.startsWith("${c.alias}.")).firstOrNull;
    if (hit == null) continue;
    if (hit.fw.name == framework.name) continue;
    final newDep = "@rpath/${hit.fw.name}.framework/${hit.fw.name}";
    if (dep == newDep) continue;
    exec(
      workingDir: Directory.current,
      args: ["install_name_tool", "-change", dep, newDep, binary.absolutePath],
    );
  }

  // Only frameworks that actually load a sibling framework need the rpaths.
  // Adding them unconditionally also breaks binaries linked without
  // -headerpad_max_install_names (MoltenVK's Xcode project, for one): they have
  // room for an extra load command or two at most, and install_name_tool then
  // fails outright rather than skipping.
  final loadsSiblings = _readDylibDeps(binary).any((d) => d != ownId && d.startsWith("@rpath/"));
  if (!loadsSiblings) return;

  final existingRpaths = _readRpaths(binary);
  for (final entry in _rpathEntries) {
    if (existingRpaths.contains(entry)) continue;
    exec(
      workingDir: Directory.current,
      args: ["install_name_tool", "-add_rpath", entry, binary.absolutePath],
    );
  }
}

List<String> _readDylibDeps(File binary) {
  final result = execAndGet(
    workingDir: Directory.current,
    args: ["otool", "-L", binary.absolutePath],
  );
  if (result.exitCode != 0) {
    throw "otool -L failed for ${binary.absolutePath}: ${result.stdout}${result.stderr}";
  }
  final lines = result.stdout.toString().split("\n");
  return lines
      .skip(1)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.endsWith(":"))
      .map((l) => l.substringBefore(" (").trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);
}

List<String> _readRpaths(File binary) {
  final result = execAndGet(
    workingDir: Directory.current,
    args: ["otool", "-l", binary.absolutePath],
  );
  if (result.exitCode != 0) {
    throw "otool -l failed for ${binary.absolutePath}: ${result.stdout}${result.stderr}";
  }
  final rpaths = <String>[];
  final lines = result.stdout.toString().split("\n");
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim() != "cmd LC_RPATH") continue;
    final pathLine = lines
        .skip(i + 1)
        .cast<String?>()
        .firstWhere((l) => l!.trim().startsWith("path "), orElse: () => null);
    if (pathLine == null) continue;
    final value = pathLine.trim().removePrefix("path ").substringBefore(" (offset").trim();
    rpaths.add(value);
  }
  return rpaths;
}

bool _copyHeaders(
  Library library,
  AppleFramework framework,
  LinkType link,
  AppleTarget sample,
  Directory headersDir,
) {
  final context = AppleBuildContext(library: library, target: sample, linkType: link);
  final includeRoot = context.prefixDir.resolveDir("include");
  if (!includeRoot.existsSync()) return false;

  final subdirName = framework.includeSubdir;
  final subdir = subdirName == null ? null : includeRoot.resolveDir(subdirName);
  if (subdir != null && subdir.existsSync()) {
    headersDir.mkdirs();
    subdir.copyToRecursively(headersDir);
  } else if (framework.includeEntries.isNotEmpty) {
    headersDir.mkdirs();
    for (final entry in framework.includeEntries) {
      final srcPath = join(includeRoot.path, entry);
      final type = FileSystemEntity.typeSync(srcPath);
      switch (type) {
        case FileSystemEntityType.directory:
          Directory(srcPath).copyToRecursively(headersDir.resolveDir(basename(srcPath)));
        case FileSystemEntityType.file:
          File(srcPath).copyTo(headersDir.resolveFile(basename(srcPath)));
        case _:
          continue;
      }
    }
  } else {
    return false;
  }

  for (final denied in framework.deniedHeaders) {
    final f = headersDir.resolveFile(denied);
    if (f.existsSync()) f.deleteSync();
  }
  return true;
}

void _writeModulemap(AppleFramework framework, File file) {
  file.parent.mkdirs();
  file.writeAsStringSync('''
framework module ${framework.name} [system] {
  umbrella "."
  export *
}
''');
}

void _writeInfoPlist(AppleFramework framework, ApplePlatform platform, File file) {
  final sdkName = switch (platform) {
    ApplePlatform.macos  => "MacOSX",
    ApplePlatform.ios    => "iPhoneOS",
    ApplePlatform.iossim => "iPhoneSimulator",
  };
  file.parent.mkdirs();
  file.writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>${framework.name}</string>
  <key>CFBundleIdentifier</key><string>dcs.studio.${framework.name}</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>${framework.name}</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleShortVersionString</key><string>${Versions.PROJECT}</string>
  <key>CFBundleVersion</key><string>${Versions.PROJECT}</string>
  <key>CFBundleSignature</key><string>????</string>
  <key>MinimumOSVersion</key><string>${platform.minVersion}</string>
  <key>CFBundleSupportedPlatforms</key><array><string>$sdkName</string></array>
</dict>
</plist>
''');
}
