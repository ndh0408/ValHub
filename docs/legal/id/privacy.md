<!-- Berkas dibuat otomatis dari assets/legal/id/. Jangan diedit manual: edit konten JSON, lalu jalankan `dart run tool/export_legal_docs.dart`. -->

# Kebijakan Privasi

**ValHub** · Versi 1.2 · Berlaku sejak: 04/10/2026

Kebijakan ini menjelaskan cara ValHub mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda, serta hak-hak Anda atas data tersebut. Kebijakan ini disusun berdasarkan hukum Vietnam tentang pelindungan data pribadi (Dekret No. 13/2023/NĐ-CP (Nghị định 13/2023/NĐ-CP)), dan sekaligus memperhitungkan ketentuan yang mungkin dapat Anda manfaatkan di tempat tinggal Anda, seperti GDPR, UK GDPR, CCPA/CPRA, atau LGPD (lihat bagian "Hak Anda berdasarkan hukum di tempat tinggal Anda"). ValHub ditujukan bagi pemain VALORANT di semua negara.

> Ringkasan: Sebagian besar data Anda hanya berada di perangkat. Data login Riot Anda disimpan di penyimpanan aman sistem operasi dan hanya digunakan di server ValHub setelah Anda memberikan persetujuan secara eksplisit: untuk memverifikasi Riot ID saat Anda terhubung ke Komunitas dan untuk memeriksa kepemilikan skin saat Anda menyimpan ulasan. Token akses dibuang setelah setiap verifikasi. Server tidak menyimpan PUUID (pengenal pemain Anda). ValHub tidak memiliki iklan, tidak menggunakan alat analitik atau pelacakan, dan tidak menjual data Anda.

## 1. Pengendali dan Prosesor Data

Nguyễn Đức Huy ("kami") adalah pihak yang menentukan tujuan dan cara pemrosesan data pribadi di ValHub (pengendali sekaligus prosesor data pribadi). Informasi kontak tersedia di bagian terakhir Kebijakan ini.

## 2. Ruang lingkup

Kebijakan ini berlaku untuk aplikasi ValHub di iOS dan Android di semua negara, termasuk fitur Komunitas. Kebijakan ini tidak berlaku untuk layanan Riot Games, valorant-api.com, Apple, Google, atau pihak ketiga lainnya. Masing-masing pihak memproses data berdasarkan kebijakannya sendiri.

## 3. Data yang diproses di perangkat Anda

Data di bawah ini dibuat atau diunduh saat Anda menggunakan aplikasi, dan hanya disimpan di perangkat Anda. Kami tidak menerima data ini.

- **Data login Riot:** data yang diberikan Riot kepada aplikasi setelah Anda login di halaman resmi Riot, meliputi token akses (access token), token hak kepemilikan (entitlement token), dan cookie login (berkas yang membantu Riot mengingat bahwa Anda sudah login). Data ini disimpan di Keychain (iOS) atau di penyimpanan terenkripsi yang dilindungi Keystore (Android). ValHub tidak pernah melihat kata sandi yang Anda masukkan di halaman Riot.
- **Info login tersimpan (opsional):** jika Anda sendiri memilih untuk menyimpan nama pengguna dan kata sandi Riot agar dapat login kembali lebih cepat, informasi ini hanya berada di penyimpanan aman di perangkat. Informasi ini tidak pernah dicatat dalam laporan bug atau dikirim ke mana pun, kecuali untuk diisikan ke halaman login resmi Riot saat Anda memintanya.
- **Daftar akun:** Riot ID (nama#tag), pengenal pemain (PUUID), region, platform, Kartu Pemain, level, dan rank dari akun-akun yang Anda tambahkan. Aplikasi menggunakannya untuk menampilkan daftar akun dan untuk beralih antarakun.
- **Data game:** toko, dompet, koleksi, loadout, Battle Pass, kontrak, riwayat pertandingan, rank, pertandingan saat ini, daftar teman, status online, dan pesan obrolan. Aplikasi membacanya langsung dari server Riot menggunakan login Riot Anda dan dapat menyimpan salinan sementara agar Anda dapat melihatnya saat tidak ada koneksi internet.
- **Wishlist dan pengaturan:** wishlist, preferensi tampilan, pengaturan notifikasi, dan platform.
- **Data sementara:** nama dan gambar item, agen, dan map yang diambil dari valorant-api.com, beserta gambar yang telah diunduh, disimpan sementara agar aplikasi berjalan lebih cepat.
- **Laporan bug:** catatan teknis di perangkat tentang apa yang telah dilakukan aplikasi (nama permintaan yang dikirim, hasil, dan waktunya), yang digunakan untuk menemukan bug. Catatan ini disaring agar tidak memuat kata sandi, data login Riot, atau ID akun, dan hanya keluar dari perangkat jika Anda sendiri memilih "Kirim laporan bug ke ValHub" di Pengaturan > Lanjutan.

## 4. Data yang diproses di server Komunitas

Server Komunitas adalah server yang dioperasikan sendiri oleh penerbit. Data disimpan di basis data dan di berkas pada disk server tersebut. Koneksi dari Aplikasi ke server ini melewati jaringan Cloudflare; Cloudflare hanya meneruskan koneksi. Hanya jika Anda menggunakan fitur Komunitas, data di bawah ini dikirim ke dan disimpan di server ini:

- **Profil Komunitas:** Riot ID (nama dan tag), region, Kartu Pemain, rank, dan bahasa aplikasi, yang dikirim oleh Aplikasi. Informasi ini bersifat publik bagi pengguna lain di Komunitas.
- **Negara:** negara Akun Riot Anda (diberikan oleh Riot saat verifikasi dan tidak dapat Anda ubah), digunakan untuk menampilkan Komunitas berdasarkan negara.
- **ID pengguna:** hash satu arah (yang tidak dapat ditelusuri balik menjadi PUUID) yang dibuat dari PUUID Anda. Server tidak menyimpan dan tidak mengembalikan PUUID Anda.
- **Postingan dan komentar:** isi postingan, gambar yang Anda unggah, informasi toko atau Night Market yang Anda pilih untuk dibagikan, komentar, suka, dan waktu posting.
- **Ulasan skin:** jumlah bintang, isi ulasan, dan tanda "Membantu" yang Anda berikan pada ulasan orang lain. Informasi ini ditampilkan secara publik bersama Riot ID Anda. Server menyimpan waktu pemeriksaan kepemilikan skin; ulasan lama yang belum diverifikasi akan diberi keterangan yang jelas dan tidak dihitung dalam skor peringkat.
- **Postingan cari rekan tim:** kode party, mode permainan, region, batas rank, peran yang dicari, apakah mikrofon diwajibkan atau tidak, bahasa, ukuran party, jumlah slot kosong, catatan, status (terbuka, penuh, sedang bermain), jumlah ketukan pada party, serta sinyal "masih aktif" yang dikirim Aplikasi secara berkala selama postingan masih terbuka. Postingan otomatis kedaluwarsa 30 menit setelah sinyal terakhir. Setiap orang hanya dapat memiliki satu postingan aktif.
- **Suara dan suka:** skin yang Anda beri suara, suka, dan waktu Anda melakukannya, digunakan untuk menyusun peringkat skin yang paling disukai.
- **Laporan pelanggaran:** konten yang dilaporkan, alasan, dan pelapor (dalam bentuk ID pengguna), digunakan untuk moderasi.
- **Log akses server:** server mencatat jenis permintaan, jalur (path), hasil, dan waktu pemrosesan setiap permintaan untuk keperluan operasional dan menemukan bug. Alamat IP hanya digunakan dalam bentuk hash bergaram (hash satu arah yang ditambahi sebuah string acak) untuk membatasi jumlah permintaan yang dapat dikirim, dan tidak dicatat dalam bentuk yang dapat dibaca. Cloudflare dapat memproses alamat IP saat meneruskan koneksi, berdasarkan kebijakannya sendiri.
- **Gambar yang diunggah:** gambar yang Anda posting disimpan sebagai berkas di disk server Komunitas dan dapat dibuka melalui tautan publik. Cara menghapus gambar dijelaskan di bagian "Penghapusan data".
- **Cadangan:** server dicadangkan setiap hari; cadangan disimpan selama 14 hari di server milik penerbit.

## 5. Token akses Riot dan verifikasi Riot ID

Data login Riot Anda (token akses, token hak kepemilikan, dan cookie) hanya digunakan di server ValHub dalam kasus verifikasi yang dijelaskan di bawah ini. Cookie login dan kata sandi tidak dikirim ke server Komunitas:

- Setelah login ke Riot, Anda harus membaca dan memilih untuk menyetujui sebelum dapat terus menggunakan fitur akun. Keputusan Anda disimpan secara terpisah untuk setiap akun dan setiap versi kebijakan. Jika tidak setuju, Anda dapat logout dari akun tersebut. Memilih setuju tidak dengan sendirinya mengirimkan token Riot; aplikasi hanya mengirim token akses melalui HTTPS saat menghubungkan kembali ke Komunitas atau saat Anda secara aktif menyimpan ulasan skin.
- Server menanyakan identitas Anda (PUUID dan Riot ID) kepada Riot. Saat Anda menyimpan ulasan, server juga membaca kepemilikan skin dari Riot dan memeriksa bahwa akun tersebut cocok dengan orang yang sedang login ke Komunitas. Token akses dan token hak kepemilikan yang bersifat sementara tidak disimpan atau dicatat dalam log; server membuangnya setelah memproses permintaan.
- Server memberikan kepada Aplikasi sebuah token login Komunitas tersendiri yang berlaku selama 30 hari. Token ini disimpan di penyimpanan aman di perangkat dan dihapus saat Anda logout dari akun.
- Server Komunitas hanya membaca informasi identitas dan kepemilikan skin untuk verifikasi ini; server tidak membeli item, tidak mengganti loadout, dan tidak mengubah Akun Riot Anda.

## 6. Tujuan pemrosesan

- Menampilkan informasi akun, toko, koleksi, pertandingan, dan fitur yang Anda minta.
- Mengirim notifikasi langsung di perangkat tentang toko, wishlist, dan Night Market jika Anda mengaktifkannya.
- Mengoperasikan Komunitas: memverifikasi bahwa pengirim postingan adalah pemilik Riot ID, serta menampilkan postingan, komentar, postingan cari rekan tim, dan peringkat skin.
- Menjamin keamanan: mencegah spam, penyalahgunaan, dan kecurangan; memoderasi konten yang dilaporkan; membatasi jumlah permintaan yang dapat dikirim dalam jangka waktu tertentu.
- Menemukan dan memperbaiki bug saat Anda secara aktif mengirim laporan bug ke ValHub.
- Memenuhi kewajiban sesuai ketentuan peraturan perundang-undangan.

Kami tidak menggunakan data Anda untuk iklan, tidak membuat profil perilaku, dan tidak menjual, menyewakan, atau menukarkan data pribadi.

## 7. Dasar hukum

- **Persetujuan Anda:** Anda memilih untuk memberikan persetujuan secara eksplisit atas Kebijakan ini setelah login, dan memberikan persetujuan terpisah saat mengaktifkan notifikasi atau menyimpan info login. Anda dapat menarik kembali persetujuan kapan saja di Pengaturan; setelah itu, Anda harus menyetujui kembali atau logout untuk dapat terus menggunakan fitur akun.
- **Pemenuhan perjanjian:** pemrosesan yang diperlukan untuk menyediakan fitur yang Anda minta berdasarkan Ketentuan Penggunaan.
- **Kepentingan yang sah:** melindungi Komunitas dari spam, penyalahgunaan, dan kecurangan, memoderasi konten yang dilaporkan, dan menjaga keamanan server, dengan data seminimal mungkin yang diperlukan.
- **Kewajiban hukum:** jika diwajibkan oleh hukum, misalnya untuk menanggapi permintaan yang sah dari instansi pemerintah yang berwenang.

## 8. Berbagi data

Kami hanya membagikan data dalam kasus-kasus berikut:

- **Riot Games:** Aplikasi terhubung langsung ke server Riot Games menggunakan login Riot Anda untuk membaca data akun dan melakukan tindakan yang Anda minta.
- **valorant-api.com:** Aplikasi mengunduh data publik tentang item; Aplikasi tidak mengirimkan informasi akun Anda.
- **Berkas publik:** Aplikasi dapat mengunduh status server publik Riot dan berkas konfigurasi umum ValHub; permintaan ini tidak menyertakan data pribadi.
- **Cloudflare, Inc.:** menyediakan jaringan yang meneruskan koneksi ke server Komunitas. Cloudflare tidak menyimpan data Komunitas kami, tetapi dapat memproses data teknis seperti alamat IP berdasarkan kebijakannya sendiri.
- **Pengguna lain:** profil Komunitas, postingan, gambar, komentar, dan postingan cari rekan tim Anda terlihat oleh pengguna ValHub lainnya. Gambar yang telah diposting dapat dibuka melalui tautan publik.
- **Instansi pemerintah yang berwenang:** jika ada permintaan yang sah sesuai ketentuan hukum yang berlaku bagi penerbit.

## 9. Transfer data lintas negara

Server Komunitas dioperasikan sendiri oleh penerbit. Koneksi ke server ini melewati jaringan global Cloudflare, Inc., sehingga data dapat melewati beberapa negara. Data Komunitas yang Anda posting terlihat oleh pengguna ValHub di mana pun. Saat Anda menggunakan Aplikasi, perangkat Anda juga terhubung langsung ke server Riot Games. Kami menerapkan langkah pelindungan yang sesuai dan melaksanakan kewajiban terkait transfer data pribadi lintas negara berdasarkan hukum Vietnam dan, jika Anda tinggal di tempat yang memiliki ketentuan serupa, berdasarkan hukum di tempat tinggal Anda.

## 10. Masa penyimpanan

- **Data di perangkat:** disimpan hingga Anda logout dari akun terkait, menghapus data sementara, atau mencopot pemasangan Aplikasi. Gambar yang disimpan sementara diperbarui secara otomatis setelah sekitar 30 hari.
- **Postingan cari rekan tim:** otomatis kedaluwarsa dan berhenti ditampilkan 30 menit setelah sinyal "masih aktif" terakhir; data yang telah kedaluwarsa dihapus secara berkala.
- **Postingan, ulasan, komentar, suara:** disimpan hingga Anda menghapusnya, hingga kami menghapusnya karena pelanggaran, atau hingga Anda meminta penghapusan data Komunitas.
- **Laporan pelanggaran:** hanya disimpan paling lama 12 bulan untuk menangani pelanggaran dan mencegah penyalahgunaan, lalu server menghapusnya secara otomatis. Laporan tentang konten yang telah dihapus juga dihapus, dan laporan yang Anda kirim sendiri dianonimkan saat Anda menghapus data Komunitas.
- **Log akses server:** hanya hash bergaram (dari alamat IP) yang disimpan untuk membatasi jumlah permintaan yang dapat dikirim; log teknis hanya disimpan selama diperlukan untuk menemukan bug dan menjaga keamanan.
- **Cadangan:** disimpan selama 14 hari lalu ditimpa; karena itu, konten yang telah dihapus mungkin masih ada di cadangan paling lama 14 hari.
- **Token login Komunitas:** kedaluwarsa setelah 30 hari, dihapus dari perangkat saat logout, dan dicabut di server saat tersedia koneksi jaringan.

## 11. Penghapusan data

### Di perangkat

- Logout dari sebuah akun di Pengaturan akan menghapus dari perangkat data login Riot (token akses dan cookie), info login tersimpan, token login Komunitas, data sementara, dan notifikasi terjadwal milik akun tersebut. Wishlist, konfigurasi loadout, serta riwayat RR, pertandingan, dan toko juga dihapus, kecuali Anda memilih untuk menyimpan data lokal di kotak konfirmasi agar dapat digunakan saat login kembali.
- "Hapus data sementara" di Pengaturan > Lanjutan menghapus gambar, data yang diunduh untuk dilihat saat tidak ada koneksi internet, nama pemain yang pernah dicari, dan laporan bug yang tercatat di perangkat. Riwayat pribadi Anda tetap disimpan.
- "Hapus data lokal" menghapus riwayat, konfigurasi loadout, dan data yang disimpan dari akun yang telah logout. Wishlist akun yang sedang login tetap ada; Anda dapat menghapusnya sendiri di Wishlist.
- Mencopot pemasangan Aplikasi akan menghapus seluruh data Aplikasi di perangkat.

### Di server Komunitas

- Anda dapat menghapus sendiri postingan, ulasan, komentar, dan postingan cari rekan tim, serta membatalkan suara, langsung di Aplikasi.
- Untuk menghapus seluruh data Komunitas yang terkait dengan Riot ID Anda, buka Pengaturan > "Data Komunitas kamu" > "Hapus data Komunitas saya". Server akan menghapus secara permanen postingan, komentar, ulasan, suka, suara, postingan cari rekan tim, gambar, dan akun Komunitas Anda. Tindakan ini tidak dapat dibatalkan. Anda juga dapat mengirim email ke ndh0408@gmail.com dengan menyertakan Riot ID Anda; kami dapat meminta verifikasi bahwa Anda adalah pemilik akun dan akan memproses permintaan dalam waktu 30 hari.
- Gambar: berkas gambar dihapus bersama postingan atau akun. Gambar dari konten yang disembunyikan karena dilaporkan tidak lagi dapat diakses secara publik dan dihapus setelah 30 hari; gambar yang telah diunggah tetapi tidak digunakan dihapus setelah 24 jam. Saat Anda mengunggah gambar, server menghapus informasi lokasi dan data tersembunyi lainnya di dalam gambar (metadata EXIF).
- Konten yang telah dihapus mungkin masih ada di cadangan paling lama 14 hari sebelum ditimpa.
- Catatan: logout dari Aplikasi tidak secara otomatis menghapus konten yang telah Anda posting di server Komunitas.

## 12. Notifikasi dan tugas latar belakang

ValHub hanya menggunakan notifikasi lokal, yaitu notifikasi yang dibuat oleh perangkat Anda sendiri. Kami tidak mengoperasikan server notifikasi push dan tidak mengumpulkan token perangkat. Aplikasi mendaftarkan sebuah tugas latar belakang berkala ke sistem operasi, yang berjalan langsung di perangkat, untuk menjaga agar login Riot Anda tetap berlaku dan, jika Anda mengaktifkannya, untuk membaca toko langsung dari Riot guna memberi tahu Anda tentang skin di wishlist atau di Night Market. Anda dapat menonaktifkan notifikasi di Pengaturan Aplikasi atau di pengaturan sistem operasi.

## 13. Penerjemahan konten di perangkat

Saat Anda memilih untuk menerjemahkan konten Komunitas, ValHub menggunakan alat terjemahan ML Kit dari Google yang berjalan di perangkat. Jika paket bahasa yang diperlukan belum tersedia, ValHub akan bertanya kepada Anda sebelum mengunduh paket tersebut dari Google (sekitar 30 MB per paket). Pengunduhan memerlukan koneksi jaringan, dan Google dapat menerima informasi teknis tentang koneksi tersebut, seperti alamat IP, berdasarkan kebijakan Google. Isi postingan diterjemahkan di perangkat dan tidak dikirim ke Google untuk diterjemahkan. Anda boleh tidak menggunakan fitur ini; ValHub tidak menggunakan chatbot atau layanan pembuatan konten berbasis AI.

## 14. Analitik, iklan, dan pelacakan

ValHub tidak mengintegrasikan alat analitik, alat pelaporan crash otomatis, iklan, atau alat pelacakan pihak ketiga. ValHub tidak menggunakan pengenal iklan dan tidak melacak Anda di berbagai aplikasi atau situs web. Jika hal ini berubah di masa mendatang, kami akan memperbarui Kebijakan ini dan meminta persetujuan Anda jika diwajibkan oleh hukum.

## 15. Keamanan data

- Informasi rahasia (data login Riot, info login tersimpan, token login Komunitas) hanya disimpan di penyimpanan aman sistem operasi (Keychain atau Keystore) dan dihapus saat Aplikasi dipasang ulang.
- Semua koneksi jaringan dienkripsi (HTTPS/TLS).
- Laporan bug disaring secara otomatis untuk menghilangkan data login Riot, kata sandi, dan ID akun.
- Server Komunitas hanya menyimpan hash satu arah dari PUUID; membatasi jumlah permintaan yang dapat dikirim (berdasarkan hash bergaram dari alamat IP); hanya mengizinkan Anda menghapus konten milik Anda sendiri; dan menyimpan kunci rahasia di konfigurasi privat server, bukan di kode sumber.
- Kami hanya mengumpulkan data seminimal mungkin yang diperlukan untuk fitur.

Tidak ada langkah pengamanan yang aman secara mutlak. Jika terjadi insiden pelanggaran data pribadi (kegagalan pelindungan data pribadi), kami akan memberi tahu otoritas yang berwenang dan pengguna yang terdampak sesuai ketentuan hukum.

## 16. Anak-anak

Aplikasi tidak ditujukan untuk anak-anak di bawah usia 13 tahun. Di tempat yang hukumnya menetapkan usia minimum yang lebih tinggi untuk dapat memberikan sendiri persetujuan atas pemrosesan data (misalnya 16 tahun di beberapa negara Uni Eropa), Anda hanya boleh menggunakan Aplikasi, khususnya fitur Komunitas, jika telah mencapai usia tersebut atau dengan persetujuan dan pengawasan orang tua atau wali yang sah. Jika Anda adalah orang tua dan menganggap anak Anda telah memberikan data kepada Komunitas tanpa persetujuan, silakan hubungi kami agar kami dapat menghapus data tersebut.

## 17. Hak Anda

Berdasarkan hukum Vietnam tentang pelindungan data pribadi (termasuk Dekret No. 13/2023/NĐ-CP), Anda memiliki hak-hak berikut:

- **Hak untuk mengetahui:** mengetahui kegiatan pemrosesan data Anda;
- **Hak memberikan persetujuan:** menyetujui atau tidak menyetujui pemrosesan data;
- **Hak akses:** melihat, memperbaiki, atau meminta perbaikan data Anda;
- **Hak menarik kembali persetujuan:** menarik kembali persetujuan yang telah diberikan;
- **Hak penghapusan data:** meminta penghapusan data Anda;
- **Hak membatasi pemrosesan:** meminta pembatasan pemrosesan data;
- **Hak memperoleh data:** meminta agar data Anda diberikan kepada Anda;
- **Hak mengajukan keberatan atas pemrosesan:** mengajukan keberatan atas pemrosesan data untuk tujuan yang tidak dikehendaki;
- **Hak mengajukan keluhan dan menuntut ganti rugi:** mengajukan keluhan dan pengaduan, mengajukan gugatan, serta menuntut ganti rugi sesuai ketentuan hukum;
- **Hak melindungi diri sendiri:** melindungi sendiri data pribadi Anda.

Sebagian besar data berada di perangkat, dan Anda dapat melihat atau menghapusnya sendiri langsung di Aplikasi. Untuk data di server Komunitas, kirimkan permintaan Anda ke ndh0408@gmail.com. Kami memproses permintaan dalam waktu 30 hari dan mungkin perlu memverifikasi identitas Anda sebelum memprosesnya. Anda juga dapat mengunduh sendiri salinan data Komunitas Anda (berkas JSON) di Pengaturan > "Data Komunitas kamu" > "Unduh data saya", dan menghapus sendiri data tersebut di tempat yang sama.

## 18. Hak Anda berdasarkan hukum di tempat tinggal Anda

Tergantung pada tempat tinggal Anda, hukum setempat mungkin memberikan hak tambahan kepada Anda. Di mana pun Anda berada, Anda dapat menggunakan hak-hak praktis di bawah ini dengan mengirim email ke ndh0408@gmail.com; kami memproses permintaan dalam waktu 30 hari dan tidak akan memperlakukan Anda secara diskriminatif karena telah menggunakan hak Anda.

- **Akses:** mengetahui data apa yang kami simpan tentang Anda dan menerima salinannya;
- **Penghapusan:** meminta penghapusan data Komunitas yang terkait dengan Riot ID Anda (lihat bagian "Penghapusan data");
- **Perbaikan:** memperbaiki data yang tidak akurat (profil Komunitas diperbarui dari akun Riot setiap kali Anda terhubung);
- **Portabilitas data:** menerima data Anda dalam format yang umum digunakan;
- **Keberatan, pembatasan, dan penarikan persetujuan:** mengajukan keberatan atau meminta pembatasan pemrosesan, serta menarik kembali persetujuan kapan saja;
- **Pengaduan:** mengajukan pengaduan kepada otoritas pelindungan data yang berwenang di tempat tinggal Anda.

Beberapa contoh hukum yang mungkin berlaku bagi Anda:

- **GDPR / UK GDPR:** jika Anda berada di Uni Eropa, Kawasan Ekonomi Eropa, atau Britania Raya: Anda memiliki hak akses, perbaikan, penghapusan, pembatasan, portabilitas data, keberatan, dan penarikan persetujuan, serta hak mengajukan pengaduan kepada otoritas pengawas data di negara tempat Anda tinggal. Dasar pemrosesan data dijelaskan di bagian "Dasar hukum".
- **CCPA / CPRA:** jika Anda adalah penduduk California: Anda berhak untuk mengetahui, menghapus, dan memperbaiki data, serta menolak "penjualan" atau "pembagian" data. ValHub tidak menjual data pribadi dan tidak membagikannya untuk iklan lintas konteks.
- **LGPD:** jika Anda berada di Brasil: Anda memiliki hak akses, perbaikan, anonimisasi, penghapusan, portabilitas data, dan hak memperoleh informasi tentang pembagian data.
- **PIPL dan hukum serupa:** jika Anda berada di Tiongkok daratan atau di tempat yang memiliki hukum serupa: Anda berhak untuk mengetahui, memutuskan, membatasi, menolak, mengakses, menyalin, memperbaiki, dan menghapus data, serta meminta penjelasan tentang pemrosesan.
- **Dekret No. 13/2023/NĐ-CP:** jika Anda berada di Vietnam: hak-hak yang dijelaskan di bagian "Hak Anda" di atas.

Kami tidak mengumpulkan data lebih dari yang diperlukan dan tidak membuat keputusan otomatis yang menimbulkan akibat hukum bagi Anda. Jika Anda tidak puas dengan tanggapan kami, Anda berhak mengajukan pengaduan kepada otoritas yang berwenang di tempat tinggal Anda.

## 19. Perubahan Kebijakan

Kami dapat memperbarui Kebijakan ini apabila Aplikasi atau ketentuan hukum berubah. Versi dan tanggal berlaku selalu dicantumkan di bagian atas dokumen. Untuk perubahan penting terkait cara pemrosesan data, kami akan memberi tahu Anda di Aplikasi dan meminta kembali persetujuan Anda jika diperlukan.

## 20. Kontak

Untuk setiap pertanyaan atau permintaan terkait privasi dan data pribadi, silakan hubungi:

- **Pengendali data:** Nguyễn Đức Huy
- **Email:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Hak cipta dilindungi undang-undang.
