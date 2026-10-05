# Tiến độ ValHub (điểm dừng để làm tiếp)

Hotfix mới nhất 05/10 build 4025: [ảnh Guardian / CDN placeholder](SKIN_IMAGE_FALLBACK_2026-10-05.md). Đã xác minh ảnh cha của Guardian Hoàng Gia trả HTTP 200 nhưng là dấu X; ưu tiên ảnh cấp 1 thật trong model dùng chung. Analyzer 0, 377 test liên quan và Android 10 public flows đạt; Mac 4 test và unsigned iOS build đạt. Nâng APK giữ sáu tài khoản/wishlist/cài đặt; MCP/cache xác nhận ảnh súng 512×104 đúng byte. Chưa nghiệm thu toàn bộ; kết quả full-suite/i18n của 4024 nằm ở checkpoint bên dưới.

Checkpoint trước 05/10 build 4024: [tài nguyên pháp lý / fallback / CI local](LEGAL_ASSETS_AND_FALLBACK_2026-10-05.md). Bốn văn bản pháp lý đã chuyển sang JSON theo kiến trúc hiện có, giữ nguyên toàn bộ điều khoản; thêm loader/fallback/error/retry và CI kiểm tra Markdown. Windows 4.411 tests mỗi cấu hình, analyzer 0; backend 949; Mac 158 tests và unsigned iOS 4024; Android native 6/public 10. Mobile MCP đọc đủ bốn văn bản, nâng APK giữ sáu tài khoản/wishlist/cài đặt. Đã dọn 2,44 GiB cache/staging cũ trên Mac. Cutover còn 0 refs / 5 detected literals / 52 manual inventory entries; chỉ VI ships, chưa nghiệm thu 18 ngôn ngữ hay signed store release.

Checkpoint trước 05/10 build 4023: [trạng thái máy chủ / coverage / release gates](DEEP_REVIEW_CHECKPOINT_2026-10-05.md). Đã sửa phản hồi status sai cấu trúc bị coi là bình thường và lỗi refresh che nút thử lại. Windows 4.396 tests mỗi cấu hình, analyzer 0; Mac 165 tests và unsigned iOS 4023; Android native 6/public 10, nâng APK giữ sáu tài khoản và kiểm tra mất mạng/retry bằng Mobile MCP. Backend 949, runtime afa7162 giữ nguyên. Coverage 89,96% dòng được instrument, còn 16 file ngoài LCOV. Cutover vẫn 1 ref / 768 literals / 52 structural; chưa nghiệm thu toàn bộ hay signed store release.

Checkpoint trước 05/10 build 4022: [đối chiếu audit và chat isolation](AUDIT_RECONCILIATION_2026-10-05.md). Đã đối chiếu báo cáo bên ngoài và sửa lỗi bản nháp/callback chat lẫn giữa tài khoản hoặc người nhận. Windows 4.389 tests mỗi cấu hình, analyzer 0; Mac Social/XMPP 128, analyzer 0 và unsigned iOS build; Android native 6/public 10. Nâng APK giữ sáu accounts/active/wishlist/settings, Mobile MCP/cache/log đã kiểm tra. Backend vẫn healthy ở afa7162; i18n gate vẫn đỏ, chưa nghiệm thu toàn bộ hay signed release.

Checkpoint production 05/10: [production deployment và tài khoản thật](PRODUCTION_DEPLOYMENT_2026-10-05.md). Backend `afa7162` đã deploy: API/backup/watchdog healthy, 13 migrations; bình luận và đánh giá skin sở hữu được tạo/đọc/xóa thật qua Mobile MCP. Giữ 5 người dùng/review/vote cũ và 6 tài khoản trên emulator; restore bản sao dữ liệu production đã qua. Flutter 4.386 tests mỗi cấu hình, analyzer 0; backend 949; Docker/Trivy pass. P0 i18n vẫn chặn phát hành toàn bộ; chưa có signed store release.

Checkpoint trước 04/10 build 4021: [danh mục skin / bình luận / CI local](SKIN_CATALOG_AND_DISCUSSION_2026-10-04.md). Windows 4.386 tests mỗi cấu hình, analyzer 0; backend 931; Mac Community 361 và unsigned iOS build; Android public 10/native 6. Docker build/restore/Trivy đã qua sau sửa 11 HIGH. Emulator giữ 6 tài khoản, hiển thị 1.373 skin sưu tầm thật. API bình luận production còn 404; i18n cutover còn 1 ref / 768 literals / 52 structural, chưa nghiệm thu toàn bộ.

Checkpoint 04/10 build 4020: [account/ownership verification](ACCOUNT_AND_OWNERSHIP_CHECKPOINT_2026-10-04.md). Windows/Mac 4,369 tests; analyzer 0; backend 917; Android public 10/native 6; unsigned iOS build succeeds. Whole-product acceptance, localization cutover and new full-catalog/comment requirements remain open.

Checkpoint trước 04/10: [Model / export riêng tư / CI local, build 4018](I18N_MODELS_AND_EXPORT_2026-10-04.md).

Đã chuyển nhãn model sang resources hiện tại, bảo toàn tên bộ trang bị cũ
và chặn chia sẻ export khi đổi/gỡ tài khoản hoặc rút đồng ý lúc đang tải.
Windows hai lượt/Mac đạt **4.332 tests**, analyzer 0; backend **900 tests**.
APK 4018 qua 10 public flows; Mobile MCP/cache/log kiểm tra bốn tài khoản thật,
giữ dữ liệu, khôi phục active ban đầu và đối chiếu bốn giá VP với Riot Cost.
iOS build trên Mac, **chưa ký/chưa nghiệm thu iPhone**. Cutover còn
**35 refs / 762 literals / 52 structural**, chỉ VI UI ships; toàn bộ sản phẩm
chưa được nghiệm thu, backend chưa deploy production.

Checkpoint trước 03/10: [LFG / phiên chờ / backend, build 4017](LFG_AND_SESSION_COMMIT_2026-10-03.md).

Đã khóa thao tác vào tổ đội, giữ đúng tài khoản khi chờ và làm mới cache sau
khi vào; số lượt yêu cầu không còn bị ghi thành người đã vào. Backend chặn ghi
muộn bằng phiên đã thu hồi; có bản rà soát 40 endpoint. Windows hai lượt/Mac
đạt **4.319 tests**, analyzer 0; backend **900 tests**. APK 4017 qua 10 public
flows và kiểm tra Mobile MCP/cache/log với **bốn tài khoản thật**, giữ dữ liệu
và đối chiếu giá VP. iOS build trên Mac, **chưa ký/chưa nghiệm thu iPhone**.
Cutover còn **62 refs / 762 literals / 52 structural**, chỉ VI UI ships.
Backend chưa deploy production; toàn bộ sản phẩm chưa được nghiệm thu.

Checkpoint trước 03/10: [Nhãn có điều kiện / semantics, build 4016](I18N_CONDITIONAL_VIEWS_2026-10-03.md).

Đã chuyển nhãn có điều kiện và semantics sang resources hiện tại,
giữ hành vi VI. Windows hai lượt và Mac đạt **4.312 tests**, analyzer 0;
backend **867 tests**. APK 4016 qua 10 public flows; Mobile MCP/cache/log kiểm
tra đủ **bốn tài khoản thật**, giữ wishlist/cài đặt, trả active ban đầu và đối
chiếu bốn giá VP với Riot Offer Cost. iOS 4016 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **62 refs / 762 literals / 52 structural**;
chỉ VI UI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Ngày/giờ / giá / thống kê, build 4015](I18N_FORMAT_CUTOVER_2026-10-03.md).

Đã chuyển ngày/giờ, hết hạn, giá và thống kê sang formatter/resources hiện tại,
giữ hành vi VI. Windows hai lượt và Mac đạt **4.307 tests**, analyzer 0;
backend **867 tests**. APK 4015 qua 10 public flows; Mobile MCP/cache/log kiểm
tra đủ **bốn tài khoản thật**, giữ wishlist/cài đặt, trả active ban đầu và đối
chiếu bốn giá VP với Riot Offer Cost. iOS 4015 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **94 refs / 762 literals / 52 structural**;
chỉ VI UI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Nhãn hiển thị / xác nhận ngôn ngữ, build 4014](I18N_VIEW_CUTOVER_2026-10-03.md).

Đã chuyển nhãn enum/widget/callback sang resources hiện tại và thêm xác nhận
ngôn ngữ cho screen reader sau khi lưu. Windows hai lượt và Mac đạt **4.299
tests**, analyzer 0; backend **867 tests**. APK 4014 qua 10 public flows;
Mobile MCP/cache/log kiểm tra chuyển đủ **bốn tài khoản thật**, đúng dữ liệu
cửa hàng từng tài khoản và trả active ban đầu. iOS 4014 build trên Mac,
**chưa ký/chưa nghiệm thu iPhone**. Cutover còn **129 refs / 762 literals /
52 structural**, chỉ VI UI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Nội dung / locale / RR loading, build 4013](I18N_CONTENT_CUTOVER_2026-10-03.md).

Đã tách nhãn nội dung khỏi model, thêm lựa chọn tên vật phẩm theo app hoặc 18
locale và giữ lựa chọn cũ; sửa thứ tự ghi cài đặt và race đọc RR. Windows hai
lượt và Mac đạt **4.292 tests**, analyzer 0; backend **867 tests**. APK 4013 qua
10 public flows, đã nâng cấp emulator và giữ bốn tài khoản/wishlist/cài đặt;
Mobile MCP/cache/log thật được kiểm tra. iOS 4013 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **195 refs / 762 literals / 52 structural**;
chỉ VI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Cộng đồng / cách ly tài khoản, build 4012](COMMUNITY_ACCOUNT_ISOLATION_2026-10-03.md).

Windows hai lượt và Mac đạt **4.265 tests**, analyzer 0; backend **867 tests**.
APK 4012 qua 10 public-flow cases, đã nâng cấp emulator có cửa sổ, giữ đủ
bốn tài khoản, wishlist và cài đặt. iOS 4012 đã build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **262 refs / 762 literal hits / 52 structural
members**, chỉ VI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Callback / cách ly tài khoản, build 4011](I18N_CALLBACK_ISOLATION_2026-10-03.md).
Đã sửa lỗi phản hồi tổ đội đến muộn và xóa mã của tài khoản khác khi chuyển;
Windows hai lượt và Mac đạt **4.246 tests**, analyzer 0. APK **4011** đã cài
trên emulator, 10 public flows đạt; bốn tài khoản/active/wishlist/cài đặt giữ
nguyên. iOS 4011 build trên Mac, **chưa ký/chưa test iPhone**. Cutover còn
**307 refs / 762 literal hits**, chưa nghiệm thu toàn bộ.


Checkpoint trước 03/10: [Render-time cutover, build 4010](I18N_RENDER_CUTOVER_2026-10-03.md).
Đã chuyển thêm **175 refs** (514 → **339**). Windows hai lượt và Mac đạt
**4.238 tests**, analyzer 0; backend 867, codemod 37, Android native 6 và public
flows 10 đạt. APK **4010** đã được kiểm tra trên emulator; bốn tài khoản/active/wishlist/
settings giữ nguyên. iOS 4010 build trên Mac nhưng **chưa ký/chưa test iPhone**.
Cutover còn đỏ, chưa nghiệm thu toàn bộ; chỉ tiếng Việt được phát hành.


Checkpoint 03/10: [Review Gemini và tích hợp ValHub](VALHUB_INTEGRATION_2026-10-03.md). Đã sửa lỗi
Gemini và gộp locale nền/bộ chọn/thông báo. Windows/Mac **4.236 tests**,
analyzer 0; backend 867, native 6, public-flow 10 cases đạt. APK/iOS không ký
**4009** đã build; bốn tài khoản, active, wishlist và settings giữ sau nâng APK.
Cutover còn **514 refs / 52 structural members**, chưa nghiệm thu toàn app.
Các số 02/10 bên dưới là checkpoint lịch sử.

Checkpoint mới 02/10: [Locale nền, bộ chọn và CI local](I18N_BACKGROUND_2026-10-02.md).
Windows vi/device-en và Mac toàn bộ đạt **4.232 tests**, analyzer 0 issues;
backend 867, native Android 6 và public-flow 10 cases đạt. APK/iOS không ký
**4007** đã build. Background locale, thông báo/kênh và reminder dùng generated
resources; UI picker chỉ mở shipped locales. Global còn **514 references /
52 structural members / 762 literal hits**, chỉ vi ships. Chủ dự án đã cho phép
test tài khoản thật; sau manual login, MCP/cache/log xác nhận metadata, ví và
loadout thật. Wishlist/restart/remove và đổi ba tài khoản đã trả trạng thái cũ;
thẻ tạm giữ sau restart nhưng trả thẻ cũ/đối chiếu PC còn chưa xác nhận.

Checkpoint trước: [Runtime locale và CI local](I18N_RUNTIME_2026-10-02.md).
Root đã nối locale/format provider và ghi snapshot theo thứ tự, giữ riêng tên
vật phẩm tiếng Anh. Windows **4.201 tests** đạt ở cả hai lượt; Mac **25 test liên
quan**, analyzer và build iOS **4006** không ký đạt. APK **4006** đạt 10 public
flows và đã cài trên emulator có cửa sổ. W5 vẫn partial, chỉ vi ships;
không coi snapshot mới là đã dịch thông báo nền.

Checkpoint trước 02/10: [Final gap audit và CI local](FINAL_GAP_AUDIT_2026-10-02.md).
4.197 Flutter tests đạt trên Windows và Mac; lượt device locale `en` trên Windows
cũng đạt 4.197 (fallback vi), analyzer 0 issues. Backend 867 tests đạt; Docker
native backup/restore smoke đạt. APK 4005 có 10 public-flow cases đạt và đã cài
lên emulator có cửa sổ. I18N còn **560 references / 52 structural members**,
chưa có đủ bản dịch; build iOS không ký trên Mac đạt (82,7 MB), IPA kiểm tra đã
đóng gói; chưa nghiệm thu native trên iPhone/ký release.
GitHub Actions không khởi động do tài khoản bị khóa billing. Các số bên dưới là lịch sử.

Đợt đổi tên VanHub, sửa UI và rà tính năng: xem [VANHUB_REVIEW_2026-10-01.md](VANHUB_REVIEW_2026-10-01.md). Trạng thái tích hợp 01/10/2026: xem [COMPLETION_STATUS.md](COMPLETION_STATUS.md) và [QA_2026-10-01.md](QA_2026-10-01.md). Bốn WP và phần sửa/test tiếp theo đã gộp trên `ndh0408/codex-complete`; chủ dự án yêu cầu cập nhật cả nhánh mặc định GitHub `claude/jolly-hawking-23o2j8`; toàn bộ yêu cầu global **chưa hoàn tất**. Phần dưới là snapshot lịch sử 29/09, không phải bằng chứng nghiệm thu bản mới.

## Snapshot 29/09/2026

Cập nhật: 2026-09-29. Nhánh: `claude/jolly-hawking-23o2j8`.

Trạng thái: **đủ 8 nhóm tính năng giao diện, đã tích hợp và đã sửa hết lỗi của đợt review**
(xem "Đã review"). `flutter analyze` 0 lỗi, 960 test pass. `flutter build apk --release` thành
công, ký bằng debug key vì chưa có keystore thật: APK universal 70,8 MB, bản tách theo ABI
arm64-v8a 25,7 MB, armeabi-v7a 23,5 MB, x86_64 27,2 MB.

## Đã xong

1. **Nghiên cứu**: `docs/research/` (SUMMARY.md là nguồn chính).
2. **Nền móng lõi**: `lib/core/` (xem `docs/ARCHITECTURE.md`). Gồm đăng nhập Riot bằng WebView,
   re-auth bằng cookie, tối đa 10 tài khoản, `PvpApi` (mọi endpoint), nội dung valorant-api.com
   vi-VN có cache, thông báo cục bộ, tác vụ nền, bộ widget UI, router 5 tab.
3. **Lớp dữ liệu dùng chung**: `lib/core/domain/economy` (cửa hàng, ví, đồ sở hữu, giá, wishlist),
   `competitive` (rank, RR, lịch sử trận, chi tiết trận), `loadout` (GET/PUT v3 giữ nguyên map
   gốc, preset cục bộ, loadout trong trận), `lib/core/xmpp` (chat Riot: roster, presence, tin nhắn).
   Tài liệu API: `docs/architecture/domain-*.md`, `xmpp.md`.
4. **Giao diện theo tính năng** (`lib/features/`, sơ đồ màn hình VF §6):

   | Tính năng | Màn hình | Commit |
   |---|---|---|
   | Cửa hàng + chi tiết skin | S10–S16: Hằng ngày, Chợ Đêm, Phụ kiện, Bundle, chi tiết bundle, chi tiết skin, video | `7225db4` |
   | Battle Pass | S20 thẻ Battle Pass, cột mốc hằng ngày, nhiệm vụ tuần; S21 phần thưởng | `4964bf9` |
   | Bộ sưu tập | S30–S39: thẻ/danh hiệu, trang bị vũ khí, phụ kiện súng, tổ hợp cảm xúc, preset, duyệt bộ sưu tập | `93e52e3` |
   | Wishlist | S3A Wishlist, S3B Tất cả skin, kiểm tra wishlist trong nền | `6bb0d40` |
   | Hồ sơ | S40–S44: rank, lịch sử trận, tính lên hạng, RR theo ngày, chi tiết trận, hồ sơ người chơi | `aac5501` |
   | Trận hiện tại | S50/S51: theo dõi trận, chọn/khóa đặc vụ, đội hình kèm rank, rời trận có xác nhận, thẻ trên Hồ sơ | `7c04154`, `5c7fd9d` |
   | Xã hội | S55 Tổ đội & hàng chờ, S60 Bạn bè, S61 Trò chuyện | `32d93e3` |
   | Cài đặt | S01 Chào mừng, S04 xin quyền thông báo, S70 Cài đặt, S71 Nhật ký phiên, S72 Giới thiệu | `0d07376` |

   Màn hình nào cũng có skeleton khi tải, trạng thái trống, lỗi kèm "Thử lại" và kéo để làm mới.
   Widget test chạy ở 360dp (nhiều test ở 320dp với cỡ chữ 130%).
5. **Tích hợp** (commit tích hợp cuối):
   - Test tích hợp toàn app `test/app/app_integration_test.dart`: đủ 5 tab dựng được khi Riot
     lỗi (hiện "Thử lại"), route chéo tính năng (`/collection/wishlist`, `/profile/friends`,
     `/profile/rankup`, trang không tồn tại), đổi tài khoản đang dùng.
   - Thông báo **"Chợ Đêm đã mở!"** (VF §6.9): gửi trong lần kiểm tra nền, mỗi Chợ Đêm một lần
     cho mỗi tài khoản, khi bật "Khi Chợ Đêm mở". Dùng chung một lần đọc storefront/ngày với
     kiểm tra wishlist.
   - Icon app gốc (chữ V đỏ #FF4655 kèm ngôi sao trên nền #0F1923, không dùng logo Riot/Valorant):
     `tool/generate_icon.py` → `assets/icon/`, sinh icon Android (kèm adaptive + monochrome) và
     iOS bằng `flutter_launcher_icons`. Icon thông báo trắng riêng `@drawable/ic_stat_valvn`.
     Màn khởi động Android/iOS nền tối (không còn chớp trắng).
   - Xóa `docs/wip/store-settings-wip.patch` (Cửa hàng và Cài đặt đã vào code).
6. **Trang chủ và 5 tab** (`docs/design/HOME.md`, `lib/features/home/`): tab đầu tiên là bảng điều
   khiển thông minh với tám thẻ đúng thứ tự IA (Trận hiện tại, Cửa hàng hôm nay, Rank & phong độ,
   Battle Pass, Bạn bè đang chơi, Cộng đồng, Tài khoản khác, Trạng thái máy chủ). Thẻ nào không có dữ
   liệu thì ẩn; trận đang diễn ra và bảo trì chặn nổi lên đầu; skeleton chỉ cho ba thẻ lõi. Người dùng ẩn
   / sắp xếp thẻ trong "Tùy chỉnh Trang chủ" (lưu ở Prefs `f.home.layout`). Thanh tab còn 5 mục
   (Cộng đồng ở giữa, nhấn mạnh); Battle Pass và Cài đặt không còn là tab: route giữ nguyên, nằm trong
   nhánh Hồ sơ (hàng "Battle Pass" và nút ⚙ ở Trang chủ / Hồ sơ). `/` đổi thành `/home`, link thông báo
   `/settings` và `/battlepass` mở kèm Hồ sơ phía dưới nên Back vẫn chạy. `StoreResetReminderHost` luôn
   được dựng trong shell nên nhắc "Cửa hàng đã làm mới" không phụ thuộc việc tab Cửa hàng có được mở.
   Trang chủ không có vòng poll Riot mới (dùng lại TTL / poller sẵn có), không tự kết nối chat (bạn bè
   cần đồng ý một lần) và không tự đăng nhập cộng đồng. Test: hàm thuần, provider, từng thẻ, bố cục
   360 dp / chữ 200% / tablet / gập / RTL, tiếp cận (chạm ≥ 48 dp, tương phản), chuyển động giảm.
7. **CI**: `.github/workflows/android.yml` (APK) và `ios.yml` (IPA chưa ký), xem `docs/BUILD.md`.

## Đã review

Đợt review 2026-09-29: 35 lỗi đã xác minh, **sửa hết 35**, không bỏ qua lỗi nào. Mỗi lỗi có test hồi quy,
trừ các thay đổi CI và màn đăng nhập WebView (chỉ test phần logic tách ra).

- **Phiên đăng nhập / bảo mật**
  - Token mới vẫn bị 401/BAD_CLAIMS sau re-auth: kiểm tra lại region một lần (đổi shard nếu Riot
    đã chuyển vùng), không đổi thì đánh dấu `needsLogin`. Không còn vòng re-auth ở mỗi request.
  - Đăng xuất khi đang re-auth: `forget()` chờ re-auth đang chạy rồi xóa trong khóa tài khoản.
    Re-auth kiểm tra tài khoản còn tồn tại (đọc từ đĩa, xét cả isolate nền) trước khi ghi
    cookie/token. Metadata xóa trước, secret xóa lại lần nữa để chắc chắn.
  - Khóa re-auth liên isolate: heartbeat 15 s, lock cũ sau 40 s. Hết 60 s chờ thì báo
    `TransientException(lock_timeout)` chứ không chạy song song.
  - Chỉ `login_required` / `interaction_required` / `consent_required` /
    `account_selection_required` mới là cookie chết. `server_error`, `rate_limited`… là lỗi tạm.
  - 403 JSON của name-service kích hoạt 1 lần re-auth + thử lại (không tính 403 HTML hay bảo trì).
    Thất bại lần hai không đánh dấu tài khoản và không re-auth lại với cùng token.
  - Danh sách tài khoản đọc từ đĩa trước mỗi lần ghi, nên isolate nền không làm sống lại tài
    khoản đã xóa hay xóa mất `needsLogin`. Khi đăng xuất, xóa cả key `acct.<puuid>.*` và ID thông
    báo do isolate nền ghi.
  - `establishFromLogin` gọi bootstrap trước, ghi cookie sau. Đăng nhập lỗi không để lại secret.
  - `Prefs.reload()` đổi cache nguyên khối, không còn khoảng cache rỗng khi app quay lại.
  - Màn đăng nhập đọc `SessionLog` một lần khi còn mounted. Đăng nhập lại quay về màn trước (`pop`),
    chỉ lần đăng nhập đầu từ /welcome mới vào Cửa hàng.
- **Độ bền**
  - Chat: `stop()` bỏ lượt kết nối đang chạy, nên app ra/vào nền lúc đang kết nối vẫn kết nối lại.
  - Tác vụ nền: một hạn chung 25 s. Keep-alive lỗi (Keystore…) không chặn kiểm tra wishlist.
    Mọi lỗi của từng tài khoản được bắt và `finish()` luôn chạy. Trong nền, nội dung lấy từ cache
    dù cũ, không gọi /version.
  - `/version`: timeout 10 s, và nếu quá 5 s thì dùng bản cache để không chặn việc tải nội dung.
  - Nội dung tải lỗi được tải lại khi kéo làm mới hoặc bấm "Thử lại" ở Cửa hàng/Bộ sưu tập, và khi
    app quay lại.
- **Đúng API**
  - Lịch sử RR vẫn tải bù trang 2–5 khi MMR đã lưu trận mới nhất trước trang 1.
  - `QueueEntryTime` của tổ đội đọc được dạng `2026.04.23-22.40.57`, nên đồng hồ "Đang tìm trận" hiện.
- **Riêng tư**
  - Ai bật Incognito / ẩn cấp được ghi lại theo trận khi theo dõi trận trực tiếp
    (`acct.<puuid>.matchPrivacy`, tối đa 60 trận / 60 ngày). Bảng điểm chi tiết trận, bảng điểm
    "Kết thúc" và tóm tắt người chơi đều hiện "Người chơi ẩn danh". Mở hồ sơ từ bảng điểm dùng
    `?hidden=1`, và name-service không được gọi cho họ. Hạn chế: trận mà app chưa từng theo dõi
    trực tiếp thì không có cờ, vì match-details của Riot không có trường này.
  - "Rời trận" chỉ gửi đúng trận và đúng giai đoạn đã cảnh báo. Nếu trận đổi giai đoạn trong lúc
    hộp thoại đang mở thì không gửi gì và báo "hãy thử lại".
- **Giao diện tiếng Việt**
  - Bảo trì luôn hiện câu tiếng Việt.
  - Thông báo và link wishlist có thêm tham số `nav`, nên bấm lại cùng link vẫn đổi segment Cửa
    hàng và mở lại skin.
  - Huy hiệu tô nền dùng chữ tối trên teal/amber.
  - Theme sáng có màu `away`/`gold` riêng, và chữ teal đổi sang `win`.
  - Thống nhất "Đội địch" và "Chơi tự do". Giờ làm mới cửa hàng tính theo 00:00 UTC ở giờ máy.
- **CI**
  - iOS: IPA chưa ký upload trước bước ký, bước ký lỗi không làm hỏng job hay Release. Cần đủ 4
    secret mới ký. Ký chỉ cho target Runner (qua `Release.xcconfig`), không đụng target SwiftPM.
    `debugging` dùng Apple Development.
  - Android: tag không có keystore thật thì không tạo Release, vì debug key trên CI mỗi lần một
    khác. `docs/BUILD.md` đã ghi rõ.

## Còn thiếu / hạn chế đã biết

Chưa kiểm tra trên máy thật với dữ liệu Riot thật. Đây là việc quan trọng nhất còn lại.

- **Cửa hàng**: chưa có mua hàng (cố ý không làm). Bố cục mới chỉ kiểm tra qua ảnh chụp test,
  không có ảnh mạng.
- **Battle Pass**: phần thưởng miễn phí mở ở cấp cuối chương, ≈ 4.000 XP/trận và thuật ngữ
  "Phần mở rộng" là giả định, tài liệu chưa xác nhận. Riot không trả lượng XP/KC của cột mốc,
  nên chỉ hiện "+XP, +KC".
- **Hồ sơ**: cờ ẩn danh chỉ có cho các trận app đã theo dõi trực tiếp (xem "Đã review"). Lọc theo map chỉ lọc các trận đã tải. Cột ACS ở Sinh Tử là
  tổng điểm. Mục "Bạn bè & trò chuyện" chưa có số tin chưa đọc, vì hiện số này sẽ phải mở kết nối
  chat mỗi lần vào tab Hồ sơ.
- **Trận hiện tại**: huy hiệu "Tổ đội" chỉ lấy từ tổ đội của bạn và presence của bạn bè. Tỉ số
  trực tiếp ẩn khi presence của bạn cũ hơn 2 phút (SUMMARY §13 U9). Kéo làm mới tab Hồ sơ không
  làm mới thẻ Trận hiện tại; thẻ tự làm mới mỗi 20 giây.
- **Cài đặt**: chưa có link Discord ("Góp ý & báo lỗi" mở GitHub issues). Chưa có cảnh báo tối
  ưu pin Android. "Xóa bộ nhớ đệm" chỉ xóa cache phản hồi và ảnh. Preset loadout (prefs), lịch sử
  RR (thư mục `history`) và wishlist được giữ lại (đã kiểm tra).
- **Thông báo nền**: chạy theo lịch workmanager (≥ 6 giờ, Android có thể trễ hơn khi Doze). iOS
  chạy nền không đảm bảo.
- **Phát hành**: APK đang ký bằng debug key. Muốn phát hành thật cần keystore riêng
  (`docs/BUILD.md` §4). IPA chỉ build được qua GitHub Actions (macOS).

## Cách làm tiếp

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get && flutter analyze && flutter test
flutter build apk --release                  # build/app/outputs/flutter-apk/app-release.apk
flutter build apk --release --split-per-abi  # app-{arm64-v8a,armeabi-v7a,x86_64}-release.apk
```

Đổi icon: sửa `tool/generate_icon.py`, rồi chạy
`pip install pillow && python3 tool/generate_icon.py && dart run flutter_launcher_icons`.
Sau đó **hoàn tác thay đổi của lệnh này trong `ios/Runner.xcodeproj/project.pbxproj`** (lỗi của
flutter_launcher_icons 0.14.4: nó ghi đè `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`).

Thứ tự nên làm:

1. Chạy thử trên máy Android thật với tài khoản Riot của mình: đăng nhập, đủ 5 tab, đổi tài khoản,
   trang bị (PUT), trận hiện tại, chat. Ghi lỗi từ "Nhật ký phiên" (đã ẩn token).
2. Sửa các giả định còn mở (Battle Pass, ACS Sinh Tử) theo dữ liệu thật.
3. Tạo keystore release, cấu hình secret CI, gắn tag `v1.0.0`.

Container mới cần cài lại Flutter 3.47.5 (`/opt/flutter`) và Android SDK
(`platform-tools`, `platforms;android-36`, `build-tools;36.0.0` tại `/opt/android-sdk`).
Quy tắc commit: chỉ commit khi analyze 0 lỗi và toàn bộ test pass.
