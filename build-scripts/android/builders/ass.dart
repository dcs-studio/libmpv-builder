import '../../common/common.dart';
import '../android.dart';

class AssBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.ass);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=shared",
        "-Dbuildtype=release",
        "-Dtest=disabled",
        context.abi == AndroidAbi.arm64 ? "-Dasm=enabled" : "-Dasm=disabled",
        "-Dlibunibreak=enabled",
        "-Dfontconfig=disabled",
        "-Drequire-system-font-provider=false",
        "-Dlarge-tiles=true",
        "-Db_pie=false",
      ],
    );
  }

}
