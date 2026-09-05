import 'versions.dart';

enum Library {
  
  mbedtls(
    version: Versions.MBEDTLS,
    url    : "https://github.com/Mbed-TLS/mbedtls.git",
    args   : ["--recurse-submodules"],
  ),

  dav1d(
    version: Versions.DAV1D,
    url    : "https://code.videolan.org/videolan/dav1d.git",
  ),

  ffmpeg(
    version: Versions.FFMPEG,
    url    : "https://github.com/FFmpeg/FFmpeg.git",
  ),

  freetype(
    version: Versions.FREETYPE,
    url    : "https://gitlab.freedesktop.org/freetype/freetype.git",
  ),

  fribidi(
    version: Versions.FRIBIDI,
    url    : "https://github.com/fribidi/fribidi.git",
  ),

  harfbuzz(
    version: Versions.HARFBUZZ,
    url    : "https://github.com/harfbuzz/harfbuzz.git",
  ),

  ass(
    version: Versions.ASS,
    url    : "https://github.com/libass/libass.git",
  ),

  placebo(
    version: Versions.PLACEBO,
    url    : "https://code.videolan.org/videolan/libplacebo.git",
    args   : ["--recurse-submodules"],
  ),

  mpv(
    version: Versions.MPV,
    url    : "https://github.com/mpv-player/mpv.git",
  ),

  uchardet(
    version: Versions.UCHARDET,
    url    : "https://gitlab.freedesktop.org/uchardet/uchardet.git",
  ),

  lcms2(
    version: Versions.LCMS2,
    url    : "https://github.com/mm2/Little-CMS.git",
  ),

  unibreak(
    version: Versions.UNIBREAK,
    url    : "https://github.com/adah1972/libunibreak.git",
  ),

  shaderc(
    version: Versions.SHADERC,
    url    : "https://github.com/google/shaderc.git",
  ),

  moltenvk(
    version: Versions.MOLTENVK,
    url    : "https://github.com/KhronosGroup/MoltenVK.git",
  ),

  dovi(
    version: Versions.DOVI,
    url    : "https://github.com/quietvoid/dovi_tool.git",
  );
  
  final String version;
  final String url;
  final List<String> args;
  
  const Library({required this.version, required this.url, this.args = const []});

}