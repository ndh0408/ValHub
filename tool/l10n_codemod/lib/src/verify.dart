/// Cutover verification uses the resolved scan, never a regex-only count that can mistake comments for calls.
Map<String, Object?> verificationReport(Map<String, Object?> scan) {
  List<Map<String, Object?>> rows(String key) =>
      (scan[key] as List<Object?>? ?? const []).cast<Map<String, Object?>>();
  final references = rows('refs')
      .where(
        (r) =>
            (r['file'] as String).startsWith('lib/') && r['cat'] != 'strings',
      )
      .toList();
  final literals = rows('viLiterals');
  final errors = rows('analysisErrors');
  final unknown = scan['unknownStringsClasses'] as Map<String, Object?>? ?? {};
  final groups = <String, int>{};
  for (final ref in references) {
    final category = ref['cat'] as String;
    groups[category] = (groups[category] ?? 0) + 1;
  }
  final sorted = groups.keys.toList()..sort();
  return {
    'schema': 1,
    'readyForCutover':
        references.isEmpty &&
        literals.isEmpty &&
        errors.isEmpty &&
        unknown.isEmpty,
    'remainingReferences': references.length,
    'remainingVietnameseLiterals': literals.length,
    'byLayer': {for (final category in sorted) category: groups[category]},
    'references': references,
    'literals': literals,
    'analysisErrors': errors,
    'unknownStringsClasses': unknown,
  };
}
