import 'dart:math';

import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/children_component.dart';
import 'package:xcode_parser/src/pbxproj/pbxproj_parse.dart';

import 'pbxproj_file_stub.dart'
    if (dart.library.io) 'pbxproj_file_io.dart';

class Pbxproj extends ChildrenComponent {
  final String path;

  /// This is a static method in Dart that takes an
  /// [indentLevel] as an argument and returns a string of spaces
  /// equal to the indentLevel multiplied by 4.
  /// This is commonly used to create indentation in code for readability.
  static String indent(int indentLevel) => '	' * (indentLevel);

  Pbxproj({
    super.children,
    required this.path,
  });

  /// Parses a [Pbxproj] file's [content]
  ///
  /// An empty [Pbxproj] is created if [content] is empty.
  factory Pbxproj.parse(String content, {String path = "project.pbxproj"}) {
    if (content.isEmpty) {
      return Pbxproj(path: path);
    }
    return parsePbxproj(content, path, debug: false);
  }

  @override
  String toString({int indentLevel = 0, bool removeN = false}) {
    String indent = Pbxproj.indent(indentLevel);
    StringBuffer sb = StringBuffer();
    sb.write('// !\$*UTF8*\$!\n');
    sb.write('$indent{\n');
    sb.write(super.toString(indentLevel: indentLevel));
    sb.write('$indent}\n');
    return sb.toString();
  }

  @override
  Pbxproj copyWith({
    List<NamedComponent>? children,
    String? path,
  }) {
    return Pbxproj(
      children: children ?? childrenList,
      path: path ?? this.path,
    );
  }

  /// [open] is a static method in Dart that takes a [path] as an argument
  /// and returns a [Future] that resolves to a [Pbxproj] object.
  ///
  /// It first creates a [File] object from the [path] provided.
  /// Then it reads the content of the file as a string using `readAsString()`.
  /// If the content is empty, it returns a new [Pbxproj] object with the provided [path].
  ///
  /// If the content is not empty, it calls the [parsePbxproj]
  /// function with the content, the path, and [debug] : false as arguments.
  /// The [parsePbxproj] function is likely a custom function that parses
  /// the content of the file and returns a [Pbxproj] object.
  ///
  /// Throws [UnsupportedError] on Web and WASM platforms.
  /// Use [Pbxproj.parse] for platform-independent parsing.
  static Future<Pbxproj> open(String path) async {
    final content = await readFileContent(path);
    if (content.isEmpty) {
      return Pbxproj(path: path);
    }
    return parsePbxproj(content, path, debug: false);
  }

  /// [save] defines a save method in the [Pbxproj] class.
  /// It creates a [File] object from a specified [path] and writes
  /// the result of calling the [toString] method into the file asynchronously.
  ///
  /// Throws [UnsupportedError] on Web and WASM platforms.
  Future<void> save() async {
    await writeFileContent(path, formatOutput(toString()));
  }

  /// The [generateUuid] method generates a unique identifier (UUID) by
  /// randomly selecting characters from a predefined string. It uses the
  /// [Random] class to generate random indices and selects the corresponding
  /// characters from the [chars] string. The generated UUID is then passed to
  /// the [_checkUuid] method.
  ///
  /// The [_checkUuid] method checks if the generated UUID already exists
  /// in the content of the [Pbxproj] object. If it does, it recursively calls
  /// [generateUuid] to generate a new UUID. If the UUID is unique, it is returned.
  String generateUuid() {
    const chars = '0123456789ABCDEF';
    final rand = Random();
    final uuid =
        List.generate(24, (index) => chars[rand.nextInt(chars.length)]).join();
    return _checkUuid(uuid);
  }

  String _checkUuid(String uuid) {
    final content = toString();
    if (content.contains(uuid)) {
      return generateUuid();
    } else {
      return uuid;
    }
  }
}
