## 2.0.0

- Extracted `ChildrenMixin` to eliminate code duplication between `ChildrenComponent` and `ChildrenNamedComponent`
- Replaced String concatenation with StringBuffer in `toString` methods for better performance
- Added collection methods to `ListPbx`: `iterator`, `where`, `map`, `isEmpty`, `isNotEmpty`, `toList`
- Fixed roundtrip serialization: inline/multiline map detection, section formatting, output trailing newline
- Fixed `formatOutput` to preserve intentional blank lines between sections
- Rewritten tests with realistic anonymous pbxproj data and roundtrip tests

## 1.3.1
- Fixed leading comment count increase
- Fixed saving file with multiple comments
- Added function to array modifications

## 1.2.0

- Added Web support with Pbxproj.parse constructor to parse the String Pbxproj content
- Fixed index out of bounds error

## 1.1.4

- Updated output formatter

## 1.1.1

- Updated README.md
- Fixed something bugs
- Added tests

## 1.1.0

- Updated README.md
- fixed parse MapEntry in parsePbxproj

## 1.0.0

- Initial version.
