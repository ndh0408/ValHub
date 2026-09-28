/// Vietnamese copy owned by the economy domain (VF §8.2, §8.5, §8.6).
///
/// Reward-source labels ("Phần thưởng Battle Pass" …), "Không bán", currency
/// and item-type labels live in `ContentStrings`; this file only adds what
/// the economy models need on top.
abstract final class EconomyStrings {
  // Where a wishlist skin is on sale right now (VF §8.5 placeDaily / placeNM /
  // placeBundle).
  static const placeDaily = 'cửa hàng hằng ngày';
  static const placeNightMarket = 'Chợ Đêm';
  static const placeBundleGeneric = 'bundle';
  static String placeBundle(String name) => 'bundle $name';

  /// "Đang có trong Chợ Đêm!" (VF §8.5 wishlistAvailableNow).
  static String availableNow(String place) => 'Đang có trong $place!';

  // Price sources (tooltip / caption under a price, B9).
  static const priceFromTable = 'Giá niêm yết';
  static const priceFromStore = 'Giá đã thấy trong cửa hàng';
  static const priceFromOffers = 'Giá từ bảng giá Riot';
  static const priceEstimated = 'Giá ước tính theo phiên bản';
  static const priceUnknown = 'Chưa rõ giá';

  // Collection value (VF §8.6).
  static const collectionValue = 'Giá trị bộ sưu tập';
  static const wishlistValue = 'Tổng giá trị wishlist';
  static const excludedRewards = 'Không tính skin phần thưởng';
  static const valueHasEstimates = 'Có giá ước tính (≈)';
}
