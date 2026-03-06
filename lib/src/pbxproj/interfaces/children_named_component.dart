import 'dart:collection';

import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/children_mixin.dart';

abstract class ChildrenNamedComponent extends NamedComponent with ChildrenMixin {
  final List<NamedComponent> _childrenList;
  final HashMap<String, NamedComponent> _childrenMap;

  @override
  List<NamedComponent> get childrenList => _childrenList;
  @override
  HashMap<String, NamedComponent> get childrenMap => _childrenMap;

  ChildrenNamedComponent({
    List<NamedComponent> children = const [],
    required super.uuid,
    super.comment,
  })  : _childrenList = List<NamedComponent>.from(children),
        _childrenMap = HashMap.fromIterable(
          children,
          key: (e) => e.uuid,
        );

  @override
  String toString({int indentLevel = 0, bool removeN = false}) =>
      childrenToString(childrenList,
          indentLevel: indentLevel, removeN: removeN);
}
