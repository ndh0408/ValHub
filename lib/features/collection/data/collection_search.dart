/// Accent-insensitive search for Vietnamese item names ("cafe xanh mat"
/// finds "Vandal Cafe Xanh Mát"). Implemented once in core.
library;

export '../../../core/util/search_text.dart'
    show compareNames, foldSearchText, matchesSearch;
