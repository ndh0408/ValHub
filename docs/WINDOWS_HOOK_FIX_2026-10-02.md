# Hook Windows tái diễn — 02/10/2026

## Nguyên nhân đã tái hiện

Phiên mới gọi `C:/Windows/System32/bash.exe` của WSL. Chạy chính executable này trả `execvpe(/bin/bash) failed: No such file or directory`, exit 1. Thư mục arg0 của phiên 01/10 đã bị dọn; thư mục arg0 mới không có shim. Vì vậy bản sửa riêng phiên trước không tồn tại sau khi khởi động lại. Đây là lỗi môi trường hook, không phải bằng chứng Flutter tests thất bại.

Ngoài shell lookup, hai plugin Claude có thể xuất `metrics` và `rewakeSummary` mà schema hook Codex 0.159.0 không nhận. Schema chính thức có `additionalProperties: false`: [PostToolUse output](https://github.com/openai/codex/blob/rust-v0.159.0/codex-rs/hooks/schema/generated/post-tool-use.command.output.schema.json). Không dùng kết quả shell exit 0 để suy ra JSON đã hợp lệ.

## Sửa đã áp dụng trên máy này

`tool/qa/install_windows_hook_compat.ps1` cài bridge tại thư mục người dùng `.codex/windows-hook-compat`, ngoài `CODEX_HOME/tmp`. `bash.cmd`/`sh.cmd` gọi Git Bash đã cài và `windows_hook_compat.py`; Python launcher extensionless giúp shell tránh Microsoft Store stub. Allowlist chứa chính đường dẫn script của hai plugin đang cài, không nhận mọi script cùng tên.

Hai shortcut Orca của người dùng trên Desktop và Start Menu đã được sao lưu và trỏ qua `Launch-Orca.pyw`. Launcher chỉ thêm thư mục bridge vào PATH của tiến trình Orca được mở từ shortcut; không đổi PATH máy/người dùng, không sửa binary Orca. Không dừng Orca đang làm việc. Phiên hiện tại đã nhận shim ở đúng thư mục arg0 đang có trong PATH.

Bridge chạy script hook gốc, giữ stdout chuẩn, stderr, exit code, `continue`, `stopReason`, `decision`, `reason`, `additionalContext` và các warning. Chỉ bỏ trường telemetry `metrics` không được Codex nhận và chuyển `rewakeSummary` thành `systemMessage`, nối sau thông báo có sẵn. Output không biết/malformed giữ nguyên để lỗi còn được phát hiện. Không sửa source plugin, command hook, trust hash, hay tắt hook bảo mật. Audit chỉ ghi thời điểm/event/exit/đã chuyển hay chưa; không ghi input, finding, token hoặc dữ liệu tài khoản.

## Kiểm tra

- **14 Python tests đạt**: warning/block/deny/continue false, Unicode, output chuẩn byte-identical, malformed/unknown giữ nguyên, và thực thi fixture Git Bash thật giữ stderr + exit 2. Lệnh shell thường giữ stdout, stderr và exit 7.
- Chạy script security pattern thật trên file tổng hợp `innerHTML` nhận cảnh báo `additionalContext`, exit 0; không gọi LLM review hay gửi source dự án đến dịch vụ ngoài.
- Chạy metrics hook thật đạt exit 0, JSON chuyển thành object hợp lệ. Kiểm tra đường khởi chạy `cmd /c` theo cách đóng quote của Codex cũng giữ cảnh báo.
- Loại toàn bộ đường dẫn arg0 khỏi môi trường thử nghiệm, chạy launcher `--check` vẫn nhận GNU Git Bash, exit 0. Điều này chứng minh launcher không phụ thuộc shim tạm.
- Log kết quả cục bộ: `dist/review/hook-compat-20261002/results.json`. Bộ test: `python -X utf8 -m unittest discover -s tool/qa -p test_windows_hook_compat.py -v`.

## Giới hạn và khôi phục

**Chưa đóng/mở lại toàn bộ Orca để nghiệm thu phiên mới thật**, vì đang giữ công việc hiện tại. Lần mở sau phải đi qua shortcut đã cập nhật; mở trực tiếp executable hoặc shortcut khác không có private PATH này. Installer đã sửa hai shortcut tìm thấy; không có bằng chứng cho cơ chế mở khác. Cập nhật Orca có thể thay shortcut; cập nhật plugin có thể thay đường dẫn version. Chạy lại installer để kiểm tra/cập nhật allowlist và shortcut sau các thay đổi đó.

Backup từng shortcut và manifest `shortcuts.json` nằm trong `.codex/windows-hook-compat`. Muốn khôi phục, chép từng backup về đúng `path` trong manifest, giữ nguyên các plugin. Không cần xóa dữ liệu ứng dụng hay uninstall Orca.
