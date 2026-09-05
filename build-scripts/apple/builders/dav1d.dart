import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../utils/apple_crossfile.dart';

class Dav1dBuilder extends AppleLibraryBuilder {

  const new() : super(Library.dav1d);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Dav1d",
      staticLib: "libdav1d",
      sharedLib: "libdav1d",
      includeSubdir: "dav1d",
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
        "-Denable_asm=false",
        "-Denable_tests=false",
        "-Denable_tools=false",
        "-Dxxhash_muxer=disabled",
      ],
    );
  }

}