import 'package:xcode_parser/src/pbxproj/interfaces/base_components.dart';
import 'package:xcode_parser/src/pbxproj/list/element_of_list_pbx.dart';
import 'package:xcode_parser/src/pbxproj/list/list_pbx.dart';
import 'package:xcode_parser/src/pbxproj/list/var_pbx.dart';
import 'package:xcode_parser/src/pbxproj/map/map_entry_pbx.dart';
import 'package:xcode_parser/src/pbxproj/map/map_pbx.dart';
import 'package:xcode_parser/src/pbxproj/map/section_pbx.dart';
import 'package:xcode_parser/src/pbxproj/other/comment_pbx.dart';
import 'package:xcode_parser/src/pbxproj/pbxproj.dart';

/// The function is named [parsePbxproj] and it takes three parameters:
/// [content] of type [String], [path] of type [String], and an optional
/// parameter [debug] of type [bool] with a default value of [false].
/// The function returns a value of type [Pbxproj].
///
/// The purpose of this function is to parse the [content] string and
/// create a [Pbxproj] object based on the provided [path]. The debug parameter
/// is used for debugging purposes and is set to 'false' by default.
Pbxproj parsePbxproj(String content, String path, {bool debug = false}) {
  printD(Object? object) {
    if (debug) {
      print(object);
    }
  }

  final regexList =
      RegExp(r'[a-zA-Z0-9_]+\s*(/\*.*?\*/\s*)?=\s*(?:/\*.*?\*/\s*)?\(');
  // final regexEntry = RegExp(
  //   r'^\s*(\w+)\s*(?:\/\*\s*[^*]*\*\/\s*)?=\s*(?:\/\*\s*[^*]*\*\/\s*)?"((?:\\.|[^"\\])*)"|([\w$%.\?!)(}{#@]+)\s*(?:\/\*\s*[^*]*\*\/)?;\s*$',
  //   multiLine: true,
  //   dotAll: true,
  // );

  final regexMap =
      RegExp(r'[a-zA-Z0-9_]+\s*(/\*.*?\*/\s*)?=\s*(?:/\*.*?\*/\s*)?\{');

  int index = 0;

  String current() {
    return content.substring(index).trim();
  }

  void skipPattern(String pattern) {
    if (!current().startsWith(pattern)) {
      return;
    }
    while (index < content.length &&
        !content.substring(index).startsWith(pattern)) {
      index++;
    }
    index += pattern.length;
  }

  String? checkBeginSection(String comment) {
    final pattern = comment.trim();
    final begin = 'Begin';
    final section = 'section';
    if (pattern.startsWith(begin) && pattern.endsWith(section)) {
      return pattern.replaceFirst(begin, '').replaceFirst(section, '').trim();
    }
    return null;
  }

  String? checkEndSection(String comment) {
    final pattern = comment.trim();
    final begin = 'End';
    final section = 'section';
    if (pattern.startsWith(begin) && pattern.endsWith(section)) {
      return pattern.replaceFirst(begin, '').replaceFirst(section, '').trim();
    }
    return null;
  }

  String parseKey() {
    String key = '';
    final bool isStringValue = current()[0] == '"';
    if (isStringValue) {
      skipPattern('"');
      key += '"';
    }
    if (isStringValue) {
      bool endOfStringFound = false;
      while (index < content.length) {
        if (content[index] == '"' && endOfStringFound) {
          index++;
          break;
        } else if (content[index] == '"') {
          // Встретили кавычку, следующий символ может быть завершающим
          key += content[index];
          endOfStringFound = true;
        } else {
          key += content[index];
          index++;
        }
      }
    } else {
      while (index < content.length &&
          !current().startsWith('=') &&
          !current().startsWith('/*')) {
        key += content[index];
        index++;
      }
    }
    printD('ParseKey: ${key.trim()}');

    return key.trim();
  }

  String parseVar() {
    while (current().startsWith('=')) {
      skipPattern('=');
    }

    String value = '';
    final bool isStringValue = current()[0] == '"';
    bool endOfStringFound = false;

    while (index < content.length) {
      if (isStringValue) {
        if (content[index] == ';' && endOfStringFound) {
          break;
        } else if (content[index] == '"') {
          // Встретили кавычку, следующий символ может быть завершающим
          value += content[index];
          endOfStringFound = true;
        } else {
          // Продолжаем добавлять символы к строковому значению
          value += content[index];
          endOfStringFound =
              false; // Сброс флага, если это не была последняя кавычка
        }
      } else {
        // Для нестроковых значений, проверяем на комментарий или точку с запятой
        if (content.substring(index, index + 2) == '/*' ||
            content[index] == ';') {
          break;
        } else {
          value += content[index];
        }
      }
      index++;
    }
    printD('ParseVar: ${value.trim()}');
    return value.trim();
  }

  String parseValOfList() {
    String value = '';
    while (index < content.length &&
        content[index] != ',' &&
        (index == content.length - 1 ||
            content.substring(index, index + 2) != '/*')) {
      value += content[index];
      index++;
    }

    printD('ParseValOfList: ${value.trim()}');
    return value.trim();
  }

  String parseComment() {
    String comment = '';
    skipPattern('/*');
    while (
        index < content.length && !content.substring(index).startsWith('*/')) {
      comment += content[index];
      index++;
    }
    skipPattern('*/');
    printD('Parse Comment: ${comment.trim()}');
    return comment.trim();
  }

  CommentPbx parseCommentLine() {
    if (!current().startsWith('//')) {
      return CommentPbx('');
    }
    skipPattern('//');
    String comment = '';
    while (
        index < content.length && !content.substring(index).startsWith('\n')) {
      comment += content[index];
      index++;
    }
    skipPattern('\n');
    printD('Parse Comment Line: ${comment.trim()}');
    return CommentPbx(comment.trim());
  }

  MapEntryPbx parseEntry() {
    final key = parseKey();
    if (current().startsWith('/*')) {
      final comment = parseComment();
      final value = parseVar();
      index++;
      return MapEntryPbx(key, VarPbx(value), comment: comment);
    }
    final value = parseVar();
    if (current().startsWith('/*')) {
      final comment = parseComment();
      index++;
      return MapEntryPbx(key, VarPbx(value), comment: comment);
    }
    index++;
    return MapEntryPbx(key, VarPbx(value));
  }

  ListPbx parseList() {
    List<ElementOfListPbx> elements = [];
    String? comment;
    final key = parseKey();
    if (current().startsWith('/*')) {
      comment = parseComment();
    }
    if (current().startsWith('=')) {
      while (index < content.length && content[index] != '=') {
        index++;
      }
      index++;
    }
    while (index < content.length) {
      if (current().startsWith('(')) {
        printD('L FOUND (');
        skipPattern('(');
        continue;
      } else if (current().startsWith(')')) {
        printD('L FOUND )');
        skipPattern(')');
        index++;
        break;
      } else if (current().startsWith('/*')) {
        printD('L FOUND /*');
        final comment = parseComment();
        final value = parseValOfList();
        elements.add(ElementOfListPbx(value, comment: comment));
        skipPattern(',');
      } else {
        printD('L FOUND val');
        String value = parseValOfList();
        if (current().startsWith('/*')) {
          final comment = parseComment();
          index++;
          elements.add(ElementOfListPbx(value, comment: comment));
          skipPattern(',');
          continue;
        }
        elements.add(ElementOfListPbx(value));
        skipPattern(',');
        continue;
      }
    }
    return ListPbx(key, elements, comment: comment);
  }

  MapPbx parseMap() {
    final key = parseKey();
    String? comment;
    skipPattern('=');
    if (current().startsWith('/*')) {
      comment = parseComment();
      printD(
          'M FOUND key Comment : $comment\nM after comment: ${current().substring(0, 30)}');
      index++;
    }
    index++;
    skipPattern('=');
    List<NamedComponent> children = [];
    SectionPbx? sectionPbx;

    addChild(NamedComponent component) {
      if (sectionPbx != null) {
        sectionPbx.add(component);
      } else {
        children.add(component);
      }
    }

    while (index < content.length) {
      if (current().startsWith('{')) {
        skipPattern('{');
        continue;
      } else if (current().startsWith('};')) {
        skipPattern('};');
        break;
      }
      // if (current().startsWith(regexEntry)) {
      //   printD('M FOUND Entry');
      //   addChild(parseEntry());
      // } else
      if (current().startsWith(regexList)) {
        printD('M FOUND List');
        addChild(parseList());
      } else if (current().startsWith(regexMap)) {
        printD('M FOUND Map');
        index++;
        addChild(parseMap());
      } else if (current().startsWith('//')) {
        printD('M FOUND comment //');
        addChild(parseCommentLine());
      } else if (current().startsWith('/*')) {
        printD('M FOUND Comment /*');
        final comment = parseComment();
        final begin = checkBeginSection(comment);
        final end = checkEndSection(comment);
        if (begin != null) {
          sectionPbx = SectionPbx(name: begin, children: []);
        } else if (end != null && sectionPbx != null) {
          children.add(sectionPbx);
          sectionPbx = null;
        }
        printD('M END Comment $comment');
      } else {
        printD('M FOUND EntryFallBack');
        addChild(parseEntry());
      }
    }
    return MapPbx(uuid: key, children: children, comment: comment);
  }

  MapPbx parsePbxproj() {
    List<NamedComponent> children = [];
    SectionPbx? sectionPbx;

    addChild(NamedComponent component) {
      if (sectionPbx != null) {
        sectionPbx.add(component);
      } else {
        children.add(component);
      }
    }

    final startModelIndex = content.indexOf('{');
    index = startModelIndex.clamp(0, content.length);

    while (index < content.length) {
      skipPattern(';');
      if (current().startsWith('{')) {
        printD('J FOUND {');
        skipPattern('{');
      } else
      //   if (current().startsWith(regexEntry)) {
      //   printD('J FOUND Entry');
      //   addChild(parseEntry());
      // } else
      if (current().startsWith(regexList)) {
        printD('J FOUND List');
        addChild(parseList());
      } else if (current().startsWith(regexMap)) {
        printD('J FOUND Map');
        index++;
        addChild(parseMap());
      } else if (current().startsWith('//')) {
        printD('J FOUND comment //');
        final comment = parseCommentLine();
        addChild(comment);
      } else if (current().startsWith('/*')) {
        printD('J FOUND Comment /*');
        final comment = parseComment();
        final begin = checkBeginSection(comment);
        final end = checkEndSection(comment);
        if (begin != null) {
          sectionPbx = SectionPbx(name: begin, children: []);
        } else if (end != null && sectionPbx != null) {
          children.add(sectionPbx);
          sectionPbx = null;
        }
        printD('J END Comment $comment');
      } else if (current().startsWith('}')) {
        printD('J FOUND }');
        index++;
        break;
      } else {
        printD('J FOUND Entry FallBack');
        addChild(parseEntry());
      }
    }

    printD('J END');
    return MapPbx(uuid: '', children: children);
  }

  final parsed = parsePbxproj();
  final project = Pbxproj(children: parsed.childrenList, path: path);
  return project;
}
