
class AppleFramework ({
  required final String name,
  required final String staticLib,
  required final String sharedLib,
  final List<String> sharedAliases = const [],
  final String? includeSubdir = null,
  final List<String> includeEntries = const [],
  final Set<String> deniedHeaders = const {},
  final bool modular = false,
});
