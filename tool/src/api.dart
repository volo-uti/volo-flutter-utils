// Shared model for the index and docs generators: resolves the public API of
// a package from its barrel with `package:analyzer` and groups it by the
// source file (or component folder) that declares it.
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';

/// A package whose public API is indexed.
class Pkg {
  const Pkg(this.name, {required this.indexId});

  final String name;

  /// Marker id of the AGENTS.md block: `<!-- BEGIN:<indexId> -->`.
  final String indexId;

  String get barrel => 'package:$name/$name.dart';
}

const packages = [
  Pkg('volo_flutter_utils', indexId: 'volo-flutter-utils-index'),
];

/// Repo root (the folder above `tool/`).
final String repoRoot = File.fromUri(Platform.script).parent.parent.path;

/// A public top-level declaration reachable from the barrel.
class ApiDecl {
  ApiDecl(this.element, this.pkg, this.file, this.line);

  /// The class, enum, mixin, extension, typedef, function or variable.
  final Element element;
  final Pkg pkg;

  /// Declaring file relative to the repo root (e.g. `lib/src/...`).
  final String file;
  final int line;

  String get name => element.name!;

  String get docText => docOf(element);

  /// First sentence of the doc comment, or empty when there is none.
  String get sentence => firstSentence(docText);

  /// `file:line Name` relative to the repo root.
  String get location => '$file:$line $name';

  bool get isWidget =>
      element is ClassElement &&
      (element as ClassElement).allSupertypes.any(
        (t) => t.element.name == 'Widget',
      );
}

/// Declarations that share one doc file: a component folder or a source file.
class Group {
  Group(this.pkg, this.key, this.decls);

  final Pkg pkg;

  /// e.g. `inputs/v_button` or `theme/v_colors`.
  final String key;
  final List<ApiDecl> decls;

  /// Doc path relative to the package root.
  String get docPath => 'doc/$key.md';

  /// Main widgets of a component folder; empty for plain source files.
  List<ApiDecl> get mains => _isComponent ? _mains() : const [];

  bool get _isComponent => decls.first.file.contains('/components/');

  List<ApiDecl> _mains() {
    final widgets = decls.where((d) => d.isWidget).toList();
    return widgets.isNotEmpty ? widgets : [decls.first];
  }
}

/// Source files under `lib/src` of [pkg] that its barrel does not export,
/// relative to [root] (default: the repo root).
///
/// The generators only see what the barrel exports, so a utility whose export
/// line was forgotten would otherwise go unchecked and unindexed.
List<String> unexportedSources(Pkg pkg, {String? root}) {
  final dir = root ?? repoRoot;
  final barrel = File('$dir/lib/${pkg.name}.dart');
  final text = barrel.existsSync() ? barrel.readAsStringSync() : '';
  final exported = <String>{};
  final srcPrefix = 'package:${pkg.name}/';
  for (final m in RegExp(
    r'''^\s*export\s+['"]([^'"]+)['"]''',
    multiLine: true,
  ).allMatches(text)) {
    var path = m[1]!;
    if (path.startsWith(srcPrefix)) path = path.substring(srcPrefix.length);
    exported.add(Uri.parse(path).normalizePath().path);
  }

  final src = Directory('$dir/lib/src');
  if (!src.existsSync()) return const [];
  final out = <String>[];
  for (final f in src.listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final rel = f.path.substring('$dir/lib/'.length).replaceAll(r'\', '/');
    if (!exported.contains(rel)) out.add('lib/$rel');
  }
  return out..sort();
}

/// Resolves the public declarations of [pkg] through its barrel.
Future<List<ApiDecl>> loadApi(Pkg pkg) async {
  final dir = repoRoot;
  final collection = AnalysisContextCollection(includedPaths: ['$dir/lib']);
  final session = collection
      .contextFor('$dir/lib/${pkg.name}.dart')
      .currentSession;
  final result = await session.getLibraryByUri(pkg.barrel);
  if (result is! LibraryElementResult) {
    throw StateError('Cannot resolve ${pkg.barrel}: $result');
  }
  final out = <ApiDecl>[];
  final seen = <String>{};
  for (final entry in result.element.exportNamespace.definedNames2.entries) {
    var e = entry.value;
    if (entry.key.endsWith('=')) continue;
    if (e is GetterElement && e.isOriginVariable) e = e.variable;
    final name = e.name;
    if (name == null || name.startsWith('_') || !seen.add(name)) continue;
    final fragment = e.firstFragment;
    final unit = fragment.libraryFragment;
    if (unit == null) continue;
    final path = unit.source.fullName;
    final prefix = '$dir/';
    if (!path.startsWith(prefix)) continue;
    final offset = fragment.nameOffset ?? 0;
    final line = unit.lineInfo.getLocation(offset).lineNumber;
    out.add(ApiDecl(e, pkg, path.substring(prefix.length), line));
  }
  out.sort((a, b) {
    final c = a.file.compareTo(b.file);
    return c != 0 ? c : a.line.compareTo(b.line);
  });
  return out;
}

/// Groups [decls] by component folder or source file (`.generated` merged
/// into its hand-written sibling).
List<Group> groupsOf(Pkg pkg, List<ApiDecl> decls) {
  final map = <String, List<ApiDecl>>{};
  for (final d in decls) {
    map.putIfAbsent(_keyOf(d.file), () => []).add(d);
  }
  final keys = map.keys.toList()..sort();
  return [for (final k in keys) Group(pkg, k, map[k]!)];
}

String _keyOf(String file) {
  final parts = file.replaceFirst('lib/src/', '').split('/');
  if (parts.first == 'components' && parts.length >= 4) {
    return '${parts[1]}/${parts[2]}';
  }
  final stem = parts.last.replaceAll(RegExp(r'(\.generated)?\.dart$'), '');
  return '${parts.first}/$stem';
}

/// Raw doc comment of [e] with comment markers and template tags removed.
String docOf(Element e) {
  final owner = e is GetterElement && e.isOriginVariable ? e.variable : e;
  return stripDoc(owner.documentationComment);
}

/// Removes `///` markers, `{@template}` / `{@endtemplate}` / `{@macro}` tags.
String stripDoc(String? raw) {
  if (raw == null) return '';
  final lines = <String>[];
  for (var line in raw.split('\n')) {
    line = line.trim();
    if (line.startsWith('///')) {
      line = line.substring(3);
      if (line.startsWith(' ')) line = line.substring(1);
    }
    if (RegExp(r'^\{@(?:template|macro)\s[^}]*\}$').hasMatch(line.trim()) ||
        line.trim() == '{@endtemplate}') {
      continue;
    }
    lines.add(line.trimRight());
  }
  return lines.join('\n').trim();
}

/// First sentence of [text]: the first paragraph up to the first `. `,
/// whitespace collapsed, ending with `.`; empty when [text] is empty.
String firstSentence(String text) {
  final paragraph = text.trim().split(RegExp(r'\n\s*\n')).first;
  final flat = paragraph.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.isEmpty) return '';
  final end = flat.indexOf('. ');
  final s = end < 0 ? flat : flat.substring(0, end + 1);
  return s.endsWith('.') || s.endsWith(':') ? s : '$s.';
}

/// [firstSentence] for the one-line index: `[Name]` references lose brackets.
String indexSentence(String text) =>
    firstSentence(text).replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) => m[1]!);
