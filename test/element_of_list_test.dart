import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('ElementOfListPbx Tests', () {
    late ElementOfListPbx element;

    setUp(() {
      element = ElementOfListPbx(
        'AA11BB22CC33DD44EE55FF66',
        comment: 'main.swift in Sources',
      );
    });

    test('String representation with comment', () {
      final str = element.toString(indentLevel: 0, removeN: false);
      expect(str, 'AA11BB22CC33DD44EE55FF66 /* main.swift in Sources */,');
    });

    test('String representation without comment', () {
      element = ElementOfListPbx('BB22CC33DD44EE55FF660011');
      final str = element.toString(indentLevel: 0, removeN: false);
      expect(str, 'BB22CC33DD44EE55FF660011,');
    });

    test('String representation with indentation', () {
      final str = element.toString(indentLevel: 2, removeN: false);
      expect(str,
          '\t\tAA11BB22CC33DD44EE55FF66 /* main.swift in Sources */,');
    });

    test('CopyWith method with new value', () {
      final copied = element.copyWith(
        value: 'CC33DD44EE55FF6600112233',
        comment: 'Assets.xcassets in Resources',
      );
      expect(copied.value, 'CC33DD44EE55FF6600112233');
      expect(copied.comment, 'Assets.xcassets in Resources');
    });

    test('CopyWith method with partial changes', () {
      final copied = element.copyWith(value: 'DD44EE55FF66001122334455');
      expect(copied.value, 'DD44EE55FF66001122334455');
      expect(copied.comment, 'main.swift in Sources');
    });

    test('CopyWith method without changes', () {
      final copied = element.copyWith();
      expect(copied.value, 'AA11BB22CC33DD44EE55FF66');
      expect(copied.comment, 'main.swift in Sources');
    });
  });
}
