import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class FreetypeBuilder extends AppleLibraryBuilder {

  const new() : super(Library.freetype);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Freetype",
      staticLib: "libfreetype",
      sharedLib: "libfreetype",
      includeSubdir: "freetype2",
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    meson(
      context: context,
      crossfile: appleCrossfile(context),
      arguments: [
        "-Ddefault_library=${context.mesonLibrary}",
        "-Dzlib=enabled",
        "-Dharfbuzz=disabled",
        "-Dbzip2=disabled",
        "-Dmmap=disabled",
        "-Dpng=disabled",
        "-Dbrotli=disabled",
        "-Dtests=disabled",
      ],
    );
  }

}