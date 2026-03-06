import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('ListPbx Tests', () {
    late ListPbx listPbx;
    late ElementOfListPbx element;

    setUp(() {
      element = ElementOfListPbx(
        'AA11BB22CC33DD44EE55FF66',
        comment: 'main.swift in Sources',
      );
      listPbx = ListPbx('files', [element]);
    });

    test('Add ElementOfListPbx', () {
      final newElement = ElementOfListPbx(
        'BB22CC33DD44EE55FF660011',
        comment: 'Assets.xcassets in Resources',
      );
      listPbx.add(newElement);
      expect(listPbx.length, 2);
      expect(listPbx[1], newElement);
    });

    test('Access ElementOfListPbx by index', () {
      expect(listPbx[0], element);
    });

    test('Length of ListPbx', () {
      expect(listPbx.length, 1);
    });

    test('String representation', () {
      final str = listPbx.toString();
      expect(str.contains('files = ('), isTrue);
      expect(
          str.contains(
              'AA11BB22CC33DD44EE55FF66 /* main.swift in Sources */,'),
          isTrue);
      expect(str.contains(');'), isTrue);
    });

    test('CopyWith method', () {
      final newElement = ElementOfListPbx(
        'CC33DD44EE55FF6600112233',
        comment: 'LaunchScreen.storyboard in Resources',
      );
      final copied = listPbx.copyWith(
        uuid: 'buildPhases',
        children: [newElement],
      );

      expect(copied.uuid, 'buildPhases');
      expect(copied.length, 1);
      expect(copied[0], newElement);
      expect(copied.comment, listPbx.comment);
    });

    test('CopyWith method with partial changes', () {
      final copied = listPbx.copyWith(comment: 'build files');
      expect(copied.uuid, listPbx.uuid);
      expect(copied.length, 1);
      expect(copied[0], element);
      expect(copied.comment, 'build files');
    });

    test('CopyWith method without changes', () {
      final copied = listPbx.copyWith();
      expect(copied.uuid, listPbx.uuid);
      expect(copied.length, listPbx.length);
      expect(copied[0], element);
      expect(copied.comment, listPbx.comment);
    });
  });
}
