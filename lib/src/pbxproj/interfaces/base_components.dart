abstract class PbxprojComponent {
  String formatOutput(String output) {
    return output.replaceAll(RegExp(r'\n+'), '\n');
  }

  @override
  String toString({int indentLevel = 0, bool removeN = false});

  PbxprojComponent copyWith();

  String childrenToString(List<NamedComponent> children,
      {int indentLevel = 0, bool removeN = false}) {
    final sb = StringBuffer();
    for (int i = 0; i < children.length; i++) {
      sb.write(children[i].toString(
          indentLevel: removeN ? 0 : (indentLevel + 1), removeN: removeN));
    }
    return sb.toString();
  }
}

abstract class NamedComponent extends PbxprojComponent {
  final String? comment;
  final String uuid;
  NamedComponent({required this.uuid, this.comment});
}
