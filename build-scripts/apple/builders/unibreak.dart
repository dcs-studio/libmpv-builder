import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';

class UnibreakBuilder extends AppleLibraryBuilder {

  const new() : super(Library.unibreak);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Unibreak",
      staticLib: "libunibreak",
      sharedLib: "libunibreak",
      includeEntries: [
        "eastasianwidthdef.h",
        "graphemebreak.h",
        "linebreak.h",
        "linebreakdef.h",
        "unibreakbase.h",
        "unibreakdef.h",
        "wordbreak.h",
      ],
      modular: true,
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    autogen(context);
    configure(
      context: context,
      environment: context.configureTaskEnv,
      arguments: [
        ...context.buildShared ? ["--enable-shared", "--disable-static"] : ["--enable-static", "--disable-shared"],
        "--disable-fast-install",
        "--disable-dependency-tracking",
        "--host=${context.target.makeHostTriplet}",
      ],
    );
    make(context);
  }

}