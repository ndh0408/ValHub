import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'legal_documents.dart';

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  // Manifest membership distinguishes an absent translation from read failure.
  final paths = AssetManifest.loadFromAssetBundle(rootBundle)
      .then((manifest) => manifest.listAssets().toSet());
  return LegalRepository((path) async {
    if (!(await paths).contains(path)) return null;
    return rootBundle.loadString(path);
  });
});

final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocument, ({LegalDocumentRef document, String locale})>(
      (ref, request) => ref
          .watch(legalRepositoryProvider)
          .load(request.document.id, locale: request.locale),
    );
