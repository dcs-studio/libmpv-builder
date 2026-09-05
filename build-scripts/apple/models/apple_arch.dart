
enum AppleArch {
  x86_64, arm64;

  String get slug => switch (this) {
    AppleArch.x86_64 => "x86_64",
    AppleArch.arm64  => "arm64",
  };

  String get cpuFamily => switch (this) {
    AppleArch.x86_64 => "x86_64",
    AppleArch.arm64  => "aarch64",
  };

  String get clangArch => switch (this) {
    AppleArch.x86_64 => "x86_64",
    AppleArch.arm64  => "arm64",
  };

}
