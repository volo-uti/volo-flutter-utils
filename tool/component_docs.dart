// Generates the per-widget reference docs shipped with the package:
// doc/<group>.md, one file per component folder or source file.
// Each file has the full doc comment, every constructor with a parameter
// table, companion types (styles, enums with their values) and members.
//
// `dart run tool/component_docs.dart` writes them; `--check` exits 1 when a
// file is stale or orphaned (no declaration produces it any more).
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';

import 'src/api.dart';

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  final problems = <String>[];

  for (final pkg in packages) {
    final groups = groupsOf(pkg, await loadApi(pkg));
    final wanted = {for (final g in groups) g.docPath: renderGroup(g)};
    final docDir = Directory('$repoRoot/doc');

    final existing = <String>{
      if (docDir.existsSync())
        for (final f in docDir.listSync(recursive: true))
          if (f is File && f.path.endsWith('.md'))
            f.path.substring(docDir.path.length - 3),
    };

    for (final e in wanted.entries) {
      final file = File('$repoRoot/${e.key}');
      final fresh = file.existsSync() && file.readAsStringSync() == e.value;
      if (check) {
        if (!fresh) {
          problems.add('${e.key} is stale: run make index');
        }
      } else if (!fresh) {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(e.value);
      }
    }
    for (final orphan in existing.difference(wanted.keys.toSet())) {
      if (check) {
        problems.add('$orphan is orphaned: run make index');
      } else {
        File('$repoRoot/$orphan').deleteSync();
      }
    }
    if (!check) stdout.writeln('${pkg.name}: ${wanted.length} doc files');
  }

  if (problems.isNotEmpty) {
    problems.forEach(stderr.writeln);
    exit(1);
  }
}

/// Markdown for one group; deterministic for a given source tree.
String renderGroup(Group g) {
  final mains = g.mains;
  final ordered = [...mains, ...g.decls.where((d) => !mains.contains(d))];
  final title = mains.isNotEmpty
      ? mains.map((d) => d.name).join(', ')
      : g.key.split('/').last;
  final out = StringBuffer()
    ..writeln('# $title')
    ..writeln()
    ..writeln('Import: `${g.pkg.barrel}`');
  for (final d in ordered) {
    out
      ..writeln()
      ..write(_renderDecl(d));
  }
  return '${out.toString().trimRight()}\n';
}

String _renderDecl(ApiDecl d) {
  final e = d.element;
  final out = StringBuffer()..writeln('## ${d.name}');
  final doc = d.docText;
  if (doc.isNotEmpty) {
    out
      ..writeln()
      ..writeln(doc);
  }
  switch (e) {
    case EnumElement():
      out
        ..write(_enumValues(e))
        ..write(_constructors(e))
        ..write(_members(e));
    case InterfaceElement():
      out
        ..write(_constructors(e))
        ..write(_members(e));
    case ExtensionElement():
      out.write(_members(e));
    case TypeAliasElement():
      out
        ..writeln()
        ..writeln('```dart')
        ..writeln('typedef ${d.name} = ${e.aliasedType.getDisplayString()};')
        ..writeln('```');
    case TopLevelFunctionElement():
      out
        ..writeln()
        ..writeln('```dart')
        ..writeln(e.displayString())
        ..writeln('```');
    default:
      final type = switch (e) {
        TopLevelVariableElement() => e.type.getDisplayString(),
        GetterElement() => e.returnType.getDisplayString(),
        _ => '',
      };
      if (type.isNotEmpty) {
        out
          ..writeln()
          ..writeln('Type: `$type`');
      }
  }
  return out.toString();
}

String _enumValues(EnumElement e) {
  final values = e.constants.where((c) => c.isPublic).toList();
  if (values.isEmpty) return '';
  final out = StringBuffer()
    ..writeln()
    ..writeln('### Values')
    ..writeln()
    ..writeln('| Value | Description |')
    ..writeln('|---|---|');
  for (final v in values) {
    out.writeln('| `${v.name}` | ${_cell(stripDoc(v.documentationComment))} |');
  }
  return out.toString();
}

String _constructors(InterfaceElement e) {
  final ctors = e.constructors.where((c) => c.isPublic).toList();
  if (ctors.isEmpty || e is MixinElement) return '';
  // An enum's generated constructors carry no information.
  if (e is EnumElement) return '';
  final out = StringBuffer()
    ..writeln()
    ..writeln('### Constructors');
  for (final c in ctors) {
    final name = c.name == 'new' || c.name == null || c.name!.isEmpty
        ? e.name
        : '${e.name}.${c.name}';
    out
      ..writeln()
      ..writeln('#### `$name`');
    final doc = stripDoc(c.documentationComment);
    if (doc.isNotEmpty) {
      out
        ..writeln()
        ..writeln(doc);
    }
    final params = c.formalParameters.where((p) => p.name != 'key').toList();
    if (params.isEmpty) continue;
    out
      ..writeln()
      ..writeln('| Parameter | Type | Default | Required | Description |')
      ..writeln('|---|---|---|---|---|');
    for (final p in params) {
      final field = p.name == null ? null : e.getField(p.name!);
      final desc = [
        if (field != null && field.metadata.hasDeprecated) 'Deprecated.',
        _cell(stripDoc(field?.documentationComment)),
      ].where((s) => s.isNotEmpty).join(' ');
      final def = p.defaultValueCode;
      final required = p.isRequiredNamed || p.isRequiredPositional;
      out.writeln(
        '| `${p.name}` | `${_cell(p.type.getDisplayString())}` | '
        '${def == null ? '' : '`${_cell(def)}`'} | ${required ? 'yes' : ''} | $desc |',
      );
    }
  }
  return out.toString();
}

String _members(InstanceElement e) {
  final ctorFields = <String>{
    if (e is InterfaceElement)
      for (final c in e.constructors)
        for (final p in c.formalParameters) ?p.name,
  };
  final rows = <String>[];
  void add(Element m, String signature) {
    final doc = stripDoc(m.documentationComment);
    rows.add('| `${_cell(signature)}` | ${_cell(doc)} |');
  }

  for (final f in e.fields) {
    if (!f.isPublic || !f.isOriginDeclaration) continue;
    if (ctorFields.contains(f.name) || e is EnumElement && f.isEnumConstant) {
      continue;
    }
    add(
      f,
      '${f.isStatic ? 'static ' : ''}${f.type.getDisplayString()} ${f.name}',
    );
  }
  for (final g in e.getters) {
    if (!g.isPublic || !g.isOriginDeclaration || g.metadata.hasOverride) {
      continue;
    }
    add(
      g,
      '${g.isStatic ? 'static ' : ''}${g.returnType.getDisplayString()} get ${g.name}',
    );
  }
  for (final m in e.methods) {
    if (!m.isPublic || m.metadata.hasOverride) continue;
    add(m, '${m.isStatic ? 'static ' : ''}${m.displayString()}');
  }
  if (rows.isEmpty) return '';
  return '\n### Members\n\n| Member | Description |\n|---|---|\n${rows.join('\n')}\n';
}

/// One table cell: paragraphs joined by `<br>`, fenced code dropped, pipes
/// escaped.
String _cell(String text) {
  final withoutFences = text.replaceAll(RegExp('```.*?```', dotAll: true), '');
  final paragraphs = withoutFences
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((p) => p.isNotEmpty);
  return paragraphs.join('<br>').replaceAll('|', r'\|');
}
