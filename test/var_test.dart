import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('VarPbx Tests', () {
    late VarPbx varPbx;

    setUp(() {
      varPbx = VarPbx('sourcecode.swift');
    });

    test('String representation without indentation', () {
      final str = varPbx.toString(indentLevel: 0, removeN: false);
      expect(str, 'sourcecode.swift');
    });

    test('String representation with indentation', () {
      final str = varPbx.toString(indentLevel: 2, removeN: false);
      expect(str, 'sourcecode.swift');
    });

    test('CopyWith method with new value', () {
      final copied = varPbx.copyWith(value: 'folder.assetcatalog');
      expect(copied.value, 'folder.assetcatalog');
    });

    test('CopyWith method with same value', () {
      final copied = varPbx.copyWith();
      expect(copied.value, 'sourcecode.swift');
    });
  });
}
