/// Vietnamese strings of the "Cộng đồng" feature (feed, LFG, skin
/// leaderboard; docs/community-api.md, VF §8).
abstract final class CommunityStrings {
  static const title = 'Cộng đồng';

  // ------------------------------------------------------------- sections
  static const sectionFeed = 'Bảng tin';
  static const sectionLfg = 'Tìm đồng đội';
  static const sectionSkins = 'Xếp hạng skin';

  // ------------------------------------------------------- general states
  static const unavailableTitle = 'Chưa kết nối được Cộng đồng';
  static const unavailableBody =
      'Chưa kết nối được Cộng đồng ValHub. Hãy thử lại sau ít phút.';
  static const noAccountTitle = 'Đăng nhập để tham gia';
  static const noAccountBody =
      'Thêm tài khoản Riot để đăng bài, tìm đồng đội và bình chọn skin.';
  static const privacyNote =
      'ValHub xác minh Riot ID khi kết nối Cộng đồng và quyền sở hữu skin khi bạn đánh giá. Cộng đồng '
      'không lưu mật khẩu hay dữ liệu đăng nhập Riot của bạn.';
  static const you = 'Bạn';
  static const unknownPlayer = 'Người chơi';
  static const moreActions = 'Tùy chọn khác';
  static String tagSuffix(String tag) => '#$tag';
  static String riotId(String name, String tag) => '$name#$tag';
  static String dotJoin(Iterable<String> parts) => parts.join(' · ');
  static String pageOf(String i, String n) => '$i/$n';
  static String charCount(String n, String max) => '$n/$max';
  static const retry = 'Thử lại';
  static const loadMoreFailed = 'Chưa tải thêm được bài. Hãy thử lại.';

  // --------------------------------------------------------------- errors
  static const errorGeneric = 'Có gì đó trục trặc. Hãy thử lại.';
  static const errorNetwork =
      'Không kết nối được Cộng đồng ValHub. Kiểm tra mạng rồi thử lại.';
  static const errorTimeout = 'Cộng đồng ValHub phản hồi quá lâu. Hãy thử lại.';
  static const errorServer =
      'Cộng đồng ValHub đang gặp sự cố. Hãy thử lại sau ít phút.';
  static const errorUnauthorized = 'Kết nối Cộng đồng đã hết hạn. Hãy thử lại.';
  static const errorRiotRejected =
      'Riot chưa xác minh được tài khoản của bạn. Hãy đăng nhập lại tài khoản '
      'Riot rồi thử lại.';
  static const riotUnavailableTitle = 'Riot đang gặp sự cố';
  static const errorRiotUnavailable =
      'Riot đang gặp sự cố. Hãy thử lại sau ít phút.';
  static String errorRiotUnavailableIn(String duration) =>
      'Riot đang gặp sự cố. Hãy thử lại sau $duration.';
  static const errorStorageFull =
      'Kho ảnh của Cộng đồng đã đầy. Bạn vẫn đăng bài được, nhưng chưa thể kèm '
      'ảnh. Hãy thử lại sau.';
  static const errorForbidden =
      'Bạn chưa thể thực hiện việc này. Hãy xem Tiêu chuẩn cộng đồng hoặc liên hệ ValHub.';
  static const errorNotFound = 'Nội dung này không còn tồn tại.';
  static const errorInvalid =
      'Nội dung chưa được chấp nhận. Hãy kiểm tra lại rồi thử lại.';
  static const errorRateLimited =
      'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau ít phút.';
  static String errorRateLimitedIn(String duration) =>
      'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau $duration.';
  static const errorImageTooLarge =
      'Ảnh quá lớn (tối đa 2 MB). Hãy chọn ảnh khác.';
  static const errorImageType = 'Hãy chọn ảnh JPEG, PNG hoặc WebP.';
  static const errorPickImage = 'Chưa mở được thư viện ảnh. Hãy thử lại.';
  static const errorTitle = 'Chưa hoàn tất';
  static const rateLimitedTitle = 'Hãy đợi một chút';

  // ----------------------------------------------------------------- feed
  static const feedEmptyTitle = 'Bảng tin còn trống';
  static const feedEmptyBody =
      'Hãy là người đầu tiên chia sẻ cửa hàng, Chợ Đêm hay khoảnh khắc của '
      'bạn!';
  static const newPost = 'Đăng bài';
  static const writePost = 'Viết bài';
  static const composerHint = 'Bạn đang nghĩ gì về VALORANT hôm nay?';
  static const composerTitle = 'Bài viết mới';
  static const publish = 'Đăng';
  static const publishing = 'Đang đăng…';
  static const posted = 'Đã đăng bài!';
  static const addPhotos = 'Thêm ảnh';
  static String photoCount(int n, int max) => '$n/$max ảnh';
  static const removePhoto = 'Bỏ ảnh';
  static const emptyPost = 'Hãy viết gì đó hoặc thêm ảnh.';
  static String tooLong(int max) => 'Tối đa $max ký tự.';
  static String maxPhotos(int max) => 'Tối đa $max ảnh.';
  static const uploading = 'Đang tải ảnh lên…';
  static const discardTitle = 'Bỏ bài viết?';
  static const discardBody = 'Nội dung bạn vừa viết sẽ không được lưu.';
  static const discard = 'Bỏ';
  static const keepEditing = 'Viết tiếp';

  static const kindStore = 'Cửa hàng hôm nay';
  static const kindNightMarket = 'Chợ Đêm';
  static String storeOf(String date) => 'Cửa hàng ngày $date';
  static String nightMarketOf(String date) => 'Chợ Đêm ngày $date';
  static String offersTotal(String amount) => 'Tổng $amount';
  static String offerSemantics(String name, String price) => '$name, $price';
  static const removeAttachment = 'Bỏ đính kèm';

  static const like = 'Thích';
  static const unlike = 'Bỏ thích';
  static String likes(String n) => '$n lượt thích';
  static String comments(String n) => '$n bình luận';
  static const comment = 'Bình luận';
  static const viewImage = 'Xem ảnh';
  static String imageOf(int i, int n) => 'Ảnh $i/$n';

  static const deletePost = 'Xóa bài viết';
  static const deletePostTitle = 'Xóa bài viết?';
  static const deletePostBody =
      'Bài viết và toàn bộ bình luận sẽ bị xóa vĩnh viễn.';
  static const deleted = 'Đã xóa.';
  static const delete = 'Xóa';
  static const report = 'Báo cáo';
  static const reportTitle = 'Báo cáo nội dung';
  static const reportPrompt = 'Vì sao bạn báo cáo nội dung này?';
  static const reportConfirmTitle = 'Gửi báo cáo?';
  static const reportConfirmBody =
      'Nội dung bị nhiều người báo cáo sẽ được ẩn khỏi Cộng đồng.';
  static const send = 'Gửi';
  static const reported = 'Cảm ơn bạn! Báo cáo đã được gửi.';

  /// Report reasons: server value → label.
  static const reportReasons = <String, String>{
    'spam': 'Spam hoặc quảng cáo',
    'harassment': 'Quấy rối, xúc phạm',
    'inappropriate': 'Nội dung không phù hợp',
    'scam': 'Lừa đảo, mua bán tài khoản',
    'other': 'Lý do khác',
  };

  // -------------------------------------------------------------- comments
  static const postTitle = 'Bài viết';
  static const commentsTitle = 'Bình luận';
  static String commentsHeader(String n) => 'Bình luận · $n';
  static const commentHint = 'Viết bình luận…';
  static const noComments = 'Chưa có bình luận. Hãy mở lời trước nhé!';
  static const deleteComment = 'Xóa bình luận';
  static const deleteCommentTitle = 'Xóa bình luận?';
  static const deleteCommentBody = 'Bình luận này sẽ bị xóa vĩnh viễn.';
  static const sendComment = 'Gửi bình luận';
  static const postNotFound = 'Bài viết này đã bị xóa hoặc ẩn.';

  // ------------------------------------------------------------------ LFG
  static const lfgEmptyTitle = 'Chưa ai tìm đồng đội';
  static const lfgEmptyBody =
      'Tạo tin để người chơi khác vào tổ đội của bạn chỉ với một chạm.';
  static const createLfg = 'Tạo tin tìm đồng đội';
  static const createLfgShort = 'Tạo tin';
  static const allModes = 'Tất cả';
  static const region = 'Khu vực';
  static String slotsWanted(int n) => 'Cần $n người';
  static String expiresIn(String t) => 'Còn $t';
  static const expired = 'Đã hết hạn';
  static const joinParty = 'Vào tổ đội';
  static const joinConfirmTitle = 'Vào tổ đội này?';
  static String joinConfirmBody(String name) =>
      'Bạn sẽ rời tổ đội hiện tại trong VALORANT để vào tổ đội của $name.';
  static const join = 'Vào';
  static const joined = 'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.';
  static const joinGameNotRunning =
      'Hãy mở VALORANT trên máy tính hoặc console rồi thử lại.';
  static const joinInvalidCode =
      'Mã tổ đội không còn hiệu lực hoặc tổ đội đã đủ người.';
  static const myPost = 'Tin của bạn';
  static const removeLfg = 'Gỡ tin';
  static const removeLfgTitle = 'Gỡ tin tìm đồng đội?';
  static const removeLfgBody = 'Người khác sẽ không thấy tin này nữa.';
  static const lfgRemoved = 'Đã gỡ tin.';
  static const lfgPosted = 'Đã đăng tin tìm đồng đội!';
  static const autoRefresh = 'Tự làm mới mỗi 20 giây';
  static String partyCodeValue(String code) => 'Mã tổ đội: $code';
  static String lfgSheetSubtitle(String region) =>
      'Khu vực: $region · $lfgExpiryNote';
  static String noPartyWithReason(String reason) => '$noParty\n$reason';

  // Create LFG sheet
  static const mode = 'Chế độ';
  static const slots = 'Số người cần';
  static const note = 'Ghi chú';
  static const noteHint = 'VD: cần 1 người Kiểm soát, có mic, vui vẻ là chính';
  static const partyCode = 'Mã tổ đội';
  static const partyCodeHint = 'VD: A1B2C3';
  static const generateCode = 'Tạo mã tổ đội';
  static const generatingCode = 'Đang tạo mã…';
  static const codeGenerated = 'Đã tạo mã từ tổ đội hiện tại của bạn.';
  static const codeInvalid = 'Mã gồm đúng 6 chữ cái in hoa hoặc chữ số.';
  static const codeRequired = 'Hãy nhập hoặc tạo mã tổ đội.';
  static const noParty =
      'Không tìm thấy tổ đội. Hãy mở VALORANT rồi thử lại, hoặc nhập mã thủ '
      'công.';
  static const postLfg = 'Đăng tin';
  static const lfgExpiryNote = 'Tin tự hết hạn sau 30 phút.';
  static const decrease = 'Giảm';
  static const increase = 'Tăng';

  /// LFG modes (VF §8.9).
  static String modeLabel(String? mode) => switch (mode) {
    'competitive' => 'Xếp hạng',
    'unrated' => 'Đấu thường',
    'swiftplay' => 'Siêu Tốc',
    'spikerush' => 'Đặt Spike Nhanh',
    'deathmatch' => 'Sinh Tử',
    'teamdeathmatch' => 'Sinh Tử Đội',
    'premier' => 'Premier',
    'custom' => 'Chơi tự do',
    _ => 'Khác',
  };

  /// Community regions (`region` of the API).
  static String regionLabel(String region) => switch (region) {
    'ap' => 'Châu Á - Thái Bình Dương',
    'na' => 'Bắc Mỹ',
    'eu' => 'Châu Âu',
    'kr' => 'Hàn Quốc',
    'latam' => 'Mỹ Latinh',
    'br' => 'Brazil',
    _ => 'Chưa rõ máy chủ',
  };

  // ---------------------------------------------------------- skin votes
  static const skinsEmptyTitle = 'Chưa có lượt bình chọn';
  static const skinsEmptyBody =
      'Thả tim cho skin bạn thích nhất để đưa nó lên bảng xếp hạng!';
  static const periodAll = 'Tất cả';
  static const periodWeek = 'Tuần này';
  static const allWeapons = 'Tất cả vũ khí';
  static String votes(String n) => '$n lượt thích';
  static String rankNumber(String n) => '#$n';
  static String rankSemantics(String n, String name) => 'Hạng $n: $name';
  static const vote = 'Thả tim cho skin này';
  static const unvote = 'Bỏ tim';
  static const communityVotes = 'Cộng đồng yêu thích';

  // ---------------------------------------------------------------- share
  static String sharePostTitle(String name) => 'Bài viết của $name trên ValHub';
  static const shareStore = 'Khoe lên Cộng đồng';
  static const shareStoreHint = 'Khoe cửa hàng hôm nay với mọi người';
  static const shareNightMarketHint = 'Khoe Chợ Đêm của bạn với mọi người';

  // -------------------------------------------------------- skin reviews
  static const periodAllTime = 'Từ trước tới giờ';
  static const sortVotes = 'Yêu thích nhất';
  static const sortRating = 'Đánh giá cao nhất';
  static const sortReviews = 'Nhiều đánh giá nhất';
  static const noRatings = 'Chưa có đánh giá';
  static String ratingCount(String n) => '$n đánh giá';
  static String ratingSummary(String avg, String n) => '$avg · $n đánh giá';
  static String starsSemantics(String avg) => '$avg trên 5 sao';
  static const writeFirstReview = 'Viết đánh giá đầu tiên';
  static const reviewTitle = 'Đánh giá skin';
  static const reviewsSection = 'Đánh giá';
  static String reviewsHeader(String n) => 'Đánh giá · $n';
  static const sortNewest = 'Mới nhất';
  static const sortHelpful = 'Hữu ích nhất';
  static const reviewsEmptyTitle = 'Chưa có đánh giá';
  static const reviewsEmptyBody = 'Chưa có đánh giá — hãy là người đầu tiên!';
  static const yourReview = 'Đánh giá của bạn';
  static const tapToRate = 'Chạm vào sao để chấm điểm skin này';
  static const editReview = 'Sửa';
  static const deleteReview = 'Xóa đánh giá';
  static const deleteReviewTitle = 'Xóa đánh giá của bạn?';
  static const deleteReviewBody =
      'Điểm và nhận xét của bạn cho skin này sẽ bị xóa.';
  static const reviewDeleted = 'Đã xóa đánh giá.';
  static const reviewSaved = 'Đã lưu đánh giá!';
  static const reviewHint = 'Chia sẻ cảm nhận về skin này (không bắt buộc)';
  static const saveReview = 'Lưu đánh giá';
  static const pickRating = 'Hãy chọn số sao.';
  static const helpful = 'Hữu ích';
  static String helpfulCount(String n) => 'Hữu ích · $n';
  static const edited = 'đã sửa';
  static String starLabel(int n) => '$n sao';
  static const ratingWords = ['Tệ', 'Chưa ổn', 'Ổn', 'Đẹp', 'Tuyệt phẩm'];
  static const signInToReview = 'Thêm tài khoản Riot để đánh giá skin.';
  static const playVideo = 'Xem video';
  static const skinNotFound = 'Không tìm thấy skin này.';
  static const openReviews = 'Xem đánh giá';

  // -------------------------------------------------------------- LFG v2
  static const anyRank = 'Mọi rank';
  static const rankRange = 'Khoảng rank';
  static const rankFrom = 'Từ';
  static const rankTo = 'Đến';
  static String rankBetween(String a, String b) => '$a – $b';
  static const rankRangeInvalid =
      'Hãy chọn rank thấp nhất không cao hơn rank cao nhất.';
  static const roles = 'Vai trò cần';
  static const roleFlex = 'Linh hoạt';
  static const mic = 'Cần mic';
  static const micOn = 'Có mic';
  static const language = 'Ngôn ngữ';
  static const anyLanguage = 'Mọi ngôn ngữ';

  /// VALORANT languages by their native names (not translated).
  static const languageNames = <String, String>{
    'ar': 'العربية',
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'id': 'Bahasa Indonesia',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'pl': 'Polski',
    'pt': 'Português',
    'ru': 'Русский',
    'th': 'ไทย',
    'tr': 'Türkçe',
    'vi': 'Tiếng Việt',
    'zh-CN': '简体中文',
    'zh-TW': '繁體中文',
  };

  /// Native name of an LFG language code; "Mọi ngôn ngữ" for `any`.
  static String languageLabel(String code) =>
      languageNames[code] ?? anyLanguage;

  /// Short tag of a language on cards ("JA", "ZH-TW"); empty for `any`.
  static String languageTag(String code) =>
      languageNames.containsKey(code) ? code.toUpperCase() : '';
  static const partySize = 'Tổ đội hiện có';
  static String partySizeValue(int n) => '$n người';
  static const partySizeFromGame = 'Lấy từ tổ đội trong game';
  static String slotsTooMany(int max) =>
      'Tổ đội có tối đa 5 người: chỉ còn $max chỗ.';
  static const codeAuto =
      'Để trống: ValHub tự tạo mã từ tổ đội trong game khi bạn đăng tin.';
  static const codeAutoFailed =
      'Không tạo được mã tổ đội. Hãy mở VALORANT hoặc nhập mã thủ công.';
  static const matchMyRank = 'Phù hợp rank của bạn';
  static const outOfRange = 'Ngoài khoảng rank';
  static const statusOpen = 'Đang tìm';
  static const statusFull = 'Đã đủ người';
  static const statusInGame = 'Đang trong trận';
  static String joinsCount(String n) => '$n người đã yêu cầu vào';
  static const extend = 'Gia hạn';
  static const extended = 'Đã gia hạn tin thêm 30 phút.';
  static const lfgExpiredRepost =
      'Tin của bạn đã hết hạn. Hãy đăng tin mới để tìm đồng đội.';
  static const liveMembers = 'Thành viên';
  static String memberJoined(String name) => '$name đã vào tổ đội';
  static const memberJoinedBody = 'Tin tìm đồng đội của bạn vừa có người vào.';
  static const joinedHint = 'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.';
  static const joinPartyFull = 'Tổ đội này đã đủ người.';
  static const joinCodeExpired =
      'Mã tổ đội đã hết hạn hoặc không còn hiệu lực.';
  static const refreshList = 'Làm mới';
  static const agentsPicked = 'Đặc vụ đã chọn';
  static const filters = 'Bộ lọc';
  static const anyRole = 'Mọi vai trò';

  // ------------------------------------------------------------ previews
  static const lfgPreviewTitle = 'Tìm đồng đội hợp rank';
  static const trendingTitle = 'Skin được yêu thích toàn cầu';

  // --------------------------------------------------------- scopes (v3)
  static const scopeCountry = 'Nước bạn';
  static const scopeRegion = 'Khu vực';
  static const scopeGlobal = 'Quốc tế';
  static const scopeWorldwide = 'Toàn cầu';
  static const countriesTitle = 'Cộng đồng các nước';
  static const countriesSearchHint = 'Tìm quốc gia…';
  static const countriesEmpty = 'Không tìm thấy quốc gia phù hợp.';
  static const yourCountry = 'Nước của bạn';
  static const backToMyCountry = 'Về nước bạn';
  static String communityActivity(String posts, String authors) =>
      '$posts bài · $authors người';
  static String communityLfg(String n) => '$n tin tìm đồng đội';
  static const languageFilter = 'Ngôn ngữ nội dung';
  static const languageFilterHint =
      'Chỉ hiện nội dung viết bằng các ngôn ngữ đã chọn. Bỏ trống để xem tất cả.';
  static String languagesSelected(int n) => '$n ngôn ngữ';
  static const clearFilter = 'Bỏ chọn';
  static const apply = 'Áp dụng';
  static const feedEmptyScopeTitle = 'Chưa có bài trong phạm vi này';
  static const feedEmptyScopeBody =
      'Thử xem bài từ cộng đồng quốc tế hoặc đổi bộ lọc.';
  static const feedEmptyGuestBody =
      'Chưa có bài mới. Quay lại sau hoặc tham gia để chia sẻ.';
  static const feedEmptyFilteredBody =
      'Không có bài phù hợp. Thử đổi ngôn ngữ hoặc bỏ bộ lọc.';
  static const lfgSameShardNote = 'Chỉ người cùng máy chủ mới vào tổ đội được.';
  static String lfgOtherShardNote(String region) =>
      'Bạn đang xem máy chủ $region — chỉ người cùng máy chủ với tài khoản của bạn mới vào tổ đội được.';
  static String countryName(String code) => countryNames[code] ?? code;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n
  /// phase localizes them.
  static const countryNames = <String, String>{
    'AE': 'Các Tiểu vương quốc Ả Rập Thống nhất',
    'AL': 'Albania',
    'AM': 'Armenia',
    'AR': 'Argentina',
    'AT': 'Áo',
    'AU': 'Úc',
    'AZ': 'Azerbaijan',
    'BA': 'Bosnia và Herzegovina',
    'BD': 'Bangladesh',
    'BE': 'Bỉ',
    'BG': 'Bulgaria',
    'BH': 'Bahrain',
    'BN': 'Brunei',
    'BO': 'Bolivia',
    'BR': 'Brazil',
    'BY': 'Belarus',
    'CA': 'Canada',
    'CH': 'Thụy Sĩ',
    'CL': 'Chile',
    'CN': 'Trung Quốc',
    'CO': 'Colombia',
    'CR': 'Costa Rica',
    'CU': 'Cuba',
    'CY': 'Síp',
    'CZ': 'Séc',
    'DE': 'Đức',
    'DK': 'Đan Mạch',
    'DO': 'Cộng hòa Dominica',
    'DZ': 'Algeria',
    'EC': 'Ecuador',
    'EE': 'Estonia',
    'EG': 'Ai Cập',
    'ES': 'Tây Ban Nha',
    'ET': 'Ethiopia',
    'FI': 'Phần Lan',
    'FR': 'Pháp',
    'GB': 'Vương quốc Anh',
    'GE': 'Georgia',
    'GH': 'Ghana',
    'GR': 'Hy Lạp',
    'GT': 'Guatemala',
    'HK': 'Hồng Kông',
    'HN': 'Honduras',
    'HR': 'Croatia',
    'HU': 'Hungary',
    'ID': 'Indonesia',
    'IE': 'Ireland',
    'IL': 'Israel',
    'IN': 'Ấn Độ',
    'IQ': 'Iraq',
    'IR': 'Iran',
    'IS': 'Iceland',
    'IT': 'Ý',
    'JO': 'Jordan',
    'JP': 'Nhật Bản',
    'KE': 'Kenya',
    'KH': 'Campuchia',
    'KR': 'Hàn Quốc',
    'KW': 'Kuwait',
    'KZ': 'Kazakhstan',
    'LA': 'Lào',
    'LB': 'Liban',
    'LK': 'Sri Lanka',
    'LT': 'Litva',
    'LU': 'Luxembourg',
    'LV': 'Latvia',
    'LY': 'Libya',
    'MA': 'Maroc',
    'MD': 'Moldova',
    'ME': 'Montenegro',
    'MK': 'Bắc Macedonia',
    'MM': 'Myanmar',
    'MN': 'Mông Cổ',
    'MO': 'Ma Cao',
    'MT': 'Malta',
    'MX': 'Mexico',
    'MY': 'Malaysia',
    'NG': 'Nigeria',
    'NI': 'Nicaragua',
    'NL': 'Hà Lan',
    'NO': 'Na Uy',
    'NP': 'Nepal',
    'NZ': 'New Zealand',
    'OM': 'Oman',
    'PA': 'Panama',
    'PE': 'Peru',
    'PH': 'Philippines',
    'PK': 'Pakistan',
    'PL': 'Ba Lan',
    'PR': 'Puerto Rico',
    'PT': 'Bồ Đào Nha',
    'PY': 'Paraguay',
    'QA': 'Qatar',
    'RO': 'Romania',
    'RS': 'Serbia',
    'RU': 'Nga',
    'SA': 'Ả Rập Xê Út',
    'SE': 'Thụy Điển',
    'SG': 'Singapore',
    'SI': 'Slovenia',
    'SK': 'Slovakia',
    'SV': 'El Salvador',
    'TH': 'Thái Lan',
    'TL': 'Đông Timor',
    'TN': 'Tunisia',
    'TR': 'Thổ Nhĩ Kỳ',
    'TW': 'Đài Loan',
    'UA': 'Ukraine',
    'US': 'Hoa Kỳ',
    'UY': 'Uruguay',
    'UZ': 'Uzbekistan',
    'VE': 'Venezuela',
    'VN': 'Việt Nam',
    'ZA': 'Nam Phi',
  };

  // ---------------------------------------------------------- translation
  static const translate = 'Dịch bằng Google';
  static const translating = 'Đang dịch…';
  static const downloadingModels = 'Đang tải gói dịch…';
  static const showOriginal = 'Xem bản gốc';
  static const showTranslation = 'Xem bản dịch';
  static const translatedByGoogle = 'Dịch tự động bởi Google';
  static const translateFailed = 'Không dịch được. Hãy thử lại.';
  static const translateUnavailable = 'Thiết bị này chưa hỗ trợ dịch trên máy.';
  static const translateDownloadTitle = 'Tải gói dịch trên máy?';
  static String translateDownloadBody(String from, String to, String size) =>
      'Để dịch từ $from sang $to, ValHub cần tải gói ngôn ngữ từ Google (khoảng $size). '
      'Chỉ tải một lần; nội dung được dịch hoàn toàn trên máy của bạn và '
      'không gửi tới máy chủ nào.';
  static String modelSize(int mb) => '$mb MB';
  static const download = 'Tải và dịch';
  static const googleDisclaimerTitle = 'Bản dịch của Google';
  static const googleDisclaimer =
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE '
      'DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR '
      'IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY '
      'IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR '
      'PURPOSE AND NONINFRINGEMENT.';

  // ------------------------------------------------- data rights (Settings)
  static const dataTitle = 'Dữ liệu Cộng đồng của bạn';
  static String dataFooter(String riotId) =>
      'Áp dụng cho tài khoản đang dùng: $riotId. Tệp tải về không chứa mật '
      'khẩu hay dữ liệu đăng nhập Riot.';

  static const exportTitle = 'Tải dữ liệu của tôi';
  static const exportSubtitle =
      'Bản sao mọi thứ bạn đã đăng trong Cộng đồng: bài viết, bình luận, đánh '
      'giá, lượt thích, bình chọn và tin tìm đồng đội.';
  static const exportSubject = 'Dữ liệu Cộng đồng ValHub';
  static const exportPreparing = 'Đang chuẩn bị…';

  static const deleteDataTitle = 'Xóa dữ liệu Cộng đồng của tôi';
  static const deleteDataSubtitle =
      'Xóa vĩnh viễn mọi thứ bạn đã đăng lên Cộng đồng.';
  static const deleteDataConfirmTitle = 'Xóa dữ liệu Cộng đồng?';
  static String deleteDataConfirmBody(String riotId) =>
      'Toàn bộ bài viết, bình luận, đánh giá skin, lượt thích, bình chọn, '
      'tin tìm đồng đội và ảnh của $riotId trên Cộng đồng ValHub sẽ bị xóa '
      'vĩnh viễn và không thể khôi phục. Muốn dùng tiếp tài khoản này trong '
      'ValHub, bạn cần đồng ý lại; bạn vẫn có thể chuyển sang tài khoản khác '
      'hoặc đăng xuất tài khoản này.\n\n'
      'Tài khoản Riot và dữ liệu trong game không bị ảnh hưởng. Hãy tải dữ '
      'liệu về trước nếu bạn muốn giữ một bản sao.';
  static const deleteDataConfirm = 'Xóa vĩnh viễn';
  static const dataDeleted = 'Đã xóa dữ liệu Cộng đồng của bạn.';

  static const withdrawTitle = 'Rút lại đồng ý';
  static const withdrawSubtitle =
      'Ngừng dùng Cộng đồng bằng tài khoản này. Bài đã đăng vẫn được giữ.';
  static const withdrawConfirmTitle = 'Rút lại đồng ý?';
  static String withdrawConfirmBody(String riotId) =>
      'ValHub sẽ ngừng dùng Cộng đồng bằng $riotId và xóa kết nối Cộng đồng '
      'trên thiết bị này. Muốn dùng tiếp tài khoản này trong ValHub, bạn cần '
      'đồng ý lại; bạn vẫn có thể chuyển sang tài khoản khác hoặc đăng xuất '
      'tài khoản này.\n\n'
      'Bài viết, bình luận, đánh giá, bình chọn và tin tìm đồng đội đã đăng '
      'vẫn còn trên '
      'Cộng đồng và vẫn hiện Riot ID của bạn cho đến khi bạn xóa chúng từng '
      'cái, hoặc chọn "Xóa dữ liệu Cộng đồng của tôi".';
  static const withdrawConfirm = 'Rút lại';
  static const consentWithdrawn =
      'Đã rút lại đồng ý. Cần đồng ý lại để tiếp tục sử dụng app.';

  // -------------------------------------------------------------- consent
  static const consentTitle = 'Quyền riêng tư và Cộng đồng ValHub';
  static String consentAccount(String riotId) => 'Tài khoản: $riotId';
  static const consentVerify =
      'ValHub gửi quyền truy cập Riot cho máy chủ Cộng đồng để xác minh Riot ID khi kết nối và '
      'kiểm tra quyền sở hữu skin khi bạn lưu đánh giá. Máy chủ chỉ đọc dữ liệu cần thiết, '
      'dùng xong bỏ ngay quyền truy cập, không lưu.';
  static const consentPublic =
      'Người khác sẽ thấy Riot ID, thẻ người chơi, rank và quốc gia của bạn.';
  static const consentLocal =
      'Mật khẩu và dữ liệu đăng nhập khác của bạn luôn ở lại trên thiết bị '
      'này. Bạn có thể rút lại đồng ý trong Cài đặt.';
  static const consentPrivacy = 'Chính sách quyền riêng tư';
  static const consentGuidelines = 'Tiêu chuẩn cộng đồng';
  static const consentAgree = 'Đồng ý và tiếp tục';
  static const consentLater = 'Để sau';
  static const consentGateAction = 'Tham gia';
  static const anonymousBanner = 'Đang xem ẩn danh';
  static const lfgGateTitle = 'Tìm đồng đội dành cho thành viên';
  static const lfgGateBody =
      'Tham gia (xác minh Riot ID một lần) để xem tin của người chơi cùng máy '
      'chủ và đăng tin tìm đồng đội của bạn. Bạn vẫn xem Bảng tin và Xếp hạng '
      'skin bình thường.';
  static const errorConsent =
      'Hãy đồng ý chia sẻ Riot ID với Cộng đồng để tiếp tục.';
  static const muteAuthor = 'Ẩn người này';
  static const blockAuthor = 'Chặn trên thiết bị';
  static const hiddenAuthors = 'Người đã ẩn và chặn';
  static const hiddenAuthorsEmpty = 'Chưa ẩn hoặc chặn ai';
  static const hiddenAuthorsHint =
      'Áp dụng riêng cho tài khoản này trên thiết bị này. Nội dung của họ được ẩn; họ vẫn có thể xem nội dung công khai của bạn.';
  static const unhideAuthor = 'Bỏ ẩn / bỏ chặn';
}
