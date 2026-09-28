import 'dart:io';

import 'package:valvn/core/content/content_repository.dart';

/// Raw fixture JSON keyed like `ContentRepository.endpoints`.
Map<String, String> loadContentFixtures() => {
  for (final key in ContentRepository.endpoints.keys)
    if (File('test/fixtures/content/$key.json').existsSync())
      key: File('test/fixtures/content/$key.json').readAsStringSync(),
};
