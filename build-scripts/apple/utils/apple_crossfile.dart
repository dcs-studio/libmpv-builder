
import '../../common/common.dart';
import '../models/apple_build_context.dart';

extension _MesonUtils on List<String> {

  String get mesonArray {
    final result = this.map( (it) => "'$it'").join(", ");
    return "[$result]";
  }

}

Crossfile appleCrossfile(AppleBuildContext context) {
  final sysroot = context.target.platform.sdkPath;
  final cArgs = [
    "-arch", context.target.arch.clangArch,
    "-isysroot", sysroot,
    "-target", context.target.clangTarget,
    context.target.minVersionFlag,
    "-fPIC",
    "-I${context.prefixDir.resolveDir("include").absolutePath}",
  ];

  final linkArgs = [
    "-arch", context.target.arch.clangArch,
    "-isysroot", sysroot,
    "-target", context.target.clangTarget,
    context.target.minVersionFlag,
    "-L${context.prefixDir.resolveDir("lib").absolutePath}",
  ];

  return Crossfile({
    "built-in options": {
      "buildtype"       : "release",
      "default_library" : context.buildShared ? "shared" : "static",
      "wrap_mode"       : "nodownload",
      "prefix"          : context.prefixDir.absolutePath,
      "c_args"          : cArgs.mesonArray,
      "cpp_args"        : cArgs.mesonArray,
      "objc_args"       : cArgs.mesonArray,
      "objcpp_args"     : cArgs.mesonArray,
      "c_link_args"     : linkArgs.mesonArray,
      "cpp_link_args"   : linkArgs.mesonArray,
      "objc_link_args"  : linkArgs.mesonArray,
      "objcpp_link_args": linkArgs.mesonArray,
    },
    "binaries": {
      "c"         : "/usr/bin/clang",
      "cpp"       : "/usr/bin/clang++",
      "objc"      : "/usr/bin/clang",
      "objcpp"    : "/usr/bin/clang++",
      "ar"        : context.target.platform.tool("ar"),
      "strip"     : context.target.platform.tool("strip"),
      "ranlib"    : context.target.platform.tool("ranlib"),
      "pkg-config": "pkg-config",
    },
    "properties": {
      "pkg_config_libdir"  : context.prefixDir.resolveDir("lib/pkgconfig").absolutePath,
      "has_function_printf": "true",
    },
    "host_machine": {
      "system"    : "darwin",
      "subsystem" : context.target.platform.mesonSubsystem,
      "kernel"    : "xnu",
      "cpu_family": context.target.arch.cpuFamily,
      "cpu"       : context.target.arch.clangArch,
      "endian"    : "little",
    },
  });
}
