import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('MapPbx Tests', () {
    late MapPbx mapPbx;
    late MapEntryPbx<VarPbx> component;

    setUp(() {
      component = MapEntryPbx(
        'isa',
        VarPbx('PBXGroup'),
        comment: 'Sources',
      );
      mapPbx = MapPbx(uuid: 'AA11BB22CC33DD44EE55FF66');
    });

    test('Add NamedComponent', () {
      mapPbx.add(component);
      expect(mapPbx.childrenList, contains(component));
      expect(mapPbx.childrenMap[component.uuid], component);
    });

    test('Remove NamedComponent by UUID', () {
      mapPbx.add(component);
      mapPbx.remove(component.uuid);
      expect(mapPbx.childrenList, isNot(contains(component)));
      expect(mapPbx.childrenMap[component.uuid], isNull);
    });

    test('Replace or Add NamedComponent', () {
      mapPbx.add(component);
      final newComponent = MapEntryPbx(
        'name',
        VarPbx('Products'),
        comment: 'Products',
      );
      mapPbx.replaceOrAdd(newComponent);
      expect(mapPbx[newComponent.uuid], newComponent);

      final updated = newComponent.copyWith(
        value: VarPbx('Frameworks'),
      );

      mapPbx.replaceOrAdd(updated);
      expect(mapPbx[newComponent.uuid], updated);
    });

    test('Find NamedComponent by UUID', () {
      mapPbx.add(component);
      final found = mapPbx.find<MapEntryPbx<VarPbx>>('isa');
      expect(found, component);
    });

    test('Find NamedComponent by Comment', () {
      mapPbx.add(component);
      final found = mapPbx.findComment<MapEntryPbx<VarPbx>>('Sources');
      expect(found, component);
    });

    test('String representation multiline', () {
      mapPbx.add(component);
      final str = mapPbx.toString();
      expect(str.contains('AA11BB22CC33DD44EE55FF66 = {'), isTrue);
      expect(str.contains('isa = PBXGroup /* Sources */;'), isTrue);
      expect(str.contains('};'), isTrue);
    });

    test('String representation inline', () {
      final inlineMap = MapPbx(
        uuid: 'BB22CC33DD44EE55FF660011',
        comment: 'main.swift in Sources',
        isInline: true,
        children: [
          MapEntryPbx('isa', VarPbx('PBXBuildFile')),
          MapEntryPbx('fileRef', VarPbx('CC33DD44EE55FF6600112233'),
              comment: 'main.swift'),
        ],
      );
      final str = inlineMap.toString();
      expect(str.contains('\n\n'), isFalse);
      expect(str.startsWith('BB22CC33DD44EE55FF660011 /* main.swift in Sources */ = {'), isTrue);
      expect(str.trimRight().endsWith('};'), isTrue);
    });

    test('CopyWith method', () {
      mapPbx.add(component);
      final newComponent = MapEntryPbx(
        'path',
        VarPbx('Sources'),
      );
      final copied = mapPbx.copyWith(
        uuid: 'CC33DD44EE55FF6600112233',
        children: [newComponent],
      );

      expect(copied.uuid, 'CC33DD44EE55FF6600112233');
      expect(copied.childrenList, contains(newComponent));
      expect(copied.childrenMap[newComponent.uuid], newComponent);
      expect(copied.childrenList, isNot(contains(component)));
      expect(copied.childrenMap[component.uuid], isNull);
    });

    test('CopyWith isInline', () {
      final copied = mapPbx.copyWith(isInline: true);
      expect(copied.isInline, isTrue);
    });
  });
}
