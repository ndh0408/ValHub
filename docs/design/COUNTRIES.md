# ValVN — Quốc gia, khu vực & kết nối (kế hoạch chốt, 30/09/2026)

Trạng thái của tài liệu gốc: **thiết kế**. Đã triển khai từng phần; xem [tiến độ](../COMPLETION_STATUS.md) và [bộ chọn dùng chung](../COUNTRY_PICKER_2026-10-01.md) để biết code/test hiện tại. Các checklist chưa đóng vẫn là yêu cầu cần hoàn thiện. Tài liệu này đi cùng `docs/design/IA.md` (5 tab; Battle Pass và Cài đặt nằm dưới Hồ sơ) và `docs/community-api.md` ("Community scopes v3"). Khi mâu thuẫn với `docs/research/SUMMARY.md` về host/shard, SUMMARY thắng, trừ mục 3.1 F5 (SUMMARY §4 đã cũ, xem mục 18).

Phạm vi quyết định của chủ dự án: hỗ trợ đủ **18 ngôn ngữ VALORANT** (ar-AE, de-DE, en-US, es-ES, es-MX, fr-FR, id-ID, it-IT, ja-JP, ko-KR, pl-PL, pt-BR, ru-RU, th-TH, tr-TR, vi-VN, zh-CN, zh-TW), mặc định theo ngôn ngữ thiết bị và người dùng chọn được; người chơi ở mọi quốc gia; bộ chọn quốc gia hiển thị shard Riot phục vụ và trạng thái hỗ trợ, có bộ lọc "chỉ nơi được hỗ trợ"; người dùng chọn cách kết nối (tự động theo tài khoản hoặc thủ công); chạy tốt trên mọi thiết bị (điện thoại, máy tính bảng/iPad, màn hình gập, ngang, trình đọc màn hình, chữ lớn, giảm chuyển động, người mù màu).

Phạm vi ngoài tài liệu này: cơ chế i18n cho 18 ngôn ngữ (chọn thư viện, ARB hay Dart const, plural). Tài liệu này chỉ nêu chỗ nó cần cắm vào. Các chuỗi tiếng Việt trong tài liệu là chuỗi nguồn.

---

## 0. Tóm tắt quyết định

1. **Sự thật duy nhất khi đã đăng nhập là `affinities.live` của riot-geo.** Bảng quốc gia chỉ dùng để gắn nhãn, gợi ý, và đặt mặc định trước khi đăng nhập. Không bao giờ định tuyến theo quốc gia, locale thiết bị hay IP.
2. **Hai file dữ liệu đóng gói + một khối cập nhật từ xa**: `assets/data/regions.json` (thay bảng cứng trong `riot_hosts.dart` và `kChatFallbackHosts`), `assets/data/countries.json` (249 mã ISO + XK, mỗi dòng ghi độ tin cậy và nguồn), `assets/l10n/countries/<locale>.json` (tên quốc gia 18 ngôn ngữ từ CLDR). Máy sinh dữ liệu: `tool/geo/gen_geo.mjs`, chạy tay hoặc trong CI, không chạy lúc runtime.
3. **`RegionTable.shardFor(region)` trả `null` với vùng lạ**, không trả lại chính vùng đó. Vùng lạ hiển thị "Khu vực này chưa được hỗ trợ", không đoán.
4. **Mỗi tài khoản có chế độ kết nối**: Tự động (mặc định, theo riot-geo) hoặc Thủ công (ghi đè, có kiểm tra, không bao giờ tự đổi ngầm). `Account.region` và `Account.shard` vẫn là giá trị hiệu lực mà mọi code cũ đọc.
5. **Đăng nhập không còn thất bại chỉ vì riot-geo không trả vùng**: hoàn tất đăng nhập, đánh dấu vùng tạm, mở bộ chọn vùng.
6. **Một widget chọn quốc gia dùng chung trong `lib/core/`**, thay `CommunityStrings.countryNames` (chỉ tiếng Việt, thiếu nhiều nước).
7. **Cộng đồng/LFG dùng đúng hợp đồng `docs/community-api.md` v3**: phạm vi country/region/global, 17 mã ngôn ngữ, `appliedScope`. Client không bao giờ gửi quốc gia; máy chủ tự lấy từ Riot `/userinfo` sau khi người dùng đồng ý.
8. **Mọi khẳng định trong tài liệu được gắn nhãn độ tin cậy** (mục 2). Thứ chưa kiểm chứng nằm ở mục 16, không xuất hiện như sự thật.
9. Trạng thái "hạn chế" hiển thị bằng câu trung tính "Bị hạn chế theo Điều khoản của Riot (lệnh cấm vận của Mỹ)", không dùng chữ "bị chặn" vì chưa kiểm chứng việc chặn về kỹ thuật (Q1).

---

## 1. Nguyên tắc bất biến

| # | Nguyên tắc |
|---|---|
| P1 | Định tuyến (host PD/GLZ/shared, bảng xếp hạng, feed trạng thái) chỉ dùng vùng hiệu lực của tài khoản: `regionMode=manual` thì `manualRegion`, ngược lại riot-geo `detectedRegion`. |
| P2 | Bảng quốc gia không bao giờ chọn host. Riot đã nói rõ vùng gán cho tài khoản "độc lập với shard bạn chơi" (F11), nên quốc gia ghi nhận không đủ để suy ra shard. |
| P3 | Không đoán: vùng lạ, trường thiếu, mã lạ thì dừng ở trạng thái "chưa hỗ trợ" hoặc "chưa rõ", không rơi về `ap`. |
| P4 | Thủ công chỉ do người dùng bấm Lưu, có kiểm tra, có cảnh báo; không bao giờ tự bật, không bị ghi đè âm thầm. Mọi thao tác thay đổi tài khoản Riot vẫn do người dùng bấm như CLAUDE.md quy định. |
| P5 | Không hard-code danh sách máy chủ/data centre. Danh sách chỉ để hiển thị, có ngày kiểm tra và ghi "có thể chưa đầy đủ" (F4). |
| P6 | Không định vị IP. Quốc gia thiết bị chỉ lấy từ locale hệ thống (`deviceCountryCode()` đã có trong `lib/core/l10n/locale.dart`). |
| P7 | Không log token/cookie/PUUID. Sự kiện log chỉ có mã (`region.manualSet`, `region.mismatch`), không kèm giá trị nhận dạng. |
| P8 | Trạng thái, cảnh báo, lựa chọn luôn có biểu tượng + chữ, không chỉ màu. |

---

## 2. Cách đọc độ tin cậy

| Nhãn | Ý nghĩa |
|---|---|
| **[X]** | Đã được fact-check xác nhận, nguồn ở mục 6. |
| **[X-]** | Xác nhận nhưng có lưu ý về sức mạnh bằng chứng (nêu ngay cạnh). |
| **[R]** | Đọc trực tiếp từ repo ngày 30/09/2026 (số dòng có thể trôi). Không phải nguồn Riot. |
| **[S]** | Suy ra bởi thiết kế này từ các mục đã xác nhận; ghi rõ phép suy. Không phải phát biểu của Riot. |
| **[U]** | Chưa kiểm chứng hoặc không thể kiểm chứng. Nằm ở mục 16. |

Fact-check không bác bỏ khẳng định ngoại vi nào trong danh sách; các điểm bị loại, đã cũ hoặc không được dùng làm bằng chứng nằm ở mục 3.8.

---

## 3. Sự thật đã xác nhận

### 3.1 Vùng và shard

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F1 | Sáu vùng người chơi. Trong FAQ tặng quà Riot gọi: NA = North America; LATAM = South America; BR = Brazil; EU = "Europe, the Middle East, and Africa (EMEA)"; KR = Korea; AP = "Southeast Asia/Asia-Pacific". Lưu ý: đây là bảng vùng tặng quà, không phải định nghĩa shard chính thức; "South America" cho LATAM quá hẹp vì Mexico City và Miami cũng là data centre LATAM (F4, F15). Vì vậy nhãn LATAM trong app là "Mỹ Latinh". | X- | S-gift, S-server, S-latam |
| F2 | Người chơi ở Canada và ở Mỹ cùng shard NA. | X | S-gift |
| F3 | Giá trị routing của API VAL-CONTENT-V1: AP, BR, ESPORTS, EU, KR, LATAM, NA. ESPORTS không phải vùng người chơi (phần này là suy luận [S]). | X | S-dev-content |
| F4 | Data centre theo Riot Support "Server Select": NA (US West Oregon, US West N. California, US East N. Virginia, US Central Texas/Illinois/Georgia); LATAM (Santiago, Mexico City, Miami); BR (Sao Paulo); EU (Frankfurt, Paris, Stockholm, Istanbul, London, Warsaw, Madrid, Bahrain); KR (Seoul); AP (Hong Kong, Tokyo, Singapore, Sydney, Mumbai, Manila). **Danh sách này chưa đủ và thay đổi**: Bogotá thuộc LATAM (Riot công bố 26/11/2021 là "sẽ thuộc các server LATAM", trang 12/04/2022 xác nhận mở; nên trích trang 2022, xem Q19); Cape Town thuộc shard EU (31/08/2023); Dubai và Bahrain bị tắt tạm thời tháng 03/2026 (tbreak trích Riot). Kết luận: không hard-code. | X | S-server, S-bogota-2021, S-capetown, S-tbreak |
| F5 | Sáu feed trạng thái công khai `https://valorant.secure.dyn.riotcdn.net/channels/public/x/status/{ap,na,eu,kr,latam,br,pbe}.json` đều trả HTTP 200, id lần lượt AP, NA, EU, KR, LATAM, BR, PBE (đo lần đầu 29/09/2026, đo lại 30/09/2026). Danh sách locale trong feed: ar_AE, de_DE, en_SG, en_US, es_ES, es_MX, fr_FR, id_ID, it_IT, ja_JP, ko_KR, pl_PL, pt_BR, ru_RU, th_TH, tr_TR, vi_VN, zh_TW; **có zh_TW và en_SG, không có zh_CN** ở cả 7 feed. Ghi chú trong SUMMARY §4 rằng latam/br/kr trả 403 đã cũ. | X | S-status |
| F6 | Host theo shard: `na`, `latam`, `br` dùng shard `na` cho PD/shared; `eu`, `ap`, `kr` dùng chính nó; GLZ cần cả hai: `glz-{region}-1.{shard}.a.pvp.net`. Nguồn là log client thật trong repo (SUMMARY §4), không phải tài liệu Riot. Host PBE chưa xác minh (U22), bị ẩn. | R | `lib/core/riot/riot_hosts.dart` |
| F7 | Trung Quốc đại lục không phải shard Riot: VALORANT (无畏契约) do Tencent vận hành từ 12/07/2023 với server riêng, đăng nhập bằng QQ hoặc WeChat, tách biệt với bản quốc tế. ValVN đăng nhập bằng tài khoản Riot nên không kết nối được. Lưu ý: trang val.qq.com chỉ hiện ngày, chi tiết đăng nhập lấy từ Sina Finance/Gamersky; Gamersky nói "chỉ cần QQ hoặc WeChat" chứ không nói "chỉ"; việc dữ liệu tách biệt lấy từ bài hướng dẫn bên thứ ba (18183) và The Spike (cần IP Trung Quốc và tài khoản QQ/WeChat). Hồng Kông, Ma Cao, Đài Loan nằm trong danh sách Đông Nam Á của Riot (F20), thuộc AP. | X- | S-qq, S-gamersky, S-niko |

### 3.2 Vùng của tài khoản được gán thế nào

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F8 | Riot: "if you hop in-game in North America for the first time, your shard will be for NA" và "you will not be able to change your shard from where you are residing, so be extra careful when playing from a VPN". Lưu ý: "lần chơi đầu tiên ở NA" là ví dụ trong trang, không phải quy tắc tổng quát. | X- | S-welcome |
| F9 | Region of Residence (RoR) "decides which shards you play on, which payment options you have available to you, and who you can play with". Đổi qua công cụ kiểm tra điều kiện (cần đăng nhập) hoặc hỗ trợ Riot; công cụ cảnh báo có thể reset tài khoản 2XKO. Công cụ chưa được thử. | X | S-ror |
| F10 | "While you won't be able to change your shard, you'll be able to change the server if you're the leader of your party, or if you're playing solo." "Trong phạm vi vùng của mình" là suy ra từ cách liệt kê server theo shard. | X- | S-server |
| F11 | Riot sửa vị trí ghi sai của tài khoản Việt Nam; người chơi vẫn ở shard Asia-Pacific; "We're only adjusting the region assigned to your account, which is independent from the shard you play on." **Hệ quả thiết kế: quốc gia không được dùng để định tuyến (P2).** | X | S-vn-location |
| F12 | Account-V1 có `GET /riot/account/v1/active-shards/by-game/{game}/by-puuid/{puuid}` ("Get active shard for a player"; game `val`, `lor`, `2xko`; cụm AMERICAS, ASIA, EUROPE). Việc nó cần khóa API nhà phát triển là chuẩn chung nhưng chưa xác nhận lại (Q11). ValVN là app khách, không có khóa đó, nên không dùng. | X | S-dev-account |
| F13 | Cách ValVN và các app tương tự dùng (không chính thức): `PUT https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant` với `{id_token}` trả `{token, affinities:{pbe, live}}`; vùng là `affinities.live`. Tài liệu cộng đồng; bên kiểm chứng không gọi thật (cần Bearer + id_token từ cookie reauth). ValVN đang dùng trong production (SUMMARY §3.3). | X- | S-riotgeo |
| F14 | `GET auth.riotgames.com/userinfo` có trường `country`, ba chữ cái thường theo ISO alpha-3, ví dụ `deu`. Chỉ có ví dụ cộng đồng, không có tài liệu chính thức: parser phải phòng thủ (trường vắng hoặc lạ thì `null`). | X- | S-userinfo |

### 3.3 Căn cứ gán quốc gia vào vùng

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F15 | Riot LATAM (02/05/2020): server Mexico City phục vụ México, Centroamérica y el Caribe, Colombia, Venezuela, Ecuador; Santiago phục vụ Argentina, Bolivia, Chile, Paraguay, Perú, Uruguay. Phạm vi theo ngày; Bogotá thêm sau (F4). | X | S-latam |
| F16 | Server Cape Town "will be part of our EU shard" (31/08/2023): Nam Phi thuộc EU. | X | S-capetown |
| F17 | Riot MENA đại diện 15 nước: Lebanon, Jordan, Egypt, Iraq, Palestine; Saudi Arabia, Bahrain, Qatar, Kuwait, Oman, UAE; Libya, Algeria, Morocco, Tunisia. Data centre Bahrain "đưa Trung Đông vào VALORANT" (06/11/2020) và Server Select xếp Bahrain vào EU. Suy ra 15 nước này thuộc EU [S]. | X | S-dubai, S-mena-2020, S-server |
| F18 | Nhóm lúc ra mắt (06/2020): "Korea, Japan, and most of Asia-Pacific"; "Europe, Turkey, MENA, Russia, and CIS countries"; "North America, Latin America, and South America". Lưu ý: bài đăng gốc trên X không mở được; nội dung xác nhận qua chỉ mục tìm kiếm và The Loadout. | X- | S-launch, S-loadout |
| F19 | Server Mumbai (14/10/2020) "part of Southeast Asia shard", phục vụ India, Sri Lanka, Bangladesh, Nepal, Bhutan, Maldives (The Spike, nguồn thứ cấp trích Riot, theo ngày). Tháng 03/2026 Mumbai và Riyadh được bật tạm làm dự phòng cho Trung Đông (báo chí, xem Q9). | X- | S-spike |
| F20 | Danh sách Đông Nam Á của Riot (bài phương thức thanh toán SEA): Brunei, Cambodia, Hong Kong, Indonesia, Laos, Macau, Malaysia, Myanmar, Philippines, Singapore, Taiwan, Thailand, Timor-Leste, Vietnam (14 nước), và "payment options ... dependent on your Riot Account's region of residence". Ghép với F1 (AP = "Southeast Asia/Asia-Pacific") để gán AP: đây là suy ra hai bước [S]. | X | S-sea-pay, S-gift |
| F21 | VNG phát hành VALORANT ở Việt Nam từ 06/04/2021; người chơi Việt Nam dùng server SEA sẵn có (Gamek, đăng trước ngày phát hành; Kenh14 06/04/2021 xác nhận ngày). Riot xác nhận tài khoản VN ở shard AP (F11). | X | S-gamek, S-vn-location |

### 3.4 Quốc gia bị hạn chế hoặc không khả dụng

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F22 | Điều khoản Riot §19.9 (sửa đổi 01/12/2024): người dùng cam đoan "not located in, under the control of, or a national or resident of any embargoed country" và không thuộc danh sách OFAC SDN/BIS. **Riot không nêu tên quốc gia nào.** | X | S-tos |
| F23 | Mỹ duy trì cấm vận toàn diện: Cuba, Iran, Bắc Triều Tiên, vùng Crimea, DNR, LNR (GIR, 31/10/2025). OFAC không có "danh sách quốc gia". Vì vậy CU, IR, KP mang trạng thái `restricted` là **suy ra [S] từ F22 + F23**, không phải phát biểu của Riot. | X | S-gir, S-ofac-list |
| F24 | Syria: Mỹ không còn cấm vận toàn diện từ 01/07/2025 (E.O. 14312); biện pháp có mục tiêu vẫn còn. Tình trạng của Riot tại Syria chưa biết, nên `status=unknown`. | X | S-ofac-syria |
| F25 | Điều khoản §5.2: Riot có thể giới hạn lượng Game Currency mua/dùng theo vị trí (không nêu nước cụ thể). | X | S-tos |
| F26 | Giới hạn tặng quà: chỉ giữa PH, ID, TH, VN; chỉ nội địa ở TR, RU, UA, IR, EG; tặng VP chỉ trên PC. Đây **không phải "không hỗ trợ"**. FAQ nêu Iran nên Riot có ghi nhận người chơi ở Iran, nhưng không chứng minh kết nối được (Q1). Ukraine khả dụng; Crimea/DNR/LNR chỉ là ghi chú trên UA vì không phải mã ISO quốc gia. | X | S-gift |
| F27 | 11/03/2022 (DTF, trích Riot): Riot gỡ hầu hết phương thức thanh toán ở Nga, Belarus, Kazakhstan, Georgia và các nước CIS khác. "Game vẫn chơi được" là suy ra từ việc vẫn nạp tiền bằng thẻ mã. Hiện còn đúng hay không: chưa rõ (Q12). | X- | S-dtf |

### 3.5 Console

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F28 | Console (08/2024): Mỹ và Canada, "Europe", Nhật, Brazil. Từ 23/09/2026 có ở Úc và New Zealand dùng server Sydney (trang đăng 24/09/2026, nội dung còn một phần thì tương lai; nhiều nguồn xác nhận đã ra mắt). Hướng dẫn console của Riot: "NA, EU, JP, or BR ... also part of OCE (AUS and NZ)". | X | S-console-2024, S-console-ausnz, S-console-guide |
| F29 | Console dùng chung tài khoản và nội dung với PC, nhưng xếp hạng riêng và không đấu với PC. Phân loại vùng của console (JP, OCE) khác phân loại shard PC, nên **không dùng danh sách console để suy shard PC**. "Europe" gồm nước nào (TR, MENA, châu Phi, CIS?) chưa rõ (Q6). | X | S-console-guide |

### 3.6 Đăng nhập, ngôn ngữ, API

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F30 | `ui_locales_supported` của Riot RSO: en, cs, de, el, es, es-419, fr, hu, it, ms, pl, pt-BR, ro, ru, tr, ja, ko, id, th, vi, zh-Hans, zh-Hant, ar. Cả 18 ngôn ngữ app đều ánh xạ được vào danh sách này (bảng ở mục 5.3). | X | S-oidc |
| F31 | VAL-CONTENT-V1 hỗ trợ 19 locale: 18 ngôn ngữ app + en-GB. Đây là API của Riot; **chưa xác nhận valorant-api.com nhận đủ 18 mã** (Q14). | X | S-dev-content |
| F32 | Máy chủ cộng đồng của ValVN dùng 17 mã ngôn ngữ: `ar de en es fr id it ja ko pl pt ru th tr vi zh-CN zh-TW` (es-ES và es-MX gộp `es`, pt-BR thành `pt`), chấp nhận `_` thay `-` (`zh_CN`) và locale kèm vùng (`pt-BR`→`pt`, `zh-Hant*`/`zh-HK`/`zh-MO`→`zh-TW`). Lọc LFG theo `language`: bài `any` luôn khớp; truyền `any` trong bộ lọc nghĩa là không lọc. Lọc bài viết/đánh giá không có `any`. | R | `server/community/src/geo/languages.ts`, `db/sqlite-repo.ts` |

### 3.7 Chuẩn dữ liệu quốc gia

| ID | Sự thật | Nhãn | Nguồn |
|---|---|---|---|
| F33 | ISO 3166-1 có 249 mã alpha-2 (iso.org trả 403, dùng Wikipedia). CLDR `codeMappings.json` cho alpha-3/số (VN→VNM/704, TW→TWN/158, XK→XKK/983). UN M49 cho vùng/tiểu vùng nhưng **không có Đài Loan** (gán tay Eastern Asia). CLDR có tên rút gọn `-alt-short` (HK "Hồng Kông", PS "Palestine") và mã không phải quốc gia (001, 419, EU, UN, ZZ...) cần loại. | X | S-wiki-iso, S-cldr-codes, S-un-m49, S-cldr-terr |
| F34 | Thiết bị Apple đặt vùng Trung Quốc đại lục hiển thị cờ Đài Loan thành ô lỗi ở mọi app (Emojipedia, 2018; hiện hành chưa kiểm, Q13); vùng Hồng Kông ẩn cờ khỏi bàn phím nhưng vẫn hiển thị. Vì vậy hàng quốc gia luôn kèm tên và chip ISO. | X- | S-emoji-cn, S-emoji-hk |

### 3.8 Đính chính và thứ không dùng làm bằng chứng

| ID | Nội dung |
|---|---|
| C1 | SUMMARY §4 ghi feed `latam.json`, `br.json`, `kr.json` trả 403 và "name UNVERIFIED": **sai**, cả 7 feed trả 200 (F5). Cần sửa (mục 18). |
| C2 | "Account Transfer FAQ" ở URL VALORANT thực chất mô tả chuyển tài khoản League of Legends (cooldown 90 ngày, 2600 RP). **Không dùng làm bằng chứng cho VALORANT.** |
| C3 | Cooldown 90 ngày cho đổi RoR của VALORANT chỉ có trên blog VPN: chưa kiểm chứng (Q5). |
| C4 | Loại trừ rộng (Myanmar, Sudan, Venezuela, Quebec...) trong luật thi đấu Riot chỉ thấy ở đoạn tìm kiếm chưa mở được, và là điều kiện giải đấu, **không phải khả dụng của game**. Venezuela và Myanmar xuất hiện trong danh sách vùng game chính thức của Riot. Không dùng. |
| C5 | Cách hiểu "LATAM = Nam Mỹ" của FAQ tặng quà bị chính các bài LATAM của Riot phủ định (Mexico, Trung Mỹ, Caribe; F15). |
| C6 | Nhận định "không có trang Riot nào liệt kê nước bị chặn" **chưa kiểm chứng**: lần tìm cuối bị ngắt phiên (Q3). Không được viết trong app là "Riot không chặn nước nào". |

---

## 4. Hiện trạng trong repo (đọc 30/09/2026) và điểm phải sửa

| # | Hiện trạng [R] | Vị trí | Vấn đề khi toàn cầu |
|---|---|---|---|
| R1 | `establishFromLogin` luôn gọi riot-geo; thiếu `affinities.live` thì cả lần đăng nhập thất bại bằng `TransientException('no_region')`. | `lib/core/auth/session_manager.dart` (~437-476), `bootstrap_client.dart:113` | Người dùng ở nơi riot-geo lỗi tạm không vào được app. |
| R2 | `AccountsNotifier.completeLogin` lưu `region` và `shardForRegion(region)`. | `lib/core/accounts/account_providers.dart:81,88` | Không lưu quốc gia, không phân biệt vùng phát hiện/vùng chọn. |
| R3 | `_buildSession` gọi riot-geo lại chỉ khi vùng đã lưu không thuộc `supportedRegions`; `_readTokenCache` bỏ token cache nếu vùng không được hỗ trợ. | `session_manager.dart:399,516` | Đúng ý đồ, cần giữ (vùng rỗng tự kích hoạt kiểm tra lại). |
| R4 | `_handlePostReauthFailure` kiểm tra riot-geo một lần cho mỗi token sau 401/BAD_CLAIMS kế tiếp re-auth; đổi vùng thì tự chuyển tài khoản, không thì `needsLogin`. | `session_manager.dart:239-270` | Với chế độ thủ công phải phát sự kiện thay vì chuyển hoặc đánh dấu `needsLogin`. |
| R5 | `shardForRegion` và `supportedRegions` cứng; vùng lạ trả về chính nó (`final other => other`). | `lib/core/riot/riot_hosts.dart:5-15` | Vùng mới của Riot sinh host `pd.{x}.a.pvp.net` không tồn tại. |
| R6 | `Account.fromJson` mặc định vùng thiếu là `'ap'`. | `lib/core/accounts/account.dart:51` | Tài khoản không phải châu Á có metadata hỏng bị định tuyến sang AP âm thầm. |
| R7 | `RiotUserInfo.country` được phân tích nhưng không lưu. | `bootstrap_client.dart:28` | Mất dữ liệu cần cho gợi ý vùng. |
| R8 | Giả định Việt Nam/AP: `AuthConstants.uiLocales = 'vi'` (dùng ở `auth_callback.dart:35`); `StatusNotice.localized(..., locale: 'vi_VN')`; `communityRegion()` rơi về `'ap'`; `kChatFallbackHosts` nhân đôi bảng vùng; `ItemLanguage` chỉ có `vi`, `en`; `appLocale = Locale('vi')`; IA.md dòng 41 ghi "khu vực AP". | `app_constants.dart:10`, `platform_status.dart:42`, `community_models.dart:16-19`, `xmpp_parsers.dart:371`, `app_settings.dart:9`, `locale.dart:8`, `docs/design/IA.md:41` | Cần tổng quát hóa. (Nhãn `CommunityStrings.regionLabel` đã là tên đầy đủ tiếng Việt, chỉ còn thiếu 17 ngôn ngữ kia.) |
| R9 | Đã có sẵn thứ nên tái dùng: `deviceCountryCode()` và `deviceCountryProvider` (chú thích "A country picker may replace it later", dùng để chọn bảng giá VP); `flagEmoji()`/`countryCode()` trong `community_models.dart`; `foldForSearch`/`searchTokens`/`matchesTokens` đa chữ viết trong `lib/core/util/search_text.dart` (bảng sinh bởi `tool/gen_search_fold_table.py`; không gấp kana/Hangul/CJK); `countries_sheet.dart` (danh sách quốc gia có hoạt động) cùng `CommunityStrings.countryNames` (chỉ tiếng Việt, chưa đủ). | `lib/core/config/local_price.dart:57`, ... | Không viết lại; gom vào lõi. |
| R10 | Máy chủ cộng đồng đã có bảng ISO alpha-3→alpha-2 đủ 249 mã, `countryFromAlpha3`, `normalizeAlpha2` (chỉ nhận mã ISO thật; `XK` bị từ chối), 17 mã ngôn ngữ, phạm vi `country`/`region`/`global`, `/v1/communities`, `appliedScope`. Client gửi `region` và `language`, **không gửi country**. | `server/community/src/geo/*.ts`, `docs/community-api.md` "Community scopes v3" | Client phải khớp: kiểm tra chéo bảng alpha-3 (mục 14). |
| R11 | Tài khoản lưu trong Prefs (`app.accounts`), token trong secure store. `AppConstants.remoteConfigUrl` đang là chuỗi rỗng. Asset đọc bằng `rootBundle.loadString` rồi gộp với khối từ xa đã cache (khuôn `prices.json`). | `lib/core/storage/prefs.dart:18`, `app_constants.dart:101`, `prices.dart:227-235` | Hạ tầng hosting cho cập nhật từ xa chưa có (Q18). |

---

## 5. Mô hình dữ liệu

### 5.1 `assets/data/regions.json`

Thay bảng cứng trong `riot_hosts.dart` và `kChatFallbackHosts`.

```json
{
  "schema": 1,
  "dataVersion": 1,
  "updatedAt": "2026-09-30",
  "regions": {
    "ap":    {"shard": "ap", "feed": "ap",    "chat": "jp1",  "order": 1},
    "eu":    {"shard": "eu", "feed": "eu",    "chat": "euw1", "order": 2},
    "na":    {"shard": "na", "feed": "na",    "chat": "na2",  "order": 3},
    "latam": {"shard": "na", "feed": "latam", "chat": "la1",  "order": 4},
    "br":    {"shard": "na", "feed": "br",    "chat": "br",   "order": 5},
    "kr":    {"shard": "kr", "feed": "kr",    "chat": "kr1",  "order": 6},
    "pbe":   {"shard": "pbe", "feed": "pbe",  "hidden": true}
  },
  "servers": {
    "ap": ["Hong Kong", "Tokyo", "Singapore", "Sydney", "Mumbai", "Manila"],
    "eu": ["Frankfurt", "Paris", "Stockholm", "Istanbul", "London", "Warsaw", "Madrid", "Bahrain", "Cape Town"],
    "na": ["US West (Oregon)", "US West (N. California)", "US East (N. Virginia)", "US Central (Texas)", "US Central (Illinois)", "US Central (Georgia)"],
    "latam": ["Santiago", "Mexico City", "Miami", "Bogotá"],
    "br": ["Sao Paulo"],
    "kr": ["Seoul"]
  },
  "serversNote": "Theo Riot Support (Server Select) và thông báo Riot; có thể chưa đầy đủ.",
  "serversSrc": ["S-server", "S-bogota-2021", "S-capetown"]
}
```

Quy tắc:
- `shard` `chat` `feed`: id khớp `^[a-z0-9]{2,8}$`. `chat` là tiền tố dự phòng khi client config thiếu affinity (bảng hiện có [R] `kChatFallbackHosts`, gốc từ GinzaTech/Vshop, cộng đồng). XMPP thực tế dùng affinity PAS trong JWT và client config; bảng này chỉ là phương án cuối.
- `servers` chỉ để hiển thị, không tham gia logic. Không đưa Dubai vào: các nguồn đã xác nhận không nói Dubai thuộc shard nào (Q10). Không lưu trạng thái tạm thời (đang tắt/bật) vì đổi liên tục.
- `pbe`: ẩn, không bao giờ có trong `visibleRegions` (U22).
- `order`: thứ tự chip vùng trong UI. Thứ tự AP, EU, NA, LATAM, BR, KR khớp thứ tự chip ở mục 9.

### 5.2 `assets/data/countries.json`

Một mục cho mỗi mã ISO 3166-1 alpha-2 (249 mã) cộng `XK` gắn `nonIso`. File không chứa tên và cờ: cờ dựng từ ISO2 bằng ký tự regional indicator (`flagEmoji()` đã có); tên lấy từ mục 5.3.

| Trường | Kiểu / giá trị | Ghi chú |
|---|---|---|
| `a3` | chuỗi, ISO alpha-3 hoa | Để đọc `country` của userinfo (F14). `XK` → `XKK` (CLDR). |
| `m49` | chuỗi số 3 chữ số | |
| `sub` | mã tiểu vùng M49 hoặc `null` | `TW` gán tay `030` (F33). |
| `region` | `ap` \| `kr` \| `eu` \| `na` \| `latam` \| `br` \| `null` | Phải có trong `regions.json`, không phải `hidden`. |
| `conf` | `official` \| `region` \| `unverified` \| `none` | Định nghĩa ở mục 7. |
| `via` | `named` \| `area:<srcId>` \| `m49:<code>` \| `guess` | Cách nước này được gắn vào nguồn. Bắt buộc khi `conf` khác `none`. |
| `status` | `available` \| `restricted` \| `separate` \| `unknown` \| `na` | Lớp trạng thái, độc lập với `region`. |
| `reason` | `us_embargo` \| `tencent` \| `null` | Chỉ với `restricted`/`separate`. |
| `console` | `true` \| `null` | `true` chỉ khi Riot nêu đích danh nước (US, CA, JP, BR, AU, NZ). Không dùng `false` ở bản đầu: danh sách console đã đổi theo thời gian (F28), khẳng định "không có console" sẽ cũ. |
| `nonIso` | `true` (tùy chọn) | Chỉ `XK`. Loại khỏi mọi thao tác gửi lên máy chủ cộng đồng (`normalizeAlpha2` từ chối `XK`). |
| `notes` | mảng enum | `embargoed_subregions`, `gifting_sea_group`, `gifting_domestic_only`, `payments_limited_2022`, `embargo_lifted_2025`. Mỗi khóa ứng một chuỗi trong 18 ngôn ngữ. |
| `src` | mảng id nguồn | Phải có trong khối `sources`. |

Ví dụ (đã sửa so với bản nghiên cứu: VN không đặt `console:false`):

```json
{
  "schema": 1, "dataVersion": 1, "updatedAt": "2026-09-30",
  "countries": {
    "VN": {"a3":"VNM","m49":"704","sub":"035","region":"ap","conf":"official","via":"named","status":"available","console":null,"notes":["gifting_sea_group"],"src":["S-vn-location","S-sea-pay","S-gamek"]},
    "US": {"a3":"USA","m49":"840","sub":"021","region":"na","conf":"official","via":"named","status":"available","console":true,"src":["S-gift","S-console-2024"]},
    "JP": {"a3":"JPN","m49":"392","sub":"030","region":"ap","conf":"region","via":"area:S-server","status":"available","console":true,"src":["S-server","S-console-guide"]},
    "PK": {"a3":"PAK","m49":"586","sub":"034","region":"eu","conf":"unverified","via":"guess","status":"available","console":null,"src":[]},
    "CN": {"a3":"CHN","m49":"156","sub":"030","region":null,"conf":"official","via":"named","status":"separate","reason":"tencent","src":["S-qq","S-gamersky","S-niko"]},
    "IR": {"a3":"IRN","m49":"364","sub":"034","region":"eu","conf":"unverified","via":"guess","status":"restricted","reason":"us_embargo","notes":["gifting_domestic_only"],"src":["S-tos","S-gir","S-gift"]},
    "UA": {"a3":"UKR","m49":"804","sub":"151","region":"eu","conf":"region","via":"m49:151","status":"available","notes":["embargoed_subregions","gifting_domestic_only"],"src":["S-gift","S-gir"]},
    "SY": {"a3":"SYR","m49":"760","sub":"145","region":"eu","conf":"region","via":"m49:145","status":"unknown","notes":["embargo_lifted_2025"],"src":["S-ofac-syria"]},
    "AQ": {"a3":"ATA","m49":"010","sub":null,"region":null,"conf":"none","status":"na"}
  },
  "sources": {
    "S-gift": {"url":"https://support.riotgames.com/en-us/valorant/store/gifting-in-valorant","title":"Gifting in VALORANT","kind":"official","checked":"2026-09-30"}
  }
}
```

`sources[id]`: `url` (https bắt buộc), `title`, `kind` (`official` = Riot Support/playvalorant.com/riotgames.com/API Riot; `press`; `community`; `derived` = luật/tổ chức bên ngoài như OFAC, GIR), `checked` (ngày đọc lần cuối).

### 5.3 Tên quốc gia và ngôn ngữ

`assets/l10n/countries/<cldrLocale>.json`, 18 file sinh từ `cldr-localenames-full/main/<locale>/territories.json`:

```json
{"cldr": "<bản CLDR đã ghim>", "locale": "vi", "order": ["AF", "AX", "..."], "names": {"VN": "Việt Nam", "HK": "Hồng Kông", "KR": "Hàn Quốc", "US": "Hoa Kỳ"}}
```

- `order`: thứ tự đối chiếu ICU của locale, tính lúc build bằng Node `Intl.Collator` vì Dart không có collator theo locale. Ghim phiên bản Node và commit file sinh ra để thứ tự không đổi theo máy.
- Ưu tiên tên `-alt-short` cho HK, MO, PS (F33). Loại mã không phải quốc gia: 001, 150, 419, EU, EZ, UN, ZZ, QO, XA, XB...
- Ánh xạ locale app sang CLDR: ar-AE→`ar`, de-DE→`de`, en-US→`en`, es-ES→`es`, es-MX→`es-MX` (kế thừa `es-419`), fr-FR→`fr`, id-ID→`id`, it-IT→`it`, ja-JP→`ja`, ko-KR→`ko`, pl-PL→`pl`, pt-BR→`pt`, ru-RU→`ru`, th-TH→`th`, tr-TR→`tr`, vi-VN→`vi`, zh-CN→`zh`, zh-TW→`zh-Hant`.
- Kích thước ước tính khoảng 100 KB cho 18 file (ước lượng của người nghiên cứu, chưa đo). Chỉ nạp locale hiện hành và `en` (để tìm kiếm chéo).
- `assets/l10n/countries/aliases.json`: từ khóa tìm kiếm thêm (tên tiếng Anh, tên bản địa, dạng quen dùng: USA, UK, Korea, Viet Nam, Türkiye, Czech Republic).
- `assets/l10n/languages/<cldrLocale>.json`: tên 17 ngôn ngữ cộng đồng bằng từng ngôn ngữ (CLDR `languages.json`); dùng cho bộ lọc ngôn ngữ (mục 11). Kèm tên tự gọi (autonym) của từng ngôn ngữ.
- Tên vùng (AP, EU, NA, LATAM, BR, KR) không có trong CLDR: viết tay 6 tên x 18 locale trong `lib/core/l10n/geo_strings.dart`. Mã vùng viết hoa (AP, EU...) giữ nguyên ở mọi ngôn ngữ, giống thuật ngữ game.

### 5.4 Máy sinh `tool/geo/gen_geo.mjs`

- Node (repo đã cần Node cho `server/community`). Chạy tay hoặc trong CI, không chạy lúc runtime.
- Đầu vào: bản `cldr-json` ghim (territories 18 locale, languages, `codeMappings.json`); CSV UN M49; `tool/geo/overrides.yaml` chứa luật tầng và ngoại lệ từng nước kèm id nguồn; danh sách `sources` (id → url, kind).
- Tự thêm TW (M49 thiếu) và XK.
- **Build thất bại nếu**: thiếu mã ISO2 hoặc thiếu `status`; dòng `official` không có nguồn `kind=official` (hoặc `derived` đối với hạn chế pháp lý); `region` không có trong `regions.json` hoặc là vùng ẩn; `src` trỏ id không tồn tại; `url` không phải https; `order` không khớp tập `names`; hoặc `region == null` mà `status` là `available` và `conf != unverified`.
- Cảnh báo (không thất bại): `checked` cũ hơn 12 tháng; nước chưa có tên ở một locale (rơi về `en`).

### 5.5 Cập nhật từ xa (không cần phát hành app)

Thêm khối `geo` vào RemoteConfig hiện có (cùng kiểu khối `prices`), lưu cache trong Prefs như `RemoteConfigLoader`:

```json
{"geo": {"dataVersion": 2,
  "countries": {"PK": {"region": "eu", "conf": "region", "via": "area:new-id", "src": ["new-id"]}},
  "regions": {"newregion": {"shard": "eu", "feed": "newregion"}},
  "sources": {"new-id": {"url": "https://...", "title": "...", "kind": "official", "checked": "2026-10-01"}}}}
```

- Gộp từng mục lên file đóng gói; chỉ áp dụng khi `geo.dataVersion` lớn hơn `dataVersion` đóng gói.
- Kiểm tra chặt: id vùng/shard khớp `^[a-z]{2,8}$` (không có `.`, `/`, `-`, `@`, nên không thể chèn host); giá trị enum đúng; URL https; khóa lạ bị bỏ; giới hạn kích thước.
- **Khuyến nghị an toàn (cần chủ dự án duyệt, D3)**: khối từ xa chỉ được (a) sửa/thêm dòng quốc gia, (b) thêm vùng mới ánh xạ vào shard đã có trong file đóng gói, (c) **không** đổi shard của vùng đã có, **không** đưa shard mới. Như vậy token Bearer chỉ luôn gửi tới `https://{pd|glz|shared}...{shard đã biết}.a.pvp.net`, kể cả khi máy chủ cấu hình bị chiếm quyền. Shard mới thực sự cần phát hành app.
- Điều kiện tiên quyết: `AppConstants.remoteConfigUrl` đang rỗng (R11); cần host một JSON tĩnh (ví dụ trên máy chủ cộng đồng hoặc GitHub Pages) (Q18).
- Không gửi dữ liệu người dùng. Kênh phản hồi duy nhất là nút "Báo sai" do người dùng bấm, mở sẵn issue/email (đích đến: Q20). Không có telemetry tự động.
- Phạm vi hữu ích: Riot thêm/đổi tên vùng (ánh xạ vào shard có sẵn); thay đổi pháp lý (như Syria 2025); sửa dòng `unverified`.

---

## 6. Nguồn (id, URL, ghi chú)

Ngày "đọc" là ngày fact-check (28-30/09/2026). Cột "loại" dùng cho `kind` trong `countries.json`.

| Id | Loại | URL | Chứng minh gì / lưu ý |
|---|---|---|---|
| S-welcome | official | https://support.riotgames.com/en-us/valorant/gameplay/welcome-to-valorant/ | F8 (shard theo nơi chơi lần đầu; không đổi shard; VPN). |
| S-ror | official | https://support.riotgames.com/en-us/valorant/account/changing-your-region-of-residence-for-your-riot-account | F9 (RoR quyết định shard/thanh toán/người chơi cùng; công cụ có đăng nhập; cảnh báo 2XKO). |
| S-server | official | https://support.riotgames.com/en-us/valorant/support-tools/server-select | F4, F10 (data centre; đổi server không đổi shard). |
| S-gift | official | https://support.riotgames.com/en-us/valorant/store/gifting-in-valorant | F1, F2, F26. |
| S-vn-location | official | https://support.riotgames.com/en-us/valorant/account/player-location-update-for-vietnam | F11, F21. |
| S-sea-pay | official | https://support.riotgames.com/en-us/valorant/billing/methods-of-payment-for-valorant-southeast-asia | F20 (14 nước SEA). |
| S-latam | official | https://playvalorant.com/es-mx/news/announcements/estado-de-los-servidores-en-latinoamerica/ | F15 (02/05/2020). |
| S-bogota-2021 | official | https://www.riotgames.com/es-419/noticias/riot-direct-colombia | F4: chỉ là thông báo kế hoạch (26/11/2021). |
| S-bogota-2022 | official | **URL cần bổ sung**: bài "Un nuevo servidor aterriza en Colombia", 12/04/2022 | Bằng chứng tốt hơn cho việc Bogotá đã mở; fact-check nêu tên bài nhưng không ghi URL (Q19). |
| S-capetown | official | https://playvalorant.com/en-us/news/dev/valorant-s-cape-town-servers-are-live/ | F16 (31/08/2023). |
| S-dubai | official | https://www.riotgames.com/en/work-with-us/offices/dubai | F17 (MENA 15 nước). |
| S-mena-2020 | official | https://playvalorant.com/en-us/news/announcements/community-spotlight-welcome-middle-east/ | F17 (06/11/2020). |
| S-launch | official | https://twitter.com/VALORANT/status/1267410566873669632 | F18; chỉ xác nhận qua chỉ mục tìm kiếm. |
| S-loadout | press | https://theloadout.com/valorant/release-date-pc | F18 (đối chiếu ba nhóm ra mắt). |
| S-tos | official | https://www.riotgames.com/en/terms-of-service | F22 (§19.9), F25 (§5.2); bản 01/12/2024. |
| S-gir | derived | https://globalinvestigationsreview.com/guide/the-practitioners-guide-global-investigations/2026/article/sanctions-the-us-perspective | F23 (31/10/2025). |
| S-ofac-syria | derived | https://ofac.treasury.gov/faqs/added/2025-06-30 | F24. |
| S-ofac-list | derived | https://ofac.treasury.gov/sanctions-programs-and-country-information/where-is-ofacs-country-list-what-countries-do-i-need-to-worry-about-in-terms-of-us-sanctions | F23 (OFAC không có danh sách quốc gia). |
| S-qq | official | https://val.qq.com/act/welcomechina/ | F7: chỉ xác nhận ngày 2023.7.12 khi đọc. |
| S-gamersky | press | https://www.gamersky.com/handbook/202307/1620618.shtml | F7 (đăng nhập QQ/WeChat, một khu). |
| S-niko | press | https://nikopartners.com/valorant-to-accelerate-pc-game-esports-revenue-growth-in-china/ | F7 (ra mắt 12/07/2023, server nội địa). |
| S-sina, S-18183, S-spike-cn, S-kenh14 | press | **URL cần bổ sung** (Sina Finance 12/07/2023; hướng dẫn 18183 04/2026; The Spike; Kenh14 06/04/2021) | Bổ trợ F7 và F21 (fact-check nêu tên, chưa ghi URL). |
| S-dev-content | official | https://developer.riotgames.com/api-details/val-content-v1 | F3, F31. |
| S-dev-account | official | https://developer.riotgames.com/api-details/account-v1 | F12. |
| S-oidc | official | https://auth.riotgames.com/.well-known/openid-configuration | F30. |
| S-status | official | https://valorant.secure.dyn.riotcdn.net/channels/public/x/status/latam.json (và ap, na, eu, kr, br, pbe) | F5. |
| S-riotgeo | community | https://valapidocs.techchrism.me/endpoint/riot-geo | F13. |
| S-userinfo | community | https://gist.github.com/Luc1412/1f93257a2a808679ff014f258db6c35b | F14. |
| S-console-2024 | official | https://playvalorant.com/en-gb/news/game-updates/about-valorant-console-availability/ | F28. |
| S-console-ausnz | official | https://playvalorant.com/en-us/news/announcements/valorant-coming-to-console-in-australia--new-zealand/ | F28. |
| S-console-guide | official | https://support.riotgames.com/en-us/valorant/gameplay/valorant-console-guide | F28, F29. |
| S-spike | press | https://www.thespike.gg/valorant/news/mumbai-receives-dedicated-valorant-servers/529 | F19 (nguồn thứ cấp, 2020). |
| S-tbreak | press | https://tbreak.com/valorant-dubai-servers-down-mena/ | F4, F19 (03/2026). |
| S-dtf | press | https://dtf.ru/gameindustry/1114594-riot-games-otklyuchila-v-rf-osnovnye-sposoby-oplaty-valyuty-v-svoih-igrah-eto-kosnulos-i-zhitelei-stran-sng | F27. |
| S-gamek | press | https://gamek.vn/vng-chinh-thuc-xac-nhan-phat-hanh-valorant-tai-viet-nam-20210317122622181.chn | F21 (bài trước ngày phát hành). |
| S-transfer-faq | official | https://support.riotgames.com/en-us/valorant/account/account-transfer-faq | **Không dùng** (C2): nội dung về League of Legends. |
| S-ask-2020 | official | https://playvalorant.com/en-us/news/dev/ask-valorant-nov-19/ | Lịch sử: 11/2020 Riot dự kiến có tùy chọn chuyển vùng tài khoản khoảng giữa 2021 (Q5). |
| S-emoji-cn | press | https://blog.emojipedia.org/one-emoji-doesnt-show-on-ios-in-china/ | F34 (2018-04-10). |
| S-emoji-hk | press | https://blog.emojipedia.org/apple-hides-taiwan-flag-in-hong-kong/ | F34 (2019-10-07). |
| S-cldr-terr | derived | https://raw.githubusercontent.com/unicode-org/cldr-json/main/cldr-json/cldr-localenames-full/main/vi/territories.json | F33 (cùng đường dẫn cho 17 locale còn lại). |
| S-cldr-codes | derived | https://raw.githubusercontent.com/unicode-org/cldr-json/main/cldr-json/cldr-core/supplemental/codeMappings.json | F33. |
| S-un-m49 | derived | https://unstats.un.org/unsd/methodology/m49/overview/ | F33 (thiếu Đài Loan). |
| S-wiki-iso | derived | https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 | F33 (249 mã; iso.org trả 403). |
| S-mena-2024 | official | https://www.riotgames.com/en/news/riot-games-mena-players | Chưa được fact-check; chỉ tham khảo nền (Riot chuẩn bị server Trung Đông tại chỗ). Không dùng làm căn cứ dòng dữ liệu. |

---

## 7. Phương pháp gán quốc gia sang shard (theo tầng)

Không nguồn Riot nào công bố bảng quốc gia-shard đầy đủ, nên bảng được dựng từ bằng chứng theo tầng và **mỗi dòng ghi độ chắc chắn**. Chỉ câu trả lời riot-geo của tài khoản đang đăng nhập là sự thật.

### Tầng 0. Danh sách nước
249 mã ISO2 (F33) + alpha-3/số từ CLDR + M49; thêm TW tay; tùy chọn XK gắn `nonIso`.

### Tầng 1. `official`: 29 nước
Riot nêu tên nước cùng shard, hoặc nêu trong một vùng Riot có shard rõ.

| Vùng | Mã | Nguồn |
|---|---|---|
| NA | US, CA | S-gift |
| BR | BR | S-gift |
| KR | KR | S-gift |
| AP | VN | S-vn-location, S-gamek |
| AP | BN, KH, HK, ID, LA, MO, MY, MM, PH, SG, TW, TH, TL (13 nước còn lại của F20) | S-sea-pay + S-gift (suy hai bước [S]) |
| LATAM | MX, CO, VE, EC (Mexico City); AR, BO, CL, PY, PE, UY (Santiago) | S-latam (CO thêm S-bogota-2022) |
| EU | ZA | S-capetown |

### Tầng 2. `region`: nước nằm trong một khu vực mà nguồn đã xác nhận thuộc một shard

Chỉ **khu vực** được xác nhận; việc mỗi nước cụ thể nằm trong khu vực đó do M49 hoặc danh sách Riot quyết định [S].

| Vùng | Phạm vi | Căn cứ đã xác nhận | Phần suy ra |
|---|---|---|---|
| EU | Toàn bộ châu Âu M49 (gồm RU, BY, UA, MD và lãnh thổ) trừ ngoại lệ | F1 (EU = EMEA); F18 ("Europe, Turkey, MENA, Russia, and CIS") | Từng nước theo M49 |
| EU | Châu Phi M49 (trừ ZA đã `official`; RE, YT, SH xuống tầng 3) | F1 | Từng nước theo M49 |
| EU | Tây Á M49: TR, IL, CY, GE, AM, AZ, Vịnh, Levant (kể cả SY, IQ, YE) | F1; Istanbul và Bahrain thuộc EU (F4); F17 | Từng nước theo M49 |
| EU | 15 nước MENA: LB, JO, EG, IQ, PS, SA, BH, QA, KW, OM, AE, LY, DZ, MA, TN | F17 | EU = suy từ Bahrain DC [S] |
| EU | Trung Á/CIS: KZ, KG, TJ, TM, UZ | F18 (nhóm "CIS" ra mắt cùng châu Âu) | Từng nước theo M49 |
| LATAM | Trung Mỹ M49: BZ, CR, SV, GT, HN, NI, PA; các quốc gia và lãnh thổ Caribe M49 (trừ lãnh thổ Mỹ) | F15 ("Centroamérica y el Caribe") | Từng nước theo M49 |
| AP | JP | Tokyo thuộc AP (F4); F18 ("Korea, Japan, and most of Asia-Pacific"); KR chỉ là Hàn Quốc (F1) | JP = AP [S] |
| AP | AU, NZ | Sydney thuộc AP (F4); console AU/NZ dùng Sydney (F28) | AU/NZ = AP cho PC [S]; phân vùng console khác (F29) |
| AP | IN, BD, LK, NP, BT, MV | F19 (nguồn thứ cấp 2020) | Theo bài The Spike |

### Tầng 3. `unverified`: chỉ hiển thị tốt nhất-đoán kèm cảnh báo, không bao giờ định tuyến

| Nhóm | Mã | Đoán | Ghi chú |
|---|---|---|---|
| Nam Á/Trung Á ngoại lệ | PK | `eu` | Báo chí 2020 (chưa mở được) nói Pakistan vào server Bahrain; Q8. |
| | AF, MN | `null` | Chưa có căn cứ. |
| | IR | `eu` | Restricted (tầng 4); FAQ tặng quà nhóm Iran cùng TR, RU, UA, EG. |
| | KP | `null` | Restricted. |
| Lãnh thổ Mỹ và Bắc Đại Tây Dương | PR, VI, GU, MP, AS, UM; GL, BM, PM | `null` | Không có đoán hợp lý duy nhất (NA, LATAM hay AP?). |
| Lãnh thổ xa vùng mẹ | RE, YT, SH | `eu` | Theo M49 châu Phi. |
| | NC, PF, WF, CX, CC, NF | `ap` | Theo M49 châu Đại Dương/Úc. |
| Đảo Thái Bình Dương (quốc gia) | Melanesia/Micronesia/Polynesia M49 | `ap` | Không có căn cứ từng nước. |
| Nam Mỹ còn lại | GY, SR, GF, FK | `latam` | Độ tin cậy thấp. |
| Không dân cư | IO, TF (và UM khả năng) | `null` | `status=na`. |

### Tầng 4. Lớp trạng thái (độc lập với vùng)

| Trạng thái | Mã | Ghi chú |
|---|---|---|
| `restricted` (`us_embargo`) | CU, IR, KP | Suy ra [S] từ F22+F23. Hiển thị "theo Điều khoản của Riot", không "bị chặn". |
| `separate` (`tencent`) | CN | F7. |
| `unknown` | SY | F24. |
| `na` | AQ, BV, HM, GS, (IO, TF, UM) | Không có dân cư thường trú. |
| `available` | Tất cả còn lại | Kèm `notes`: `embargoed_subregions` (UA), `gifting_sea_group` (PH, ID, TH, VN), `gifting_domestic_only` (TR, RU, UA, IR, EG), `payments_limited_2022` (RU, BY, KZ, GE và CIS; cần chú thích "chưa rõ còn áp dụng", Q12), `embargo_lifted_2025` (SY). |

### Tầng 5. Sự thật lúc chạy
Tài khoản đã đăng nhập: riot-geo luôn thắng. Bảng chỉ dùng để (1) gắn nhãn dòng trong bộ chọn, (2) gợi ý vùng khi riot-geo lỗi lúc đăng nhập (từ `country` của userinfo, F14), (3) đặt mặc định trước khi đăng nhập (feed trạng thái, gợi ý bộ chọn).

### Cạm bẫy
- Luật M49 thô xếp Iran và Pakistan vào "Southern Asia" thì ra AP; FAQ Riot lại nhóm Iran với Thổ Nhĩ Kỳ/Nga/Ukraine/Ai Cập. Giữ ngoại lệ từng nước trong `overrides.yaml`, mỗi ngoại lệ kèm id nguồn.
- CI kiểm tra mỗi dòng `official` trích ít nhất một nguồn `kind=official` (mục 5.4).

---

## 8. Kết nối: Tự động và Thủ công

### 8.1 Mô hình Account (thêm trường, không đổi nghĩa trường cũ)

| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `country` | ISO2 hoặc null | Từ `country` (alpha-3) của userinfo qua `CountryDb.byIso3`; nhận cả giá trị 2 chữ cái; giá trị khác thành null. Thông tin, không định tuyến. |
| `regionMode` | `auto` \| `manual` | Mặc định `auto`. |
| `manualRegion` | id vùng hoặc null | Chỉ có ý nghĩa khi `manual`. Phải nằm trong `RegionTable.visibleRegions`. |
| `detectedRegion` | id vùng hoặc null | `affinities.live` gần nhất, chữ thường, khớp `^[a-z]{2,8}$`. |
| `detectedAt` | thời điểm hoặc null | Lần cuối riot-geo trả lời. |
| `region`, `shard` | như cũ | **Giá trị hiệu lực.** Bất biến (một hàm duy nhất duy trì, có test): `region = regionMode == manual ? manualRegion : detectedRegion`; `shard = RegionTable.shardFor(region)`. Code cũ, isolate nền và host tiếp tục đọc hai trường này. |

Di chuyển dữ liệu: tài khoản hiện có được `regionMode=auto`, `detectedRegion=region`, `detectedAt=null` (buộc kiểm tra ở lần re-auth kế tiếp).

`Account.fromJson`: bỏ `?? 'ap'`. Vùng thiếu thành `''`, khiến `_buildSession` gọi riot-geo (đúng cơ chế R3) và `_readTokenCache` bỏ cache (R3). Mọi nơi dùng `account.region` trước khi có phiên phải chịu được `''`: `communityRegion` trả `null` (không rơi về `ap`); đăng nhập cộng đồng chỉ chạy khi có vùng, mà phiên Riot đã có vùng.

Trạng thái suy ra (không lưu thêm trường): **đã xác nhận** (`detectedRegion` thuộc bảng); **tạm** (`detectedRegion == null`: đăng nhập xong nhưng riot-geo chưa trả lời); **chưa hỗ trợ** (riot-geo trả id không thuộc bảng).

### 8.2 Khi nào gọi riot-geo

| Sự kiện | Chế độ Tự động | Chế độ Thủ công |
|---|---|---|
| Đăng nhập | Lưu `country`, `detectedRegion`, `detectedAt`; `region` = `detectedRegion`. | Như bên trái nhưng **không đụng `manualRegion`**. |
| riot-geo lỗi lúc đăng nhập | **Hoàn tất đăng nhập** (trước đây hủy toàn bộ); vùng tạm; mở bộ chọn vùng, chọn sẵn từ `country` qua `countries.json`; thử lại ở lần re-auth kế. | Không xảy ra (thủ công có sau khi vào). |
| Kiểm tra định kỳ | Tối đa mỗi 7 ngày, đi kèm một lần re-auth (một PUT). Thấy đổi vùng (chuyển vùng cư trú) thì tự chuyển tài khoản và phiên. | Vẫn làm mới `detectedRegion`; khác `manualRegion` thì phát `SessionRegionMismatch`. |
| 401/BAD_CLAIMS sau re-auth (`_handlePostReauthFailure`) | Giữ hành vi hiện có: kiểm tra một lần cho mỗi token, đổi vùng thì tự chuyển. | Kiểm tra riot-geo như thường; **không** chuyển vùng, **không** `needsLogin` vì vùng: phát `SessionRegionMismatch` và hiển thị banner. |
| riot-geo trả id không có trong bảng | Trạng thái "chưa hỗ trợ": "Khu vực này chưa được hỗ trợ". Không đoán, không dựng host. | Như bên trái (vẫn cho chuyển sang thủ công chọn vùng khác). |

`RiotHosts.forRegion` không được sinh host cho vùng lạ: thêm `tryForRegion(region) -> RiotHosts?` (dùng ở `SessionManager`); vùng lạ ném `UnsupportedRegionException` được giao diện xử lý bằng câu trên.

### 8.3 Vùng hiệu lực thay đổi gì (kỹ thuật)

Đổi vùng hiệu lực đổi:

| Đối tượng | Chi tiết |
|---|---|
| `pd.{shard}.a.pvp.net` | cửa hàng, ví, loadout, MMR, lịch sử trận, contract/Battle Pass, hình phạt. |
| `glz-{region}-1.{shard}.a.pvp.net` | phiên game, pregame, coregame, tổ đội. |
| `shared.{shard}.a.pvp.net` | gồm `/v1/config/{region}`. |
| Đường dẫn bảng xếp hạng | `.../affinity/{region}`. |
| Feed trạng thái | `{region}.json`; MaintenanceBanner; thẻ trạng thái ở Trang chủ. |
| Cộng đồng | trường `region` (LFG, mặc định bộ lọc). Gửi `detectedRegion ?? region`, không gửi vùng thủ công, để LFG phản ánh đúng những ai bạn có thể vào tổ đội cùng (F9). |

Không đổi: auth, entitlements, userinfo, riot-geo (host toàn cầu); valorant-api.com; chat XMPP (dùng affinity PAS trong JWT và client config; chỉ bảng dự phòng dùng vùng). Bảng dự phòng chat thuộc `regions.json` (mục 5.1).

Ghi chú quan trọng: trong shard `na` (na, latam, br), PD không phân biệt được ba vùng, GLZ chỉ trả lời khi đang trong game. Hiển thị chú thích: "Chọn sai giữa NA, LATAM và BR chỉ làm hỏng tính năng trận đang chơi và tổ đội".

### 8.4 Kiểm tra khi lưu vùng thủ công

Người dùng bấm Lưu (không có chế độ thủ công tự bật). Trước khi lưu:

1. Vùng chọn phải thuộc `RegionTable.visibleRegions`.
2. Nếu khác `detectedRegion`: hộp xác nhận nêu rõ "Riot xác định tài khoản này ở {vùng}. Chỉ dùng Thủ công khi Tự động sai; chọn sai sẽ làm cửa hàng/hồ sơ không tải được."
3. Thăm dò bằng chính phiên của tài khoản: `GET pd.{shard}.a.pvp.net/account-xp/v1/players/{puuid}` (endpoint P-9 trong SUMMARY, dữ liệu của chính chủ, chỉ đọc). Phân loại:

| Kết quả | Hành động |
|---|---|
| 2xx | Shard đúng, cho lưu. |
| 400/404 kèm thân JSON | "Máy chủ này không biết tài khoản của bạn." Chặn lưu, đề nghị Tự động. |
| 401 | Đã re-auth một lần rồi thử lại; nếu vẫn 401 thì "Chưa kiểm tra được", cho lưu kèm cảnh báo. |
| Lỗi mạng, 429, 5xx, trang HTML (Cloudflare) | "Chưa kiểm tra được lúc này", cho lưu kèm cảnh báo. |

Bảng trên là bảo thủ **vì phản hồi chính xác của PD với tài khoản sai shard chưa được kiểm chứng (Q4)**: chỉ 2xx là "đúng"; chỉ 400/404 có JSON mới chặn. Khi có kết quả thử nghiệm thật (Q4) sẽ chỉnh bảng.

### 8.5 An toàn

- Host luôn dựng từ mẫu cố định `https://pd|glz-…|shared.{shard}.a.pvp.net` với id chỉ gồm chữ/số; không nhận host tự do.
- Thao tác ghi (loadout, khóa đặc vụ, hàng chờ, rời trận) vẫn do người dùng bấm và có xác nhận nếu có hình phạt (CLAUDE.md), bất kể chế độ kết nối.
- Không thay đổi gì phía Riot khi đổi vùng thủ công: đây là cài đặt cục bộ.
- Thủ công không bao giờ hoạt động chỉ vì người dùng chọn một quốc gia ở bộ chọn quốc gia (bộ chọn chỉ đổi gợi ý, mặc định, feed trước đăng nhập).
- Mọi sự kiện log không chứa PUUID/token/quốc gia (P7).

### 8.6 Lịch sử và hạn chế cần nói thật với người dùng
- Vùng của tài khoản gắn với nơi chơi lần đầu và Region of Residence (F8, F9); ValVN không thể đổi việc đó. Muốn đổi RoR phải qua công cụ/hỗ trợ của Riot (liên kết trợ giúp, không tự làm). Cooldown VALORANT chưa rõ (Q5); không hứa con số nào.
- Dùng VPN lúc chơi lần đầu có thể đặt tài khoản vào shard "sai" mà không đổi được (F8): ghi vào mô tả của chế độ Tự động ("Riot xác định...").

---

## 9. Bộ chọn quốc gia (một widget lõi dùng chung)

Vị trí code: `lib/core/geo/` (`country_db.dart`, `country_names.dart`, `geo_providers.dart`) và `lib/core/ui/country_picker/`. Tái dùng `foldForSearch/searchTokens/matchesTokens` (R9), `flagEmoji` (chuyển vào lõi), `deviceCountryCode()`.

### 9.1 Điểm vào
1. Onboarding, ngay sau bước chọn ngôn ngữ (có "Bỏ qua").
2. Cài đặt, mục "Quốc gia/khu vực".
3. Luồng chọn vùng thủ công / chọn vùng khi riot-geo lỗi (chế độ chọn vùng: cùng widget, hàng hiển thị vùng thay vì nước).
4. Bộ lọc quốc gia của Cộng đồng (biến thể có số hoạt động, mục 11).

Lưu lựa chọn trong Prefs (`geo.country`; người dùng có thể xóa). Ưu tiên khi cần "quốc gia của tôi": lựa chọn tường minh của người dùng > `country` của tài khoản đang dùng (userinfo) > quốc gia thiết bị. Bảng giá VP (`deviceCountryProvider`) đọc theo thứ tự này thay vì chỉ locale thiết bị.

### 9.2 Bố cục hàng và bộ lọc

Đầu bộ chọn:
- Ô tìm kiếm: "Tìm quốc gia hoặc mã (VN, VNM)".
- Chip **"Chỉ nơi được hỗ trợ"**: bật mặc định, ghi nhớ (`geo.supportedOnly`); lọc `status == available`.
- Chip vùng: Tất cả · AP · EU · NA · LATAM · BR · KR (nước `region == null` chỉ hiện ở "Tất cả").
- Mục **"Gợi ý"** luôn ở đầu và vẫn hiện khi bộ lọc ẩn nó: quốc gia thiết bị (từ locale, không IP), quốc gia của tài khoản đang dùng, lựa chọn hiện tại.

Mỗi hàng:
- Dòng 1: cờ trang trí (loại khỏi cây ngữ nghĩa) + tên theo ngôn ngữ người dùng + chip ISO2 (luôn hướng trái-sang-phải).
- Dòng 2: "AP · Châu Á – Thái Bình Dương"; nếu `conf == unverified` thêm "Chưa xác minh" (biểu tượng + chữ). "Theo khu vực" chỉ hiện ở màn chi tiết.
- Trạng thái (luôn biểu tượng + chữ, hình khác nhau cho từng trạng thái, không chỉ màu):

| Trạng thái | Chuỗi nguồn (tiếng Việt) |
|---|---|
| `restricted` | "Bị hạn chế theo Điều khoản của Riot (lệnh cấm vận của Mỹ)" |
| `separate` | "Máy chủ riêng do Tencent vận hành — ValVN không kết nối được" |
| `unknown` | "Chưa rõ" |
| `na` | "Không áp dụng" |
| `available` | không có huy hiệu |

Chạm hàng: chọn hàng ở mọi trạng thái (người ta sống hoặc đi qua những nơi đó). Chọn `restricted`/`separate`/`unknown` mở một tờ giải thích và **không đổi gì về định tuyến**. Ngôn ngữ giải thích trung lập, có dòng "Đây không phải tư vấn pháp lý; ValVN không chặn bạn dựa trên quốc gia" và nêu rõ Riot không công bố danh sách nước (F22).

Nút "i" mở chi tiết: vùng và shard ("LATAM, BR và NA dùng chung shard NA" nếu có); data centre (từ `regions.json`/khối từ xa, ghi "có thể chưa đầy đủ"); console (chỉ khi `true`, kèm "Riot chỉ nêu US, CA, châu Âu, JP, BR, AU, NZ (cập nhật 09/2026)"); ghi chú (`notes`: giới hạn tặng quà, UA có vùng bị cấm vận, thanh toán 2022 "chưa rõ còn áp dụng"); nguồn kèm ngày kiểm tra; "theo khu vực"/độ tin cậy; nút **"Báo sai"** (mở issue/email soạn sẵn, không telemetry tự động).

### 9.3 Tìm kiếm
- Không phân biệt hoa/thường và dấu (gấp dấu tiếng Việt, đ→d) qua `foldForSearch`; chữ CJK/Hangul/kana không gấp (đúng như bảng hiện có).
- Khớp: tên bản địa hóa, tên tiếng Anh, alias, ISO2, ISO3.
- Xếp hạng: tiền tố trước, rồi tiền tố từ, rồi chuỗi con. Kết quả theo thứ tự `order` tính sẵn.
- Không lọc khi bộ gõ (IME) đang soạn (ja, zh, ko) — chờ chốt ký tự.
- Không có kết quả: "Không tìm thấy" kèm nút "Tắt bộ lọc".
- Số kết quả được đọc cho trình đọc màn hình, làm chậm (debounce).
- Chữ viết khác: người dùng ja/zh/ko/ar/th vẫn tìm được bằng tên tiếng Anh vì `en` luôn được nạp.

### 9.4 Cờ
Cờ emoji dựng từ ISO2 chỉ để trang trí; tên và chip ISO luôn có (F34). Bộ cờ SVG đóng gói là việc tùy chọn về sau (thêm dependency/asset, chủ dự án quyết, D2).

### 9.5 Chuỗi mới (nguồn tiếng Việt), đặt ở `lib/core/l10n/geo_strings.dart`

Các khóa chính: tiêu đề bộ chọn, gợi ý ô tìm, chip "Chỉ nơi được hỗ trợ", nhãn 6 vùng, 5 trạng thái, "Chưa xác minh", "Không tìm thấy" + "Tắt bộ lọc", nhãn ngữ nghĩa từng hàng, các `notes`, câu giải thích cho `restricted`/`separate`/`unknown`, "Báo sai", chuỗi banner khác biệt vùng, chuỗi kiểm tra thủ công (mục 8.4, 10). Cần hỗ trợ số nhiều/ICU (đếm "N quốc gia") trong cơ chế i18n của chủ dự án.

---

## 10. Máy chủ theo từng tài khoản và luồng vào app

**Cài đặt → Tài khoản → [tài khoản] → "Máy chủ"**

Điều khiển phân đoạn: **"Tự động (theo tài khoản Riot)"** (mặc định) | **"Thủ công"**.

- **Tự động** hiển thị: "Riot xác định: AP – Châu Á – Thái Bình Dương · kiểm tra lúc {thời điểm}"; "Quốc gia tài khoản: {tên}" (nếu có `country`); nút **"Kiểm tra lại"** gọi riot-geo. Nếu vùng đang là tạm hoặc chưa hỗ trợ, hiển thị trạng thái tương ứng và nút chọn vùng.
- **Thủ công** hiển thị: sáu vùng nhóm theo shard kèm chú thích "LATAM, BR và NA dùng chung shard NA"; chip gợi ý theo quốc gia tài khoản (từ `countries.json`, chỉ là gợi ý); cảnh báo "Chỉ dùng khi Tự động sai; chọn sai sẽ làm cửa hàng/hồ sơ không tải được"; nút Lưu chạy bước kiểm tra ở 8.4.
- `AccountTile` (`account_widgets.dart`) hiển thị vùng hiệu lực và "· thủ công" ở chế độ thủ công.
- Banner khác biệt: khi `SessionRegionMismatch`, hiện trên hàng tài khoản và ở Trang chủ: "Khu vực thủ công khác với Riot (AP). Dùng Tự động?" kèm hai nút (Dùng Tự động / Giữ thủ công). Không chuyển ngầm, không `needsLogin`.
- Thẻ trạng thái ở Trang chủ và MaintenanceBanner theo vùng hiệu lực của tài khoản đang dùng; trước khi đăng nhập theo vùng của quốc gia đã chọn (`countries.json`). Nếu chưa biết (region null), ẩn thẻ.

**Luồng lần đầu**: chọn ngôn ngữ → chọn quốc gia (tùy chọn, mặc định từ locale thiết bị) → đăng nhập Riot (riot-geo quyết định vùng) → nếu riot-geo lỗi thì mở bộ chọn vùng với gợi ý. Quốc gia chọn trước đăng nhập không đặt vùng cho tài khoản; chỉ đặt mặc định cho feed trạng thái và gợi ý.

---

## 11. Cộng đồng và LFG: lọc quốc gia và ngôn ngữ

Bám `docs/community-api.md` "Community scopes v3" [R]; client hiện đã có `scope_providers.dart`, `scope_bar.dart`, `countries_sheet.dart`, `community_api.dart` (63 chỗ nhắc scope/appliedScope/communities) nên đây là nâng cấp, không viết mới.

| Hạng mục | Thiết kế |
|---|---|
| Phạm vi | `country` \| `region` \| `global`. Mặc định máy chủ: bảng tin, xếp hạng skin theo quốc gia người xem (fallback: vùng, rồi toàn cầu); LFG theo vùng của người xem; xếp hạng skin/đánh giá mặc định toàn cầu. Client luôn hiển thị `appliedScope` máy chủ trả về (ví dụ chữ "Khu vực" khi người xem không có quốc gia) thay vì tin phạm vi mình yêu cầu. |
| Quốc gia của người xem | **Do máy chủ lấy từ Riot `/userinfo` khi `POST /v1/auth/riot`, không sửa được**, làm mới mỗi lần xác thực. Client không bao giờ gửi `country`. Khi khách (chưa đăng nhập/chưa đồng ý) mặc định `global`. |
| Vùng gửi lên | `communityRegion(detectedRegion ?? region)`; nếu chưa biết vùng thì không đăng nhập cộng đồng (thay vì rơi về `ap`). |
| Chọn quốc gia lọc | Biến thể bộ chọn (mục 9) gồm hai thẻ: "Có hoạt động" (từ `GET /v1/communities`, hiển thị số bài/tác giả/LFG 7 ngày, công khai không cần phiên) và "Tất cả quốc gia" (toàn bộ `CountryDb`). Quốc gia của người xem ghim đầu. Bộ lọc "chỉ nơi được hỗ trợ" ẩn ở biến thể này. **Loại `XK` (không phải ISO)**: máy chủ trả `400 invalid_input`; client kiểm tra bằng `CountryDb` trước khi gửi. |
| Nhãn vùng | 6 vùng x 18 ngôn ngữ trong `geo_strings.dart`; thay `CommunityStrings.regionLabel` (hiện chỉ tiếng Việt) và `account_strings.dart` regionAp... |
| Ngôn ngữ nội dung | 18 ngôn ngữ app → 17 mã máy chủ: es-ES/es-MX → `es`, pt-BR → `pt`, zh-CN, zh-TW giữ nguyên, còn lại theo mã ngôn ngữ. Gửi trong `POST /v1/auth/riot` (`language`) và cập nhật qua `PATCH /v1/me`; máy chủ chấp nhận `zh_CN` dạng `_`, nhưng client gửi dạng chuẩn. |
| Bộ lọc ngôn ngữ | Chọn nhiều, chip có tên tự gọi (autonym) làm nhãn chính, tên theo ngôn ngữ người dùng làm phụ; danh sách tối đa 17 mã (máy chủ từ chối quá nhiều). Mặc định = ngôn ngữ app. LFG: `language=vi,...` luôn gồm bài `any`; gửi `any` nghĩa là không lọc (F32). Bài viết/đánh giá không có `any`. |
| Ngôn ngữ khi đăng bài | Mặc định = ngôn ngữ tác giả; cho sửa ("bài viết bằng ngôn ngữ nào") để người đọc khác dùng dịch trên thiết bị. LFG thêm lựa chọn `any`. |
| Lọc kiểm duyệt | Máy chủ lọc từ cấm theo ngôn ngữ (danh sách vi/en; 15 ngôn ngữ khác best-effort, chờ người bản ngữ duyệt). UI không được tuyên bố "đã kiểm duyệt đầy đủ" cho ngôn ngữ ngoài vi/en. |
| Riêng tư | Quốc gia, vùng, ngôn ngữ, Riot ID, rank, thẻ là **công khai theo thiết kế** với người đọc bài; ứng dụng đã xin đồng ý trước lần đăng nhập đầu tiên (`community-api.md`). Màn đồng ý phải nêu rõ quốc gia hiển thị công khai. |

---

## 12. Mọi thiết bị

**Bố cục theo chiều rộng**

| Chiều rộng | Trình bày |
|---|---|
| dưới 600dp | Tờ modal cao toàn màn hình. Điện thoại nằm ngang, hoặc khi bàn phím mở: route toàn màn hình (kiểm tra thêm chiều cao dưới ~480dp). |
| 600–839dp (iPad dọc, màn hình gập mở) | Hộp thoại rộng tối đa 560dp. |
| từ 840dp | Danh sách và chi tiết cạnh nhau, tách theo bản lề bằng `MediaQuery.displayFeatures` (hộp thoại dùng `DisplayFeatureSubScreen`). |

**Chữ và chạm**: không đặt chiều cao hàng cố định; huy hiệu tự xuống dòng; kiểm thử ở 200% (và 300%) cỡ chữ tại rộng 360dp; vùng chạm tối thiểu 48dp; tương phản đạt WCAG AA theo `docs/design/DESIGN.md`.

**Trình đọc màn hình**: mỗi hàng một nút ngữ nghĩa gộp: "{tên}, máy chủ AP Châu Á – Thái Bình Dương, được hỗ trợ" kèm trạng thái đã chọn; với `restricted`/`separate`/`unknown` đọc thẳng câu trạng thái; chip là nút bật/tắt có trạng thái chọn; tiêu đề mục là header; cờ bị loại khỏi ngữ nghĩa; ẩn chỉ mục A–Z khi `accessibleNavigation` bật và với ja, zh, ko, th, ar.

**Giảm chuyển động**: khi `MediaQuery.disableAnimations` bật, bỏ animation danh sách, bộ lọc và chuyển Hero.

**Ả Rập (RTL)**: layout qua `Directionality`, dùng `EdgeInsetsDirectional`; chip ISO và số vẫn trái-sang-phải.

**Mù màu**: trạng thái luôn có biểu tượng khác hình + chữ; hàng đang chọn có dấu tick + đậm + viền, không chỉ đổi màu; banner khác biệt vùng có biểu tượng cảnh báo + chữ.

**Xoay/gập**: khi xoay hoặc gập/mở, giữ ô tìm kiếm, chip, vị trí cuộn, hàng đang chọn (state nằm ngoài widget theo provider, không mất khi rebuild).

---

## 13. Riêng tư và an toàn (tổng hợp)

- Quốc gia tài khoản lưu cùng bản ghi Account (nơi `region` đang lưu, R11), không bao giờ gửi đi đâu; máy chủ cộng đồng tự lấy quốc gia từ Riot với sự đồng ý của người dùng (mục 11).
- Lựa chọn quốc gia của người dùng (`geo.country`) chỉ ở Prefs cục bộ, không gửi.
- Không định vị IP. Tải xuống duy nhất: file dữ liệu JSON tĩnh (cập nhật từ xa) và, khi dùng bộ chọn, không có yêu cầu mạng nào.
- Khối từ xa bị kiểm tra chặt và bị giới hạn không đổi shard đã có (5.5).
- Không tuyên bố pháp lý: mọi chuỗi về `restricted` chỉ dẫn Điều khoản của Riot và nói rõ ValVN không chặn theo quốc gia.
- Nội dung nhạy cảm về chính trị (Đài Loan, Hồng Kông, Ma Cao, Palestine, Kosovo): dùng tên CLDR (alt-short), không tự đặt tên; cờ chỉ trang trí, có thể thay bằng SVG sau (D2).

---

## 14. Kiểm thử

**Dữ liệu (test Dart và script CI)**
- `regions.json`: mỗi vùng trong sáu vùng ánh xạ đúng shard (ap→ap, eu→eu, kr→kr, na/latam/br→na); `pbe` ẩn, không nằm trong `visibleRegions`; vùng lạ trả `null` (không trả lại chính nó).
- `countries.json`: đủ 249 mã ISO (+XK gắn `nonIso`); mọi `region` hợp lệ; mọi `src` tồn tại; mọi dòng `official` trích nguồn `kind=official`; `official` có đúng 29 mã ở mục 7; CN là `separate`; CU/IR/KP là `restricted`; SY là `unknown`; AQ là `na`; không có `console:false`.
- Tên: 18 file, mỗi file đủ 249 mã (hoặc cảnh báo rơi về `en`); `order` cùng tập với `names`; không còn mã 001, 419, EU, UN, ZZ...; HK/MO/PS dùng tên rút gọn.
- **Đối chiếu với máy chủ**: script `tool/geo/check_server_parity.mjs` so bảng alpha-3→alpha-2 của `server/community/src/geo/countries.ts` với `countries.json` (khớp chính xác trừ XK), và danh sách 17 ngôn ngữ của `languages.ts` với bảng ánh xạ 18→17 của client.
- Ánh xạ alpha-3: `vnm`→VN, `deu`→DE, `VNM` hoa→VN, `vn` hai chữ→VN, rác/rỗng/null→null.
- `suggestRegion`: `vn`→`ap`, `de`→`eu`, `mx`→`latam`, `cn`→null, `ir`→`eu` (đoán, `conf=unverified`).
- Khối từ xa: gộp từng mục; chỉ áp dụng khi `dataVersion` cao hơn; từ chối id có `.`/`/`/chữ hoa/quá dài, URL không https, enum lạ, khối quá lớn; không cho đổi shard vùng đã có, không cho shard mới (nếu D3 được duyệt); khóa lạ bị bỏ.

**Tìm kiếm**: "viet nam"→VN, "han quoc"→KR, "usa"→US, "Türkiye"/"turkiye"→TR, "deu"→DE, "日本"→JP ở locale ja, "Japan" ở locale ja→JP (tìm chéo bằng en); xếp hạng tiền tố > tiền tố từ > chuỗi con; không lọc khi đang soạn IME (kiểm thử bằng trạng thái composing giả lập).

**Phiên (SessionManager, Account)**
- `Account.fromJson` với vùng thiếu không còn là `ap`, thành `''`; tài khoản cũ được di chuyển đúng.
- Bất biến `region`/`shard` theo `regionMode`.
- Thủ công không bị ghi đè khi đăng nhập, kiểm tra 7 ngày, hoặc sau lỗi re-auth; sự kiện `SessionRegionMismatch` phát đúng một lần cho mỗi phát hiện; **không** `needsLogin` vì vùng ở chế độ thủ công.
- Tự động: đổi vùng sau lỗi re-auth vẫn tự chuyển (R4); kiểm tra 7 ngày dùng đồng hồ giả và chỉ một PUT.
- riot-geo lỗi lúc đăng nhập: đăng nhập vẫn hoàn tất, vùng tạm, mở bộ chọn; retry ở lần re-auth kế.
- Vùng lạ: "chưa hỗ trợ", không dựng host.
- Thăm dò kiểm tra: 2xx; 400/404 JSON (chặn); 401 (re-auth rồi thử lại); 5xx; lỗi mạng; trang HTML Cloudflare; hết thời gian.
- Không log token/PUUID/quốc gia (test quét nội dung log).
- `RiotHosts`: mọi host dựng từ `RegionTable`; `kChatFallbackHosts` dựng từ `regions.json`; khớp bảng cũ.

**Đăng nhập, ngôn ngữ**
- Mỗi giá trị `ui_locales` sinh ra từ 18 locale app phải thuộc `ui_locales_supported` (F30): ar, de, en, es, es-419, fr, id, it, ja, ko, pl, pt-BR, ru, th, tr, vi, zh-Hans, zh-Hant.
- `StatusNotice.localized`: locale app dạng gạch dưới → nếu là zh_CN thì zh_TW → en_US → mục đầu tiên. Ghi chú: quy tắc zh_CN→zh_TW là lựa chọn thiết kế vì feed không có zh_CN (F5), không phải sự thật (D4).
- `ItemLanguage`: 18 mã; chưa kiểm chứng với valorant-api.com nên thêm kiểm tra sống ở dưới.
- Ánh xạ 18→17 mã cộng đồng, gồm `es-MX`→`es`, `pt-BR`→`pt`, `zh-CN`, `zh-TW`.

**Widget/golden** (bắt buộc)
- Ngôn ngữ vi và ar (RTL); cỡ chữ 2.0 (và 3.0) rộng 360dp; điện thoại ngang; máy tính bảng và màn hình gập có bản lề; bộ lọc "chỉ nơi được hỗ trợ" bật/tắt; trạng thái rỗng; hàng `restricted`/`separate`/`unknown`.
- Ngữ nghĩa: mỗi hàng một nút gộp có nhãn đủ; chip là nút bật/tắt; tiêu đề header; cờ không nằm trong cây ngữ nghĩa; chỉ mục A–Z ẩn khi `accessibleNavigation`; kiểm tra `tapTargetGuideline`, `labeledTapTargetGuideline`.
- Giảm chuyển động: không có animation khi `disableAnimations`.

**Kiểm tra sống theo lịch (không chặn PR, tránh flaky)**: 7 feed trạng thái trả 200 và id khớp; `ui_locales_supported` vẫn chứa các giá trị ta dùng; valorant-api.com nhận đủ 18 mã `language` (Q14); Riot `regions` mới xuất hiện trong feed/routing thì báo.

---

## 15. Thứ tự triển khai và file bị ảnh hưởng

| Pha | Nội dung | Phụ thuộc |
|---|---|---|
| P0 | Sửa tài liệu (mục 18). `tool/geo/gen_geo.mjs`, `overrides.yaml`, sinh 4 loại JSON; `RegionTable`, `CountryDb`; `riot_hosts.dart` thành lớp bọc; test dữ liệu và đối chiếu máy chủ. Chưa đổi hành vi. | — |
| P1 | Trường Account mới + di chuyển; bỏ `'ap'`; đăng nhập không cần riot-geo; kiểm tra 7 ngày; `SessionRegionMismatch`; `tryForRegion`; `communityRegion` cho phép null. | P0 |
| P2 | Widget chọn quốc gia lõi; bước onboarding; Cài đặt "Quốc gia/khu vực"; "Máy chủ" theo tài khoản; banner; thẻ trạng thái Trang chủ; nối bảng giá VP với lựa chọn. | P0, P1 |
| P3 | Nối locale: `ui_locales`, `StatusNotice`, `ItemLanguage` 18 mã, ngôn ngữ cộng đồng, tên vùng 18 ngôn ngữ; thay `CommunityStrings.countryNames`/`regionLabel`. | Kế hoạch i18n 18 ngôn ngữ (ngoài tài liệu này) |
| P4 | Khối `geo` từ xa + hosting. | Q18, D3 |
| P5 | (Tùy chọn) bộ cờ SVG. | D2 |

File sẽ đụng (tham khảo): `lib/core/riot/riot_hosts.dart`, `lib/core/riot/region_table.dart` (mới), `lib/core/geo/*` (mới), `lib/core/accounts/account.dart`, `account_providers.dart`, `account_widgets.dart`, `lib/core/auth/session_manager.dart`, `bootstrap_client.dart`, `auth_callback.dart`, `lib/core/config/app_constants.dart`, `local_price.dart`, `lib/core/riot/platform_status.dart`, `lib/core/xmpp/xmpp_parsers.dart`, `lib/core/settings/app_settings.dart`, `lib/core/l10n/locale.dart`, `lib/core/l10n/account_strings.dart`, `geo_strings.dart` (mới), `lib/features/community/**` (`community_models.dart`, `community_strings.dart`, `ui/scope/*`, `providers/*`, LFG), màn Cài đặt và Trang chủ, `pubspec.yaml` (assets), `assets/data/`, `assets/l10n/`, `tool/geo/`.

---

## 16. Câu hỏi mở (chưa kiểm chứng hoặc không kiểm chứng được)

Không mục nào dưới đây được trình bày là sự thật ở phần trên.

| # | Câu hỏi | Vì sao chưa biết | Cách giải quyết |
|---|---|---|---|
| Q1 | Riot có thực sự chặn kết nối (client/RSO) ở CU, IR, KP, SY hoặc từ IP Trung Quốc đại lục không? | Chỉ có điều khoản pháp lý (F22) và FAQ tặng quà có nêu Iran (F26); không có nguồn về việc chặn kỹ thuật. | Giữ nhãn "theo Điều khoản của Riot"; ValVN không chặn theo quốc gia; hỏi người dùng thực tế/Riot Support. |
| Q2 | Riot hiện có phục vụ Syria không? | OFAC gỡ cấm vận toàn diện 07/2025 (F24) nhưng chưa có nguồn từ Riot. | `status=unknown` cho tới khi có nguồn Riot. |
| Q3 | Riot có trang chính thức nào liệt kê nước bị chặn/không khả dụng không? | Không tìm thấy; lần tìm cuối bị ngắt phiên nên "không có" cũng chưa chắc. | Tìm lại (ví dụ "not available in your country"); nếu có, chuyển thành nguồn `official` cho `status`. |
| Q4 | PD trả gì (mã, thân) khi tài khoản gọi sai shard? | Chưa ai thử trong tài liệu nghiên cứu. | Thử nghiệm chỉ đọc với tài khoản thử, ghi lại rồi chỉnh bảng 8.4. |
| Q5 | Cooldown/điều kiện đổi RoR của VALORANT là bao lâu; hiện có công cụ chuyển tài khoản không? | Con số 90 ngày chỉ từ blog VPN (C3); "Account Transfer FAQ" nói về LoL (C2); 2020 Riot dự kiến giữa 2021 (S-ask-2020) nhưng chưa rõ kết quả. | Đọc công cụ Riot bằng tài khoản thật; đến lúc đó không nêu con số nào trong app. |
| Q6 | Console "Europe" gồm nước nào (TR, MENA, châu Phi, CIS)? | Riot chỉ ghi "Europe". | `console=null` ngoài các nước được nêu đích danh. |
| Q7 | Tài khoản chỉ chơi console có riot-geo affinity và các endpoint ValVN dùng không? Phân vùng console (JP, OCE) ánh xạ shard nào? | Console xếp hạng/MMR riêng (F29); chưa có nguồn về API. | Thử với tài khoản console; đến khi đó không tuyên bố ValVN hỗ trợ console. |
| Q8 | Shard đúng của các nước ở tầng 3 (PK, AF, MN, IR, lãnh thổ Mỹ, GL/BM/PM, RE/YT/SH, NC/PF/WF/CX/CC/NF, đảo Thái Bình Dương, GY/SR/GF/FK) và độ chính xác từng nước ở tầng 2? | Không có nguồn theo từng nước; PK chỉ có báo chí 2020 chưa mở được. | Thu thập từ báo cáo người dùng ("Báo sai"), nguồn Riot mới; cập nhật qua khối từ xa. Runtime luôn dùng riot-geo nên rủi ro chỉ là nhãn/gợi ý. |
| Q9 | Khi Dubai/Bahrain tắt (03/2026) người chơi Trung Đông được chuyển server nào; Mumbai/Riyadh dự phòng có đổi shard không? | Chỉ có báo chí; không có tài liệu Riot. | Không dùng làm dữ liệu; minh họa cho P2, P5. |
| Q10 | Dubai thuộc shard nào? | Nguồn đã xác nhận không nói. | Không đưa Dubai vào `servers` cho tới khi có nguồn. |
| Q11 | Account-V1 có luôn cần khóa API nhà phát triển không? | Chuẩn chung, chưa xác nhận lại. | Không ảnh hưởng thiết kế (app không dùng). |
| Q12 | Giới hạn thanh toán ở Nga/Belarus/Kazakhstan/Georgia/CIS (03/2022) còn áp dụng không? | Chỉ bài báo 2022. | Ghi "chưa rõ còn áp dụng" hoặc bỏ ghi chú nếu không xác minh được. |
| Q13 | iOS hiện nay còn hiển thị cờ Đài Loan thành ô lỗi ở vùng Trung Quốc đại lục không? | Nguồn 2018/2019. | Giữ tên + chip ISO (đã có); cân nhắc D2. |
| Q14 | valorant-api.com có nhận đủ 18 mã `language` không? | Chỉ xác nhận danh sách của API Riot (F31), khác API. | Kiểm tra sống theo lịch (mục 14) và trước P3. |
| Q15 | `country` của userinfo có luôn có, luôn alpha-3 chữ thường? | Chỉ ví dụ cộng đồng (F14). | Parser phòng thủ, mọi giá trị lạ thành `null`; đã có ở máy chủ (`countryFromAlpha3`). |
| Q16 | Host PBE. | U22 chưa xác minh. | Giữ ẩn. |
| Q17 | Mã ISO/CLDR có mã nào Riot dùng khác (ví dụ XK)? | Không có nguồn. | `XK` chỉ trong bộ chọn cục bộ, không gửi máy chủ. |
| Q18 | Host cho JSON cập nhật từ xa. | `remoteConfigUrl` rỗng. | Chọn máy chủ cộng đồng hoặc GitHub Pages (D3). |
| Q19 | URL còn thiếu: bài Bogotá 12/04/2022, Sina Finance, 18183, The Spike (Trung Quốc), Kenh14. | Fact-check nêu tên, không ghi URL. | Bổ sung vào `tool/geo/sources.yaml` trước khi commit dữ liệu. |
| Q20 | Nút "Báo sai" mở đích nào (GitHub issue hay email)? | Chưa quyết. | Chủ dự án chọn. |
| Q21 | Nếu Riot thêm vùng/shard mới thì sao? | Không thể biết trước. | Vùng mới ánh xạ shard sẵn có qua khối từ xa; shard mới cần phát hành app (D3). |

---

## 17. Quyết định cần chủ dự án

| # | Quyết định | Đề xuất |
|---|---|---|
| D1 | "Chỉ nơi được hỗ trợ" bật mặc định? | Có (ẩn `restricted`, `separate`, `unknown`, `na`; luôn có nút tắt). |
| D2 | Bộ cờ SVG đóng gói (thêm dependency/asset) hay dùng emoji? | Emoji trước, SVG là bước sau. |
| D3 | Khối `geo` từ xa: có làm không, host ở đâu, có cho đổi shard vùng đã có không? | Làm sau P3; host tĩnh; **không** cho đổi shard đã có/không cho shard mới. |
| D4 | Feed trạng thái không có zh_CN: rơi về zh_TW hay en_US cho người dùng zh-CN? | zh_TW rồi en_US (chữ phồn thể vẫn đọc được với đa số); đổi nếu chủ dự án muốn. |
| D5 | Câu chữ cho `restricted`. | "Bị hạn chế theo Điều khoản của Riot (lệnh cấm vận của Mỹ)"; không dùng "bị chặn". |
| D6 | Đích của "Báo sai" (Q20). | GitHub issue công khai hoặc email hỗ trợ. |

---

## 18. Sửa tài liệu khác

- `docs/design/IA.md` dòng 41: "khu vực AP" đổi thành "khu vực của bạn" (cả sáu feed đều hoạt động, F5).
- `docs/research/SUMMARY.md` §4: sửa ghi chú 403 của `latam.json`, `br.json`, `kr.json` (nay trả 200, F5); giữ nguyên bảng shard.
- `CLAUDE.md`: quy ước "Dữ liệu nội dung lấy từ valorant-api.com với `language=vi-VN`" và "toàn bộ chuỗi là tiếng Việt" cần cập nhật khi cơ chế 18 ngôn ngữ được chốt (ngoài phạm vi tài liệu này).
- `docs/design/COUNTRIES.md` (tài liệu này) là nguồn tham chiếu cho dữ liệu vùng/quốc gia; `docs/ARCHITECTURE.md` bổ sung `RegionTable` và `CountryDb` khi P0 xong.
