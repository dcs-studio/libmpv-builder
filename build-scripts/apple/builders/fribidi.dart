import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class FribidiBuilder extends AppleLibraryBuilder {

  const new() : super(Library.fribidi);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Fribidi",
      staticLib: "libfribidi",
      sharedLib: "libfribidi",
      includeSubdir: "fribidi",
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    meson(
      context: context,
      crossfile: appleCrossfile(context),
      arguments: [
        "-Ddefault_library=${context.mesonLibrary}",
        "-Dtests=false",
        "-Ddocs=false",
        "-Dbin=false",
        "-Ddeprecated=false",
      ],
    );
  }

}