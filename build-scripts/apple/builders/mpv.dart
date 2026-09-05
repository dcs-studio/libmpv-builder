import '../../common/common.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';
import '../models/apple_platform.dart';
import '../utils/apple_crossfile.dart';

class MpvBuilder extends AppleLibraryBuilder {

  const new() : super(Library.mpv);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Mpv",
      staticLib: "libmpv",
      sharedLib: "libmpv",
      includeSubdir: "mpv",
      modular: true,
    ),
  ];

  List<String> platformArguments(AppleBuildContext context) {
    return switch (context.target.platform) {
      ApplePlatform.macos => [
        "-Dgl-cocoa=enabled",
        "-Dcocoa=enabled",
        "-Dswift-build=enabled",
        "-Dswift-flags=-target ${context.target.clangTarget}",
        "-Dcoreaudio=enabled",
        "-Dvideotoolbox-gl=enabled",
        "-Dmacos-touchbar=disabled",
        "-Dmacos-media-player=disabled",
      ],
      ApplePlatform.ios || ApplePlatform.iossim => [
        "-Dios-gl=enabled",
        "-Dcoreaudio=disabled",
        "-Dvideotoolbox-gl=disabled",
        "-Daudiounit=enabled",
        "-Dcocoa=disabled",
        "-Dswift-build=disabled",
      ],
    };
  }

  @override
  void build({required AppleBuildContext context}) {
    meson(
      context: context,
      crossfile: appleCrossfile(context),
      arguments: [
        "-Ddefault_library=${context.mesonLibrary}",
        "-Dbuildtype=release",
        "-Dlibmpv=true",
        "-Dgpl=false",
        "-Dcplayer=false",
        "-Dtests=false",
        "-Dgl=enabled",
        "-Dplain-gl=enabled",
        "-Dvulkan=enabled",
        "-Dmoltenvk=enabled",
        "-Duchardet=enabled",
        "-Diconv=enabled",
        "-Dvo-avfoundation=enabled",
        "-Davfoundation=enabled",
        "-Dvideotoolbox-pl=enabled",
        ...platformArguments(context),
        "-Dlua=disabled",
        "-Dcdda=disabled",
        "-Dcplugins=disabled",
        "-Ddvbin=disabled",
        "-Ddvdnav=disabled",
        "-Djavascript=disabled",
        "-Djpeg=disabled",
        "-Dlcms2=disabled",
        "-Dlibarchive=disabled",
        "-Dlibavdevice=disabled",
        "-Dlibbluray=disabled",
        "-Dhtml-build=disabled",
        "-Dmanpage-build=disabled",
        "-Dpdf-build=disabled",
      ],
    );
  }

}