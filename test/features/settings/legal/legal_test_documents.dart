import 'dart:convert';
import 'dart:io';

import 'package:valvn/features/settings/legal/legal_documents.dart';

/// Synchronous fixture reading avoids filesystem futures inside widget clocks.
LegalDocument legalTestDocument(LegalDocumentRef ref) => LegalDocument.fromJson(
  jsonDecode(File('assets/legal/vi/${ref.id}.json').readAsStringSync()),
);
