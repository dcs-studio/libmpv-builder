import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../models/apple_platform.dart';

class DoviBuilder extends AppleLibraryBuilder {

  const new() : super(Library.dovi);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Dovi",
      staticLib: "libdovi",
      sharedLib: "libdovi",
      includeSubdir: "libdovi",
      modular: true,
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    try {
      Logger.info("Cargo [${context.logLabel}] -> STARTING");
      final rustTarget = context.target.rustTarget;
      final deplymentTargetVar = switch (context.target.platform) {
        ApplePlatform.macos  => "MACOSX_DEPLOYMENT_TARGET",
        ApplePlatform.ios    => "IPHONEOS_DEPLOYMENT_TARGET",
        ApplePlatform.iossim => "IPHONEOS_DEPLOYMENT_TARGET",
      };
      exec(
        workingDir: context.sourcesDir.resolveDir("dolby_vision"),
        args: [
          "cargo", "cinstall",
          "--release",
          "--prefix", context.prefixDir.absolutePath,
          "--target", rustTarget,
          "--library-type", if (context.buildShared) "cdylib" else "staticlib",
          "--features", "capi",
        ],
        env: {
          deplymentTargetVar: context.target.platform.minVersion,
          "CARGO_TARGET_DIR": context.intermediatesDir.absolutePath,
        },
      );
      Logger.info("Cargo [${context.logLabel}] -> DONE");
    } catch (_) {
      Logger.error("Cargo [${context.logLabel}] -> DONE");
      rethrow;
    }
  }

}