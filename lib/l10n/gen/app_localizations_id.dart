// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Lihat sumber harga';

  @override
  String get commonErrorApi =>
      'Riot sedang mengalami gangguan. Coba lagi dalam beberapa menit.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonClearFilters => 'Hapus filter';

  @override
  String get commonClearSearch => 'Hapus pencarian';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonCopied => 'Disalin';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n hari';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n hari lalu';
  }

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonEmptyGeneric => 'Belum ada apa-apa di sini.';

  @override
  String get commonErrorContentUnavailable =>
      'Gagal memuat skin, agen, dan map. Periksa koneksimu lalu coba lagi.';

  @override
  String get commonErrorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get commonErrorMaintenance =>
      'Server VALORANT sedang dalam pemeliharaan. Coba lagi nanti.';

  @override
  String get commonErrorNeedsLogin =>
      'Login Riot kamu sudah kedaluwarsa. Login lagi untuk melanjutkan.';

  @override
  String get commonErrorNeedsLoginTitle => 'Login lagi';

  @override
  String get commonErrorNetwork =>
      'Tidak ada koneksi. Periksa Wi-Fi atau data selulermu lalu coba lagi.';

  @override
  String get commonErrorNoAccount => 'Kamu belum login ke akun mana pun.';

  @override
  String get commonErrorNotFound => 'Konten ini tidak ditemukan.';

  @override
  String get commonErrorTimeout =>
      'Riot terlalu lama merespons. Periksa koneksimu lalu coba lagi.';

  @override
  String get commonErrorTransient =>
      'Riot sedang sibuk. Coba lagi dalam beberapa menit.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot sedang sibuk. Coba lagi dalam $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Region Riot kamu belum terdeteksi. Pilih region di Pengaturan.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Ke Beranda';

  @override
  String commonHours(int n) {
    return '$n jam';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n jam lalu';
  }

  @override
  String get commonIncidentTitle => 'Gangguan server';

  @override
  String get commonJustNow => 'baru saja';

  @override
  String get commonLoadMore => 'Muat lagi';

  @override
  String get commonLoading => 'Memuat…';

  @override
  String get commonMaintenanceTitle => 'Pemeliharaan server';

  @override
  String commonMinutes(int n) {
    return '$n menit';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n menit lalu';
  }

  @override
  String get commonNoData => 'Belum ada yang bisa ditampilkan';

  @override
  String commonOfflineCached(String time) {
    return 'Kamu sedang offline — menampilkan data tersimpan ($time).';
  }

  @override
  String get commonOpenSettings => 'Buka pengaturan';

  @override
  String get commonPageNotFound => 'Layar ini tidak ditemukan.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Paket paling hemat: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Ubah harga yang kamu masukkan';

  @override
  String get commonPriceEnterOwn => 'Masukkan harga paket VP-mu';

  @override
  String get commonPriceEstimateBody =>
      'Jumlah “≈ …” di samping harga VP adalah perkiraan, dihitung dari paket VP paling hemat. Kamu membayar dengan VP di dalam game; jumlah sebenarnya tergantung paket, metode pembayaran, pajak, dan promo saat kamu membeli.';

  @override
  String get commonPriceEstimateTitle => 'Perkiraan harga';

  @override
  String get commonPriceEstimateTooltip =>
      'Perkiraan harga — ketuk untuk melihat cara hitungnya';

  @override
  String get commonPriceHidden =>
      'Perkiraan harga disembunyikan. Aktifkan lagi di Pengaturan.';

  @override
  String get commonPriceHide => 'Sembunyikan perkiraan harga';

  @override
  String get commonPriceOpenSource => 'Buka halaman sumber';

  @override
  String get commonPriceOverrideBody =>
      'Masukkan jumlah yang benar-benar kamu bayar untuk satu paket VP (lihat di toko dalam game atau struk pembelianmu). ValHub memakai harga ini untuk memperkirakan harga semua item; harga hanya disimpan di perangkat ini.';

  @override
  String get commonPriceOverrideCurrency => 'Kode mata uang';

  @override
  String get commonPriceOverrideCurrencyHint => 'Contoh: IDR, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Contoh perkiraan: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Masukkan kode mata uang 3 huruf, misalnya IDR atau USD.';

  @override
  String get commonPriceOverrideInvalidNumber => 'Masukkan angka lebih dari 0.';

  @override
  String get commonPriceOverridePrice => 'Harga paket';

  @override
  String get commonPriceOverrideRemove => 'Hapus harga yang kamu masukkan';

  @override
  String get commonPriceOverrideRemoved =>
      'Harga yang kamu masukkan sudah dihapus.';

  @override
  String get commonPriceOverrideSave => 'Simpan harga';

  @override
  String get commonPriceOverrideSaved => 'Harga paket VP-mu sudah disimpan.';

  @override
  String get commonPriceOverrideTitle => 'Harga paket VP-mu';

  @override
  String get commonPriceOverrideVp => 'Jumlah VP dalam paket';

  @override
  String get commonPricePacksTitle => 'Paket VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Berdasarkan harga paket VP di region $country';
  }

  @override
  String get commonPriceSourceUser =>
      'Berdasarkan harga paket VP yang kamu masukkan';

  @override
  String get commonPriceUnavailable =>
      'Belum ada daftar harga terverifikasi untuk regionmu. Masukkan harga paket VP yang pernah kamu beli untuk melihat perkiraan harga.';

  @override
  String commonPriceUpdated(String date) {
    return 'Daftar harga diperbarui: $date';
  }

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonRiotDisclaimer =>
      'ValHub tidak didukung oleh Riot Games dan tidak mencerminkan pandangan atau pendapat Riot Games maupun siapa pun yang terlibat secara resmi dalam memproduksi atau mengelola properti Riot Games. Riot Games dan semua properti terkait adalah merek dagang atau merek dagang terdaftar milik Riot Games, Inc.';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonSearch => 'Cari…';

  @override
  String commonSeconds(int n) {
    return '$n detik';
  }

  @override
  String get commonShare => 'Bagikan';

  @override
  String get commonSignInAgain => 'Login lagi';

  @override
  String get commonSort => 'Urutkan';

  @override
  String commonSortBy(String option) {
    return 'Urutkan: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Koleksi';

  @override
  String get commonTabCommunity => 'Komunitas';

  @override
  String get commonTabHome => 'Beranda';

  @override
  String get commonTabProfile => 'Profil';

  @override
  String get commonTabSettings => 'Pengaturan';

  @override
  String get commonTabStore => 'Toko';

  @override
  String get commonTagline => 'Teman setia VALORANT-mu';

  @override
  String get commonToday => 'Hari ini';

  @override
  String get commonTodayLower => 'hari ini';

  @override
  String get commonTomorrow => 'besok';

  @override
  String get commonUnknownItem => 'Item tidak dikenal';

  @override
  String commonUpdatedAt(String time) {
    return 'Diperbarui pukul $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Senin';

  @override
  String get commonWeekdaysItem1 => 'Selasa';

  @override
  String get commonWeekdaysItem2 => 'Rabu';

  @override
  String get commonWeekdaysItem3 => 'Kamis';

  @override
  String get commonWeekdaysItem4 => 'Jumat';

  @override
  String get commonWeekdaysItem5 => 'Sabtu';

  @override
  String get commonWeekdaysItem6 => 'Minggu';

  @override
  String get commonYesterday => 'kemarin';

  @override
  String get commonYesterdayTitle => 'Kemarin';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Login Riot sudah kedaluwarsa — menampilkan data tersimpan ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Senjata Berat';

  @override
  String get contentCategoryMelee => 'Melee';

  @override
  String get contentCategoryRifle => 'Assault Rifle';

  @override
  String get contentCategoryShotgun => 'Shotgun';

  @override
  String get contentCategorySidearm => 'Sidearm';

  @override
  String get contentCategorySmg => 'SMG';

  @override
  String get contentCategorySniper => 'Senapan Penembak Runduk';

  @override
  String get contentCurrencyAgentTokens => 'Token Agen';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kingdom Credit';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianite';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Point';

  @override
  String get contentItemAgent => 'Agen';

  @override
  String get contentItemBuddy => 'Gun Buddy';

  @override
  String get contentItemCard => 'Kartu Pemain';

  @override
  String get contentItemChroma => 'Varian';

  @override
  String get contentItemContract => 'Kontrak';

  @override
  String get contentItemCurrency => 'Mata uang';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Spray';

  @override
  String get contentItemTitle => 'Gelar Pemain';

  @override
  String contentLevel(int n) {
    return 'Level $n';
  }

  @override
  String get contentLevelBase => 'Dasar';

  @override
  String get contentLevelItemLabelsVFX => 'Efek visual';

  @override
  String get contentLevelItemLabelsAnimation => 'Animasi';

  @override
  String get contentLevelItemLabelsFinisher => 'Finisher';

  @override
  String get contentLevelItemLabelsKillCounter => 'Penghitung Kill';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Efek Suara';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformasi';

  @override
  String get contentLevelItemLabelsKillBanner => 'Banner Kill';

  @override
  String get contentLevelItemLabelsKillEffect => 'Efek Kill';

  @override
  String get contentLevelItemLabelsInspectAndKill => 'Efek Inspect & Kill';

  @override
  String get contentLevelItemLabelsVoiceover => 'Pengisi Suara';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Acak Lagu';

  @override
  String get contentLevelItemLabelsRandomizer => 'Pengacak';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Ganti Sisi Penyerang/Bertahan';

  @override
  String get contentLevelItemLabelsTopFrag => 'Efek Top Frag';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Sensor Detak Jantung & Map';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animasi Ikan';

  @override
  String get contentNoTitle => 'Tanpa gelar';

  @override
  String get contentNotForSale => 'Tidak dijual';

  @override
  String get contentQueueNamesCompetitive => 'Competitive';

  @override
  String get contentQueueNamesUnrated => 'Unrated';

  @override
  String get contentQueueNamesSwiftplay => 'Swiftplay';

  @override
  String get contentQueueNamesSpikerush => 'Spike Rush';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Team Deathmatch';

  @override
  String get contentQueueNamesGgteam => 'Escalation';

  @override
  String get contentQueueNamesOnefa => 'Replication';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Game Custom';

  @override
  String get contentQueueNames => 'Game Custom';

  @override
  String get contentQueueNamesDodgeball => 'Knockout';

  @override
  String get contentQueueNamesFortcollins => 'Retake';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Skirmish: 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => 'Skirmish: Ascension 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => 'Skirmish: Ascension 2v2';

  @override
  String get contentQueueNamesValaram => 'All Random One Site';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Snowball Fight';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Competitive';

  @override
  String get contentQueueShortNamesValaram => 'All Random';

  @override
  String get contentRewardSourceAgent => 'Kontrak agen';

  @override
  String get contentRewardSourceBattlePass => 'Hadiah Battle Pass';

  @override
  String get contentRewardSourceEvent => 'Event Pass';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duelist';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Initiator';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Controller';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Sentinel';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Exclusive';

  @override
  String contentTierFull(String shortName) {
    return '$shortName Edition';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Select';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Unranked';

  @override
  String get accountRegionUnknown => 'Region tidak diketahui';

  @override
  String accountRiotCountry(String country) {
    return 'Negara akun Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Negara akun Riot: Tidak diketahui';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'AKUN ($count/$max)';
  }

  @override
  String get accountActive => 'Aktif';

  @override
  String accountAddAccount(int count, int max) {
    return 'Tambah akun ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Hapus data lokal';

  @override
  String get accountClearLocalDataConfirm =>
      'Hapus riwayat, loadout tersimpan, dan data akun yang sudah logout di perangkat ini?';

  @override
  String get accountClearRrHistory => 'Hapus riwayat RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Hapus riwayat RR akun yang dipilih di perangkat ini?';

  @override
  String get accountCopyPassword => 'Salin kata sandi';

  @override
  String get accountCopyUsername => 'Salin nama pengguna';

  @override
  String get accountDeleteLoginNote => 'Hapus info';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Hapus nama pengguna dan kata sandi tersimpan untuk akun ini?';

  @override
  String get accountHidePassword => 'Sembunyikan kata sandi';

  @override
  String get accountKeepLocalData => 'Simpan data lokal';

  @override
  String get accountKeepLocalDataHint =>
      'Simpan wishlist, loadout, dan riwayat di perangkat ini';

  @override
  String accountLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Akun di notifikasi ini sudah logout. Login lagi, lalu buka notifikasinya.';

  @override
  String get accountLocalDataCleared => 'Data lokal dihapus';

  @override
  String get accountLoginNote => 'Info login';

  @override
  String get accountLoginNoteDeleted => 'Info login dihapus';

  @override
  String get accountLoginNoteEmpty => 'Belum ada info login tersimpan';

  @override
  String get accountLoginNoteHint =>
      'Hanya disimpan di perangkat ini dan dikunci dengan aman. Gunakan untuk melihat atau mengisi cepat datamu saat login lagi.';

  @override
  String get accountLoginNoteLocked => 'Buka kunci info login';

  @override
  String get accountLoginNotePassword => 'Kata sandi';

  @override
  String get accountLoginNoteSaved => 'Info login disimpan';

  @override
  String get accountLoginNoteUsername => 'Nama pengguna Riot';

  @override
  String get accountManageHint =>
      'Hapus akun atau ubah info login di Pengaturan.';

  @override
  String accountMaxAccounts(int max) {
    return 'Sudah mencapai batas $max akun.';
  }

  @override
  String get accountNeedsLogin => 'Login lagi';

  @override
  String accountOnlineCount(int count) {
    return '$count online';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Isi akun tersimpan';

  @override
  String get accountQuickFillDone => 'Sudah terisi. Ketuk Login.';

  @override
  String get accountQuickFillNotReady =>
      'Halaman login belum selesai dimuat. Tunggu sebentar lalu coba lagi.';

  @override
  String get accountQuickFillSubtitle =>
      'Pilih akun untuk diisi di halaman login Riot';

  @override
  String get accountQuickFillTitle => 'Isi akun tersimpan';

  @override
  String get accountRegionAp => 'Asia Pasifik';

  @override
  String get accountRegionBr => 'Brasil';

  @override
  String get accountRegionEu => 'Eropa';

  @override
  String get accountRegionKr => 'Korea';

  @override
  String get accountRegionLatam => 'Amerika Latin';

  @override
  String get accountRegionNa => 'Amerika Utara';

  @override
  String get accountRemoveAccount => 'Hapus akun';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Hapus $account dari perangkat ini? Kamu bisa memilih untuk menyimpan data tersimpan.';
  }

  @override
  String get accountRrHistoryCleared => 'Riwayat RR dihapus';

  @override
  String get accountShowPassword => 'Tampilkan kata sandi';

  @override
  String get accountSignOutAll => 'Logout dari semua akun';

  @override
  String get accountSignOutAllConfirm =>
      'Logout dan hapus semua akun dari perangkat ini? Kamu bisa memilih untuk menyimpan data tersimpan.';

  @override
  String get accountStatusAgentSelect => 'Sedang memilih agen';

  @override
  String get accountStatusInMatch => 'Sedang bertanding';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Status tidak diketahui';

  @override
  String accountSwitchTo(String account) {
    return 'Ganti ke $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Ketuk untuk berganti akun';

  @override
  String get accountSwitcherTitle => 'Akun';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Akun ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Pemain';

  @override
  String get accountUnlockLoginNote =>
      'Verifikasi untuk membuka info login Riot';

  @override
  String get authAddAsNew => 'Tambah sebagai akun baru';

  @override
  String get authDifferentAccountBody =>
      'Kamu login dengan akun yang berbeda dari akun yang perlu login lagi. Tambahkan akun ini sebagai akun baru?';

  @override
  String get authDifferentAccountTitle => 'Akun berbeda';

  @override
  String get authLoadingAccount => 'Memuat akun…';

  @override
  String get authLoginCancelledByRiot => 'Riot menolak login ini. Coba lagi.';

  @override
  String get authLoginFailed => 'Gagal menyelesaikan login';

  @override
  String get authLoginFailedBody =>
      'Riot belum mengonfirmasi login kamu. Coba lagi.';

  @override
  String get authLoginTitle => 'Login Riot';

  @override
  String get authMissingCookies =>
      'Login kamu tidak bisa disimpan di perangkat ini, jadi kamu perlu login lagi saat kedaluwarsa.';

  @override
  String get authOfficialHost => 'Halaman resmi · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Tautan dibuka di browser.';

  @override
  String get authPageLoadFailed =>
      'Gagal memuat halaman login Riot. Periksa koneksimu lalu coba lagi.';

  @override
  String get authPreparing => 'Menyiapkan halaman login…';

  @override
  String get authReloginDone => 'Berhasil login lagi';

  @override
  String get authRememberMeHint =>
      'Aktifkan \"Tetap login\" agar tidak perlu login lagi.';

  @override
  String get authSignInCta => 'Login dengan akun Riot';

  @override
  String get authSocialLoginHint =>
      'Jika login dengan Google atau Facebook tidak berhasil, gunakan nama pengguna Riot.';

  @override
  String get authStateMismatch =>
      'Percobaan login ini tidak valid. Mulai login lagi dari awal.';

  @override
  String get notificationSessionExpiredBody =>
      'Login lagi untuk terus menerima notifikasi wishlist.';

  @override
  String get notificationBackgroundTimingHint =>
      'Mode hemat baterai di perangkatmu bisa membuat notifikasi terlambat.';

  @override
  String get notificationChannelAccountDescription =>
      'Mengingatkan saat ada akun yang perlu login lagi';

  @override
  String get notificationChannelAccountName => 'Akun';

  @override
  String get notificationChannelBattlePassDescription =>
      'Pengingat progres dan tanggal berakhir Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Aktivitas komunitas saat kamu membuka ValHub';

  @override
  String get notificationChannelCommunityName => 'Komunitas';

  @override
  String get notificationChannelLfgDescription =>
      'Pemain yang bergabung ke party-mu saat kamu membuka ValHub';

  @override
  String get notificationChannelLfgName => 'Party';

  @override
  String get notificationChannelNightMarketDescription =>
      'Pemberitahuan saat Night Market dibuka';

  @override
  String get notificationChannelNightMarketName => 'Night Market';

  @override
  String get notificationChannelRankDescription =>
      'Perubahan rank saat kamu memperbarui profil';

  @override
  String get notificationChannelRankName => 'Rank';

  @override
  String get notificationChannelStoreResetDescription =>
      'Mengingatkan saat toko harian diperbarui';

  @override
  String get notificationChannelStoreResetName => 'Pembaruan toko';

  @override
  String get notificationChannelWishlistDescription =>
      'Pemberitahuan saat skin di wishlist muncul di tokomu';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle =>
      'Ada pemain yang bergabung ke party-mu';

  @override
  String get notificationLocalOnlyHint =>
      'Hanya muncul di perangkat ini saat ValHub memperbarui data';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Buka $cards kartu penawaran milik $account sekarang.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Night Market sudah dibuka!';

  @override
  String get notificationPassEndingBody =>
      'Battle Pass tersisa sekitar satu hari. Buka ValHub untuk melihat progres terbarumu.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass segera berakhir';

  @override
  String notificationPassProgressBody(int level) {
    return 'Kamu sudah mencapai level $level di Battle Pass saat ini.';
  }

  @override
  String get notificationPassProgressTitle => 'Progres Battle Pass';

  @override
  String get notificationPrivateAccount => 'akunmu';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Rank saat ini: $rank. Baru diperbarui dari Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Rank berubah';

  @override
  String get notificationResetTimingUnknown =>
      'Buka toko untuk memperbarui waktu reset di perangkatmu.';

  @override
  String get notificationSessionExpiredTitle => 'Login lagi';

  @override
  String get notificationStoreResetBody =>
      'Skin baru sudah menunggumu di toko.';

  @override
  String get competitiveDivisionIron => 'Iron';

  @override
  String get competitiveDivisionBronze => 'Bronze';

  @override
  String get competitiveDivisionSilver => 'Silver';

  @override
  String get competitiveDivisionGold => 'Gold';

  @override
  String get competitiveDivisionPlatinum => 'Platinum';

  @override
  String get competitiveDivisionDiamond => 'Diamond';

  @override
  String get competitiveDivisionAscendant => 'Ascendant';

  @override
  String get competitiveDivisionImmortal => 'Immortal';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiant';

  @override
  String get competitiveRankUnknown => 'Rank tidak diketahui';

  @override
  String get competitiveAttack => 'Menyerang';

  @override
  String get competitiveCannotEstimate => 'Tidak bisa diperkirakan';

  @override
  String get competitiveDefeat => 'Kalah';

  @override
  String get competitiveDefense => 'Bertahan';

  @override
  String get competitiveDraw => 'Seri';

  @override
  String get competitiveIncognitoPlayer => 'Pemain tersembunyi';

  @override
  String get competitiveMatchPending =>
      'Riot masih memproses pertandingan ini…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return 'Sisa $n pertandingan penempatan';
  }

  @override
  String get competitiveRoundDefuse => 'Spike dijinakkan';

  @override
  String get competitiveRoundDetonate => 'Spike meledak';

  @override
  String get competitiveRoundElimination => 'Eliminasi';

  @override
  String get competitiveRoundSurrendered => 'Menyerah';

  @override
  String get competitiveRoundTimeExpired => 'Waktu habis';

  @override
  String get competitiveUnknownPlayer => 'Pemain';

  @override
  String get competitiveVictory => 'Menang';

  @override
  String economyAvailableNow(String place) {
    return 'Sekarang ada di $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'bundle $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'bundle';

  @override
  String get economyPlaceDaily => 'toko harian';

  @override
  String get economyPlaceNightMarket => 'Night Market';

  @override
  String get economyPriceEstimated => 'Perkiraan dari edisi';

  @override
  String get economyPriceFromOffers => 'Harga dari daftar harga Riot';

  @override
  String get economyPriceFromStore => 'Harga yang terlihat di toko';

  @override
  String get economyPriceFromTable => 'Harga resmi';

  @override
  String get economyPriceUnknown => 'Harga tidak diketahui';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Loadout $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Perubahan ini tidak bisa diterapkan ke loadout-mu saat ini.';

  @override
  String get loadoutNotPersisted =>
      'Riot tidak menyimpan perubahanmu, jadi loadout-mu tetap sama. Coba lagi.';

  @override
  String get loadoutSaveFailed => 'Gagal menyimpan loadout';

  @override
  String battlePassActEndsIn(String time) {
    return 'Act berakhir dalam $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return 'Act berakhir dalam $days hari';
  }

  @override
  String get battlePassAllMissionsDone => 'Semua misi selesai';

  @override
  String get battlePassAllWeeklyDone => 'Semua misi mingguan selesai';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Hadiah ganda tertunda: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Chapter $n';
  }

  @override
  String battlePassChapterProgress(int reached, int total) {
    return '$reached/$total';
  }

  @override
  String battlePassCharges(int charges, int needed) {
    return '$charges/$needed';
  }

  @override
  String get battlePassCheckpointHint =>
      'Menangkan ronde untuk maju ke checkpoint (Deathmatch tidak dihitung).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Checkpoint $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Tiap checkpoint: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return '$done/$total checkpoint tercapai';
  }

  @override
  String get battlePassCurrentChapter => 'Saat ini';

  @override
  String get battlePassDailyAllDone => 'Semua checkpoint hari ini selesai';

  @override
  String get battlePassDailyCaption => 'Hadiah harian';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Hadiah harian · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Checkpoint kemarin sudah kedaluwarsa. Buka game atau muat ulang di sini.';

  @override
  String get battlePassDailyMissions => 'Misi harian';

  @override
  String get battlePassDailyNotReady =>
      'Checkpoint hari ini belum siap. Buka game atau muat ulang di sini.';

  @override
  String get battlePassDailyPlayToStart =>
      'Checkpoint hari ini belum siap. Buka game untuk memulai hari baru.';

  @override
  String battlePassDaysLeft(int days) {
    return 'Sisa $days hari';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Berakhir pada $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilog';

  @override
  String get battlePassEstimateNote =>
      'Perkiraan sekitar 4.000 XP per pertandingan, belum termasuk misi.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Berakhir dalam $time';
  }

  @override
  String get battlePassEventPass => 'Event Pass';

  @override
  String get battlePassFilterAll => 'Semua';

  @override
  String get battlePassFilterLocked => 'Terkunci';

  @override
  String get battlePassFilterUnlocked => 'Terbuka';

  @override
  String get battlePassFree => 'Gratis';

  @override
  String get battlePassFreeTrack => 'Hadiah gratis';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Level $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Lv. $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '≈ $nString pertandingan $queue';
  }

  @override
  String get battlePassMissionDone => 'Selesai';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total selesai';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Misi baru pada $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Misi baru dalam $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Checkpoint berikutnya: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Menuju level $level';
  }

  @override
  String get battlePassNextReward => 'Berikutnya';

  @override
  String get battlePassNoBattlePass =>
      'Belum ada info Battle Pass untuk Act saat ini. Coba lagi nanti.';

  @override
  String get battlePassNoRewards => 'Battle Pass ini belum punya hadiah.';

  @override
  String get battlePassNoRewardsInFilter => 'Tidak ada hadiah di bagian ini.';

  @override
  String get battlePassNoRewardsTitle => 'Belum ada hadiah';

  @override
  String get battlePassNoWeeklyMissions => 'Belum ada misi mingguan saat ini.';

  @override
  String get battlePassPassComplete => 'Battle Pass selesai';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Kamu belum punya Premium: kamu hanya mendapat hadiah Gratis. Beli Premium di dalam game untuk membuka level yang sudah kamu capai.';

  @override
  String get battlePassRenewButton => 'Muat ulang checkpoint';

  @override
  String get battlePassRenewDone => 'Checkpoint harian sudah dimuat ulang.';

  @override
  String get battlePassRenewFailed =>
      'Gagal memuat ulang checkpoint. Coba lagi nanti.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Reset pada $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Reset dalam $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Level';

  @override
  String get battlePassRewardLocked => 'Terkunci';

  @override
  String get battlePassRewardNeedsPremium => 'Butuh Premium';

  @override
  String get battlePassRewardStatusLabel => 'Status';

  @override
  String get battlePassRewardTrackLabel => 'Jalur hadiah';

  @override
  String get battlePassRewardTypeLabel => 'Jenis';

  @override
  String get battlePassRewardUnlocked => 'Terbuka';

  @override
  String get battlePassRewardsTitle => 'Hadiah';

  @override
  String get battlePassShowAllRewards => 'Lihat semua';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'Total XP';

  @override
  String get battlePassUnknownMission => 'Misi baru (belum ada deskripsi)';

  @override
  String get battlePassUnknownReward => 'Hadiah';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total terbuka';
  }

  @override
  String get battlePassUnratedFallback => 'Unrated';

  @override
  String get battlePassViewAllRewards => 'Lihat semua hadiah';

  @override
  String get battlePassWeeklyMissions => 'Misi mingguan';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Misi mingguan: sisa +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / hari';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Dibutuhkan per hari agar selesai tepat waktu';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Butuh $xp XP lagi';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Gagal menyimpan loadout. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Semua skin milikmu, dinilai dengan harga toko',
      'buddy': 'Gun Buddy milikmu dan jumlah salinannya',
      'spray': 'Spray yang bisa kamu pasang di expression wheel',
      'card':
          'Kartu Pemain yang sudah terbuka, ketuk untuk melihat dan memakai',
      'title': 'Gelar Pemain yang bisa kamu tampilkan di bawah namamu',
      'flex': 'Item Flex milikmu',
      'other': 'Jelajahi koleksi',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Slot $position';
  }

  @override
  String get collectionApplyPreset => 'Terapkan';

  @override
  String get collectionApplyPresetBody =>
      'Skin, Gun Buddy, expression wheel, kartu, dan gelar yang sedang kamu pakai akan diganti dengan loadout ini.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Terapkan “$name”?';
  }

  @override
  String get collectionBrowseBuddies => 'Gun Buddy';

  @override
  String get collectionBrowseCards => 'Kartu Pemain';

  @override
  String get collectionBrowseEmpty => 'Kamu belum punya item di bagian ini.';

  @override
  String get collectionBrowseEmptyTitle => 'Belum ada item';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skin';

  @override
  String get collectionBrowseSprays => 'Spray';

  @override
  String get collectionBrowseTitles => 'Gelar Pemain';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Sisa $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Untuk $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Pilih Gun Buddy';

  @override
  String get collectionBuddyRemoved => 'Gun Buddy dilepas';

  @override
  String get collectionBuddySlot => 'Gun Buddy';

  @override
  String get collectionBuddyUnavailable =>
      'Gagal memasang Gun Buddy ini. Muat ulang atau pilih yang lain.';

  @override
  String get collectionCachedLoadout =>
      'Menampilkan loadout tersimpan. Tarik untuk memuat ulang sebelum mengubah.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString kartu dimiliki';
  }

  @override
  String get collectionChangeBuddy => 'Ganti';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total varian';
  }

  @override
  String get collectionClearTiers => 'Hapus filter edisi';

  @override
  String get collectionCollectionValue => 'Nilai koleksi';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standar';

  @override
  String get collectionDeletePreset => 'Hapus';

  @override
  String get collectionEmptySlot => 'Kosong';

  @override
  String get collectionEquip => 'Pakai';

  @override
  String get collectionEquipped => 'Dipakai';

  @override
  String get collectionEquippedCard => 'Kartu yang dipakai';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Kartu yang dipakai: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$name dipakai';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Dipakai: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Tidak termasuk skin hadiah';

  @override
  String get collectionExpressionsHint =>
      'Ketuk slot untuk memilih Spray atau Flex.';

  @override
  String get collectionExpressionsSlots => 'Slot roda';

  @override
  String get collectionExpressionsTitle => 'Expression wheel';

  @override
  String get collectionHideAccountLevel => 'Sembunyikan level akun';

  @override
  String get collectionHideAccountLevelHint =>
      'Pemain lain tidak akan melihat level akunmu.';

  @override
  String get collectionIncognito => 'Mode penyamaran';

  @override
  String get collectionIncognitoHint =>
      'Sembunyikan namamu dari pemain di luar party-mu saat bertanding.';

  @override
  String get collectionLevelBorderAuto => 'Otomatis sesuai level';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Mulai level $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Akun level $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Pilih Bingkai Level';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Level $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Level $n · $type';
  }

  @override
  String get collectionLevels => 'Level';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$total level terbuka';
  }

  @override
  String get collectionLobbyBanner => 'Banner lobi';

  @override
  String get collectionLocked => 'Terkunci';

  @override
  String get collectionMeleeNoBuddy =>
      'Senjata melee tidak bisa dipasangi Gun Buddy.';

  @override
  String get collectionMove => 'Pindahkan';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy terpasang di $from. Pindahkan ke $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Pindahkan Gun Buddy?';

  @override
  String get collectionNoBuddies => 'Kamu belum punya Gun Buddy.';

  @override
  String get collectionNoBuddy => 'Tanpa Gun Buddy';

  @override
  String get collectionNoFlex => 'Kamu belum punya item Flex.';

  @override
  String get collectionNoResults => 'Tidak ada hasil yang cocok.';

  @override
  String get collectionNoResultsTitle => 'Tidak ditemukan';

  @override
  String get collectionNoSkinsForWeapon =>
      'Kamu belum punya skin untuk senjata ini.';

  @override
  String get collectionNoSprays => 'Kamu belum punya Spray.';

  @override
  String get collectionNoTitle => 'Tanpa gelar';

  @override
  String get collectionOtherWeapons => 'Lainnya';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin dimiliki',
      zero: 'Belum ada skin',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString skin dimiliki';
  }

  @override
  String get collectionPlayLevelVideo => 'Tonton video level ini';

  @override
  String get collectionPlayVideo => 'Tonton video';

  @override
  String get collectionPlayerCardSubtitle =>
      'Ditampilkan di lobi, di papan skor, dan saat kamu mengeliminasi musuh.';

  @override
  String get collectionPlayerCardTitle => 'Ganti Kartu Pemain';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Ditampilkan di bawah namamu di lobi dan saat bertanding.';

  @override
  String get collectionPlayerTitleTitle => 'Ganti Gelar Pemain';

  @override
  String get collectionPresetActions => 'Opsi';

  @override
  String collectionPresetApplied(String name) {
    return '“$name” diterapkan';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n loadout',
      zero: 'Belum ada',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '“$name” dihapus';
  }

  @override
  String get collectionPresetNameHint => 'Contoh: Push rank';

  @override
  String get collectionPresetNameTitle => 'Nama loadout';

  @override
  String collectionPresetSaved(String name) {
    return '“$name” disimpan';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Disimpan pada $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return '$n item yang sudah tidak kamu miliki dilewati.';
  }

  @override
  String get collectionPresetsEmpty =>
      'Simpan loadout yang sedang kamu pakai untuk berganti cepat antar set skin, kartu, dan expression wheel nanti.';

  @override
  String get collectionPresetsEmptyTitle => 'Belum ada loadout tersimpan';

  @override
  String get collectionPresetsFull =>
      'Sudah mencapai batas 50 loadout. Hapus beberapa untuk menyimpan lagi.';

  @override
  String get collectionPresetsNote =>
      'Loadout hanya disimpan di perangkat ini, untuk akun yang dipilih.';

  @override
  String get collectionPresetsTitle => 'Loadout tersimpan';

  @override
  String get collectionPreview => 'Pratinjau';

  @override
  String get collectionRemoveBuddy => 'Lepas Gun Buddy';

  @override
  String get collectionRenamePreset => 'Ganti nama';

  @override
  String get collectionRowExpressions => 'Expression wheel';

  @override
  String get collectionRowLevelBorder => 'Bingkai Level';

  @override
  String get collectionRowPresets => 'Loadout tersimpan';

  @override
  String get collectionRowWeapons => 'Loadout senjata';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Gagal menyimpan loadout';

  @override
  String get collectionSavePreset => 'Simpan loadout saat ini';

  @override
  String get collectionSaving => 'Menyimpan…';

  @override
  String get collectionSearchBuddies => 'Cari Gun Buddy…';

  @override
  String get collectionSearchCards => 'Cari Kartu Pemain…';

  @override
  String get collectionSearchFlex => 'Cari Flex…';

  @override
  String get collectionSearchItems => 'Cari…';

  @override
  String get collectionSearchSkins => 'Cari skin…';

  @override
  String get collectionSearchSprays => 'Cari Spray…';

  @override
  String get collectionSearchTitles => 'Cari gelar…';

  @override
  String get collectionSearchWeapons => 'Cari senjata, skin, atau Gun Buddy…';

  @override
  String get collectionSectionBrowse => 'Jelajahi koleksi';

  @override
  String get collectionSectionIdentity => 'Terlihat oleh pemain lain';

  @override
  String get collectionSectionLoadout => 'Loadout';

  @override
  String get collectionSkinCustomizeTitle => 'Kustomisasi skin';

  @override
  String get collectionSkinNotFound => 'Skin ini tidak ditemukan.';

  @override
  String get collectionSkinNotOwned => 'Kamu belum memiliki skin ini.';

  @override
  String get collectionSlotNamesItem0 => 'Atas';

  @override
  String get collectionSlotNamesItem1 => 'Kanan';

  @override
  String get collectionSlotNamesItem2 => 'Bawah';

  @override
  String get collectionSlotNamesItem3 => 'Kiri';

  @override
  String get collectionSortName => 'Nama';

  @override
  String get collectionSortPrice => 'Harga';

  @override
  String get collectionSortRarity => 'Kelangkaan';

  @override
  String get collectionSortWeapon => 'Senjata';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return 'Difilter: $count skin · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Difilter: $count/$total item';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count item';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count skin · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Spray';

  @override
  String get collectionTapToChangeCard => 'Ketuk untuk ganti kartu';

  @override
  String get collectionTitle => 'Koleksi';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString gelar dimiliki';
  }

  @override
  String get collectionUndo => 'Urungkan';

  @override
  String get collectionUnknownCard => 'Kartu tidak dikenal';

  @override
  String get collectionValueAtStorePrices => 'Berdasarkan harga toko';

  @override
  String get collectionValueHasEstimates => 'Termasuk perkiraan (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return '$n skin hadiah tidak dihitung';
  }

  @override
  String get collectionValueSeeSkins => 'Lihat skin';

  @override
  String collectionValueSkinCount(int n) {
    return 'Berdasarkan $n skin';
  }

  @override
  String get collectionVariants => 'Varian';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total senjata memakai skin';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Loadout senjata';

  @override
  String get collectionWeaponNotFound => 'Senjata ini tidak ditemukan.';

  @override
  String get collectionWeaponSkinsTitle => 'Pilih skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin',
      zero: 'Kosong',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Gagal memposting karena ada kata-kata yang tidak pantas. Ubah isinya lalu coba lagi.';

  @override
  String get communityModerationContentScam =>
      'Komunitas tidak mengizinkan iklan jual beli akun, jasa joki, atau nomor telepon. Hapus konten tersebut lalu coba lagi.';

  @override
  String get communityModerationContentTooComplex =>
      'Postinganmu punya terlalu banyak karakter acak. Tulis lebih ringkas lalu coba lagi.';

  @override
  String get communityModerationAccountBanned =>
      'Akun ini sudah diblokir dari Komunitas. Jika menurutmu ini kesalahan, hubungi ValHub di Tentang & legal.';

  @override
  String get communityModerationAccountRestricted =>
      'Akun ini sedang dibatasi untuk memposting, berkomentar, mencari rekan tim, dan memberi suara. Coba lagi nanti atau hubungi ValHub di Tentang & legal.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitive',
      'unrated': 'Unrated',
      'swiftplay': 'Swiftplay',
      'spikerush': 'Spike Rush',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Team Deathmatch',
      'premier': 'Premier',
      'custom': 'Game Custom',
      'other': 'Lainnya',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asia Pasifik',
      'na': 'Amerika Utara',
      'eu': 'Eropa',
      'kr': 'Korea',
      'latam': 'Amerika Latin',
      'br': 'Brasil',
      'other': 'Region tidak diketahui',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'Belum ada skin di peringkat ini';

  @override
  String get communityRankingEmptyVotes =>
      'Belum ada favorit yang cocok dengan cakupan dan filter yang dipilih.';

  @override
  String get communityRankingEmptyRatings =>
      'Belum ada rating bintang yang cocok dengan cakupan dan filter yang dipilih.';

  @override
  String get communityRankingEmptyReviews =>
      'Belum ada ulasan yang cocok dengan cakupan dan filter yang dipilih.';

  @override
  String get communityRankingExplore => 'Cari skin untuk dilihat dan dinilai';

  @override
  String get communityRankingExploreHint =>
      'Cari berdasarkan nama skin atau senjata. Hanya penilaian asli dari komunitas yang muncul di peringkat.';

  @override
  String get communityRankingClear => 'Hapus filter senjata dan waktu';

  @override
  String get communityRankingSort => 'Urutkan peringkat';

  @override
  String get communityRankingWeapon => 'Senjata';

  @override
  String get communityRankingNoSearch =>
      'Tidak ada skin yang cocok. Coba nama lain atau hapus filter senjata.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Gagal memuat daftar skin. Tutup panel ini dan coba lagi setelah data tersinkron.';

  @override
  String get communityConsentExitAccount => 'Tolak · Logout dari akun ini';

  @override
  String get communityRankingGlobalAllTime => 'Global · Sepanjang masa';

  @override
  String get communityRankingCatalogTitle => 'Semua skin';

  @override
  String get communityReviewOwnershipRequired =>
      'Akunmu harus memiliki skin ini untuk menilainya. Kamu tetap bisa membaca penilaian dan komentar komunitas.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Kepemilikan skin belum bisa diverifikasi. Muat ulang Koleksi atau coba lagi saat online.';

  @override
  String get communityReviewLegacyOwnership =>
      'Ulasan lama · Kepemilikan belum diverifikasi';

  @override
  String get communityReviewVerifiedOwner =>
      'Kepemilikan terverifikasi saat ulasan dibuat';

  @override
  String get communitySkinDiscussionHint =>
      'Semua orang bisa berkomentar. Hanya pemilik skin yang bisa memberi bintang dan menulis ulasan.';

  @override
  String get communityAddPhotos => 'Tambah foto';

  @override
  String get communityAllModes => 'Semua';

  @override
  String get communityAllWeapons => 'Semua senjata';

  @override
  String get communityAnonymousBanner => 'Menjelajah secara anonim';

  @override
  String get communityAnyLanguage => 'Bahasa apa saja';

  @override
  String get communityAnyRank => 'Rank apa saja';

  @override
  String get communityAnyRole => 'Role apa saja';

  @override
  String get communityApply => 'Terapkan';

  @override
  String get communityBackToMyCountry => 'Kembali ke negaramu';

  @override
  String get communityBlockAuthor => 'Blokir di perangkat ini';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Hapus';

  @override
  String get communityCodeAuto =>
      'Kosongkan: ValHub akan membuat kode dari party-mu di dalam game saat kamu memposting.';

  @override
  String get communityCodeAutoFailed =>
      'Gagal membuat kode party. Buka VALORANT atau masukkan kode secara manual.';

  @override
  String get communityCodeInvalid =>
      'Kode harus terdiri dari tepat 6 huruf kapital atau angka.';

  @override
  String get communityCodeRequired => 'Masukkan atau buat kode party.';

  @override
  String get communityCommentHint => 'Tulis komentar…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString komentar';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Komentar · $n';
  }

  @override
  String get communityCommentsTitle => 'Komentar';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '$posts postingan · $authors pemain';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString postingan cari rekan tim';
  }

  @override
  String get communityCommunityVotes => 'Favorit komunitas';

  @override
  String get communityComposerHint =>
      'Apa yang kamu pikirkan tentang VALORANT hari ini?';

  @override
  String get communityComposerTitle => 'Postingan baru';

  @override
  String communityConsentAccount(String riotId) {
    return 'Akun: $riotId';
  }

  @override
  String get communityConsentAgree => 'Setuju dan lanjutkan';

  @override
  String get communityConsentGateAction => 'Gabung';

  @override
  String get communityConsentGuidelines => 'Pedoman Komunitas';

  @override
  String get communityConsentLater => 'Nanti';

  @override
  String get communityConsentLocal =>
      'Kata sandi dan data login lainnya selalu tetap di perangkat ini. Kamu bisa menarik persetujuan di Pengaturan.';

  @override
  String get communityConsentPrivacy => 'Kebijakan Privasi';

  @override
  String get communityConsentPublic =>
      'Orang lain akan melihat Riot ID, Kartu Pemain, rank, dan negaramu.';

  @override
  String get communityConsentTitle => 'Privasi dan Komunitas ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub mengirim akses Riot-mu ke server Komunitas untuk memverifikasi Riot ID saat terhubung dan memeriksa kepemilikan skin saat kamu menyimpan ulasan. Server hanya membaca data yang diperlukan, langsung membuang akses tersebut setelahnya, dan tidak pernah menyimpannya.';

  @override
  String get communityConsentWithdrawn =>
      'Persetujuan ditarik. Kamu perlu menyetujui lagi untuk terus memakai aplikasi.';

  @override
  String get communityCountriesTitle => 'Komunitas per negara';

  @override
  String get communityCountryNamesAE => 'Uni Emirat Arab';

  @override
  String get communityCountryNamesAL => 'Albania';

  @override
  String get communityCountryNamesAM => 'Armenia';

  @override
  String get communityCountryNamesAR => 'Argentina';

  @override
  String get communityCountryNamesAT => 'Austria';

  @override
  String get communityCountryNamesAU => 'Australia';

  @override
  String get communityCountryNamesAZ => 'Azerbaijan';

  @override
  String get communityCountryNamesBA => 'Bosnia dan Herzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Belgia';

  @override
  String get communityCountryNamesBG => 'Bulgaria';

  @override
  String get communityCountryNamesBH => 'Bahrain';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivia';

  @override
  String get communityCountryNamesBR => 'Brasil';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Kanada';

  @override
  String get communityCountryNamesCH => 'Swiss';

  @override
  String get communityCountryNamesCL => 'Cile';

  @override
  String get communityCountryNamesCN => 'Tiongkok';

  @override
  String get communityCountryNamesCO => 'Kolombia';

  @override
  String get communityCountryNamesCR => 'Kosta Rika';

  @override
  String get communityCountryNamesCU => 'Kuba';

  @override
  String get communityCountryNamesCY => 'Siprus';

  @override
  String get communityCountryNamesCZ => 'Ceko';

  @override
  String get communityCountryNamesDE => 'Jerman';

  @override
  String get communityCountryNamesDK => 'Denmark';

  @override
  String get communityCountryNamesDO => 'Republik Dominika';

  @override
  String get communityCountryNamesDZ => 'Aljazair';

  @override
  String get communityCountryNamesEC => 'Ekuador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Mesir';

  @override
  String get communityCountryNamesES => 'Spanyol';

  @override
  String get communityCountryNamesET => 'Etiopia';

  @override
  String get communityCountryNamesFI => 'Finlandia';

  @override
  String get communityCountryNamesFR => 'Prancis';

  @override
  String get communityCountryNamesGB => 'Britania Raya';

  @override
  String get communityCountryNamesGE => 'Georgia';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Yunani';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Kroasia';

  @override
  String get communityCountryNamesHU => 'Hungaria';

  @override
  String get communityCountryNamesID => 'Indonesia';

  @override
  String get communityCountryNamesIE => 'Irlandia';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'India';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Islandia';

  @override
  String get communityCountryNamesIT => 'Italia';

  @override
  String get communityCountryNamesJO => 'Yordania';

  @override
  String get communityCountryNamesJP => 'Jepang';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Kamboja';

  @override
  String get communityCountryNamesKR => 'Korea Selatan';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Kazakhstan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Lebanon';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Lituania';

  @override
  String get communityCountryNamesLU => 'Luksemburg';

  @override
  String get communityCountryNamesLV => 'Latvia';

  @override
  String get communityCountryNamesLY => 'Libya';

  @override
  String get communityCountryNamesMA => 'Maroko';

  @override
  String get communityCountryNamesMD => 'Moldova';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Makedonia Utara';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolia';

  @override
  String get communityCountryNamesMO => 'Makau';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Meksiko';

  @override
  String get communityCountryNamesMY => 'Malaysia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nikaragua';

  @override
  String get communityCountryNamesNL => 'Belanda';

  @override
  String get communityCountryNamesNO => 'Norwegia';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Selandia Baru';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Filipina';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Polandia';

  @override
  String get communityCountryNamesPR => 'Puerto Riko';

  @override
  String get communityCountryNamesPT => 'Portugal';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Qatar';

  @override
  String get communityCountryNamesRO => 'Rumania';

  @override
  String get communityCountryNamesRS => 'Serbia';

  @override
  String get communityCountryNamesRU => 'Rusia';

  @override
  String get communityCountryNamesSA => 'Arab Saudi';

  @override
  String get communityCountryNamesSE => 'Swedia';

  @override
  String get communityCountryNamesSG => 'Singapura';

  @override
  String get communityCountryNamesSI => 'Slovenia';

  @override
  String get communityCountryNamesSK => 'Slowakia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Thailand';

  @override
  String get communityCountryNamesTL => 'Timor Leste';

  @override
  String get communityCountryNamesTN => 'Tunisia';

  @override
  String get communityCountryNamesTR => 'Turki';

  @override
  String get communityCountryNamesTW => 'Taiwan';

  @override
  String get communityCountryNamesUA => 'Ukraina';

  @override
  String get communityCountryNamesUS => 'Amerika Serikat';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Uzbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'Afrika Selatan';

  @override
  String get communityCreateLfg => 'Buat postingan cari rekan tim';

  @override
  String get communityCreateLfgShort => 'Posting';

  @override
  String get communityDataDeleted => 'Data Komunitas kamu sudah dihapus.';

  @override
  String communityDataFooter(String riotId) {
    return 'Berlaku untuk akun yang sedang dipakai: $riotId. File unduhan tidak berisi kata sandi atau data login Riot.';
  }

  @override
  String get communityDataTitle => 'Data Komunitas kamu';

  @override
  String get communityDecrease => 'Kurangi';

  @override
  String get communityDelete => 'Hapus';

  @override
  String get communityDeleteComment => 'Hapus komentar';

  @override
  String get communityDeleteCommentBody =>
      'Komentar ini akan dihapus secara permanen.';

  @override
  String get communityDeleteCommentTitle => 'Hapus komentar?';

  @override
  String get communityDeleteDataConfirm => 'Hapus permanen';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Semua postingan, komentar, ulasan skin, suka, suara, postingan cari rekan tim, dan foto dari $riotId di Komunitas ValHub akan dihapus permanen dan tidak bisa dipulihkan. Kamu akan kembali ke mode menjelajah anonim dan perlu menyetujui lagi jika ingin bergabung kembali.\n\nAkun Riot dan data di dalam game tidak terpengaruh. Unduh datamu terlebih dahulu jika ingin menyimpan salinannya.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Hapus data Komunitas?';

  @override
  String get communityDeleteDataSubtitle =>
      'Hapus permanen semua yang pernah kamu posting di Komunitas.';

  @override
  String get communityDeleteDataTitle => 'Hapus data Komunitas saya';

  @override
  String get communityDeletePost => 'Hapus postingan';

  @override
  String get communityDeletePostBody =>
      'Postingan ini beserta semua komentarnya akan dihapus permanen.';

  @override
  String get communityDeletePostTitle => 'Hapus postingan?';

  @override
  String get communityDeleteReview => 'Hapus ulasan';

  @override
  String get communityDeleteReviewBody =>
      'Nilai dan ulasanmu untuk skin ini akan dihapus.';

  @override
  String get communityDeleteReviewTitle => 'Hapus ulasanmu?';

  @override
  String get communityDeleted => 'Dihapus.';

  @override
  String get communityDiscard => 'Buang';

  @override
  String get communityDiscardBody =>
      'Yang baru saja kamu tulis tidak akan disimpan.';

  @override
  String get communityDiscardTitle => 'Buang postingan?';

  @override
  String get communityDownload => 'Unduh dan terjemahkan';

  @override
  String get communityDownloadingModels => 'Mengunduh paket bahasa…';

  @override
  String get communityEditReview => 'Ubah';

  @override
  String get communityEdited => 'diedit';

  @override
  String get communityEmptyPost => 'Tulis sesuatu atau tambahkan foto.';

  @override
  String get communityExpired => 'Kedaluwarsa';

  @override
  String communityExpiresIn(String t) {
    return 'Sisa $t';
  }

  @override
  String get communityExportPreparing => 'Menyiapkan…';

  @override
  String get communityExportSubject => 'Data Komunitas ValHub';

  @override
  String get communityExportSubtitle =>
      'Salinan semua yang pernah kamu posting di Komunitas: postingan, komentar, ulasan, suka, suara, dan postingan cari rekan tim.';

  @override
  String get communityExportTitle => 'Unduh data saya';

  @override
  String get communityExtend => 'Perpanjang';

  @override
  String get communityExtended => 'Postingan diperpanjang 30 menit.';

  @override
  String get communityFeedEmptyBody =>
      'Jadilah yang pertama membagikan toko, Night Market, atau momen terbaikmu!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Tidak ada postingan yang cocok. Coba bahasa lain atau hapus filter.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Belum ada postingan baru. Kembali lagi nanti atau gabung untuk berbagi.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Coba lihat postingan dari komunitas internasional atau ubah filter.';

  @override
  String get communityFeedEmptyScopeTitle => 'Belum ada postingan di sini';

  @override
  String get communityFeedEmptyTitle => 'Feed masih kosong';

  @override
  String get communityFilters => 'Filter';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Diterjemahkan oleh Google';

  @override
  String get communityHelpful => 'Membantu';

  @override
  String communityHelpfulCount(String n) {
    return 'Membantu · $n';
  }

  @override
  String get communityHiddenAuthors => 'Pemain yang disembunyikan dan diblokir';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Kamu belum menyembunyikan atau memblokir siapa pun';

  @override
  String get communityHiddenAuthorsHint =>
      'Hanya berlaku untuk akun ini di perangkat ini. Konten mereka disembunyikan; mereka tetap bisa melihat konten publikmu.';

  @override
  String communityImageOf(int i, int n) {
    return 'Foto $i/$n';
  }

  @override
  String get communityIncrease => 'Tambah';

  @override
  String get communityJoin => 'Gabung';

  @override
  String get communityJoinCodeExpired =>
      'Kode party sudah kedaluwarsa atau tidak berlaku lagi.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Kamu akan keluar dari party VALORANT saat ini untuk bergabung ke party $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Gabung ke party ini?';

  @override
  String get communityJoinGameNotRunning =>
      'Buka VALORANT di PC atau konsolmu lalu coba lagi.';

  @override
  String get communityJoinParty => 'Gabung party';

  @override
  String get communityJoinPartyFull => 'Party ini sudah penuh.';

  @override
  String get communityJoinedHint =>
      'Kamu sudah bergabung ke party! Buka VALORANT untuk main bareng.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString permintaan bergabung';
  }

  @override
  String get communityKindNightMarket => 'Night Market';

  @override
  String get communityKindStore => 'Toko hari ini';

  @override
  String get communityLanguage => 'Bahasa';

  @override
  String get communityLanguageFilter => 'Bahasa konten';

  @override
  String get communityLanguageFilterHint =>
      'Hanya tampilkan konten yang ditulis dalam bahasa yang dipilih. Kosongkan untuk melihat semuanya.';

  @override
  String get communityLanguageNamesAr => 'العربية';

  @override
  String get communityLanguageNamesDe => 'Deutsch';

  @override
  String get communityLanguageNamesEn => 'English';

  @override
  String get communityLanguageNamesEs => 'Español';

  @override
  String get communityLanguageNamesFr => 'Français';

  @override
  String get communityLanguageNamesId => 'Bahasa Indonesia';

  @override
  String get communityLanguageNamesIt => 'Italiano';

  @override
  String get communityLanguageNamesJa => '日本語';

  @override
  String get communityLanguageNamesKo => '한국어';

  @override
  String get communityLanguageNamesPl => 'Polski';

  @override
  String get communityLanguageNamesPt => 'Português';

  @override
  String get communityLanguageNamesRu => 'Русский';

  @override
  String get communityLanguageNamesTh => 'ไทย';

  @override
  String get communityLanguageNamesTr => 'Türkçe';

  @override
  String get communityLanguageNamesVi => 'Tiếng Việt';

  @override
  String get communityLanguageNamesZhCN => '简体中文';

  @override
  String get communityLanguageNamesZhTW => '繁體中文';

  @override
  String communityLanguagesSelected(int n) {
    return '$n bahasa';
  }

  @override
  String get communityLfgEmptyBody =>
      'Buat postingan agar pemain lain bisa bergabung ke party-mu dengan sekali ketuk.';

  @override
  String get communityLfgEmptyTitle => 'Belum ada yang mencari rekan tim';

  @override
  String get communityLfgExpiredRepost =>
      'Postinganmu sudah kedaluwarsa. Buat postingan baru untuk mencari rekan tim.';

  @override
  String get communityLfgGateBody =>
      'Gabung (verifikasi Riot ID sekali saja) untuk melihat postingan pemain di server yang sama dan memposting pencarian rekan timmu sendiri. Kamu tetap bisa menjelajahi Feed dan Peringkat skin seperti biasa.';

  @override
  String get communityLfgGateTitle => 'Cari rekan tim khusus anggota';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Kamu sedang melihat server $region — hanya pemain di server yang sama dengan akunmu yang bisa bergabung ke party.';
  }

  @override
  String get communityLfgPosted => 'Postingan cari rekan tim diterbitkan!';

  @override
  String get communityLfgPreviewTitle => 'Cari rekan tim yang sesuai rank-mu';

  @override
  String get communityLfgRemoved => 'Postingan dihapus.';

  @override
  String get communityLfgSameShardNote =>
      'Hanya pemain di server yang sama yang bisa bergabung ke party.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Region: $region · Postingan otomatis kedaluwarsa setelah 30 menit.';
  }

  @override
  String get communityLike => 'Suka';

  @override
  String get communityLiveMembers => 'Anggota';

  @override
  String get communityMatchMyRank => 'Sesuai rank-mu';

  @override
  String communityMemberJoined(String name) {
    return '$name bergabung ke party';
  }

  @override
  String get communityMemberJoinedBody =>
      'Ada yang baru saja bergabung dari postingan cari rekan timmu.';

  @override
  String get communityMic => 'Wajib mic';

  @override
  String get communityMicOn => 'Pakai mic';

  @override
  String get communityMode => 'Mode';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Opsi lainnya';

  @override
  String get communityMuteAuthor => 'Sembunyikan pemain ini';

  @override
  String get communityNewPost => 'Posting';

  @override
  String communityNightMarketOf(String date) {
    return 'Night Market tanggal $date';
  }

  @override
  String get communityNoAccountBody =>
      'Tambahkan akun Riot untuk memposting, mencari rekan tim, dan memberi suara untuk skin.';

  @override
  String get communityNoAccountTitle => 'Login untuk bergabung';

  @override
  String get communityNoComments =>
      'Belum ada komentar. Jadilah yang pertama berkomentar!';

  @override
  String get communityNoRatings => 'Belum ada penilaian';

  @override
  String get communityNote => 'Catatan';

  @override
  String get communityNoteHint =>
      'Contoh: butuh 1 Controller, pakai mic, main santai';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get communityOpenReviews => 'Lihat ulasan';

  @override
  String get communityOutOfRange => 'Di luar rentang rank';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Kode party';

  @override
  String get communityPartyCodeHint => 'Contoh: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Kode party: $code';
  }

  @override
  String get communityPartySize => 'Party saat ini';

  @override
  String get communityPartySizeFromGame =>
      'Diambil dari party-mu di dalam game';

  @override
  String communityPartySizeValue(int n) {
    return '$n pemain';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max foto';
  }

  @override
  String get communityPlayVideo => 'Tonton video';

  @override
  String get communityPostLfg => 'Posting';

  @override
  String get communityPostNotFound =>
      'Postingan ini sudah dihapus atau disembunyikan.';

  @override
  String get communityPostTitle => 'Postingan';

  @override
  String get communityPosted => 'Berhasil diposting!';

  @override
  String get communityPublish => 'Posting';

  @override
  String get communityPublishing => 'Memposting…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Dari';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Rentang rank';

  @override
  String get communityRankRangeInvalid =>
      'Rank terendah tidak boleh lebih tinggi dari rank tertinggi.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Peringkat $n: $name';
  }

  @override
  String get communityRankTo => 'Sampai';

  @override
  String get communityRateLimitedTitle => 'Tunggu sebentar';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString penilaian';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString penilaian';
  }

  @override
  String get communityRatingWordsItem0 => 'Jelek';

  @override
  String get communityRatingWordsItem1 => 'Kurang';

  @override
  String get communityRatingWordsItem2 => 'Lumayan';

  @override
  String get communityRatingWordsItem3 => 'Keren';

  @override
  String get communityRatingWordsItem4 => 'Mahakarya';

  @override
  String get communityRefreshList => 'Muat ulang';

  @override
  String get communityRegion => 'Region';

  @override
  String get communityRemoveAttachment => 'Hapus lampiran';

  @override
  String get communityRemoveLfg => 'Hapus postingan';

  @override
  String get communityRemoveLfgBody =>
      'Pemain lain tidak akan melihat postingan ini lagi.';

  @override
  String get communityRemoveLfgTitle => 'Hapus postingan cari rekan tim?';

  @override
  String get communityRemovePhoto => 'Hapus foto';

  @override
  String get communityReport => 'Laporkan';

  @override
  String get communityReportConfirmBody =>
      'Konten yang dilaporkan banyak pemain akan disembunyikan dari Komunitas.';

  @override
  String get communityReportConfirmTitle => 'Kirim laporan?';

  @override
  String get communityReportPrompt => 'Kenapa kamu melaporkan konten ini?';

  @override
  String get communityReportReasonsSpam => 'Spam atau iklan';

  @override
  String get communityReportReasonsHarassment => 'Pelecehan atau hinaan';

  @override
  String get communityReportReasonsInappropriate => 'Konten tidak pantas';

  @override
  String get communityReportReasonsScam => 'Penipuan atau jual beli akun';

  @override
  String get communityReportReasonsOther => 'Alasan lain';

  @override
  String get communityReportTitle => 'Laporkan konten';

  @override
  String get communityReported => 'Terima kasih! Laporanmu sudah dikirim.';

  @override
  String get communityReviewDeleted => 'Ulasan dihapus.';

  @override
  String get communityReviewHint =>
      'Bagikan pendapatmu tentang skin ini (opsional)';

  @override
  String get communityReviewSaved => 'Ulasan disimpan!';

  @override
  String get communityReviewTitle => 'Nilai skin';

  @override
  String get communityReviewsEmptyBody =>
      'Belum ada ulasan — jadilah yang pertama!';

  @override
  String get communityReviewsEmptyTitle => 'Belum ada ulasan';

  @override
  String communityReviewsHeader(String n) {
    return 'Ulasan · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot sedang mengalami gangguan';

  @override
  String get communityRoleFlex => 'Fleksibel';

  @override
  String get communityRoles => 'Role yang dibutuhkan';

  @override
  String get communitySaveReview => 'Simpan ulasan';

  @override
  String get communityScopeCountry => 'Negaramu';

  @override
  String get communityScopeGlobal => 'Internasional';

  @override
  String get communityScopeRegion => 'Region';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Cari rekan tim';

  @override
  String get communitySectionSkins => 'Peringkat skin';

  @override
  String get communitySend => 'Kirim';

  @override
  String get communitySendComment => 'Kirim komentar';

  @override
  String get communityShareNightMarketHint =>
      'Pamerkan Night Market-mu ke semua orang';

  @override
  String communitySharePostTitle(String name) {
    return 'Postingan $name di ValHub';
  }

  @override
  String get communityShareStore => 'Bagikan ke Komunitas';

  @override
  String get communityShareStoreHint => 'Pamerkan toko hari ini ke semua orang';

  @override
  String get communityShowOriginal => 'Lihat aslinya';

  @override
  String get communityShowTranslation => 'Lihat terjemahan';

  @override
  String get communitySignInToReview =>
      'Tambahkan akun Riot untuk menilai skin.';

  @override
  String get communitySkinNotFound => 'Skin ini tidak ditemukan.';

  @override
  String get communitySlots => 'Jumlah pemain yang dibutuhkan';

  @override
  String communitySlotsTooMany(int max) {
    return 'Party maksimal 5 pemain: hanya tersisa $max slot.';
  }

  @override
  String communitySlotsWanted(int n) {
    return 'Butuh $n pemain';
  }

  @override
  String get communitySortHelpful => 'Paling membantu';

  @override
  String get communitySortNewest => 'Terbaru';

  @override
  String get communitySortRating => 'Nilai tertinggi';

  @override
  String get communitySortReviews => 'Ulasan terbanyak';

  @override
  String get communitySortVotes => 'Paling disukai';

  @override
  String communityStarLabel(int n) {
    return '$n bintang';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg dari 5 bintang';
  }

  @override
  String get communityStatusFull => 'Penuh';

  @override
  String get communityStatusInGame => 'Sedang bertanding';

  @override
  String get communityStatusOpen => 'Mencari';

  @override
  String communityStoreOf(String date) {
    return 'Toko tanggal $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Ketuk bintang untuk menilai skin ini';

  @override
  String get communityTitle => 'Komunitas';

  @override
  String communityTooLong(int max) {
    return 'Maksimal $max karakter.';
  }

  @override
  String get communityTranslate => 'Terjemahkan dengan Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Untuk menerjemahkan dari $from ke $to, ValHub perlu mengunduh paket bahasa dari Google (sekitar $size). Cukup diunduh sekali; konten diterjemahkan sepenuhnya di perangkatmu dan tidak dikirim ke server mana pun.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Unduh paket bahasa di perangkat?';

  @override
  String get communityTranslateFailed => 'Gagal menerjemahkan. Coba lagi.';

  @override
  String get communityTranslatedByGoogle =>
      'Diterjemahkan otomatis oleh Google';

  @override
  String get communityTranslating => 'Menerjemahkan…';

  @override
  String get communityTrendingTitle => 'Skin paling disukai di seluruh dunia';

  @override
  String get communityUnavailableBody =>
      'Gagal terhubung ke Komunitas ValHub. Coba lagi dalam beberapa menit.';

  @override
  String get communityUnavailableTitle => 'Gagal terhubung ke Komunitas';

  @override
  String get communityUnhideAuthor => 'Tampilkan lagi / buka blokir';

  @override
  String get communityUnknownPlayer => 'Pemain';

  @override
  String get communityUnlike => 'Batal suka';

  @override
  String get communityUnvote => 'Hapus hati';

  @override
  String get communityVote => 'Beri hati untuk skin ini';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString suka';
  }

  @override
  String get communityWithdrawConfirm => 'Tarik';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub akan berhenti memakai Komunitas dengan $riotId: koneksi Komunitas di perangkat ini dihapus dan kamu kembali ke mode menjelajah anonim.\n\nPostingan, komentar, ulasan, suara, dan postingan cari rekan tim yang sudah kamu terbitkan tetap ada di Komunitas dan tetap menampilkan Riot ID-mu sampai kamu menghapusnya satu per satu, atau memilih \"Hapus data Komunitas saya\". Kamu bisa bergabung lagi kapan saja.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Tarik persetujuan?';

  @override
  String get communityWithdrawSubtitle =>
      'Berhenti memakai Komunitas dengan akun ini. Postinganmu tetap disimpan.';

  @override
  String get communityWithdrawTitle => 'Tarik persetujuan';

  @override
  String get communityWriteFirstReview => 'Tulis ulasan pertama';

  @override
  String get communityYou => 'Kamu';

  @override
  String get communityYourCountry => 'Negaramu';

  @override
  String get communityYourReview => 'Ulasanmu';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Kamu: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Pemilihan agen';

  @override
  String get liveGameAnonymous => 'Anonim';

  @override
  String get liveGameAutoRefreshNote =>
      'Dimuat ulang otomatis saat kamu sedang bertanding.';

  @override
  String get liveGameCurrentGame => 'Pertandingan saat ini';

  @override
  String get liveGameEmptyTeam => 'Belum ada pemain.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Tim musuh akan muncul saat pertandingan dimulai.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Tim musuh sudah mengunci $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Data pertandingan langsung ini tidak menyediakan Kill/Death/Assist. Papan skor muncul setelah Riot merilis data pasca-pertandingan.';

  @override
  String get liveGameFinalScoreboard => 'Papan skor akhir';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'Di lobi';

  @override
  String get liveGameInMatch => 'Sedang bertanding';

  @override
  String get liveGameInQueue => 'Dalam antrean';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Dalam antrean · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Level $n';
  }

  @override
  String get liveGameLiveScore => 'Skor langsung';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Loadout dari pemilihan agen';

  @override
  String get liveGameLoadoutFromMatch => 'Loadout di pertandingan ini';

  @override
  String get liveGameLobbyHint =>
      'Begitu pertandingan ditemukan, ValHub akan menampilkan susunan tim dan rank semua pemain.';

  @override
  String get liveGameLockedTag => 'Terkunci';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub akan mencoba lagi otomatis. Papan skor biasanya siap dalam sekitar satu menit.';

  @override
  String get liveGameNoAgentYet => 'Belum memilih agen';

  @override
  String get liveGameNoLoadout => 'Tidak ada info loadout untuk pemain ini.';

  @override
  String get liveGameNotInGame => 'Tidak sedang bertanding';

  @override
  String get liveGameNotInGameHint =>
      'Buka VALORANT dan masuk antrean — detail pertandingan akan muncul otomatis di sini begitu kamu masuk ke pemilihan agen.';

  @override
  String get liveGameNotInGameTitle => 'Kamu tidak sedang bertanding';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Lihat loadout $name';
  }

  @override
  String get liveGameOpenParty => 'Buka party & antrean';

  @override
  String get liveGameParty => 'Party';

  @override
  String liveGamePeak(String rank) {
    return 'Tertinggi: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Loadout $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Loadout';

  @override
  String get liveGameQueueHint =>
      'Biarkan aplikasi tetap terbuka — detail pertandingan muncul begitu pertandingan ditemukan.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Keluar dari pertandingan bisa membuatmu terkena penalti (kehilangan RR, pembatasan antrean). Tetap keluar?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Dodge saat pemilihan agen bisa membuatmu terkena penalti (kehilangan RR, pembatasan antrean). Tetap keluar?';

  @override
  String get liveGameQuitConfirmTitle => 'Keluar dari pertandingan?';

  @override
  String get liveGameQuitDone => 'Kamu sudah keluar dari pertandingan.';

  @override
  String get liveGameQuitFailed => 'Gagal keluar dari pertandingan.';

  @override
  String get liveGameQuitMatch => 'Keluar pertandingan';

  @override
  String get liveGameQuitMatchChanged =>
      'Pertandingan berpindah fase saat kamu mengonfirmasi. Kamu belum keluar; coba lagi.';

  @override
  String get liveGameRankUnavailable => 'Rank tidak diketahui';

  @override
  String get liveGameRefresh => 'Muat ulang';

  @override
  String liveGameRefreshIn(int seconds) {
    return 'Dimuat ulang dalam $seconds detik';
  }

  @override
  String get liveGameRefreshNow => 'Muat ulang sekarang';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Detail pertandingan';

  @override
  String get liveGameSprays => 'Spray';

  @override
  String get liveGameStatusAgentSelect => 'Pemilihan agen';

  @override
  String get liveGameStatusEnded => 'Selesai';

  @override
  String get liveGameStatusInProgress => 'Berlangsung';

  @override
  String get liveGameStatusUnavailable =>
      'Gagal memperbarui status pertandingan';

  @override
  String get liveGameTabAllPlayers => 'Pemain';

  @override
  String get liveGameTabEnemyTeam => 'Tim musuh';

  @override
  String get liveGameTabYourTeam => 'Timmu';

  @override
  String liveGameTimeLeft(String t) {
    return 'Sisa $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Lihat detail pertandingan';

  @override
  String get liveGameWeapons => 'Senjata';

  @override
  String get liveGameYou => 'KAMU';

  @override
  String liveGameYouHover(String agent) {
    return 'Kamu sedang memilih $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Kamu mengunci $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Pilih dan kunci agenmu di VALORANT. ValHub hanya menampilkan sisa waktu dan timmu.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws seri',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown pertandingan dengan hasil tidak diketahui',
      zero: '',
    );
    return '$wins menang – $losses kalah$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'waktu perangkat ($offset)';
  }

  @override
  String profileKillDescription(
    String killer,
    String victim,
    String hasWeapon,
    String weapon,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasWeapon, {
      'yes': ' dengan $weapon',
      'other': '',
    });
    return '$killer mengeliminasi $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 hari',
      'days7': '7 hari',
      'other': 'Sepanjang masa',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agen',
      'maps': 'Map',
      'queues': 'Mode',
      'sides': 'Menyerang / Bertahan',
      'trend': 'Tren',
      'other': 'Mode',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Semua mode';

  @override
  String get profileAbility => 'Skill';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n pertandingan';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Skor tempur rata-rata';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return 'Act ini: $wins menang / $games pertandingan · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Semua pemain';

  @override
  String get profileAlreadyReached => 'Kamu sudah mencapai rank ini.';

  @override
  String get profileAtCurrentForm => 'Dengan performa saat ini';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Dengan performa saat ini ($gain / $loss per pertandingan)';
  }

  @override
  String profileBestCase(int n) {
    return 'Terbaik: $n kemenangan beruntun';
  }

  @override
  String get profileByWinRateTitle => 'Berdasarkan win rate';

  @override
  String get profileChooseMap => 'Filter berdasarkan map';

  @override
  String get profileColA => 'A';

  @override
  String get profileColD => 'D';

  @override
  String get profileColK => 'K';

  @override
  String get profileColPlace => '#';

  @override
  String get profileColPlusMinus => '+/−';

  @override
  String get profileCopyRiotId => 'Salin Riot ID';

  @override
  String get profileCurrentRank => 'Saat ini';

  @override
  String get profileDailyRrEmpty =>
      'Belum ada pertandingan Competitive yang tersimpan di perangkat ini.';

  @override
  String get profileDailyRrFootnote =>
      'Riwayat RR disimpan langsung di perangkatmu, termasuk pertandingan yang sudah tidak ditampilkan lagi oleh Riot.';

  @override
  String get profileDailyRrTitle => 'RR harian';

  @override
  String profileDayBoundary(String zone) {
    return 'Hari dihitung berdasarkan $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return '$n hari bermain';
  }

  @override
  String get profileEndOfHistory => 'Semua pertandingan sudah ditampilkan';

  @override
  String get profileEnemyTeam => 'Tim musuh';

  @override
  String get profileFallDamage => 'Jatuh dari ketinggian';

  @override
  String get profileFilterAll => 'Semua';

  @override
  String get profileFirstBloods => 'First blood';

  @override
  String get profileFirstDeaths => 'Mati pertama';

  @override
  String get profileFirstHalf => 'Babak pertama';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS, dan HS% hanya dihitung untuk mode berbasis ronde.';

  @override
  String profileFormPending(int n) {
    return '$n pertandingan di daftar belum dimuat untuk statistik ini.';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR, dan HS% hanya menghitung $roundGames/$games pertandingan berbasis ronde';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '$games pertandingan terakhir: $w menang, $l kalah';
  }

  @override
  String get profileFriendsRow => 'Teman & chat';

  @override
  String get profileHideKills => 'Sembunyikan kill';

  @override
  String get profileHitBody => 'Badan';

  @override
  String get profileHitDistribution => 'Distribusi tembakan kena';

  @override
  String get profileHitHead => 'Kepala';

  @override
  String get profileHitLegs => 'Kaki';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint =>
      'Persentase ronde saat kamu mendapat kill, assist, bertahan hidup, atau dibalas oleh rekan tim';

  @override
  String get profileKd => 'K/D';

  @override
  String get profileKdaLabel => 'K/D/A';

  @override
  String profileKdaValue(int k, int d, int a) {
    return '$k/$d/$a';
  }

  @override
  String profileLastDays(int n) {
    return '$n hari terakhir';
  }

  @override
  String profileLastMatches(int n) {
    return '$n pertandingan terakhir';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Papan peringkat #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Level $n';
  }

  @override
  String get profileLevelHidden => 'Level disembunyikan';

  @override
  String profileLossStreak(int n) {
    return '$n kekalahan beruntun';
  }

  @override
  String profileMapFilter(String map) {
    return 'Map: $map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n pertandingan';
  }

  @override
  String get profileMatchDetailTitle => 'Detail pertandingan';

  @override
  String get profileMatchHistory => 'Riwayat pertandingan';

  @override
  String get profileMatchUnavailable => 'Gagal memuat pertandingan';

  @override
  String get profileMatchesNeeded => 'Pertandingan yang dibutuhkan';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Belum pernah ranked';

  @override
  String get profileNoKillsInRound => 'Belum ada info kill di ronde ini.';

  @override
  String get profileNoMatches => 'Belum ada pertandingan.';

  @override
  String get profileNoMatchesMap =>
      'Tidak ada pertandingan di map ini dari pertandingan yang sudah dimuat.';

  @override
  String get profileNoMatchesQueue => 'Tidak ada pertandingan di mode ini.';

  @override
  String get profileNoPlayers =>
      'Belum ada info pemain untuk pertandingan ini.';

  @override
  String get profileNoRounds =>
      'Belum ada info per ronde untuk pertandingan ini.';

  @override
  String get profileOvertime => 'Overtime';

  @override
  String get profilePlayHubTitle => 'Pertandingan & party';

  @override
  String get profilePeakRank => 'Tertinggi';

  @override
  String get profilePerformanceAttack => 'Menyerang';

  @override
  String get profilePerformanceDefense => 'Bertahan';

  @override
  String get profilePerformanceEmpty =>
      'Belum ada pertandingan yang tercatat di perangkat ini. Buka riwayat pertandingan untuk mencatat pertandingan yang sudah kamu mainkan.';

  @override
  String get profilePerformanceNoMatches =>
      'Tidak ada pertandingan dalam rentang waktu yang dipilih.';

  @override
  String profilePerformanceRounds(int n) {
    return '$n ronde tercatat';
  }

  @override
  String get profilePerformanceSample =>
      'Persentase hanya muncul jika ada minimal 3 pertandingan. ACS, ADR, HS%, dan K/D hanya menghitung mode berbasis ronde.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Sisi menyerang atau bertahan teridentifikasi di $known/$total ronde.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Riwayat di perangkat ini, sejak $date';
  }

  @override
  String get profilePerformanceTitle => 'Performa';

  @override
  String profilePlacement(int n) {
    return 'Peringkat $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike dipasang di $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Profil pemain';

  @override
  String get profilePlayerSummary => 'Performa';

  @override
  String profileProgressTo(String rank) {
    return 'Progres menuju $rank';
  }

  @override
  String get profileProgressToTarget => 'Progres menuju rank target';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Perkiraan berdasarkan pertandingan Competitive terbaru; belum memperhitungkan pertandingan penempatan atau perlindungan turun rank.';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches pertandingan untuk mencapai $rank';
  }

  @override
  String get profileRankUpImmortal =>
      'Kamu sudah Immortal atau lebih tinggi — fitur ini hanya menghitung sampai Immortal 1.';

  @override
  String get profileRankUpNoForm =>
      'Belum ada pertandingan Competitive terbaru untuk memperkirakan performamu.';

  @override
  String get profileRankUpOpen => 'Buka kalkulator naik rank';

  @override
  String get profileRankUpTitle => 'Kalkulator naik rank';

  @override
  String get profileRankUpUnranked =>
      'Selesaikan pertandingan penempatan untuk memakai kalkulator naik rank.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Papan skor Competitive';

  @override
  String profileRecentForm(int w, int l) {
    return 'Performa terbaru: $w menang – $l kalah';
  }

  @override
  String get profileRecentFormTitle => 'Performa terbaru';

  @override
  String get profileRecentMatches => 'Pertandingan terbaru';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}M · ${l}K · ${d}S',
      zero: '${w}M · ${l}K',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID disalin';

  @override
  String profileRound(int n) {
    return 'Ronde $n';
  }

  @override
  String profileRoundKills(int n) {
    return '$n kill';
  }

  @override
  String get profileRoundLost => 'Kalah ronde';

  @override
  String get profileRoundTimeline => 'Jalannya ronde';

  @override
  String get profileRoundWon => 'Menang ronde';

  @override
  String get profileRoundsHint => 'Ketuk ronde untuk melihat setiap kill.';

  @override
  String profileRrLeft(String n) {
    return 'Kurang $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Tren RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Papan skor';

  @override
  String get profileSecondHalf => 'Babak kedua';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Lihat kill';

  @override
  String get profileSideSwitch => 'Ganti sisi';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Rank target';

  @override
  String get profileTeamBlue => 'Tim Biru';

  @override
  String get profileTeamMvp => 'MVP tim';

  @override
  String get profileTeamRed => 'Tim Merah';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileToday(String text) {
    return 'Hari ini: $text';
  }

  @override
  String get profileTodayNone => 'Belum ada pertandingan Competitive hari ini';

  @override
  String get profileTruePeakLocal => 'Berdasarkan riwayat di perangkat ini';

  @override
  String get profileWeekdayShortItem0 => 'Sen';

  @override
  String get profileWeekdayShortItem1 => 'Sel';

  @override
  String get profileWeekdayShortItem2 => 'Rab';

  @override
  String get profileWeekdayShortItem3 => 'Kam';

  @override
  String get profileWeekdayShortItem4 => 'Jum';

  @override
  String get profileWeekdayShortItem5 => 'Sab';

  @override
  String get profileWeekdayShortItem6 => 'Min';

  @override
  String get profileWinRate => 'Win rate';

  @override
  String profileWinStreak(int n) {
    return '$n kemenangan beruntun';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Rank-mu';

  @override
  String get profileYourSummary => 'Performamu';

  @override
  String get profileYourTeam => 'Timmu';

  @override
  String get profileYourWinRate => 'Win rate terbarumu';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Mode: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filter menurut mode';

  @override
  String get profilePerformancePerMatchTitle => 'Per pertandingan';

  @override
  String get profilePerformancePerMatchHint =>
      'Ketuk batang untuk membuka pertandingan itu.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Rata-rata $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Butuh minimal 2 pertandingan berbasis ronde dengan statistik ini untuk menampilkan grafik.';

  @override
  String get profilePerformanceOpeningsTitle => 'Duel pembuka';

  @override
  String get profilePerformanceOpeningWin => 'Menang duel pembuka';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Dari ronde saat kamu mendapat kill pertama atau mati pertama, persentase kamu yang mendapat kill.';

  @override
  String get profilePerformanceFirstBloodsPerGame =>
      'First blood per pertandingan';

  @override
  String get profilePerformanceFirstDeathsPerGame =>
      'Mati pertama per pertandingan';

  @override
  String get profilePerformanceMultiKillsTitle => 'Multi-kill dalam satu ronde';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 kill',
      'k4': '4 kill',
      'ace': 'Ace',
      'other': '2 kill',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceMultiKillsNote(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Dihitung dari $nString pertandingan dengan data kill lengkap.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Menang ronde';

  @override
  String get profilePerformanceDrillHint =>
      'Ketuk baris untuk melihat agen, map, atau mode itu saja.';

  @override
  String get profilePerformanceLoadOlder => 'Analisis pertandingan lama';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub hanya menganalisis pertandingan yang sudah dibuka di perangkat ini. Setiap ketukan menambahkan hingga $nString pertandingan yang lebih lama.';
  }

  @override
  String get profilePerformanceSearchingOlder =>
      'Mencari pertandingan yang lebih lama…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Menganalisis pertandingan $doneString/$totalString…';
  }

  @override
  String profilePerformanceAddedOlder(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString pertandingan ditambahkan ke analisis.',
      zero: 'Tidak ada pertandingan baru untuk ditambahkan.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot tidak lagi menyimpan pertandingan yang lebih lama.';

  @override
  String get profileEconomyTitle => 'Ekonomi timmu';

  @override
  String get profileEconomyHint =>
      'Jenis pembelian dihitung dari total nilai perlengkapan timmu di awal ronde (konvensi vlr.gg untuk 5 pemain): Eco di bawah 5.000, Semi-eco di bawah 10.000, Semi-buy di bawah 20.000, Full buy mulai 20.000 kredit. Ronde pertama tiap babak adalah Pistol.';

  @override
  String profileBuyType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'pistol': 'Pistol',
      'eco': 'Eco',
      'semiEco': 'Semi-eco',
      'semiBuy': 'Semi-buy',
      'fullBuy': 'Full buy',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String profileEconomyWon(int won, int played) {
    final intl.NumberFormat wonNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String wonString = wonNumberFormat.format(won);
    final intl.NumberFormat playedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String playedString = playedNumberFormat.format(played);

    return 'Menang $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'Teman setia VALORANT-mu: toko harian, wishlist, rank, pertandingan, banyak akun, dan komunitas pemain, langsung di perangkatmu.';

  @override
  String get legalBackToTop => 'Kembali ke atas';

  @override
  String get legalConsentAnd => ' dan ';

  @override
  String get legalConsentPrefix => 'Dengan melanjutkan, kamu menyetujui ';

  @override
  String get legalConsentPrivacy => 'Kebijakan Privasi';

  @override
  String get legalConsentSuffix => ' ValHub.';

  @override
  String get legalConsentTerms => 'Ketentuan Penggunaan';

  @override
  String get legalContact => 'Kontak';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'KONTAK';

  @override
  String legalEffectiveFrom(String date) {
    return 'Berlaku sejak $date';
  }

  @override
  String get legalLegalHeader => 'LEGAL';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Hak cipta dilindungi undang-undang.';

  @override
  String get legalThirdPartyLicenses => 'Perangkat lunak pihak ketiga';

  @override
  String get legalThirdPartyLicensesBody =>
      'Lisensi perangkat lunak open source yang digunakan ValHub';

  @override
  String get legalTocTitle => 'DAFTAR ISI';

  @override
  String legalVersion(String version) {
    return 'Versi $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Dokumen ini saat ini ditampilkan dalam $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Gagal membaca dokumen legal. Coba lagi atau hubungi dukungan.';

  @override
  String get legalTranslationNotice =>
      'Terjemahan ini disediakan untuk kemudahan. Jika ada perbedaan, versi bahasa Vietnam yang berlaku.';

  @override
  String get settingsUiLanguageTitle => 'Bahasa aplikasi';

  @override
  String get settingsLanguageFollowDevice => 'Ikuti bahasa perangkat';

  @override
  String get settingsLanguageSaveFailed =>
      'Gagal menyimpan bahasa. Silakan coba lagi.';

  @override
  String get settingsGeoCountry => 'Negara';

  @override
  String get settingsGeoSearchCountry => 'Cari nama atau kode negara';

  @override
  String get settingsGeoSupportedOnly => 'Hanya yang sudah pasti didukung';

  @override
  String get settingsGeoUnknown => 'Dukungan belum diverifikasi';

  @override
  String get settingsGeoRestricted => 'Dibatasi';

  @override
  String get settingsGeoSeparate => 'Layanan terpisah';

  @override
  String get settingsGeoAvailable => 'Didukung';

  @override
  String get settingsGeoNotApplicable => 'Tidak berlaku';

  @override
  String get settingsGeoConnection => 'Koneksi Riot';

  @override
  String get settingsGeoChooseRegion => 'Pilih region';

  @override
  String get settingsGeoAuto => 'Otomatis dari akun';

  @override
  String get settingsGeoManual => 'Pilih manual';

  @override
  String get settingsGeoNoRegion => 'Region Riot kamu belum terdeteksi';

  @override
  String get settingsGeoManualWarning =>
      'Pilihan ini hanya mengubah server yang dihubungkan ValHub. Region akun Riot-mu tidak akan dipindahkan. ValHub akan memeriksa koneksi sebelum menyimpan.';

  @override
  String get settingsGeoConnectionSaved => 'Koneksi disimpan';

  @override
  String get settingsGeoValidationFailed =>
      'Akunmu tidak bisa dikonfirmasi di server ini. Pilih region lagi.';

  @override
  String get settingsGeoHintOnly =>
      'Negara hanya dipakai untuk pencarian dan saran. Region koneksi mengikuti akun Riot-mu.';

  @override
  String get settingsGeoSave => 'Periksa dan simpan';

  @override
  String get settingsGeoCancel => 'Batal';

  @override
  String get settingsGeoLoading => 'Memeriksa koneksi…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Pilihan ini dipakai untuk nama negara, saran, dan perkiraan harga VP. Koneksi server dan negara akun Komunitas tetap ditentukan oleh Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'Pakai negara akun atau perangkat';

  @override
  String get settingsGeoSaveFailed => 'Gagal menyimpan pilihan. Coba lagi.';

  @override
  String get settingsGeoAllRegions => 'Semua region';

  @override
  String get settingsGeoSuggestions => 'Saran';

  @override
  String get settingsGeoNoCountries =>
      'Tidak ada negara yang cocok dengan filter.';

  @override
  String get settingsGeoActiveCountries => 'Aktif';

  @override
  String get settingsGeoAllCountries => 'Semua negara';

  @override
  String get settingsGeoActivityUnavailable =>
      'Gagal memuat aktivitas negara. Kamu tetap bisa memilih dari Semua negara.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count negara',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Kamu memilih $manual, tapi Riot menempatkan akunmu di $detected. Lanjutkan pemeriksaan koneksi ini?';
  }

  @override
  String get settingsGeoUnverified =>
      'Koneksi belum bisa diverifikasi karena server atau jaringan sedang bermasalah. Simpan pilihan ini dan coba lagi nanti?';

  @override
  String get settingsGeoContinue => 'Lanjutkan';

  @override
  String settingsGeoMismatch(String region) {
    return 'Koneksi manual berbeda dari region Riot-mu: $region. Beralih ke otomatis?';
  }

  @override
  String get settingsGeoUseAuto => 'Pakai otomatis';

  @override
  String get settingsGeoKeepManual => 'Tetap manual';

  @override
  String get settingsGeoReviewConnection => 'Lihat koneksi';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Terakhir diperiksa: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Periksa lagi';

  @override
  String get settingsPlatformMobile => 'Seluler';

  @override
  String get settingsPlatformOther => 'Platform lain';

  @override
  String get settingsContentLanguageFollowApp => 'Sama dengan bahasa aplikasi';

  @override
  String get settingsContentLanguageHint =>
      'Pilih bahasa untuk nama item. Pilihan ini tidak mengubah bahasa aplikasi atau server Riot-mu.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Bahasa: $language.';
  }

  @override
  String get settingsAboutHeader => 'INFO';

  @override
  String get settingsAboutRowSubtitle =>
      'Privasi, ketentuan, hak cipta, dan kontak';

  @override
  String get settingsAboutTitle => 'Tentang & legal';

  @override
  String get settingsAppHeader => 'LANJUTAN';

  @override
  String get settingsAppearanceHeader => 'TAMPILAN';

  @override
  String settingsBuildNumber(String build) {
    return 'Build $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '$size dihapus';
  }

  @override
  String get settingsClearCache => 'Hapus data sementara';

  @override
  String get settingsClearCacheFailed =>
      'Gagal menghapus data sementara. Coba lagi.';

  @override
  String get settingsClearCacheSubtitle =>
      'Gambar dan data yang diunduh ke perangkatmu, termasuk laporan bug yang tercatat';

  @override
  String get settingsExportLog => 'Kirim laporan bug ke ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Belum ada yang bisa dikirim. Pakai aplikasi sebentar lalu coba lagi.';

  @override
  String get settingsExportLogSubtitle =>
      'Laporan bug tidak berisi kata sandi atau data login Riot-mu.';

  @override
  String get settingsFeedback => 'Kirim masukan ke ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Buka halaman masukan ValHub';

  @override
  String get settingsItemLanguageEn => 'Bahasa Inggris';

  @override
  String get settingsItemLanguageLabel => 'Nama item';

  @override
  String get settingsItemLanguagePickerTitle => 'Bahasa nama item';

  @override
  String get settingsItemLanguageVi => 'Bahasa Vietnam';

  @override
  String get settingsLinkOpenFailed => 'Gagal membuka tautan. Coba lagi.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Laporan bug';
  }

  @override
  String get settingsLogShareFailed => 'Gagal mengirim laporan bug. Coba lagi.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Saat Night Market dibuka';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Mengingatkanmu untuk membuka kartu penawaran Night Market';

  @override
  String get settingsNotifPermissionMissing =>
      'Aplikasi belum punya izin untuk mengirim notifikasi.';

  @override
  String get settingsNotifStoreReset => 'Saat toko diperbarui';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Setiap hari pukul $time';
  }

  @override
  String get settingsNotifWishlist => 'Saat skin di wishlist muncul';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Memeriksa toko di semua akun, bahkan saat aplikasi ditutup';

  @override
  String get settingsNotificationsHeader => 'NOTIFIKASI';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Buka detail pertandingan otomatis';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Buka panel pertandingan saat ini begitu pertandingan ditemukan';

  @override
  String get settingsOptionOwnPrice => 'Harga paket VP-mu';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Belum diisi — memakai daftar harga regionmu jika ada';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Platform';

  @override
  String get settingsOptionShowLiveScore => 'Tampilkan skor langsung';

  @override
  String get settingsOptionShowPeakRank =>
      'Tampilkan rank tertinggi di detail pertandingan';

  @override
  String get settingsOptionShowPrice => 'Tampilkan perkiraan harga';

  @override
  String get settingsOptionShowPriceInfo => 'Cara kerja perkiraan harga';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Di samping harga VP, contoh $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Belum ada daftar harga terverifikasi untuk regionmu — masukkan harga paket VP-mu.';

  @override
  String get settingsOptionsHeader => 'OPSI';

  @override
  String get settingsPhaseComplete => 'Selesai';

  @override
  String get settingsPhaseInProgress => 'Berlangsung';

  @override
  String get settingsPhaseScheduled => 'Terjadwal';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Berlaku untuk $account';
  }

  @override
  String get settingsPlatformHint =>
      'Pilih PC, PlayStation, atau Xbox sesuai tempatmu bermain untuk melihat riwayat pertandingan yang benar.';

  @override
  String get settingsPlatformPickerTitle => 'Pilih platform';

  @override
  String get settingsPrimingBody =>
      'Aktifkan notifikasi untuk tahu kapan tokomu diperbarui dan kapan skin di wishlist muncul.';

  @override
  String get settingsPrimingEnable => 'Aktifkan notifikasi';

  @override
  String get settingsPrimingFootnote =>
      'Kamu bisa mengaktifkan atau menonaktifkan tiap jenis notifikasi kapan saja di Pengaturan.';

  @override
  String get settingsPrimingLater => 'Nanti';

  @override
  String get settingsPrimingPointNightMarket =>
      'Tahu kapan Night Market dibuka';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Agar sempat membuka kartu penawaran sebelum kedaluwarsa';

  @override
  String get settingsPrimingPointStore =>
      'Pengingat saat toko harian diperbarui';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Mengingatkanmu setelah toko akunmu diperbarui';

  @override
  String get settingsPrimingPointWishlist =>
      'Pemberitahuan saat skin incaranmu muncul';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Memeriksa toko di semua akun, bahkan saat aplikasi ditutup';

  @override
  String get settingsPrimingTitle => 'Jangan lewatkan skin incaranmu';

  @override
  String settingsRemovedAccount(String account) {
    return '$account dihapus';
  }

  @override
  String get settingsServerStatus => 'Status server';

  @override
  String get settingsServerStatusMaintenance => 'Sedang pemeliharaan';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n pemberitahuan';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Pemeliharaan dan gangguan VALORANT per server';

  @override
  String get settingsSessionLogTitle => 'Laporan bug ValHub';

  @override
  String get settingsSeverityCritical => 'Kritis';

  @override
  String get settingsSeverityInfo => 'Info';

  @override
  String get settingsSeverityWarning => 'Peringatan';

  @override
  String get settingsSignedOutAll => 'Sudah logout dari semua akun';

  @override
  String get settingsStatusAllGood => 'Server berjalan normal';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Tidak ada gangguan atau pemeliharaan di server $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Tampilkan lebih sedikit';

  @override
  String get settingsStatusIssues => 'Riot sedang menangani gangguan';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'Server ini punya $n pemberitahuan gangguan.';
  }

  @override
  String get settingsStatusKindIncident => 'Gangguan';

  @override
  String get settingsStatusKindMaintenance => 'Pemeliharaan';

  @override
  String get settingsStatusMaintenanceNow => 'Server sedang pemeliharaan';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Kamu mungkin belum bisa bermain sekarang, dan ValHub mungkin untuk sementara tidak bisa memuat info.';

  @override
  String settingsStatusMoreUpdates(int n) {
    return 'Tampilkan $n pembaruan lagi';
  }

  @override
  String get settingsStatusScheduled => 'Pemeliharaan akan datang';

  @override
  String settingsStatusScheduledBody(int n) {
    return '$n jadwal pemeliharaan sudah diumumkan oleh Riot.';
  }

  @override
  String get settingsStatusSourceNote =>
      'Sumber: halaman status resmi Riot Games. Waktu ditampilkan sesuai zona waktu perangkatmu.';

  @override
  String settingsStatusStarted(String when) {
    return 'Dimulai $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Diperbarui $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'PEMBARUAN DARI RIOT';

  @override
  String get settingsSupportHeader => 'DUKUNGAN';

  @override
  String settingsSwitchedTo(String account) {
    return 'Beralih ke $account';
  }

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemePickerTitle => 'Pilih tema';

  @override
  String get settingsThemeSystem => 'Ikuti sistem';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String settingsVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rank, riwayat pertandingan, pertandingan langsung';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR per pertandingan, rank lawan';

  @override
  String get settingsWelcomeBulletStore =>
      'Toko harian, Night Market, dan bundle';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Harga, kelangkaan, hitung mundur reset';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist & notifikasi';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Dapat pemberitahuan saat skin incaranmu muncul di toko';

  @override
  String get settingsWelcomeFootnote =>
      'Kamu login di halaman resmi Riot. ValHub hanya menyimpan kata sandimu jika kamu memilih untuk menyimpan info login.';

  @override
  String get settingsWelcomeKicker => 'TEMAN SETIA VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average ($count penilaian) · ',
      'other': '',
    });
    return 'Komunitas: $_temp0$votes suka';
  }

  @override
  String get skinDetailAddToWishlist => 'Tambah ke wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Ada di toko: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return 'Di tokomu: $daily kali di toko harian, $night kali di Night Market. Hanya menghitung data di perangkat ini, dicatat sejak $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Hapus riwayat toko';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Hapus semua hari toko yang tercatat untuk akun ini di perangkat ini?';

  @override
  String get skinDetailInWishlist => 'Ada di wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Terkunci';

  @override
  String get skinDetailMute => 'Bisukan';

  @override
  String get skinDetailNotFound => 'Skin ini tidak ditemukan.';

  @override
  String get skinDetailOwned => 'Dimiliki';

  @override
  String get skinDetailPause => 'Jeda';

  @override
  String get skinDetailPlay => 'Putar';

  @override
  String get skinDetailPlayVideo => 'Tonton video';

  @override
  String get skinDetailRemoveFromWishlist => 'Hapus dari wishlist';

  @override
  String get skinDetailTitle => 'Detail skin';

  @override
  String get skinDetailUnmute => 'Bunyikan';

  @override
  String get skinDetailUpgrades => 'Upgrade';

  @override
  String get skinDetailVariants => 'Varian';

  @override
  String get skinDetailVideoError =>
      'Gagal memutar video. Periksa koneksimu lalu coba lagi.';

  @override
  String get socialPresenceInMatch => 'Sedang bertanding';

  @override
  String get socialPresenceAgentSelect => 'Sedang memilih agen';

  @override
  String get socialPresenceQueue => 'Dalam antrean';

  @override
  String get socialPresenceLobby => 'Di lobi';

  @override
  String get socialPresenceCustom => 'Di Game Custom';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Party terbuka',
      'other': 'Hanya undangan',
    });
    return '$size/$max pemain · $_temp0';
  }

  @override
  String get socialAccept => 'Terima';

  @override
  String get socialAcceptInGame => 'Terima undangan ini di dalam game.';

  @override
  String socialActionFailed(String message) {
    return 'Gagal menyelesaikan tindakan. $message';
  }

  @override
  String get socialAutoRefresh => 'Muat ulang otomatis';

  @override
  String get socialAway => 'Sedang pergi';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Batalkan antrean · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Batalkan antrean';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Party-mu belum bisa masuk antrean $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Ganti antrean';

  @override
  String get socialChatUnavailable => 'Chat sedang offline.';

  @override
  String get socialCloseParty => 'Tutup party';

  @override
  String get socialCodeInvalid => 'Kode party hanya berisi huruf dan angka.';

  @override
  String get socialConnecting => 'Menghubungkan ke chat…';

  @override
  String get socialCopyCode => 'Salin';

  @override
  String get socialCurrentQueue => 'Dipilih';

  @override
  String get socialCustomGameLobby => 'Party-mu sedang di lobi Game Custom.';

  @override
  String get socialDecline => 'Tolak';

  @override
  String get socialDisableCode => 'Nonaktifkan kode';

  @override
  String get socialEmptyChat => 'Belum ada pesan. Sapa duluan!';

  @override
  String get socialEmptyChatTitle => 'Mulai mengobrol';

  @override
  String get socialFailedBadge => 'Belum terkirim';

  @override
  String get socialFilterAll => 'Semua';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Belum dibaca';

  @override
  String get socialFriendsPrivacyNote =>
      'Daftar teman dan pesanmu diambil langsung dari Riot. ValHub tidak menyimpannya di tempat lain.';

  @override
  String socialFriendsSummary(int total, int online) {
    return '$total teman · $online online';
  }

  @override
  String get socialFriendsTitle => 'Teman & chat';

  @override
  String get socialGameNotRunningBody =>
      'Party & antrean hanya berfungsi saat VALORANT berjalan di PC atau konsolmu. Buka game, lalu tarik ke bawah untuk memuat ulang.';

  @override
  String get socialGameNotRunningTitle => 'Buka VALORANT di PC atau konsolmu';

  @override
  String get socialGenerateCode => 'Buat kode';

  @override
  String get socialIdleQueue => 'Siap masuk antrean';

  @override
  String get socialInMatchBanner =>
      'Kamu sedang bertanding. Antrean akan dibuka lagi setelah pertandingan selesai.';

  @override
  String get socialInValorant => 'Di VALORANT';

  @override
  String get socialInviteByRiotId => 'Undang dengan Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Undang pemain yang belum jadi temanmu';

  @override
  String get socialInviteFriends => 'Undang teman';

  @override
  String socialInviteFrom(String name) {
    return 'Undangan dari $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Undang $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Riot ID pemain ini belum diketahui, jadi belum bisa diundang.';

  @override
  String socialInviteSent(String name) {
    return 'Undangan dikirim ke $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Diundang';
  }

  @override
  String get socialInvitesSection => 'Undangan';

  @override
  String get socialJoin => 'Gabung';

  @override
  String get socialJoinConfirmBody =>
      'Kamu akan keluar dari party saat ini untuk bergabung ke party dengan kode ini.';

  @override
  String get socialJoinConfirmTitle => 'Gabung ke party lain?';

  @override
  String get socialJoinSection => 'Gabung ke party lain';

  @override
  String get socialJoinWithCode => 'Masukkan kode untuk bergabung';

  @override
  String get socialJoined => 'Berhasil bergabung ke party.';

  @override
  String socialLastOnline(String relative) {
    return 'Aktif $relative';
  }

  @override
  String get socialLeader => 'Leader';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Kamu akan keluar dari party saat ini dan kembali ke party solo.';

  @override
  String get socialLeaveConfirmTitle => 'Keluar dari party?';

  @override
  String get socialLeaveParty => 'Keluar party';

  @override
  String socialLevel(int n) {
    return 'Level $n';
  }

  @override
  String get socialMatchFound => 'Pertandingan ditemukan!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Anggota ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Ketik pesan…';

  @override
  String get socialMoreActions => 'Opsi lainnya';

  @override
  String get socialNoCode =>
      'Buat kode agar teman bisa cepat bergabung ke party-mu.';

  @override
  String get socialNoCodeMember =>
      'Leader party bisa membuat kode untuk undangan cepat.';

  @override
  String get socialNoFilterResults =>
      'Tidak ada teman yang cocok dengan filter ini.';

  @override
  String get socialNoFriends =>
      'Daftar teman Riot-mu masih kosong. Tambahkan teman di dalam game.';

  @override
  String get socialNoFriendsTitle => 'Belum ada teman';

  @override
  String get socialNoOnlineFriends =>
      'Belum ada temanmu yang online di VALORANT saat ini.';

  @override
  String get socialNoSearchResults => 'Tidak ada teman yang cocok.';

  @override
  String get socialNoSearchResultsTitle => 'Tidak ditemukan';

  @override
  String get socialNotReady => 'Belum siap';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online di ponsel';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Hanya leader party yang bisa mengganti antrean dan mulai mencari pertandingan.';

  @override
  String get socialOpenParty => 'Buka party';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Kode party';

  @override
  String socialPartyCodeValue(String code) {
    return 'Kode party: $code';
  }

  @override
  String get socialPartyInvite => 'Undangan party';

  @override
  String socialPartyOf(int size, int max) {
    return 'Party $size/$max';
  }

  @override
  String get socialPartyTitle => 'Party & antrean';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'Party $size pemain';
  }

  @override
  String get socialPickQueueTitle => 'Pilih antrean';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Ping terbaik ke server pertandingan';

  @override
  String socialPlayingOther(String game) {
    return 'Sedang main $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Sedang main ($n)';
  }

  @override
  String get socialQueueLabel => 'Antrean';

  @override
  String get socialQueueLocked =>
      'Kamu tidak bisa mengganti antrean saat sedang bertanding.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Maksimal $max pemain',
      one: 'Hanya solo',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Status game-mu belum bisa diverifikasi. Muat ulang untuk memakai siap dan antrean.';

  @override
  String get socialReady => 'Siap';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Siap $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'ada anggota yang level akunnya belum cukup';

  @override
  String get socialReasonGeneric => 'party belum memenuhi syarat';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'party terlalu besar (maksimal $max pemain)';
  }

  @override
  String get socialReasonRankDisparity =>
      'selisih rank terlalu jauh untuk Competitive';

  @override
  String socialReasonRestricted(String time) {
    return 'party sedang dibatasi untuk masuk antrean (sisa $time)';
  }

  @override
  String get socialReconnecting =>
      'Koneksi chat terputus. Menyambungkan ulang…';

  @override
  String get socialRemoteNote =>
      'Perubahan hanya dikirim ke Riot saat kamu mengetuknya. ValHub tidak pernah masuk antrean atau mengunci agen untukmu.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name akan dikeluarkan dari party-mu.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Keluarkan dari party?';

  @override
  String get socialRemoveMember => 'Keluarkan dari party';

  @override
  String socialRequestFrom(String name) {
    return '$name ingin bergabung ke party';
  }

  @override
  String get socialRequestsSection => 'Permintaan bergabung';

  @override
  String get socialRiotIdFieldHint => 'Nama#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID terdiri dari nama (3–16 karakter), tanda # dan tag (3–5 huruf atau angka).';

  @override
  String get socialSearchHint => 'Cari berdasarkan Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'Dalam antrean · $elapsed';
  }

  @override
  String get socialSend => 'Kirim';

  @override
  String get socialSendFailed =>
      'Gagal mengirim pesan. Periksa koneksimu lalu coba lagi.';

  @override
  String get socialSendInvite => 'Kirim undangan';

  @override
  String get socialShareCode => 'Bagikan';

  @override
  String socialShareCodeText(String code) {
    return 'Gabung ke party VALORANT-ku dengan kode: $code';
  }

  @override
  String get socialShootingRange => 'Di Area Berlatih';

  @override
  String get socialShowEveryone => 'Lihat semua';

  @override
  String get socialStartQueue => 'Mulai antrean';

  @override
  String get socialSuggestionsItem0 => 'Halo!';

  @override
  String get socialSuggestionsItem1 => 'Main beberapa game yuk?';

  @override
  String get socialSuggestionsItem2 => 'Ayo gabung ke party-ku!';

  @override
  String socialUnread(int n) {
    return '$n pesan belum dibaca';
  }

  @override
  String get socialUnready => 'Batal siap';

  @override
  String get socialViewProfile => 'Lihat profil';

  @override
  String get socialWaitingForConnection =>
      'Menghubungkan… Kamu bisa mengirim pesan setelah terhubung.';

  @override
  String get socialYou => 'Kamu';

  @override
  String get socialPartyUnavailable =>
      'Gagal menyinkronkan party-mu. Muat ulang untuk mencoba lagi.';

  @override
  String get storeAccessoryEmpty => 'Toko aksesori sedang kosong.';

  @override
  String get storeAccessoryEmptyTitle => 'Belum ada aksesori';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Dari: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Diperbarui dalam $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Diperbarui pada $wall';
  }

  @override
  String get storeAddToWishlist => 'Tambah ke wishlist';

  @override
  String get storeBackToBundles => 'Lihat bundle yang dijual';

  @override
  String get storeBundleBuySeparateLabel => 'Beli satuan';

  @override
  String get storeBundleDetailTitle => 'Detail bundle';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Berakhir pada $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Sisa $t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n item';
  }

  @override
  String get storeBundleItemFree => 'Gratis';

  @override
  String get storeBundleItemsTitle => 'Item dalam bundle';

  @override
  String get storeBundleNotFound =>
      'Bundle ini tidak ditemukan. Mungkin sudah berakhir.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle sudah berakhir';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Dimiliki $owned/$total item';
  }

  @override
  String get storeBundlePriceLabel => 'Harga bundle';

  @override
  String get storeBundleSavingsLabel => 'Hemat';

  @override
  String get storeBundleWholesaleOnly =>
      'Hanya dijual satu bundle penuh, tidak bisa dibeli satuan.';

  @override
  String get storeBundlesEmpty => 'Sedang tidak ada bundle yang dijual.';

  @override
  String get storeBundlesEmptyTitle => 'Belum ada bundle';

  @override
  String get storeDailyEmpty => 'Tidak ada skin di toko hari ini.';

  @override
  String get storeDailyEmptyTitle => 'Toko kosong';

  @override
  String storeDailyResetAt(String time) {
    return 'Diperbarui setiap hari pukul $time';
  }

  @override
  String get storeDailyTotalLabel => 'Total';

  @override
  String get storeNightMarketEmpty => 'Sedang tidak ada Night Market.';

  @override
  String get storeNightMarketEmptyTitle => 'Night Market belum dibuka';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Berakhir pada $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Berakhir dalam $t';
  }

  @override
  String get storeNightMarketNote =>
      'Penawaran Night Market khusus untuk akunmu dan tidak bisa diperbarui.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Total hemat $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Belum dibuka';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Dimiliki';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Dimiliki $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Hapus dari wishlist';

  @override
  String get storeResetNotificationTitle => 'Tokomu sudah diperbarui';

  @override
  String storeResetsIn(String t) {
    return 'Diperbarui dalam $t';
  }

  @override
  String get storeSegmentAccessories => 'Aksesori';

  @override
  String get storeSegmentBundles => 'Bundle';

  @override
  String get storeSegmentDaily => 'Harian';

  @override
  String get storeSegmentNightMarket => 'Night Market';

  @override
  String get storeShareButton => 'Bagikan';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Toko hari ini';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Night Market';

  @override
  String get storeShareCardPriceNote =>
      'Harga konversi hanya perkiraan berdasarkan paket VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Hemat $vp';
  }

  @override
  String get storeShareCardTagline => 'Teman setia VALORANT-mu';

  @override
  String storeShareCardTotal(String vp) {
    return 'Total $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Sampai $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Bagikan toko hari ini';

  @override
  String get storeShareFailed => 'Gagal membuat gambar. Coba lagi.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Bagikan gambar';

  @override
  String get storeShareNightMarketTitle => 'Bagikan Night Market';

  @override
  String get storeSharePreparing => 'Memuat gambar skin…';

  @override
  String get storeShareShowPrice => 'Tampilkan perkiraan harga';

  @override
  String get storeShareShowPriceHint => 'Dihitung dari paket VP paling hemat.';

  @override
  String get storeShareShowRiotId => 'Tampilkan Riot ID di gambar';

  @override
  String get storeShareShowRiotIdHint =>
      'Nonaktif secara default untuk menjaga privasimu.';

  @override
  String get storeShareSubjectDaily => 'Toko VALORANT-ku hari ini';

  @override
  String get storeShareSubjectNightMarket => 'Night Market VALORANT-ku';

  @override
  String get storeShareSubtitle =>
      'Bagikan gambar tokomu ke teman lewat aplikasi pilihanmu.';

  @override
  String get storeTitle => 'Toko';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Saldo: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n di wishlist';
  }

  @override
  String get storeHistoryTitle => 'Riwayat toko';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString hari',
    );
    return 'Dicatat di perangkat ini sejak $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Belum ada hari yang tercatat. ValHub menyimpan toko harianmu setiap kali kamu membuka aplikasi, hanya di perangkat ini.';

  @override
  String get storeHistoryMostOffered => 'Paling sering muncul';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString kali',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryNightMarket(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Night Market · $countString penawaran',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryEntrySubtitle(int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString hari tercatat di perangkat ini',
      zero: 'Mulai dicatat hari ini',
    );
    return '$_temp0';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin ada di toko $account — sisa $left.',
      'other': '$skin ada di toko $account.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifNightMarketBody(
    String skin,
    String mode,
    String percent,
    String price,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'discount': '$skin diskon $percent%, sekarang $price ($account).',
      'price': '$skin hanya $price ($account).',
      'other': '$skin ada di Night Market $account.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifBundleBody(
    String skin,
    String hasName,
    String bundle,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasName, {
      'yes': '$skin ada di bundle $bundle ($account).',
      'other': '$skin ada di bundle yang sedang dijual ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names dan $more skin lainnya ada di toko $account.',
      zero: '$names ada di toko $account.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', ada di wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Tambah skin';

  @override
  String get wishlistAddToWishlist => 'Tambah ke wishlist';

  @override
  String get wishlistAllWeapons => 'Semua senjata';

  @override
  String get wishlistBrowseCatalog => 'Lihat semua skin';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Gagal memuat daftar skin. Muat ulang untuk mencoba lagi.';

  @override
  String get wishlistCatalogEmptyTitle => 'Belum ada skin';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '$count di wishlist';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Ketuk ♡ untuk menambahkan skin ke wishlist';

  @override
  String get wishlistCatalogTitle => 'Semua skin';

  @override
  String get wishlistChooseWeapon => 'Pilih senjata';

  @override
  String get wishlistClearFilters => 'Hapus filter';

  @override
  String get wishlistEmpty =>
      'Wishlist-mu kosong. Ketuk ♡ di skin mana pun untuk menambahkannya.';

  @override
  String get wishlistEmptyTitle => 'Belum ada skin';

  @override
  String wishlistEndsIn(String time) {
    return 'Berakhir dalam $time';
  }

  @override
  String get wishlistExcludedRewards => 'Tidak termasuk skin hadiah';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Difilter: $countString skin · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Tidak ada skin yang cocok. Hapus filter untuk melihat lebih banyak.';

  @override
  String get wishlistNoMatchTitle => 'Skin tidak ditemukan';

  @override
  String get wishlistNotifBundleTitle =>
      'Bundle baru berisi skin dari wishlist';

  @override
  String get wishlistNotifDailyTitle => 'Skin dari wishlist sudah muncul!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Night Market-mu punya skin incaranmu!';

  @override
  String get wishlistNotifPermissionMissing =>
      'Aplikasi belum punya izin untuk mengirim notifikasi.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return '$count skin dari wishlist sedang dijual!';
  }

  @override
  String get wishlistNotifToggle => 'Notifikasi wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Untuk akun ini, bahkan saat aplikasi ditutup';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skin dari wishlist sedang dijual!',
      one: 'Satu skin dari wishlist sedang dijual!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Ketuk baris yang ditandai untuk melihat penawarannya.';

  @override
  String get wishlistOpenSettings => 'Buka pengaturan';

  @override
  String get wishlistOwned => 'Dimiliki';

  @override
  String get wishlistRemoveAction => 'Hapus dari wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Hapus dari wishlist';

  @override
  String wishlistRemoved(String name) {
    return '$name dihapus dari wishlist';
  }

  @override
  String get wishlistSearchHint => 'Cari skin…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistSortName => 'Nama';

  @override
  String get wishlistSortPrice => 'Harga';

  @override
  String get wishlistSortRarity => 'Kelangkaan';

  @override
  String get wishlistSortWeapon => 'Senjata';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Total nilai wishlist';

  @override
  String get wishlistUndo => 'Urungkan';

  @override
  String get wishlistViewInStore => 'Lihat di toko';

  @override
  String get wishlistWeapon => 'Senjata';

  @override
  String get homeLiveScoreSeparator => 'VS';

  @override
  String homeOfferAccessibility(
    String name,
    String price,
    String tier,
    String wished,
  ) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', ada di wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', ada di wishlist',
      'other': '',
    });
    return '$name, $votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': 'naik',
      'other': 'turun',
    });
    return 'Hari ini $_temp0 $rr RR, $wins menang, $losses kalah';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws seri',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown pertandingan dengan hasil tidak diketahui',
      zero: '',
    );
    return '$wins menang – $losses kalah$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody =>
      'Buka Kustomisasi Beranda untuk menampilkannya lagi.';

  @override
  String get homeAllHiddenTitle => 'Kamu menyembunyikan semua kartu';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Level, XP yang dibutuhkan per hari, dan misi mingguan.';

  @override
  String get homeCardCommunity => 'Komunitas';

  @override
  String get homeCardCommunityDesc =>
      'Cari rekan tim yang sesuai rank-mu dan skin paling disukai komunitas.';

  @override
  String get homeCardFriends => 'Teman yang sedang main';

  @override
  String get homeCardFriendsDesc =>
      'Teman yang sedang bertanding atau dalam antrean.';

  @override
  String homeCardHidden(String name) {
    return '\"$name\" disembunyikan';
  }

  @override
  String get homeCardLive => 'Pertandingan saat ini';

  @override
  String get homeCardLiveDesc =>
      'Muncul saat kamu dalam antrean, di pemilihan agen, atau sedang bertanding.';

  @override
  String get homeCardOtherAccounts => 'Akun lain';

  @override
  String get homeCardOtherAccountsDesc =>
      'Status dan wishlist akun-akunmu yang lain.';

  @override
  String get homeCardRank => 'Rank & performa';

  @override
  String get homeCardRankDesc =>
      'Rank, RR hari ini, streak, dan jumlah pertandingan untuk naik rank.';

  @override
  String get homeCardServerStatus => 'Status server';

  @override
  String get homeCardServerStatusDesc =>
      'Hanya muncul saat ada pemeliharaan atau gangguan.';

  @override
  String get homeCardStore => 'Toko hari ini';

  @override
  String get homeCardStoreDesc => 'Skin harian, wishlist, dan Night Market.';

  @override
  String get homeCustomize => 'Kustomisasi Beranda';

  @override
  String get homeCustomizeHint =>
      'Seret untuk mengatur urutan. Nonaktifkan untuk menyembunyikan kartu.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Berpindah ke $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Aktifkan';

  @override
  String get homeFriendsConsentBody =>
      'Untuk melihat teman yang sedang main, ValHub akan terhubung ke chat Riot dari akun yang sedang dipakai setiap kali kamu membuka Beranda. Teman-temanmu akan melihatmu online. Kamu bisa menonaktifkannya di Kustomisasi Beranda.';

  @override
  String get homeFriendsConsentDecline => 'Tidak, sembunyikan kartu';

  @override
  String get homeFriendsConsentTitle => 'Lihat teman yang sedang main?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n teman sedang main';
  }

  @override
  String get homeFriendsSeeAll => 'Lihat semua';

  @override
  String get homeHideCard => 'Sembunyikan kartu ini';

  @override
  String homeLeaderboard(String pos) {
    return 'Peringkat #$pos di papan peringkat';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Sisa $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return 'Butuh $n pemain';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Cari rekan tim yang sesuai rank-mu';

  @override
  String get homeLiveAllyLabel => 'Timmu';

  @override
  String get homeLiveEnemyLabel => 'Tim musuh';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Dalam antrean, sudah menunggu $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Timmu $ally, tim musuh $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '$n kekalahan Competitive beruntun';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n pertandingan untuk mencapai $rank';
  }

  @override
  String homeMoreActions(String name) {
    return 'Opsi untuk $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Login lagi untuk memperbarui toko, rank, dan Battle Pass milik $riotId. Kamu tetap bisa melihat versi yang tersimpan di perangkatmu.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Sisa $time';
  }

  @override
  String get homeNightMarketNew => 'Baru';

  @override
  String get homeNightMarketTitle => 'Night Market';

  @override
  String homeNightMarketWaiting(int n) {
    return '$n penawaran menunggu untuk kamu buka';
  }

  @override
  String get homeNoRankedToday => 'Belum ada pertandingan Competitive hari ini';

  @override
  String get homeOpenLfg => 'Lihat semua postingan cari rekan tim';

  @override
  String get homeOpenRanking => 'Lihat peringkat skin';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Akun lain ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n akun';
  }

  @override
  String get homeOtherWishlistHit => 'Ada skin dari wishlist';

  @override
  String homePreviousAct(String rank) {
    return 'Act sebelumnya: $rank';
  }

  @override
  String get homeQuietBody => 'Tarik ke bawah untuk memuat ulang.';

  @override
  String get homeQuietTitle => 'Belum ada yang baru';

  @override
  String homeRankToNext(int rr) {
    return '$rr RR lagi untuk naik rank';
  }

  @override
  String get homeResetLayout => 'Kembalikan ke default';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Hari ini $value';
  }

  @override
  String get homeStatusDetails => 'Detail';

  @override
  String homeStatusIncident(String region) {
    return 'Gangguan server · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Sedang pemeliharaan · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Pemeliharaan akan datang · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n pemberitahuan';
  }

  @override
  String get homeStoreRefreshing => 'Memperbarui…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Diperbarui dalam $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Total $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Dompet $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return 'Dompet $vp · cukup untuk maksimal $n skin';
  }

  @override
  String get homeStoreWishlistHit => 'Ada skin dari wishlist di toko!';

  @override
  String homeStoreWishlistHits(int n) {
    return '$n skin dari wishlist sedang dijual';
  }

  @override
  String get homeTitle => 'Beranda';

  @override
  String get homeTrendingTitle => 'Skin paling disukai di seluruh dunia';

  @override
  String homeTrendingVotes(int n) {
    return '$n suka';
  }

  @override
  String get homeUndo => 'Urungkan';

  @override
  String homeWinStreak(int n) {
    return '$n kemenangan Competitive beruntun';
  }

  @override
  String get homeStoreOutdated =>
      'Toko sudah berganti. ValHub belum bisa memuat toko yang baru.';

  @override
  String get communityErrorConsent =>
      'Setujui untuk membagikan Riot ID-mu ke Komunitas agar bisa melanjutkan.';

  @override
  String get communityErrorForbidden =>
      'Kamu belum bisa melakukan ini. Lihat Pedoman Komunitas atau hubungi ValHub.';

  @override
  String get communityErrorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get communityErrorImageTooLarge =>
      'Gambar terlalu besar (maksimal 2 MB). Pilih gambar lain.';

  @override
  String get communityErrorImageType => 'Pilih gambar JPEG, PNG, atau WebP.';

  @override
  String get communityErrorInvalid =>
      'Kontenmu belum diterima. Periksa lagi lalu coba lagi.';

  @override
  String get communityErrorNetwork =>
      'Gagal terhubung ke Komunitas ValHub. Periksa koneksimu lalu coba lagi.';

  @override
  String get communityErrorNotFound => 'Konten ini sudah tidak ada.';

  @override
  String get communityErrorPickImage => 'Gagal membuka galeri foto. Coba lagi.';

  @override
  String get communityErrorRateLimited =>
      'Komunitas sedang menerima terlalu banyak permintaan. Coba lagi dalam beberapa menit.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Komunitas sedang menerima terlalu banyak permintaan. Coba lagi dalam $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot belum bisa memverifikasi akunmu. Login lagi ke akun Riot-mu lalu coba lagi.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot sedang mengalami gangguan. Coba lagi dalam beberapa menit.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot sedang mengalami gangguan. Coba lagi dalam $duration.';
  }

  @override
  String get communityErrorServer =>
      'Komunitas ValHub sedang mengalami gangguan. Coba lagi dalam beberapa menit.';

  @override
  String get communityErrorStorageFull =>
      'Penyimpanan foto Komunitas sudah penuh. Kamu tetap bisa memposting, tapi belum bisa melampirkan foto. Coba lagi nanti.';

  @override
  String get communityErrorTimeout =>
      'Komunitas ValHub terlalu lama merespons. Coba lagi.';

  @override
  String get communityErrorTitle => 'Belum selesai';

  @override
  String get communityErrorUnauthorized =>
      'Koneksi Komunitas sudah kedaluwarsa. Coba lagi.';

  @override
  String get communityErrorImageQuota =>
      'Ruang penyimpanan gambarmu sudah habis. Hapus beberapa postingan bergambar lalu coba lagi.';

  @override
  String get smokePlain => 'Pemeriksaan codegen';

  @override
  String smokeGreeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n item',
    );
    return '$_temp0';
  }
}
