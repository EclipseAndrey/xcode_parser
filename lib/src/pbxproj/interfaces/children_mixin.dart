import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';

mixin ChildrenMixin on PbxprojComponent {
  List<NamedComponent> get childrenList;
  HashMap<String, NamedComponent> get childrenMap;

  /// The universal [find] method takes a [String]
  /// key and returns an instance of type [T] that extends [NamedComponent], or
  /// [null] if not found.
  T? find<T extends NamedComponent>(String key) =>
      childrenList.firstWhereOrNull((test) => test.uuid == key && test is T)
          as T?;

  /// [findComment] is a method that searches for a component of
  /// type [T] that extends [NamedComponent] based on a given [comment] string.
  /// It returns the found component or null if not found.
  T? findComment<T extends NamedComponent>(String comment) =>
      childrenList.firstWhereOrNull(
              (test) => (test.comment?.contains(comment) ?? false) && test is T)
          as T?;

  /// [add] is a method that adds a new [NamedComponent] to the list of children
  /// and updates the mapping of children by associating the component's UUID
  /// with the component itself.
  void add(NamedComponent component) {
    childrenList.add(component);
    childrenMap[component.uuid] = component;
  }

  /// [remove] is a method that removes a [NamedComponent] from the list of children
  /// based on the component's UUID. It also removes the mapping of
  /// the component from the children map.
  void remove(String uuid) {
    childrenList.removeWhere((test) => test.uuid == uuid);
    childrenMap.remove(uuid);
  }

  /// [replaceOrAdd] replaces an existing [NamedComponent] in the list of children
  /// with a new component if it already exists, or adds a new component to the list.
  ///
  /// If a component with the same UUID already exists in the list of children,
  /// it is replaced with the new component. Otherwise, the new component is added.
  void replaceOrAdd(NamedComponent component) {
    childrenMap[component.uuid] = component;
    final indexInList =
        childrenList.indexWhere((test) => test.uuid == component.uuid);
    if (indexInList == -1) {
      childrenList.add(component);
    } else {
      childrenList[indexInList] = component;
    }
  }

  /// The [] operator allows accessing a [NamedComponent] from the list of children
  /// based on its UUID. Returns the corresponding [NamedComponent] if found, or null.
  ///
  /// ```dart
  /// NamedComponent? component = component[uuid];
  /// ```
  NamedComponent? operator [](String key) => childrenMap[key];
}
