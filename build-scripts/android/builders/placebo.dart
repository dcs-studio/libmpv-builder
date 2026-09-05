import '../../common/common.dart';
import '../android.dart';

class PlaceboBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.placebo);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=static",
        "-Dbuildtype=release",
        "-Dvulkan=disabled",
        "-Ddemos=false",
        "-Dtests=false",
        "-Dunwind=disabled",
        "-Dglslang=disabled",
        "-Dshaderc=disabled",
        "-Dd3d11=disabled",
        "-Dlcms=disabled",
        "-Dxxhash=disabled",
      ],
    );
    final pkgConfig = context.prefixDir.resolveFile("lib/pkgconfig/libplacebo.pc");
    final newText = pkgConfig.readAsLinesSync()
      .map( (it) => it.startsWith("Libs: ") ? "${it} -lc++" : it)
      .join("\n");
    pkgConfig.writeAsStringSync(newText);
  }

}
