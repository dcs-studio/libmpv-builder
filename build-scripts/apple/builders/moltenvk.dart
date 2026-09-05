import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../models/apple_platform.dart';
import '../models/apple_target.dart';

class MoltenvkBuilder extends AppleLibraryBuilder {

  const new() : super(Library.moltenvk);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "MoltenVK",
      staticLib: "libMoltenVK",
      sharedLib: "libMoltenVK",
      includeEntries: ["MoltenVK", "vulkan", "vk_video"],
    )
  ];

  @override
  void build({required AppleBuildContext context}) {
    final archSlug = context.target.arch.clangArch;
    final platformSlug = context.target.platform.slug;
    context.prefixDir.resolveDir("lib").mkdirs();
    context.prefixDir.resolveDir("include").mkdirs();
    exec(
      workingDir: context.sourcesDir,
      args: ["./fetchDependencies", "--$platformSlug"]
    );
    exec(
      workingDir: context.sourcesDir,
      args: ["make", platformSlug]
    );
    final linkDir = context.buildShared ? "dynamic" : "static";
    final framework = context.sourcesDir.resolveDir("Package/Release/MoltenVK/$linkDir/MoltenVK.xcframework");
    final slice = pickXcframeworkSlice(framework, context.target);
    if (slice == null || !slice.existsSync()) {
      throw "No framework slice for ${context.target.slug} in $framework";
    }
    final builtBinary = context.buildShared ? slice.resolveFile("MoltenVK.framework/MoltenVK") : slice.resolveFile("libMoltenVK.a");
    if ( !builtBinary.existsSync() ) {
      throw "MoltenVK output not found: $builtBinary";
    }
    final installedBinaryName = context.buildShared ? "libMoltenVK.dylib" : "libMoltenVK.a";
    final destBinary = context.prefixDir.resolveFile("lib/$installedBinaryName");
    final archs = readLipoArchs(builtBinary);
    if (archs.isEmpty || (archs.length == 1 && archs.first == archSlug)) {
      builtBinary.copyTo(destBinary);
      exec(
        workingDir: destBinary.parent,
        args: ["chmod", "a+x", destBinary.name],
      );
    } else if ( archs.contains(archSlug) ) {
      exec(
        workingDir: context.sourcesDir,
        args: ["lipo", builtBinary.absolutePath, "-thin", archSlug, "-output", destBinary.absolutePath]
      );
    } else {
      throw "MoltenVK for $platformSlug does not contain $archSlug (has $archs)";
    }
    if (context.buildShared) {
      exec(
        workingDir: Directory.current,
        args: ["install_name_tool", "-id", "@rpath/MoltenVK.framework/MoltenVK", destBinary.absolutePath],
      );
    }
    final includeSrc = context.sourcesDir.resolveDir("Package/Release/MoltenVK/include");
    if ( includeSrc.existsSync() ) {
      final target = context.prefixDir.resolveDir("include");
      includeSrc.copyToRecursively(target);
    }
    writeVulkanPkgConfig(context);
  }

  void writeVulkanPkgConfig(AppleBuildContext context) {
    final version = readVulkanHeadersVersion(context);
    final pkgConfigFile = context.prefixDir.resolveFile("lib/pkgconfig/vulkan.pc");
    pkgConfigFile.parent.mkdirs();
    pkgConfigFile.createSync();

    final frameworks = [
      "CoreFoundation",
      "CoreGraphics",
      "Foundation",
      "IOSurface",
      "Metal",
      "QuartzCore",
      ...switch (context.target.platform) {
        ApplePlatform.macos                          => ["Cocoa", "IOKit"],
        ApplePlatform.ios || ApplePlatform.iossim    => ["UIKit", "IOKit"],
      },
    ];

    final libs = frameworks.map( (it) => "-framework $it").join(' ');

    final contents = '''
      prefix=${context.prefixDir.absolutePath}
      includedir=\${prefix}/include
      libdir=\${prefix}/lib
      
      Name: Vulkan-Loader
      Description: Vulkan Loader
      Version: $version
      Libs: -L\${libdir} -lMoltenVK $libs
      Cflags: -I\${includedir}
    '''.trimLeft();
    pkgConfigFile.writeAsStringSync(contents);
    pkgConfigFile.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
  }

  String readVulkanHeadersVersion(AppleBuildContext context) {
    final headersRepo = context.sourcesDir.resolveDir("External/Vulkan-Headers");
    final processResult = execAndGet(
      workingDir: headersRepo,
      args: ["git", "describe", "--tags"],
    );
    final out = processResult.stdout.toString();
    if (processResult.exitCode != 0 || out.isEmpty) {
      throw "Failed to read Vulkan-Headers version from $headersRepo (exit=${processResult.exitCode}, out='$out')";
    }
    return out.trim().replaceAll("v", "");
  }

  Directory? pickXcframeworkSlice(Directory xcframework, AppleTarget target) {
    if ( !xcframework.existsSync() ) {
      return null;
    }
    final prefix = switch (target.platform) {
      ApplePlatform.macos  => "macos-",
      ApplePlatform.ios    => "ios-",
      ApplePlatform.iossim => "ios-",
    };
    final wantVariant = target.platform == ApplePlatform.iossim ? "simulator" : null;
    final archToken = target.arch.clangArch;
    return xcframework.listSync()
        .whereType<Directory>()
        .firstWhere( (dir) {
          if ( !dir.name.startsWith(prefix) ) return false;
          final rest = dir.name.removePrefix(prefix);
          String? variant = rest.substringAfter("-", "");
          if (variant.isEmpty) {
            variant = null;
          }
          final regex = RegExp(r"_(?=[A-Za-z])");
          final archs = rest.substringBefore("-").split(regex);
          return variant == wantVariant && archs.contains(archToken);
        });
  }

  List<String> readLipoArchs(File file) {
    final result = execAndGet(
      workingDir: Directory.current,
      args: ["lipo", "-archs", file.absolutePath],
    );
    if (result.exitCode != 0) {
      return [];
    }
    final regex = RegExp(r"\s+");
    return result.stdout
        .toString()
        .split(regex)
        .where( (it) => it.isNotEmpty)
        .toList(growable: false);
  }


}