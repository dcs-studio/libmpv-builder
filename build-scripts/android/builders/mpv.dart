import '../../common/common.dart';
import '../android.dart';

class MpvBuilder extends AndroidLibraryBuilder {

  new() : super(library: Library.mpv);

  @override
  void build({required AndroidBuildContext context}) {
    meson(
      context: context,
      crossfile: androidCrossfile(context),
      arguments: [
        "--default-library", "shared",
        "-Dbuildtype=release",
        "-Dgpl=false",
        "-Dcplayer=false",
        "-Dlibmpv=true",
        "-Dtests=false",
        "-Dbuild-date=false",

        "-Dopensles=disabled",

        "-Dvulkan=disabled",
        "-Dshaderc=disabled",
        "-Dspirv-cross=disabled",

        "-Drubberband=disabled",
        "-Dvapoursynth=disabled",
        "-Dzimg=disabled",

        "-Dcdda=disabled",
        "-Dcplugins=disabled",
        "-Ddvbin=disabled",
        "-Ddvdnav=disabled",
        "-Diconv=disabled",
        "-Duchardet=disabled",
        "-Djavascript=disabled",
        "-Djpeg=disabled",
        "-Dlcms2=disabled",
        "-Dlibarchive=disabled",
        "-Dlibavdevice=disabled",
        "-Dlibbluray=disabled",
        "-Dlua=disabled",

        "-Dhtml-build=disabled",
        "-Dmanpage-build=disabled",
        "-Dpdf-build=disabled",
      ],
    );
  }

}