import '../../common/common.dart';
import '../android.dart';

class HarfbuzzBuilder extends AndroidLibraryBuilder {

  const new() : super(library: Library.harfbuzz);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=static",
        "-Dbuildtype=release",
        "-Dglib=disabled",
        "-Dfreetype=enabled",
        "-Dcairo=disabled",
        "-Dsubset=disabled",
        "-Dgpu=disabled",
        "-Draster=disabled",
        "-Dvector=disabled",
        "-Ddocs=disabled",
        "-Dtests=disabled",
        "-Dutilities=disabled",
        "-Dintrospection=disabled",
        "-Dicu=disabled",
        "-Dpng=disabled",
        "-Dzlib=disabled",
        "-Dchafa=disabled",
        "-Dgobject=disabled",
      ],
    );
  }

}
