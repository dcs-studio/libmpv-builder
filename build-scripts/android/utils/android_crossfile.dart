
import '../../common/common.dart';
import '../models/android_build_context.dart';

Crossfile androidCrossfile(AndroidBuildContext context) {
  return Crossfile({
    "built-in options": {
      "buildtype"      : "release",
      "b_ndebug"       : "true",
      "default_library": "static",
      "wrap_mode"      : "nodownload",
      "prefix"         : context.prefixDir.absolutePath,
      "c_args"         : "[]",
      "cpp_args"       : "[]",
      "c_link_args"    : "['-Wl,-z,max-page-size=16384']",
      "cpp_link_args"  : "['-Wl,-z,max-page-size=16384']",
    },
    "binaries": {
      "c"         : "${CurrentHost.ndkToolchainsDirectory.resolveFile(context.abi.clang).absolutePath}",
      "cpp"       : "${CurrentHost.ndkToolchainsDirectory.resolveFile(context.abi.cpp).absolutePath}",
      "ar"        : "${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-ar").absolutePath}",
      "nm"        : "${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-nm").absolutePath}",
      "strip"     : "${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-strip").absolutePath}",
      "pkg-config": "pkg-config",
    },
    "properties": {
      "pkg_config_libdir": context.prefixDir.resolveDir("lib/pkgconfig").absolutePath
    },
    "host_machine": {
      "system"    : "android",
      "cpu_family": context.abi.cpuFamily,
      "cpu"       : context.abi.ndkTriple.split("-")[0],
      "endian"    : "little",
    },
  });
}