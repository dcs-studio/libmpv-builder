
enum AndroidAbi {

  arm32, arm64, x86, x86_64;

  final int minimumApi = 21;

  String get clang => "$ndkTriple$minimumApi-clang";
  String get cpp   => "$ndkTriple$minimumApi-clang++";

  String get androidName => switch (this) {
    AndroidAbi.arm32  => "armeabi-v7a",
    AndroidAbi.arm64  => "arm64-v8a",
    AndroidAbi.x86    => "x86",
    AndroidAbi.x86_64 => "x86_64",
  };

  String get ndkTriple => switch (this) {
    AndroidAbi.arm32  => "armv7a-linux-androideabi",
    AndroidAbi.arm64  => "aarch64-linux-android",
    AndroidAbi.x86    => "i686-linux-android",
    AndroidAbi.x86_64 => "x86_64-linux-android",
  };

  String get cpuFamily => switch (this) {
    AndroidAbi.arm32  => "arm",
    AndroidAbi.arm64  => "aarch64",
    AndroidAbi.x86    => "x86",
    AndroidAbi.x86_64 => "x86_64",
  };

  String get cmakeSystemProcessor => switch (this) {
    AndroidAbi.arm32  => "armv7a",
    AndroidAbi.arm64  => "aarch64",
    AndroidAbi.x86    => "x86",
    AndroidAbi.x86_64 => "x86_64",
  };


}
