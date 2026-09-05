import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class Lcms2Builder extends AppleLibraryBuilder {

  const new() : super(Library.lcms2);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Lcms2",
      staticLib: "liblcms2",
      sharedLib: "liblcms2",
      includeEntries: ["lcms2.h", "lcms2_plugin.h"],
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
        "-Djpeg=disabled",
        "-Dtiff=disabled",
      ],
    );
  }

}