# Build & phát hành VanHub

Trạng thái kiểm chứng mới nhất: [CI local 02/10](FINAL_GAP_AUDIT_2026-10-02.md).
APK/IPA mang tên ValVN trong pipeline để giữ tương thích artifact; thương hiệu
sản phẩm là VanHub. Bản debug-signed/unsigned dùng kiểm tra, chưa là bản store.
GitHub Actions hiện không khởi động vì billing; kiểm tra local không mở khóa GitHub.

Tài liệu này hướng dẫn: build APK ở máy local, lấy APK/IPA từ GitHub Actions, cài IPA chưa ký
lên iPhone (AltStore/Sideloadly), và cấu hình secret để CI ký release bằng key thật.

CI tương ứng: [`.github/workflows/android.yml`](../.github/workflows/android.yml) (APK, chạy trên
`ubuntu-24.04`) và [`.github/workflows/ios.yml`](../.github/workflows/ios.yml) (IPA, chỉ build được
trên `macos-26` vì Apple không cho build iOS trên Linux/Windows).

## 1. Build APK ở máy local

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get
flutter analyze     # phải 0 issues
flutter test        # phải pass hết
flutter build apk --release                # 1 file APK universal (mọi kiến trúc CPU)
flutter build apk --release --split-per-abi  # 3 file APK nhỏ hơn, mỗi file 1 kiến trúc CPU
```

Kết quả nằm ở:

- Universal: `build/app/outputs/flutter-apk/app-release.apk`
- Split theo ABI: `build/app/outputs/flutter-apk/app-{arm64-v8a,armeabi-v7a,x86_64}-release.apk`

APK universal cài được trên mọi máy Android nhưng nặng hơn; APK split nhẹ hơn nhưng phải chọn
đúng kiến trúc CPU của máy (điện thoại đời mới hầu hết là `arm64-v8a`).

**Ký release:** nếu không có `android/key.properties` (file này nằm trong `.gitignore`, không
commit), `android/app/build.gradle.kts` tự động ký release bằng **debug key** để lệnh build luôn
ra APK cài được — xem mục 4 để ký bằng key thật.

Build iOS (`.app`, không đóng gói IPA) chỉ chạy được trên macOS đã cài Xcode:

```bash
flutter build ios --release --no-codesign
```

## 2. Lấy APK/IPA từ GitHub Actions (không cần máy Mac)

Hai workflow chạy tự động khi push lên `main` hoặc nhánh mặc định
`claude/jolly-hawking-23o2j8`, khi tag dạng `v*` (ví dụ `v1.0.0`), hoặc bấm
chạy tay (**Run workflow**). Riêng **Android APK** còn chạy trên mọi Pull Request, nhưng chỉ để
kiểm tra `flutter analyze` + `flutter test` (không build APK) — **iOS IPA** không chạy trên PR vì
cần runner macOS đắt hơn nhiều lần so với Linux:

1. Vào tab **Actions** của repo trên GitHub.
2. Chọn workflow **Android APK** hoặc **iOS IPA** → chọn lần chạy mới nhất (hoặc bấm
   **Run workflow** để chạy tay).
3. Kéo xuống mục **Artifacts** ở cuối trang chạy → tải file zip
   (`ValVN-android-<version>+<build>`, `ValVN-ios-unsigned-<version>+<build>`, và
   `ValVN-ios-signed-<version>+<build>` khi có ký thật).
4. Giải nén: bên Android sẽ có các file `.apk` + `SHA256SUMS.txt`; bên iOS có file
   `ValVN-<version>-unsigned.ipa` (và thêm `-signed.ipa` nếu repo đã cấu hình secret ký — xem mục 4).

**Lưu ý:** Artifact trên GitHub Actions chỉ lưu **30 ngày** rồi tự xoá.

### Phát hành bằng tag (khuyên dùng cho bản chính thức)

Push một tag bắt đầu bằng `v` (ví dụ `v1.0.0`):

```bash
git tag v1.0.0
git push origin v1.0.0
```

CI chỉ tạo **GitHub Release** khi gate ký bản phát hành đạt. Android yêu cầu
release signer; iOS yêu cầu signed IPA thành công. iOS unsigned vẫn được lưu
thành artifact kiểm tra, không được đưa vào tag release. Build number lấy base
trong pubspec cộng run number để không hạ version code của bản review đã cài.

## 3. Cài IPA chưa ký lên iPhone (AltStore / Sideloadly)

File `ValVN-<version>-unsigned.ipa` do workflow **iOS IPA** tạo ra là app **iOS build sẵn nhưng
chưa ký** (Apple bắt buộc mọi app chạy trên máy thật phải được ký bằng chứng chỉ). Có 2 cách
thông dụng để tự ký và cài mà không cần tài khoản Apple Developer trả phí ($99/năm):

### Cách A — AltStore (khuyên dùng, tự ký lại mỗi 7 ngày)

1. Cài **AltServer** trên máy tính (Windows/macOS) từ [altstore.io](https://altstore.io), cài
   **AltStore** lên iPhone qua AltServer (cắm cáp USB, cùng mạng Wi-Fi).
2. Trên iPhone: **Cài đặt → Cài đặt chung → VPN & Quản lý thiết bị** → tin cậy profile AltServer.
3. Tải file `ValVN-<version>-unsigned.ipa` về iPhone (AirDrop từ máy tính, hoặc mở link tải bằng
   Safari trên iPhone rồi bấm **Share → AltStore**).
4. Mở AltStore trên iPhone → tab **My Apps** → nút **+** → chọn file `.ipa` vừa tải → nhập Apple ID
   (miễn phí, dùng để ký app, **không** cần Apple Developer Program).
5. AltStore tự ký bằng chứng chỉ Apple ID miễn phí (hạn 7 ngày) và cài app. Mở AltServer trên máy
   tính, để máy/iPhone cùng mạng Wi-Fi ít nhất 1 lần mỗi tuần để AltStore tự ký lại — nếu không app
   sẽ báo "Untrusted Developer" và ngừng mở được sau 7 ngày.

### Cách B — Sideloadly (ký 1 lần bằng máy tính, cũng hết hạn 7 ngày với Apple ID miễn phí)

1. Cài [Sideloadly](https://sideloadly.io) trên Windows/macOS, cắm iPhone bằng cáp USB.
2. Kéo file `ValVN-<version>-unsigned.ipa` vào Sideloadly, nhập Apple ID → bấm **Start**.
3. Trên iPhone: **Cài đặt → Cài đặt chung → VPN & Quản lý thiết bị** → tin cậy profile Apple ID đó.
4. Giống AltStore, bản ký bằng Apple ID miễn phí hết hạn sau **7 ngày** — phải cắm lại máy tính và
   ký lại bằng Sideloadly (hoặc dùng Apple Developer Program trả phí để hạn ký kéo dài 1 năm).

> Cả hai cách đều cần chấp nhận cảnh báo "ứng dụng không rõ nguồn gốc" một lần trong
> **Cài đặt chung → VPN & Quản lý thiết bị** sau khi cài.

## 4. Cấu hình secret để CI ký bằng key thật

Không bắt buộc — thiếu secret thì CI vẫn build ra APK (ký bằng debug key) và IPA chưa ký (đủ dùng
cho AltStore/Sideloadly ở mục 3). Chỉ cần cấu hình khi muốn CI tự ký bằng key phát hành thật, ví dụ
để đăng lên Google Play / App Store hoặc để APK có thể **cập nhật đè** lên bản cài trước đó (APK ký
bằng key khác nhau thì Android coi là app khác, không cho cập nhật đè).

> **Lưu ý APK ký debug key trên CI:** mỗi lần chạy, runner GitHub là một máy ảo mới và tự sinh
> một debug keystore **ngẫu nhiên khác**. Vì vậy APK debug-signed của hai lần chạy CI khác nhau
> **không bao giờ cập nhật đè lên nhau được** — người thử phải gỡ app (mất toàn bộ tài khoản đã
> đăng nhập) rồi cài lại. Do đó khi push tag `v*` mà chưa có `ANDROID_KEYSTORE_BASE64`, job Android
> **không tạo GitHub Release** (báo lỗi); APK vẫn có trong artifact của lần chạy để thử.

Vào **Settings → Secrets and variables → Actions** của repo trên GitHub, thêm:

### Android (ký release thật) — workflow `android.yml`

| Secret | Nội dung |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | File `.jks`/`.keystore` mã hoá base64: `base64 -i upload-keystore.jks \| pbcopy` (macOS) hoặc `base64 -w0 upload-keystore.jks` (Linux) |
| `ANDROID_KEYSTORE_PASSWORD` | Mật khẩu keystore |
| `ANDROID_KEY_ALIAS` | Alias của key trong keystore |
| `ANDROID_KEY_PASSWORD` | Mật khẩu của key (thường trùng `ANDROID_KEYSTORE_PASSWORD`) |

Chưa có keystore? Tạo bằng lệnh có sẵn trong JDK:

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Giữ keystore này mãi mãi** — mất hoặc đổi keystore thì không thể phát hành bản cập nhật đè lên
app đã cài (Android/Google Play từ chối APK ký bằng key khác app gốc).

Khi có đủ 4 secret trên, CI sẽ tự tạo `android/key.properties` (theo đúng định dạng
`android/app/build.gradle.kts` đang đọc) trước khi build, và xoá file này lẫn `.jks` sau khi build
xong — secret không lưu lại trong repo hay artifact.

### iOS (ký thật, tuỳ chọn) — workflow `ios.yml`

Job build IPA chưa ký luôn chạy, và IPA chưa ký được upload **trước** mọi bước ký. Khi có **đủ 4
secret bắt buộc** `IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`, `IOS_PROFILE_BASE64`, `IOS_TEAM_ID`
thì các bước **ký thật** mới chạy kèm (cần tài khoản Apple Developer Program trả phí, $99/năm).
Bước ký lỗi (profile hết hạn, chứng chỉ không khớp…) chỉ tạo cảnh báo: IPA chưa ký vẫn được upload
và vẫn vào GitHub Release. Việc ký chỉ áp dụng cho target Runner (ghi vào
`ios/Flutter/Release.xcconfig` trên runner), không đụng các target resource bundle của plugin
SwiftPM. `IOS_EXPORT_METHOD=debugging` dùng chứng chỉ **Apple Development** + development profile;
các cách khác dùng **Apple Distribution**.

| Secret / biến | Nội dung |
|---|---|
| `IOS_CERT_P12_BASE64` | Chứng chỉ ký `.p12` (Distribution certificate) mã hoá base64 |
| `IOS_CERT_PASSWORD` | Mật khẩu file `.p12` |
| `IOS_PROFILE_BASE64` | Provisioning profile (`.mobileprovision`) mã hoá base64 |
| `IOS_TEAM_ID` | Apple Developer Team ID (10 ký tự, xem tại developer.apple.com/account) |
| `IOS_KEYCHAIN_PASSWORD` | Tuỳ chọn — mật khẩu keychain tạm trên CI runner |
| Biến `IOS_EXPORT_METHOD` (Actions **variable**, không phải secret) | `release-testing` (ad-hoc, mặc định — cài trực tiếp qua UDID), `debugging` (development), hoặc `app-store-connect` (nộp App Store) |

Bundle ID app hiện tại: `vn.valvn.app` — provisioning profile phải khớp bundle ID này.

## 5. CI kiểm tra gì trước khi build release

`android.yml` chạy `flutter analyze` + `flutter test`, `ios.yml` chạy `flutter test`, đều trước
bước build — bước build APK/IPA release chỉ chạy khi các bước này pass. Trên Pull Request,
`android.yml` dừng lại sau `flutter test` (không build APK) để CI nhanh và không tốn phút runner.
