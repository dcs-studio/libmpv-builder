
import '../common.dart';

final class Crossfile {

  final Map<String, Map<String, String>> data;

  const Crossfile(this.data);

  void writeTo(File destination) {
    if ( destination.existsSync() ) {
      destination.deleteSync();
    }
    destination.parent.mkdirs();
    destination.createSync();
    for (final entry in data.entries) {
      destination.writeAsStringSync("[${entry.key}]", mode: FileMode.writeOnlyAppend);
      destination.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
      for (final subEntry in entry.value.entries) {
        final isArray = subEntry.value.startsWith('[') && subEntry.value.endsWith(']');
        if (isArray) {
          destination.writeAsStringSync("${subEntry.key} = ${subEntry.value}", mode: FileMode.writeOnlyAppend);
        } else {
          destination.writeAsStringSync("${subEntry.key} = '${subEntry.value}'", mode: FileMode.writeOnlyAppend);
        }
        destination.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
      }
      destination.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
      destination.writeAsStringSync("\n", mode: FileMode.writeOnlyAppend);
    }
  }

}
