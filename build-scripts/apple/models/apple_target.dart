import 'apple_arch.dart';
import 'apple_platform.dart';

class const AppleTarget(final ApplePlatform platform, final AppleArch arch) {

  String get slug => "${platform.slug}-${arch.slug}";

  String get clangTarget => switch (platform) {
    ApplePlatform.macos  => "${arch.clangArch}-apple-macos${platform.minVersion}",
    ApplePlatform.ios    => "${arch.clangArch}-apple-ios${platform.minVersion}",
    ApplePlatform.iossim => "${arch.clangArch}-apple-ios${platform.minVersion}-simulator",
  };

  String get minVersionFlag => switch (platform) {
    ApplePlatform.macos  => "-mmacosx-version-min=${platform.minVersion}",
    ApplePlatform.ios    => "-mios-version-min=${platform.minVersion}",
    ApplePlatform.iossim => "-mios-simulator-version-min=${platform.minVersion}",
  };

  String get rustTarget => switch (platform) {
    ApplePlatform.macos  => "${arch.cpuFamily}-apple-darwin",
    ApplePlatform.ios    => "${arch.cpuFamily}-apple-ios",
    ApplePlatform.iossim => switch (arch) {
      AppleArch.x86_64 => "x86_64-apple-ios",
      AppleArch.arm64  => "aarch64-apple-ios-sim",
    },
  };

  String get makeHostTriplet {
    final prefix = switch (arch) {
      AppleArch.x86_64 => "x86_64",
      AppleArch.arm64  => "arm64",
    };
    final suffix = switch (platform) {
      ApplePlatform.macos  => "apple-darwin",
      ApplePlatform.ios    => "ios-darwin",
      ApplePlatform.iossim => "ios-darwin",
    };
    return "$prefix-$suffix";
  }


}
