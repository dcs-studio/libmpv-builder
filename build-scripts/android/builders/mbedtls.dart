import '../../common/common.dart';
import '../android.dart';

class MbedtlsBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.mbedtls);

  @override
  void build({required AndroidBuildContext context}) {
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