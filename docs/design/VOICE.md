# ValVN — Giọng văn & thuật ngữ (Voice and terminology guide)

| | |
|---|---|
| Trạng thái | Áp dụng từ 30/09/2026. Bản tiếng Việt là **bản gốc (master)** để dịch sang 17 ngôn ngữ còn lại. |
| Ai dùng | Mọi người viết hoặc sửa chữ hiển thị cho người chơi: `lib/**/*_strings.dart`, `lib/core/l10n/**`, văn bản pháp lý trong app, thông báo, chữ trên ảnh chia sẻ, chuỗi hệ điều hành (Info.plist), README/trang cửa hàng, chuỗi máy chủ Cộng đồng trả về. |
| Nguồn thuật ngữ | `docs/research/valbuddy-features.md` §7–§8 (bảng thuật ngữ) và `valorant-api.com?language=vi-VN`. Khi hai nguồn mâu thuẫn: dữ liệu vi-VN của game thắng. |
| Liên quan | `CLAUDE.md` (Quy ước), `docs/design/I18N.md` §4, §14.3 (khóa ARB, từ điển, placeholder), `docs/design/IA.md`. |

*English gloss: this is the single voice and terminology guide for everything a player can read in ValVN. Vietnamese is the master text that all other locales are translated from; each rule has a short English gloss in italics.*

---

## 1. Giọng văn — một đồng đội biết chơi VALORANT

ValVN nói như một **đồng đội đang chơi VALORANT cùng bạn**: thân thiện, gọn, chỉ nói điều cần nói. Không phải công ty, không phải kỹ sư.

| # | Nguyên tắc | Ví dụ đúng | Ví dụ sai |
|---|---|---|---|
| 1.1 | **Nói chuyện của người chơi**, không nói chuyện của hệ thống. Mô tả điều người chơi thấy và làm, không mô tả cách app hoạt động bên trong. | "Đăng nhập Riot của bạn đã hết hạn." | "Phiên đã hết hạn (token invalid)." |
| 1.2 | **Ngắn.** Nhãn nút 1–3 từ, tiêu đề 2–5 từ, mô tả ≤ 2 câu, mỗi câu một ý. | "Thêm tài khoản" | "Nhấn vào đây để thêm một tài khoản mới vào ứng dụng" |
| 1.3 | **Xưng "bạn"**, không "quý khách", "người dùng", "user", "ae", "bro". ValVN là chủ ngữ khi cần ("ValVN sẽ tự thử lại"), không dùng "chúng tôi" trong giao diện (chỉ dùng trong văn bản pháp lý). | "Bạn có thể tắt bất cứ lúc nào." | "Người dùng có thể tắt tính năng này." |
| 1.4 | **Thân thiện nhưng không lố.** Không emoji (giữ ký hiệu ♡ khi nói tới nút tim). Dấu chấm than chỉ cho khoảnh khắc vui (đăng bài xong, có skin wishlist), **không bao giờ** trong thông báo lỗi. Không tiếng lóng dễ lỗi thời ("cá mập", "xịn xò"...). | "Đã đăng bài!" | "Ối giời ơi lỗi rồi bro 😭" |
| 1.5 | **Nói thẳng, không đổ lỗi.** Lỗi là chuyện đã xảy ra + việc nên làm, không bao giờ "bạn đã làm sai". | "Chưa đăng được. Hãy kiểm tra lại rồi thử lại." | "Bạn nhập sai dữ liệu không hợp lệ." |
| 1.6 | **Không dọa.** Với quyền riêng tư và đồng ý: nói cụ thể điều gì được gửi, gửi cho ai, để làm gì, và cách rút lại. Không "cảnh báo nghiêm trọng", không thuật ngữ pháp lý trong màn hình đồng ý. | "Người khác sẽ thấy Riot ID và rank của bạn." | "Bằng việc tiếp tục, bạn chấp thuận việc xử lý dữ liệu cá nhân…" |
| 1.7 | **Không có gì trông như console.** Không dòng log, mã HTTP, ID, JSON, stack trace, URL thô, số phiên bản/bản dựng ngoài trang Giới thiệu. Cần chẩn đoán → người chơi tự bấm "Gửi báo lỗi cho ValVN" (§6). | "Không tải được dữ liệu. Thử lại." | "DioException [404] /store/v3/storefront/{id}" |

*English gloss: a teammate who plays VALORANT — friendly, short, second person "bạn", no corporate or engineering tone, no emoji spam, no slang that ages badly, no blame, no fear in consent text, and nothing that looks like console output.*

---

## 2. Quy tắc viết

| # | Quy tắc | Ghi chú |
|---|---|---|
| 2.1 | **Sentence case**: chỉ viết hoa chữ đầu câu và tên riêng ("Cửa hàng phụ kiện", "Lịch sử đấu"). Tên trong game giữ đúng dạng của game (Chợ Đêm, Battle Pass, Thượng Nhân). Viết HOA TOÀN BỘ chỉ dành cho nhãn nhóm nhỏ và **do kiểu hiển thị** làm (`x-caps`, I18N §4.5); chuỗi mới viết sẵn sentence case. | *Sentence case; all-caps only through rendering.* |
| 2.2 | **Động từ mở đầu cho hành động**: "Thêm", "Xóa", "Đăng nhập lại", "Gửi báo lỗi". Nút không có "Vui lòng", "Hãy" (chỉ dùng "Hãy" trong câu hướng dẫn). | *Buttons start with a verb.* |
| 2.3 | **"Hãy…" thay cho "Vui lòng…"** trong câu hướng dẫn ("Hãy thử lại."). "Vui lòng" chỉ còn trong văn bản pháp lý. | *"Hãy", not "Vui lòng", in UI.* |
| 2.4 | **Thao tác chạm**: "Chạm" để chạm vào nội dung ("Chạm ♡ để thêm"), "Bấm" để bấm nút có nhãn ("Bấm Đăng nhập"), "Kéo" để kéo/kéo xuống làm mới, "Giữ" để nhấn giữ. Không dùng "Nhấn", "Nhấp", "Click". | *Tap = Chạm, press a labelled button = Bấm.* |
| 2.5 | **Dấu câu**: dấu ba chấm là một ký tự `…` (U+2026) cho việc đang chạy ("Đang tải…"); gạch giữa số dùng en dash `–` ("8 – 4"); dấu trừ của số âm là `−` (U+2212), "±" giữ nguyên; dấu chấm giữa ` · ` để ngăn các dữ kiện ngắn; nháy kép kiểu “ ”. Không dấu chấm cuối nhãn, tiêu đề, nút; có dấu chấm cuối câu đầy đủ. | *One ellipsis character, en dash for scores, U+2212 for minus.* |
| 2.5b | **Không viết hoa** nhấn mạnh trong câu ("HÃY thử lại"), không ký tự trang trí ("★★", "→" trong câu; mũi tên chỉ ở nhãn sắp xếp có sẵn). | |
| 2.6 | **Số, tiền, thời gian đi qua định dạng theo thiết bị** (`AppFormats`), không viết cứng trong chuỗi. Số "2.175 VP", "+24 RR", "−17 RR", "≈ 9 trận", "còn 2 giờ", "5 phút trước", "38 phút". Ký hiệu khóa: VP, KC, RP, RR, K/D/A, ACS, HS%, ADR, MVP. | *Numbers/dates/times come from the formatter as placeholders.* |
| 2.7 | **Giờ**: luôn là **giờ của thiết bị** ("Làm mới lúc 07:00 ngày mai"). Không bao giờ ghi "giờ Việt Nam" hay múi giờ cố định. Không ghi giờ khi không biết chắc — bỏ hẳn cụm giờ. | *Device time zone only; never "Vietnam time".* |
| 2.8 | **"hằng ngày / hằng tuần"** (dạng từ điển), không "hàng ngày". "Tỉ lệ" (không "Tỷ lệ"). | *Consistent spelling.* |
| 2.9 | **Thiết bị**: nói "thiết bị" (hoặc "máy" trong câu thân mật), không "điện thoại" trừ khi thật sự nói về điện thoại, không "device"/"handset". | |
| 2.10 | **Không chỉ vị trí bằng hướng** ("nút bên phải", "phía trên") vì giao diện đảo chiều ở ngôn ngữ đọc từ phải sang trái. Gọi tên nút ("bấm Thêm"). | *No left/right/above/below wording (RTL).* |
| 2.11 | **Viết VALORANT** (đúng thương hiệu, chữ hoa), **Riot ID**, **Riot Games**, **ValVN**. Không "Valorant", "Val", "valo" trong giao diện. | |

---

## 3. Thuật ngữ chính thức (Official terms)

Nguyên tắc: (1) khái niệm người chơi thấy trong client vi-VN → dùng **đúng từ của client**; (2) từ người chơi Việt quen nói tiếng Anh → giữ tiếng Anh theo `CLAUDE.md`; (3) **không bao giờ tự đặt tên** cho khái niệm của game. Một khái niệm = một cách gọi trong toàn app.

| Khái niệm (EN) | Dùng | Không dùng |
|---|---|---|
| Agent | **Đặc vụ** | Điệp viên (cũ 2020), "tướng" (từ của LoL) |
| Lobby / Party / Party leader | **Sảnh chờ** / **Tổ đội** / **Trưởng nhóm** | "phòng chờ", "nhóm" cho tổ đội |
| Queue / Find match | **Hàng chờ** / **Tìm trận** | "xếp hàng" |
| Competitive / Unrated / Swiftplay / Spike Rush / Deathmatch / Team Deathmatch / Escalation / Replication / Custom | **Thi đấu xếp hạng** (nhãn ngắn "Xếp hạng") / **Đấu thường** / **Siêu Tốc** / **Đặt Spike Nhanh** / **Sinh Tử** / **Sinh Tử Đội** / **Tăng Tiến** / **Nhân bản** / **Chơi tự do** | Tên chế độ dịch tự do |
| Rank / RR / Act / Season / Round | **Rank** (hoặc "hạng" trong nhãn: "Hạng mục tiêu") / **RR** / **Phần** / **Mùa** / **Vòng** | "ĐXH" (chỉ patch notes), "Act" trong câu tiếng Việt |
| Attack / Defense / Spike | **Tấn công** / **Phòng thủ** / **Spike** | "phe công/thủ" trong nhãn (chỉ dùng trong tên hiệu ứng skin có sẵn) |
| Store / Night Market / Accessory Store / Bundle | **Cửa hàng** / **Chợ Đêm** / **Cửa hàng phụ kiện** / **Bundle** | "Bộ sưu tập" cho bundle (trùng tab Bộ sưu tập) |
| Collection / Loadout | **Bộ sưu tập** / **Trang bị** | |
| Player card / Title / Spray / Gun buddy / Expressions / Flex / Level border | **Thẻ người chơi** / **Danh hiệu** / **Hình phun sơn** / **Phụ kiện súng** / **Tổ hợp cảm xúc** / **Flex** / **Khung cấp** | "banner", "móc súng" (chỉ nói miệng) |
| Battle Pass / Event pass / Agent contract / Checkpoint | **Battle Pass** / **Vé sự kiện** / **Hợp đồng đặc vụ** / **Cột mốc** | |
| Content tiers | **Phiên bản** Tuyển Chọn / Sang Chảnh / Cao Cấp / Độc Quyền / Siêu Cấp | "hạng skin" |
| Currencies | **VP**, **KC**, **RP** (Radianite), Radianite, Huy hiệu đặc vụ | "Điểm VALORANT" |
| Skin, wishlist, bundle, Battle Pass, rank, Flex, Premier | giữ tiếng Anh | |
| Friends / Chat / Online / Offline / Away | **Bạn bè** / **Trò chuyện** / **Trực tuyến** / **Ngoại tuyến** / **Vắng mặt** | |
| Server (game) | **máy chủ** + tên thân thiện (§4) | mã "AP", "EU"... |
| Riot login | **đăng nhập Riot**, **tài khoản Riot**, **Riot ID** | "Riot account token", "auth" |

**Thuật ngữ chưa xác minh với client vi-VN** (giữ nguyên chữ hiện có, chưa "sửa cho hay"; kiểm tra với ảnh chụp từ người chơi VN trước khi phát hành): "trận phân hạng" (placement), "Hiệp 1 / Hiệp 2 / Hiệp phụ" (halves), "Phần mở rộng" (Epilogue), "Bộ trang bị đã lưu" (presets), "Đổi bên" (side switch), "Điểm hiệu suất" (Performance Score, patch 13.06). Xem Phụ lục D.

---

## 4. Bảng thay thế: từ kỹ thuật → lời của người chơi

Từ ở cột trái **không được xuất hiện** trong chuỗi hiển thị (trừ văn bản pháp lý, xem ghi chú). Nếu cần nói tới khái niệm đó, dùng cột phải.

| Từ cấm (developer speak) | Dùng thay | Ví dụ |
|---|---|---|
| token, access token, mã truy cập, JWT, cookie | **đăng nhập Riot** · **quyền truy cập Riot** (khi nói về thứ gửi đi để xác minh) · **dữ liệu đăng nhập** | "ValVN chỉ gửi quyền truy cập Riot của bạn một lần để xác minh Riot ID." |
| phiên, phiên đăng nhập (nghĩa kỹ thuật), session | **đăng nhập** ("Đăng nhập Riot đã hết hạn"), **kết nối Cộng đồng** | "Đăng nhập của Name#TAG đã hết hạn." |
| PUUID, UUID, ID tài khoản, mã người dùng | **không bao giờ hiện**; nếu cần: **Riot ID** (Tên#TAG) | |
| cache, bộ nhớ đệm | **dữ liệu tạm** | "Xóa dữ liệu tạm" |
| nhật ký phiên, session log, log, "Xuất nhật ký" | **báo lỗi** | "Gửi báo lỗi cho ValVN" |
| sync, đồng bộ | **cập nhật**, **làm mới** | "Cập nhật lúc 14:05" |
| shard, region, "AP/EU/NA/KR/BR/LATAM" | **máy chủ** + **Châu Á - Thái Bình Dương · Châu Âu · Bắc Mỹ · Hàn Quốc · Mỹ Latinh · Brazil** | "Máy chủ Châu Âu đang bảo trì." |
| endpoint, API, provider, client, backend, "máy chủ cộng đồng" | **Riot**, **VALORANT**, **Cộng đồng ValVN** | "Cộng đồng ValVN đang gặp sự cố." |
| HTTP, mã trạng thái, "lỗi 404/500", exception, null, timeout | nói **chuyện gì xảy ra** bằng lời: "phản hồi quá lâu", "đang bận", "không tìm thấy" | "Riot phản hồi quá lâu." |
| `riot_rejected`, `invalid_input`, tên hằng lỗi | không bao giờ; ánh xạ sang câu ở §5 | |
| "trong nền", "background" | **ngay cả khi bạn không mở ứng dụng** | |
| "ghi chú đăng nhập", "bộ nhớ bảo mật", "secure storage" | **thông tin đăng nhập đã lưu**, **được khóa an toàn trên thiết bị này** | |
| "Điền nhanh" (tên tính năng kỹ thuật) | **Điền tài khoản đã lưu** (động từ rõ nghĩa) | |
| số phiên bản, "Bản dựng 42" | chỉ ở **Giới thiệu & pháp lý** | |
| URL/host thô, tên repo, "valorant-api.com" | tên nguồn dễ hiểu ("dữ liệu công khai về VALORANT") — tên riêng chỉ ở mục **ghi công** | |
| "vote", "spam", "AFK", "toxic", "LFG" | **bình chọn**; spam/AFK là từ game quen thuộc (được giữ); "toxic" → "chửi bới, phá game"; LFG → **tìm đồng đội** | |
| "nạp"/"load" máy móc ("đang tải dữ liệu") | **đang tải…** (không nói "dữ liệu" nếu có tên cụ thể hơn: skin, đặc vụ, trận đấu) | |
| "dữ liệu" trống nghĩa ("Không có dữ liệu") | nói thứ đang thiếu: "Chưa có trận nào", "Chưa có gì để xem" | |

*Ngoại lệ có kiểm soát*: (a) văn bản pháp lý được giữ **một lần** thuật ngữ chính xác (token, PUUID, Cloudflare) kèm lời giải thích ngay trong câu, khi câu pháp lý nói riêng về thứ đó; (b) mục ghi công (valorant-api.com, techchrism/valorant-api-docs) giữ tên riêng vì nghĩa vụ ghi nguồn; (c) dòng `auth.riotgames.com` trên màn hình đăng nhập là dấu hiệu chống giả mạo, giữ nguyên.

*English gloss: the left column never appears in player-facing text (legal texts may keep one explained technical term where the legal statement is about it). Use the right column instead.*

---

## 5. Mẫu câu

### 5.1 Lỗi — "chuyện gì xảy ra + việc nên làm", có nút

Cấu trúc: **[Tiêu đề ngắn, tùy chọn]** · **Câu 1: chuyện gì xảy ra, bằng lời người chơi, nêu đúng bên gặp trục trặc** · **Câu 2: việc nên làm** · **Nút: "Thử lại" hoặc "Đăng nhập lại"**.

| Tình huống | Mẫu | Không viết |
|---|---|---|
| Mất mạng | "Không kết nối được mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại." | "Network error", "SocketException" |
| Phản hồi chậm | "Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại." | "Timeout 30s" |
| Riot bận | "Riot đang bận. Hãy thử lại sau ít phút." (có thời gian: "…thử lại sau 2 phút.") | "503 Service Unavailable" |
| Bảo trì | "Máy chủ VALORANT đang bảo trì. Hãy quay lại sau." | |
| Hết đăng nhập | "Đăng nhập Riot của bạn đã hết hạn. Hãy đăng nhập lại để tiếp tục." + nút **Đăng nhập lại** | "Token hết hạn (401)" |
| Không tìm thấy | "Không tìm thấy nội dung này." | "404" |
| Cộng đồng ValVN lỗi | "Cộng đồng ValVN đang gặp sự cố. Hãy thử lại sau ít phút." | "Máy chủ Cộng đồng trả về 500" |
| Nội dung bị từ chối | "Chưa đăng được. Hãy kiểm tra lại rồi thử lại." + lý do do người chơi hiểu được | tên trường ("body không được để trống") |
| Thay đổi tài khoản lỗi | tên việc + "Riot chưa nhận thay đổi này…" + nên làm gì | mã lỗi Riot |

Quy tắc: không bao giờ hiện mã, tên ngoại lệ, JSON, URL, ID; không "Vui lòng"; không dấu chấm than; nói rõ **bên nào** gặp sự cố (mạng của bạn / Riot / Cộng đồng ValVN) để người chơi biết có đáng thử lại không; lỗi hồi phục được luôn có nút thử lại; lỗi không hồi phục được (không có quyền, đã bị xóa) không có nút thử lại và nói rõ vì sao.

### 5.2 Trạng thái trống — thân thiện + bước tiếp theo

**Tiêu đề** (điều đang trống, ≤ 5 từ) · **1 câu**: nói vì sao/ý nghĩa + việc làm tiếp · **nút** khi có hành động rõ.
- "Chưa có skin nào" · "Wishlist trống. Chạm ♡ ở bất kỳ skin nào để thêm." · [Xem tất cả skin]
- "Bảng tin còn trống" · "Hãy là người đầu tiên chia sẻ cửa hàng, Chợ Đêm hay khoảnh khắc của bạn!"
- Không dùng "Không có dữ liệu". Nói thứ đang thiếu.

### 5.3 Đang tải / đang làm

"Đang tải…", "Đang lưu…", "Đang tạo ảnh…", "Đang kết nối trò chuyện…". Việc dài: nói việc đang làm, không nói "vui lòng đợi".

### 5.4 Thành công

Quá khứ, ≤ 6 từ, không "thành công": "Đã lưu", "Đã xóa bài viết", "Đã sao chép". Chấm than chỉ cho niềm vui ("Đã đăng bài!").

### 5.5 Hộp thoại xác nhận

Tiêu đề = câu hỏi có đối tượng ("Xóa bài viết?"). Nội dung = hậu quả trong 1–2 câu, nói rõ khi không hoàn tác được. Nút hủy "Hủy"; nút chính lặp lại động từ ("Xóa", "Rời trận"); hành động có hình phạt trong game (rời trận, né trận) **luôn** nêu hình phạt cụ thể ("mất RR, khóa hàng chờ") và màu nguy hiểm.

### 5.6 Đồng ý và quyền

Bố cục: **vì sao cần** → **điều gì được gửi/hiển thị và cho ai** → **điều gì luôn ở lại thiết bị** → **cách rút lại**. Dạng gạch đầu dòng ngắn, mỗi dòng một ý, không thuật ngữ, không điều khoản chằng chịt; liên kết tới Chính sách quyền riêng tư và Tiêu chuẩn cộng đồng thay vì chép lại.
- Quyền hệ điều hành (Info.plist): nêu **việc cụ thể** và **giới hạn**: "Chọn ảnh từ thư viện để đính kèm vào bài đăng của bạn trên Cộng đồng ValVN. ValVN chỉ dùng những ảnh bạn chọn."
- Mọi thao tác đổi trạng thái tài khoản (trang bị, khóa đặc vụ, hàng chờ, rời trận) do người chơi bấm; câu chữ phải nói rõ điều đó ("ValVN không tự tìm trận hay khóa đặc vụ thay bạn").

### 5.7 Thông báo (local notification)

- **Tiêu đề** ≤ 40 ký tự, là **sự kiện** ("Cửa hàng đã làm mới", "Chợ Đêm đã mở!"). Không Riot ID, không tên tài khoản, không chấm than trừ sự kiện vui.
- **Nội dung** ≤ 2 dòng, là **việc nên làm**; nêu tên tài khoản chỉ để phân biệt khi có nhiều tài khoản, đặt cuối câu trong ngoặc; Riot ID **không** nằm ở tiêu đề hay bản hiển thị công khai trên màn hình khóa (xem §9 để triển khai bản công khai).
- Tên kênh (Android) là danh từ ngắn, người dùng thấy trong cài đặt hệ thống: "Làm mới cửa hàng", "Wishlist", "Chợ Đêm", "Tài khoản". Mô tả kênh: một câu "Nhắc khi…"/"Báo khi…".
- Không bao giờ viết thông báo mà người chơi không biết mình đã bật.

### 5.8 Chia sẻ

Chữ trên ảnh chia sẻ là **giọng của người chia sẻ, ngôi thứ nhất**, ngắn, tự đứng được khi không có ngữ cảnh: "Cửa hàng VALORANT hôm nay của mình". Không Riot ID trên ảnh trừ khi người chơi bật; ảnh chú giá quy đổi luôn ghi "ước tính". Tên tệp chia sẻ là ASCII ngắn, không chứa ID/Riot ID.

---

## 6. Màn hình chỉ dành cho dev → "Nâng cao"

Nguyên tắc: **không có gì trông như console trong app.** Không màn hình liệt kê log, không dòng HTTP, không bộ lọc "Lỗi/HTTP", không tìm "mã lỗi". Mọi thứ chỉ dev cần nằm trong **tệp** người chơi tự bấm gửi.

| Trước | Sau |
|---|---|
| Cài đặt → Hỗ trợ → "Nhật ký phiên" (màn hình liệt kê log, tìm, lọc, sao chép, xóa) | **Bỏ màn hình.** Cài đặt → **Nâng cao** → **"Gửi báo lỗi cho ValVN"**: tạo tệp báo lỗi đã lọc sạch và mở bảng chia sẻ của hệ điều hành. Một câu giải thích: "Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn." |
| Cài đặt → Ứng dụng → "Xóa bộ nhớ đệm" | Cài đặt → **Nâng cao** → **"Xóa dữ liệu tạm"** (ảnh, dữ liệu đã tải để xem khi không có mạng, báo lỗi đã ghi; không đụng tới đăng nhập, wishlist, cài đặt) |
| Cài đặt → Ứng dụng → "Phiên bản 1.2.3 / Bản dựng 42" | Chỉ ở **Giới thiệu & pháp lý** |
| Cài đặt → Hỗ trợ → "Góp ý & báo lỗi — Gửi góp ý trên GitHub" | **"Góp ý cho ValVN"** (không nêu tên nền tảng dev) |
| Mã vùng "AP" cạnh mỗi tài khoản, tab "AP · EU · NA…" | Tên máy chủ thân thiện (§4) |
| Liên kết cũ `/settings/log` | Vẫn hợp lệ: chuyển thẳng về Cài đặt |

"Nâng cao" chỉ chứa hai hàng trên và **không có gì kỹ thuật khác**. Nhóm mới thêm vào đây phải qua checklist §8 và không được là màn hình chỉ chứa dữ liệu thô.

Cập nhật 07/10/2026: nhóm "Nâng cao" được bỏ. "Gửi báo lỗi cho ValHub" nằm trong **Hỗ trợ** (cùng "Giới thiệu & pháp lý"); mọi thao tác xóa dữ liệu trên máy ("Xóa dữ liệu tạm", "Xóa lịch sử RR", "Xóa dữ liệu cục bộ") gom vào nhóm **Dữ liệu trên máy**. Quy tắc trên vẫn giữ: không hàng nào hiện log hay mã kỹ thuật.

---

## 7. Giữ nguyên cấu trúc để trích xuất ARB (ICU) về sau

Mỗi chuỗi tiếng Việt sẽ thành một khóa ARB (`docs/design/I18N.md` §4). Viết chữ sao cho việc trích xuất là cơ học:

1. **Không ghép câu.** Một câu = một chuỗi (hoặc một hàm có placeholder). Không ghép hai chuỗi thành một câu, không cắt một câu thành nhiều chuỗi. Ngoại lệ đã biết (5 mảnh của dòng đồng ý đăng nhập) sẽ được gộp thành một chuỗi có thẻ khi cutover. Ghép **dữ kiện ngắn** bằng dấu ` · ` (hằng số) là được; ghép danh sách theo ngôn ngữ dùng hằng `commonListSeparator`, không tự viết ", ".
2. **Giữ placeholder** kiểu `$name`, `$count`, `$time` và **ý nghĩa** của chúng. Không đổi tên, không thêm placeholder mới, không chuyển placeholder sang chuỗi khác. Sửa lời mà làm một placeholder không còn xuất hiện phải được ghi lại (ví dụ `errorApi(int status)` không còn in mã).
3. **Số đứng ngay trước danh từ** để dịch giả chia số nhiều: "$n skin", "$n trận" (một chuỗi, số không tách khỏi danh từ). Không viết "skin(s)". Tránh "một/1" viết cứng cho số ít.
4. **Số, ngày, giờ, tiền** truyền vào dạng đã định dạng (placeholder chuỗi), không tự ghép dấu phân cách.
5. **Không HTML, không markdown, không ký tự `{` `}`**; không dấu nháy đơn `'` bao chữ; dùng “ ” cho tên nút được trích dẫn.
6. **Không thành ngữ, chơi chữ, viết tắt mơ hồ** khó dịch ("cày" → "cày rank" chỉ dùng khi là từ chuyên dụng), không chỉ hướng trái/phải (RTL).
7. **Ký hiệu khóa** (VP, KC, RP, RR, K/D/A, ACS, HS%, ADR, MVP, Riot ID, ValVN, PC, PlayStation, Xbox) không đổi, không dịch.
8. **Giới hạn độ dài**: nhãn tab/chip/nút ≤ 14 ký tự, huy hiệu ≤ 10, tiêu đề thông báo ≤ 40; đừng cắt nhãn bằng "…" trong chuỗi.
9. **Chuỗi hiển thị nằm trong `*_strings.dart` hoặc `lib/core/l10n/`**, không viết cứng trong widget. Điểm sót ở `wishlist_notification_toggle.dart` đã dùng helper chuỗi hiện có.
10. Khi sửa lời một chuỗi đã có bản dịch, băm nguồn đổi và mọi ngôn ngữ thành "stale" tới khi dịch lại: chỉ sửa khi có lý do (sai nghĩa, thuật ngữ, lộ chi tiết kỹ thuật).

---

## 8. Checklist duyệt chuỗi mới

- [ ] Người chơi hiểu được mà không cần biết lập trình? (không token, cache, API, HTTP, ID, phiên, đồng bộ...)
- [ ] Thuật ngữ game đúng bảng §3, một khái niệm một cách gọi? Không tự đặt tên?
- [ ] Sentence case, "bạn", "Hãy…" (không "Vui lòng"), "Chạm/Bấm" đúng, không "Nhấn/Nhấp/Click"?
- [ ] Lỗi có đủ "chuyện gì xảy ra + việc nên làm" và nút? Không mã, không tên ngoại lệ, không URL?
- [ ] Trạng thái trống nói thứ đang thiếu và bước tiếp theo?
- [ ] Đồng ý/quyền: nêu cụ thể gửi gì, cho ai, để làm gì, luôn ở lại đâu? Không dọa? Có đường rút lại?
- [ ] Không giả định Việt Nam: giờ theo thiết bị, không "giờ Việt Nam", không tiền/quốc gia/máy chủ cố định?
- [ ] Không có gì trông như console/log/debug; không số phiên bản ngoài Giới thiệu?
- [ ] Placeholder giữ nguyên tên và nghĩa; không ghép câu; số đứng cạnh danh từ; không `{ }`?
- [ ] Độ dài trong ngân sách (nút ≤ 14, thông báo ≤ 40 ký tự)? Không chỉ hướng trái/phải?
- [ ] Thông báo: tiêu đề = sự kiện, không Riot ID; nội dung = việc nên làm?
- [ ] Có xuất hiện từ trong bảng §4 cột trái? Nếu là văn bản pháp lý: đã giải thích ngay trong câu?
- [ ] Viết VALORANT, Riot ID, ValVN đúng dạng?
- [ ] Chuỗi do máy chủ trả về (Cộng đồng) đã có mã lý do để app tự dịch, không hiển thị văn bản thô của máy chủ?

---

## 9. Yêu cầu kỹ thuật để lead nối vào (không nằm trong phạm vi sửa chữ)

Ba việc này giữ lời hứa "không có gì trông như console" trong bản release. **Tài liệu này chỉ ghi yêu cầu; không sửa `lib/main.dart`, `lib/app/app.dart`** (đang do agent nền tảng i18n chỉnh).

1. **`ErrorWidget.builder` thân thiện ở bản release.** Mặc định Flutter release vẽ một ô xám trơn khi build lỗi (debug vẽ chữ đỏ có stack trace). Cần đặt `ErrorWidget.builder` (trong `main()` trước `runApp`) trả về một khung nhỏ: biểu tượng + `CommonStrings.errorGeneric` ("Có gì đó trục trặc. Hãy thử lại."), có `Semantics` đọc được, **không** in `details.exceptionAsString()`, không stack trace, dùng màu nền theo chủ đề sáng/tối của hệ thống (builder không có `BuildContext`; ngôn ngữ lấy từ `PlatformDispatcher.instance.locale` khi hệ i18n có). Ở bản debug giữ mặc định của Flutter.
2. **Bộ xử lý lỗi toàn cục chỉ ghi vào bộ nhớ trong.** `FlutterError.onError` và `PlatformDispatcher.instance.onError` phải: (a) gọi `SessionLog.add('app.error', detail: <chỉ tên kiểu lỗi, đã lọc bởi scrubText>)`; (b) ở release **không** in ra màn hình, không `print`; ở debug gọi `FlutterError.presentError`; (c) trả `true` để lỗi không làm sập tiến trình. Tuyệt đối không ghi token/cookie/PUUID/Riot ID (đã có `SessionLog.scrubText`).
3. **Bản "công khai" của thông báo trên màn hình khóa.** Nội dung thông báo hiện còn nêu Riot ID trong ngoặc ở cuối (ví dụ `WishlistStrings.notifDailyBody`). Cần cấu hình `publicVersion` (Android) / chế độ xem trước "khi mở khóa" (iOS) để màn hình khóa chỉ hiện tiêu đề chung ("Cửa hàng đã làm mới") và **không** hiện Riot ID.

---

## Phụ lục A. Kiểm kê và kết quả WP-COPY

- [Kiểm kê toàn bộ literal nguồn](../audit/COPY_INVENTORY.md): 20 file chuỗi ban đầu, lớp lời lỗi Cộng đồng mới, toàn bộ cây pháp lý, chuỗi ngoài file chuỗi, iOS và W0. Có dòng nguồn để bước ARB rà lại.
- [Phát hiện và quyết định sửa](../audit/AUDIT_COPY.md): phân loại sáu nhóm, liên kết audit GL/PR/CS, phần xong và các điểm nối.
- [Thông điệp máy chủ cần xử lý](../audit/COPY_SERVER_MESSAGES.md): chỉ liệt kê `server/**`, không sửa máy chủ trong WP-COPY. Client không còn hiển thị nguyên văn thông điệp đó.

## Phụ lục B. Ngoại lệ placeholder và thành phần giữ nguyên

Mọi member/chữ ký hiện có của 20 lớp chuỗi được giữ. Hai ngoại lệ cần thiết để không lộ kỹ thuật: `CommonStrings.errorApi(int status)` giữ tham số nhưng không in mã HTTP (đã làm ở WIP trước); `CommonStrings.priceSource(String url)` giữ tham số nhưng chỉ hiện “Xem nguồn bảng giá”. Nút mở trang nguồn vẫn mở liên kết thật. Chữ trong tệp báo lỗi có thể chứa tên yêu cầu/mã kết quả đã lọc; không được xuất hiện trong màn hình ứng dụng.

Tên vật phẩm/bản đồ/đặc vụ lấy từ nội dung game; Riot ID và mã tổ đội là thông tin người chơi chủ động sử dụng, được giữ. Tên kênh và ID kênh thông báo không đổi. Tên tệp chia sẻ không chứa tài khoản: `valvn-store-<ngày>.png`, `valvn-night-market-<ngày>.png`, `valvn-bug-report-<ngày>.txt`.

## Phụ lục C. Lỗi Cộng đồng

`CommunityException` giữ `serverMessage` để tương thích nhưng UI không đọc nó. Các reason `content_inappropriate`, `content_scam`, `content_too_complex`, `account_banned`, `account_restricted` dùng lời của app trong `lib/core/l10n/community_error_strings.dart`. Reason mới/lạ, trường nhập sai, HTML và máy chủ cũ dùng mẫu dự phòng; không chèn tên trường/JSON/`params`. `server_busy` giữ thời gian chờ và nút thử lại. Namespace mới `communityError` đã đăng ký trong công cụ W0; các namespace cũ không đổi thứ tự.

## Phụ lục D. Thuật ngữ và phạm vi kiểm chứng

Thuật ngữ đã đối chiếu bảng §8 của `valbuddy-features.md`, không tự dịch lại tên chế độ/vật phẩm từ game. Các tên mới chưa xác minh nêu ở §3 giữ nguyên. WP-COPY không dùng thiết bị/emulator/adb; Claude kiểm tra trực quan chữ dài, bảng chia sẻ và bố cục trước phát hành. Bản W0 vẫn chỉ có tiếng Việt; hỗ trợ 18 ngôn ngữ là chương trình tiếp theo, không quảng cáo như đã dịch xong.

Các cam kết pháp lý, số ngày lưu trữ, địa chỉ liên hệ, quyền, nghĩa vụ và tuyên bố miễn trừ được giữ khi viết lại. Phần bổ sung Google ML Kit thực hiện quyết định D1 trong `GLOBAL_AUDIT.md`: nói rõ tải gói từ Google sau khi đồng ý, dịch trên máy và không gửi bài viết đi dịch. Không khẳng định SDK không có lưu lượng kỹ thuật chưa kiểm chứng.
