import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';

class UchardetBuilder extends AppleLibraryBuilder {

  const new() : super(Library.uchardet);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Uchardet",
      staticLib: "libuchardet",
      sharedLib: "libuchardet",
      includeSubdir: "uchardet",
      modular: true,
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    cmake(
      context: context,
      arguments: [
        "-DBUILD_SHARED_LIBS=${context.buildShared ? "ON" : "OFF"}",
        "-DBUILD_STATIC=${context.buildShared? "OFF" : "ON"}",
        "-DBUILD_BINARY=OFF"
      ],
    );
    make(context);
  }

}