import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/children_named_component.dart';

class SectionPbx extends ChildrenNamedComponent {
  final String name;

  SectionPbx({
    required this.name,
    super.children,
  }) : super(uuid: name, comment: name);

  @override
  String toString({int indentLevel = 0, bool removeN = false}) {
    StringBuffer sb = StringBuffer();
    sb.write('\n/* Begin $name section */\n');
    for (int i = 0; i < childrenList.length; i++) {
      sb.write(childrenList[i].toString(indentLevel: indentLevel));
    }
    sb.write('/* End $name section */\n');
    return sb.toString();
  }

  @override
  SectionPbx copyWith({
    String? name,
    List<NamedComponent>? children,
  }) {
    return SectionPbx(
      name: name ?? this.name,
      children: children ?? childrenList,
    );
  }
}
