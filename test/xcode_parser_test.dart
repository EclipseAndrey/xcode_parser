import 'dart:io';

import 'package:test/test.dart';
import 'package:xcode_parser/src/pbxproj/pbxproj_parse.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('Pbxproj.open Tests', () {
    late String tempDirPath;
    late String tempFilePath;

    setUp(() async {
      tempDirPath = Directory.systemTemp.createTempSync().path;
      tempFilePath = '$tempDirPath/project.pbxproj';
    });

    tearDown(() async {
      final tempDir = Directory(tempDirPath);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Open Pbxproj file when file does not exist', () async {
      final pbxproj = await Pbxproj.open(tempFilePath);
      expect(pbxproj.path, tempFilePath);
      expect(pbxproj.childrenList, isEmpty);
    });

    test('Open Pbxproj file when file is empty', () async {
      final file = File(tempFilePath);
      await file.create(recursive: true);
      final pbxproj = await Pbxproj.open(tempFilePath);
      expect(pbxproj.path, tempFilePath);
      expect(pbxproj.childrenList, isEmpty);
    });

    test('Open Pbxproj file with multiple comments', () async {
      final inputContents = '''// !\$*UTF8*\$!
{
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	// !\$*UTF8*\$!
	archiveVersion = 1;
	classes = {};
	objectVersion = 54;
}''';
      final file = File(tempFilePath);
      await file.create(recursive: true);
      await file.writeAsString(inputContents);

      final pbxproj = await Pbxproj.open(tempFilePath);
      await pbxproj.save();

      final outputContents = file.readAsStringSync();
      expect(inputContents, outputContents);
    });

    test('Open Pbxproj file with content', () async {
      final file = File(tempFilePath);
      await file.create(recursive: true);
      await file.writeAsString('''// !\$*UTF8*\$!
      {
        someKey = someValue;
        "string test \$key" = "string "test" \$value";
       // comment
       someKey /* connemt */ = someValue;
       someKey = someValue /* comment */;
      }''');

      final pbxproj = await Pbxproj.open(tempFilePath);
      expect(pbxproj.path, tempFilePath);
      expect(pbxproj.childrenList, isNotEmpty);
    });

    test('Open Pbxproj file and create necessary directories', () async {
      final customDirPath = '$tempDirPath/customDir';
      final customFilePath = '$customDirPath/project.pbxproj';
      final pbxproj = await Pbxproj.open(customFilePath);
      expect(pbxproj.path, customFilePath);
      expect(pbxproj.childrenList, isEmpty);
    });
  });

  group('parsePbxproj Tests', () {
    test('Parse simple PBX content', () {
      final content = '''
      {
        someKey = someValue;
      }
      ''';
      final pbxproj = parsePbxproj(content, '/path/to/project.pbxproj');
      expect(pbxproj.childrenList, isNotEmpty);
      expect((pbxproj.childrenList.first as MapEntryPbx).uuid, 'someKey');
      expect((pbxproj.childrenList.first as MapEntryPbx).value.toString(),
          'someValue');
    });

    test('Parse PBX content with list', () {
      final content = '''
      {
        someList /* comment */     = (
          item1,
          item2 /* comment */,
          /* comment */ item3,
        );
         someList1      =   (
          item1,
          item2 /* comment */,
          /* comment */ item3,
        );
      }
      ''';
      final pbxproj = parsePbxproj(content, '/path/to/project.pbxproj');
      expect(pbxproj.childrenList, isNotEmpty);
      final listPbx = pbxproj.find<ListPbx>('someList');
      expect(listPbx, isNotNull);
      expect(listPbx?.length, 3);

      expect(listPbx![0].value, 'item1');
      expect(listPbx[0].comment, null);

      expect(listPbx[1].value, 'item2');
      expect(listPbx[1].comment, 'comment');

      expect(listPbx[2].value, 'item3');
      expect(listPbx[2].comment, 'comment');
    });

    test('Parse PBX content with nested maps', () {
      final content = '''
      {
      entryKey = entryValue;
        parentMap        = /* comment */ {
        // comment
          childKey = childValue;
      /* Begin PBXSection section */
        sectionKey = sectionValue;
      /* End PBXSection section */
        childMap /* comment */ = {};
      
        };
      }
      ''';

      final projContent = Pbxproj(
        path: '/path/to/project.pbxproj',
        children: [
          MapEntryPbx('entryKey', VarPbx('entryValue')),
          MapPbx(
            uuid: 'parentMap',
            comment: 'comment',
            children: [
              CommentPbx('comment'),
              MapEntryPbx('childKey', VarPbx('childValue')),
              SectionPbx(
                name: 'PBXSection',
                children: [
                  MapEntryPbx('sectionKey', VarPbx('sectionValue')),
                ],
              ),
              MapPbx(
                uuid: 'childMap',
                comment: 'comment',
                children: [],
              ),
            ],
          ),
        ],
      );

      final pbxproj =
          parsePbxproj(content, '/path/to/project.pbxproj', debug: true);
      expect(pbxproj.childrenList, isNotEmpty);

      final parentMap = pbxproj.find<MapPbx>('parentMap');
      expect(parentMap, isNotNull);
      expect(parentMap?.childrenList, isNotEmpty);

      final childMapEntry = parentMap!.find<MapEntryPbx>('childKey');

      expect(childMapEntry, isNotNull);
      expect(childMapEntry!.uuid, 'childKey');
      expect(childMapEntry.value.toString(), 'childValue');

      final section = parentMap.findComment('PBXSection') as SectionPbx;
      expect(section.comment, 'PBXSection');
      expect(section.uuid, 'PBXSection');
      expect(section.name, 'PBXSection');

      final sectionEntry = section.childrenList.first as MapEntryPbx;
      expect(sectionEntry.uuid, 'sectionKey');
      expect(sectionEntry.value.toString(), 'sectionValue');
      expect(projContent.toString(), pbxproj.toString());
    });

    test('Parse PBX content with sections', () {
      final content = '''
      
      {
      /* Begin PBXSection section */
        sectionKey = sectionValue;
      /* End PBXSection section */
      }
      
      ''';
      final pbxproj = parsePbxproj(content, '/path/to/project.pbxproj');
      expect(pbxproj.childrenList, isNotEmpty);
      final section = pbxproj.childrenList.first as SectionPbx;
      final sectionEntry = section.childrenList.first as MapEntryPbx;
      expect(section.name, 'PBXSection');
      expect(sectionEntry.uuid, 'sectionKey');
      expect(sectionEntry.value.toString(), 'sectionValue');
    });
  });
}
