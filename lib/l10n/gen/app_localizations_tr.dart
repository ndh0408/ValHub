// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Fiyat kaynağını gör';

  @override
  String get commonErrorApi =>
      'Riot şu anda sorun yaşıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonClearFilters => 'Filtreleri temizle';

  @override
  String get commonClearSearch => 'Aramayı temizle';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonCopied => 'Kopyalandı';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n gün';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n gün önce';
  }

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonEmptyGeneric => 'Burada henüz bir şey yok.';

  @override
  String get commonErrorContentUnavailable =>
      'Kaplama, ajan ve harita bilgileri yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get commonErrorGeneric => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String get commonErrorMaintenance =>
      'VALORANT sunucuları bakımda. Daha sonra tekrar uğra.';

  @override
  String get commonErrorNeedsLogin =>
      'Riot oturumunun süresi doldu. Devam etmek için tekrar giriş yap.';

  @override
  String get commonErrorNeedsLoginTitle => 'Tekrar giriş yap';

  @override
  String get commonErrorNetwork =>
      'Bağlantı yok. Wi-Fi\'ını veya mobil verini kontrol edip tekrar dene.';

  @override
  String get commonErrorNoAccount => 'Henüz hiçbir hesaba giriş yapmadın.';

  @override
  String get commonErrorNotFound => 'Bu içerik bulunamadı.';

  @override
  String get commonErrorTimeout =>
      'Riot\'un yanıt vermesi çok uzun sürüyor. Bağlantını kontrol edip tekrar dene.';

  @override
  String get commonErrorTransient =>
      'Riot şu anda yoğun. Birkaç dakika sonra tekrar dene.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot şu anda yoğun. Şu süre sonra tekrar dene: $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Riot bölgen belirlenemedi. Ayarlar\'dan bir bölge seç.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Ana Sayfa\'ya dön';

  @override
  String commonHours(int n) {
    return '$n saat';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n saat önce';
  }

  @override
  String get commonIncidentTitle => 'Sunucu sorunu';

  @override
  String get commonJustNow => 'az önce';

  @override
  String get commonLoadMore => 'Daha fazla yükle';

  @override
  String get commonLoading => 'Yükleniyor…';

  @override
  String get commonMaintenanceTitle => 'Sunucu bakımı';

  @override
  String commonMinutes(int n) {
    return '$n dakika';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n dakika önce';
  }

  @override
  String get commonNoData => 'Henüz gösterilecek bir şey yok';

  @override
  String commonOfflineCached(String time) {
    return 'Çevrim dışısın — kayıtlı veriler gösteriliyor ($time).';
  }

  @override
  String get commonOpenSettings => 'Ayarları aç';

  @override
  String get commonPageNotFound => 'Bu ekran bulunamadı.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'En avantajlı paket: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Girdiğin fiyatı düzenle';

  @override
  String get commonPriceEnterOwn => 'VP paketi fiyatını gir';

  @override
  String get commonPriceEstimateBody =>
      'VP fiyatlarının yanındaki “≈ …” tutarı bir tahmindir ve en avantajlı VP paketine göre hesaplanır. Oyunda VP ile ödeme yaparsın; gerçek tutar, satın aldığın andaki pakete, ödeme yöntemine, vergilere ve kampanyalara göre değişir.';

  @override
  String get commonPriceEstimateTitle => 'Tahmini fiyat';

  @override
  String get commonPriceEstimateTooltip =>
      'Tahmini fiyat — nasıl hesaplandığını görmek için dokun';

  @override
  String get commonPriceHidden =>
      'Tahmini fiyatlar gizlendi. Ayarlar\'dan tekrar açabilirsin.';

  @override
  String get commonPriceHide => 'Tahmini fiyatları gizle';

  @override
  String get commonPriceOpenSource => 'Kaynak sayfayı aç';

  @override
  String get commonPriceOverrideBody =>
      'Bir VP paketi için gerçekte ödediğin tutarı gir (oyun içi mağazaya veya faturana bak). ValHub bu fiyatı tüm ürünlerin tahmini fiyatını hesaplamak için kullanır; fiyat yalnızca bu cihazda saklanır.';

  @override
  String get commonPriceOverrideCurrency => 'Para birimi kodu';

  @override
  String get commonPriceOverrideCurrencyHint => 'Örn. TRY, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Örnek tahmin: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      '3 harfli bir para birimi kodu gir, örneğin TRY veya USD.';

  @override
  String get commonPriceOverrideInvalidNumber => '0\'dan büyük bir sayı gir.';

  @override
  String get commonPriceOverridePrice => 'Paket fiyatı';

  @override
  String get commonPriceOverrideRemove => 'Girdiğin fiyatı sil';

  @override
  String get commonPriceOverrideRemoved => 'Girdiğin fiyat silindi.';

  @override
  String get commonPriceOverrideSave => 'Fiyatı kaydet';

  @override
  String get commonPriceOverrideSaved => 'VP paketi fiyatın kaydedildi.';

  @override
  String get commonPriceOverrideTitle => 'VP paketi fiyatın';

  @override
  String get commonPriceOverrideVp => 'Paketteki VP';

  @override
  String get commonPricePacksTitle => 'VP paketleri';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Şu bölgedeki VP paketi fiyatlarına göre: $country';
  }

  @override
  String get commonPriceSourceUser => 'Girdiğin VP paketi fiyatına göre';

  @override
  String get commonPriceUnavailable =>
      'Bölgen için henüz doğrulanmış bir fiyat listesi yok. Tahmini fiyatları görmek için daha önce satın aldığın bir VP paketinin fiyatını gir.';

  @override
  String commonPriceUpdated(String date) {
    return 'Fiyat listesi güncellendi: $date';
  }

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonRiotDisclaimer =>
      'ValHub, Riot Games tarafından onaylanmamıştır ve Riot Games\'in ya da Riot Games mülklerinin yapımında veya yönetiminde resmî olarak yer alan herhangi birinin görüş veya düşüncelerini yansıtmaz. Riot Games ve ilişkili tüm mülkler, Riot Games, Inc. şirketinin ticari markaları veya tescilli ticari markalarıdır.';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonSearch => 'Ara…';

  @override
  String commonSeconds(int n) {
    return '$n saniye';
  }

  @override
  String get commonShare => 'Paylaş';

  @override
  String get commonSignInAgain => 'Tekrar giriş yap';

  @override
  String get commonSort => 'Sırala';

  @override
  String commonSortBy(String option) {
    return 'Sırala: $option';
  }

  @override
  String get commonTabBattlePass => 'Savaş Bileti';

  @override
  String get commonTabCollection => 'Koleksiyon';

  @override
  String get commonTabCommunity => 'Topluluk';

  @override
  String get commonTabHome => 'Ana Sayfa';

  @override
  String get commonTabProfile => 'Profil';

  @override
  String get commonTabSettings => 'Ayarlar';

  @override
  String get commonTabStore => 'Mağaza';

  @override
  String get commonTagline => 'VALORANT yol arkadaşın';

  @override
  String get commonToday => 'Bugün';

  @override
  String get commonTodayLower => 'bugün';

  @override
  String get commonTomorrow => 'yarın';

  @override
  String get commonUnknownItem => 'Bilinmeyen öğe';

  @override
  String commonUpdatedAt(String time) {
    return 'Güncellenme: $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day $time';
  }

  @override
  String get commonWeekdaysItem0 => 'Pazartesi';

  @override
  String get commonWeekdaysItem1 => 'Salı';

  @override
  String get commonWeekdaysItem2 => 'Çarşamba';

  @override
  String get commonWeekdaysItem3 => 'Perşembe';

  @override
  String get commonWeekdaysItem4 => 'Cuma';

  @override
  String get commonWeekdaysItem5 => 'Cumartesi';

  @override
  String get commonWeekdaysItem6 => 'Pazar';

  @override
  String get commonYesterday => 'dün';

  @override
  String get commonYesterdayTitle => 'Dün';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot oturumunun süresi doldu — kayıtlı veriler gösteriliyor ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Ağır Silahlar';

  @override
  String get contentCategoryMelee => 'Yakın Dövüş';

  @override
  String get contentCategoryRifle => 'Taarruz Tüfekleri';

  @override
  String get contentCategoryShotgun => 'Pompalı Tüfekler';

  @override
  String get contentCategorySidearm => 'Beylik Silahlar';

  @override
  String get contentCategorySmg => 'Hafif Makineliler';

  @override
  String get contentCategorySniper => 'Keskin Nişancı Tüfekleri';

  @override
  String get contentCurrencyAgentTokens => 'Ajan Sembolleri';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kingdom Kredisi';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radyanit';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Puanı';

  @override
  String get contentItemAgent => 'Ajan';

  @override
  String get contentItemBuddy => 'Silah Aksesuarı';

  @override
  String get contentItemCard => 'Oyuncu Kartı';

  @override
  String get contentItemChroma => 'Varyant';

  @override
  String get contentItemContract => 'Kontrat';

  @override
  String get contentItemCurrency => 'Para birimi';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Kaplama';

  @override
  String get contentItemSpray => 'Sprey';

  @override
  String get contentItemTitle => 'Oyuncu Unvanı';

  @override
  String contentLevel(int n) {
    return 'Seviye $n';
  }

  @override
  String get contentLevelBase => 'Temel';

  @override
  String get contentLevelItemLabelsVFX => 'Görsel Efektler';

  @override
  String get contentLevelItemLabelsAnimation => 'Animasyon';

  @override
  String get contentLevelItemLabelsFinisher => 'Bitirici';

  @override
  String get contentLevelItemLabelsKillCounter => 'Leş Sayacı';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Ses Efektleri';

  @override
  String get contentLevelItemLabelsTransformation => 'Dönüşüm';

  @override
  String get contentLevelItemLabelsKillBanner => 'Leş Afişi';

  @override
  String get contentLevelItemLabelsKillEffect => 'Leş Efekti';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'İnceleme ve Leş Efektleri';

  @override
  String get contentLevelItemLabelsVoiceover => 'Seslendirme';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Şarkı Karıştırma';

  @override
  String get contentLevelItemLabelsRandomizer => 'Rastgele Seçici';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Saldırı/Savunma Değişimi';

  @override
  String get contentLevelItemLabelsTopFrag => 'Top Frag Efekti';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Kalp Atışı ve Harita Sensörü';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Balık Animasyonu';

  @override
  String get contentNoTitle => 'Unvan yok';

  @override
  String get contentNotForSale => 'Satışta değil';

  @override
  String get contentQueueNamesCompetitive => 'Rekabete Dayalı';

  @override
  String get contentQueueNamesUnrated => 'Derecesiz';

  @override
  String get contentQueueNamesSwiftplay => 'Tam Gaz';

  @override
  String get contentQueueNamesSpikerush => 'Spike\'a Hücum';

  @override
  String get contentQueueNamesDeathmatch => 'Ölüm Kalım Savaşı';

  @override
  String get contentQueueNamesHurm => 'Takımlı Ölüm Kalım Savaşı';

  @override
  String get contentQueueNamesGgteam => 'Tırmanış';

  @override
  String get contentQueueNamesOnefa => 'Kopya';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Özel Oyun';

  @override
  String get contentQueueNames => 'Özel Oyun';

  @override
  String get contentQueueNamesDodgeball => 'Nakavt';

  @override
  String get contentQueueNamesFortcollins => 'Akın';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Çarpışma: 2\'ye 2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Çarpışma: Yükseliş 1\'e 1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Çarpışma: Yükseliş 2\'ye 2';

  @override
  String get contentQueueNamesValaram => 'Tek Bölgede Hepsi Rastgele';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Kartopu Çatışması';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Rekabete Dayalı';

  @override
  String get contentQueueShortNamesValaram => 'AR1S';

  @override
  String get contentRewardSourceAgent => 'Ajan kontratı';

  @override
  String get contentRewardSourceBattlePass => 'Savaş Bileti ödülü';

  @override
  String get contentRewardSourceEvent => 'Etkinlik Bileti';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Düellocu';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Öncü';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 =>
      'Kontrol Uzmanı';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Gözcü';

  @override
  String get contentTierDeluxe => 'Üstün';

  @override
  String get contentTierExclusive => 'Seçkin';

  @override
  String contentTierFull(String shortName) {
    return '$shortName Seri';
  }

  @override
  String get contentTierPremium => 'İhtişamlı';

  @override
  String get contentTierSelect => 'Özel';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Derecesiz';

  @override
  String get accountRegionUnknown => 'Bilinmeyen bölge';

  @override
  String accountRiotCountry(String country) {
    return 'Riot hesabı ülkesi: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riot hesabı ülkesi: Bilinmiyor';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'HESAPLAR ($count/$max)';
  }

  @override
  String get accountActive => 'Kullanımda';

  @override
  String accountAddAccount(int count, int max) {
    return 'Hesap ekle ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Yerel verileri sil';

  @override
  String get accountClearLocalDataConfirm =>
      'Bu cihazdaki geçmiş, kayıtlı kuşanım setleri ve çıkış yapılmış hesapların verileri silinsin mi?';

  @override
  String get accountClearRrHistory => 'RR geçmişini sil';

  @override
  String get accountClearRrHistoryConfirm =>
      'Seçili hesabın bu cihazdaki RR geçmişi silinsin mi?';

  @override
  String get accountCopyPassword => 'Şifreyi kopyala';

  @override
  String get accountCopyUsername => 'Kullanıcı adını kopyala';

  @override
  String get accountDeleteLoginNote => 'Bilgileri sil';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Bu hesabın kayıtlı kullanıcı adı ve şifresi silinsin mi?';

  @override
  String get accountHidePassword => 'Şifreyi gizle';

  @override
  String get accountKeepLocalData => 'Yerel verileri sakla';

  @override
  String get accountKeepLocalDataHint =>
      'İstek listesini, kuşanım setlerini ve geçmişi bu cihazda sakla';

  @override
  String accountLevelShort(int level) {
    return 'Svy. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Bu bildirimdeki hesaptan çıkış yapılmış. Tekrar giriş yap, ardından bildirimi aç.';

  @override
  String get accountLocalDataCleared => 'Yerel veriler silindi';

  @override
  String get accountLoginNote => 'Giriş bilgileri';

  @override
  String get accountLoginNoteDeleted => 'Giriş bilgileri silindi';

  @override
  String get accountLoginNoteEmpty => 'Kayıtlı giriş bilgisi yok';

  @override
  String get accountLoginNoteHint =>
      'Yalnızca bu cihazda, güvenli şekilde kilitli olarak saklanır. Tekrar giriş yaparken bilgilerine bakmak veya onları hızlıca doldurmak için kullan.';

  @override
  String get accountLoginNoteLocked => 'Giriş bilgilerinin kilidini aç';

  @override
  String get accountLoginNotePassword => 'Şifre';

  @override
  String get accountLoginNoteSaved => 'Giriş bilgileri kaydedildi';

  @override
  String get accountLoginNoteUsername => 'Riot kullanıcı adı';

  @override
  String get accountManageHint =>
      'Hesapları kaldırmak veya giriş bilgilerini düzenlemek için Ayarlar\'a git.';

  @override
  String accountMaxAccounts(int max) {
    return 'En fazla $max hesap sınırına ulaştın.';
  }

  @override
  String get accountNeedsLogin => 'Tekrar giriş yap';

  @override
  String accountOnlineCount(int count) {
    return 'Çevrim içi: $count';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Kayıtlı hesabı doldur';

  @override
  String get accountQuickFillDone => 'Bilgiler dolduruldu. Giriş Yap\'a dokun.';

  @override
  String get accountQuickFillNotReady =>
      'Giriş sayfası henüz yüklenmedi. Biraz bekleyip tekrar dene.';

  @override
  String get accountQuickFillSubtitle =>
      'Riot giriş sayfasına doldurulacak hesabı seç';

  @override
  String get accountQuickFillTitle => 'Kayıtlı hesabı doldur';

  @override
  String get accountRegionAp => 'Asya Pasifik';

  @override
  String get accountRegionBr => 'Brezilya';

  @override
  String get accountRegionEu => 'Avrupa';

  @override
  String get accountRegionKr => 'Kore';

  @override
  String get accountRegionLatam => 'Latin Amerika';

  @override
  String get accountRegionNa => 'Kuzey Amerika';

  @override
  String get accountRemoveAccount => 'Hesabı kaldır';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Bu hesap cihazdan kaldırılsın mı: $account? Kayıtlı verileri saklamayı seçebilirsin.';
  }

  @override
  String get accountRrHistoryCleared => 'RR geçmişi silindi';

  @override
  String get accountShowPassword => 'Şifreyi göster';

  @override
  String get accountSignOutAll => 'Tüm hesaplardan çıkış yap';

  @override
  String get accountSignOutAllConfirm =>
      'Tüm hesaplardan çıkış yapılıp hepsi bu cihazdan kaldırılsın mı? Kayıtlı verileri saklamayı seçebilirsin.';

  @override
  String get accountStatusAgentSelect => 'Ajan seçiminde';

  @override
  String get accountStatusInMatch => 'Maçta';

  @override
  String get accountStatusOffline => 'Çevrim dışı';

  @override
  String get accountStatusOnline => 'Çevrim içi';

  @override
  String get accountStatusUnknown => 'Durum bilinmiyor';

  @override
  String accountSwitchTo(String account) {
    return 'Geçiş yap: $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Hesap değiştirmek için dokun';

  @override
  String get accountSwitcherTitle => 'Hesaplar';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Hesaplar ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Oyuncu';

  @override
  String get accountUnlockLoginNote =>
      'Riot giriş bilgilerinin kilidini açmak için doğrula';

  @override
  String get authAddAsNew => 'Yeni hesap olarak ekle';

  @override
  String get authDifferentAccountBody =>
      'Tekrar giriş yapması gereken hesaptan farklı bir hesapla giriş yaptın. Bu hesap yeni bir hesap olarak eklensin mi?';

  @override
  String get authDifferentAccountTitle => 'Farklı hesap';

  @override
  String get authLoadingAccount => 'Hesap yükleniyor…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot bu giriş denemesini reddetti. Tekrar dene.';

  @override
  String get authLoginFailed => 'Giriş tamamlanamadı';

  @override
  String get authLoginFailedBody =>
      'Riot girişini henüz onaylamadı. Tekrar dene.';

  @override
  String get authLoginTitle => 'Riot girişi';

  @override
  String get authMissingCookies =>
      'Girişin bu cihaza kaydedilemedi, bu yüzden süresi dolduğunda tekrar giriş yapman gerekecek.';

  @override
  String get authOfficialHost => 'Resmî sayfa · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Bağlantı tarayıcıda açıldı.';

  @override
  String get authPageLoadFailed =>
      'Riot giriş sayfası yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get authPreparing => 'Giriş sayfası hazırlanıyor…';

  @override
  String get authReloginDone => 'Tekrar giriş yapıldı';

  @override
  String get authSignInCta => 'Riot hesabıyla giriş yap';

  @override
  String get authSocialLoginHint =>
      'Google veya Facebook ile giriş yapamıyorsan Riot kullanıcı adını kullan.';

  @override
  String get authStateMismatch =>
      'Bu giriş denemesi geçerli değil. Girişe baştan başla.';

  @override
  String get notificationSessionExpiredBody =>
      'İstek listesi bildirimlerini almaya devam etmek için tekrar giriş yap.';

  @override
  String get notificationBackgroundTimingHint =>
      'Cihazının pil tasarrufu modu bildirimleri geciktirebilir.';

  @override
  String get notificationChannelAccountDescription =>
      'Bir hesabın tekrar giriş yapması gerektiğinde hatırlatır';

  @override
  String get notificationChannelAccountName => 'Hesaplar';

  @override
  String get notificationChannelBattlePassDescription =>
      'Savaş Bileti ilerlemesi ve bitiş tarihi hatırlatmaları';

  @override
  String get notificationChannelBattlePassName => 'Savaş Bileti';

  @override
  String get notificationChannelCommunityDescription =>
      'ValHub\'ı açtığında topluluk etkinlikleri';

  @override
  String get notificationChannelCommunityName => 'Topluluk';

  @override
  String get notificationChannelLfgDescription =>
      'ValHub\'ı açtığında grubuna katılan oyuncular';

  @override
  String get notificationChannelLfgName => 'Grup';

  @override
  String get notificationChannelNightMarketDescription =>
      'Gece Pazarı açıldığında bildirir';

  @override
  String get notificationChannelNightMarketName => 'Gece Pazarı';

  @override
  String get notificationChannelRankDescription =>
      'Profilini yenilediğinde rütbe değişiklikleri';

  @override
  String get notificationChannelRankName => 'Rütbe';

  @override
  String get notificationChannelStoreResetDescription =>
      'Günlük mağaza yenilendiğinde hatırlatır';

  @override
  String get notificationChannelStoreResetName => 'Mağaza yenilenmesi';

  @override
  String get notificationChannelWishlistDescription =>
      'İstek listendeki bir kaplama mağazana geldiğinde bildirir';

  @override
  String get notificationChannelWishlistName => 'İstek listesi';

  @override
  String get notificationLfgJoinedTitle => 'Grubuna bir oyuncu katıldı';

  @override
  String get notificationLocalOnlyHint =>
      'Yalnızca ValHub verilerini güncellediğinde bu cihazda gösterilir';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return '$account için $cards teklif kartı bekliyor. Hemen çevir.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Gece Pazarı açıldı!';

  @override
  String get notificationPassEndingBody =>
      'Savaş Bileti\'nin bitmesine yaklaşık bir gün kaldı. Son ilerlemeni görmek için ValHub\'ı aç.';

  @override
  String get notificationPassEndingTitle => 'Savaş Bileti yakında bitiyor';

  @override
  String notificationPassProgressBody(int level) {
    return 'Mevcut Savaş Bileti\'nde $level. seviyeye ulaştın.';
  }

  @override
  String get notificationPassProgressTitle => 'Savaş Bileti ilerlemesi';

  @override
  String get notificationPrivateAccount => 'hesabın';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Mevcut rütbe: $rank. Riot\'tan az önce güncellendi.';
  }

  @override
  String get notificationRankChangedTitle => 'Rütbe değişti';

  @override
  String get notificationResetTimingUnknown =>
      'Cihazındaki yenilenme saatini güncellemek için mağazayı aç.';

  @override
  String get notificationSessionExpiredTitle => 'Tekrar giriş yap';

  @override
  String get notificationStoreResetBody =>
      'Mağazada seni yeni kaplamalar bekliyor.';

  @override
  String get competitiveDivisionIron => 'Demir';

  @override
  String get competitiveDivisionBronze => 'Bronz';

  @override
  String get competitiveDivisionSilver => 'Gümüş';

  @override
  String get competitiveDivisionGold => 'Altın';

  @override
  String get competitiveDivisionPlatinum => 'Platin';

  @override
  String get competitiveDivisionDiamond => 'Elmas';

  @override
  String get competitiveDivisionAscendant => 'Yücelik';

  @override
  String get competitiveDivisionImmortal => 'Ölümsüzlük';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radyant';

  @override
  String get competitiveRankUnknown => 'Rütbe bilinmiyor';

  @override
  String get competitiveAttack => 'Saldırı';

  @override
  String get competitiveCannotEstimate => 'Tahmin edilemiyor';

  @override
  String get competitiveDefeat => 'Yenilgi';

  @override
  String get competitiveDefense => 'Savunma';

  @override
  String get competitiveDraw => 'Beraberlik';

  @override
  String get competitiveIncognitoPlayer => 'Gizli oyuncu';

  @override
  String get competitiveMatchPending => 'Riot bu maçı hâlâ işliyor…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return 'Kalan yerleştirme maçı: $n';
  }

  @override
  String get competitiveRoundDefuse => 'Spike imha edildi';

  @override
  String get competitiveRoundDetonate => 'Spike patladı';

  @override
  String get competitiveRoundElimination => 'Takım yok edildi';

  @override
  String get competitiveRoundSurrendered => 'Teslim olundu';

  @override
  String get competitiveRoundTimeExpired => 'Süre doldu';

  @override
  String get competitiveUnknownPlayer => 'Oyuncu';

  @override
  String get competitiveVictory => 'Zafer';

  @override
  String economyAvailableNow(String place) {
    return 'Şu an burada: $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return '$name paketi';
  }

  @override
  String get economyPlaceBundleGeneric => 'paket';

  @override
  String get economyPlaceDaily => 'günlük mağaza';

  @override
  String get economyPlaceNightMarket => 'Gece Pazarı';

  @override
  String get economyPriceEstimated => 'Seriye göre tahmini fiyat';

  @override
  String get economyPriceFromOffers => 'Riot fiyat listesindeki fiyat';

  @override
  String get economyPriceFromStore => 'Mağazada görülen fiyat';

  @override
  String get economyPriceFromTable => 'Liste fiyatı';

  @override
  String get economyPriceUnknown => 'Fiyat bilinmiyor';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Kuşanım $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Bu değişiklik mevcut kuşanımına uygulanamaz.';

  @override
  String get loadoutNotPersisted =>
      'Riot değişikliğini kaydetmedi, kuşanımın aynı kaldı. Tekrar dene.';

  @override
  String get loadoutSaveFailed => 'Kuşanım kaydedilemedi';

  @override
  String battlePassActEndsIn(String time) {
    return 'Kısmın bitmesine: $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return 'Kısmın bitmesine $days gün kaldı';
  }

  @override
  String get battlePassAllMissionsDone => 'Tüm görevler tamamlandı';

  @override
  String get battlePassAllWeeklyDone => 'Tüm haftalık görevler tamamlandı';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Bekleyen çift ödül: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Bölüm $n';
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
      'Kontrol noktalarında ilerlemek için raunt kazan (Ölüm Kalım Savaşı sayılmaz).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Kontrol noktası $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Her kontrol noktası: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Ulaşılan kontrol noktası: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Mevcut';

  @override
  String get battlePassDailyAllDone =>
      'Bugünkü tüm kontrol noktaları tamamlandı';

  @override
  String get battlePassDailyCaption => 'Günlük ödüller';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Günlük ödüller · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Önceki günün kontrol noktalarının süresi doldu. Oyuna gir veya burada yenile.';

  @override
  String get battlePassDailyMissions => 'Günlük görevler';

  @override
  String get battlePassDailyNotReady =>
      'Bugünkü kontrol noktaları henüz hazır değil. Oyuna gir veya burada yenile.';

  @override
  String get battlePassDailyPlayToStart =>
      'Bugünkü kontrol noktaları henüz hazır değil. Yeni güne başlamak için oyuna gir.';

  @override
  String battlePassDaysLeft(int days) {
    return '$days gün kaldı';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Bitiş: $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilog';

  @override
  String get battlePassEstimateNote =>
      'Görevler hariç, maç başına yaklaşık 4.000 XP olarak tahmin edilmiştir.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Bitmesine: $time';
  }

  @override
  String get battlePassEventPass => 'Etkinlik Bileti';

  @override
  String get battlePassFilterAll => 'Tümü';

  @override
  String get battlePassFilterLocked => 'Kilitli';

  @override
  String get battlePassFilterUnlocked => 'Açılmış';

  @override
  String get battlePassFree => 'Ücretsiz';

  @override
  String get battlePassFreeTrack => 'Ücretsiz ödüller';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Seviye $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Svy. $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '≈ $nString maç ($queue)';
  }

  @override
  String get battlePassMissionDone => 'Tamamlandı';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total tamamlandı';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Yeni görevler: $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Yeni görevlere: $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Sonraki kontrol noktası: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Hedef seviye: $level';
  }

  @override
  String get battlePassNextReward => 'Sıradaki';

  @override
  String get battlePassNoBattlePass =>
      'Mevcut kısım için henüz Savaş Bileti bilgisi yok. Daha sonra tekrar dene.';

  @override
  String get battlePassNoRewards => 'Bu Savaş Bileti\'nde henüz ödül yok.';

  @override
  String get battlePassNoRewardsInFilter => 'Bu bölümde ödül yok.';

  @override
  String get battlePassNoRewardsTitle => 'Henüz ödül yok';

  @override
  String get battlePassNoWeeklyMissions => 'Şu anda haftalık görev yok.';

  @override
  String get battlePassPassComplete => 'Savaş Bileti tamamlandı';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Premium\'un yok: yalnızca Ücretsiz ödülleri alırsın. Ulaştığın seviyelerin kilidini açmak için oyunda Premium satın al.';

  @override
  String get battlePassRenewButton => 'Kontrol noktalarını yenile';

  @override
  String get battlePassRenewDone => 'Günlük kontrol noktaları yenilendi.';

  @override
  String get battlePassRenewFailed =>
      'Kontrol noktaları yenilenemedi. Daha sonra tekrar dene.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Yenilenme: $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Yenilenmesine: $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Seviye';

  @override
  String get battlePassRewardLocked => 'Kilitli';

  @override
  String get battlePassRewardNeedsPremium => 'Premium gerekir';

  @override
  String get battlePassRewardStatusLabel => 'Durum';

  @override
  String get battlePassRewardTrackLabel => 'Ödül yolu';

  @override
  String get battlePassRewardTypeLabel => 'Tür';

  @override
  String get battlePassRewardUnlocked => 'Açıldı';

  @override
  String get battlePassRewardsTitle => 'Ödüller';

  @override
  String get battlePassShowAllRewards => 'Tümünü gör';

  @override
  String get battlePassTitle => 'Savaş Bileti';

  @override
  String get battlePassTotalXpCaption => 'Toplam XP';

  @override
  String get battlePassUnknownMission => 'Yeni görev (henüz açıklama yok)';

  @override
  String get battlePassUnknownReward => 'Ödül';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total açıldı';
  }

  @override
  String get battlePassUnratedFallback => 'Derecesiz';

  @override
  String get battlePassViewAllRewards => 'Tüm ödülleri gör';

  @override
  String get battlePassWeeklyMissions => 'Haftalık görevler';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Haftalık görevlerde kalan: +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / gün';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Zamanında bitirmek için günlük gereken';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Kalan: $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Kuşanım kaydedilemedi. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin':
          'Sahip olduğun tüm kaplamalar, mağaza fiyatlarıyla değerlendirilir',
      'buddy': 'Sahip olduğun silah aksesuarları ve kopya sayıları',
      'spray': 'İfade çarkına ekleyebileceğin spreyler',
      'card': 'Açtığın oyuncu kartları, görmek ve kuşanmak için dokun',
      'title': 'Adının altında gösterebileceğin unvanlar',
      'flex': 'Sahip olduğun Flex öğeleri',
      'other': 'Koleksiyona göz at',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Yuva: $position';
  }

  @override
  String get collectionApplyPreset => 'Uygula';

  @override
  String get collectionApplyPresetBody =>
      'Kullandığın kaplamalar, silah aksesuarları, ifade çarkı, kart ve unvan bu setle değiştirilecek.';

  @override
  String collectionApplyPresetTitle(String name) {
    return '“$name” uygulansın mı?';
  }

  @override
  String get collectionBrowseBuddies => 'Silah Aksesuarları';

  @override
  String get collectionBrowseCards => 'Oyuncu Kartları';

  @override
  String get collectionBrowseEmpty => 'Bu bölümde henüz hiç öğen yok.';

  @override
  String get collectionBrowseEmptyTitle => 'Henüz öğe yok';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Kaplamalar';

  @override
  String get collectionBrowseSprays => 'Spreyler';

  @override
  String get collectionBrowseTitles => 'Oyuncu Unvanları';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Kalan: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Silah: $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Silah aksesuarı seç';

  @override
  String get collectionBuddyRemoved => 'Silah aksesuarı çıkarıldı';

  @override
  String get collectionBuddySlot => 'Silah Aksesuarı';

  @override
  String get collectionBuddyUnavailable =>
      'Bu silah aksesuarı takılamadı. Yenile veya başka bir tane seç.';

  @override
  String get collectionCachedLoadout =>
      'Kayıtlı kuşanımın gösteriliyor. Değişiklik yapmadan önce yenilemek için çek.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'Sahip olunan $nString kart';
  }

  @override
  String get collectionChangeBuddy => 'Değiştir';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total varyant';
  }

  @override
  String get collectionClearTiers => 'Seri filtresini temizle';

  @override
  String get collectionCollectionValue => 'Koleksiyon değeri';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standart';

  @override
  String get collectionDeletePreset => 'Sil';

  @override
  String get collectionEmptySlot => 'Boş';

  @override
  String get collectionEquip => 'Kuşan';

  @override
  String get collectionEquipped => 'Kuşanıldı';

  @override
  String get collectionEquippedCard => 'Kuşanılan kart';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Kuşanılan kart: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Kuşanıldı: $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Kuşanılan: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Ödül kaplamaları hariç';

  @override
  String get collectionExpressionsHint =>
      'Sprey veya Flex seçmek için bir yuvaya dokun.';

  @override
  String get collectionExpressionsSlots => 'Çark yuvaları';

  @override
  String get collectionExpressionsTitle => 'İfade çarkı';

  @override
  String get collectionHideAccountLevel => 'Hesap seviyesini gizle';

  @override
  String get collectionHideAccountLevelHint =>
      'Diğer oyuncular hesap seviyeni göremez.';

  @override
  String get collectionIncognito => 'Gizli mod';

  @override
  String get collectionIncognitoHint =>
      'Maçlarda adını grubunda olmayan oyunculardan gizle.';

  @override
  String get collectionLevelBorderAuto => 'Seviyeye göre otomatik';

  @override
  String collectionLevelBorderFrom(int level) {
    return '$level. seviyeden itibaren';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Hesap seviyesi $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Seviye çerçevesi seç';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Seviye $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Seviye $n · $type';
  }

  @override
  String get collectionLevels => 'Seviyeler';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$total seviye açıldı';
  }

  @override
  String get collectionLobbyBanner => 'Lobi afişi';

  @override
  String get collectionLocked => 'Kilitli';

  @override
  String get collectionMeleeNoBuddy =>
      'Yakın dövüş silahlarına silah aksesuarı takılamaz.';

  @override
  String get collectionMove => 'Taşı';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy şu silaha takılı: $from. Şu silaha taşınsın mı: $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Silah aksesuarı taşınsın mı?';

  @override
  String get collectionNoBuddies => 'Henüz hiç silah aksesuarın yok.';

  @override
  String get collectionNoBuddy => 'Silah aksesuarı yok';

  @override
  String get collectionNoFlex => 'Henüz hiç Flex öğen yok.';

  @override
  String get collectionNoResults => 'Eşleşen sonuç yok.';

  @override
  String get collectionNoResultsTitle => 'Hiçbir şey bulunamadı';

  @override
  String get collectionNoSkinsForWeapon =>
      'Bu silah için henüz hiç kaplaman yok.';

  @override
  String get collectionNoSprays => 'Henüz hiç spreyin yok.';

  @override
  String get collectionNoTitle => 'Unvan yok';

  @override
  String get collectionOtherWeapons => 'Diğer';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n kaplamaya sahipsin',
      one: '$n kaplamaya sahipsin',
      zero: 'Henüz kaplama yok',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'Sahip olunan $nString kaplama';
  }

  @override
  String get collectionPlayLevelVideo => 'Bu seviyenin videosunu izle';

  @override
  String get collectionPlayVideo => 'Videoyu izle';

  @override
  String get collectionPlayerCardSubtitle =>
      'Lobide, skor tablosunda ve bir rakibi indirdiğinde gösterilir.';

  @override
  String get collectionPlayerCardTitle => 'Oyuncu kartını değiştir';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Lobide ve maçlarda adının altında gösterilir.';

  @override
  String get collectionPlayerTitleTitle => 'Oyuncu unvanını değiştir';

  @override
  String get collectionPresetActions => 'Seçenekler';

  @override
  String collectionPresetApplied(String name) {
    return '“$name” uygulandı';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n set',
      one: '$n set',
      zero: 'Henüz yok',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '“$name” silindi';
  }

  @override
  String get collectionPresetNameHint => 'Örn. Rütbe kasma';

  @override
  String get collectionPresetNameTitle => 'Kuşanım seti adı';

  @override
  String collectionPresetSaved(String name) {
    return '“$name” kaydedildi';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Kaydedilme tarihi: $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return 'Artık sahip olmadığın $n öğe atlandı.';
  }

  @override
  String get collectionPresetsEmpty =>
      'Daha sonra kaplama, kart ve ifade çarkı setleri arasında hızlıca geçiş yapmak için mevcut kuşanımını kaydet.';

  @override
  String get collectionPresetsEmptyTitle => 'Henüz kayıtlı kuşanım seti yok';

  @override
  String get collectionPresetsFull =>
      'En fazla 50 kuşanım seti sınırına ulaştın. Daha fazla kaydetmek için bazılarını sil.';

  @override
  String get collectionPresetsNote =>
      'Kuşanım setleri yalnızca bu cihazda, seçili hesap için saklanır.';

  @override
  String get collectionPresetsTitle => 'Kayıtlı kuşanım setleri';

  @override
  String get collectionPreview => 'Önizle';

  @override
  String get collectionRemoveBuddy => 'Silah aksesuarını çıkar';

  @override
  String get collectionRenamePreset => 'Yeniden adlandır';

  @override
  String get collectionRowExpressions => 'İfade çarkı';

  @override
  String get collectionRowLevelBorder => 'Seviye Çerçevesi';

  @override
  String get collectionRowPresets => 'Kayıtlı kuşanım setleri';

  @override
  String get collectionRowWeapons => 'Silah kuşanımı';

  @override
  String get collectionRowWishlist => 'İstek listesi';

  @override
  String get collectionSaveFailed => 'Kuşanım kaydedilemedi';

  @override
  String get collectionSavePreset => 'Mevcut kuşanımı kaydet';

  @override
  String get collectionSaving => 'Kaydediliyor…';

  @override
  String get collectionSearchBuddies => 'Silah aksesuarı ara…';

  @override
  String get collectionSearchCards => 'Oyuncu kartı ara…';

  @override
  String get collectionSearchFlex => 'Flex ara…';

  @override
  String get collectionSearchItems => 'Ara…';

  @override
  String get collectionSearchSkins => 'Kaplama ara…';

  @override
  String get collectionSearchSprays => 'Sprey ara…';

  @override
  String get collectionSearchTitles => 'Unvan ara…';

  @override
  String get collectionSearchWeapons =>
      'Silah, kaplama veya silah aksesuarı ara…';

  @override
  String get collectionSectionBrowse => 'Koleksiyona göz at';

  @override
  String get collectionSectionIdentity => 'Diğer oyunculara görünür';

  @override
  String get collectionSectionLoadout => 'Kuşanım';

  @override
  String get collectionSkinCustomizeTitle => 'Kaplamayı özelleştir';

  @override
  String get collectionSkinNotFound => 'Bu kaplama bulunamadı.';

  @override
  String get collectionSkinNotOwned => 'Bu kaplamaya henüz sahip değilsin.';

  @override
  String get collectionSlotNamesItem0 => 'Üst';

  @override
  String get collectionSlotNamesItem1 => 'Sağ';

  @override
  String get collectionSlotNamesItem2 => 'Alt';

  @override
  String get collectionSlotNamesItem3 => 'Sol';

  @override
  String get collectionSortName => 'Ad';

  @override
  String get collectionSortPrice => 'Fiyat';

  @override
  String get collectionSortRarity => 'Nadirlik';

  @override
  String get collectionSortWeapon => 'Silah';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return 'Filtrelenen: $count kaplama · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Filtrelenen: $count/$total öğe';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count öğe';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count kaplama · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Spreyler';

  @override
  String get collectionTapToChangeCard => 'Kartı değiştirmek için dokun';

  @override
  String get collectionTitle => 'Koleksiyon';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'Sahip olunan $nString unvan';
  }

  @override
  String get collectionUndo => 'Geri al';

  @override
  String get collectionUnknownCard => 'Bilinmeyen kart';

  @override
  String get collectionValueAtStorePrices => 'Mağaza fiyatlarına göre';

  @override
  String get collectionValueHasEstimates => 'Tahminler dahil (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return '$n ödül kaplaması hesaba katılmadı';
  }

  @override
  String get collectionValueSeeSkins => 'Kaplamaları gör';

  @override
  String collectionValueSkinCount(int n) {
    return '$n kaplamaya göre';
  }

  @override
  String get collectionVariants => 'Varyantlar';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total silahta kaplama kullanılıyor';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Silah kuşanımı';

  @override
  String get collectionWeaponNotFound => 'Bu silah bulunamadı.';

  @override
  String get collectionWeaponSkinsTitle => 'Kaplama seç';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n kaplama',
      one: '$n kaplama',
      zero: 'Boş',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Uygunsuz ifadeler içerdiği için paylaşılamadı. Gönderini düzenleyip tekrar dene.';

  @override
  String get communityModerationContentScam =>
      'Topluluk\'ta hesap satışı, boost hizmeti veya telefon numarası içeren ilanlara izin verilmez. Bu içerikleri kaldırıp tekrar dene.';

  @override
  String get communityModerationContentTooComplex =>
      'Gönderinde çok fazla dağınık karakter var. Daha sade yazıp tekrar dene.';

  @override
  String get communityModerationAccountBanned =>
      'Bu hesabın Topluluk\'u kullanması yasaklandı. Bir hata olduğunu düşünüyorsan Hakkında ve yasal bölümünden ValHub ile iletişime geç.';

  @override
  String get communityModerationAccountRestricted =>
      'Bu hesabın gönderi paylaşma, yorum yapma, takım arkadaşı arama ve oy verme özellikleri kısıtlandı. Daha sonra tekrar dene veya Hakkında ve yasal bölümünden ValHub ile iletişime geç.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Rekabete Dayalı',
      'unrated': 'Derecesiz',
      'swiftplay': 'Tam Gaz',
      'spikerush': 'Spike\'a Hücum',
      'deathmatch': 'Ölüm Kalım Savaşı',
      'teamdeathmatch': 'Takımlı Ölüm Kalım Savaşı',
      'premier': 'Premier',
      'custom': 'Özel Oyun',
      'other': 'Diğer',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asya Pasifik',
      'na': 'Kuzey Amerika',
      'eu': 'Avrupa',
      'kr': 'Kore',
      'latam': 'Latin Amerika',
      'br': 'Brezilya',
      'other': 'Bilinmeyen bölge',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'Bu sıralamada henüz kaplama yok';

  @override
  String get communityRankingEmptyVotes =>
      'Seçili kapsam ve filtrelerle eşleşen favori henüz yok.';

  @override
  String get communityRankingEmptyRatings =>
      'Seçili kapsam ve filtrelerle eşleşen yıldız puanı henüz yok.';

  @override
  String get communityRankingEmptyReviews =>
      'Seçili kapsam ve filtrelerle eşleşen inceleme henüz yok.';

  @override
  String get communityRankingExplore =>
      'Görüntülemek ve puanlamak için kaplama bul';

  @override
  String get communityRankingExploreHint =>
      'Kaplama veya silah adına göre ara. Sıralamalarda yalnızca topluluğun gerçek puanları yer alır.';

  @override
  String get communityRankingClear => 'Silah ve zaman filtrelerini temizle';

  @override
  String get communityRankingSort => 'Sıralama ölçütü';

  @override
  String get communityRankingWeapon => 'Silah';

  @override
  String get communityRankingNoSearch =>
      'Eşleşen kaplama yok. Başka bir ad dene veya silah filtresini temizle.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Kaplama listesi yüklenemedi. Bu paneli kapatıp veriler eşitlendikten sonra tekrar dene.';

  @override
  String get communityConsentExitAccount =>
      'Kabul etme · Bu hesaptan çıkış yap';

  @override
  String get communityRankingGlobalAllTime => 'Küresel · Tüm zamanlar';

  @override
  String get communityRankingCatalogTitle => 'Tüm kaplamalar';

  @override
  String get communityReviewOwnershipRequired =>
      'Bu kaplamayı puanlamak için hesabının ona sahip olması gerekir. Topluluk puanlarını ve yorumlarını yine de okuyabilirsin.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Bu kaplamaya sahip olduğun doğrulanamadı. Koleksiyon\'u yeniden yükle veya çevrim içi olduğunda tekrar dene.';

  @override
  String get communityReviewLegacyOwnership =>
      'Eski inceleme · Sahiplik doğrulanmadı';

  @override
  String get communityReviewVerifiedOwner =>
      'İnceleme sırasında sahiplik doğrulandı';

  @override
  String get communitySkinDiscussionHint =>
      'Herkes yorum yapabilir. Yalnızca kaplamanın sahipleri yıldız verip inceleme yazabilir.';

  @override
  String get communityAddPhotos => 'Fotoğraf ekle';

  @override
  String get communityAllModes => 'Tümü';

  @override
  String get communityAllWeapons => 'Tüm silahlar';

  @override
  String get communityAnonymousBanner => 'Anonim olarak göz atıyorsun';

  @override
  String get communityAnyLanguage => 'Herhangi bir dil';

  @override
  String get communityAnyRank => 'Herhangi bir rütbe';

  @override
  String get communityAnyRole => 'Herhangi bir rol';

  @override
  String get communityApply => 'Uygula';

  @override
  String get communityBackToMyCountry => 'Ülkeme dön';

  @override
  String get communityBlockAuthor => 'Bu cihazda engelle';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Temizle';

  @override
  String get communityCodeAuto =>
      'Boş bırak: Paylaştığında ValHub oyundaki grubundan bir kod oluşturur.';

  @override
  String get communityCodeAutoFailed =>
      'Grup kodu oluşturulamadı. VALORANT\'ı aç veya kodu elle gir.';

  @override
  String get communityCodeInvalid =>
      'Kod tam olarak 6 büyük harf veya rakamdan oluşmalı.';

  @override
  String get communityCodeRequired => 'Bir grup kodu gir veya oluştur.';

  @override
  String get communityCommentHint => 'Yorum yaz…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString yorum';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Yorumlar · $n';
  }

  @override
  String get communityCommentsTitle => 'Yorumlar';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Gönderi: $posts · Oyuncu: $authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString takım arkadaşı ilanı';
  }

  @override
  String get communityCommunityVotes => 'Topluluğun favorileri';

  @override
  String get communityComposerHint =>
      'Bugün VALORANT hakkında ne düşünüyorsun?';

  @override
  String get communityComposerTitle => 'Yeni gönderi';

  @override
  String communityConsentAccount(String riotId) {
    return 'Hesap: $riotId';
  }

  @override
  String get communityConsentAgree => 'Kabul et ve devam et';

  @override
  String get communityConsentGateAction => 'Katıl';

  @override
  String get communityConsentGuidelines => 'Topluluk Kuralları';

  @override
  String get communityConsentLater => 'Daha sonra';

  @override
  String get communityConsentLocal =>
      'Şifren ve diğer giriş verilerin her zaman bu cihazda kalır. Onayını Ayarlar\'dan geri çekebilirsin.';

  @override
  String get communityConsentPrivacy => 'Gizlilik Politikası';

  @override
  String get communityConsentPublic =>
      'Diğer oyuncular Riot ID\'ni, oyuncu kartını, rütbeni ve ülkeni görür.';

  @override
  String get communityConsentTitle => 'Gizlilik ve ValHub Topluluğu';

  @override
  String get communityConsentVerify =>
      'ValHub, bağlandığında Riot ID\'ni doğrulamak ve bir inceleme kaydettiğinde kaplama sahipliğini kontrol etmek için Riot erişimini Topluluk sunucusuna gönderir. Sunucu yalnızca gereken verileri okur, erişimi hemen siler ve asla saklamaz.';

  @override
  String get communityConsentWithdrawn =>
      'Onay geri çekildi. Uygulamayı kullanmaya devam etmek için tekrar onay vermen gerekir.';

  @override
  String get communityCountriesTitle => 'Ülkelere göre topluluklar';

  @override
  String get communityCountryNamesAE => 'Birleşik Arap Emirlikleri';

  @override
  String get communityCountryNamesAL => 'Arnavutluk';

  @override
  String get communityCountryNamesAM => 'Ermenistan';

  @override
  String get communityCountryNamesAR => 'Arjantin';

  @override
  String get communityCountryNamesAT => 'Avusturya';

  @override
  String get communityCountryNamesAU => 'Avustralya';

  @override
  String get communityCountryNamesAZ => 'Azerbaycan';

  @override
  String get communityCountryNamesBA => 'Bosna-Hersek';

  @override
  String get communityCountryNamesBD => 'Bangladeş';

  @override
  String get communityCountryNamesBE => 'Belçika';

  @override
  String get communityCountryNamesBG => 'Bulgaristan';

  @override
  String get communityCountryNamesBH => 'Bahreyn';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivya';

  @override
  String get communityCountryNamesBR => 'Brezilya';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Kanada';

  @override
  String get communityCountryNamesCH => 'İsviçre';

  @override
  String get communityCountryNamesCL => 'Şili';

  @override
  String get communityCountryNamesCN => 'Çin';

  @override
  String get communityCountryNamesCO => 'Kolombiya';

  @override
  String get communityCountryNamesCR => 'Kosta Rika';

  @override
  String get communityCountryNamesCU => 'Küba';

  @override
  String get communityCountryNamesCY => 'Kıbrıs';

  @override
  String get communityCountryNamesCZ => 'Çekya';

  @override
  String get communityCountryNamesDE => 'Almanya';

  @override
  String get communityCountryNamesDK => 'Danimarka';

  @override
  String get communityCountryNamesDO => 'Dominik Cumhuriyeti';

  @override
  String get communityCountryNamesDZ => 'Cezayir';

  @override
  String get communityCountryNamesEC => 'Ekvador';

  @override
  String get communityCountryNamesEE => 'Estonya';

  @override
  String get communityCountryNamesEG => 'Mısır';

  @override
  String get communityCountryNamesES => 'İspanya';

  @override
  String get communityCountryNamesET => 'Etiyopya';

  @override
  String get communityCountryNamesFI => 'Finlandiya';

  @override
  String get communityCountryNamesFR => 'Fransa';

  @override
  String get communityCountryNamesGB => 'Birleşik Krallık';

  @override
  String get communityCountryNamesGE => 'Gürcistan';

  @override
  String get communityCountryNamesGH => 'Gana';

  @override
  String get communityCountryNamesGR => 'Yunanistan';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Hırvatistan';

  @override
  String get communityCountryNamesHU => 'Macaristan';

  @override
  String get communityCountryNamesID => 'Endonezya';

  @override
  String get communityCountryNamesIE => 'İrlanda';

  @override
  String get communityCountryNamesIL => 'İsrail';

  @override
  String get communityCountryNamesIN => 'Hindistan';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'İran';

  @override
  String get communityCountryNamesIS => 'İzlanda';

  @override
  String get communityCountryNamesIT => 'İtalya';

  @override
  String get communityCountryNamesJO => 'Ürdün';

  @override
  String get communityCountryNamesJP => 'Japonya';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Kamboçya';

  @override
  String get communityCountryNamesKR => 'Güney Kore';

  @override
  String get communityCountryNamesKW => 'Kuveyt';

  @override
  String get communityCountryNamesKZ => 'Kazakistan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Lübnan';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Litvanya';

  @override
  String get communityCountryNamesLU => 'Lüksemburg';

  @override
  String get communityCountryNamesLV => 'Letonya';

  @override
  String get communityCountryNamesLY => 'Libya';

  @override
  String get communityCountryNamesMA => 'Fas';

  @override
  String get communityCountryNamesMD => 'Moldova';

  @override
  String get communityCountryNamesME => 'Karadağ';

  @override
  String get communityCountryNamesMK => 'Kuzey Makedonya';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Moğolistan';

  @override
  String get communityCountryNamesMO => 'Makao';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Meksika';

  @override
  String get communityCountryNamesMY => 'Malezya';

  @override
  String get communityCountryNamesNG => 'Nijerya';

  @override
  String get communityCountryNamesNI => 'Nikaragua';

  @override
  String get communityCountryNamesNL => 'Hollanda';

  @override
  String get communityCountryNamesNO => 'Norveç';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Yeni Zelanda';

  @override
  String get communityCountryNamesOM => 'Umman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Filipinler';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Polonya';

  @override
  String get communityCountryNamesPR => 'Porto Riko';

  @override
  String get communityCountryNamesPT => 'Portekiz';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Katar';

  @override
  String get communityCountryNamesRO => 'Romanya';

  @override
  String get communityCountryNamesRS => 'Sırbistan';

  @override
  String get communityCountryNamesRU => 'Rusya';

  @override
  String get communityCountryNamesSA => 'Suudi Arabistan';

  @override
  String get communityCountryNamesSE => 'İsveç';

  @override
  String get communityCountryNamesSG => 'Singapur';

  @override
  String get communityCountryNamesSI => 'Slovenya';

  @override
  String get communityCountryNamesSK => 'Slovakya';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Tayland';

  @override
  String get communityCountryNamesTL => 'Doğu Timor';

  @override
  String get communityCountryNamesTN => 'Tunus';

  @override
  String get communityCountryNamesTR => 'Türkiye';

  @override
  String get communityCountryNamesTW => 'Tayvan';

  @override
  String get communityCountryNamesUA => 'Ukrayna';

  @override
  String get communityCountryNamesUS => 'Amerika Birleşik Devletleri';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Özbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'Güney Afrika';

  @override
  String get communityCreateLfg => 'Takım arkadaşı ilanı oluştur';

  @override
  String get communityCreateLfgShort => 'İlan ver';

  @override
  String get communityDataDeleted => 'Topluluk verilerin silindi.';

  @override
  String communityDataFooter(String riotId) {
    return 'Kullanılan hesap için geçerlidir: $riotId. İndirilen dosya şifreni veya Riot giriş verilerini içermez.';
  }

  @override
  String get communityDataTitle => 'Topluluk verilerin';

  @override
  String get communityDecrease => 'Azalt';

  @override
  String get communityDelete => 'Sil';

  @override
  String get communityDeleteComment => 'Yorumu sil';

  @override
  String get communityDeleteCommentBody => 'Bu yorum kalıcı olarak silinecek.';

  @override
  String get communityDeleteCommentTitle => 'Yorum silinsin mi?';

  @override
  String get communityDeleteDataConfirm => 'Kalıcı olarak sil';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return '$riotId hesabının ValHub Topluluğu\'ndaki tüm gönderileri, yorumları, kaplama incelemeleri, beğenileri, oyları, takım arkadaşı ilanları ve fotoğrafları kalıcı olarak silinecek ve geri getirilemeyecek. Anonim göz atma moduna döneceksin ve tekrar katılmak istersen yeniden onay vermen gerekecek.\n\nRiot hesabın ve oyun içi verilerin etkilenmez. Bir kopyasını saklamak istiyorsan önce verilerini indir.';
  }

  @override
  String get communityDeleteDataConfirmTitle =>
      'Topluluk verileri silinsin mi?';

  @override
  String get communityDeleteDataSubtitle =>
      'Topluluk\'ta paylaştığın her şeyi kalıcı olarak sil.';

  @override
  String get communityDeleteDataTitle => 'Topluluk verilerimi sil';

  @override
  String get communityDeletePost => 'Gönderiyi sil';

  @override
  String get communityDeletePostBody =>
      'Bu gönderi ve tüm yorumları kalıcı olarak silinecek.';

  @override
  String get communityDeletePostTitle => 'Gönderi silinsin mi?';

  @override
  String get communityDeleteReview => 'İncelemeyi sil';

  @override
  String get communityDeleteReviewBody =>
      'Bu kaplama için verdiğin puan ve yazdığın inceleme silinecek.';

  @override
  String get communityDeleteReviewTitle => 'İncelemen silinsin mi?';

  @override
  String get communityDeleted => 'Silindi.';

  @override
  String get communityDiscard => 'Vazgeç';

  @override
  String get communityDiscardBody => 'Az önce yazdıkların kaydedilmeyecek.';

  @override
  String get communityDiscardTitle => 'Gönderiden vazgeçilsin mi?';

  @override
  String get communityDownload => 'İndir ve çevir';

  @override
  String get communityDownloadingModels => 'Dil paketi indiriliyor…';

  @override
  String get communityEditReview => 'Düzenle';

  @override
  String get communityEdited => 'düzenlendi';

  @override
  String get communityEmptyPost => 'Bir şeyler yaz veya fotoğraf ekle.';

  @override
  String get communityExpired => 'Süresi doldu';

  @override
  String communityExpiresIn(String t) {
    return 'Kalan: $t';
  }

  @override
  String get communityExportPreparing => 'Hazırlanıyor…';

  @override
  String get communityExportSubject => 'ValHub Topluluk verileri';

  @override
  String get communityExportSubtitle =>
      'Topluluk\'ta paylaştığın her şeyin bir kopyası: gönderiler, yorumlar, incelemeler, beğeniler, oylar ve takım arkadaşı ilanları.';

  @override
  String get communityExportTitle => 'Verilerimi indir';

  @override
  String get communityExtend => 'Uzat';

  @override
  String get communityExtended => 'İlan 30 dakika uzatıldı.';

  @override
  String get communityFeedEmptyBody =>
      'Mağazanı, Gece Pazarı\'nı veya en iyi anlarını ilk paylaşan sen ol!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Eşleşen gönderi yok. Başka bir dil dene veya filtreleri temizle.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Henüz yeni gönderi yok. Daha sonra tekrar uğra veya paylaşmak için katıl.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Uluslararası topluluğun gönderilerine bak veya filtreleri değiştir.';

  @override
  String get communityFeedEmptyScopeTitle => 'Burada henüz gönderi yok';

  @override
  String get communityFeedEmptyTitle => 'Akış boş';

  @override
  String get communityFilters => 'Filtreler';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Google tarafından çevrildi';

  @override
  String get communityHelpful => 'Faydalı';

  @override
  String communityHelpfulCount(String n) {
    return 'Faydalı · $n';
  }

  @override
  String get communityHiddenAuthors => 'Gizlenen ve engellenen oyuncular';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Henüz kimseyi gizlemedin veya engellemedin';

  @override
  String get communityHiddenAuthorsHint =>
      'Yalnızca bu cihazdaki bu hesap için geçerlidir. Onların içerikleri gizlenir; onlar senin herkese açık içeriklerini görmeye devam edebilir.';

  @override
  String communityImageOf(int i, int n) {
    return 'Fotoğraf $i/$n';
  }

  @override
  String get communityIncrease => 'Artır';

  @override
  String get communityJoin => 'Katıl';

  @override
  String get communityJoinCodeExpired =>
      'Grup kodunun süresi doldu veya artık geçerli değil.';

  @override
  String communityJoinConfirmBody(String name) {
    return '$name adlı oyuncunun grubuna katılmak için VALORANT\'taki mevcut grubundan ayrılacaksın.';
  }

  @override
  String get communityJoinConfirmTitle => 'Bu gruba katılınsın mı?';

  @override
  String get communityJoinGameNotRunning =>
      'VALORANT\'ı bilgisayarında veya konsolunda açıp tekrar dene.';

  @override
  String get communityJoinParty => 'Gruba katıl';

  @override
  String get communityJoinPartyFull => 'Bu grup dolu.';

  @override
  String get communityJoinedHint =>
      'Gruba katıldın! Birlikte oynamak için VALORANT\'ı aç.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString katılma isteği';
  }

  @override
  String get communityKindNightMarket => 'Gece Pazarı';

  @override
  String get communityKindStore => 'Bugünkü mağaza';

  @override
  String get communityLanguage => 'Dil';

  @override
  String get communityLanguageFilter => 'İçerik dili';

  @override
  String get communityLanguageFilterHint =>
      'Yalnızca seçilen dillerde yazılmış içerikleri göster. Hepsini görmek için boş bırak.';

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
    return '$n dil';
  }

  @override
  String get communityLfgEmptyBody =>
      'Diğer oyuncuların tek dokunuşla grubuna katılabilmesi için bir ilan oluştur.';

  @override
  String get communityLfgEmptyTitle => 'Henüz kimse takım arkadaşı aramıyor';

  @override
  String get communityLfgExpiredRepost =>
      'İlanının süresi doldu. Takım arkadaşı bulmak için yeni bir ilan oluştur.';

  @override
  String get communityLfgGateBody =>
      'Sunucundaki oyuncuların ilanlarını görmek ve kendi takım arkadaşı ilanını vermek için katıl (Riot ID\'ni bir kez doğrula). Akış\'a ve Kaplama sıralamalarına her zamanki gibi göz atabilirsin.';

  @override
  String get communityLfgGateTitle => 'Takım arkadaşı bulma üyelere özel';

  @override
  String communityLfgOtherShardNote(String region) {
    return '$region sunucusunu görüntülüyorsun — gruplara yalnızca hesabınla aynı sunucudaki oyuncular katılabilir.';
  }

  @override
  String get communityLfgPosted => 'Takım arkadaşı ilanı yayınlandı!';

  @override
  String get communityLfgPreviewTitle => 'Rütbene uygun takım arkadaşları bul';

  @override
  String get communityLfgRemoved => 'İlan kaldırıldı.';

  @override
  String get communityLfgSameShardNote =>
      'Gruba yalnızca aynı sunucudaki oyuncular katılabilir.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Bölge: $region · İlanların süresi 30 dakika sonra otomatik olarak dolar.';
  }

  @override
  String get communityLike => 'Beğen';

  @override
  String get communityLiveMembers => 'Üyeler';

  @override
  String get communityMatchMyRank => 'Rütbene uygun';

  @override
  String communityMemberJoined(String name) {
    return '$name gruba katıldı';
  }

  @override
  String get communityMemberJoinedBody =>
      'Takım arkadaşı ilanın üzerinden biri az önce katıldı.';

  @override
  String get communityMic => 'Mikrofon gerekli';

  @override
  String get communityMicOn => 'Mikrofonlu';

  @override
  String get communityMode => 'Mod';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Diğer seçenekler';

  @override
  String get communityMuteAuthor => 'Bu oyuncuyu gizle';

  @override
  String get communityNewPost => 'Paylaş';

  @override
  String communityNightMarketOf(String date) {
    return 'Gece Pazarı · $date';
  }

  @override
  String get communityNoAccountBody =>
      'Gönderi paylaşmak, takım arkadaşı bulmak ve kaplamalara oy vermek için bir Riot hesabı ekle.';

  @override
  String get communityNoAccountTitle => 'Katılmak için giriş yap';

  @override
  String get communityNoComments => 'Henüz yorum yok. İlk yorumu sen yap!';

  @override
  String get communityNoRatings => 'Henüz puan yok';

  @override
  String get communityNote => 'Not';

  @override
  String get communityNoteHint =>
      'Örn. 1 Kontrol Uzmanı lazım, mikrofon açık, sadece eğlence için';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Toplam: $amount';
  }

  @override
  String get communityOpenReviews => 'İncelemeleri gör';

  @override
  String get communityOutOfRange => 'Rütbe aralığı dışında';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Grup kodu';

  @override
  String get communityPartyCodeHint => 'Örn. A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Grup kodu: $code';
  }

  @override
  String get communityPartySize => 'Mevcut grup';

  @override
  String get communityPartySizeFromGame => 'Oyundaki grubundan alındı';

  @override
  String communityPartySizeValue(int n) {
    return '$n oyuncu';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max fotoğraf';
  }

  @override
  String get communityPlayVideo => 'Videoyu izle';

  @override
  String get communityPostLfg => 'İlan ver';

  @override
  String get communityPostNotFound => 'Bu gönderi silinmiş veya gizlenmiş.';

  @override
  String get communityPostTitle => 'Gönderi';

  @override
  String get communityPosted => 'Paylaşıldı!';

  @override
  String get communityPublish => 'Paylaş';

  @override
  String get communityPublishing => 'Paylaşılıyor…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'En düşük';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Rütbe aralığı';

  @override
  String get communityRankRangeInvalid =>
      'En düşük rütbe, en yüksek rütbeden yüksek olamaz.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Sıra $n: $name';
  }

  @override
  String get communityRankTo => 'En yüksek';

  @override
  String get communityRateLimitedTitle => 'Biraz bekle';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString puan';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString puan';
  }

  @override
  String get communityRatingWordsItem0 => 'Kötü';

  @override
  String get communityRatingWordsItem1 => 'Vasat';

  @override
  String get communityRatingWordsItem2 => 'İdare eder';

  @override
  String get communityRatingWordsItem3 => 'Harika';

  @override
  String get communityRatingWordsItem4 => 'Başyapıt';

  @override
  String get communityRefreshList => 'Yenile';

  @override
  String get communityRegion => 'Bölge';

  @override
  String get communityRemoveAttachment => 'Eki kaldır';

  @override
  String get communityRemoveLfg => 'İlanı kaldır';

  @override
  String get communityRemoveLfgBody =>
      'Diğer oyuncular bu ilanı artık göremeyecek.';

  @override
  String get communityRemoveLfgTitle => 'Takım arkadaşı ilanı kaldırılsın mı?';

  @override
  String get communityRemovePhoto => 'Fotoğrafı kaldır';

  @override
  String get communityReport => 'Bildir';

  @override
  String get communityReportConfirmBody =>
      'Çok sayıda oyuncu tarafından bildirilen içerikler Topluluk\'tan gizlenir.';

  @override
  String get communityReportConfirmTitle => 'Bildirim gönderilsin mi?';

  @override
  String get communityReportPrompt => 'Bu içeriği neden bildiriyorsun?';

  @override
  String get communityReportReasonsSpam => 'Spam veya reklam';

  @override
  String get communityReportReasonsHarassment => 'Taciz veya hakaret';

  @override
  String get communityReportReasonsInappropriate => 'Uygunsuz içerik';

  @override
  String get communityReportReasonsScam => 'Dolandırıcılık veya hesap satışı';

  @override
  String get communityReportReasonsOther => 'Başka bir neden';

  @override
  String get communityReportTitle => 'İçeriği bildir';

  @override
  String get communityReported => 'Teşekkürler! Bildirimin gönderildi.';

  @override
  String get communityReviewDeleted => 'İnceleme silindi.';

  @override
  String get communityReviewHint =>
      'Bu kaplama hakkındaki düşüncelerini paylaş (isteğe bağlı)';

  @override
  String get communityReviewSaved => 'İnceleme kaydedildi!';

  @override
  String get communityReviewTitle => 'Kaplamayı puanla';

  @override
  String get communityReviewsEmptyBody => 'Henüz inceleme yok — ilk sen yaz!';

  @override
  String get communityReviewsEmptyTitle => 'Henüz inceleme yok';

  @override
  String communityReviewsHeader(String n) {
    return 'İncelemeler · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot sorun yaşıyor';

  @override
  String get communityRoleFlex => 'Esnek';

  @override
  String get communityRoles => 'Gereken roller';

  @override
  String get communitySaveReview => 'İncelemeyi kaydet';

  @override
  String get communityScopeCountry => 'Ülken';

  @override
  String get communityScopeGlobal => 'Uluslararası';

  @override
  String get communityScopeRegion => 'Bölge';

  @override
  String get communitySectionFeed => 'Akış';

  @override
  String get communitySectionLfg => 'Takım bul';

  @override
  String get communitySectionSkins => 'Kaplama sıralaması';

  @override
  String get communitySend => 'Gönder';

  @override
  String get communitySendComment => 'Yorumu gönder';

  @override
  String get communityShareNightMarketHint => 'Gece Pazarı\'nı herkese göster';

  @override
  String communitySharePostTitle(String name) {
    return '$name adlı oyuncunun ValHub gönderisi';
  }

  @override
  String get communityShareStore => 'Topluluk\'ta paylaş';

  @override
  String get communityShareStoreHint => 'Bugünkü mağazanı herkese göster';

  @override
  String get communityShowOriginal => 'Orijinali göster';

  @override
  String get communityShowTranslation => 'Çeviriyi göster';

  @override
  String get communitySignInToReview =>
      'Kaplamaları puanlamak için bir Riot hesabı ekle.';

  @override
  String get communitySkinNotFound => 'Bu kaplama bulunamadı.';

  @override
  String get communitySlots => 'Gereken oyuncu';

  @override
  String communitySlotsTooMany(int max) {
    return 'Bir grupta en fazla 5 oyuncu olabilir: yalnızca $max yer kaldı.';
  }

  @override
  String communitySlotsWanted(int n) {
    return '$n oyuncu aranıyor';
  }

  @override
  String get communitySortHelpful => 'En faydalı';

  @override
  String get communitySortNewest => 'En yeni';

  @override
  String get communitySortRating => 'En yüksek puanlı';

  @override
  String get communitySortReviews => 'En çok incelenen';

  @override
  String get communitySortVotes => 'En sevilen';

  @override
  String communityStarLabel(int n) {
    return '$n yıldız';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '5 üzerinden $avg yıldız';
  }

  @override
  String get communityStatusFull => 'Dolu';

  @override
  String get communityStatusInGame => 'Maçta';

  @override
  String get communityStatusOpen => 'Arıyor';

  @override
  String communityStoreOf(String date) {
    return 'Mağaza · $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate =>
      'Bu kaplamayı puanlamak için yıldızlara dokun';

  @override
  String get communityTitle => 'Topluluk';

  @override
  String communityTooLong(int max) {
    return 'En fazla $max karakter.';
  }

  @override
  String get communityTranslate => 'Google ile çevir';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Çeviri için ($from → $to) ValHub\'ın Google\'dan bir dil paketi indirmesi gerekiyor (yaklaşık $size). Yalnızca bir kez indirilir; içerik tamamen cihazında çevrilir ve hiçbir sunucuya gönderilmez.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Cihaz içi dil paketi indirilsin mi?';

  @override
  String get communityTranslateFailed => 'Çevrilemedi. Tekrar dene.';

  @override
  String get communityTranslatedByGoogle =>
      'Google tarafından otomatik çevrildi';

  @override
  String get communityTranslating => 'Çevriliyor…';

  @override
  String get communityTrendingTitle => 'Dünya genelinde en sevilen kaplamalar';

  @override
  String get communityUnavailableBody =>
      'ValHub Topluluğu\'na bağlanılamadı. Birkaç dakika sonra tekrar dene.';

  @override
  String get communityUnavailableTitle => 'Topluluk\'a bağlanılamadı';

  @override
  String get communityUnhideAuthor => 'Göster / engeli kaldır';

  @override
  String get communityUnknownPlayer => 'Oyuncu';

  @override
  String get communityUnlike => 'Beğeniyi geri al';

  @override
  String get communityUnvote => 'Kalbi kaldır';

  @override
  String get communityVote => 'Bu kaplamaya kalp bırak';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString beğeni';
  }

  @override
  String get communityWithdrawConfirm => 'Geri çek';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub, Topluluk\'u $riotId hesabıyla kullanmayı bırakacak: bu cihazdaki Topluluk bağlantısı kaldırılır ve anonim göz atma moduna dönersin.\n\nPaylaştığın gönderiler, yorumlar, incelemeler, oylar ve takım arkadaşı ilanları Topluluk\'ta kalır ve sen onları tek tek silene veya \"Topluluk verilerimi sil\" seçeneğini seçene kadar Riot ID\'ni göstermeye devam eder. İstediğin zaman tekrar katılabilirsin.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Onay geri çekilsin mi?';

  @override
  String get communityWithdrawSubtitle =>
      'Topluluk\'u bu hesapla kullanmayı bırak. Gönderilerin korunur.';

  @override
  String get communityWithdrawTitle => 'Onayı geri çek';

  @override
  String get communityWriteFirstReview => 'İlk incelemeyi yaz';

  @override
  String get communityYou => 'Sen';

  @override
  String get communityYourCountry => 'Ülken';

  @override
  String get communityYourReview => 'İncelemen';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Sen: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Ajan seçimi';

  @override
  String get liveGameAnonymous => 'Anonim';

  @override
  String get liveGameAutoRefreshNote => 'Maçtayken otomatik olarak yenilenir.';

  @override
  String get liveGameCurrentGame => 'Mevcut maç';

  @override
  String get liveGameEmptyTeam => 'Henüz oyuncu yok.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Rakip takım maç başladığında görünür.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Rakip takım kilitledi: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Bu canlı maç verisi Leş/Ölüm/Asist bilgisi sağlamıyor. Skor tablosu, Riot maç sonu verilerini yayınladığında görünür.';

  @override
  String get liveGameFinalScoreboard => 'Maç sonu skor tablosu';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'Lobide';

  @override
  String get liveGameInMatch => 'Maçta';

  @override
  String get liveGameInQueue => 'Sırada';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Sırada · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Seviye $n';
  }

  @override
  String get liveGameLiveScore => 'Canlı skor';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Ajan seçimindeki kuşanım';

  @override
  String get liveGameLoadoutFromMatch => 'Bu maçtaki kuşanım';

  @override
  String get liveGameLobbyHint =>
      'Maç bulunduğunda ValHub herkesin kadrosunu ve rütbesini gösterir.';

  @override
  String get liveGameLockedTag => 'Kilitlendi';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub otomatik olarak tekrar deneyecek. Skor tablosu genellikle yaklaşık bir dakika içinde hazır olur.';

  @override
  String get liveGameNoAgentYet => 'Ajan seçilmedi';

  @override
  String get liveGameNoLoadout => 'Bu oyuncunun kuşanım bilgisi yok.';

  @override
  String get liveGameNotInGame => 'Maçta değil';

  @override
  String get liveGameNotInGameHint =>
      'VALORANT\'ı aç ve sıraya gir — ajan seçimine geldiğinde maç ayrıntıları burada otomatik olarak görünür.';

  @override
  String get liveGameNotInGameTitle => 'Bir maçta değilsin';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return '$name adlı oyuncunun kuşanımını gör';
  }

  @override
  String get liveGameOpenParty => 'Grubu ve sırayı aç';

  @override
  String get liveGameParty => 'Grup';

  @override
  String liveGamePeak(String rank) {
    return 'En yüksek: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Kuşanım: $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Kuşanım';

  @override
  String get liveGameQueueHint =>
      'Uygulamayı açık tut — maç bulunur bulunmaz ayrıntılar görünür.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Maçtan ayrılmak ceza almana (RR kaybı, sıra kısıtlaması) yol açabilir. Yine de ayrılmak istiyor musun?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Ajan seçiminde maçtan kaçmak ceza almana (RR kaybı, sıra kısıtlaması) yol açabilir. Yine de ayrılmak istiyor musun?';

  @override
  String get liveGameQuitConfirmTitle => 'Maçtan ayrılınsın mı?';

  @override
  String get liveGameQuitDone => 'Maçtan ayrıldın.';

  @override
  String get liveGameQuitFailed => 'Maçtan ayrılamadın.';

  @override
  String get liveGameQuitMatch => 'Maçtan ayrıl';

  @override
  String get liveGameQuitMatchChanged =>
      'Sen onaylarken maç yeni bir aşamaya geçti. Maçtan ayrılmadın; tekrar dene.';

  @override
  String get liveGameRankUnavailable => 'Rütbe bilinmiyor';

  @override
  String get liveGameRefresh => 'Yenile';

  @override
  String liveGameRefreshIn(int seconds) {
    return '$seconds saniye içinde yenilenecek';
  }

  @override
  String get liveGameRefreshNow => 'Şimdi yenile';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Maç ayrıntıları';

  @override
  String get liveGameSprays => 'Spreyler';

  @override
  String get liveGameStatusAgentSelect => 'Ajan seçimi';

  @override
  String get liveGameStatusEnded => 'Bitti';

  @override
  String get liveGameStatusInProgress => 'Devam ediyor';

  @override
  String get liveGameStatusUnavailable => 'Maç durumu güncellenemedi';

  @override
  String get liveGameTabAllPlayers => 'Oyuncular';

  @override
  String get liveGameTabEnemyTeam => 'Rakip takım';

  @override
  String get liveGameTabYourTeam => 'Takımın';

  @override
  String liveGameTimeLeft(String t) {
    return 'Kalan: $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Maç ayrıntılarını gör';

  @override
  String get liveGameWeapons => 'Silahlar';

  @override
  String get liveGameYou => 'SEN';

  @override
  String liveGameYouHover(String agent) {
    return 'Seçtiğin ajan: $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Kilitlediğin ajan: $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Ajanını VALORANT\'ta seç ve kilitle. ValHub yalnızca kalan süreyi ve takımını gösterir.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws beraberlik',
      one: ' – $draws beraberlik',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – sonucu bilinmeyen $unknown maç',
      one: ' – sonucu bilinmeyen $unknown maç',
      zero: '',
    );
    return '$wins galibiyet – $losses mağlubiyet$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'cihaz saati ($offset)';
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
      'yes': ' · $weapon',
      'other': '',
    });
    return '$killer, $victim oyuncusunu indirdi$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 gün',
      'days7': '7 gün',
      'other': 'Tüm zamanlar',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Ajanlar',
      'maps': 'Haritalar',
      'queues': 'Modlar',
      'sides': 'Saldırı / Savunma',
      'trend': 'Eğilim',
      'other': 'Modlar',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Tüm modlar';

  @override
  String get profileAbility => 'Yetenek';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n maç';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Ortalama savaş skoru';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return 'Bu kısım: $wins galibiyet / $games maç · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Tüm oyuncular';

  @override
  String get profileAlreadyReached => 'Bu rütbeye zaten ulaştın.';

  @override
  String get profileAtCurrentForm => 'Mevcut formunla';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Mevcut formunla (maç başına $gain / $loss)';
  }

  @override
  String profileBestCase(int n) {
    return 'En iyi ihtimal: üst üste $n galibiyet';
  }

  @override
  String get profileByWinRateTitle => 'Kazanma oranına göre';

  @override
  String get profileChooseMap => 'Haritaya göre filtrele';

  @override
  String get profileColA => 'A';

  @override
  String get profileColD => 'Ö';

  @override
  String get profileColK => 'L';

  @override
  String get profileColPlace => '#';

  @override
  String get profileColPlusMinus => '+/−';

  @override
  String get profileCopyRiotId => 'Riot ID\'yi kopyala';

  @override
  String get profileCurrentRank => 'Mevcut';

  @override
  String get profileDailyRrEmpty =>
      'Bu cihaza henüz Rekabete Dayalı maç kaydedilmedi.';

  @override
  String get profileDailyRrFootnote =>
      'RR geçmişi doğrudan cihazına kaydedilir; Riot\'un artık göstermediği maçlar da buna dahildir.';

  @override
  String get profileDailyRrTitle => 'Günlük RR';

  @override
  String profileDayBoundary(String zone) {
    return 'Günler şuna göre hesaplanır: $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return 'Oynanan gün: $n';
  }

  @override
  String get profileEndOfHistory => 'Tüm maçlar gösterildi';

  @override
  String get profileEnemyTeam => 'Rakip takım';

  @override
  String get profileFallDamage => 'Düşme hasarı';

  @override
  String get profileFilterAll => 'Tümü';

  @override
  String get profileFirstBloods => 'İlk kan';

  @override
  String get profileFirstDeaths => 'İlk ölümler';

  @override
  String get profileFirstHalf => 'İlk yarı';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS ve HS% yalnızca raunt tabanlı modlarda hesaplanır.';

  @override
  String profileFormPending(int n) {
    return 'Listedeki $n maç bu istatistikler için henüz yüklenmedi.';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR ve HS% yalnızca $roundGames/$games raunt tabanlı maçı hesaba katar';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return 'Son $games maç: $w galibiyet, $l mağlubiyet';
  }

  @override
  String get profileFriendsRow => 'Arkadaşlar ve sohbet';

  @override
  String get profileHideKills => 'Leşleri gizle';

  @override
  String get profileHitBody => 'Gövde';

  @override
  String get profileHitDistribution => 'İsabet dağılımı';

  @override
  String get profileHitHead => 'Kafa';

  @override
  String get profileHitLegs => 'Bacak';

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
      'Leş aldığın, asist yaptığın, hayatta kaldığın veya intikamın alındığı rauntların oranı';

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
    return 'Son $n gün';
  }

  @override
  String profileLastMatches(int n) {
    return 'Son $n maç';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Sıralama tablosu #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Seviye $n';
  }

  @override
  String get profileLevelHidden => 'Seviye gizli';

  @override
  String profileLossStreak(int n) {
    return '$n maçlık mağlubiyet serisi';
  }

  @override
  String profileMapFilter(String map) {
    return 'Harita: $map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n maç';
  }

  @override
  String get profileMatchDetailTitle => 'Maç ayrıntıları';

  @override
  String get profileMatchHistory => 'Maç geçmişi';

  @override
  String get profileMatchUnavailable => 'Maç yüklenemedi';

  @override
  String get profileMatchesNeeded => 'Gereken maç';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Hiç derecelendirilmedi';

  @override
  String get profileNoKillsInRound => 'Bu raunt için henüz leş bilgisi yok.';

  @override
  String get profileNoMatches => 'Henüz maç yok.';

  @override
  String get profileNoMatchesMap =>
      'Yüklenen maçlar arasında bu haritada oynanan maç yok.';

  @override
  String get profileNoMatchesQueue => 'Bu modda maç yok.';

  @override
  String get profileNoPlayers => 'Bu maç için henüz oyuncu bilgisi yok.';

  @override
  String get profileNoRounds => 'Bu maç için henüz raunt raunt bilgi yok.';

  @override
  String get profileOvertime => 'Uzatma';

  @override
  String get profilePlayHubTitle => 'Maç ve grup';

  @override
  String get profilePeakRank => 'En yüksek';

  @override
  String get profilePerformanceAttack => 'Saldırı';

  @override
  String get profilePerformanceDefense => 'Savunma';

  @override
  String get profilePerformanceEmpty =>
      'Bu cihaza henüz maç kaydedilmedi. Oynadığın maçları kaydetmek için maç geçmişini aç.';

  @override
  String get profilePerformanceNoMatches => 'Seçilen zaman aralığında maç yok.';

  @override
  String profilePerformanceRounds(int n) {
    return 'Kaydedilen raunt: $n';
  }

  @override
  String get profilePerformanceSample =>
      'Oranlar yalnızca en az 3 maç olduğunda gösterilir. ACS, ADR, HS% ve K/D yalnızca raunt tabanlı modlarda hesaplanır.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Saldırı veya savunma tarafı $known/$total rauntta belirlendi.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Bu cihazdaki geçmiş, başlangıç: $date';
  }

  @override
  String get profilePerformanceTitle => 'Performans';

  @override
  String profilePlacement(int n) {
    return 'Sıra $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike kuruldu: $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Oyuncu profili';

  @override
  String get profilePlayerSummary => 'Performans';

  @override
  String profileProgressTo(String rank) {
    return 'Hedef: $rank';
  }

  @override
  String get profileProgressToTarget => 'Hedef rütbeye ilerleme';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Son Rekabete Dayalı maçlara dayalı bir tahmindir; yerleştirme maçlarını ve rütbe düşme korumasını hesaba katmaz.';

  @override
  String profileRankUpHint(int matches, String rank) {
    return 'Hedef $rank: ≈ $matches maç';
  }

  @override
  String get profileRankUpImmortal =>
      'Zaten Ölümsüzlük veya daha yüksek rütbedesin — bu araç yalnızca Ölümsüzlük 1\'e kadar hesaplar.';

  @override
  String get profileRankUpNoForm =>
      'Formunu tahmin etmek için son zamanlarda oynanmış Rekabete Dayalı maç yok.';

  @override
  String get profileRankUpOpen => 'Rütbe atlama hesaplayıcısını aç';

  @override
  String get profileRankUpTitle => 'Rütbe atlama hesaplayıcısı';

  @override
  String get profileRankUpUnranked =>
      'Rütbe atlama hesaplayıcısını kullanmak için yerleştirme maçlarını tamamla.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Rekabete Dayalı skor tablosu';

  @override
  String profileRecentForm(int w, int l) {
    return 'Son form: $w galibiyet – $l mağlubiyet';
  }

  @override
  String get profileRecentFormTitle => 'Son form';

  @override
  String get profileRecentMatches => 'Son maçlar';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}G · ${l}M · ${d}B',
      one: '${w}G · ${l}M · ${d}B',
      zero: '${w}G · ${l}M',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID kopyalandı';

  @override
  String profileRound(int n) {
    return 'Raunt $n';
  }

  @override
  String profileRoundKills(int n) {
    return '$n leş';
  }

  @override
  String get profileRoundLost => 'Raunt kaybedildi';

  @override
  String get profileRoundTimeline => 'Raunt akışı';

  @override
  String get profileRoundWon => 'Raunt kazanıldı';

  @override
  String get profileRoundsHint => 'Her leşi görmek için bir raunda dokun.';

  @override
  String profileRrLeft(String n) {
    return 'Kalan: $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR eğilimi';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Skor tablosu';

  @override
  String get profileSecondHalf => 'İkinci yarı';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Leşleri göster';

  @override
  String get profileSideSwitch => 'Taraf değişimi';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Hedef rütbe';

  @override
  String get profileTeamBlue => 'Mavi takım';

  @override
  String get profileTeamMvp => 'Takım MVP\'si';

  @override
  String get profileTeamRed => 'Kırmızı takım';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileToday(String text) {
    return 'Bugün: $text';
  }

  @override
  String get profileTodayNone => 'Bugün Rekabete Dayalı maç yok';

  @override
  String get profileTruePeakLocal => 'Bu cihazdaki geçmişe göre';

  @override
  String get profileWeekdayShortItem0 => 'Pzt';

  @override
  String get profileWeekdayShortItem1 => 'Sal';

  @override
  String get profileWeekdayShortItem2 => 'Çar';

  @override
  String get profileWeekdayShortItem3 => 'Per';

  @override
  String get profileWeekdayShortItem4 => 'Cum';

  @override
  String get profileWeekdayShortItem5 => 'Cmt';

  @override
  String get profileWeekdayShortItem6 => 'Paz';

  @override
  String get profileWinRate => 'Kazanma oranı';

  @override
  String profileWinStreak(int n) {
    return '$n maçlık galibiyet serisi';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Rütben';

  @override
  String get profileYourSummary => 'Performansın';

  @override
  String get profileYourTeam => 'Takımın';

  @override
  String get profileYourWinRate => 'Son kazanma oranın';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Mod: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Moda göre filtrele';

  @override
  String get profilePerformancePerMatchTitle => 'Maç maç';

  @override
  String get profilePerformancePerMatchHint =>
      'Maçı açmak için bir çubuğa dokun.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Ortalama $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Grafik için bu istatistiğe sahip en az 2 raunt tabanlı maç gerekir.';

  @override
  String get profilePerformanceOpeningsTitle => 'Açılış düelloları';

  @override
  String get profilePerformanceOpeningWin => 'Kazanılan açılış düelloları';

  @override
  String get profilePerformanceOpeningWinHint =>
      'İlk leşi aldığın ya da ilk öldüğün rauntlar içinde ilk leşi aldığın rauntların oranı.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'Maç başına ilk kan';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Maç başına ilk ölüm';

  @override
  String get profilePerformanceMultiKillsTitle => 'Bir rauntta çoklu leş';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 leş',
      'k4': '4 leş',
      'ace': 'Ace',
      'other': '2 leş',
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
      other: 'Tam leş verisi olan $nString maça göre hesaplanır.',
      one: 'Tam leş verisi olan $nString maça göre hesaplanır.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Kazanılan rauntlar';

  @override
  String get profilePerformanceDrillHint =>
      'Yalnızca o ajanı, haritayı ya da modu görmek için bir satıra dokun.';

  @override
  String get profilePerformanceLoadOlder => 'Eski maçları analiz et';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub yalnızca bu cihazda açılan maçları analiz eder. Her dokunuşta en fazla $nString eski maç eklenir.';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Daha eski maçlar aranıyor…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Maçlar analiz ediliyor: $doneString/$totalString…';
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
      other: 'Analize $nString maç eklendi.',
      one: 'Analize $nString maç eklendi.',
      zero: 'Eklenecek yeni maç yok.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'Riot daha eski maçları saklamıyor.';

  @override
  String get profileEconomyTitle => 'Takımının ekonomisi';

  @override
  String get profileEconomyHint =>
      'Satın alma türü, raunt başında takımının toplam ekipman değerine göre belirlenir (5 oyuncu için vlr.gg kuralı): Eco 5.000 altı, Semi-eco 10.000 altı, Semi-buy 20.000 altı, Full buy 20.000 kredi ve üstü. Her yarının ilk rauntu Pistol rauntudur.';

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

    return 'Kazanılan $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'VALORANT yol arkadaşın: günlük mağaza, istek listesi, rütbe, maçlar, birden fazla hesap ve oyuncu topluluğu, hepsi cihazında.';

  @override
  String get legalBackToTop => 'Başa dön';

  @override
  String get legalConsentAnd => ' ve ';

  @override
  String get legalConsentPrefix => 'Devam ederek ValHub ';

  @override
  String get legalConsentPrivacy => 'Gizlilik Politikası';

  @override
  String get legalConsentSuffix => ' belgelerini kabul etmiş olursun.';

  @override
  String get legalConsentTerms => 'Kullanım Koşulları';

  @override
  String get legalContact => 'İletişim';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'İLETİŞİM';

  @override
  String legalEffectiveFrom(String date) {
    return 'Yürürlük tarihi: $date';
  }

  @override
  String get legalLegalHeader => 'YASAL';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Tüm hakları saklıdır.';

  @override
  String get legalThirdPartyLicenses => 'Üçüncü taraf yazılımlar';

  @override
  String get legalThirdPartyLicensesBody =>
      'ValHub\'ın kullandığı açık kaynak yazılımların lisansları';

  @override
  String get legalTocTitle => 'İÇİNDEKİLER';

  @override
  String legalVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Bu belge şu anda şu dilde gösteriliyor: $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Yasal belge okunamadı. Tekrar dene veya destek ekibiyle iletişime geç.';

  @override
  String get legalTranslationNotice =>
      'Bu çeviri kolaylık sağlamak amacıyla sunulmuştur. Farklılık olması hâlinde Vietnamca sürüm geçerlidir.';

  @override
  String get settingsUiLanguageTitle => 'Uygulama dili';

  @override
  String get settingsLanguageFollowDevice => 'Cihaz dilini kullan';

  @override
  String get settingsLanguageSaveFailed =>
      'Dil kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get settingsGeoCountry => 'Ülke';

  @override
  String get settingsGeoSearchCountry => 'Ülke adı veya kodu ara';

  @override
  String get settingsGeoSupportedOnly => 'Yalnızca desteklendiği doğrulananlar';

  @override
  String get settingsGeoUnknown => 'Destek doğrulanmadı';

  @override
  String get settingsGeoRestricted => 'Kısıtlı';

  @override
  String get settingsGeoSeparate => 'Ayrı hizmet';

  @override
  String get settingsGeoAvailable => 'Destekleniyor';

  @override
  String get settingsGeoNotApplicable => 'Geçerli değil';

  @override
  String get settingsGeoConnection => 'Riot bağlantısı';

  @override
  String get settingsGeoChooseRegion => 'Bölge seç';

  @override
  String get settingsGeoAuto => 'Hesaba göre otomatik';

  @override
  String get settingsGeoManual => 'Elle seç';

  @override
  String get settingsGeoNoRegion => 'Riot bölgen belirlenemedi';

  @override
  String get settingsGeoManualWarning =>
      'Bu seçenek yalnızca ValHub\'ın bağlandığı sunucuyu değiştirir. Riot hesabının bölgesini değiştirmez. ValHub kaydetmeden önce bağlantıyı kontrol eder.';

  @override
  String get settingsGeoConnectionSaved => 'Bağlantı kaydedildi';

  @override
  String get settingsGeoValidationFailed =>
      'Hesabın bu sunucuda doğrulanamadı. Bölgeni yeniden seç.';

  @override
  String get settingsGeoHintOnly =>
      'Ülke yalnızca arama ve öneriler için kullanılır. Bağlantı bölgen Riot hesabına göre belirlenir.';

  @override
  String get settingsGeoSave => 'Kontrol et ve kaydet';

  @override
  String get settingsGeoCancel => 'İptal';

  @override
  String get settingsGeoLoading => 'Bağlantı kontrol ediliyor…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Bu seçim ülke adları, öneriler ve tahmini VP fiyatları için kullanılır. Sunucu bağlantın ve Topluluk hesabının ülkesi yine Riot tarafından belirlenir.';

  @override
  String get settingsGeoCountryAutomatic => 'Hesap veya cihaz ülkesini kullan';

  @override
  String get settingsGeoSaveFailed => 'Seçimin kaydedilemedi. Tekrar dene.';

  @override
  String get settingsGeoAllRegions => 'Tüm bölgeler';

  @override
  String get settingsGeoSuggestions => 'Öneriler';

  @override
  String get settingsGeoNoCountries => 'Filtreyle eşleşen ülke yok.';

  @override
  String get settingsGeoActiveCountries => 'Aktif';

  @override
  String get settingsGeoAllCountries => 'Tüm ülkeler';

  @override
  String get settingsGeoActivityUnavailable =>
      'Ülke etkinlikleri yüklenemedi. Yine de Tüm ülkeler listesinden seçim yapabilirsin.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ülke',
      one: '$count ülke',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Seçtiğin bölge: $manual. Ancak Riot hesabını şu bölgede gösteriyor: $detected. Bu bağlantıyı kontrol etmeye devam edilsin mi?';
  }

  @override
  String get settingsGeoUnverified =>
      'Sunucu veya ağ sorun yaşadığı için bağlantı doğrulanamadı. Bu seçim kaydedilip daha sonra tekrar denensin mi?';

  @override
  String get settingsGeoContinue => 'Devam et';

  @override
  String settingsGeoMismatch(String region) {
    return 'Elle seçtiğin bağlantı Riot bölgenden farklı: $region. Otomatik moda geçilsin mi?';
  }

  @override
  String get settingsGeoUseAuto => 'Otomatik kullan';

  @override
  String get settingsGeoKeepManual => 'Elle seçileni koru';

  @override
  String get settingsGeoReviewConnection => 'Bağlantıyı gör';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Son kontrol: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Tekrar kontrol et';

  @override
  String get settingsPlatformMobile => 'Mobil';

  @override
  String get settingsPlatformOther => 'Diğer platform';

  @override
  String get settingsContentLanguageFollowApp => 'Uygulama diliyle aynı';

  @override
  String get settingsContentLanguageHint =>
      'Öğe adlarının dilini seç. Bu seçim uygulama dilini veya Riot sunucunu değiştirmez.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Dil: $language.';
  }

  @override
  String get settingsAboutHeader => 'BİLGİ';

  @override
  String get settingsAboutRowSubtitle =>
      'Gizlilik, koşullar, telif hakkı ve iletişim';

  @override
  String get settingsAboutTitle => 'Hakkında ve yasal';

  @override
  String get settingsAppHeader => 'GELİŞMİŞ';

  @override
  String get settingsAppearanceHeader => 'GÖRÜNÜM';

  @override
  String settingsBuildNumber(String build) {
    return 'Derleme $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Temizlendi: $size';
  }

  @override
  String get settingsClearCache => 'Geçici verileri temizle';

  @override
  String get settingsClearCacheFailed =>
      'Geçici veriler temizlenemedi. Tekrar dene.';

  @override
  String get settingsClearCacheSubtitle =>
      'Cihazına indirilen görseller ve veriler, kaydedilen hata raporları dahil';

  @override
  String get settingsExportLog => 'ValHub\'a hata raporu gönder';

  @override
  String get settingsExportLogEmpty =>
      'Henüz gönderilecek bir şey yok. Uygulamayı bir süre kullanıp tekrar dene.';

  @override
  String get settingsExportLogSubtitle =>
      'Hata raporları şifreni veya Riot giriş verilerini içermez.';

  @override
  String get settingsFeedback => 'ValHub\'a geri bildirim gönder';

  @override
  String get settingsFeedbackSubtitle =>
      'ValHub\'ın geri bildirim sayfasını aç';

  @override
  String get settingsItemLanguageEn => 'İngilizce';

  @override
  String get settingsItemLanguageLabel => 'Öğe adları';

  @override
  String get settingsItemLanguagePickerTitle => 'Öğe adı dili';

  @override
  String get settingsItemLanguageVi => 'Vietnamca';

  @override
  String get settingsLinkOpenFailed => 'Bağlantı açılamadı. Tekrar dene.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Hata raporu';
  }

  @override
  String get settingsLogShareFailed =>
      'Hata raporu gönderilemedi. Tekrar dene.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Gece Pazarı açıldığında';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Gece Pazarı tekliflerini çevirmeni hatırlatır';

  @override
  String get settingsNotifPermissionMissing =>
      'Uygulamanın bildirim gönderme izni yok.';

  @override
  String get settingsNotifStoreReset => 'Mağaza yenilendiğinde';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Her gün $time';
  }

  @override
  String get settingsNotifWishlist =>
      'İstek listendeki bir kaplama göründüğünde';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Uygulama kapalıyken bile tüm hesapların mağazasını kontrol eder';

  @override
  String get settingsNotificationsHeader => 'BİLDİRİMLER';

  @override
  String get settingsOptionAutoOpenLiveGame => 'Maç ayrıntılarını otomatik aç';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Maç bulunur bulunmaz mevcut maç panelini aç';

  @override
  String get settingsOptionOwnPrice => 'VP paketi fiyatın';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Girilmedi — varsa bölgenin fiyat listesi kullanılır';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Platform';

  @override
  String get settingsOptionShowLiveScore => 'Canlı skoru göster';

  @override
  String get settingsOptionShowPeakRank =>
      'Maç ayrıntılarında en yüksek rütbeyi göster';

  @override
  String get settingsOptionShowPrice => 'Tahmini fiyatları göster';

  @override
  String get settingsOptionShowPriceInfo => 'Tahmini fiyatlar nasıl hesaplanır';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'VP fiyatlarının yanında, örn. $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Bölgen için henüz doğrulanmış bir fiyat listesi yok — VP paketi fiyatını gir.';

  @override
  String get settingsOptionsHeader => 'SEÇENEKLER';

  @override
  String get settingsPhaseComplete => 'Tamamlandı';

  @override
  String get settingsPhaseInProgress => 'Devam ediyor';

  @override
  String get settingsPhaseScheduled => 'Planlandı';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Geçerli olduğu hesap: $account';
  }

  @override
  String get settingsPlatformHint =>
      'Doğru maç geçmişini görmek için oynadığın yere göre PC, PlayStation veya Xbox seç.';

  @override
  String get settingsPlatformPickerTitle => 'Platform seç';

  @override
  String get settingsPrimingBody =>
      'Mağazan yenilendiğinde ve istek listendeki bir kaplama göründüğünde haberdar olmak için bildirimleri aç.';

  @override
  String get settingsPrimingEnable => 'Bildirimleri aç';

  @override
  String get settingsPrimingFootnote =>
      'Her bildirim türünü istediğin zaman Ayarlar\'dan açıp kapatabilirsin.';

  @override
  String get settingsPrimingLater => 'Daha sonra';

  @override
  String get settingsPrimingPointNightMarket =>
      'Gece Pazarı açıldığında haberdar ol';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Böylece tekliflerini süreleri dolmadan çevirebilirsin';

  @override
  String get settingsPrimingPointStore =>
      'Günlük mağaza yenilendiğinde hatırlatma';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Hesabının mağazası yenilendikten sonra hatırlatır';

  @override
  String get settingsPrimingPointWishlist =>
      'Peşinde olduğun kaplama göründüğünde bildirim';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Uygulama kapalıyken bile tüm hesapların mağazasını kontrol eder';

  @override
  String get settingsPrimingTitle => 'Peşinde olduğun kaplamayı asla kaçırma';

  @override
  String settingsRemovedAccount(String account) {
    return 'Kaldırıldı: $account';
  }

  @override
  String get settingsServerStatus => 'Sunucu durumu';

  @override
  String get settingsServerStatusMaintenance => 'Bakımda';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n duyuru';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Sunucuya göre VALORANT bakımları ve sorunları';

  @override
  String get settingsSessionLogTitle => 'ValHub hata raporu';

  @override
  String get settingsSeverityCritical => 'Kritik';

  @override
  String get settingsSeverityInfo => 'Bilgi';

  @override
  String get settingsSeverityWarning => 'Uyarı';

  @override
  String get settingsSignedOutAll => 'Tüm hesaplardan çıkış yapıldı';

  @override
  String get settingsStatusAllGood => 'Sunucular normal çalışıyor';

  @override
  String settingsStatusAllGoodBody(String region) {
    return '$region sunucusunda sorun veya bakım yok.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Daha az göster';

  @override
  String get settingsStatusIssues => 'Riot bir sorun üzerinde çalışıyor';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'Bu sunucuda $n sorun duyurusu var.';
  }

  @override
  String get settingsStatusKindIncident => 'Sorun';

  @override
  String get settingsStatusKindMaintenance => 'Bakım';

  @override
  String get settingsStatusMaintenanceNow => 'Sunucu bakımda';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Şu anda oyuna giremeyebilirsin ve ValHub bilgileri geçici olarak yükleyemeyebilir.';

  @override
  String settingsStatusMoreUpdates(int n) {
    return '$n güncelleme daha göster';
  }

  @override
  String get settingsStatusScheduled => 'Yaklaşan bakım';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riot tarafından duyurulan bakım sayısı: $n.';
  }

  @override
  String get settingsStatusSourceNote =>
      'Kaynak: Riot Games\'in resmî durum sayfası. Saatler cihazının saat diliminde gösterilir.';

  @override
  String settingsStatusStarted(String when) {
    return 'Başlangıç: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Güncelleme: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'RIOT\'TAN GÜNCELLEMELER';

  @override
  String get settingsSupportHeader => 'DESTEK';

  @override
  String settingsSwitchedTo(String account) {
    return 'Geçiş yapıldı: $account';
  }

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemePickerTitle => 'Tema seç';

  @override
  String get settingsThemeSystem => 'Sistem varsayılanı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsWelcomeBulletProfile => 'Rütbe, maç geçmişi, canlı maçlar';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'Maç başına RR, rakiplerin rütbeleri';

  @override
  String get settingsWelcomeBulletStore =>
      'Günlük mağaza, Gece Pazarı ve paketler';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Fiyatlar, nadirlik, yenilenme geri sayımı';

  @override
  String get settingsWelcomeBulletWishlist => 'İstek listesi ve bildirimler';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Peşinde olduğun kaplama mağazana geldiğinde haberin olsun';

  @override
  String get settingsWelcomeFootnote =>
      'Riot\'un resmî sayfasında giriş yaparsın. ValHub şifreni yalnızca giriş bilgilerini kaydetmeyi seçersen saklar.';

  @override
  String get settingsWelcomeKicker => 'VALORANT YOL ARKADAŞI';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (Puan: $count) · ',
      'other': '',
    });
    return 'Topluluk: ${_temp0}Beğeni: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'İstek listesine ekle';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Şu hesapların mağazasında: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return 'Mağazanda: günlük mağazada $daily kez, $night Gece Pazarı\'nda. Yalnızca bu cihazdaki veriler sayılır; kayıt başlangıcı: $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Mağaza geçmişini sil';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Bu hesap için bu cihazda kaydedilen tüm mağaza günleri silinsin mi?';

  @override
  String get skinDetailInWishlist => 'İstek listende';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Kilitli';

  @override
  String get skinDetailMute => 'Sesi kapat';

  @override
  String get skinDetailNotFound => 'Bu kaplama bulunamadı.';

  @override
  String get skinDetailOwned => 'Sahipsin';

  @override
  String get skinDetailPause => 'Duraklat';

  @override
  String get skinDetailPlay => 'Oynat';

  @override
  String get skinDetailPlayVideo => 'Videoyu izle';

  @override
  String get skinDetailRemoveFromWishlist => 'İstek listesinden çıkar';

  @override
  String get skinDetailTitle => 'Kaplama ayrıntıları';

  @override
  String get skinDetailUnmute => 'Sesi aç';

  @override
  String get skinDetailUpgrades => 'Yükseltmeler';

  @override
  String get skinDetailVariants => 'Varyantlar';

  @override
  String get skinDetailVideoError =>
      'Video oynatılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get socialPresenceInMatch => 'Maçta';

  @override
  String get socialPresenceAgentSelect => 'Ajan seçiminde';

  @override
  String get socialPresenceQueue => 'Sırada';

  @override
  String get socialPresenceLobby => 'Lobide';

  @override
  String get socialPresenceCustom => 'Özel oyunda';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Açık grup',
      'other': 'Yalnızca davetle',
    });
    return '$size/$max oyuncu · $_temp0';
  }

  @override
  String get socialAccept => 'Kabul et';

  @override
  String get socialAcceptInGame => 'Bu daveti oyunda kabul et.';

  @override
  String socialActionFailed(String message) {
    return 'İşlem tamamlanamadı. $message';
  }

  @override
  String get socialAutoRefresh => 'Otomatik yenile';

  @override
  String get socialAway => 'Uzakta';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Sırayı iptal et · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Sırayı iptal et';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Grubun $queue sırasına giremiyor: $reason';
  }

  @override
  String get socialChangeQueue => 'Sırayı değiştir';

  @override
  String get socialChatUnavailable => 'Sohbet çevrim dışı.';

  @override
  String get socialCloseParty => 'Grubu kapat';

  @override
  String get socialCodeInvalid => 'Grup kodları yalnızca harf ve rakam içerir.';

  @override
  String get socialConnecting => 'Sohbete bağlanılıyor…';

  @override
  String get socialCopyCode => 'Kopyala';

  @override
  String get socialCurrentQueue => 'Seçili';

  @override
  String get socialCustomGameLobby => 'Grubun bir Özel Oyun lobisinde.';

  @override
  String get socialDecline => 'Reddet';

  @override
  String get socialDisableCode => 'Kodu kapat';

  @override
  String get socialEmptyChat => 'Henüz mesaj yok. Bir selam gönder!';

  @override
  String get socialEmptyChatTitle => 'Sohbete başla';

  @override
  String get socialFailedBadge => 'Gönderilemedi';

  @override
  String get socialFilterAll => 'Tümü';

  @override
  String get socialFilterOnline => 'Çevrim içi';

  @override
  String get socialFilterUnread => 'Okunmamış';

  @override
  String get socialFriendsPrivacyNote =>
      'Arkadaş listen ve mesajların doğrudan Riot\'tan gelir. ValHub bunları başka hiçbir yerde saklamaz.';

  @override
  String socialFriendsSummary(int total, int online) {
    return '$total arkadaş · $online çevrim içi';
  }

  @override
  String get socialFriendsTitle => 'Arkadaşlar ve sohbet';

  @override
  String get socialGameNotRunningBody =>
      'Grup ve sıra yalnızca VALORANT bilgisayarında veya konsolunda çalışırken kullanılabilir. Oyunu aç, ardından yenilemek için aşağı çek.';

  @override
  String get socialGameNotRunningTitle =>
      'VALORANT\'ı bilgisayarında veya konsolunda aç';

  @override
  String get socialGenerateCode => 'Kod oluştur';

  @override
  String get socialIdleQueue => 'Sıraya girmeye hazır';

  @override
  String get socialInMatchBanner =>
      'Şu anda maçtasın. Maç bittiğinde sıra yeniden açılır.';

  @override
  String get socialInValorant => 'VALORANT\'ta';

  @override
  String get socialInviteByRiotId => 'Riot ID ile davet et';

  @override
  String get socialInviteByRiotIdHint =>
      'Henüz arkadaşın olmayan oyuncuları da davet et';

  @override
  String get socialInviteFriends => 'Arkadaşlarını davet et';

  @override
  String socialInviteFrom(String name) {
    return 'Davet eden: $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Davet et: $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Bu oyuncunun Riot ID\'si bilinmediği için henüz davet edilemiyor.';

  @override
  String socialInviteSent(String name) {
    return 'Davet gönderildi: $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Davet edildi';
  }

  @override
  String get socialInvitesSection => 'Davetler';

  @override
  String get socialJoin => 'Katıl';

  @override
  String get socialJoinConfirmBody =>
      'Bu koda sahip gruba katılmak için mevcut grubundan ayrılacaksın.';

  @override
  String get socialJoinConfirmTitle => 'Başka bir gruba katılınsın mı?';

  @override
  String get socialJoinSection => 'Başka bir gruba katıl';

  @override
  String get socialJoinWithCode => 'Katılmak için kod gir';

  @override
  String get socialJoined => 'Gruba katıldın.';

  @override
  String socialLastOnline(String relative) {
    return 'Son etkinlik: $relative';
  }

  @override
  String get socialLeader => 'Lider';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Mevcut grubundan ayrılıp tek kişilik gruba döneceksin.';

  @override
  String get socialLeaveConfirmTitle => 'Gruptan ayrılınsın mı?';

  @override
  String get socialLeaveParty => 'Gruptan ayrıl';

  @override
  String socialLevel(int n) {
    return 'Seviye $n';
  }

  @override
  String get socialMatchFound => 'Maç bulundu!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Üyeler ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Bir mesaj yaz…';

  @override
  String get socialMoreActions => 'Diğer seçenekler';

  @override
  String get socialNoCode =>
      'Arkadaşlarının grubuna hızlıca katılabilmesi için bir kod oluştur.';

  @override
  String get socialNoCodeMember =>
      'Grup lideri hızlı davet için bir kod oluşturabilir.';

  @override
  String get socialNoFilterResults => 'Bu filtreyle eşleşen arkadaş yok.';

  @override
  String get socialNoFriends => 'Riot arkadaş listen boş. Oyunda arkadaş ekle.';

  @override
  String get socialNoFriendsTitle => 'Henüz arkadaş yok';

  @override
  String get socialNoOnlineFriends =>
      'Şu anda VALORANT\'ta çevrim içi olan arkadaşın yok.';

  @override
  String get socialNoSearchResults => 'Eşleşen arkadaş yok.';

  @override
  String get socialNoSearchResultsTitle => 'Hiçbir şey bulunamadı';

  @override
  String get socialNotReady => 'Hazır değil';

  @override
  String socialOfflineSection(int n) {
    return 'Çevrim dışı ($n)';
  }

  @override
  String get socialOfflineStatus => 'Çevrim dışı';

  @override
  String get socialOnlineMobile => 'Mobilde çevrim içi';

  @override
  String socialOnlineSection(int n) {
    return 'Çevrim içi ($n)';
  }

  @override
  String get socialOnlineStatus => 'Çevrim içi';

  @override
  String get socialOnlyLeader =>
      'Sırayı yalnızca grup lideri değiştirebilir ve maç aramayı başlatabilir.';

  @override
  String get socialOpenParty => 'Grubu aç';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Grup kodu';

  @override
  String socialPartyCodeValue(String code) {
    return 'Grup kodu: $code';
  }

  @override
  String get socialPartyInvite => 'Grup daveti';

  @override
  String socialPartyOf(int size, int max) {
    return 'Grup $size/$max';
  }

  @override
  String get socialPartyTitle => 'Grup ve sıra';

  @override
  String socialPickQueueSubtitle(int size) {
    return '$size kişilik grup';
  }

  @override
  String get socialPickQueueTitle => 'Sıra seç';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Maç sunucularına en iyi ping';

  @override
  String socialPlayingOther(String game) {
    return 'Oynuyor: $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Oynuyor ($n)';
  }

  @override
  String get socialQueueLabel => 'Sıra';

  @override
  String get socialQueueLocked => 'Maçtayken sırayı değiştiremezsin.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'En fazla $max oyuncu',
      one: 'En fazla $max oyuncu',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Oyun durumun doğrulanamadı. Hazır ve sıra özelliklerini kullanmak için yenile.';

  @override
  String get socialReady => 'Hazır';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Hazır $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'bir üyenin hesap seviyesi yeterli değil';

  @override
  String get socialReasonGeneric => 'grup henüz uygun değil';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'grup çok kalabalık (en fazla $max)';
  }

  @override
  String get socialReasonRankDisparity =>
      'rütbe farkı Rekabete Dayalı için çok büyük';

  @override
  String socialReasonRestricted(String time) {
    return 'grubun sıraya girmesi kısıtlandı (kalan: $time)';
  }

  @override
  String get socialReconnecting =>
      'Sohbet bağlantısı koptu. Yeniden bağlanılıyor…';

  @override
  String get socialRemoteNote =>
      'Değişiklikler yalnızca sen dokunduğunda Riot\'a gönderilir. ValHub asla senin yerine sıraya girmez veya ajan kilitlemez.';

  @override
  String socialRemoveConfirmBody(String name) {
    return 'Bu oyuncu grubundan çıkarılacak: $name.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Gruptan çıkarılsın mı?';

  @override
  String get socialRemoveMember => 'Gruptan çıkar';

  @override
  String socialRequestFrom(String name) {
    return '$name gruba katılmak istiyor';
  }

  @override
  String get socialRequestsSection => 'Katılma istekleri';

  @override
  String get socialRiotIdFieldHint => 'Ad#ETİKET';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID; bir ad (3–16 karakter), # işareti ve bir etiketten (3–5 harf veya rakam) oluşur.';

  @override
  String get socialSearchHint => 'Riot ID ile ara…';

  @override
  String socialSearching(String elapsed) {
    return 'Sırada · $elapsed';
  }

  @override
  String get socialSend => 'Gönder';

  @override
  String get socialSendFailed =>
      'Mesaj gönderilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get socialSendInvite => 'Davet gönder';

  @override
  String get socialShareCode => 'Paylaş';

  @override
  String socialShareCodeText(String code) {
    return 'Şu kodla VALORANT grubuma katıl: $code';
  }

  @override
  String get socialShootingRange => 'Poligonda';

  @override
  String get socialShowEveryone => 'Tümünü göster';

  @override
  String get socialStartQueue => 'Sıraya gir';

  @override
  String get socialSuggestionsItem0 => 'Selam!';

  @override
  String get socialSuggestionsItem1 => 'Birkaç maç atalım mı?';

  @override
  String get socialSuggestionsItem2 => 'Grubuma gel!';

  @override
  String socialUnread(int n) {
    return '$n okunmamış mesaj';
  }

  @override
  String get socialUnready => 'Hazır değilim';

  @override
  String get socialViewProfile => 'Profili gör';

  @override
  String get socialWaitingForConnection =>
      'Bağlanılıyor… Bağlantı kurulunca mesaj gönderebilirsin.';

  @override
  String get socialYou => 'Sen';

  @override
  String get socialPartyUnavailable =>
      'Grubun eşitlenemedi. Tekrar denemek için yenile.';

  @override
  String get socialAcceptConfirmBody =>
      'Seni davet eden gruba katılmak için mevcut grubundan ayrılacaksın.';

  @override
  String get storeAccessoryEmpty => 'Aksesuar mağazası şu anda boş.';

  @override
  String get storeAccessoryEmptyTitle => 'Henüz aksesuar yok';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Kaynak: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Yenilenmesine: $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Yenilenme: $wall';
  }

  @override
  String get storeAddToWishlist => 'İstek listesine ekle';

  @override
  String get storeBackToBundles => 'Satıştaki paketleri gör';

  @override
  String get storeBundleBuySeparateLabel => 'Ayrı ayrı satın al';

  @override
  String get storeBundleDetailTitle => 'Paket ayrıntıları';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Bitiş: $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Kalan: $t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n öğe';
  }

  @override
  String get storeBundleItemFree => 'Ücretsiz';

  @override
  String get storeBundleItemsTitle => 'Paketteki öğeler';

  @override
  String get storeBundleNotFound =>
      'Bu paket bulunamadı. Süresi dolmuş olabilir.';

  @override
  String get storeBundleNotFoundTitle => 'Paketin süresi doldu';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Sahip olunan öğe: $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Paket fiyatı';

  @override
  String get storeBundleSavingsLabel => 'Tasarrufun';

  @override
  String get storeBundleWholesaleOnly =>
      'Yalnızca paketin tamamı satılır, ayrı ayrı satın alınamaz.';

  @override
  String get storeBundlesEmpty => 'Şu anda satışta paket yok.';

  @override
  String get storeBundlesEmptyTitle => 'Henüz paket yok';

  @override
  String get storeDailyEmpty => 'Bugün mağazada kaplama yok.';

  @override
  String get storeDailyEmptyTitle => 'Mağaza boş';

  @override
  String storeDailyResetAt(String time) {
    return 'Her gün $time itibarıyla yenilenir';
  }

  @override
  String get storeDailyTotalLabel => 'Toplam';

  @override
  String get storeNightMarketEmpty => 'Şu anda Gece Pazarı yok.';

  @override
  String get storeNightMarketEmptyTitle => 'Gece Pazarı açık değil';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Bitiş: $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Bitmesine: $t';
  }

  @override
  String get storeNightMarketNote =>
      'Gece Pazarı teklifleri hesabına özeldir ve yenilenemez.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Toplam tasarruf: $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Çevrilmedi';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Sahipsin';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Sahip olunan: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'İstek listesinden çıkar';

  @override
  String get storeResetNotificationTitle => 'Mağazan yenilendi';

  @override
  String storeResetsIn(String t) {
    return 'Yenilenmesine: $t';
  }

  @override
  String get storeSegmentAccessories => 'Aksesuarlar';

  @override
  String get storeSegmentBundles => 'Paketler';

  @override
  String get storeSegmentDaily => 'Günlük';

  @override
  String get storeSegmentNightMarket => 'Gece Pazarı';

  @override
  String get storeShareButton => 'Paylaş';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Bugünkü mağaza';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Gece Pazarı';

  @override
  String get storeShareCardPriceNote =>
      'Tahmini fiyatlar VP paketlerine göre yapılan tahminlerdir.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Tasarruf: $vp';
  }

  @override
  String get storeShareCardTagline => 'VALORANT yol arkadaşın';

  @override
  String storeShareCardTotal(String vp) {
    return 'Toplam: $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Bitiş: $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Bugünkü mağazayı paylaş';

  @override
  String get storeShareFailed => 'Görsel oluşturulamadı. Tekrar dene.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Görseli paylaş';

  @override
  String get storeShareNightMarketTitle => 'Gece Pazarı\'nı paylaş';

  @override
  String get storeSharePreparing => 'Kaplama görselleri yükleniyor…';

  @override
  String get storeShareShowPrice => 'Tahmini fiyatları göster';

  @override
  String get storeShareShowPriceHint =>
      'En avantajlı VP paketine göre hesaplanır.';

  @override
  String get storeShareShowRiotId => 'Görselde Riot ID\'yi göster';

  @override
  String get storeShareShowRiotIdHint =>
      'Gizliliğin için varsayılan olarak kapalı.';

  @override
  String get storeShareSubjectDaily => 'Bugünkü VALORANT mağazam';

  @override
  String get storeShareSubjectNightMarket => 'VALORANT Gece Pazarım';

  @override
  String get storeShareSubtitle =>
      'Mağazanın görselini istediğin uygulamayla arkadaşlarınla paylaş.';

  @override
  String get storeTitle => 'Mağaza';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Bakiye: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'İstek listesinde: $n';
  }

  @override
  String get storeHistoryTitle => 'Mağaza geçmişi';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString gün',
      one: '$daysString gün',
    );
    return 'Bu cihazda kayıt başlangıcı: $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Henüz kaydedilmiş gün yok. ValHub, uygulamayı her açtığında günlük mağazanı yalnızca bu cihaza kaydeder.';

  @override
  String get storeHistoryMostOffered => 'En sık çıkanlar';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString kez',
      one: '$nString kez',
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
      other: 'Gece Pazarı · $countString teklif',
      one: 'Gece Pazarı · $countString teklif',
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
      other: 'Bu cihazda $daysString gün kaydedildi',
      one: 'Bu cihazda $daysString gün kaydedildi',
      zero: 'Kayıt bugün başladı',
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
      'yes': '$skin, $account mağazasında — kalan süre: $left.',
      'other': '$skin, $account mağazasında.',
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
      'discount': '$skin %$percent indirimle şimdi $price ($account).',
      'price': '$skin yalnızca $price ($account).',
      'other': '$skin, $account Gece Pazarı\'nda.',
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
      'yes': '$skin, $bundle paketinde ($account).',
      'other': '$skin satıştaki bir pakette ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$account mağazasında şu an: $names ve $more kaplama daha.',
      one: '$account mağazasında şu an: $names ve $more kaplama daha.',
      zero: '$account mağazasında şu an: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', istek listesinde',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Kaplama ekle';

  @override
  String get wishlistAddToWishlist => 'İstek listesine ekle';

  @override
  String get wishlistAllWeapons => 'Tüm silahlar';

  @override
  String get wishlistBrowseCatalog => 'Tüm kaplamaları gör';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString kaplama';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Kaplama listesi yüklenemedi. Tekrar denemek için yenile.';

  @override
  String get wishlistCatalogEmptyTitle => 'Henüz kaplama yok';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'İstek listesinde: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Bir kaplamayı istek listene eklemek için ♡ simgesine dokun';

  @override
  String get wishlistCatalogTitle => 'Tüm kaplamalar';

  @override
  String get wishlistChooseWeapon => 'Silah seç';

  @override
  String get wishlistClearFilters => 'Filtreleri temizle';

  @override
  String get wishlistEmpty =>
      'İstek listen boş. Eklemek için herhangi bir kaplamadaki ♡ simgesine dokun.';

  @override
  String get wishlistEmptyTitle => 'Henüz kaplama yok';

  @override
  String wishlistEndsIn(String time) {
    return 'Bitmesine: $time';
  }

  @override
  String get wishlistExcludedRewards => 'Ödül kaplamaları hariç';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Filtrelenen: $countString kaplama · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Eşleşen kaplama yok. Daha fazlasını görmek için filtreleri temizle.';

  @override
  String get wishlistNoMatchTitle => 'Kaplama bulunamadı';

  @override
  String get wishlistNotifBundleTitle =>
      'Yeni pakette istek listendeki bir kaplama var';

  @override
  String get wishlistNotifDailyTitle => 'İstek listendeki bir kaplama geldi!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Gece Pazarı\'nda istediğin bir kaplama var!';

  @override
  String get wishlistNotifPermissionMissing =>
      'Uygulamanın bildirim gönderme izni yok.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return 'İstek listendeki $count kaplama satışta!';
  }

  @override
  String get wishlistNotifToggle => 'İstek listesi bildirimleri';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Bu hesap için, uygulama kapalıyken bile';

  @override
  String wishlistOfAccount(String riotId) {
    return 'İstek listesi: $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'İstek listendeki $count kaplama satışta!',
      one: 'İstek listendeki $count kaplama satışta!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Teklifi görmek için vurgulanan satıra dokun.';

  @override
  String get wishlistOpenSettings => 'Ayarları aç';

  @override
  String get wishlistOwned => 'Sahipsin';

  @override
  String get wishlistRemoveAction => 'İstek listesinden çıkar';

  @override
  String get wishlistRemoveFromWishlist => 'İstek listesinden çıkar';

  @override
  String wishlistRemoved(String name) {
    return 'İstek listesinden çıkarıldı: $name';
  }

  @override
  String get wishlistSearchHint => 'Kaplama ara…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString kaplama';
  }

  @override
  String get wishlistSortName => 'Ad';

  @override
  String get wishlistSortPrice => 'Fiyat';

  @override
  String get wishlistSortRarity => 'Nadirlik';

  @override
  String get wishlistSortWeapon => 'Silah';

  @override
  String get wishlistTitle => 'İstek listesi';

  @override
  String get wishlistTotalValue => 'İstek listesi toplam değeri';

  @override
  String get wishlistUndo => 'Geri al';

  @override
  String get wishlistViewInStore => 'Mağazada gör';

  @override
  String get wishlistWeapon => 'Silah';

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
      'yes': ', istek listesinde',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', istek listesinde',
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
      'gain': 'kazanıldı',
      'other': 'kaybedildi',
    });
    return 'Bugün $rr RR $_temp0, $wins galibiyet, $losses mağlubiyet';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws beraberlik',
      one: ', $draws beraberlik',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', sonucu bilinmeyen $unknown maç',
      one: ', sonucu bilinmeyen $unknown maç',
      zero: '',
    );
    return '$wins galibiyet – $losses mağlubiyet$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody =>
      'Tekrar göstermek için Ana Sayfayı Özelleştir\'i aç.';

  @override
  String get homeAllHiddenTitle => 'Tüm kartları gizledin';

  @override
  String get homeCardBattlePass => 'Savaş Bileti';

  @override
  String get homeCardBattlePassDesc =>
      'Seviye, günlük gereken XP ve haftalık görevler.';

  @override
  String get homeCardCommunity => 'Topluluk';

  @override
  String get homeCardCommunityDesc =>
      'Rütbene uygun takım arkadaşları ve topluluğun en sevdiği kaplamalar.';

  @override
  String get homeCardFriends => 'Oynayan arkadaşlar';

  @override
  String get homeCardFriendsDesc => 'Maçta veya sırada olan arkadaşlar.';

  @override
  String homeCardHidden(String name) {
    return '\"$name\" gizlendi';
  }

  @override
  String get homeCardLive => 'Mevcut maç';

  @override
  String get homeCardLiveDesc =>
      'Sıradayken, ajan seçimindeyken veya maçtayken gösterilir.';

  @override
  String get homeCardOtherAccounts => 'Diğer hesaplar';

  @override
  String get homeCardOtherAccountsDesc =>
      'Diğer hesaplarının durumu ve istek listesi.';

  @override
  String get homeCardRank => 'Rütbe ve form';

  @override
  String get homeCardRankDesc =>
      'Rütbe, bugünkü RR, seriler ve rütbe atlamak için gereken maçlar.';

  @override
  String get homeCardServerStatus => 'Sunucu durumu';

  @override
  String get homeCardServerStatusDesc =>
      'Yalnızca bakım veya sorun olduğunda gösterilir.';

  @override
  String get homeCardStore => 'Bugünkü mağaza';

  @override
  String get homeCardStoreDesc =>
      'Günlük kaplamalar, istek listesi ve Gece Pazarı.';

  @override
  String get homeCustomize => 'Ana Sayfayı Özelleştir';

  @override
  String get homeCustomizeHint =>
      'Sıralamak için sürükle. Kartı gizlemek için kapat.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Şuraya gidildi: $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Aç';

  @override
  String get homeFriendsConsentBody =>
      'Hangi arkadaşlarının oynadığını görmek için ValHub, Ana Sayfa\'yı her açtığında kullanılan hesabın Riot sohbetine bağlanır. Arkadaşların seni çevrim içi olarak görür. Bunu Ana Sayfayı Özelleştir\'den kapatabilirsin.';

  @override
  String get homeFriendsConsentDecline => 'Hayır, kartı gizle';

  @override
  String get homeFriendsConsentTitle =>
      'Hangi arkadaşların oynuyor, görmek ister misin?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n arkadaş oynuyor';
  }

  @override
  String get homeFriendsSeeAll => 'Tümünü gör';

  @override
  String get homeHideCard => 'Bu kartı gizle';

  @override
  String homeLeaderboard(String pos) {
    return 'Sıralama tablosunda #$pos';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Kalan: $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return '$n oyuncu aranıyor';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Rütbene uygun takım arkadaşları bul';

  @override
  String get homeLiveAllyLabel => 'Takımın';

  @override
  String get homeLiveEnemyLabel => 'Rakip takım';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Sırada, bekleme süresi: $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Takımın $ally, rakip takım $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '$n maçlık Rekabete Dayalı mağlubiyet serisi';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return 'Hedef $rank: ≈ $n maç';
  }

  @override
  String homeMoreActions(String name) {
    return 'Seçenekler: $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return '$riotId hesabının mağazasını, rütbesini ve Savaş Bileti\'ni güncellemek için tekrar giriş yap. Cihazında kayıtlı sürümü görmeye devam edebilirsin.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Kalan: $time';
  }

  @override
  String get homeNightMarketNew => 'Yeni';

  @override
  String get homeNightMarketTitle => 'Gece Pazarı';

  @override
  String homeNightMarketWaiting(int n) {
    return 'Çevirmeni bekleyen $n teklif var';
  }

  @override
  String get homeNoRankedToday => 'Bugün Rekabete Dayalı maç yok';

  @override
  String get homeOpenLfg => 'Tüm takım arkadaşı ilanlarını gör';

  @override
  String get homeOpenRanking => 'Kaplama sıralamasını gör';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Diğer hesaplar ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n hesap';
  }

  @override
  String get homeOtherWishlistHit => 'İstek listendeki kaplama mağazada';

  @override
  String homePreviousAct(String rank) {
    return 'Önceki kısım: $rank';
  }

  @override
  String get homeQuietBody => 'Yenilemek için aşağı çek.';

  @override
  String get homeQuietTitle => 'Henüz yeni bir şey yok';

  @override
  String homeRankToNext(int rr) {
    return 'Rütbe atlamak için $rr RR';
  }

  @override
  String get homeResetLayout => 'Varsayılana dön';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Bugün $value';
  }

  @override
  String get homeStatusDetails => 'Ayrıntılar';

  @override
  String homeStatusIncident(String region) {
    return 'Sunucu sorunu · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Bakımda · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Yaklaşan bakım · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n duyuru';
  }

  @override
  String get homeStoreRefreshing => 'Yenileniyor…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Yenilenmesine: $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Toplam: $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Cüzdan: $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return 'Cüzdan: $vp · en fazla $n kaplama alınabilir';
  }

  @override
  String get homeStoreWishlistHit => 'İstek listendeki kaplama mağazada!';

  @override
  String homeStoreWishlistHits(int n) {
    return 'İstek listendeki $n kaplama satışta';
  }

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get homeTrendingTitle => 'Dünya genelinde en sevilen kaplamalar';

  @override
  String homeTrendingVotes(int n) {
    return '$n beğeni';
  }

  @override
  String get homeUndo => 'Geri al';

  @override
  String homeWinStreak(int n) {
    return '$n maçlık Rekabete Dayalı galibiyet serisi';
  }

  @override
  String get homeStoreOutdated =>
      'Mağaza yenilendi. ValHub yeni mağazayı henüz yükleyemedi.';

  @override
  String get homeOfflineTitle => 'Çevrim dışısın';

  @override
  String get homeOfflineBody =>
      'Cihazda kayıtlı veriler gösteriliyor. Bağlantı geri geldiğinde ValHub her şeyi günceller.';

  @override
  String get homeCardOffline => 'Bağlandığında görünecek.';

  @override
  String get communityErrorConsent =>
      'Devam etmek için Riot ID\'ni Topluluk ile paylaşmayı kabul et.';

  @override
  String get communityErrorForbidden =>
      'Bunu henüz yapamazsın. Topluluk Kuralları\'na göz at veya ValHub ile iletişime geç.';

  @override
  String get communityErrorGeneric => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String get communityErrorImageTooLarge =>
      'Görsel çok büyük (en fazla 2 MB). Başka bir görsel seç.';

  @override
  String get communityErrorImageType =>
      'JPEG, PNG veya WebP formatında bir görsel seç.';

  @override
  String get communityErrorInvalid =>
      'İçeriğin kabul edilmedi. Kontrol edip tekrar dene.';

  @override
  String get communityErrorNetwork =>
      'ValHub Topluluğu\'na bağlanılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get communityErrorNotFound => 'Bu içerik artık mevcut değil.';

  @override
  String get communityErrorPickImage =>
      'Fotoğraf arşivin açılamadı. Tekrar dene.';

  @override
  String get communityErrorRateLimited =>
      'Topluluk şu anda çok fazla istek alıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Topluluk şu anda çok fazla istek alıyor. Şu süre sonra tekrar dene: $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot hesabını doğrulayamadı. Riot hesabına tekrar giriş yapıp yeniden dene.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot şu anda sorun yaşıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot şu anda sorun yaşıyor. Şu süre sonra tekrar dene: $duration.';
  }

  @override
  String get communityErrorServer =>
      'ValHub Topluluğu şu anda sorun yaşıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String get communityErrorStorageFull =>
      'Topluluğun fotoğraf alanı dolu. Gönderi paylaşmaya devam edebilirsin ancak şu anda fotoğraf ekleyemezsin. Daha sonra tekrar dene.';

  @override
  String get communityErrorTimeout =>
      'ValHub Topluluğu\'nun yanıt vermesi çok uzun sürüyor. Tekrar dene.';

  @override
  String get communityErrorTitle => 'Tamamlanamadı';

  @override
  String get communityErrorUnauthorized =>
      'Topluluk bağlantının süresi doldu. Tekrar dene.';

  @override
  String get communityErrorImageQuota =>
      'Görsel depolama alanın doldu. Görselli birkaç gönderini silip tekrar dene.';

  @override
  String get smokePlain => 'Kod üretimi kontrolü';

  @override
  String smokeGreeting(String name) {
    return 'Merhaba $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n öğe',
      one: '$n öğe',
    );
    return '$_temp0';
  }
}
