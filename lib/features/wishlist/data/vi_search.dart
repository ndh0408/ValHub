/// Accent-insensitive search for Vietnamese names ("vo cuc" finds
/// "Vô Cực", "DAO" finds "Dao Reaver"). Implemented once in core.
library;

import '../../../core/util/search_text.dart';

export '../../../core/util/search_text.dart' show matchesTokens, searchTokens;

/// Lowercases [input], strips Vietnamese diacritics (precomposed or
/// combining) and collapses whitespace.
String foldForSearch(String input) => foldSearchText(input);
