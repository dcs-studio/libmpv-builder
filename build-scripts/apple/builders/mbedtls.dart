import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';

class MbedtlsBuilder extends AppleLibraryBuilder {

  const new() : super(Library.mbedtls);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Mbedtls",
      staticLib: "libmbedtls",
      sharedLib: "libmbedtls",
      includeEntries: ["mbedtls", "psa"],
    ),
    AppleFramework(
      name: "Mbedx509",
      staticLib: "libmbedx509",
      sharedLib: "libmbedx509",
    ),
    AppleFramework(
      name: "Mbedcrypto",
      staticLib: "libmbedcrypto",
      sharedLib: "libmbedcrypto",
    ),
  ];

  @override
  void build({required AppleBuildContext context}) {
    cmake(
      context: context,
      arguments: [
        "-DUSE_SHARED_MBEDTLS_LIBRARY=OFF",
        "-DUSE_STATIC_MBEDTLS_LIBRARY=ON",
        "-DENABLE_PROGRAMS=OFF",
        "-DENABLE_TESTING=OFF",
      ],
    );
    make(context);
  }

}