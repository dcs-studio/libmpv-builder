import '../common.dart';

void autogen(BuildContext context) {
  final file = context.sourcesDir.resolveFile("autogen.sh");
  if ( !file.existsSync() ) return;
  exec(
    workingDir: context.sourcesDir,
    args: [file.absolutePath],
    env: {
      "NOCONFIGURE": "1",
    },
  );
}
