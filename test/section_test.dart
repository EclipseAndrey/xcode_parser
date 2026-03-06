import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('SectionPbx Tests', () {
    late SectionPbx section;
    late MapEntryPbx<VarPbx> component;

    setUp(() {
      component = MapEntryPbx(
        'isa',
        VarPbx('PBXBuildFile'),
        comment: 'Sources',
      );
      section = SectionPbx(name: 'PBXBuildFile');
    });

    test('Add NamedComponent', () {
      section.add(component);
      expect(section.childrenList, contains(component));
      expect(section.childrenMap[component.uuid], component);
    });

    test('Remove NamedComponent by UUID', () {
      section.add(component);
      section.remove(component.uuid);
      expect(section.childrenList, isNot(contains(component)));
      expect(section.childrenMap[component.uuid], isNull);
    });

    test('Replace or Add NamedComponent', () {
      section.add(component);
      final newComponent = MapEntryPbx(
        'isa',
        VarPbx('PBXFileReference'),
        comment: 'References',
      );
      section.replaceOrAdd(newComponent);
      expect(section.childrenList, contains(newComponent));
      expect(section.childrenMap[component.uuid], newComponent);
    });

    test('Find NamedComponent by UUID', () {
      section.add(component);
      final found = section.find<MapEntryPbx<VarPbx>>('isa');
      expect(found, component);
    });

    test('Find NamedComponent by Comment', () {
      section.add(component);
      final found = section.findComment<MapEntryPbx<VarPbx>>('Sources');
      expect(found, component);
    });

    test('String representation', () {
      section.add(component);
      final str = section.toString();
      expect(str.contains('/* Begin PBXBuildFile section */'), isTrue);
      expect(str.contains('isa = PBXBuildFile /* Sources */;'), isTrue);
      expect(str.contains('/* End PBXBuildFile section */'), isTrue);
    });

    test('CopyWith method', () {
      section.add(component);
      final newComponent = MapEntryPbx(
        'fileRef',
        VarPbx('AA11BB22CC33DD44EE55FF66'),
        comment: 'AppDelegate.swift',
      );
      final copied = section.copyWith(
        name: 'PBXFileReference',
        children: [newComponent],
      );

      expect(copied.name, 'PBXFileReference');
      expect(copied.childrenList, contains(newComponent));
      expect(copied.childrenMap[newComponent.uuid], newComponent);
      expect(copied.childrenList, isNot(contains(component)));
      expect(copied.childrenMap[component.uuid], isNull);
    });
  });
}
