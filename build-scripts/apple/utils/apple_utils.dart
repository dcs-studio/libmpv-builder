
import '../../common/common.dart';

extension AppleLibrary on Library {

  bool get canBeShared => switch (this) {
    Library.dav1d    => true,
    Library.dovi     => true,
    Library.ffmpeg   => true,
    Library.freetype => true,
    Library.fribidi  => true,
    Library.harfbuzz => true,
    Library.lcms2    => true,
    Library.ass      => true,
    Library.placebo  => true,
    Library.mbedtls  => false,
    Library.moltenvk => true,
    Library.mpv      => true,
    Library.shaderc  => true,
    Library.uchardet => false,
    Library.unibreak => false,
  };

}

String xcrun({required String sdk, required String arg}) {
  final result = execAndGet(
    workingDir: Directory.current,
    args: ["xcrun", "--sdk", sdk, arg],
  );
  if (result.exitCode != 0) {
    throw "xcrun --sdk $sdk $arg failed (exit ${result.exitCode})";
  }
  return result.stdout.toString().trim();
}
