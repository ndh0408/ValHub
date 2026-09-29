/// Compatibility re-export: search folding now lives in
/// `core/util/search_text.dart` (every language, not only Vietnamese).
library;

export '../../../core/util/search_text.dart'
    show foldForSearch, matchesTokens, searchTokens;
