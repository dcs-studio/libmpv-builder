import "../common.dart";

abstract class LibraryBuilder<C extends BuildContext> {

  const LibraryBuilder();

  abstract final Library library;
  abstract final Directory patchesDir;

  void fetchSources({required C context}) {
    clone(
      destination: context.sourcesDir,
      library: library,
      patchesDir: patchesDir
    );
  }

  void build({required C context});

}
