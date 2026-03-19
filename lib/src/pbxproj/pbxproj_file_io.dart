import 'dart:io' as io;

Future<String> readFileContent(String path) async {
  final file = io.File(path);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  return file.readAsString();
}

Future<void> writeFileContent(String path, String content) async {
  final file = io.File(path);
  if (!await file.exists()) {
    await file.create();
  }
  await file.writeAsString(content);
}
