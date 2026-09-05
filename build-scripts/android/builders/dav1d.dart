import '../../common/common.dart';
import '../android.dart';

class Dav1dBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.dav1d);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context:   context,
      crossfile: androidCrossfile(context),
      arguments: [
        "-Ddefault_library=shared",
        "-Denable_tests=false",
        "-Denable_tools=false",
        "-Db_lto=true",
        "-Dstack_alignment=16",
      ],
    );
  }

}