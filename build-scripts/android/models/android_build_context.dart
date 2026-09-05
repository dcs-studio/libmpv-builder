import '../../common/common.dart';
import 'android_abi.dart';

class AndroidBuildContext extends BuildContext {

  new({required this.library, required this.abi});

  final AndroidAbi abi;
  @override final Library library;

  @override Directory get buildDirectory   => Directory.current.absolute.resolveDir("out/android");
  @override Directory get intermediatesDir => buildDirectory.resolveDir("${abi.androidName}/intermediates/${library.name}");
  @override Directory get prefixDir        => buildDirectory.resolveDir("${abi.androidName}/prefix");
  @override Directory get sourcesDir       => buildDirectory.resolveDir("sources/${library.name}");
  @override File      get crossFile        => buildDirectory.resolveFile("${abi.androidName}/cross-files/${library.name}.ini");
  @override String    get logLabel         => "${library.name}-${abi.androidName}";

  @override
  List<String> get defaultCmakeArgs => [
    "-DCMAKE_TOOLCHAIN_FILE=${CurrentHost.ndkDirectory.resolveFile("build/cmake/android.toolchain.cmake").absolutePath}",
    "-DANDROID_ABI=${abi.androidName}",
    "-DANDROID_PLATFORM=android-${abi.minimumApi}",
    "-DCMAKE_VERBOSE_MAKEFILE=0",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_SYSTEM_NAME=Android",
    "-DCMAKE_SYSTEM_PROCESSOR=${abi.cmakeSystemProcessor}",
    "-DCMAKE_INSTALL_PREFIX=${prefixDir.absolutePath}",
    "-DBUILD_SHARED_LIBS=OFF",
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
  ];

  @override
  Map<String, String> get configureTaskEnv {
    final toolchains = CurrentHost.ndkToolchainsDirectory;
    return {
      "CC"               : toolchains.resolveFile(abi.clang).absolutePath,
      "CXX"              : toolchains.resolveFile(abi.cpp).absolutePath,
      "AR"               : toolchains.resolveFile("llvm-ar").absolutePath,
      "NM"               : toolchains.resolveFile("llvm-nm").absolutePath,
      "STRIP"            : toolchains.resolveFile("llvm-strip").absolutePath,
      "RANLIB"           : toolchains.resolveFile("llvm-ranlib").absolutePath,
      "PKG_CONFIG_LIBDIR": prefixDir.resolveDir("lib/pkgconfig").absolutePath,
      "CFLAGS"           : "-fPIC -I${prefixDir.resolveDir("include").absolutePath}",
      "LDFLAGS"          : "-Wl,-z,max-page-size=16384 -L${prefixDir.resolveDir("lib").absolutePath}",
    };
  }



}