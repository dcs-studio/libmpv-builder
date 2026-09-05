import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';

class ShadercBuilder extends AppleLibraryBuilder {

  const new() : super(Library.shaderc);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Shaderc",
      staticLib: "libshaderc_combined",
      sharedLib: "libshaderc_combined",
      sharedAliases: ["libshaderc_shared"],
      includeSubdir: "shaderc",
    ),
  ];

  void patchPopenLines({
    required File file,
    required int popenLineIdx,
    required int returnLineIdx,
  }) {
    final lines = file.readAsLinesSync();
    lines[popenLineIdx] = r"FILE* fp = popen(nullptr, "r");";
    lines[returnLineIdx] = "return fp == NULL;";
    final contents = lines.join("\n");
    file.writeAsStringSync(contents, mode: FileMode.writeOnly);
  }

  void buildCombinedDylib(AppleBuildContext context) {
    final libDir = context.prefixDir.resolveDir("lib");
    final combinedA = libDir.resolveFile("libshaderc_combined.a");
    if ( !combinedA.existsSync() ) {
      throw "Missing $combinedA — required to build shared combined dylib";
    }
    final outDylib  = libDir.resolveFile("libshaderc_combined.dylib");
    exec(
      workingDir: Directory.current,
      args: [
        "/usr/bin/clang++",
        "-dynamiclib",
        "-arch", context.target.arch.clangArch,
        "-isysroot", context.target.platform.sdkPath,
        "-target", context.target.clangTarget,
        context.target.minVersionFlag,
        "-install_name", "@rpath/Shaderc.framework/Shaderc",
        "-Wl,-force_load,${combinedA.absolutePath}",
        "-Wl,-exported_symbol,_shaderc_*",
        "-o", outDylib.absolutePath,
      ],
    );
  }

  void patchPkgConfig(AppleBuildContext context) {
    final pc = context.prefixDir.resolveFile("lib/pkgconfig/shaderc.pc");
    if ( !pc.existsSync() ) {
      return;
    }
    final patched = pc.readAsLinesSync()
      .map( (line) => line.startsWith("Libs:") ? "Libs: -L\${libdir} -lshaderc_combined" : line)
      .join("\n");
    pc.writeAsStringSync(patched, mode: FileMode.writeOnly);
    if ( !patched.endsWith("\n") ) {
      pc.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
    }
  }

  @override
  void build({required AppleBuildContext context}) {
    exec(
      workingDir: context.sourcesDir,
      args: ["utils/git-sync-deps"],
    );
    patchPopenLines(
      file: context.sourcesDir.resolveFile("third_party/spirv-tools/tools/reduce/reduce.cpp"),
      popenLineIdx: 36,
      returnLineIdx: 41,
    );
    patchPopenLines(
      file: context.sourcesDir.resolveFile("third_party/spirv-tools/tools/fuzz/fuzz.cpp"),
      popenLineIdx: 47,
      returnLineIdx: 52,
    );
    cmake(
      context: context,
      arguments: [
        "-DSHADERC_SKIP_TESTS=ON",
        "-DSHADERC_SKIP_EXAMPLES=ON",
        "-DSHADERC_SKIP_COPYRIGHT_CHECK=ON",
        "-DENABLE_EXCEPTIONS=ON",
        "-DENABLE_GLSLANG_BINARIES=OFF",
        "-DSPIRV_SKIP_EXECUTABLES=ON",
        "-DSPIRV_TOOLS_BUILD_STATIC=ON",
        "-DBUILD_SHARED_LIBS=OFF",
        // Force shaderc's public C API symbols to default visibility even in the
        // static build, so we can re-export them from the combined shared dylib.
        // Both defines are required — see libshaderc/include/shaderc/visibility.h.
        "-DCMAKE_C_FLAGS=-DSHADERC_SHAREDLIB=1 -DSHADERC_IMPLEMENTATION=1",
        "-DCMAKE_CXX_FLAGS=-DSHADERC_SHAREDLIB=1 -DSHADERC_IMPLEMENTATION=1",
      ],
    );
    make(context);
    if (context.buildShared) {
      buildCombinedDylib(context);
      patchPkgConfig(context);
    }
  }

}