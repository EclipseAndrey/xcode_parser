Future<String> readFileContent(String path) async {
  throw UnsupportedError(
    'Pbxproj.open() is not supported on this platform. '
    'Use Pbxproj.parse() instead.',
  );
}

Future<void> writeFileContent(String path, String content) async {
  throw UnsupportedError(
    'Pbxproj.save() is not supported on this platform.',
  );
}
