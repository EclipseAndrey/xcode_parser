import 'dart:io';

import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('Pbxproj Tests', () {
    late Pbxproj pbxproj;
    late MapPbx component;
    late String tempFilePath;

    setUp(() async {
      tempFilePath = 'test_project.pbxproj';
      pbxproj = Pbxproj(path: tempFilePath);
      component = MapPbx(
        uuid: '123',
        children: [
          MapEntryPbx('name', VarPbx('TestComponent')),
        ],
        comment: 'TestComment',
      );
    });

    tearDown(() async {
      if (await File(tempFilePath).exists()) {
        await File(tempFilePath).delete();
      }
    });

    test('Open Pbxproj file', () async {
      final file = File(tempFilePath);
      await file.writeAsString('// !\$*UTF8*\$!\n{\n // !\$*UTF8*\$!\n}');
      final openedProject = await Pbxproj.open(tempFilePath);
      expect(openedProject.path, tempFilePath);

      expect(
          openedProject.childrenList.toString(),
          [
            CommentPbx('!\$*UTF8*\$!'),
          ].toString());
    });

    test('Open Pbxproj file from string', () {
      final openedProject = Pbxproj.parse(
          '// !\$*UTF8*\$!\n{\n // !\$*UTF8*\$!\n}',
          path: tempFilePath);
      expect(openedProject.path, tempFilePath);

      expect(
          openedProject.childrenList.toString(),
          [
            CommentPbx('!\$*UTF8*\$!'),
          ].toString());
    });

    test('Save Pbxproj file', () async {
      await pbxproj.save();
      final file = File(tempFilePath);
      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content.contains('// !\$*UTF8*\$!\n{\n}'), isTrue);
    });

    test('Add NamedComponent', () {
      pbxproj.add(component);
      expect(pbxproj.childrenList, contains(component));
      expect(pbxproj.childrenMap[component.uuid], component);
    });

    test('Remove NamedComponent by UUID', () {
      pbxproj.add(component);
      pbxproj.remove(component.uuid);
      expect(pbxproj.childrenList, isNot(contains(component)));
      expect(pbxproj.childrenMap[component.uuid], isNull);
    });

    test('Replace or Add NamedComponent', () {
      pbxproj.add(component);
      final newComponent = MapPbx(
        uuid: '123',
        children: [
          MapEntryPbx('name', VarPbx('NewComponent')),
        ],
        comment: 'NewComment',
      );
      pbxproj.replaceOrAdd(newComponent);
      expect(pbxproj.childrenList, contains(newComponent));
      expect(pbxproj[component.uuid], newComponent);
    });

    test('Find NamedComponent by UUID', () {
      pbxproj.add(component);
      final foundComponent = pbxproj.find<MapPbx>('123');
      expect(foundComponent, component);
    });

    test('Find NamedComponent by Comment', () {
      pbxproj.add(component);
      final foundComponent = pbxproj.findComment<MapPbx>('TestComment');
      expect(foundComponent, component);
    });

    test('Generate unique UUID', () {
      final uuid = pbxproj.generateUuid();
      final uuid2 = pbxproj.generateUuid();
      expect(uuid, isNot(uuid2));
      expect(uuid, isNotNull);
      expect(uuid.length, 24);
    });

    test('String representation', () {
      final str = pbxproj.toString();
      expect(str.contains('// !\$*UTF8*\$!\n{\n}'), isTrue);
    });

    test('CopyWith method', () {
      pbxproj.add(component);
      final newComponent = MapPbx(
        uuid: '456',
        children: [
          MapEntryPbx('name', VarPbx('NewComponent')),
        ],
        comment: 'NewComment',
      );
      final newPath = 'new_test_project.pbxproj';
      final copiedPbxproj = pbxproj.copyWith(
        children: [newComponent],
        path: newPath,
      );

      expect(copiedPbxproj.path, newPath);
      expect(copiedPbxproj.childrenList, contains(newComponent));
      expect(copiedPbxproj.childrenMap[newComponent.uuid], newComponent);
      expect(copiedPbxproj.childrenList, isNot(contains(component)));
      expect(copiedPbxproj.childrenMap[component.uuid], isNull);
    });
  });
}
