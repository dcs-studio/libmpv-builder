import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class AssBuilder extends AppleLibraryBuilder {

  const new() : super(Library.ass);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Ass",
      staticLib: "libass",
      sharedLib: "libass",
      includeSubdir: "ass",
      modular: true,
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
        "-Dlibunibreak=enabled",
        "-Dcoretext=enabled",
        "-Dfontconfig=disabled",
        "-Ddirectwrite=disabled",
        "-Dasm=disabled",
        "-Dcheckasm=disabled",
        "-Dtest=disabled",
        "-Dprofile=disabled",
        "-Dcompare=disabled",
        "-Dfuzz=disabled",
      ]
    );
  }

}