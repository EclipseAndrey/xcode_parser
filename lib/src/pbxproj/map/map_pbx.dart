import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/children_named_component.dart';
import 'package:xcode_parser/src/pbxproj/pbxproj.dart';

class MapPbx extends ChildrenNamedComponent {
  bool isInline;

  MapPbx({
    super.children,
    required super.uuid,
    super.comment,
    this.isInline = false,
  });

  @override
  String toString({int indentLevel = 0, bool removeN = false}) {
    String indent = Pbxproj.indent(indentLevel);
    String commentOut = comment != null ? ' /* $comment */' : '';
    final sb = StringBuffer();
    if (isInline) {
      sb.write('$indent$uuid$commentOut = {');
      sb.write(super.toString(indentLevel: indentLevel, removeN: true));
      sb.write('};\n');
    } else {
      sb.write('$indent$uuid$commentOut = {\n');
      sb.write(super.toString(indentLevel: indentLevel));
      sb.write('$indent};\n');
    }
    return sb.toString();
  }

  @override
  MapPbx copyWith({
    String? uuid,
    List<NamedComponent>? children,
    String? comment,
    bool? isInline,
  }) {
    return MapPbx(
      uuid: uuid ?? this.uuid,
      children: children ?? childrenList,
      comment: comment ?? this.comment,
      isInline: isInline ?? this.isInline,
    );
  }
}
