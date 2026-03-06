import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/children_named_component.dart';
import 'package:xcode_parser/src/pbxproj/map/map_entry_pbx.dart';
import 'package:xcode_parser/src/pbxproj/pbxproj.dart';

class MapPbx extends ChildrenNamedComponent {
  MapPbx({
    super.children,
    required super.uuid,
    super.comment,
  });

  @override
  String toString({int indentLevel = 0, bool removeN = false}) {
    final allEntry = childrenList.every((test) => test is MapEntryPbx);

    String indent = Pbxproj.indent(indentLevel);
    String commentOut = comment != null ? ' /* $comment */' : '';
    final sb = StringBuffer();
    final n = allEntry ? '' : '\n';
    sb.write('$indent$uuid$commentOut = {$n');
    sb.write(super.toString(indentLevel: indentLevel, removeN: allEntry));
    sb.write('${allEntry ? '' : indent}};${removeN ? ' ' : '\n'}');
    return sb.toString();
  }

  @override
  MapPbx copyWith({
    String? uuid,
    List<NamedComponent>? children,
    String? comment,
  }) {
    return MapPbx(
      uuid: uuid ?? this.uuid,
      children: children ?? childrenList,
      comment: comment ?? this.comment,
    );
  }
}
