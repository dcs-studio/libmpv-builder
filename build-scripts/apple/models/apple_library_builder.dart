import '../../common/common.dart';
import '../utils/apple_utils.dart';
import '../utils/framework_assembler.dart';
import 'apple_build_context.dart';
import 'apple_framework.dart';
import 'apple_target.dart';

abstract class const AppleLibraryBuilder(final Library library) extends LibraryBuilder<AppleBuildContext> {

  @override
  Directory get patchesDir => Directory.current.absolute.resolveDir("patches/apple");

  abstract final List<AppleFramework> frameworks;

  void assembleFramework({
    required LinkType link,
    required List<AppleTarget> targets,
  }) {
    if (link == LinkType.shared && !library.canBeShared) return;
    if (frameworks.isEmpty) return;
    this.assembleFrameworks(link, targets);
  }

}