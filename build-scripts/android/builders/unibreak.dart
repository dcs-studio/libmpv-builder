import '../../common/common.dart';
import '../android.dart';

class UnibreakBuilder extends AndroidLibraryBuilder {

  const UnibreakBuilder() : super(library: Library.unibreak);

  @override
  void build({required AndroidBuildContext context}) {
    autogen(context);
    configure(
      context: context,
      environment: context.configureTaskEnv,
      arguments: [
        "--disable-shared",
        "--enable-static",
        "--disable-fast-install",
        "--disable-dependency-tracking",
        "--host=${context.abi.ndkTriple}",
      ],
    );
    make(context);

  }
}