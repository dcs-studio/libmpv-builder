import '../../common/common.dart';
import '../android.dart';

class FribidiBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.fribidi);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=static",
        "-Dtests=false",
        "-Ddocs=false",
        "-Dbin=false",
        "-Ddeprecated=false",
      ],
    );
  }

}
