/// Accent- and case-insensitive search for item names in every language
/// ("cafe xanh mat" finds "Vandal Cafe Xanh Mát"). Implemented once in core.
library;

export '../../../core/util/search_text.dart'
    show compareNames, foldForSearch, matchesSearch;
