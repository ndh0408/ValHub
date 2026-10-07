// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Zobacz źródło cennika';

  @override
  String get commonErrorApi =>
      'Riot ma problemy. Spróbuj ponownie za kilka minut.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonClearFilters => 'Wyczyść filtry';

  @override
  String get commonClearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonCopied => 'Skopiowano';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dnia',
      many: '$n dni',
      few: '$n dni',
      one: '$n dzień',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dnia temu',
      many: '$n dni temu',
      few: '$n dni temu',
      one: '$n dzień temu',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonEmptyGeneric => 'Na razie nic tu nie ma.';

  @override
  String get commonErrorContentUnavailable =>
      'Nie udało się wczytać skinów, agentów i map. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get commonErrorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get commonErrorMaintenance =>
      'Serwery VALORANT są w trakcie konserwacji. Wróć później.';

  @override
  String get commonErrorNeedsLogin =>
      'Twoje logowanie do Riot wygasło. Zaloguj się ponownie, aby kontynuować.';

  @override
  String get commonErrorNeedsLoginTitle => 'Zaloguj się ponownie';

  @override
  String get commonErrorNetwork =>
      'Brak połączenia. Sprawdź Wi-Fi lub dane mobilne i spróbuj ponownie.';

  @override
  String get commonErrorNoAccount => 'Nie zalogowano się na żadne konto.';

  @override
  String get commonErrorNotFound => 'Nie znaleziono tej zawartości.';

  @override
  String get commonErrorTimeout =>
      'Riot zbyt długo nie odpowiada. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get commonErrorTransient =>
      'Riot jest zajęty. Spróbuj ponownie za kilka minut.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot jest zajęty. Spróbuj ponownie za $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Nie udało się ustalić regionu Riot. Wybierz region w Ustawieniach.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Przejdź do Startu';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n godziny',
      many: '$n godzin',
      few: '$n godziny',
      one: '$n godzina',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n godziny temu',
      many: '$n godzin temu',
      few: '$n godziny temu',
      one: '$n godzinę temu',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Awaria serwera';

  @override
  String get commonJustNow => 'przed chwilą';

  @override
  String get commonLoadMore => 'Wczytaj więcej';

  @override
  String get commonLoading => 'Wczytywanie…';

  @override
  String get commonMaintenanceTitle => 'Konserwacja serwerów';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minuty',
      many: '$n minut',
      few: '$n minuty',
      one: '$n minuta',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minuty temu',
      many: '$n minut temu',
      few: '$n minuty temu',
      one: '$n minutę temu',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Na razie nie ma nic do pokazania';

  @override
  String commonOfflineCached(String time) {
    return 'Jesteś offline — pokazujemy zapisane dane ($time).';
  }

  @override
  String get commonOpenSettings => 'Otwórz ustawienia';

  @override
  String get commonPageNotFound => 'Nie znaleziono tego ekranu.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Najkorzystniejszy pakiet: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Edytuj swoją cenę';

  @override
  String get commonPriceEnterOwn => 'Wpisz cenę swojego pakietu VP';

  @override
  String get commonPriceEstimateBody =>
      'Kwota „≈ …” obok cen w VP to szacunek przeliczony według najkorzystniejszego pakietu VP. W grze płacisz w VP; prawdziwa kwota zależy od pakietu, metody płatności, podatków i promocji w chwili zakupu.';

  @override
  String get commonPriceEstimateTitle => 'Szacunkowa cena';

  @override
  String get commonPriceEstimateTooltip =>
      'Szacunkowa cena — dotknij, aby zobaczyć, jak ją liczymy';

  @override
  String get commonPriceHidden =>
      'Szacunkowe ceny są ukryte. Włącz je ponownie w Ustawieniach.';

  @override
  String get commonPriceHide => 'Ukryj szacunkowe ceny';

  @override
  String get commonPriceOpenSource => 'Otwórz stronę źródłową';

  @override
  String get commonPriceOverrideBody =>
      'Wpisz kwotę, którą faktycznie zapłacono za pakiet VP (sprawdź w sklepie w grze lub na paragonie). ValHub używa tej ceny do szacowania cen wszystkich przedmiotów; jest zapisana tylko na tym urządzeniu.';

  @override
  String get commonPriceOverrideCurrency => 'Kod waluty';

  @override
  String get commonPriceOverrideCurrencyHint => 'Np. PLN, EUR, USD, VND';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Przykładowy szacunek: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Wpisz 3-literowy kod waluty, np. PLN lub EUR.';

  @override
  String get commonPriceOverrideInvalidNumber => 'Wpisz liczbę większą od 0.';

  @override
  String get commonPriceOverridePrice => 'Cena pakietu';

  @override
  String get commonPriceOverrideRemove => 'Usuń swoją cenę';

  @override
  String get commonPriceOverrideRemoved => 'Usunięto wpisaną cenę.';

  @override
  String get commonPriceOverrideSave => 'Zapisz cenę';

  @override
  String get commonPriceOverrideSaved => 'Zapisano cenę pakietu VP.';

  @override
  String get commonPriceOverrideTitle => 'Cena twojego pakietu VP';

  @override
  String get commonPriceOverrideVp => 'VP w pakiecie';

  @override
  String get commonPricePacksTitle => 'Pakiety VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Według cen pakietów VP w regionie: $country';
  }

  @override
  String get commonPriceSourceUser =>
      'Według wpisanej przez ciebie ceny pakietu VP';

  @override
  String get commonPriceUnavailable =>
      'Brak jeszcze sprawdzonego cennika dla twojego regionu. Wpisz cenę kupionego wcześniej pakietu VP, aby zobaczyć szacunkowe ceny.';

  @override
  String commonPriceUpdated(String date) {
    return 'Cennik zaktualizowano: $date';
  }

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonRiotDisclaimer =>
      'ValHub nie jest wspierany przez Riot Games i nie odzwierciedla poglądów ani opinii Riot Games ani nikogo, kto oficjalnie uczestniczy w tworzeniu lub zarządzaniu produktami Riot Games. Riot Games i wszystkie powiązane produkty są znakami towarowymi lub zastrzeżonymi znakami towarowymi Riot Games, Inc.';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonSearch => 'Szukaj…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sekundy',
      many: '$n sekund',
      few: '$n sekundy',
      one: '$n sekunda',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Udostępnij';

  @override
  String get commonSignInAgain => 'Zaloguj się ponownie';

  @override
  String get commonSort => 'Sortuj';

  @override
  String commonSortBy(String option) {
    return 'Sortuj: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Kolekcja';

  @override
  String get commonTabCommunity => 'Społeczność';

  @override
  String get commonTabHome => 'Start';

  @override
  String get commonTabProfile => 'Profil';

  @override
  String get commonTabSettings => 'Ustawienia';

  @override
  String get commonTabStore => 'Sklep';

  @override
  String get commonTagline => 'Twój towarzysz w VALORANT';

  @override
  String get commonToday => 'Dzisiaj';

  @override
  String get commonTodayLower => 'dzisiaj';

  @override
  String get commonTomorrow => 'jutro';

  @override
  String get commonUnknownItem => 'Nieznany przedmiot';

  @override
  String commonUpdatedAt(String time) {
    return 'Zaktualizowano o $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Poniedziałek';

  @override
  String get commonWeekdaysItem1 => 'Wtorek';

  @override
  String get commonWeekdaysItem2 => 'Środa';

  @override
  String get commonWeekdaysItem3 => 'Czwartek';

  @override
  String get commonWeekdaysItem4 => 'Piątek';

  @override
  String get commonWeekdaysItem5 => 'Sobota';

  @override
  String get commonWeekdaysItem6 => 'Niedziela';

  @override
  String get commonYesterday => 'wczoraj';

  @override
  String get commonYesterdayTitle => 'Wczoraj';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Logowanie do Riot wygasło — pokazujemy zapisane dane ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Broń ciężka';

  @override
  String get contentCategoryMelee => 'Broń biała';

  @override
  String get contentCategoryRifle => 'Karabiny';

  @override
  String get contentCategoryShotgun => 'Strzelby';

  @override
  String get contentCategorySidearm => 'Broń boczna';

  @override
  String get contentCategorySmg => 'Pistolety maszynowe';

  @override
  String get contentCategorySniper => 'Karabiny snajperskie';

  @override
  String get contentCurrencyAgentTokens => 'Tokeny Agenta';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kredyty Królestwa';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Promienit';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Points';

  @override
  String get contentItemAgent => 'Agent';

  @override
  String get contentItemBuddy => 'Breloczek';

  @override
  String get contentItemCard => 'Karta gracza';

  @override
  String get contentItemChroma => 'Wariant';

  @override
  String get contentItemContract => 'Kontrakt';

  @override
  String get contentItemCurrency => 'Waluta';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Graffiti';

  @override
  String get contentItemTitle => 'Tytuł gracza';

  @override
  String contentLevel(int n) {
    return 'Poziom $n';
  }

  @override
  String get contentLevelBase => 'Podstawowy';

  @override
  String get contentLevelItemLabelsVFX => 'Efekty wizualne';

  @override
  String get contentLevelItemLabelsAnimation => 'Animacja';

  @override
  String get contentLevelItemLabelsFinisher => 'Finisher';

  @override
  String get contentLevelItemLabelsKillCounter => 'Licznik zabójstw';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Efekty dźwiękowe';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformacja';

  @override
  String get contentLevelItemLabelsKillBanner => 'Baner zabójstwa';

  @override
  String get contentLevelItemLabelsKillEffect => 'Efekt zabójstwa';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Efekty oglądania i zabójstwa';

  @override
  String get contentLevelItemLabelsVoiceover => 'Kwestie głosowe';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Losowy utwór';

  @override
  String get contentLevelItemLabelsRandomizer => 'Losowy wariant';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap => 'Zmiana atak/obrona';

  @override
  String get contentLevelItemLabelsTopFrag => 'Efekt top fraga';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Czujnik bicia serca i mapy';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animacja ryby';

  @override
  String get contentNoTitle => 'Brak tytułu';

  @override
  String get contentNotForSale => 'Nie na sprzedaż';

  @override
  String get contentQueueNamesCompetitive => 'Rankingowa';

  @override
  String get contentQueueNamesUnrated => 'Nierankingowa';

  @override
  String get contentQueueNamesSwiftplay => 'Szybka Gra';

  @override
  String get contentQueueNamesSpikerush => 'Gorączka Spike’a';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Drużynowy deathmatch';

  @override
  String get contentQueueNamesGgteam => 'Eskalacja';

  @override
  String get contentQueueNamesOnefa => 'Replikacja';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Gra niestandardowa';

  @override
  String get contentQueueNames => 'Gra niestandardowa';

  @override
  String get contentQueueNamesDodgeball => 'Nokaut';

  @override
  String get contentQueueNamesFortcollins => 'Odbicie';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Potyczka: 2 na 2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Potyczka: Wyniesienie 1 na 1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Potyczka: Wyniesienie 2 na 2';

  @override
  String get contentQueueNamesValaram => 'Wszyscy losowo, jeden punkt';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Bitwa na Śnieżki';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Rankingowa';

  @override
  String get contentQueueShortNamesValaram => 'Wszyscy losowo';

  @override
  String get contentRewardSourceAgent => 'Kontrakt agenta';

  @override
  String get contentRewardSourceBattlePass => 'Nagroda z Battle Passa';

  @override
  String get contentRewardSourceEvent => 'Przepustka wydarzenia';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Szturmowiec';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Inicjator';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Kontroler';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Strażnik';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Ekskluzywna';

  @override
  String contentTierFull(String shortName) {
    return 'Edycja $shortName';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Specjalna';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Bez rangi';

  @override
  String get accountRegionUnknown => 'Nieznany region';

  @override
  String accountRiotCountry(String country) {
    return 'Kraj konta Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Kraj konta Riot: nieznany';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'KONTA ($count/$max)';
  }

  @override
  String get accountActive => 'Aktywne';

  @override
  String accountAddAccount(int count, int max) {
    return 'Dodaj konto ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Wyczyść dane lokalne';

  @override
  String get accountClearLocalDataConfirm =>
      'Wyczyścić historię, zapisane zestawy wyposażenia i dane wylogowanych kont na tym urządzeniu?';

  @override
  String get accountClearRrHistory => 'Wyczyść historię RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Wyczyścić historię RR wybranego konta na tym urządzeniu?';

  @override
  String get accountCopyPassword => 'Kopiuj hasło';

  @override
  String get accountCopyUsername => 'Kopiuj nazwę użytkownika';

  @override
  String get accountDeleteLoginNote => 'Usuń dane';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Usunąć zapisaną nazwę użytkownika i hasło tego konta?';

  @override
  String get accountHidePassword => 'Ukryj hasło';

  @override
  String get accountKeepLocalData => 'Zachowaj dane lokalne';

  @override
  String get accountKeepLocalDataHint =>
      'Zachowaj listę życzeń, zestawy wyposażenia i historię na tym urządzeniu';

  @override
  String accountLevelShort(int level) {
    return 'Poz. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Konto z tego powiadomienia jest wylogowane. Zaloguj się ponownie, a potem otwórz powiadomienie.';

  @override
  String get accountLocalDataCleared => 'Wyczyszczono dane lokalne';

  @override
  String get accountLoginNote => 'Dane logowania';

  @override
  String get accountLoginNoteDeleted => 'Usunięto dane logowania';

  @override
  String get accountLoginNoteHint =>
      'Zapisane tylko na tym urządzeniu i bezpiecznie zablokowane. Służą do podejrzenia lub szybkiego wypełnienia danych przy ponownym logowaniu.';

  @override
  String get accountLoginNoteLocked => 'Odblokuj dane logowania';

  @override
  String get accountLoginNotePassword => 'Hasło';

  @override
  String get accountLoginNoteSaved => 'Zapisano dane logowania';

  @override
  String get accountLoginNoteUsername => 'Nazwa użytkownika Riot';

  @override
  String accountMaxAccounts(int max) {
    return 'Osiągnięto limit kont ($max).';
  }

  @override
  String get accountNeedsLogin => 'Zaloguj się ponownie';

  @override
  String accountOnlineCount(int count) {
    return 'Online: $count';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Wypełnij zapisanym kontem';

  @override
  String get accountQuickFillDone =>
      'Wszystko wypełnione. Dotknij „Zaloguj się”.';

  @override
  String get accountQuickFillNotReady =>
      'Strona logowania jeszcze się nie wczytała. Poczekaj chwilę i spróbuj ponownie.';

  @override
  String get accountQuickFillSubtitle =>
      'Wybierz konto do wypełnienia na stronie logowania Riot';

  @override
  String get accountQuickFillTitle => 'Wypełnij zapisanym kontem';

  @override
  String get accountRegionAp => 'Azja i Pacyfik';

  @override
  String get accountRegionBr => 'Brazylia';

  @override
  String get accountRegionEu => 'Europa';

  @override
  String get accountRegionKr => 'Korea';

  @override
  String get accountRegionLatam => 'Ameryka Łacińska';

  @override
  String get accountRegionNa => 'Ameryka Północna';

  @override
  String get accountRemoveAccount => 'Usuń konto';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Usunąć $account z tego urządzenia? Możesz zachować zapisane dane.';
  }

  @override
  String get accountRrHistoryCleared => 'Wyczyszczono historię RR';

  @override
  String get accountShowPassword => 'Pokaż hasło';

  @override
  String get accountSignOutAll => 'Wyloguj ze wszystkich kont';

  @override
  String get accountSignOutAllConfirm =>
      'Wylogować się i usunąć wszystkie konta z tego urządzenia? Możesz zachować zapisane dane.';

  @override
  String get accountStatusAgentSelect => 'Wybór agenta';

  @override
  String get accountStatusInMatch => 'W meczu';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Nieznany status';

  @override
  String accountSwitchTo(String account) {
    return 'Przełącz na $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Dotknij, aby przełączyć konto';

  @override
  String get accountSwitcherTitle => 'Konta';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Konta ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Gracz';

  @override
  String get accountUnlockLoginNote =>
      'Potwierdź tożsamość, aby odblokować dane logowania Riot';

  @override
  String accountMoreActions(String riotId) {
    return 'Opcje dla $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Zapisz dane logowania';

  @override
  String get accountClearRrHistorySubtitle => 'Tylko wybrane konto';

  @override
  String get accountClearLocalDataSubtitle =>
      'Historia, zapisane zestawy i dane wylogowanych kont';

  @override
  String get accountQuickFillLocked =>
      'Odblokuj odciskiem palca, twarzą lub kodem urządzenia, aby użyć zapisanego konta. Jeśli telefon nie ma blokady ekranu, ustaw ją i spróbuj ponownie.';

  @override
  String get authAddAsNew => 'Dodaj jako nowe konto';

  @override
  String get authDifferentAccountBody =>
      'Zalogowano się na inne konto niż to, które wymaga ponownego logowania. Dodać je jako nowe konto?';

  @override
  String get authDifferentAccountTitle => 'Inne konto';

  @override
  String get authLoadingAccount => 'Wczytywanie konta…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot odrzucił to logowanie. Spróbuj ponownie.';

  @override
  String get authLoginFailed => 'Nie udało się dokończyć logowania';

  @override
  String get authLoginFailedBody =>
      'Riot nie potwierdził logowania. Spróbuj ponownie.';

  @override
  String get authLoginTitle => 'Logowanie Riot';

  @override
  String get authMissingCookies =>
      'Nie udało się zapamiętać logowania na tym urządzeniu, więc po jego wygaśnięciu trzeba będzie zalogować się ponownie.';

  @override
  String get authOfficialHost => 'Oficjalna strona · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Otwarto link w przeglądarce.';

  @override
  String get authPageLoadFailed =>
      'Nie udało się wczytać strony logowania Riot. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get authPreparing => 'Przygotowywanie strony logowania…';

  @override
  String get authReloginDone => 'Zalogowano ponownie';

  @override
  String get authSignInCta => 'Zaloguj się kontem Riot';

  @override
  String get authSocialLoginHint =>
      'Jeśli logowanie przez Google lub Facebooka nie działa, użyj nazwy użytkownika Riot.';

  @override
  String get authStateMismatch =>
      'Ta próba logowania jest nieprawidłowa. Zacznij logowanie od nowa.';

  @override
  String get notificationSessionExpiredBody =>
      'Zaloguj się ponownie, aby dalej dostawać powiadomienia z listy życzeń.';

  @override
  String get notificationBackgroundTimingHint =>
      'Tryb oszczędzania baterii na urządzeniu może opóźniać powiadomienia.';

  @override
  String get notificationChannelAccountDescription =>
      'Przypomina, gdy konto wymaga ponownego logowania';

  @override
  String get notificationChannelAccountName => 'Konta';

  @override
  String get notificationChannelBattlePassDescription =>
      'Przypomnienia o postępach i końcu Battle Passa';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Aktywność społeczności po otwarciu ValHub';

  @override
  String get notificationChannelCommunityName => 'Społeczność';

  @override
  String get notificationChannelLfgDescription =>
      'Gracze dołączający do twojej drużyny po otwarciu ValHub';

  @override
  String get notificationChannelLfgName => 'Drużyna';

  @override
  String get notificationChannelNightMarketDescription =>
      'Powiadamia, gdy otworzy się Nocny Targ';

  @override
  String get notificationChannelNightMarketName => 'Nocny Targ';

  @override
  String get notificationChannelRankDescription =>
      'Zmiany rangi po odświeżeniu profilu';

  @override
  String get notificationChannelRankName => 'Ranga';

  @override
  String get notificationChannelStoreResetDescription =>
      'Przypomina, gdy odświeży się dzienna oferta sklepu';

  @override
  String get notificationChannelStoreResetName => 'Odświeżenie sklepu';

  @override
  String get notificationChannelWishlistDescription =>
      'Powiadamia, gdy skin z listy życzeń pojawi się w sklepie';

  @override
  String get notificationChannelWishlistName => 'Lista życzeń';

  @override
  String get notificationLfgJoinedTitle => 'Gracz dołączył do twojej drużyny';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Karty ofert do odkrycia: $cards ($account). Odkryj je teraz.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Nocny Targ jest otwarty!';

  @override
  String get notificationPassEndingBody =>
      'Do końca Battle Passa został około jeden dzień. Otwórz ValHub, aby sprawdzić najnowsze postępy.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass wkrótce się kończy';

  @override
  String notificationPassProgressBody(int level) {
    return 'Osiągnięto poziom $level w obecnym Battle Passie.';
  }

  @override
  String get notificationPassProgressTitle => 'Postępy w Battle Passie';

  @override
  String get notificationPrivateAccount => 'twoje konto';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Obecna ranga: $rank. Właśnie zaktualizowano dane z Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Ranga się zmieniła';

  @override
  String get notificationResetTimingUnknown =>
      'Otwórz sklep, aby zaktualizować godzinę odświeżenia na urządzeniu.';

  @override
  String get notificationSessionExpiredTitle => 'Zaloguj się ponownie';

  @override
  String get notificationStoreResetBody =>
      'Nowe skiny czekają na ciebie w sklepie.';

  @override
  String get competitiveDivisionIron => 'Żelazo';

  @override
  String get competitiveDivisionBronze => 'Brąz';

  @override
  String get competitiveDivisionSilver => 'Srebro';

  @override
  String get competitiveDivisionGold => 'Złoto';

  @override
  String get competitiveDivisionPlatinum => 'Platyna';

  @override
  String get competitiveDivisionDiamond => 'Diament';

  @override
  String get competitiveDivisionAscendant => 'Wschodząca Gwiazda';

  @override
  String get competitiveDivisionImmortal => 'Nieśmiertelny';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Promienisty';

  @override
  String get competitiveRankUnknown => 'Nieznana ranga';

  @override
  String get competitiveAttack => 'Atak';

  @override
  String get competitiveCannotEstimate => 'Nie da się oszacować';

  @override
  String get competitiveDefeat => 'Porażka';

  @override
  String get competitiveDefense => 'Obrona';

  @override
  String get competitiveDraw => 'Remis';

  @override
  String get competitiveIncognitoPlayer => 'Ukryty gracz';

  @override
  String get competitiveMatchPending => 'Riot wciąż przetwarza ten mecz…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Zostało $n meczu kwalifikacyjnego',
      many: 'Zostało $n meczów kwalifikacyjnych',
      few: 'Zostały $n mecze kwalifikacyjne',
      one: 'Został $n mecz kwalifikacyjny',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike rozbrojony';

  @override
  String get competitiveRoundDetonate => 'Spike wybuchł';

  @override
  String get competitiveRoundElimination => 'Eliminacja';

  @override
  String get competitiveRoundSurrendered => 'Poddanie';

  @override
  String get competitiveRoundTimeExpired => 'Koniec czasu';

  @override
  String get competitiveUnknownPlayer => 'Gracz';

  @override
  String get competitiveVictory => 'Zwycięstwo';

  @override
  String economyAvailableNow(String place) {
    return 'Teraz dostępne: $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'pakiet $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'pakiet';

  @override
  String get economyPlaceDaily => 'dzienna oferta sklepu';

  @override
  String get economyPlaceNightMarket => 'Nocny Targ';

  @override
  String get economyPriceEstimated => 'Cena szacowana według edycji';

  @override
  String get economyPriceFromOffers => 'Cena z cennika Riot';

  @override
  String get economyPriceFromStore => 'Cena widziana w sklepie';

  @override
  String get economyPriceFromTable => 'Cena katalogowa';

  @override
  String get economyPriceUnknown => 'Nieznana cena';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Zestaw $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Tej zmiany nie można zastosować do obecnego wyposażenia.';

  @override
  String get loadoutNotPersisted =>
      'Riot nie zapisał zmiany, więc wyposażenie się nie zmieniło. Spróbuj ponownie.';

  @override
  String get loadoutSaveFailed => 'Nie udało się zapisać wyposażenia';

  @override
  String battlePassActEndsIn(String time) {
    return 'Akt kończy się za $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Akt kończy się za $days dnia',
      many: 'Akt kończy się za $days dni',
      few: 'Akt kończy się za $days dni',
      one: 'Akt kończy się za $days dzień',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Wszystkie misje ukończone';

  @override
  String get battlePassAllWeeklyDone => 'Wszystkie misje tygodniowe ukończone';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Oczekujące podwójne nagrody: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Rozdział $n';
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
      'Wygrywaj rundy, aby zbliżać się do punktów kontrolnych (Deathmatch się nie liczy).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Punkt kontrolny $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Każdy punkt kontrolny: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Osiągnięte punkty kontrolne: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Obecny';

  @override
  String get battlePassDailyAllDone =>
      'Wszystkie dzisiejsze punkty kontrolne zaliczone';

  @override
  String get battlePassDailyCaption => 'Nagrody dzienne';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Nagrody dzienne · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Wczorajsze punkty kontrolne wygasły. Uruchom grę lub odśwież tutaj.';

  @override
  String get battlePassDailyMissions => 'Misje dzienne';

  @override
  String get battlePassDailyNotReady =>
      'Dzisiejsze punkty kontrolne nie są jeszcze gotowe. Uruchom grę lub odśwież tutaj.';

  @override
  String get battlePassDailyPlayToStart =>
      'Dzisiejsze punkty kontrolne nie są jeszcze gotowe. Uruchom grę, aby zacząć nowy dzień.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Zostało $days dnia',
      many: 'Zostało $days dni',
      few: 'Zostały $days dni',
      one: 'Został $days dzień',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Koniec: $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilog';

  @override
  String get battlePassEstimateNote =>
      'Szacunek: około 4000 XP na mecz, bez misji.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Kończy się za $time';
  }

  @override
  String get battlePassEventPass => 'Przepustka wydarzenia';

  @override
  String get battlePassFilterAll => 'Wszystkie';

  @override
  String get battlePassFilterLocked => 'Zablokowane';

  @override
  String get battlePassFilterUnlocked => 'Odblokowane';

  @override
  String get battlePassFree => 'Darmowa';

  @override
  String get battlePassFreeTrack => 'Darmowe nagrody';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Poziom $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Poz. $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString meczu',
      many: '$nString meczów',
      few: '$nString mecze',
      one: '$nString mecz',
    );
    return '≈ $_temp0 ($queue)';
  }

  @override
  String get battlePassMissionDone => 'Ukończono';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'Ukończone: $done/$total';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Nowe misje: $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Nowe misje za $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Następny punkt kontrolny: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Do poziomu $level';
  }

  @override
  String get battlePassNextReward => 'Następna';

  @override
  String get battlePassNoBattlePass =>
      'Brak jeszcze informacji o Battle Passie obecnego aktu. Spróbuj ponownie później.';

  @override
  String get battlePassNoRewards => 'Ten Battle Pass nie ma jeszcze nagród.';

  @override
  String get battlePassNoRewardsInFilter => 'Brak nagród w tej sekcji.';

  @override
  String get battlePassNoRewardsTitle => 'Brak nagród';

  @override
  String get battlePassNoWeeklyMissions => 'Obecnie brak misji tygodniowych.';

  @override
  String get battlePassPassComplete => 'Battle Pass ukończony';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Nie masz Premium: dostajesz tylko darmowe nagrody. Kup Premium w grze, aby odblokować osiągnięte poziomy.';

  @override
  String get battlePassRenewButton => 'Odśwież punkty kontrolne';

  @override
  String get battlePassRenewDone => 'Odświeżono dzienne punkty kontrolne.';

  @override
  String get battlePassRenewFailed =>
      'Nie udało się odświeżyć punktów kontrolnych. Spróbuj ponownie później.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Odświeżenie: $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Odświeżenie za $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Poziom';

  @override
  String get battlePassRewardLocked => 'Zablokowana';

  @override
  String get battlePassRewardNeedsPremium => 'Wymaga Premium';

  @override
  String get battlePassRewardStatusLabel => 'Status';

  @override
  String get battlePassRewardTrackLabel => 'Ścieżka nagród';

  @override
  String get battlePassRewardTypeLabel => 'Typ';

  @override
  String get battlePassRewardUnlocked => 'Odblokowana';

  @override
  String get battlePassRewardsTitle => 'Nagrody';

  @override
  String get battlePassShowAllRewards => 'Zobacz wszystko';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'Łącznie XP';

  @override
  String get battlePassUnknownMission => 'Nowa misja (brak opisu)';

  @override
  String get battlePassUnknownReward => 'Nagroda';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'Odblokowane: $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'Nierankingowa';

  @override
  String get battlePassViewAllRewards => 'Zobacz wszystkie nagrody';

  @override
  String get battlePassWeeklyMissions => 'Misje tygodniowe';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Misje tygodniowe: zostało +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / dzień';
  }

  @override
  String get battlePassXpPerDayCaption => 'Potrzebne dziennie, aby zdążyć';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Zostało: $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Nie udało się zapisać wyposażenia. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Wszystkie twoje skiny, wycenione według cen w sklepie',
      'buddy': 'Posiadane breloczki i liczba kopii',
      'spray': 'Graffiti, które możesz dodać do koła ekspresji',
      'card': 'Odblokowane karty gracza — dotknij, aby zobaczyć i wyposażyć',
      'title': 'Tytuły gracza, które możesz pokazać pod nazwą',
      'flex': 'Posiadane przedmioty Flex',
      'other': 'Przeglądaj kolekcję',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Miejsce: $position';
  }

  @override
  String get collectionApplyPreset => 'Zastosuj';

  @override
  String get collectionApplyPresetBody =>
      'Obecne skiny, breloczki, koło ekspresji, karta i tytuł zostaną zastąpione tym zestawem.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Zastosować „$name”?';
  }

  @override
  String get collectionBrowseBuddies => 'Breloczki';

  @override
  String get collectionBrowseCards => 'Karty gracza';

  @override
  String get collectionBrowseEmpty =>
      'Nie masz jeszcze przedmiotów w tej sekcji.';

  @override
  String get collectionBrowseEmptyTitle => 'Brak przedmiotów';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skiny';

  @override
  String get collectionBrowseSprays => 'Graffiti';

  @override
  String get collectionBrowseTitles => 'Tytuły gracza';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Dostępne: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Do: $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Wybierz breloczek';

  @override
  String get collectionBuddyRemoved => 'Zdjęto breloczek';

  @override
  String get collectionBuddySlot => 'Breloczek';

  @override
  String get collectionBuddyUnavailable =>
      'Nie udało się przypiąć tego breloczka. Odśwież lub wybierz inny.';

  @override
  String get collectionCachedLoadout =>
      'Pokazujemy zapisane wyposażenie. Pociągnij, aby odświeżyć przed zmianami.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString posiadanej karty',
      many: '$nString posiadanych kart',
      few: '$nString posiadane karty',
      one: '$nString posiadana karta',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Zmień';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'Warianty: $owned/$total';
  }

  @override
  String get collectionClearTiers => 'Wyczyść filtr edycji';

  @override
  String get collectionCollectionValue => 'Wartość kolekcji';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standardowy';

  @override
  String get collectionDeletePreset => 'Usuń';

  @override
  String get collectionEmptySlot => 'Puste';

  @override
  String get collectionEquip => 'Wyposaż';

  @override
  String get collectionEquipped => 'Wyposażone';

  @override
  String get collectionEquippedCard => 'Wyposażona karta';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Wyposażona karta: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Wyposażono: $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Wyposażone: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Bez skinów z nagród';

  @override
  String get collectionExpressionsHint =>
      'Dotknij miejsca, aby wybrać graffiti lub Flex.';

  @override
  String get collectionExpressionsSlots => 'Miejsca na kole';

  @override
  String get collectionExpressionsTitle => 'Koło ekspresji';

  @override
  String get collectionHideAccountLevel => 'Ukryj poziom konta';

  @override
  String get collectionHideAccountLevelHint =>
      'Inni gracze nie zobaczą poziomu twojego konta.';

  @override
  String get collectionIncognito => 'Tryb incognito';

  @override
  String get collectionIncognitoHint =>
      'Ukryj swoją nazwę przed graczami spoza drużyny podczas meczów.';

  @override
  String get collectionLevelBorderAuto => 'Automatycznie wg poziomu';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Od poziomu $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Poziom konta: $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Wybierz ramkę poziomu';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Poziom $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Poziom $n · $type';
  }

  @override
  String get collectionLevels => 'Poziomy';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Odblokowane poziomy: $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'Baner w poczekalni';

  @override
  String get collectionLocked => 'Zablokowane';

  @override
  String get collectionMeleeNoBuddy =>
      'Do broni białej nie można przypiąć breloczka.';

  @override
  String get collectionMove => 'Przenieś';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy jest przypięty do: $from. Przenieść go do: $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Przenieść breloczek?';

  @override
  String get collectionNoBuddies => 'Nie masz jeszcze żadnych breloczków.';

  @override
  String get collectionNoBuddy => 'Brak breloczka';

  @override
  String get collectionNoFlex => 'Nie masz jeszcze żadnych przedmiotów Flex.';

  @override
  String get collectionNoResults => 'Brak pasujących wyników.';

  @override
  String get collectionNoResultsTitle => 'Nic nie znaleziono';

  @override
  String get collectionNoSkinsForWeapon =>
      'Nie masz jeszcze skinów do tej broni.';

  @override
  String get collectionNoSprays => 'Nie masz jeszcze żadnych graffiti.';

  @override
  String get collectionNoTitle => 'Brak tytułu';

  @override
  String get collectionOtherWeapons => 'Inne';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n posiadanego skina',
      many: '$n posiadanych skinów',
      few: '$n posiadane skiny',
      one: '$n posiadany skin',
      zero: 'Brak skinów',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString posiadanego skina',
      many: '$nString posiadanych skinów',
      few: '$nString posiadane skiny',
      one: '$nString posiadany skin',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Obejrzyj film tego poziomu';

  @override
  String get collectionPlayVideo => 'Obejrzyj film';

  @override
  String get collectionPlayerCardSubtitle =>
      'Widoczna w poczekalni, na tablicy wyników i gdy wyeliminujesz wroga.';

  @override
  String get collectionPlayerCardTitle => 'Zmień kartę gracza';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Widoczny pod twoją nazwą w poczekalni i w meczach.';

  @override
  String get collectionPlayerTitleTitle => 'Zmień tytuł gracza';

  @override
  String get collectionPresetActions => 'Opcje';

  @override
  String collectionPresetApplied(String name) {
    return 'Zastosowano „$name”';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n zestawu',
      many: '$n zestawów',
      few: '$n zestawy',
      one: '$n zestaw',
      zero: 'Brak',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'Usunięto „$name”';
  }

  @override
  String get collectionPresetNameHint => 'Np. Wbijanie rangi';

  @override
  String get collectionPresetNameTitle => 'Nazwa zestawu';

  @override
  String collectionPresetSaved(String name) {
    return 'Zapisano „$name”';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Zapisano: $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Pominięto $n przedmiotu, których już nie masz.',
      many: 'Pominięto $n przedmiotów, których już nie masz.',
      few: 'Pominięto $n przedmioty, których już nie masz.',
      one: 'Pominięto $n przedmiot, którego już nie masz.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Zapisz obecne wyposażenie, aby później szybko przełączać się między zestawami skinów, kart i kół ekspresji.';

  @override
  String get collectionPresetsEmptyTitle => 'Brak zapisanych zestawów';

  @override
  String get collectionPresetsFull =>
      'Osiągnięto limit 50 zestawów. Usuń niektóre, aby zapisać więcej.';

  @override
  String get collectionPresetsNote =>
      'Zestawy są zapisywane tylko na tym urządzeniu, dla wybranego konta.';

  @override
  String get collectionPresetsTitle => 'Zapisane zestawy';

  @override
  String get collectionPreview => 'Podgląd';

  @override
  String get collectionRemoveBuddy => 'Zdejmij breloczek';

  @override
  String get collectionRenamePreset => 'Zmień nazwę';

  @override
  String get collectionRowExpressions => 'Koło ekspresji';

  @override
  String get collectionRowLevelBorder => 'Ramka poziomu';

  @override
  String get collectionRowPresets => 'Zapisane zestawy';

  @override
  String get collectionRowWeapons => 'Wyposażenie broni';

  @override
  String get collectionRowWishlist => 'Lista życzeń';

  @override
  String get collectionSaveFailed => 'Nie udało się zapisać wyposażenia';

  @override
  String get collectionSavePreset => 'Zapisz obecne wyposażenie';

  @override
  String get collectionSaving => 'Zapisywanie…';

  @override
  String get collectionSearchBuddies => 'Szukaj breloczków…';

  @override
  String get collectionSearchCards => 'Szukaj kart gracza…';

  @override
  String get collectionSearchFlex => 'Szukaj Flex…';

  @override
  String get collectionSearchItems => 'Szukaj…';

  @override
  String get collectionSearchSkins => 'Szukaj skinów…';

  @override
  String get collectionSearchSprays => 'Szukaj graffiti…';

  @override
  String get collectionSearchTitles => 'Szukaj tytułów…';

  @override
  String get collectionSearchWeapons => 'Szukaj broni, skinów lub breloczków…';

  @override
  String get collectionSectionBrowse => 'Przeglądaj kolekcję';

  @override
  String get collectionSectionIdentity => 'Widoczne dla innych graczy';

  @override
  String get collectionSectionLoadout => 'Wyposażenie';

  @override
  String get collectionSkinCustomizeTitle => 'Dostosuj skin';

  @override
  String get collectionSkinNotFound => 'Nie znaleziono tego skina.';

  @override
  String get collectionSkinNotOwned => 'Nie masz jeszcze tego skina.';

  @override
  String get collectionSlotNamesItem0 => 'Góra';

  @override
  String get collectionSlotNamesItem1 => 'Prawo';

  @override
  String get collectionSlotNamesItem2 => 'Dół';

  @override
  String get collectionSlotNamesItem3 => 'Lewo';

  @override
  String get collectionSortName => 'Nazwa';

  @override
  String get collectionSortPrice => 'Cena';

  @override
  String get collectionSortRarity => 'Rzadkość';

  @override
  String get collectionSortWeapon => 'Broń';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skina',
      many: '$count skinów',
      few: '$count skiny',
      one: '$count skin',
    );
    return 'Filtr: $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Filtr: przedmioty $count/$total';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przedmiotu',
      many: '$count przedmiotów',
      few: '$count przedmioty',
      one: '$count przedmiot',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skina',
      many: '$count skinów',
      few: '$count skiny',
      one: '$count skin',
    );
    return '$_temp0 · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Graffiti';

  @override
  String get collectionTapToChangeCard => 'Dotknij, aby zmienić kartę';

  @override
  String get collectionTitle => 'Kolekcja';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString posiadanego tytułu',
      many: '$nString posiadanych tytułów',
      few: '$nString posiadane tytuły',
      one: '$nString posiadany tytuł',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Cofnij';

  @override
  String get collectionUnknownCard => 'Nieznana karta';

  @override
  String get collectionValueAtStorePrices => 'Według cen w sklepie';

  @override
  String get collectionValueHasEstimates => 'Zawiera szacunki (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return 'Pominięte skiny z nagród: $n';
  }

  @override
  String get collectionValueSeeSkins => 'Zobacz skiny';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Na podstawie $n skina',
      many: 'Na podstawie $n skinów',
      few: 'Na podstawie $n skinów',
      one: 'Na podstawie $n skina',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Warianty';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'Bronie ze skinami: $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Wyposażenie broni';

  @override
  String get collectionWeaponNotFound => 'Nie znaleziono tej broni.';

  @override
  String get collectionWeaponSkinsTitle => 'Wybierz skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skina',
      many: '$n skinów',
      few: '$n skiny',
      one: '$n skin',
      zero: 'Pusta',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Nie udało się opublikować z powodu niestosownych słów. Popraw treść i spróbuj ponownie.';

  @override
  String get communityModerationContentScam =>
      'Społeczność nie zezwala na reklamy sprzedaży kont, boostingu ani podawanie numerów telefonów. Usuń te treści i spróbuj ponownie.';

  @override
  String get communityModerationContentTooComplex =>
      'Treść ma zbyt wiele rozrzuconych znaków. Napisz ją prościej i spróbuj ponownie.';

  @override
  String get communityModerationAccountBanned =>
      'To konto ma zablokowany dostęp do Społeczności. Jeśli uważasz, że to pomyłka, skontaktuj się z ValHub w sekcji Informacje i kwestie prawne.';

  @override
  String get communityModerationAccountRestricted =>
      'To konto ma ograniczoną możliwość publikowania, komentowania, szukania drużyny i głosowania. Spróbuj ponownie później lub skontaktuj się z ValHub w sekcji Informacje i kwestie prawne.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Rankingowa',
      'unrated': 'Nierankingowa',
      'swiftplay': 'Szybka Gra',
      'spikerush': 'Gorączka Spike’a',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Drużynowy deathmatch',
      'premier': 'Premier',
      'custom': 'Gra niestandardowa',
      'other': 'Inne',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Azja i Pacyfik',
      'na': 'Ameryka Północna',
      'eu': 'Europa',
      'kr': 'Korea',
      'latam': 'Ameryka Łacińska',
      'br': 'Brazylia',
      'other': 'Nieznany region',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'Brak skinów w tym rankingu';

  @override
  String get communityRankingEmptyVotes =>
      'Brak polubień pasujących do wybranego zakresu i filtrów.';

  @override
  String get communityRankingEmptyRatings =>
      'Brak ocen w gwiazdkach pasujących do wybranego zakresu i filtrów.';

  @override
  String get communityRankingEmptyReviews =>
      'Brak recenzji pasujących do wybranego zakresu i filtrów.';

  @override
  String get communityRankingExplore => 'Znajdź skiny do obejrzenia i oceny';

  @override
  String get communityRankingExploreHint =>
      'Szukaj po nazwie skina lub broni. W rankingu pojawiają się tylko prawdziwe oceny społeczności.';

  @override
  String get communityRankingClear => 'Wyczyść filtry broni i czasu';

  @override
  String get communityRankingSort => 'Ranking według';

  @override
  String get communityRankingWeapon => 'Broń';

  @override
  String get communityRankingNoSearch =>
      'Brak pasujących skinów. Spróbuj innej nazwy lub wyczyść filtr broni.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Nie udało się wczytać listy skinów. Zamknij panel i spróbuj ponownie po zsynchronizowaniu danych.';

  @override
  String get communityConsentExitAccount =>
      'Nie zgadzam się · Wyloguj to konto';

  @override
  String get communityRankingGlobalAllTime => 'Globalnie · Od początku';

  @override
  String get communityRankingCatalogTitle => 'Wszystkie skiny';

  @override
  String get communityReviewOwnershipRequired =>
      'Aby ocenić ten skin, twoje konto musi go posiadać. Nadal możesz czytać oceny i komentarze społeczności.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Nie udało się potwierdzić, że masz ten skin. Odśwież Kolekcję lub spróbuj ponownie, gdy będziesz online.';

  @override
  String get communityReviewLegacyOwnership =>
      'Starsza recenzja · Posiadanie niepotwierdzone';

  @override
  String get communityReviewVerifiedOwner =>
      'Posiadanie potwierdzone w chwili recenzji';

  @override
  String get communitySkinDiscussionHint =>
      'Każdy może komentować. Tylko właściciele skina mogą dawać gwiazdki i pisać recenzje.';

  @override
  String get communityAddPhotos => 'Dodaj zdjęcia';

  @override
  String get communityAllModes => 'Wszystkie';

  @override
  String get communityAllWeapons => 'Wszystkie bronie';

  @override
  String get communityAnonymousBanner => 'Przeglądasz anonimowo';

  @override
  String get communityAnyLanguage => 'Dowolny język';

  @override
  String get communityAnyRank => 'Dowolna ranga';

  @override
  String get communityAnyRole => 'Dowolna rola';

  @override
  String get communityApply => 'Zastosuj';

  @override
  String get communityBackToMyCountry => 'Wróć do mojego kraju';

  @override
  String get communityBlockAuthor => 'Zablokuj na tym urządzeniu';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Wyczyść';

  @override
  String get communityCodeAuto =>
      'Zostaw puste: ValHub utworzy kod z twojej drużyny w grze, gdy opublikujesz ogłoszenie.';

  @override
  String get communityCodeAutoFailed =>
      'Nie udało się utworzyć kodu drużyny. Otwórz VALORANT lub wpisz kod ręcznie.';

  @override
  String get communityCodeInvalid =>
      'Kod musi mieć dokładnie 6 wielkich liter lub cyfr.';

  @override
  String get communityCodeRequired => 'Wpisz lub utwórz kod drużyny.';

  @override
  String get communityCommentHint => 'Napisz komentarz…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString komentarza',
      many: '$nString komentarzy',
      few: '$nString komentarze',
      one: '$nString komentarz',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Komentarze · $n';
  }

  @override
  String get communityCommentsTitle => 'Komentarze';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Posty: $posts · Gracze: $authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString ogłoszenia o szukaniu drużyny',
      many: '$nString ogłoszeń o szukaniu drużyny',
      few: '$nString ogłoszenia o szukaniu drużyny',
      one: '$nString ogłoszenie o szukaniu drużyny',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Ulubione społeczności';

  @override
  String get communityComposerHint => 'Co dziś myślisz o VALORANT?';

  @override
  String get communityComposerTitle => 'Nowy post';

  @override
  String communityConsentAccount(String riotId) {
    return 'Konto: $riotId';
  }

  @override
  String get communityConsentAgree => 'Zgadzam się i kontynuuję';

  @override
  String get communityConsentGateAction => 'Dołącz';

  @override
  String get communityConsentGuidelines => 'Zasady społeczności';

  @override
  String get communityConsentLater => 'Później';

  @override
  String get communityConsentLocal =>
      'Twoje hasło i inne dane logowania zawsze zostają na tym urządzeniu. Zgodę możesz wycofać w Ustawieniach.';

  @override
  String get communityConsentPrivacy => 'Polityka prywatności';

  @override
  String get communityConsentPublic =>
      'Inni zobaczą twój Riot ID, kartę gracza, rangę i kraj.';

  @override
  String get communityConsentTitle => 'Prywatność i Społeczność ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub przekazuje dostęp do Riot serwerowi Społeczności, aby potwierdzić twój Riot ID przy połączeniu i sprawdzić posiadanie skina, gdy zapisujesz recenzję. Serwer odczytuje tylko potrzebne dane, od razu porzuca dostęp i niczego nie przechowuje.';

  @override
  String get communityConsentWithdrawn =>
      'Wycofano zgodę. Aby dalej korzystać z aplikacji, musisz zgodzić się ponownie.';

  @override
  String get communityCountriesTitle => 'Społeczności według krajów';

  @override
  String get communityCountryNamesAE => 'Zjednoczone Emiraty Arabskie';

  @override
  String get communityCountryNamesAL => 'Albania';

  @override
  String get communityCountryNamesAM => 'Armenia';

  @override
  String get communityCountryNamesAR => 'Argentyna';

  @override
  String get communityCountryNamesAT => 'Austria';

  @override
  String get communityCountryNamesAU => 'Australia';

  @override
  String get communityCountryNamesAZ => 'Azerbejdżan';

  @override
  String get communityCountryNamesBA => 'Bośnia i Hercegowina';

  @override
  String get communityCountryNamesBD => 'Bangladesz';

  @override
  String get communityCountryNamesBE => 'Belgia';

  @override
  String get communityCountryNamesBG => 'Bułgaria';

  @override
  String get communityCountryNamesBH => 'Bahrajn';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Boliwia';

  @override
  String get communityCountryNamesBR => 'Brazylia';

  @override
  String get communityCountryNamesBY => 'Białoruś';

  @override
  String get communityCountryNamesCA => 'Kanada';

  @override
  String get communityCountryNamesCH => 'Szwajcaria';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'Chiny';

  @override
  String get communityCountryNamesCO => 'Kolumbia';

  @override
  String get communityCountryNamesCR => 'Kostaryka';

  @override
  String get communityCountryNamesCU => 'Kuba';

  @override
  String get communityCountryNamesCY => 'Cypr';

  @override
  String get communityCountryNamesCZ => 'Czechy';

  @override
  String get communityCountryNamesDE => 'Niemcy';

  @override
  String get communityCountryNamesDK => 'Dania';

  @override
  String get communityCountryNamesDO => 'Dominikana';

  @override
  String get communityCountryNamesDZ => 'Algieria';

  @override
  String get communityCountryNamesEC => 'Ekwador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Egipt';

  @override
  String get communityCountryNamesES => 'Hiszpania';

  @override
  String get communityCountryNamesET => 'Etiopia';

  @override
  String get communityCountryNamesFI => 'Finlandia';

  @override
  String get communityCountryNamesFR => 'Francja';

  @override
  String get communityCountryNamesGB => 'Wielka Brytania';

  @override
  String get communityCountryNamesGE => 'Gruzja';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Grecja';

  @override
  String get communityCountryNamesGT => 'Gwatemala';

  @override
  String get communityCountryNamesHK => 'Hongkong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Chorwacja';

  @override
  String get communityCountryNamesHU => 'Węgry';

  @override
  String get communityCountryNamesID => 'Indonezja';

  @override
  String get communityCountryNamesIE => 'Irlandia';

  @override
  String get communityCountryNamesIL => 'Izrael';

  @override
  String get communityCountryNamesIN => 'Indie';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Islandia';

  @override
  String get communityCountryNamesIT => 'Włochy';

  @override
  String get communityCountryNamesJO => 'Jordania';

  @override
  String get communityCountryNamesJP => 'Japonia';

  @override
  String get communityCountryNamesKE => 'Kenia';

  @override
  String get communityCountryNamesKH => 'Kambodża';

  @override
  String get communityCountryNamesKR => 'Korea Południowa';

  @override
  String get communityCountryNamesKW => 'Kuwejt';

  @override
  String get communityCountryNamesKZ => 'Kazachstan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Liban';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Litwa';

  @override
  String get communityCountryNamesLU => 'Luksemburg';

  @override
  String get communityCountryNamesLV => 'Łotwa';

  @override
  String get communityCountryNamesLY => 'Libia';

  @override
  String get communityCountryNamesMA => 'Maroko';

  @override
  String get communityCountryNamesMD => 'Mołdawia';

  @override
  String get communityCountryNamesME => 'Czarnogóra';

  @override
  String get communityCountryNamesMK => 'Macedonia Północna';

  @override
  String get communityCountryNamesMM => 'Mjanma';

  @override
  String get communityCountryNamesMN => 'Mongolia';

  @override
  String get communityCountryNamesMO => 'Makau';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Meksyk';

  @override
  String get communityCountryNamesMY => 'Malezja';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nikaragua';

  @override
  String get communityCountryNamesNL => 'Holandia';

  @override
  String get communityCountryNamesNO => 'Norwegia';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Nowa Zelandia';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Filipiny';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Polska';

  @override
  String get communityCountryNamesPR => 'Portoryko';

  @override
  String get communityCountryNamesPT => 'Portugalia';

  @override
  String get communityCountryNamesPY => 'Paragwaj';

  @override
  String get communityCountryNamesQA => 'Katar';

  @override
  String get communityCountryNamesRO => 'Rumunia';

  @override
  String get communityCountryNamesRS => 'Serbia';

  @override
  String get communityCountryNamesRU => 'Rosja';

  @override
  String get communityCountryNamesSA => 'Arabia Saudyjska';

  @override
  String get communityCountryNamesSE => 'Szwecja';

  @override
  String get communityCountryNamesSG => 'Singapur';

  @override
  String get communityCountryNamesSI => 'Słowenia';

  @override
  String get communityCountryNamesSK => 'Słowacja';

  @override
  String get communityCountryNamesSV => 'Salwador';

  @override
  String get communityCountryNamesTH => 'Tajlandia';

  @override
  String get communityCountryNamesTL => 'Timor Wschodni';

  @override
  String get communityCountryNamesTN => 'Tunezja';

  @override
  String get communityCountryNamesTR => 'Turcja';

  @override
  String get communityCountryNamesTW => 'Tajwan';

  @override
  String get communityCountryNamesUA => 'Ukraina';

  @override
  String get communityCountryNamesUS => 'Stany Zjednoczone';

  @override
  String get communityCountryNamesUY => 'Urugwaj';

  @override
  String get communityCountryNamesUZ => 'Uzbekistan';

  @override
  String get communityCountryNamesVE => 'Wenezuela';

  @override
  String get communityCountryNamesVN => 'Wietnam';

  @override
  String get communityCountryNamesZA => 'Republika Południowej Afryki';

  @override
  String get communityCreateLfg => 'Utwórz ogłoszenie';

  @override
  String get communityCreateLfgShort => 'Ogłoś';

  @override
  String get communityDataDeleted => 'Usunięto twoje dane Społeczności.';

  @override
  String communityDataFooter(String riotId) {
    return 'Dotyczy obecnego konta: $riotId. Pobrany plik nie zawiera hasła ani danych logowania Riot.';
  }

  @override
  String get communityDecrease => 'Zmniejsz';

  @override
  String get communityDelete => 'Usuń';

  @override
  String get communityDeleteComment => 'Usuń komentarz';

  @override
  String get communityDeleteCommentBody =>
      'Ten komentarz zostanie trwale usunięty.';

  @override
  String get communityDeleteCommentTitle => 'Usunąć komentarz?';

  @override
  String get communityDeleteDataConfirm => 'Usuń trwale';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Wszystkie posty, komentarze, recenzje skinów, polubienia, głosy, ogłoszenia o szukaniu drużyny i zdjęcia konta $riotId w Społeczności ValHub zostaną trwale usunięte bez możliwości odzyskania. Aby dalej używać tego konta w ValHub, trzeba będzie ponownie wyrazić zgodę; możesz też przełączyć się na inne konto lub wylogować to.\n\nTwoje konto Riot i dane w grze pozostaną nienaruszone. Jeśli chcesz zachować kopię, najpierw pobierz dane.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Usunąć dane Społeczności?';

  @override
  String get communityDeleteDataSubtitle =>
      'Trwale usuń wszystko, co opublikowano w Społeczności.';

  @override
  String get communityDeleteDataTitle => 'Usuń moje dane Społeczności';

  @override
  String get communityDeletePost => 'Usuń post';

  @override
  String get communityDeletePostBody =>
      'Ten post i wszystkie jego komentarze zostaną trwale usunięte.';

  @override
  String get communityDeletePostTitle => 'Usunąć post?';

  @override
  String get communityDeleteReview => 'Usuń recenzję';

  @override
  String get communityDeleteReviewBody =>
      'Twoja ocena i recenzja tego skina zostaną usunięte.';

  @override
  String get communityDeleteReviewTitle => 'Usunąć twoją recenzję?';

  @override
  String get communityDeleted => 'Usunięto.';

  @override
  String get communityDiscard => 'Odrzuć';

  @override
  String get communityDiscardBody =>
      'To, co właśnie napisano, nie zostanie zapisane.';

  @override
  String get communityDiscardTitle => 'Odrzucić post?';

  @override
  String get communityDownload => 'Pobierz i przetłumacz';

  @override
  String get communityDownloadingModels => 'Pobieranie pakietu językowego…';

  @override
  String get communityEditReview => 'Edytuj';

  @override
  String get communityEdited => 'edytowano';

  @override
  String get communityEmptyPost => 'Napisz coś lub dodaj zdjęcie.';

  @override
  String get communityExpired => 'Wygasło';

  @override
  String communityExpiresIn(String t) {
    return 'Zostało: $t';
  }

  @override
  String get communityExportPreparing => 'Przygotowywanie…';

  @override
  String get communityExportSubject => 'Dane Społeczności ValHub';

  @override
  String get communityExportSubtitle =>
      'Kopia wszystkiego, co opublikowano w Społeczności: posty, komentarze, recenzje, polubienia, głosy i ogłoszenia o szukaniu drużyny.';

  @override
  String get communityExportTitle => 'Pobierz moje dane';

  @override
  String get communityExtend => 'Przedłuż';

  @override
  String get communityExtended => 'Przedłużono ogłoszenie o 30 minut.';

  @override
  String get communityFeedEmptyBody =>
      'Bądź pierwszą osobą, która pokaże swój sklep, Nocny Targ lub najlepsze momenty!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Brak pasujących postów. Wybierz inny język lub wyczyść filtry.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Brak nowych postów. Wróć później lub dołącz, aby coś udostępnić.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Zobacz posty społeczności międzynarodowej lub zmień filtry.';

  @override
  String get communityFeedEmptyScopeTitle => 'Brak postów w tym zakresie';

  @override
  String get communityFeedEmptyTitle => 'Tablica jest pusta';

  @override
  String get communityFilters => 'Filtry';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Przetłumaczono przez Google';

  @override
  String get communityHelpful => 'Pomocne';

  @override
  String communityHelpfulCount(String n) {
    return 'Pomocne · $n';
  }

  @override
  String get communityHiddenAuthors => 'Ukryci i zablokowani gracze';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Nikogo nie ukryto ani nie zablokowano';

  @override
  String get communityHiddenAuthorsHint =>
      'Dotyczy tylko tego konta na tym urządzeniu. Ich treści są ukryte; oni nadal widzą twoje publiczne treści.';

  @override
  String communityImageOf(int i, int n) {
    return 'Zdjęcie $i/$n';
  }

  @override
  String get communityIncrease => 'Zwiększ';

  @override
  String get communityJoin => 'Dołącz';

  @override
  String get communityJoinCodeExpired =>
      'Kod drużyny wygasł lub jest już nieważny.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Opuścisz obecną drużynę w VALORANT, aby dołączyć do drużyny gracza $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Dołączyć do tej drużyny?';

  @override
  String get communityJoinGameNotRunning =>
      'Uruchom VALORANT na komputerze lub konsoli i spróbuj ponownie.';

  @override
  String get communityJoinParty => 'Dołącz do drużyny';

  @override
  String get communityJoinPartyFull => 'Ta drużyna jest pełna.';

  @override
  String get communityJoinedHint =>
      'Dołączono do drużyny! Uruchom VALORANT, aby zagrać razem.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString prośby o dołączenie',
      many: '$nString próśb o dołączenie',
      few: '$nString prośby o dołączenie',
      one: '$nString prośba o dołączenie',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Nocny Targ';

  @override
  String get communityKindStore => 'Dzisiejszy sklep';

  @override
  String get communityLanguage => 'Język';

  @override
  String get communityLanguageFilter => 'Język treści';

  @override
  String get communityLanguageFilterHint =>
      'Pokazuj tylko treści napisane w wybranych językach. Zostaw puste, aby widzieć wszystko.';

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
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n języka',
      many: '$n języków',
      few: '$n języki',
      one: '$n język',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Utwórz ogłoszenie, aby inni gracze mogli dołączyć do twojej drużyny jednym dotknięciem.';

  @override
  String get communityLfgEmptyTitle => 'Nikt jeszcze nie szuka drużyny';

  @override
  String get communityLfgExpiredRepost =>
      'Twoje ogłoszenie wygasło. Utwórz nowe, aby znaleźć drużynę.';

  @override
  String get communityLfgGateBody =>
      'Dołącz (jednorazowo potwierdzając Riot ID), aby widzieć ogłoszenia graczy z twojego serwera i publikować własne. Tablicę i ranking skinów nadal możesz przeglądać jak zwykle.';

  @override
  String get communityLfgGateTitle => 'Szukanie drużyny jest dla członków';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Przeglądasz serwer: $region — do drużyny mogą dołączyć tylko gracze z tego samego serwera co twoje konto.';
  }

  @override
  String get communityLfgPosted => 'Opublikowano ogłoszenie!';

  @override
  String get communityLfgPreviewTitle => 'Znajdź drużynę na swoim poziomie';

  @override
  String get communityLfgRemoved => 'Usunięto ogłoszenie.';

  @override
  String get communityLfgSameShardNote =>
      'Do drużyny mogą dołączyć tylko gracze z tego samego serwera.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Region: $region · Ogłoszenia wygasają automatycznie po 30 minutach.';
  }

  @override
  String get communityLike => 'Lubię to';

  @override
  String get communityLiveMembers => 'Członkowie';

  @override
  String get communityMatchMyRank => 'Pasuje do twojej rangi';

  @override
  String communityMemberJoined(String name) {
    return '$name dołącza do drużyny';
  }

  @override
  String get communityMemberJoinedBody =>
      'Ktoś właśnie dołączył z twojego ogłoszenia.';

  @override
  String get communityMic => 'Wymagany mikrofon';

  @override
  String get communityMicOn => 'Ma mikrofon';

  @override
  String get communityMode => 'Tryb';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Więcej opcji';

  @override
  String get communityMuteAuthor => 'Ukryj tego gracza';

  @override
  String get communityNewPost => 'Opublikuj';

  @override
  String communityNightMarketOf(String date) {
    return 'Nocny Targ z dnia $date';
  }

  @override
  String get communityNoAccountBody =>
      'Dodaj konto Riot, aby publikować, szukać drużyny i głosować na skiny.';

  @override
  String get communityNoAccountTitle => 'Zaloguj się, aby dołączyć';

  @override
  String get communityNoComments =>
      'Brak komentarzy. Napisz coś jako pierwszy!';

  @override
  String get communityNoRatings => 'Brak ocen';

  @override
  String get communityNote => 'Notatka';

  @override
  String get communityNoteHint =>
      'Np. potrzebny 1 Kontroler, mikrofon, gramy dla zabawy';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Łącznie $amount';
  }

  @override
  String get communityOpenReviews => 'Zobacz recenzje';

  @override
  String get communityOutOfRange => 'Poza zakresem rang';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Kod drużyny';

  @override
  String get communityPartyCodeHint => 'Np. A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Kod drużyny: $code';
  }

  @override
  String get communityPartySize => 'Obecna drużyna';

  @override
  String get communityPartySizeFromGame => 'Pobrano z drużyny w grze';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gracza',
      many: '$n graczy',
      few: '$n graczy',
      one: '$n gracz',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return 'Zdjęcia: $n/$max';
  }

  @override
  String get communityPlayVideo => 'Obejrzyj film';

  @override
  String get communityPostLfg => 'Opublikuj';

  @override
  String get communityPostNotFound => 'Ten post został usunięty lub ukryty.';

  @override
  String get communityPostTitle => 'Post';

  @override
  String get communityPosted => 'Opublikowano!';

  @override
  String get communityPublish => 'Opublikuj';

  @override
  String get communityPublishing => 'Publikowanie…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Od';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Zakres rang';

  @override
  String get communityRankRangeInvalid =>
      'Najniższa ranga nie może być wyższa od najwyższej.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Miejsce $n: $name';
  }

  @override
  String get communityRankTo => 'Do';

  @override
  String get communityRateLimitedTitle => 'Chwileczkę';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString oceny',
      many: '$nString ocen',
      few: '$nString oceny',
      one: '$nString ocena',
    );
    return '$_temp0';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString oceny',
      many: '$nString ocen',
      few: '$nString oceny',
      one: '$nString ocena',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Słaby';

  @override
  String get communityRatingWordsItem1 => 'Taki sobie';

  @override
  String get communityRatingWordsItem2 => 'W porządku';

  @override
  String get communityRatingWordsItem3 => 'Świetny';

  @override
  String get communityRatingWordsItem4 => 'Arcydzieło';

  @override
  String get communityRefreshList => 'Odśwież';

  @override
  String get communityRegion => 'Region';

  @override
  String get communityRemoveAttachment => 'Usuń załącznik';

  @override
  String get communityRemoveLfg => 'Usuń ogłoszenie';

  @override
  String get communityRemoveLfgBody =>
      'Inni gracze nie będą już widzieć tego ogłoszenia.';

  @override
  String get communityRemoveLfgTitle => 'Usunąć ogłoszenie?';

  @override
  String get communityRemovePhoto => 'Usuń zdjęcie';

  @override
  String get communityReport => 'Zgłoś';

  @override
  String get communityReportConfirmBody =>
      'Treści zgłoszone przez wielu graczy zostaną ukryte w Społeczności.';

  @override
  String get communityReportConfirmTitle => 'Wysłać zgłoszenie?';

  @override
  String get communityReportPrompt => 'Dlaczego zgłaszasz tę treść?';

  @override
  String get communityReportReasonsSpam => 'Spam lub reklama';

  @override
  String get communityReportReasonsHarassment => 'Nękanie lub obrażanie';

  @override
  String get communityReportReasonsInappropriate => 'Niestosowna treść';

  @override
  String get communityReportReasonsScam => 'Oszustwo lub sprzedaż kont';

  @override
  String get communityReportReasonsOther => 'Inny powód';

  @override
  String get communityReportTitle => 'Zgłoś treść';

  @override
  String get communityReported => 'Dzięki! Zgłoszenie zostało wysłane.';

  @override
  String get communityReviewDeleted => 'Usunięto recenzję.';

  @override
  String get communityReviewHint =>
      'Napisz, co myślisz o tym skinie (opcjonalnie)';

  @override
  String get communityReviewSaved => 'Zapisano recenzję!';

  @override
  String get communityReviewTitle => 'Oceń skin';

  @override
  String get communityReviewsEmptyBody => 'Brak recenzji — napisz pierwszą!';

  @override
  String get communityReviewsEmptyTitle => 'Brak recenzji';

  @override
  String communityReviewsHeader(String n) {
    return 'Recenzje · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot ma problemy';

  @override
  String get communityRoleFlex => 'Dowolna';

  @override
  String get communityRoles => 'Potrzebne role';

  @override
  String get communitySaveReview => 'Zapisz recenzję';

  @override
  String get communityScopeCountry => 'Twój kraj';

  @override
  String get communityScopeGlobal => 'Międzynarodowa';

  @override
  String get communityScopeRegion => 'Region';

  @override
  String get communitySectionFeed => 'Tablica';

  @override
  String get communitySectionLfg => 'Szukaj drużyny';

  @override
  String get communitySectionSkins => 'Ranking skinów';

  @override
  String get communitySend => 'Wyślij';

  @override
  String get communitySendComment => 'Wyślij komentarz';

  @override
  String get communityShareNightMarketHint =>
      'Pochwal się swoim Nocnym Targiem';

  @override
  String communitySharePostTitle(String name) {
    return 'Post gracza $name w ValHub';
  }

  @override
  String get communityShareStore => 'Udostępnij w Społeczności';

  @override
  String get communityShareStoreHint => 'Pochwal się dzisiejszym sklepem';

  @override
  String get communityShowOriginal => 'Pokaż oryginał';

  @override
  String get communityShowTranslation => 'Pokaż tłumaczenie';

  @override
  String get communitySignInToReview => 'Dodaj konto Riot, aby oceniać skiny.';

  @override
  String get communitySkinNotFound => 'Nie znaleziono tego skina.';

  @override
  String get communitySlots => 'Potrzebni gracze';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other:
          'Drużyna może mieć maksymalnie 5 graczy: zostało tylko $max miejsca.',
      many:
          'Drużyna może mieć maksymalnie 5 graczy: zostało tylko $max miejsc.',
      few:
          'Drużyna może mieć maksymalnie 5 graczy: zostały tylko $max miejsca.',
      one:
          'Drużyna może mieć maksymalnie 5 graczy: zostało tylko $max miejsce.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Potrzeba $n gracza',
      many: 'Potrzebnych $n graczy',
      few: 'Potrzebnych $n graczy',
      one: 'Potrzebny $n gracz',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Najbardziej pomocne';

  @override
  String get communitySortNewest => 'Najnowsze';

  @override
  String get communitySortRating => 'Najwyżej oceniane';

  @override
  String get communitySortReviews => 'Najwięcej recenzji';

  @override
  String get communitySortVotes => 'Najbardziej lubiane';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gwiazdki',
      many: '$n gwiazdek',
      few: '$n gwiazdki',
      one: '$n gwiazdka',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg na 5 gwiazdek';
  }

  @override
  String get communityStatusFull => 'Pełna';

  @override
  String get communityStatusInGame => 'W meczu';

  @override
  String get communityStatusOpen => 'Szuka';

  @override
  String communityStoreOf(String date) {
    return 'Sklep z dnia $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Dotknij gwiazdek, aby ocenić ten skin';

  @override
  String get communityTitle => 'Społeczność';

  @override
  String communityTooLong(int max) {
    return 'Limit znaków: $max.';
  }

  @override
  String get communityTranslate => 'Przetłumacz przez Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Aby tłumaczyć z języka $from na $to, ValHub musi pobrać pakiet językowy od Google (około $size). Pobierasz go tylko raz; treści są tłumaczone wyłącznie na twoim urządzeniu i nie trafiają na żaden serwer.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Pobrać pakiet językowy na urządzenie?';

  @override
  String get communityTranslateFailed =>
      'Nie udało się przetłumaczyć. Spróbuj ponownie.';

  @override
  String get communityTranslatedByGoogle =>
      'Automatycznie przetłumaczone przez Google';

  @override
  String get communityTranslating => 'Tłumaczenie…';

  @override
  String get communityTrendingTitle => 'Najbardziej lubiane skiny na świecie';

  @override
  String get communityUnavailableBody =>
      'Nie udało się połączyć ze Społecznością ValHub. Spróbuj ponownie za kilka minut.';

  @override
  String get communityUnavailableTitle => 'Brak połączenia ze Społecznością';

  @override
  String get communityUnhideAuthor => 'Pokaż / odblokuj';

  @override
  String get communityUnknownPlayer => 'Gracz';

  @override
  String get communityUnlike => 'Cofnij polubienie';

  @override
  String get communityUnvote => 'Usuń serduszko';

  @override
  String get communityVote => 'Daj serduszko temu skinowi';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString polubienia',
      many: '$nString polubień',
      few: '$nString polubienia',
      one: '$nString polubienie',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Wycofaj';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub przestanie korzystać ze Społeczności przy użyciu konta $riotId i usunie połączenie ze Społecznością na tym urządzeniu. Aby dalej używać tego konta w ValHub, trzeba będzie ponownie wyrazić zgodę; możesz też przełączyć się na inne konto lub wylogować to.\n\nOpublikowane posty, komentarze, recenzje, głosy i ogłoszenia o szukaniu drużyny pozostaną w Społeczności i nadal będą pokazywać twój Riot ID, dopóki nie usuniesz ich pojedynczo lub nie wybierzesz opcji „Usuń moje dane Społeczności”.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Wycofać zgodę?';

  @override
  String get communityWithdrawSubtitle =>
      'Przestań korzystać ze Społeczności na tym koncie. Twoje posty zostaną zachowane.';

  @override
  String get communityWithdrawTitle => 'Wycofaj zgodę';

  @override
  String get communityWriteFirstReview => 'Napisz pierwszą recenzję';

  @override
  String get communityYou => 'Ty';

  @override
  String get communityYourCountry => 'Twój kraj';

  @override
  String get communityYourReview => 'Twoja recenzja';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ukryto $nString osoby',
      many: 'Ukryto $nString osób',
      few: 'Ukryto $nString osoby',
      one: 'Ukryto $nString osobę',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgOtherServer => 'Nie twój serwer';

  @override
  String get communityLfgEmptyRankTitle => 'Brak ogłoszeń dla twojej rangi';

  @override
  String get communityLfgEmptyRankBody =>
      'Ogłoszenia, które nie przyjmują twojej rangi, są ukryte.';

  @override
  String get communityLfgShowAllRanks => 'Pokaż wszystkie rangi';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Ty: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Wybór agenta';

  @override
  String get liveGameAnonymous => 'Anonimowy';

  @override
  String get liveGameAutoRefreshNote =>
      'Odświeża się automatycznie, gdy jesteś w meczu.';

  @override
  String get liveGameCurrentGame => 'Obecny mecz';

  @override
  String get liveGameEmptyTeam => 'Brak graczy.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Drużyna przeciwna pojawi się po rozpoczęciu meczu.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Przeciwnicy zablokowali: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'K/D/A i tablica wyników pojawią się po meczu.';

  @override
  String get liveGameFinalScoreboard => 'Końcowa tablica wyników';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'W poczekalni';

  @override
  String get liveGameInMatch => 'W meczu';

  @override
  String get liveGameInQueue => 'W kolejce';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'W kolejce · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Poziom $n';
  }

  @override
  String get liveGameLiveScore => 'Wynik na żywo';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Wyposażenie z wyboru agenta';

  @override
  String get liveGameLoadoutFromMatch => 'Wyposażenie w tym meczu';

  @override
  String get liveGameLobbyHint =>
      'Gdy mecz zostanie znaleziony, ValHub pokaże składy i rangi wszystkich graczy.';

  @override
  String get liveGameLockedTag => 'Zablokowany';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub spróbuje ponownie automatycznie. Tablica wyników jest zwykle gotowa po około minucie.';

  @override
  String get liveGameNoAgentYet => 'Nie wybrano agenta';

  @override
  String get liveGameNoLoadout => 'Brak informacji o wyposażeniu tego gracza.';

  @override
  String get liveGameNotInGame => 'Nie w meczu';

  @override
  String get liveGameNotInGameHint =>
      'Uruchom VALORANT i dołącz do kolejki — szczegóły meczu pojawią się tu automatycznie po przejściu do wyboru agenta.';

  @override
  String get liveGameNotInGameTitle => 'Nie jesteś w meczu';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Zobacz wyposażenie: $name';
  }

  @override
  String get liveGameOpenParty => 'Otwórz drużynę i kolejkę';

  @override
  String get liveGameParty => 'Drużyna';

  @override
  String liveGamePeak(String rank) {
    return 'Najwyższa: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Wyposażenie: $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Wyposażenie';

  @override
  String get liveGameQueueHint =>
      'Nie zamykaj aplikacji — szczegóły meczu pojawią się, gdy tylko mecz zostanie znaleziony.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Opuszczenie meczu może skutkować karą (utrata RR, blokada kolejki). Opuścić mimo to?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Opuszczenie wyboru agenta może skutkować karą (utrata RR, blokada kolejki). Opuścić mimo to?';

  @override
  String get liveGameQuitConfirmTitle => 'Opuścić mecz?';

  @override
  String get liveGameQuitDone => 'Opuszczono mecz.';

  @override
  String get liveGameQuitFailed => 'Nie udało się opuścić meczu.';

  @override
  String get liveGameQuitMatch => 'Opuść mecz';

  @override
  String get liveGameQuitMatchChanged =>
      'Mecz przeszedł do nowej fazy, gdy potwierdzano wyjście. Nie opuszczono meczu, spróbuj ponownie.';

  @override
  String get liveGameRankUnavailable => 'Nieznana ranga';

  @override
  String get liveGameRefresh => 'Odśwież';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Odświeżenie za $seconds sekundy',
      many: 'Odświeżenie za $seconds sekund',
      few: 'Odświeżenie za $seconds sekundy',
      one: 'Odświeżenie za $seconds sekundę',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Odśwież teraz';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Szczegóły meczu';

  @override
  String get liveGameSprays => 'Graffiti';

  @override
  String get liveGameStatusAgentSelect => 'Wybór agenta';

  @override
  String get liveGameStatusEnded => 'Zakończony';

  @override
  String get liveGameStatusInProgress => 'W toku';

  @override
  String get liveGameStatusUnavailable =>
      'Nie udało się zaktualizować statusu meczu';

  @override
  String get liveGameTabAllPlayers => 'Gracze';

  @override
  String get liveGameTabEnemyTeam => 'Przeciwnicy';

  @override
  String get liveGameTabYourTeam => 'Twoja drużyna';

  @override
  String liveGameTimeLeft(String t) {
    return 'Zostało: $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Zobacz szczegóły meczu';

  @override
  String get liveGameWeapons => 'Broń';

  @override
  String get liveGameYou => 'TY';

  @override
  String liveGameYouHover(String agent) {
    return 'Wybierasz: $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Zablokowano: $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Wybierz i zablokuj agenta w VALORANT. ValHub pokazuje tylko pozostały czas i twoją drużynę.';

  @override
  String get liveGameLastMatchTitle => 'Ostatni mecz';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wygranej',
      many: '$wins wygranych',
      few: '$wins wygrane',
      one: '$wins wygrana',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses porażki',
      many: '$losses porażek',
      few: '$losses porażki',
      one: '$losses porażka',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws remisu',
      many: ' – $draws remisów',
      few: ' – $draws remisy',
      one: ' – $draws remis',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown meczu z nieznanym wynikiem',
      many: ' – $unknown meczów z nieznanym wynikiem',
      few: ' – $unknown mecze z nieznanym wynikiem',
      one: ' – $unknown mecz z nieznanym wynikiem',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'czas urządzenia ($offset)';
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
      'yes': ', broń: $weapon',
      'other': '',
    });
    return '$killer eliminuje $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 dni',
      'days7': '7 dni',
      'other': 'Cały okres',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agenci',
      'maps': 'Mapy',
      'queues': 'Tryby',
      'sides': 'Atak / Obrona',
      'trend': 'Trend',
      'other': 'Tryby',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Wszystkie tryby';

  @override
  String get profileAbility => 'Umiejętność';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meczu',
      many: '$n meczów',
      few: '$n mecze',
      one: '$n mecz',
    );
    return '≈ $_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Średni wynik bojowy';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return 'Ten akt: wygrane $wins z $games · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Wszyscy gracze';

  @override
  String get profileAlreadyReached => 'Masz już tę rangę.';

  @override
  String get profileAtCurrentForm => 'Przy obecnej formie';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Przy obecnej formie ($gain / $loss na mecz)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Najlepiej: $n wygranej z rzędu',
      many: 'Najlepiej: $n wygranych z rzędu',
      few: 'Najlepiej: $n wygrane z rzędu',
      one: 'Najlepiej: $n wygrana z rzędu',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Według współczynnika wygranych';

  @override
  String get profileChooseMap => 'Filtruj według mapy';

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
  String get profileCopyRiotId => 'Kopiuj Riot ID';

  @override
  String get profileCurrentRank => 'Obecna';

  @override
  String get profileDailyRrEmpty =>
      'Na tym urządzeniu nie zapisano jeszcze meczów rankingowych.';

  @override
  String get profileDailyRrFootnote =>
      'Historia RR jest zapisywana na twoim urządzeniu, łącznie z meczami, których Riot już nie zwraca.';

  @override
  String get profileDailyRrTitle => 'RR dziennie';

  @override
  String profileDayBoundary(String zone) {
    return 'Dni liczone według: $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dnia z meczami',
      many: '$n dni z meczami',
      few: '$n dni z meczami',
      one: '$n dzień z meczami',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Pokazano wszystkie mecze';

  @override
  String get profileEnemyTeam => 'Przeciwnicy';

  @override
  String get profileFallDamage => 'Obrażenia od upadku';

  @override
  String get profileFilterAll => 'Wszystkie';

  @override
  String get profileFirstBloods => 'Pierwsze zabójstwa';

  @override
  String get profileFirstDeaths => 'Pierwsze zgony';

  @override
  String get profileFirstHalf => 'Pierwsza połowa';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS i HS% liczą się tylko w trybach z rundami.';

  @override
  String profileFormPending(int n) {
    return 'Jeszcze niewczytane mecze z listy: $n.';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR i HS% liczone tylko z meczów z rundami: $roundGames/$games';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return 'Ostatnie mecze ($games): wygrane $w, porażki $l';
  }

  @override
  String get profileFriendsRow => 'Znajomi i czat';

  @override
  String get profileHideKills => 'Ukryj zabójstwa';

  @override
  String get profileHitBody => 'Tułów';

  @override
  String get profileHitDistribution => 'Rozkład trafień';

  @override
  String get profileHitHead => 'Głowa';

  @override
  String get profileHitLegs => 'Nogi';

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
      'Odsetek rund z zabójstwem, asystą, przeżyciem lub pomszczeniem przez drużynę';

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
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ostatnie $n dnia',
      many: 'Ostatnie $n dni',
      few: 'Ostatnie $n dni',
      one: 'Ostatni $n dzień',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ostatnie $n meczu',
      many: 'Ostatnie $n meczów',
      few: 'Ostatnie $n mecze',
      one: 'Ostatni $n mecz',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Tabela liderów #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Poziom $n';
  }

  @override
  String get profileLevelHidden => 'Poziom ukryty';

  @override
  String profileLossStreak(int n) {
    return 'Seria porażek: $n';
  }

  @override
  String profileMapFilter(String map) {
    return 'Mapa: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meczu',
      many: '$n meczów',
      few: '$n mecze',
      one: '$n mecz',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Szczegóły meczu';

  @override
  String get profileMatchHistory => 'Historia meczów';

  @override
  String get profileMatchUnavailable => 'Nie udało się wczytać meczu';

  @override
  String get profileMatchesNeeded => 'Potrzebne mecze';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Nigdy nie grano rankingowo';

  @override
  String get profileNoKillsInRound =>
      'Brak informacji o zabójstwach w tej rundzie.';

  @override
  String get profileNoMatches => 'Brak meczów.';

  @override
  String get profileNoMatchesMap =>
      'Wśród wczytanych meczów nie ma żadnego na tej mapie.';

  @override
  String get profileNoMatchesQueue => 'Brak meczów w tym trybie.';

  @override
  String get profileNoPlayers => 'Brak informacji o graczach tego meczu.';

  @override
  String get profileNoRounds =>
      'Brak informacji o poszczególnych rundach tego meczu.';

  @override
  String get profileOvertime => 'Dogrywka';

  @override
  String get profilePlayHubTitle => 'Mecz i drużyna';

  @override
  String get profilePeakRank => 'Najwyższa';

  @override
  String get profilePerformanceAttack => 'Atak';

  @override
  String get profilePerformanceDefense => 'Obrona';

  @override
  String get profilePerformanceEmpty =>
      'Na tym urządzeniu nie zapisano jeszcze meczów. Otwórz historię meczów, aby zapisać rozegrane mecze.';

  @override
  String get profilePerformanceNoMatches => 'Brak meczów w wybranym okresie.';

  @override
  String profilePerformanceRounds(int n) {
    return 'Zapisane rundy: $n';
  }

  @override
  String get profilePerformanceSample =>
      'Współczynniki pojawiają się od 3 meczów. ACS, ADR, HS% i K/D liczą się tylko w trybach z rundami.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Rundy z ustaloną stroną (atak lub obrona): $known/$total.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Historia na urządzeniu od $date';
  }

  @override
  String get profilePerformanceTitle => 'Wyniki';

  @override
  String profilePlacement(int n) {
    return 'Miejsce $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike podłożony na $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Profil gracza';

  @override
  String get profilePlayerSummary => 'Wyniki';

  @override
  String profileProgressTo(String rank) {
    return 'Postęp do: $rank';
  }

  @override
  String get profileProgressToTarget => 'Postęp do docelowej rangi';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Szacunek na podstawie ostatnich meczów rankingowych; nie uwzględnia meczów kwalifikacyjnych ani ochrony przed spadkiem.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches meczu do rangi $rank',
      many: '≈ $matches meczów do rangi $rank',
      few: '≈ $matches mecze do rangi $rank',
      one: '≈ $matches mecz do rangi $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'Masz już rangę Nieśmiertelny lub wyższą — ten kalkulator sięga tylko do Nieśmiertelny 1.';

  @override
  String get profileRankUpNoForm =>
      'Brak ostatnich meczów rankingowych, by oszacować twoją formę.';

  @override
  String get profileRankUpOpen => 'Otwórz kalkulator awansu';

  @override
  String get profileRankUpTitle => 'Kalkulator awansu';

  @override
  String get profileRankUpUnranked =>
      'Rozegraj mecze kwalifikacyjne, aby korzystać z kalkulatora awansu.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Tablica wyników rankingowa';

  @override
  String profileRecentForm(int w, int l) {
    return 'Ostatnia forma: wygrane $w, porażki $l';
  }

  @override
  String get profileRecentFormTitle => 'Ostatnia forma';

  @override
  String get profileRecentMatches => 'Ostatnie mecze';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}W · ${l}P · ${d}R',
      many: '${w}W · ${l}P · ${d}R',
      few: '${w}W · ${l}P · ${d}R',
      one: '${w}W · ${l}P · ${d}R',
      zero: '${w}W · ${l}P',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Skopiowano Riot ID';

  @override
  String profileRound(int n) {
    return 'Runda $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n zabójstwa',
      many: '$n zabójstw',
      few: '$n zabójstwa',
      one: '$n zabójstwo',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Runda przegrana';

  @override
  String get profileRoundTimeline => 'Przebieg rund';

  @override
  String get profileRoundWon => 'Runda wygrana';

  @override
  String get profileRoundsHint =>
      'Dotknij rundy, aby zobaczyć każde zabójstwo.';

  @override
  String profileRrLeft(String n) {
    return 'Brakuje: $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Trend RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Tablica wyników';

  @override
  String get profileSecondHalf => 'Druga połowa';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Pokaż zabójstwa';

  @override
  String get profileSideSwitch => 'Zmiana stron';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Docelowa ranga';

  @override
  String get profileTeamBlue => 'Drużyna niebieska';

  @override
  String get profileTeamMvp => 'MVP drużyny';

  @override
  String get profileTeamRed => 'Drużyna czerwona';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileToday(String text) {
    return 'Dzisiaj: $text';
  }

  @override
  String get profileTodayNone => 'Dziś brak meczów rankingowych';

  @override
  String get profileTruePeakLocal => 'Na podstawie historii na urządzeniu';

  @override
  String get profileWeekdayShortItem0 => 'Pn';

  @override
  String get profileWeekdayShortItem1 => 'Wt';

  @override
  String get profileWeekdayShortItem2 => 'Śr';

  @override
  String get profileWeekdayShortItem3 => 'Cz';

  @override
  String get profileWeekdayShortItem4 => 'Pt';

  @override
  String get profileWeekdayShortItem5 => 'So';

  @override
  String get profileWeekdayShortItem6 => 'Nd';

  @override
  String get profileWinRate => 'Współczynnik wygranych';

  @override
  String profileWinStreak(int n) {
    return 'Seria wygranych: $n';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Twoja ranga';

  @override
  String get profileYourSummary => 'Twoje wyniki';

  @override
  String get profileYourTeam => 'Twoja drużyna';

  @override
  String get profileYourWinRate => 'Twój ostatni współczynnik wygranych';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Tryb: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filtruj według trybu';

  @override
  String get profilePerformancePerMatchTitle => 'Mecz po meczu';

  @override
  String get profilePerformancePerMatchHint =>
      'Dotknij słupka, aby otworzyć ten mecz.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Średnia $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Do wykresu potrzeba co najmniej 2 meczów z rundami, w których jest ta statystyka.';

  @override
  String get profilePerformanceOpeningsTitle => 'Pojedynki otwarcia';

  @override
  String get profilePerformanceOpeningWin => 'Wygrane otwarcia';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Spośród rund z twoim pierwszym zabójstwem lub pierwszym zgonem: odsetek pierwszych zabójstw.';

  @override
  String get profilePerformanceFirstBloodsPerGame =>
      'Pierwsze zabójstwa na mecz';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Pierwsze zgony na mecz';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'Wiele zabójstw w jednej rundzie';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 zabójstwa',
      'k4': '4 zabójstwa',
      'ace': 'Ace',
      'other': '2 zabójstwa',
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
      other: 'Na podstawie $nString meczu z pełnymi danymi o zabójstwach.',
      many: 'Na podstawie $nString meczów z pełnymi danymi o zabójstwach.',
      few: 'Na podstawie $nString meczów z pełnymi danymi o zabójstwach.',
      one: 'Na podstawie $nString meczu z pełnymi danymi o zabójstwach.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Wygrane rundy';

  @override
  String get profilePerformanceDrillHint =>
      'Dotknij wiersza, aby zobaczyć tylko tego agenta, tę mapę lub ten tryb.';

  @override
  String get profilePerformanceLoadOlder => 'Analizuj starsze mecze';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub analizuje tylko mecze otwarte na tym urządzeniu. Każde dotknięcie dodaje starsze mecze (maks. $nString).';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Szukanie starszych meczów…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analizowanie meczów: $doneString/$totalString…';
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
      other: 'Dodano $nString meczu do analizy.',
      many: 'Dodano $nString meczów do analizy.',
      few: 'Dodano $nString mecze do analizy.',
      one: 'Dodano $nString mecz do analizy.',
      zero: 'Brak nowych meczów do dodania.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot nie przechowuje już starszych meczów.';

  @override
  String get profileEconomyTitle => 'Ekonomia twojej drużyny';

  @override
  String get profileEconomyHint =>
      'Typ zakupu według łącznej wartości wyposażenia drużyny na początku rundy (konwencja vlr.gg dla 5 graczy): Eco poniżej 5000, Semi-eco poniżej 10 000, Semi-buy poniżej 20 000, Full buy od 20 000 kredytów. Pierwsza runda każdej połowy to Pistol.';

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

    return 'Wygrane $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => 'Ostatnia sesja';

  @override
  String profileSessionDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString godz. $minutesString min';
  }

  @override
  String profileSessionTopAgent(String agent, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Najczęściej: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      'Twój towarzysz w VALORANT: dzienny sklep, lista życzeń, ranga, mecze, wiele kont i społeczność graczy — na twoim urządzeniu.';

  @override
  String get legalBackToTop => 'Wróć na górę';

  @override
  String get legalConsentAnd => ' i ';

  @override
  String get legalConsentPrefix => 'Kontynuując, akceptujesz ';

  @override
  String get legalConsentPrivacy => 'Politykę prywatności';

  @override
  String get legalConsentSuffix => ' aplikacji ValHub.';

  @override
  String get legalConsentTerms => 'Warunki korzystania';

  @override
  String get legalContact => 'Kontakt';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'KONTAKT';

  @override
  String legalEffectiveFrom(String date) {
    return 'Obowiązuje od $date';
  }

  @override
  String get legalLegalHeader => 'KWESTIE PRAWNE';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Wszelkie prawa zastrzeżone.';

  @override
  String get legalThirdPartyLicenses => 'Oprogramowanie firm trzecich';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licencje oprogramowania open source używanego przez ValHub';

  @override
  String get legalTocTitle => 'SPIS TREŚCI';

  @override
  String legalVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Ten dokument jest obecnie wyświetlany w języku: $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Nie udało się odczytać dokumentu prawnego. Spróbuj ponownie lub skontaktuj się z pomocą.';

  @override
  String get legalTranslationNotice =>
      'To tłumaczenie służy wyłącznie wygodzie. W razie rozbieżności obowiązuje wersja wietnamska.';

  @override
  String get settingsUiLanguageTitle => 'Język aplikacji';

  @override
  String get settingsLanguageFollowDevice => 'Język urządzenia';

  @override
  String get settingsLanguageSaveFailed =>
      'Nie udało się zapisać języka. Spróbuj ponownie.';

  @override
  String get settingsGeoCountry => 'Kraj';

  @override
  String get settingsGeoSearchCountry => 'Szukaj nazwy lub kodu kraju';

  @override
  String get settingsGeoSupportedOnly => 'Tylko potwierdzone';

  @override
  String get settingsGeoUnknown => 'Obsługa niepotwierdzona';

  @override
  String get settingsGeoRestricted => 'Ograniczony';

  @override
  String get settingsGeoSeparate => 'Osobna usługa';

  @override
  String get settingsGeoAvailable => 'Obsługiwany';

  @override
  String get settingsGeoNotApplicable => 'Nie dotyczy';

  @override
  String get settingsGeoConnection => 'Połączenie z Riot';

  @override
  String get settingsGeoChooseRegion => 'Wybierz region';

  @override
  String get settingsGeoAuto => 'Automatycznie z konta';

  @override
  String get settingsGeoManual => 'Wybierz ręcznie';

  @override
  String get settingsGeoNoRegion => 'Nie udało się ustalić regionu Riot';

  @override
  String get settingsGeoManualWarning =>
      'Ta opcja zmienia tylko serwer, z którym łączy się ValHub. Nie przenosi regionu twojego konta Riot. ValHub sprawdzi połączenie przed zapisaniem.';

  @override
  String get settingsGeoConnectionSaved => 'Zapisano połączenie';

  @override
  String get settingsGeoValidationFailed =>
      'Nie udało się potwierdzić konta na tym serwerze. Wybierz region ponownie.';

  @override
  String get settingsGeoHintOnly =>
      'Kraj służy tylko do wyszukiwania i podpowiedzi. Region połączenia wynika z konta Riot.';

  @override
  String get settingsGeoSave => 'Sprawdź i zapisz';

  @override
  String get settingsGeoCancel => 'Anuluj';

  @override
  String get settingsGeoLoading => 'Sprawdzanie połączenia…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Ten wybór dotyczy nazw krajów, podpowiedzi i szacunkowych cen VP. Serwer połączenia i kraj konta w Społeczności nadal ustala Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'Użyj kraju konta lub urządzenia';

  @override
  String get settingsGeoSaveFailed =>
      'Nie udało się zapisać wyboru. Spróbuj ponownie.';

  @override
  String get settingsGeoAllRegions => 'Wszystkie regiony';

  @override
  String get settingsGeoSuggestions => 'Podpowiedzi';

  @override
  String get settingsGeoNoCountries => 'Brak krajów pasujących do filtra.';

  @override
  String get settingsGeoActiveCountries => 'Aktywne';

  @override
  String get settingsGeoAllCountries => 'Wszystkie kraje';

  @override
  String get settingsGeoActivityUnavailable =>
      'Nie udało się wczytać aktywności krajów. Nadal możesz wybrać z listy Wszystkie kraje.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kraju',
      many: '$count krajów',
      few: '$count kraje',
      one: '$count kraj',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Wybrano: $manual, ale Riot przypisuje twoje konto do: $detected. Kontynuować sprawdzanie tego połączenia?';
  }

  @override
  String get settingsGeoUnverified =>
      'Nie udało się sprawdzić połączenia, bo serwer lub sieć mają problemy. Zapisać ten wybór i spróbować później?';

  @override
  String get settingsGeoContinue => 'Kontynuuj';

  @override
  String settingsGeoMismatch(String region) {
    return 'Wybrano inny serwer niż serwer twojego konta ($region). Użyć serwera konta?';
  }

  @override
  String get settingsGeoUseAuto => 'Użyj automatycznego';

  @override
  String get settingsGeoKeepManual => 'Zostaw ręczne';

  @override
  String get settingsGeoReviewConnection => 'Zobacz połączenie';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Ostatnio sprawdzono: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Sprawdź ponownie';

  @override
  String get settingsPlatformMobile => 'Urządzenie mobilne';

  @override
  String get settingsPlatformOther => 'Inna platforma';

  @override
  String get settingsContentLanguageFollowApp => 'Jak język aplikacji';

  @override
  String get settingsContentLanguageHint =>
      'Wybierz język nazw przedmiotów. Nie zmienia to języka aplikacji ani serwera Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Język: $language.';
  }

  @override
  String get settingsAboutRowSubtitle =>
      'Prywatność, warunki, prawa autorskie i kontakt';

  @override
  String get settingsAboutTitle => 'Informacje i kwestie prawne';

  @override
  String get settingsAppearanceHeader => 'WYGLĄD';

  @override
  String settingsBuildNumber(String build) {
    return 'Kompilacja $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Wyczyszczono $size';
  }

  @override
  String get settingsClearCache => 'Wyczyść dane tymczasowe';

  @override
  String get settingsClearCacheFailed =>
      'Nie udało się wyczyścić danych tymczasowych. Spróbuj ponownie.';

  @override
  String get settingsClearCacheSubtitle =>
      'Obrazy i dane pobrane na urządzenie, łącznie z zapisanymi raportami błędów';

  @override
  String get settingsExportLog => 'Wyślij raport błędu do ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Na razie nie ma nic do wysłania. Poużywaj aplikacji przez chwilę i spróbuj ponownie.';

  @override
  String get settingsExportLogSubtitle =>
      'Raporty błędów nie zawierają hasła ani danych logowania Riot.';

  @override
  String get settingsFeedback => 'Prześlij opinię o ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Otwórz stronę opinii ValHub';

  @override
  String get settingsItemLanguageEn => 'Angielski';

  @override
  String get settingsItemLanguageLabel => 'Nazwy przedmiotów';

  @override
  String get settingsItemLanguagePickerTitle => 'Język nazw przedmiotów';

  @override
  String get settingsItemLanguageVi => 'Wietnamski';

  @override
  String get settingsLinkOpenFailed =>
      'Nie udało się otworzyć linku. Spróbuj ponownie.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Raport błędu';
  }

  @override
  String get settingsLogShareFailed =>
      'Nie udało się wysłać raportu błędu. Spróbuj ponownie.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Gdy otworzy się Nocny Targ';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Przypomina o odkryciu ofert Nocnego Targu';

  @override
  String get settingsNotifPermissionMissing =>
      'Aplikacja nie ma uprawnień do wysyłania powiadomień.';

  @override
  String get settingsNotifStoreReset => 'Gdy sklep się odświeży';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Codziennie o $time';
  }

  @override
  String get settingsNotifWishlist => 'Gdy skin z listy życzeń się pojawi';

  @override
  String get settingsNotificationsHeader => 'POWIADOMIENIA';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Automatycznie otwieraj szczegóły meczu';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Otwiera panel obecnego meczu, gdy tylko mecz zostanie znaleziony';

  @override
  String get settingsOptionOwnPrice => 'Cena twojego pakietu VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Nie ustawiono — używa cennika regionu, jeśli jest dostępny';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Platforma';

  @override
  String get settingsOptionShowLiveScore => 'Pokazuj wynik na żywo';

  @override
  String get settingsOptionShowPeakRank =>
      'Pokazuj najwyższą rangę w szczegółach meczu';

  @override
  String get settingsOptionShowPrice => 'Pokazuj szacunkowe ceny';

  @override
  String get settingsOptionShowPriceInfo => 'Jak liczymy szacunkowe ceny';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Obok cen w VP, np. $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Brak jeszcze sprawdzonego cennika dla twojego regionu — wpisz cenę swojego pakietu VP.';

  @override
  String get settingsOptionsHeader => 'OPCJE';

  @override
  String get settingsPhaseComplete => 'Zakończono';

  @override
  String get settingsPhaseInProgress => 'W toku';

  @override
  String get settingsPhaseScheduled => 'Zaplanowano';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Dotyczy: $account';
  }

  @override
  String get settingsPlatformHint =>
      'Wybierz PC, PlayStation lub Xbox zależnie od tego, gdzie grasz, aby widzieć właściwą historię meczów.';

  @override
  String get settingsPlatformPickerTitle => 'Wybierz platformę';

  @override
  String get settingsPrimingBody =>
      'Włącz powiadomienia, aby wiedzieć, kiedy sklep się odświeża i kiedy pojawia się skin z listy życzeń.';

  @override
  String get settingsPrimingEnable => 'Włącz powiadomienia';

  @override
  String get settingsPrimingFootnote =>
      'W każdej chwili możesz włączyć lub wyłączyć każdy typ powiadomień w Ustawieniach.';

  @override
  String get settingsPrimingLater => 'Później';

  @override
  String get settingsPrimingPointNightMarket =>
      'Dowiedz się, gdy otworzy się Nocny Targ';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Aby zdążyć odkryć oferty przed ich wygaśnięciem';

  @override
  String get settingsPrimingPointStore =>
      'Przypomnienia o odświeżeniu dziennego sklepu';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Przypomina po odświeżeniu sklepu na twoim koncie';

  @override
  String get settingsPrimingPointWishlist =>
      'Powiadomienia, gdy pojawi się upolowany skin';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Sprawdza sklep na każdym koncie, nawet gdy aplikacja jest zamknięta';

  @override
  String get settingsPrimingTitle => 'Nie przegap wymarzonego skina';

  @override
  String settingsRemovedAccount(String account) {
    return 'Usunięto $account';
  }

  @override
  String get settingsServerStatus => 'Stan serwerów';

  @override
  String get settingsServerStatusMaintenance => 'Trwa konserwacja';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n komunikatu',
      many: '$n komunikatów',
      few: '$n komunikaty',
      one: '$n komunikat',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Konserwacje i awarie VALORANT według serwera';

  @override
  String get settingsSessionLogTitle => 'Raport błędu ValHub';

  @override
  String get settingsSeverityCritical => 'Krytyczny';

  @override
  String get settingsSeverityInfo => 'Informacja';

  @override
  String get settingsSeverityWarning => 'Ostrzeżenie';

  @override
  String get settingsSignedOutAll => 'Wylogowano ze wszystkich kont';

  @override
  String get settingsStatusAllGood => 'Serwery działają normalnie';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Brak awarii i konserwacji na serwerze: $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Pokaż mniej';

  @override
  String get settingsStatusIssues => 'Riot pracuje nad problemem';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'Komunikaty o awariach na tym serwerze: $n.';
  }

  @override
  String get settingsStatusKindIncident => 'Awaria';

  @override
  String get settingsStatusKindMaintenance => 'Konserwacja';

  @override
  String get settingsStatusMaintenanceNow => 'Serwer w trakcie konserwacji';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Możesz nie móc teraz zagrać, a ValHub może chwilowo nie wczytywać informacji.';

  @override
  String settingsStatusMoreUpdates(int n) {
    return 'Pokaż więcej aktualizacji ($n)';
  }

  @override
  String get settingsStatusScheduled => 'Nadchodzi konserwacja';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Konserwacje zapowiedziane przez Riot: $n.';
  }

  @override
  String get settingsStatusSourceNote =>
      'Źródło: oficjalna strona stanu usług Riot Games. Godziny są podane w strefie czasowej urządzenia.';

  @override
  String settingsStatusStarted(String when) {
    return 'Początek: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Aktualizacja: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'AKTUALIZACJE OD RIOT';

  @override
  String get settingsSupportHeader => 'POMOC';

  @override
  String settingsSwitchedTo(String account) {
    return 'Przełączono na $account';
  }

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsThemeLabel => 'Motyw';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemePickerTitle => 'Wybierz motyw';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Ranga, historia meczów, mecze na żywo';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR z każdego meczu, rangi przeciwników';

  @override
  String get settingsWelcomeBulletStore =>
      'Dzienny sklep, Nocny Targ i pakiety';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Ceny, rzadkość, odliczanie do odświeżenia';

  @override
  String get settingsWelcomeBulletWishlist => 'Lista życzeń i powiadomienia';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Powiadomienie, gdy upolowany skin trafi do twojego sklepu';

  @override
  String get settingsWelcomeFootnote =>
      'Logujesz się na oficjalnej stronie Riot. ValHub zapisuje hasło tylko wtedy, gdy sam zdecydujesz się zapisać dane logowania.';

  @override
  String get settingsWelcomeKicker => 'TOWARZYSZ W VALORANT';

  @override
  String get settingsCountryPriceHeader => 'Kraj i ceny';

  @override
  String get settingsDataHeader => 'Dane na urządzeniu';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (Oceny: $count) · ',
      'other': '',
    });
    return 'Społeczność: ${_temp0}Polubienia: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Dodaj do listy życzeń';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'W sklepie kont: $accounts';
  }

  @override
  String get skinDetailHistoryDelete => 'Usuń historię sklepu';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Usunąć wszystkie zapisane dni sklepu tego konta na tym urządzeniu?';

  @override
  String get skinDetailInWishlist => 'Na liście życzeń';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Zablokowany';

  @override
  String get skinDetailMute => 'Wycisz';

  @override
  String get skinDetailNotFound => 'Nie znaleziono tego skina.';

  @override
  String get skinDetailOwned => 'Posiadany';

  @override
  String get skinDetailPause => 'Pauza';

  @override
  String get skinDetailPlay => 'Odtwórz';

  @override
  String get skinDetailPlayVideo => 'Obejrzyj film';

  @override
  String get skinDetailRemoveFromWishlist => 'Usuń z listy życzeń';

  @override
  String get skinDetailTitle => 'Szczegóły skina';

  @override
  String get skinDetailUnmute => 'Włącz dźwięk';

  @override
  String get skinDetailUpgrades => 'Ulepszenia';

  @override
  String get skinDetailVariants => 'Warianty';

  @override
  String get skinDetailVideoError =>
      'Nie udało się odtworzyć filmu. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String skinDetailSeenDaily(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'W twoim sklepie $nString razy',
      many: 'W twoim sklepie $nString razy',
      few: 'W twoim sklepie $nString razy',
      one: 'W twoim sklepie $nString raz',
    );
    return '$_temp0';
  }

  @override
  String skinDetailSeenNight(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Nocny Targ $nString razy',
      many: 'Nocny Targ $nString razy',
      few: 'Nocny Targ $nString razy',
      one: 'Nocny Targ $nString raz',
    );
    return '$_temp0';
  }

  @override
  String get socialPresenceInMatch => 'W meczu';

  @override
  String get socialPresenceAgentSelect => 'Wybór agenta';

  @override
  String get socialPresenceQueue => 'W kolejce';

  @override
  String get socialPresenceLobby => 'W poczekalni';

  @override
  String get socialPresenceCustom => 'W grze niestandardowej';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Otwarta drużyna',
      'other': 'Tylko na zaproszenie',
    });
    return 'Gracze: $size/$max · $_temp0';
  }

  @override
  String get socialAccept => 'Akceptuj';

  @override
  String get socialAcceptInGame => 'Zaakceptuj to zaproszenie w grze.';

  @override
  String socialActionFailed(String message) {
    return 'Nie udało się tego wykonać. $message';
  }

  @override
  String get socialAutoRefresh => 'Automatyczne odświeżanie';

  @override
  String get socialAway => 'Zaraz wracam';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Anuluj kolejkę · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Anuluj kolejkę';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Drużyna nie może dołączyć do kolejki ($queue): $reason';
  }

  @override
  String get socialChangeQueue => 'Zmień kolejkę';

  @override
  String get socialChatUnavailable => 'Czat jest offline.';

  @override
  String get socialCloseParty => 'Zamknij drużynę';

  @override
  String get socialCodeInvalid =>
      'Kod drużyny może zawierać tylko litery i cyfry.';

  @override
  String get socialConnecting => 'Łączenie z czatem…';

  @override
  String get socialCopyCode => 'Kopiuj';

  @override
  String get socialCurrentQueue => 'Wybrana';

  @override
  String get socialCustomGameLobby =>
      'Twoja drużyna jest w poczekalni gry niestandardowej.';

  @override
  String get socialDecline => 'Odrzuć';

  @override
  String get socialDisableCode => 'Wyłącz kod';

  @override
  String get socialEmptyChat => 'Brak wiadomości. Przywitaj się!';

  @override
  String get socialEmptyChatTitle => 'Zacznij rozmowę';

  @override
  String get socialFailedBadge => 'Nie wysłano';

  @override
  String get socialFilterAll => 'Wszyscy';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Nieprzeczytane';

  @override
  String get socialFriendsPrivacyNote =>
      'Lista znajomych i wiadomości pochodzą bezpośrednio z Riot. ValHub nie przechowuje ich nigdzie indziej.';

  @override
  String socialFriendsSummary(int total, int online) {
    return 'Znajomi: $total · Online: $online';
  }

  @override
  String get socialFriendsTitle => 'Znajomi i czat';

  @override
  String get socialGameNotRunningBody =>
      'Drużyna i kolejka działają tylko wtedy, gdy VALORANT jest uruchomiony na twoim komputerze lub konsoli. Uruchom grę i przeciągnij w dół, aby odświeżyć.';

  @override
  String get socialGameNotRunningTitle =>
      'Uruchom VALORANT na komputerze lub konsoli';

  @override
  String get socialGenerateCode => 'Utwórz kod';

  @override
  String get socialIdleQueue => 'Gotowi do kolejki';

  @override
  String get socialInMatchBanner =>
      'Jesteś w meczu. Kolejka będzie znów dostępna po jego zakończeniu.';

  @override
  String get socialInValorant => 'W VALORANT';

  @override
  String get socialInviteByRiotId => 'Zaproś przez Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Zaproś graczy, którzy nie są jeszcze twoimi znajomymi';

  @override
  String get socialInviteFriends => 'Zaproś znajomych';

  @override
  String socialInviteFrom(String name) {
    return 'Zaproszenie od: $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Zaproś: $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Riot ID tego gracza jest nieznany, więc nie można go jeszcze zaprosić.';

  @override
  String socialInviteSent(String name) {
    return 'Wysłano zaproszenie: $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Zaproszono';
  }

  @override
  String get socialInvitesSection => 'Zaproszenia';

  @override
  String get socialJoin => 'Dołącz';

  @override
  String get socialJoinConfirmBody =>
      'Opuścisz obecną drużynę, aby dołączyć do drużyny z tym kodem.';

  @override
  String get socialJoinConfirmTitle => 'Dołączyć do innej drużyny?';

  @override
  String get socialJoinSection => 'Dołącz do innej drużyny';

  @override
  String get socialJoinWithCode => 'Wpisz kod, aby dołączyć';

  @override
  String get socialJoined => 'Dołączono do drużyny.';

  @override
  String socialLastOnline(String relative) {
    return 'Aktywność: $relative';
  }

  @override
  String get socialLeader => 'Lider';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Opuścisz obecną drużynę i wrócisz do gry solo.';

  @override
  String get socialLeaveConfirmTitle => 'Opuścić drużynę?';

  @override
  String get socialLeaveParty => 'Opuść drużynę';

  @override
  String socialLevel(int n) {
    return 'Poziom $n';
  }

  @override
  String get socialMatchFound => 'Znaleziono mecz!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Członkowie ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Napisz wiadomość…';

  @override
  String get socialMoreActions => 'Więcej opcji';

  @override
  String get socialNoCode =>
      'Utwórz kod, aby znajomi mogli szybko dołączyć do twojej drużyny.';

  @override
  String get socialNoCodeMember =>
      'Lider drużyny może utworzyć kod do szybkiego zapraszania.';

  @override
  String get socialNoFilterResults =>
      'Żaden znajomy nie pasuje do tego filtra.';

  @override
  String get socialNoFriends =>
      'Twoja lista znajomych Riot jest pusta. Dodaj znajomych w grze.';

  @override
  String get socialNoFriendsTitle => 'Brak znajomych';

  @override
  String get socialNoOnlineFriends =>
      'Żaden z twoich znajomych nie jest teraz online w VALORANT.';

  @override
  String get socialNoSearchResults => 'Brak pasujących znajomych.';

  @override
  String get socialNoSearchResultsTitle => 'Nic nie znaleziono';

  @override
  String get socialNotReady => 'Niegotowy';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online na telefonie';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Tylko lider drużyny może zmienić kolejkę i rozpocząć szukanie meczu.';

  @override
  String get socialOpenParty => 'Otwórz drużynę';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Kod drużyny';

  @override
  String socialPartyCodeValue(String code) {
    return 'Kod drużyny: $code';
  }

  @override
  String get socialPartyInvite => 'Zaproszenie do drużyny';

  @override
  String socialPartyOf(int size, int max) {
    return 'Drużyna $size/$max';
  }

  @override
  String get socialPartyTitle => 'Drużyna i kolejka';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'Graczy w drużynie: $size';
  }

  @override
  String get socialPickQueueTitle => 'Wybierz kolejkę';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Najlepszy ping do serwerów meczowych';

  @override
  String socialPlayingOther(String game) {
    return 'Gra w: $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'W grze ($n)';
  }

  @override
  String get socialQueueLabel => 'Kolejka';

  @override
  String get socialQueueLocked => 'Nie można zmienić kolejki podczas meczu.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Maksymalnie $max gracza',
      many: 'Maksymalnie $max graczy',
      few: 'Maksymalnie $max graczy',
      one: 'Maksymalnie $max gracz',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Nie udało się potwierdzić stanu gry. Odśwież, aby korzystać z gotowości i kolejki.';

  @override
  String get socialReady => 'Gotowy';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Gotowi $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'członek drużyny ma za niski poziom konta';

  @override
  String get socialReasonGeneric => 'drużyna nie spełnia jeszcze warunków';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'drużyna jest za duża (maks. $max)';
  }

  @override
  String get socialReasonRankDisparity =>
      'różnica rang jest za duża na grę rankingową';

  @override
  String socialReasonRestricted(String time) {
    return 'drużyna ma blokadę kolejki (zostało: $time)';
  }

  @override
  String get socialReconnecting => 'Rozłączono z czatem. Ponowne łączenie…';

  @override
  String get socialRemoteNote =>
      'Zmiany trafiają do Riot tylko po twoim dotknięciu. ValHub nigdy nie dołącza do kolejki ani nie blokuje agenta za ciebie.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name zostanie usunięty z twojej drużyny.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Usunąć z drużyny?';

  @override
  String get socialRemoveMember => 'Usuń z drużyny';

  @override
  String socialRequestFrom(String name) {
    return '$name chce dołączyć do drużyny';
  }

  @override
  String get socialRequestsSection => 'Prośby o dołączenie';

  @override
  String get socialRiotIdFieldHint => 'Nazwa#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID to nazwa (3–16 znaków), znak # i tag (3–5 liter lub cyfr).';

  @override
  String get socialSearchHint => 'Szukaj po Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'W kolejce · $elapsed';
  }

  @override
  String get socialSend => 'Wyślij';

  @override
  String get socialSendFailed =>
      'Nie udało się wysłać wiadomości. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get socialSendInvite => 'Wyślij zaproszenie';

  @override
  String get socialShareCode => 'Udostępnij';

  @override
  String socialShareCodeText(String code) {
    return 'Dołącz do mojej drużyny w VALORANT kodem: $code';
  }

  @override
  String get socialShootingRange => 'Na strzelnicy';

  @override
  String get socialShowEveryone => 'Pokaż wszystkich';

  @override
  String get socialStartQueue => 'Dołącz do kolejki';

  @override
  String get socialSuggestionsItem0 => 'Siema!';

  @override
  String get socialSuggestionsItem1 => 'Gramy parę meczów?';

  @override
  String get socialSuggestionsItem2 => 'Wbijaj do mojej drużyny!';

  @override
  String socialUnread(int n) {
    return 'Nieprzeczytane: $n';
  }

  @override
  String get socialUnready => 'Niegotowy';

  @override
  String get socialViewProfile => 'Zobacz profil';

  @override
  String get socialWaitingForConnection =>
      'Łączenie… Wiadomości wyślesz po nawiązaniu połączenia.';

  @override
  String get socialYou => 'Ty';

  @override
  String get socialPartyUnavailable =>
      'Nie udało się zsynchronizować drużyny. Odśwież, aby spróbować ponownie.';

  @override
  String get socialAcceptConfirmBody =>
      'Opuścisz obecną drużynę, aby dołączyć do drużyny, która wysłała ci zaproszenie.';

  @override
  String get storeAccessoryEmpty => 'Sklep z akcesoriami jest teraz pusty.';

  @override
  String get storeAccessoryEmptyTitle => 'Brak akcesoriów';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Z: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Odświeżenie za $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Odświeżenie: $wall';
  }

  @override
  String get storeAddToWishlist => 'Dodaj do listy życzeń';

  @override
  String get storeBackToBundles => 'Zobacz dostępne pakiety';

  @override
  String get storeBundleBuySeparateLabel => 'Kup osobno';

  @override
  String get storeBundleDetailTitle => 'Szczegóły pakietu';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Koniec: $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Zostało: $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n przedmiotu',
      many: '$n przedmiotów',
      few: '$n przedmioty',
      one: '$n przedmiot',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Za darmo';

  @override
  String get storeBundleItemsTitle => 'Przedmioty w pakiecie';

  @override
  String get storeBundleNotFound =>
      'Nie znaleziono tego pakietu. Możliwe, że już wygasł.';

  @override
  String get storeBundleNotFoundTitle => 'Pakiet wygasł';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Posiadane przedmioty: $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Cena pakietu';

  @override
  String get storeBundleSavingsLabel => 'Oszczędzasz';

  @override
  String get storeBundleWholesaleOnly =>
      'Sprzedawany tylko w całości, nie osobno.';

  @override
  String get storeBundlesEmpty => 'Obecnie nie ma pakietów w sprzedaży.';

  @override
  String get storeBundlesEmptyTitle => 'Brak pakietów';

  @override
  String get storeDailyEmpty => 'Dziś w sklepie nie ma żadnych skinów.';

  @override
  String get storeDailyEmptyTitle => 'Sklep jest pusty';

  @override
  String storeDailyResetAt(String time) {
    return 'Odświeża się codziennie o $time';
  }

  @override
  String get storeDailyTotalLabel => 'Łącznie';

  @override
  String get storeNightMarketEmpty => 'Obecnie nie ma Nocnego Targu.';

  @override
  String get storeNightMarketEmptyTitle => 'Nocny Targ jest zamknięty';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Koniec: $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Kończy się za $t';
  }

  @override
  String get storeNightMarketNote =>
      'Oferty Nocnego Targu są unikalne dla twojego konta i nie można ich odświeżyć.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Łączna oszczędność: $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Nieodkryta';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Posiadany';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Posiadane: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Usuń z listy życzeń';

  @override
  String get storeResetNotificationTitle => 'Twój sklep się odświeżył';

  @override
  String storeResetsIn(String t) {
    return 'Odświeżenie za $t';
  }

  @override
  String get storeSegmentAccessories => 'Akcesoria';

  @override
  String get storeSegmentBundles => 'Pakiety';

  @override
  String get storeSegmentDaily => 'Dzienna';

  @override
  String get storeSegmentNightMarket => 'Nocny Targ';

  @override
  String get storeShareButton => 'Udostępnij';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Dzisiejszy sklep';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Nocny Targ';

  @override
  String get storeShareCardPriceNote =>
      'Przeliczone ceny to tylko szacunek według pakietów VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Oszczędność: $vp';
  }

  @override
  String get storeShareCardTagline => 'Twój towarzysz w VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Łącznie $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Do $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Udostępnij dzisiejszy sklep';

  @override
  String get storeShareFailed =>
      'Nie udało się utworzyć obrazu. Spróbuj ponownie.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Udostępnij obraz';

  @override
  String get storeShareNightMarketTitle => 'Udostępnij Nocny Targ';

  @override
  String get storeSharePreparing => 'Wczytywanie obrazów skinów…';

  @override
  String get storeShareShowPrice => 'Pokaż szacunkowe ceny';

  @override
  String get storeShareShowPriceHint =>
      'Przeliczone według najkorzystniejszego pakietu VP.';

  @override
  String get storeShareShowRiotId => 'Pokaż Riot ID na obrazie';

  @override
  String get storeShareShowRiotIdHint =>
      'Domyślnie wyłączone dla twojej prywatności.';

  @override
  String get storeShareSubjectDaily => 'Mój dzisiejszy sklep w VALORANT';

  @override
  String get storeShareSubjectNightMarket => 'Mój Nocny Targ w VALORANT';

  @override
  String get storeShareSubtitle =>
      'Udostępnij znajomym obraz swojego sklepu przez dowolną aplikację.';

  @override
  String get storeTitle => 'Sklep';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Saldo: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'Na liście życzeń: $n';
  }

  @override
  String get storeHistoryTitle => 'Historia sklepu';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString dnia',
      many: '$daysString dni',
      few: '$daysString dni',
      one: '$daysString dzień',
    );
    return 'Zapisywane na tym urządzeniu od $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Nie zapisano jeszcze żadnego dnia. ValHub zapisuje twój dzienny sklep przy każdym otwarciu aplikacji, tylko na tym urządzeniu.';

  @override
  String get storeHistoryMostOffered => 'Najczęściej w ofercie';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString raza',
      many: '$nString razy',
      few: '$nString razy',
      one: '$nString raz',
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
      other: 'Nocny Targ · $countString oferty',
      many: 'Nocny Targ · $countString ofert',
      few: 'Nocny Targ · $countString oferty',
      one: 'Nocny Targ · $countString oferta',
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
      other: 'Zapisano na tym urządzeniu: $daysString dnia',
      many: 'Zapisano na tym urządzeniu: $daysString dni',
      few: 'Zapisano na tym urządzeniu: $daysString dni',
      one: 'Zapisano na tym urządzeniu: $daysString dzień',
      zero: 'Zapis rozpoczęty dzisiaj',
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
      'yes': '$skin jest teraz w sklepie ($account) — zostało: $left.',
      'other': '$skin jest teraz w sklepie ($account).',
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
      'discount': '$skin: −$percent%, teraz $price ($account).',
      'price': '$skin tylko za $price ($account).',
      'other': '$skin jest na Nocnym Targu ($account).',
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
      'yes': '$skin jest w pakiecie $bundle ($account).',
      'other': '$skin jest w pakiecie dostępnym w sprzedaży ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'Teraz w sklepie ($account): $names i $more innego skina.',
      many: 'Teraz w sklepie ($account): $names i $more innych skinów.',
      few: 'Teraz w sklepie ($account): $names i $more inne skiny.',
      one: 'Teraz w sklepie ($account): $names i $more inny skin.',
      zero: 'Teraz w sklepie ($account): $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', na liście życzeń',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Dodaj skiny';

  @override
  String get wishlistAddToWishlist => 'Dodaj do listy życzeń';

  @override
  String get wishlistAllWeapons => 'Wszystkie bronie';

  @override
  String get wishlistBrowseCatalog => 'Zobacz wszystkie skiny';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skina',
      many: '$countString skinów',
      few: '$countString skiny',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Nie udało się wczytać listy skinów. Odśwież, aby spróbować ponownie.';

  @override
  String get wishlistCatalogEmptyTitle => 'Brak skinów';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'Na liście życzeń: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Dotknij ♡, aby dodać skin do listy życzeń';

  @override
  String get wishlistCatalogTitle => 'Wszystkie skiny';

  @override
  String get wishlistChooseWeapon => 'Wybierz broń';

  @override
  String get wishlistClearFilters => 'Wyczyść filtry';

  @override
  String get wishlistEmpty =>
      'Twoja lista życzeń jest pusta. Dotknij ♡ przy dowolnym skinie, aby go dodać.';

  @override
  String get wishlistEmptyTitle => 'Brak skinów';

  @override
  String wishlistEndsIn(String time) {
    return 'Kończy się za $time';
  }

  @override
  String get wishlistExcludedRewards => 'Bez skinów z nagród';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skina',
      many: '$countString skinów',
      few: '$countString skiny',
      one: '$countString skin',
    );
    return 'Filtrowane: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Brak pasujących skinów. Wyczyść filtry, aby zobaczyć więcej.';

  @override
  String get wishlistNoMatchTitle => 'Nie znaleziono skinów';

  @override
  String get wishlistNotifBundleTitle => 'Nowy pakiet ze skinem z listy życzeń';

  @override
  String get wishlistNotifDailyTitle => 'Skin z listy życzeń jest w sklepie!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Na Nocnym Targu jest skin, którego chcesz!';

  @override
  String get wishlistNotifPermissionMissing =>
      'Aplikacja nie ma uprawnień do wysyłania powiadomień.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skina z listy życzeń jest w sprzedaży!',
      many: '$count skinów z listy życzeń jest w sprzedaży!',
      few: '$count skiny z listy życzeń są w sprzedaży!',
      one: '$count skin z listy życzeń jest w sprzedaży!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Powiadomienia z listy życzeń';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Dla tego konta, nawet gdy aplikacja jest zamknięta';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Lista życzeń: $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skina z listy życzeń jest w sprzedaży!',
      many: '$count skinów z listy życzeń jest w sprzedaży!',
      few: '$count skiny z listy życzeń są w sprzedaży!',
      one: '$count skin z listy życzeń jest w sprzedaży!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Dotknij wyróżnionego wiersza, aby zobaczyć ofertę.';

  @override
  String get wishlistOpenSettings => 'Otwórz ustawienia';

  @override
  String get wishlistOwned => 'Posiadany';

  @override
  String get wishlistRemoveAction => 'Usuń z listy życzeń';

  @override
  String get wishlistRemoveFromWishlist => 'Usuń z listy życzeń';

  @override
  String wishlistRemoved(String name) {
    return 'Usunięto $name z listy życzeń';
  }

  @override
  String get wishlistSearchHint => 'Szukaj skinów…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skina',
      many: '$countString skinów',
      few: '$countString skiny',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'Nazwa';

  @override
  String get wishlistSortPrice => 'Cena';

  @override
  String get wishlistSortRarity => 'Rzadkość';

  @override
  String get wishlistSortWeapon => 'Broń';

  @override
  String get wishlistTitle => 'Lista życzeń';

  @override
  String get wishlistTotalValue => 'Łączna wartość listy życzeń';

  @override
  String get wishlistUndo => 'Cofnij';

  @override
  String get wishlistViewInStore => 'Zobacz w sklepie';

  @override
  String get wishlistWeapon => 'Broń';

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
      'yes': ', na liście życzeń',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', na liście życzeń',
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
      'gain': 'w górę',
      'other': 'w dół',
    });
    return 'Dzisiaj $_temp0 o $rr RR, wygrane: $wins, porażki: $losses';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wygranej',
      many: '$wins wygranych',
      few: '$wins wygrane',
      one: '$wins wygrana',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses porażki',
      many: '$losses porażek',
      few: '$losses porażki',
      one: '$losses porażka',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws remisu',
      many: ', $draws remisów',
      few: ', $draws remisy',
      one: ', $draws remis',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown meczu z nieznanym wynikiem',
      many: ', $unknown meczów z nieznanym wynikiem',
      few: ', $unknown mecze z nieznanym wynikiem',
      one: ', $unknown mecz z nieznanym wynikiem',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody => 'Otwórz Dostosuj Start, aby znów je pokazać.';

  @override
  String get homeAllHiddenTitle => 'Ukryto wszystkie karty';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Poziom, potrzebne XP dziennie i misje tygodniowe.';

  @override
  String get homeCardCommunity => 'Społeczność';

  @override
  String get homeCardCommunityDesc =>
      'Drużyna na twoim poziomie i skiny najbardziej lubiane przez społeczność.';

  @override
  String get homeCardFriends => 'Znajomi w grze';

  @override
  String get homeCardFriendsDesc => 'Znajomi, którzy są w meczu lub w kolejce.';

  @override
  String homeCardHidden(String name) {
    return 'Ukryto „$name”';
  }

  @override
  String get homeCardLive => 'Obecny mecz';

  @override
  String get homeCardLiveDesc =>
      'Widoczna, gdy jesteś w kolejce, wyborze agenta lub meczu.';

  @override
  String get homeCardOtherAccounts => 'Inne konta';

  @override
  String get homeCardOtherAccountsDesc =>
      'Status i lista życzeń pozostałych kont.';

  @override
  String get homeCardRank => 'Ranga i forma';

  @override
  String get homeCardRankDesc =>
      'Ranga, dzisiejsze RR, serie i mecze do awansu.';

  @override
  String get homeCardServerStatus => 'Stan serwerów';

  @override
  String get homeCardServerStatusDesc =>
      'Widoczna tylko podczas konserwacji lub awarii.';

  @override
  String get homeCardStore => 'Dzisiejszy sklep';

  @override
  String get homeCardStoreDesc => 'Dzienne skiny, lista życzeń i Nocny Targ.';

  @override
  String get homeCustomize => 'Dostosuj Start';

  @override
  String get homeCustomizeHint =>
      'Przeciągnij, aby zmienić kolejność. Wyłącz, aby ukryć kartę.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Przeniesiono do: $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Włącz';

  @override
  String get homeFriendsConsentBody =>
      'Aby pokazać, którzy znajomi grają, ValHub łączy się z czatem Riot obecnego konta za każdym razem, gdy otwierasz Start. Znajomi zobaczą cię jako online. Możesz to wyłączyć w Dostosuj Start.';

  @override
  String get homeFriendsConsentDecline => 'Nie, ukryj kartę';

  @override
  String get homeFriendsConsentTitle => 'Pokazywać, którzy znajomi grają?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n znajomego gra',
      many: '$n znajomych gra',
      few: '$n znajomych gra',
      one: '$n znajomy gra',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Zobacz wszystko';

  @override
  String get homeHideCard => 'Ukryj tę kartę';

  @override
  String homeLeaderboard(String pos) {
    return 'Miejsce $pos w tabeli liderów';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Zostało: $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Potrzeba $n gracza',
      many: 'Potrzebnych $n graczy',
      few: 'Potrzebnych $n graczy',
      one: 'Potrzebny $n gracz',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Znajdź drużynę na swoim poziomie';

  @override
  String get homeLiveAllyLabel => 'Twoja drużyna';

  @override
  String get homeLiveEnemyLabel => 'Przeciwnicy';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'W kolejce, czas oczekiwania: $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Twoja drużyna $ally, przeciwnicy $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return 'Seria porażek w rankingowych: $n';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n meczu do rangi $rank',
      many: '≈ $n meczów do rangi $rank',
      few: '≈ $n mecze do rangi $rank',
      one: '≈ $n mecz do rangi $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Opcje: $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Zaloguj się ponownie, aby zaktualizować sklep, rangę i Battle Pass konta $riotId. Nadal możesz przeglądać wersję zapisaną na urządzeniu.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Zostało: $time';
  }

  @override
  String get homeNightMarketNew => 'Nowość';

  @override
  String get homeNightMarketTitle => 'Nocny Targ';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n oferty czeka na odkrycie',
      many: '$n ofert czeka na odkrycie',
      few: '$n oferty czekają na odkrycie',
      one: '$n oferta czeka na odkrycie',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Dziś brak meczów rankingowych';

  @override
  String get homeOpenLfg => 'Zobacz wszystkie ogłoszenia';

  @override
  String get homeOpenRanking => 'Zobacz ranking skinów';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Inne konta ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n konta',
      many: '+$n kont',
      few: '+$n konta',
      one: '+$n konto',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Dostępny skin z listy życzeń';

  @override
  String homePreviousAct(String rank) {
    return 'Poprzedni akt: $rank';
  }

  @override
  String get homeQuietBody => 'Przeciągnij w dół, aby odświeżyć.';

  @override
  String get homeQuietTitle => 'Nic nowego';

  @override
  String homeRankToNext(int rr) {
    return 'Brakuje $rr RR do awansu';
  }

  @override
  String get homeResetLayout => 'Przywróć domyślne';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Dzisiaj $value';
  }

  @override
  String get homeStatusDetails => 'Szczegóły';

  @override
  String homeStatusIncident(String region) {
    return 'Awaria serwera · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Trwa konserwacja · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Nadchodzi konserwacja · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n komunikatu',
      many: '+$n komunikatów',
      few: '+$n komunikaty',
      one: '+$n komunikat',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Odświeżanie…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Odświeżenie za $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Łącznie $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Portfel $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skina',
      many: '$n skinów',
      few: '$n skiny',
      one: '$n skin',
    );
    return 'Portfel $vp · wystarczy na maks. $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Skin z listy życzeń w sklepie!';

  @override
  String homeStoreWishlistHits(int n) {
    return 'Skiny z listy życzeń w sprzedaży: $n';
  }

  @override
  String get homeTitle => 'Start';

  @override
  String get homeTrendingTitle => 'Najbardziej lubiane skiny na świecie';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n polubienia',
      many: '$n polubień',
      few: '$n polubienia',
      one: '$n polubienie',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Cofnij';

  @override
  String homeWinStreak(int n) {
    return 'Seria wygranych w rankingowych: $n';
  }

  @override
  String get homeStoreOutdated =>
      'Sklep się zmienił. ValHub nie zdołał jeszcze wczytać nowego.';

  @override
  String get homeOfflineTitle => 'Jesteś offline';

  @override
  String get homeOfflineBody =>
      'Pokazujemy dane zapisane na urządzeniu. ValHub zaktualizuje je, gdy wrócisz do sieci.';

  @override
  String get homeCardOffline => 'Pojawi się, gdy będziesz online.';

  @override
  String get communityErrorConsent =>
      'Aby kontynuować, zgódź się na udostępnienie Riot ID Społeczności.';

  @override
  String get communityErrorForbidden =>
      'Nie możesz jeszcze tego zrobić. Sprawdź Zasady społeczności lub skontaktuj się z ValHub.';

  @override
  String get communityErrorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get communityErrorImageTooLarge =>
      'Obraz jest za duży (maks. 2 MB). Wybierz inny.';

  @override
  String get communityErrorImageType => 'Wybierz obraz JPEG, PNG lub WebP.';

  @override
  String get communityErrorInvalid =>
      'Treść nie została przyjęta. Sprawdź ją i spróbuj ponownie.';

  @override
  String get communityErrorNetwork =>
      'Nie udało się połączyć ze Społecznością ValHub. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get communityErrorNotFound => 'Ta treść już nie istnieje.';

  @override
  String get communityErrorPickImage =>
      'Nie udało się otworzyć galerii zdjęć. Spróbuj ponownie.';

  @override
  String get communityErrorRateLimited =>
      'Społeczność otrzymuje zbyt wiele żądań. Spróbuj ponownie za kilka minut.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Społeczność otrzymuje zbyt wiele żądań. Spróbuj ponownie za $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot nie potwierdził twojego konta. Zaloguj się ponownie na konto Riot i spróbuj jeszcze raz.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot ma problemy. Spróbuj ponownie za kilka minut.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot ma problemy. Spróbuj ponownie za $duration.';
  }

  @override
  String get communityErrorServer =>
      'Społeczność ValHub ma problemy. Spróbuj ponownie za kilka minut.';

  @override
  String get communityErrorStorageFull =>
      'Miejsce na zdjęcia w Społeczności jest pełne. Możesz publikować posty, ale na razie bez zdjęć. Spróbuj ponownie później.';

  @override
  String get communityErrorTimeout =>
      'Społeczność ValHub zbyt długo nie odpowiada. Spróbuj ponownie.';

  @override
  String get communityErrorTitle => 'Nie udało się';

  @override
  String get communityErrorUnauthorized =>
      'Połączenie ze Społecznością wygasło. Spróbuj ponownie.';

  @override
  String get communityErrorImageQuota =>
      'Wykorzystano całe miejsce na obrazy. Usuń kilka postów z obrazami i spróbuj ponownie.';

  @override
  String get smokePlain => 'Test generowania kodu';

  @override
  String smokeGreeting(String name) {
    return 'Cześć, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n elementu',
      many: '$n elementów',
      few: '$n elementy',
      one: '$n element',
    );
    return '$_temp0';
  }
}
