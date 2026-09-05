import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class PlaceboBuilder extends AppleLibraryBuilder {

  const new() : super(Library.placebo);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Placebo",
      staticLib: "libplacebo",
      sharedLib: "libplacebo",
      includeEntries: ["libplacebo"],
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    meson(
      context: context,
      crossfile: appleCrossfile(context),
      arguments: [
        "-Ddefault_library=${context.mesonLibrary}",
        "-Dbuildtype=release",
        "-Dopengl=enabled",
        "-Dvulkan=enabled",
        "-Dshaderc=enabled",
        "-Dlcms=enabled",
        "-Ddovi=enabled",
        "-Dxxhash=disabled",
        "-Dunwind=disabled",
        "-Dglslang=disabled",
        "-Dd3d11=disabled",
        "-Ddemos=false",
        "-Dtests=false",
      ],
    );
    final pkgConfig = context.prefixDir.resolveFile("lib/pkgconfig/libplacebo.pc");
    final newText = pkgConfig
        .readAsLinesSync()
        .map( (it) => it.startsWith("Libs: ") ? "${it} -lc++" : it)
        .join("\n");
    pkgConfig.writeAsStringSync(newText);
  }

}