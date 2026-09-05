import 'dart:ffi';

import '../common.dart';

final class CurrentHost {

  CurrentHost._();

  static int get cores => 1;

  static String get arch {
    final os = Platform.operatingSystem;
    final abiArch = Abi.current().toString().split("_").last;
    return switch (os) {
      "macos" => "darwin-x86_64",
      "linux" => switch (abiArch) {
        "arm64" => "linux-aarch64",
        "x64"   => "linux-x86_64",
        _ => throw "Unknown arch: $abiArch",
      },
      _ => throw "Unknown operating system: $os",
    };
  }

  static Directory get ndkDirectory {
    final providedPath = Platform.environment["ANDROID_NDK_HOME"];
    if (providedPath != null && providedPath.isNotEmpty) {
      return Directory(providedPath);
    }
    final user = Platform.environment["USER"];
    if (user == null || user.isEmpty) {
      throw "Cannot look for a default NDK path";
    }
    return Directory("/Users/$user/Library/Android/sdk/ndk/29.0.14206865");
  }

  static Directory get ndkToolchainsDirectory => CurrentHost.ndkDirectory.resolveDir("toolchains/llvm/prebuilt/${CurrentHost.arch}/bin");


}