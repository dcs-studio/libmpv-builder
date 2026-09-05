import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class HarfbuzzBuilder extends AppleLibraryBuilder {

  const new() : super(Library.harfbuzz);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Harfbuzz",
      staticLib: "libharfbuzz",
      sharedLib: "libharfbuzz",
      includeSubdir: "harfbuzz",
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
        "-Dglib=disabled",
        "-Dfreetype=enabled",
        "-Dcairo=disabled",
        "-Dsubset=disabled",
        "-Dgpu=disabled",
        "-Draster=disabled",
        "-Dvector=disabled",
        "-Ddocs=disabled",
      ],
    );
  }

}