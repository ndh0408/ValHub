/// Vietnamese strings of the "Cộng đồng" feature (feed, LFG, skin
/// leaderboard; docs/community-api.md, VF §8).
abstract final class CommunityStrings {
  static const title = 'Cộng đồng';

  // ------------------------------------------------------------- sections
  static const sectionFeed = 'Bảng tin';
  static const sectionLfg = 'Tìm đồng đội';
  static const sectionSkins = 'Xếp hạng skin';

  // ------------------------------------------------------- general states
  static const unavailableTitle = 'Cộng đồng chưa sẵn sàng';
  static const unavailableBody =
      'Máy chủ Cộng đồng đang được chuẩn bị. Bạn quay lại sau nhé!';
  static const noAccountTitle = 'Đăng nhập để tham gia';
  static const noAccountBody =
      'Thêm tài khoản Riot để đăng bài, tìm đồng đội và bình chọn skin.';
  static const privacyNote =
      'Riot ID của bạn được xác minh một lần với máy chủ Cộng đồng ValVN. '
      'Máy chủ không lưu mật khẩu, token hay PUUID.';
  static const you = 'Bạn';
  static const unknownPlayer = 'Người chơi';
  static const moreActions = 'Tùy chọn khác';
  static String tagSuffix(String tag) => '#$tag';
  static String riotId(String name, String tag) => '$name#$tag';
  static String dotJoin(Iterable<String> parts) => parts.join(' · ');
  static String pageOf(String i, String n) => '$i/$n';
  static String charCount(String n, String max) => '$n/$max';
  static const retry = 'Thử lại';
  static const loadMoreFailed = 'Không tải thêm được.';

  // --------------------------------------------------------------- errors
  static const errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const errorNetwork =
      'Không kết nối được máy chủ Cộng đồng. Kiểm tra mạng rồi thử lại.';
  static const errorTimeout =
      'Máy chủ Cộng đồng phản hồi quá lâu. Vui lòng thử lại.';
  static const errorServer =
      'Máy chủ Cộng đồng đang gặp sự cố. Vui lòng thử lại sau ít phút.';
  static const errorUnauthorized =
      'Phiên Cộng đồng đã hết hạn. Vui lòng thử lại.';
  static const errorRiotRejected =
      'Riot chưa xác minh được tài khoản của bạn. Hãy đăng nhập lại tài khoản '
      'Riot rồi thử lại.';
  static const errorForbidden = 'Bạn không có quyền thực hiện thao tác này.';
  static const errorNotFound = 'Nội dung này không còn tồn tại.';
  static const errorInvalid = 'Nội dung chưa hợp lệ. Kiểm tra lại rồi thử lại.';
  static const errorRateLimited =
      'Bạn thao tác hơi nhanh. Thử lại sau ít phút.';
  static String errorRateLimitedIn(String duration) =>
      'Bạn thao tác hơi nhanh. Thử lại sau $duration.';
  static const errorImageTooLarge =
      'Ảnh quá lớn (tối đa 2 MB). Hãy chọn ảnh khác.';
  static const errorImageType = 'Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.';
  static const errorPickImage = 'Không mở được thư viện ảnh.';
  static const errorTitle = 'Có lỗi xảy ra';
  static const rateLimitedTitle = 'Chậm lại một chút';

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
  static const noteHint = 'VD: cần 1 Controller, mic đầy đủ, vui vẻ là chính';
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
    'ap' => 'Châu Á - TBD',
    'na' => 'Bắc Mỹ',
    'eu' => 'Châu Âu',
    'kr' => 'Hàn Quốc',
    'latam' => 'Mỹ Latinh',
    'br' => 'Brazil',
    _ => region.toUpperCase(),
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
  static const rankRangeInvalid = 'Rank thấp nhất phải nhỏ hơn rank cao nhất.';
  static const roles = 'Vai trò cần';
  static const roleFlex = 'Linh hoạt';
  static const mic = 'Cần mic';
  static const micOn = 'Có mic';
  static const language = 'Ngôn ngữ';
  static String languageLabel(String code) => switch (code) {
    'vi' => 'Tiếng Việt',
    'en' => 'English',
    _ => 'Bất kỳ',
  };
  static String languageFlag(String code) => switch (code) {
    'vi' => 'VN',
    'en' => 'EN',
    _ => '',
  };
  static const partySize = 'Tổ đội hiện có';
  static String partySizeValue(int n) => '$n người';
  static const partySizeFromGame = 'Lấy từ tổ đội trong game';
  static String slotsTooMany(int max) =>
      'Tổ đội có tối đa 5 người: chỉ còn $max chỗ.';
  static const codeAuto =
      'Để trống: ValVN tự tạo mã từ tổ đội trong game khi bạn đăng tin.';
  static const codeAutoFailed =
      'Không tạo được mã tổ đội. Hãy mở VALORANT hoặc nhập mã thủ công.';
  static const matchMyRank = 'Phù hợp rank của bạn';
  static const outOfRange = 'Ngoài khoảng rank';
  static const statusOpen = 'Đang tìm';
  static const statusFull = 'Đã đủ người';
  static const statusInGame = 'Đang trong trận';
  static String joinsCount(String n) => '$n người đã vào';
  static const extend = 'Gia hạn';
  static const extended = 'Đã gia hạn tin thêm 30 phút.';
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
  static const trendingTitle = 'Skin hot trong tuần';
}
