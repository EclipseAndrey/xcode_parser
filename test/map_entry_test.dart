import 'package:test/test.dart';
import 'package:xcode_parser/xcode_parser.dart';

void main() {
  group('MapEntryPbx Tests', () {
    late MapEntryPbx<VarPbx> mapEntryPbx;
    late VarPbx value;

    setUp(() {
      value = VarPbx('PBXBuildFile');
      mapEntryPbx = MapEntryPbx(
        'isa',
        value,
        comment: 'Sources',
      );
    });

    test('String representation without indentation and with comment', () {
      final str = mapEntryPbx.toString(indentLevel: 0, removeN: true);
      expect(str, 'isa = PBXBuildFile /* Sources */; ');
    });

    test('String representation with indentation and without comment', () {
      mapEntryPbx = MapEntryPbx(
        'isa',
        value,
      );
      final str = mapEntryPbx.toString(indentLevel: 2, removeN: false);
      expect(str, '\t\tisa = PBXBuildFile;\n');
    });

    test('CopyWith method', () {
      final newValue = VarPbx('PBXFileReference');
      final copied = mapEntryPbx.copyWith(
        uuid: 'fileRef',
        value: newValue,
        comment: 'AppDelegate.swift',
      );

      expect(copied.uuid, 'fileRef');
      expect(copied.value, newValue);
      expect(copied.comment, 'AppDelegate.swift');
    });

    test('CopyWith method with partial changes', () {
      final newValue = VarPbx('PBXGroup');
      final copied = mapEntryPbx.copyWith(
        value: newValue,
      );

      expect(copied.uuid, 'isa');
      expect(copied.value, newValue);
      expect(copied.comment, 'Sources');
    });
  });
}
