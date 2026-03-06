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

    test('Open Pbxproj file with content', () async {
      final file = File(tempFilePath);
      await file.create(recursive: true);
      await file.writeAsString('// !\$*UTF8*\$!\n'
          '{\n'
          '\tarchiveVersion = 1;\n'
          '\tobjectVersion = 54;\n'
          '}\n');

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
    test('Parse simple entry', () {
      final content = '{\n'
          '\tarchiveVersion = 1;\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      expect(pbxproj.childrenList, isNotEmpty);
      final entry = pbxproj.childrenList.first as MapEntryPbx;
      expect(entry.uuid, 'archiveVersion');
      expect(entry.value.toString(), '1');
    });

    test('Parse entry with comment before value', () {
      final content = '{\n'
          '\tbuildConfigurationList = AA11BB22CC33DD44EE55FF66 /* Build configuration list for PBXProject */;\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final entry = pbxproj.childrenList.first as MapEntryPbx;
      expect(entry.uuid, 'buildConfigurationList');
      expect(entry.value.toString(), 'AA11BB22CC33DD44EE55FF66');
      expect(entry.comment, 'Build configuration list for PBXProject');
    });

    test('Parse entry with comment after key', () {
      final content = '{\n'
          '\tAA11BB22CC33DD44EE55FF66 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.childrenList.first as MapPbx;
      expect(map.uuid, 'AA11BB22CC33DD44EE55FF66');
      expect(map.comment, 'AppDelegate.swift');
      expect(map.isInline, isTrue);
    });

    test('Parse quoted string key and value', () {
      final content = '{\n'
          '\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final entry = pbxproj.childrenList.first as MapEntryPbx;
      expect(entry.uuid, '"CODE_SIGN_IDENTITY[sdk=iphoneos*]"');
      expect(entry.value.toString(), '"iPhone Developer"');
    });

    test('Parse list', () {
      final content = '{\n'
          '\tfiles = (\n'
          '\t\tAA11BB22CC33DD44EE55FF66 /* main.swift in Sources */,\n'
          '\t\tBB22CC33DD44EE55FF660011 /* Assets.xcassets in Resources */,\n'
          '\t);\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final list = pbxproj.find<ListPbx>('files');
      expect(list, isNotNull);
      expect(list!.length, 2);
      expect(list[0].value, 'AA11BB22CC33DD44EE55FF66');
      expect(list[0].comment, 'main.swift in Sources');
      expect(list[1].value, 'BB22CC33DD44EE55FF660011');
      expect(list[1].comment, 'Assets.xcassets in Resources');
    });

    test('Parse list with comment on key', () {
      final content = '{\n'
          '\tbuildRules /* rules */ = (\n'
          '\t);\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final list = pbxproj.find<ListPbx>('buildRules');
      expect(list, isNotNull);
      expect(list!.comment, 'rules');
      expect(list.length, 0);
    });

    test('Parse multiline map', () {
      final content = '{\n'
          '\tAA11BB22CC33DD44EE55FF66 = {\n'
          '\t\tisa = PBXGroup;\n'
          '\t\tname = Products;\n'
          '\t\tsourceTree = "<group>";\n'
          '\t};\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('AA11BB22CC33DD44EE55FF66');
      expect(map, isNotNull);
      expect(map!.isInline, isFalse);
      expect(map.find<MapEntryPbx>('isa')!.value.toString(), 'PBXGroup');
      expect(map.find<MapEntryPbx>('name')!.value.toString(), 'Products');
    });

    test('Parse inline map', () {
      final content = '{\n'
          '\tAA11BB22CC33DD44EE55FF66 /* main.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB22CC33DD44EE55FF660011 /* main.swift */; };\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('AA11BB22CC33DD44EE55FF66');
      expect(map, isNotNull);
      expect(map!.isInline, isTrue);
      expect(map.comment, 'main.swift in Sources');
    });

    test('Parse empty multiline map', () {
      final content = '{\n'
          '\tclasses = {\n'
          '\t};\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('classes');
      expect(map, isNotNull);
      expect(map!.isInline, isFalse);
      expect(map.childrenList, isEmpty);
    });

    test('Parse empty inline map', () {
      final content = '{\n'
          '\tchildMap = {};\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('childMap');
      expect(map, isNotNull);
      expect(map!.isInline, isTrue);
      expect(map.childrenList, isEmpty);
    });

    test('Parse sections', () {
      final content = '{\n'
          '/* Begin PBXBuildFile section */\n'
          '\tAA11BB22CC33DD44EE55FF66 /* main.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB22CC33DD44EE55FF660011 /* main.swift */; };\n'
          '/* End PBXBuildFile section */\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final section = pbxproj.childrenList.first as SectionPbx;
      expect(section.name, 'PBXBuildFile');
      expect(section.childrenList.length, 1);
      final map = section.childrenList.first as MapPbx;
      expect(map.uuid, 'AA11BB22CC33DD44EE55FF66');
      expect(map.comment, 'main.swift in Sources');
      expect(map.isInline, isTrue);
    });

    test('Parse line comment', () {
      final content = '{\n'
          '\t// !!\$*UTF8*\$!\n'
          '\tarchiveVersion = 1;\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      expect(pbxproj.childrenList.first, isA<CommentPbx>());
      expect((pbxproj.childrenList.first as CommentPbx).comment,
          '!!\$*UTF8*\$!');
    });

    test('Parse map with comment on key', () {
      final content = '{\n'
          '\tparentMap /* groupComment */ = {\n'
          '\t\tchildKey = childValue;\n'
          '\t};\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('parentMap');
      expect(map, isNotNull);
      expect(map!.comment, 'groupComment');
      expect(map.find<MapEntryPbx>('childKey')!.value.toString(), 'childValue');
    });

    test('Parse map with comment after equals', () {
      final content = '{\n'
          '\tparentMap = /* groupComment */ {\n'
          '\t\tchildKey = childValue;\n'
          '\t};\n'
          '}\n';
      final pbxproj = parsePbxproj(content, 'project.pbxproj');
      final map = pbxproj.find<MapPbx>('parentMap');
      expect(map, isNotNull);
      expect(map!.comment, 'groupComment');
    });
  });

  group('Roundtrip Tests', () {
    test('Roundtrip minimal pbxproj', () {
      final input = '// !\$*UTF8*\$!\n'
          '{\n'
          '\tarchiveVersion = 1;\n'
          '\tobjectVersion = 54;\n'
          '}\n';
      final pbxproj = Pbxproj.parse(input);
      expect(pbxproj.toString(), input);
    });

    test('Roundtrip with empty multiline map', () {
      final input = '// !\$*UTF8*\$!\n'
          '{\n'
          '\tarchiveVersion = 1;\n'
          '\tclasses = {\n'
          '\t};\n'
          '\tobjectVersion = 54;\n'
          '}\n';
      final pbxproj = Pbxproj.parse(input);
      expect(pbxproj.toString(), input);
    });

    test('Roundtrip with comments', () {
      final input = '// !\$*UTF8*\$!\n'
          '{\n'
          '\t// !!\$*UTF8*\$!\n'
          '\t// !!\$*UTF8*\$!\n'
          '\tarchiveVersion = 1;\n'
          '}\n';
      final pbxproj = Pbxproj.parse(input);
      expect(pbxproj.toString(), input);
    });

    test('Roundtrip with sections and inline maps', () {
      final input = '// !\$*UTF8*\$!\n'
          '{\n'
          '\tarchiveVersion = 1;\n'
          '\tclasses = {\n'
          '\t};\n'
          '\tobjectVersion = 54;\n'
          '\tobjects = {\n'
          '\n'
          '/* Begin PBXBuildFile section */\n'
          '\t\tAA11BB22CC33DD44EE55FF66 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB22CC33DD44EE55FF660011 /* AppDelegate.swift */; };\n'
          '\t\tCC33DD44EE55FF6600112233 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = DD44EE55FF66001122334455 /* Assets.xcassets */; };\n'
          '/* End PBXBuildFile section */\n'
          '\n'
          '/* Begin PBXFileReference section */\n'
          '\t\tBB22CC33DD44EE55FF660011 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };\n'
          '\t\tDD44EE55FF66001122334455 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };\n'
          '/* End PBXFileReference section */\n'
          '\n'
          '/* Begin PBXGroup section */\n'
          '\t\tEE55FF66001122334455AABB = {\n'
          '\t\t\tisa = PBXGroup;\n'
          '\t\t\tchildren = (\n'
          '\t\t\t\tBB22CC33DD44EE55FF660011 /* AppDelegate.swift */,\n'
          '\t\t\t\tDD44EE55FF66001122334455 /* Assets.xcassets */,\n'
          '\t\t\t);\n'
          '\t\t\tpath = MyApp;\n'
          '\t\t\tsourceTree = "<group>";\n'
          '\t\t};\n'
          '/* End PBXGroup section */\n'
          '\n'
          '/* Begin PBXNativeTarget section */\n'
          '\t\tFF66001122334455AABBCCDD /* MyApp */ = {\n'
          '\t\t\tisa = PBXNativeTarget;\n'
          '\t\t\tbuildConfigurationList = 001122334455AABBCCDDEEFF /* Build configuration list for PBXNativeTarget "MyApp" */;\n'
          '\t\t\tbuildPhases = (\n'
          '\t\t\t\t112233445566778899AABBCC /* Sources */,\n'
          '\t\t\t\t2233445566778899AABBCCDD /* Resources */,\n'
          '\t\t\t);\n'
          '\t\t\tbuildRules = (\n'
          '\t\t\t);\n'
          '\t\t\tdependencies = (\n'
          '\t\t\t);\n'
          '\t\t\tname = MyApp;\n'
          '\t\t\tproductName = MyApp;\n'
          '\t\t\tproductReference = 334455AABBCCDDEEFF001122 /* MyApp.app */;\n'
          '\t\t\tproductType = "com.apple.product-type.application";\n'
          '\t\t};\n'
          '/* End PBXNativeTarget section */\n'
          '\n'
          '/* Begin XCBuildConfiguration section */\n'
          '\t\t445566778899AABBCCDDEEFF /* Debug */ = {\n'
          '\t\t\tisa = XCBuildConfiguration;\n'
          '\t\t\tbuildSettings = {\n'
          '\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n'
          '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";\n'
          '\t\t\t\tINFOPLIST_FILE = "MyApp/Info.plist";\n'
          '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.myapp;\n'
          '\t\t\t\tSWIFT_VERSION = 5.0;\n'
          '\t\t\t};\n'
          '\t\t\tname = Debug;\n'
          '\t\t};\n'
          '\t\t556677889900AABBCCDDEEFF /* Release */ = {\n'
          '\t\t\tisa = XCBuildConfiguration;\n'
          '\t\t\tbuildSettings = {\n'
          '\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n'
          '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";\n'
          '\t\t\t\tINFOPLIST_FILE = "MyApp/Info.plist";\n'
          '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.example.myapp;\n'
          '\t\t\t\tSWIFT_VERSION = 5.0;\n'
          '\t\t\t};\n'
          '\t\t\tname = Release;\n'
          '\t\t};\n'
          '/* End XCBuildConfiguration section */\n'
          '\t};\n'
          '\trootObject = AABBCCDDEEFF001122334455 /* Project object */;\n'
          '}\n';
      final pbxproj = Pbxproj.parse(input);
      expect(pbxproj.toString(), input);
    });

    test('Roundtrip save and reopen', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = '${tempDir.path}/project.pbxproj';

      try {
        final input = '// !\$*UTF8*\$!\n'
            '{\n'
            '\tarchiveVersion = 1;\n'
            '\tclasses = {\n'
            '\t};\n'
            '\tobjectVersion = 54;\n'
            '\tobjects = {\n'
            '\n'
            '/* Begin PBXBuildFile section */\n'
            '\t\tAA11BB22CC33DD44EE55FF66 /* ViewController.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB22CC33DD44EE55FF660011 /* ViewController.swift */; };\n'
            '/* End PBXBuildFile section */\n'
            '\n'
            '/* Begin PBXGroup section */\n'
            '\t\tCC33DD44EE55FF6600112233 = {\n'
            '\t\t\tisa = PBXGroup;\n'
            '\t\t\tchildren = (\n'
            '\t\t\t\tBB22CC33DD44EE55FF660011 /* ViewController.swift */,\n'
            '\t\t\t);\n'
            '\t\t\tsourceTree = "<group>";\n'
            '\t\t};\n'
            '/* End PBXGroup section */\n'
            '\t};\n'
            '\trootObject = DD44EE55FF66001122334455 /* Project object */;\n'
            '}\n';

        final file = File(tempFile);
        await file.create(recursive: true);
        await file.writeAsString(input);

        final pbxproj = await Pbxproj.open(tempFile);
        await pbxproj.save();

        final output = await file.readAsString();
        expect(output, input);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
