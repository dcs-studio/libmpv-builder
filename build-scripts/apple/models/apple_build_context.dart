import '../../common/common.dart';
import '../utils/apple_utils.dart';
import 'apple_target.dart';

class AppleBuildContext extends BuildContext {

  new({required this.library, required this.target, required this.linkType});

  @override final Library library;

  final AppleTarget target;
  final LinkType linkType;

  bool get buildShared => linkType == LinkType.shared && library.canBeShared;

  String get mesonLibrary => buildShared ? "shared" : "static";

  @override Directory get buildDirectory   => Directory.current.absolute.resolveDir("out/apple/${linkType.name}");
  @override Directory get intermediatesDir => buildDirectory.resolveDir("${target.slug}/intermediates/${library.name}");
  @override Directory get prefixDir        => buildDirectory.resolveDir("${target.slug}/prefix");
  @override File      get crossFile        => buildDirectory.resolveFile("${target.slug}/cross-files/${library.name}.ini");
  @override String    get logLabel         => "${library.name}-${target.slug}";

  @override Directory get sourcesDir => switch (library) {
    Library.moltenvk => Directory.current.absolute.resolveDir("out/apple/sources/${library.name}-${target.platform.slug}"),
    _                => Directory.current.absolute.resolveDir("out/apple/sources/${library.name}"),
  } ;

  @override
  Map<String, String> get configureTaskEnv {
    final commonFlags = "-arch ${target.arch.clangArch} -isysroot ${target.platform.sdkPath} -target ${target.clangTarget} ${target.minVersionFlag}";
    return {
      "LC_CTYPE"         : "C",
      "CC"               : "/usr/bin/clang",
      "CXX"              : "/usr/bin/clang++",
      "AR"               : target.platform.toolPath("ar"),
      "RANLIB"           : target.platform.toolPath("ranlib"),
      "STRIP"            : target.platform.toolPath("strip"),
      "PKG_CONFIG_LIBDIR": prefixDir.resolveDir("lib/pkgconfig").absolutePath,
      "CFLAGS"           : "$commonFlags -fPIC -I${prefixDir.resolveDir("include").absolutePath}",
      "CXXFLAGS"         : "$commonFlags -fPIC -I${prefixDir.resolveDir("include").absolutePath}",
      "LDFLAGS"          : "$commonFlags -L${prefixDir.resolveDir("lib").absolutePath}",
    };
  }

  @override
  List<String> get defaultCmakeArgs => [
    "-DCMAKE_OSX_SYSROOT=${target.platform.sdk}",
    "-DCMAKE_OSX_ARCHITECTURES=${target.arch.clangArch}",
    "-DCMAKE_OSX_DEPLOYMENT_TARGET=${target.platform.minVersion}",
    "-DCMAKE_SYSTEM_NAME=${target.platform.cmakeSystemName}",
    "-DCMAKE_SYSTEM_PROCESSOR=${target.arch.clangArch}",
    "-DCMAKE_INSTALL_PREFIX=${prefixDir.absolutePath}",
  ];


}