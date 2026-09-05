import '../../common/common.dart';
import '../android.dart';

class FreetypeBuilder extends AndroidLibraryBuilder {

  const new() : super(library: Library.freetype);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=static",
        "-Dzlib=system",
        "-Dbrotli=disabled",
        "-Dpng=disabled",
        "-Dbzip2=disabled",
        "-Dharfbuzz=disabled",
        "-Dtests=disabled",
      ],
    );
  }

}
