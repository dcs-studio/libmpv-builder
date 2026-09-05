import '../../common/common.dart';
import 'android_build_context.dart';

abstract class AndroidLibraryBuilder extends LibraryBuilder<AndroidBuildContext> {

  const AndroidLibraryBuilder({required this.library});

  @override
  final Library library;

  @override
  Directory get patchesDir => Directory.current.absolute.resolveDir("patches/android");


}