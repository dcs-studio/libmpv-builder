import '../../common/common.dart';
import '../utils/apple_utils.dart';

enum ApplePlatform {

  macos, ios, iossim;

  String get slug => switch (this) {
    ApplePlatform.macos  => "macos",
    ApplePlatform.ios    => "ios",
    ApplePlatform.iossim => "iossim",
  };

  String get sdk => switch (this) {
    ApplePlatform.macos  => "macosx",
    ApplePlatform.ios    => "iphoneos",
    ApplePlatform.iossim => "iphonesimulator",
  };

  String get cmakeSystemName => switch (this) {
    ApplePlatform.macos  => "Darwin",
    ApplePlatform.ios    => "iOS",
    ApplePlatform.iossim => "iOS",
  };

  String get mesonSubsystem => switch (this) {
    ApplePlatform.macos  => "macos",
    ApplePlatform.ios    => "ios",
    ApplePlatform.iossim => "ios-simulator",
  };

  String get minVersion => switch (this) {
    ApplePlatform.macos  => "12.0",
    ApplePlatform.ios    => "15.0",
    ApplePlatform.iossim => "15.0",
  };

  String get sdkPath => xcrun(sdk: this.sdk, arg: "--show-sdk-path");


  String toolPath(String name) {
    final result = execAndGet(
      workingDir: Directory.current,
      args: ["xcrun", "--sdk", sdk, "--find", name],
    );
    if (result.exitCode != 0) {
      throw "xcrun --sdk $sdk --find $tool failed (exit ${result.exitCode})";
    }
    return result.stdout.toString().trim();
  }

  String tool(String name) => toolPath(name);

}
