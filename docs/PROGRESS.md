# Tiến độ ValVN (điểm dừng để làm tiếp)

Cập nhật: 2026-09-28. Nhánh: `claude/jolly-hawking-23o2j8`.

## Đã xong (đã commit, `flutter analyze` 0 lỗi, 363 test pass)

1. **Nghiên cứu** — `docs/research/` (SUMMARY.md là nguồn chính).
2. **Nền móng lõi** — `lib/core/` (xem `docs/ARCHITECTURE.md`): cấu hình Android/iOS, font, theme,
   đăng nhập Riot bằng WebView + re-auth bằng cookie, tối đa 10 tài khoản, `PvpApi` (mọi endpoint),
   nội dung valorant-api.com vi-VN có cache, thông báo, tác vụ nền, bộ widget UI, router 5 tab,
   màn hình khung (stub) cho mọi màn trong `valbuddy-features.md` §6. Build APK debug thành công.
3. **Lớp dữ liệu dùng chung**
   - `lib/core/domain/economy/`: storefront (shop ngày, bundle, Chợ Đêm, phụ kiện), ví, đồ sở hữu,
     giá (chuỗi B9), nguồn phần thưởng, wishlist + `findWishlistHits`.
   - `lib/core/domain/competitive/`: name-service, MMR/rank/peak, lịch sử RR, RR theo ngày,
     tính số trận lên hạng, lịch sử trận + chi tiết trận + chỉ số, account XP.

4. **CI** — `.github/workflows/android.yml` (APK) và `ios.yml` (IPA chưa ký), hướng dẫn `docs/BUILD.md`.

## Đang dở (lưu dạng patch, CHƯA vào code)

`docs/wip/store-settings-wip.patch` — giao diện **Cửa hàng + chi tiết skin** và **Cài đặt** do agent viết dở
(khoảng 4.000 dòng). Tình trạng khi dừng: `flutter analyze` còn 4 cảnh báo import thừa trong test,
vài test `test/features/skin_detail/` còn fail. Áp lại bằng:

```bash
git apply docs/wip/store-settings-wip.patch
```

rồi sửa cho analyze 0 lỗi + test pass, commit, sau đó xóa file patch.

## Chưa làm (theo thứ tự)

1. **Lớp dữ liệu loadout + XMPP** — `lib/core/domain/loadout/` và `lib/core/xmpp/`
   (đề bài chi tiết: agent `domain-social-loadout` trong script workflow nền móng; tóm tắt:
   loadout v3 GET/PUT giữ nguyên map gốc, preset cục bộ, parse loadout trận; client XMPP
   roster/presence/chat theo SUMMARY §6.5).
2. **Tài liệu API lớp competitive** — `docs/architecture/domain-competitive.md`
   (chưa viết; `domain-economy.md` đã có).
3. **Bước tích hợp** — analyze/test toàn dự án, rà soát auth theo SUMMARY §3/§5/§6/§11,
   smoke test app, build APK.
4. **8 nhóm tính năng giao diện** (mỗi nhóm một thư mục trong `lib/features/`, thay stub):
   store + skin_detail, wishlist (kèm `runWishlistCheck` nền), battlepass, collection (+loadout UI),
   profile (rank, lịch sử trận, chi tiết trận, RR theo ngày, tính lên hạng), live_game,
   social (tổ đội, bạn bè, chat), settings (+ welcome, nhật ký phiên).
5. **Review + sửa lỗi**, icon app, build APK release.

## Cách làm tiếp

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get && flutter analyze && flutter test
```

Container mới cần cài lại Flutter 3.47.5 (`/opt/flutter`) và Android SDK
(`platform-tools`, `platforms;android-36`, `build-tools;36.0.0` tại `/opt/android-sdk`).
Quy tắc commit: chỉ commit khi analyze 0 lỗi và toàn bộ test pass.
