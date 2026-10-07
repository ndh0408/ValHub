// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Preisquelle ansehen';

  @override
  String get commonErrorApi =>
      'Bei Riot gibt es gerade Probleme. Versuch es in ein paar Minuten erneut.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClearFilters => 'Filter löschen';

  @override
  String get commonClearSearch => 'Suche löschen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonCopied => 'Kopiert';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Tage',
      one: '$n Tag',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Tagen',
      one: 'vor $n Tag',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonEmptyGeneric => 'Hier ist noch nichts.';

  @override
  String get commonErrorContentUnavailable =>
      'Infos zu Skins, Agenten und Karten konnten nicht geladen werden. Prüf deine Verbindung und versuch es erneut.';

  @override
  String get commonErrorGeneric =>
      'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get commonErrorMaintenance =>
      'Die VALORANT-Server werden gerade gewartet. Schau später wieder vorbei.';

  @override
  String get commonErrorNeedsLogin =>
      'Deine Riot-Anmeldung ist abgelaufen. Melde dich erneut an, um fortzufahren.';

  @override
  String get commonErrorNeedsLoginTitle => 'Erneute Anmeldung nötig';

  @override
  String get commonErrorNetwork =>
      'Keine Internetverbindung. Prüf dein WLAN oder deine mobilen Daten und versuch es erneut.';

  @override
  String get commonErrorNoAccount => 'Du bist mit keinem Konto angemeldet.';

  @override
  String get commonErrorNotFound => 'Dieser Inhalt wurde nicht gefunden.';

  @override
  String get commonErrorTimeout =>
      'Riot antwortet zu langsam. Prüf deine Verbindung und versuch es erneut.';

  @override
  String get commonErrorTransient =>
      'Riot ist gerade ausgelastet. Versuch es in ein paar Minuten erneut.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot ist gerade ausgelastet. Versuch es in $duration erneut.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Deine Riot-Region konnte nicht ermittelt werden. Wähle deine Region in den Einstellungen.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Zur Startseite';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Stunden',
      one: '$n Stunde',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Stunden',
      one: 'vor $n Stunde',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Serverproblem';

  @override
  String get commonJustNow => 'gerade eben';

  @override
  String get commonLoadMore => 'Mehr laden';

  @override
  String get commonLoading => 'Wird geladen …';

  @override
  String get commonMaintenanceTitle => 'Serverwartung';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Minuten',
      one: '$n Minute',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Minuten',
      one: 'vor $n Minute',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Noch nichts zu sehen';

  @override
  String commonOfflineCached(String time) {
    return 'Keine Verbindung – gespeicherter Stand wird angezeigt ($time).';
  }

  @override
  String get commonOpenSettings => 'Einstellungen öffnen';

  @override
  String get commonPageNotFound => 'Diese Seite wurde nicht gefunden.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Bestes Paket: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Deinen Preis bearbeiten';

  @override
  String get commonPriceEnterOwn => 'Preis deines VP-Pakets eingeben';

  @override
  String get commonPriceEstimateBody =>
      'Der Betrag „≈ …“ neben VP-Preisen ist eine Schätzung, umgerechnet nach dem günstigsten VP-Paket. Im Spiel zahlst du mit VP; der echte Betrag hängt vom Paket, der Zahlungsart, Steuern und Angeboten beim Kauf ab.';

  @override
  String get commonPriceEstimateTitle => 'Geschätzter Umrechnungspreis';

  @override
  String get commonPriceEstimateTooltip =>
      'Geschätzter Preis – tippen, um die Berechnung zu sehen';

  @override
  String get commonPriceHidden =>
      'Umrechnungspreise ausgeblendet. In den Einstellungen wieder einschalten.';

  @override
  String get commonPriceHide => 'Umrechnungspreis ausblenden';

  @override
  String get commonPriceOpenSource => 'Quellseite öffnen';

  @override
  String get commonPriceOverrideBody =>
      'Gib den Betrag ein, den du tatsächlich für ein VP-Paket zahlst (siehe Shop im Spiel oder deine Rechnung). ValHub schätzt damit den Umrechnungspreis aller Gegenstände; der Preis wird nur auf diesem Gerät gespeichert.';

  @override
  String get commonPriceOverrideCurrency => 'Währungscode';

  @override
  String get commonPriceOverrideCurrencyHint => 'Beispiel: EUR, USD, CHF, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Beispielschätzung: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Gib einen Währungscode aus 3 Buchstaben ein, z. B. EUR oder USD.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Gib eine Zahl größer als 0 ein.';

  @override
  String get commonPriceOverridePrice => 'Paketpreis';

  @override
  String get commonPriceOverrideRemove => 'Eingegebenen Preis löschen';

  @override
  String get commonPriceOverrideRemoved =>
      'Dein eingegebener Preis wurde gelöscht.';

  @override
  String get commonPriceOverrideSave => 'Preis speichern';

  @override
  String get commonPriceOverrideSaved => 'Preis deines VP-Pakets gespeichert.';

  @override
  String get commonPriceOverrideTitle => 'Preis deines VP-Pakets';

  @override
  String get commonPriceOverrideVp => 'VP im Paket';

  @override
  String get commonPricePacksTitle => 'VP-Pakete';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Laut VP-Preisliste für die Region $country';
  }

  @override
  String get commonPriceSourceUser => 'Laut deinem eingegebenen VP-Paketpreis';

  @override
  String get commonPriceUnavailable =>
      'Für deine Region gibt es noch keine bestätigte Preisliste. Gib den Preis eines VP-Pakets ein, das du gekauft hast, um geschätzte Umrechnungspreise zu sehen.';

  @override
  String commonPriceUpdated(String date) {
    return 'Preisliste aktualisiert: $date';
  }

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonRiotDisclaimer =>
      'ValHub wird nicht von Riot Games unterstützt und gibt nicht die Ansichten oder Meinungen von Riot Games oder von Personen wieder, die offiziell an der Produktion oder Verwaltung von Riot-Games-Produkten beteiligt sind. Riot Games und alle zugehörigen Eigentümer sind Marken oder eingetragene Marken von Riot Games, Inc.';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonSearch => 'Suchen …';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sekunden',
      one: '$n Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Teilen';

  @override
  String get commonSignInAgain => 'Erneut anmelden';

  @override
  String get commonSort => 'Sortieren';

  @override
  String commonSortBy(String option) {
    return 'Sortieren: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Sammlung';

  @override
  String get commonTabCommunity => 'Community';

  @override
  String get commonTabHome => 'Start';

  @override
  String get commonTabProfile => 'Profil';

  @override
  String get commonTabSettings => 'Einstellungen';

  @override
  String get commonTabStore => 'Shop';

  @override
  String get commonTagline => 'Dein VALORANT-Begleiter';

  @override
  String get commonToday => 'Heute';

  @override
  String get commonTodayLower => 'heute';

  @override
  String get commonTomorrow => 'morgen';

  @override
  String get commonUnknownItem => 'Unbekannter Gegenstand';

  @override
  String commonUpdatedAt(String time) {
    return 'Aktualisiert um $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day um $time';
  }

  @override
  String get commonWeekdaysItem0 => 'Montag';

  @override
  String get commonWeekdaysItem1 => 'Dienstag';

  @override
  String get commonWeekdaysItem2 => 'Mittwoch';

  @override
  String get commonWeekdaysItem3 => 'Donnerstag';

  @override
  String get commonWeekdaysItem4 => 'Freitag';

  @override
  String get commonWeekdaysItem5 => 'Samstag';

  @override
  String get commonWeekdaysItem6 => 'Sonntag';

  @override
  String get commonYesterday => 'gestern';

  @override
  String get commonYesterdayTitle => 'Gestern';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot-Anmeldung abgelaufen – gespeicherter Stand wird angezeigt ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Schwere Waffen';

  @override
  String get contentCategoryMelee => 'Nahkampf';

  @override
  String get contentCategoryRifle => 'Sturmgewehre';

  @override
  String get contentCategoryShotgun => 'Schrotflinten';

  @override
  String get contentCategorySidearm => 'Sekundärwaffen';

  @override
  String get contentCategorySmg => 'Maschinenpistolen';

  @override
  String get contentCategorySniper => 'Präzisionsgewehre';

  @override
  String get contentCurrencyAgentTokens => 'Agentenmarken';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kingdom-Credits';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianit';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT-Punkte';

  @override
  String get contentItemAgent => 'Agent';

  @override
  String get contentItemBuddy => 'Talisman';

  @override
  String get contentItemCard => 'Spielerkarte';

  @override
  String get contentItemChroma => 'Variante';

  @override
  String get contentItemContract => 'Vertrag';

  @override
  String get contentItemCurrency => 'Währung';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Spray';

  @override
  String get contentItemTitle => 'Titel';

  @override
  String contentLevel(int n) {
    return 'Stufe $n';
  }

  @override
  String get contentLevelBase => 'Basis';

  @override
  String get contentLevelItemLabelsVFX => 'Visuelle Effekte';

  @override
  String get contentLevelItemLabelsAnimation => 'Animation';

  @override
  String get contentLevelItemLabelsFinisher => 'Finisher';

  @override
  String get contentLevelItemLabelsKillCounter => 'Kill-Zähler';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Soundeffekte';

  @override
  String get contentLevelItemLabelsTransformation => 'Verwandlung';

  @override
  String get contentLevelItemLabelsKillBanner => 'Kill-Banner';

  @override
  String get contentLevelItemLabelsKillEffect => 'Kill-Effekt';

  @override
  String get contentLevelItemLabelsInspectAndKill => 'Inspizier- & Kill-Effekt';

  @override
  String get contentLevelItemLabelsVoiceover => 'Sprachausgabe';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Songwechsel';

  @override
  String get contentLevelItemLabelsRandomizer => 'Zufallsauswahl';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Wechsel nach Angreifer/Verteidiger';

  @override
  String get contentLevelItemLabelsTopFrag => 'Top-Frag-Effekt';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Herzschlag- & Kartensensor';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Fischanimation';

  @override
  String get contentNoTitle => 'Kein Titel';

  @override
  String get contentNotForSale => 'Nicht käuflich';

  @override
  String get contentQueueNamesCompetitive => 'Gewertet';

  @override
  String get contentQueueNamesUnrated => 'Ungewertet';

  @override
  String get contentQueueNamesSwiftplay => 'Schnelles Spiel';

  @override
  String get contentQueueNamesSpikerush => 'Spike-Ansturm';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Team-Deathmatch';

  @override
  String get contentQueueNamesGgteam => 'Eskalation';

  @override
  String get contentQueueNamesOnefa => 'Klonprogramm';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Eigenes Spiel';

  @override
  String get contentQueueNames => 'Eigenes Spiel';

  @override
  String get contentQueueNamesDodgeball => 'Knockout';

  @override
  String get contentQueueNamesFortcollins => 'Rückeroberung';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Skirmish: 2vs2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Skirmish: Ascension (1vs1)';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Skirmish: Ascension (2vs2)';

  @override
  String get contentQueueNamesValaram => 'Alle Zufällig, Ein Areal';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Schneeballschlacht';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Gewertet';

  @override
  String get contentQueueShortNamesValaram => 'Zufällig, 1 Areal';

  @override
  String get contentRewardSourceAgent => 'Agentenvertrag';

  @override
  String get contentRewardSourceBattlePass => 'Battle-Pass-Belohnung';

  @override
  String get contentRewardSourceEvent => 'Event-Pass';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duellant';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Initiator';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Taktiker';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Wächter';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Exklusiv';

  @override
  String contentTierFull(String shortName) {
    return '$shortName-Edition';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Selektion';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Ohne Rang';

  @override
  String get accountRegionUnknown => 'Server unbekannt';

  @override
  String accountRiotCountry(String country) {
    return 'Land des Riot-Kontos: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Land des Riot-Kontos: unbekannt';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'KONTEN ($count/$max)';
  }

  @override
  String get accountActive => 'Aktiv';

  @override
  String accountAddAccount(int count, int max) {
    return 'Konto hinzufügen ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Lokale Daten löschen';

  @override
  String get accountClearLocalDataConfirm =>
      'Verlauf, gespeicherte Loadouts und Daten abgemeldeter Konten auf diesem Gerät löschen?';

  @override
  String get accountClearRrHistory => 'RR-Verlauf löschen';

  @override
  String get accountClearRrHistoryConfirm =>
      'RR-Verlauf des ausgewählten Kontos auf diesem Gerät löschen?';

  @override
  String get accountCopyPassword => 'Passwort kopieren';

  @override
  String get accountCopyUsername => 'Benutzernamen kopieren';

  @override
  String get accountDeleteLoginNote => 'Daten löschen';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Gespeicherten Benutzernamen und Passwort dieses Kontos löschen?';

  @override
  String get accountHidePassword => 'Passwort verbergen';

  @override
  String get accountKeepLocalData => 'Lokale Daten behalten';

  @override
  String get accountKeepLocalDataHint =>
      'Wishlist, Loadouts und Verlauf auf diesem Gerät behalten';

  @override
  String accountLevelShort(int level) {
    return 'Stufe $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Das Konto aus der Benachrichtigung wurde abgemeldet. Melde dich erneut an und öffne dann die Benachrichtigung.';

  @override
  String get accountLocalDataCleared => 'Lokale Daten gelöscht';

  @override
  String get accountLoginNote => 'Anmeldedaten';

  @override
  String get accountLoginNoteDeleted => 'Anmeldedaten gelöscht';

  @override
  String get accountLoginNoteHint =>
      'Nur auf diesem Gerät gespeichert und sicher gesperrt. Zum Nachsehen oder schnellen Ausfüllen, wenn du dich erneut anmeldest.';

  @override
  String get accountLoginNoteLocked => 'Anmeldedaten entsperren';

  @override
  String get accountLoginNotePassword => 'Passwort';

  @override
  String get accountLoginNoteSaved => 'Anmeldedaten gespeichert';

  @override
  String get accountLoginNoteUsername => 'Riot-Benutzername';

  @override
  String accountMaxAccounts(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Maximum von $max Konten erreicht.',
      one: 'Maximum von $max Konto erreicht.',
    );
    return '$_temp0';
  }

  @override
  String get accountNeedsLogin => 'Erneute Anmeldung nötig';

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
  String get accountQuickFill => 'Gespeichertes Konto einfügen';

  @override
  String get accountQuickFillDone => 'Ausgefüllt. Tippe jetzt auf Anmelden.';

  @override
  String get accountQuickFillNotReady =>
      'Die Anmeldeseite ist noch nicht geladen. Warte kurz und versuch es erneut.';

  @override
  String get accountQuickFillSubtitle =>
      'Wähle ein Konto, um die Riot-Anmeldeseite auszufüllen';

  @override
  String get accountQuickFillTitle => 'Gespeichertes Konto einfügen';

  @override
  String get accountRegionAp => 'Asien-Pazifik';

  @override
  String get accountRegionBr => 'Brasilien';

  @override
  String get accountRegionEu => 'Europa';

  @override
  String get accountRegionKr => 'Korea';

  @override
  String get accountRegionLatam => 'Lateinamerika';

  @override
  String get accountRegionNa => 'Nordamerika';

  @override
  String get accountRemoveAccount => 'Konto entfernen';

  @override
  String accountRemoveAccountConfirm(String account) {
    return '$account von diesem Gerät entfernen? Du kannst gespeicherte Daten behalten.';
  }

  @override
  String get accountRrHistoryCleared => 'RR-Verlauf gelöscht';

  @override
  String get accountShowPassword => 'Passwort anzeigen';

  @override
  String get accountSignOutAll => 'Von allen Konten abmelden';

  @override
  String get accountSignOutAllConfirm =>
      'Abmelden und alle Konten von diesem Gerät entfernen? Du kannst gespeicherte Daten behalten.';

  @override
  String get accountStatusAgentSelect => 'In der Agentenauswahl';

  @override
  String get accountStatusInMatch => 'Im Match';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Status unbekannt';

  @override
  String accountSwitchTo(String account) {
    return 'Zu $account wechseln';
  }

  @override
  String get accountSwitcherSubtitle => 'Tippen, um das Konto zu wechseln';

  @override
  String get accountSwitcherTitle => 'Konten';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Konten ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Spieler';

  @override
  String get accountUnlockLoginNote =>
      'Bestätige deine Identität, um die Riot-Anmeldedaten zu öffnen';

  @override
  String accountMoreActions(String riotId) {
    return 'Optionen für $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Anmeldedaten speichern';

  @override
  String get accountClearRrHistorySubtitle => 'Nur das ausgewählte Konto';

  @override
  String get accountClearLocalDataSubtitle =>
      'Verlauf, gespeicherte Loadouts und Daten abgemeldeter Konten';

  @override
  String get accountQuickFillLocked =>
      'Entsperre mit Fingerabdruck, Gesicht oder Geräte-PIN, um ein gespeichertes Konto zu nutzen. Hat dein Handy keine Displaysperre, richte eine ein und versuche es erneut.';

  @override
  String get authAddAsNew => 'Als neues Konto hinzufügen';

  @override
  String get authDifferentAccountBody =>
      'Du hast dich mit einem anderen Konto angemeldet als dem, das eine erneute Anmeldung braucht. Dieses Konto als neues Konto hinzufügen?';

  @override
  String get authDifferentAccountTitle => 'Anderes Konto';

  @override
  String get authLoadingAccount => 'Konto wird geladen …';

  @override
  String get authLoginCancelledByRiot =>
      'Riot hat diese Anmeldung abgelehnt. Versuch es erneut.';

  @override
  String get authLoginFailed => 'Anmeldung konnte nicht abgeschlossen werden';

  @override
  String get authLoginFailedBody =>
      'Riot hat deine Anmeldung nicht bestätigt. Versuch es erneut.';

  @override
  String get authLoginTitle => 'Riot-Anmeldung';

  @override
  String get authMissingCookies =>
      'Die Anmeldung kann auf diesem Gerät nicht gespeichert werden. Wenn sie abläuft, musst du dich erneut anmelden.';

  @override
  String get authOfficialHost => 'Offizielle Seite · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Link im Browser geöffnet.';

  @override
  String get authPageLoadFailed =>
      'Die Riot-Anmeldeseite konnte nicht geladen werden. Prüf deine Verbindung und versuch es erneut.';

  @override
  String get authPreparing => 'Anmeldeseite wird vorbereitet …';

  @override
  String get authReloginDone => 'Erneut angemeldet';

  @override
  String get authSignInCta => 'Mit Riot-Konto anmelden';

  @override
  String get authSocialLoginHint =>
      'Falls die Anmeldung mit Google oder Facebook nicht klappt, nutze deinen Riot-Benutzernamen.';

  @override
  String get authStateMismatch =>
      'Diese Anmeldung ist ungültig. Melde dich noch einmal von vorn an.';

  @override
  String get notificationSessionExpiredBody =>
      'Melde dich erneut an, um weiter Wishlist-Benachrichtigungen zu erhalten.';

  @override
  String get notificationBackgroundTimingHint =>
      'Der Energiesparmodus deines Geräts kann Benachrichtigungen verzögern.';

  @override
  String get notificationChannelAccountDescription =>
      'Erinnert dich, wenn ein Konto eine erneute Anmeldung braucht';

  @override
  String get notificationChannelAccountName => 'Konten';

  @override
  String get notificationChannelBattlePassDescription =>
      'Erinnert an Fortschritt und Enddatum des Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Meldet Community-Aktivität, wenn du ValHub öffnest';

  @override
  String get notificationChannelCommunityName => 'Community';

  @override
  String get notificationChannelLfgDescription =>
      'Meldet, wenn Spieler deiner Gruppe beitreten, sobald du ValHub öffnest';

  @override
  String get notificationChannelLfgName => 'Gruppe';

  @override
  String get notificationChannelNightMarketDescription =>
      'Meldet, wenn der Nachtmarkt öffnet';

  @override
  String get notificationChannelNightMarketName => 'Nachtmarkt';

  @override
  String get notificationChannelRankDescription =>
      'Meldet Rangänderungen, wenn du dein Profil aktualisierst';

  @override
  String get notificationChannelRankName => 'Rang';

  @override
  String get notificationChannelStoreResetDescription =>
      'Erinnert dich, wenn der tägliche Shop sich erneuert';

  @override
  String get notificationChannelStoreResetName => 'Shop-Erneuerung';

  @override
  String get notificationChannelWishlistDescription =>
      'Meldet, wenn ein Skin aus deiner Wishlist im Shop auftaucht';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle =>
      'Ein Spieler ist deiner Gruppe beigetreten';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Deck jetzt die Angebote für $account auf (Karten: $cards).';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Der Nachtmarkt ist da!';

  @override
  String get notificationPassEndingBody =>
      'Der Battle Pass läuft noch etwa einen Tag. Öffne ValHub, um deinen aktuellen Fortschritt zu sehen.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass endet bald';

  @override
  String notificationPassProgressBody(int level) {
    return 'Du hast Stufe $level im aktuellen Battle Pass erreicht.';
  }

  @override
  String get notificationPassProgressTitle => 'Battle-Pass-Fortschritt';

  @override
  String get notificationPrivateAccount => 'dein Konto';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Aktueller Rang: $rank. Gerade von Riot aktualisiert.';
  }

  @override
  String get notificationRankChangedTitle => 'Dein Rang hat sich geändert';

  @override
  String get notificationResetTimingUnknown =>
      'Öffne den Shop, um die Erneuerungszeit auf deinem Gerät zu aktualisieren.';

  @override
  String get notificationSessionExpiredTitle => 'Erneute Anmeldung nötig';

  @override
  String get notificationStoreResetBody =>
      'Neue Skins warten im Shop auf dich.';

  @override
  String get competitiveDivisionIron => 'Eisen';

  @override
  String get competitiveDivisionBronze => 'Bronze';

  @override
  String get competitiveDivisionSilver => 'Silber';

  @override
  String get competitiveDivisionGold => 'Gold';

  @override
  String get competitiveDivisionPlatinum => 'Platin';

  @override
  String get competitiveDivisionDiamond => 'Diamant';

  @override
  String get competitiveDivisionAscendant => 'Aufgestiegen';

  @override
  String get competitiveDivisionImmortal => 'Unsterblich';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiant';

  @override
  String get competitiveRankUnknown => 'Rang unbekannt';

  @override
  String get competitiveAttack => 'Angriff';

  @override
  String get competitiveCannotEstimate => 'Nicht abschätzbar';

  @override
  String get competitiveDefeat => 'Niederlage';

  @override
  String get competitiveDefense => 'Verteidigung';

  @override
  String get competitiveDraw => 'Unentschieden';

  @override
  String get competitiveIncognitoPlayer => 'Anonymer Spieler';

  @override
  String get competitiveMatchPending => 'Riot verarbeitet das Match …';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Noch $n Platzierungsmatches',
      one: 'Noch $n Platzierungsmatch',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike entschärft';

  @override
  String get competitiveRoundDetonate => 'Spike detoniert';

  @override
  String get competitiveRoundElimination => 'Team ausgeschaltet';

  @override
  String get competitiveRoundSurrendered => 'Aufgegeben';

  @override
  String get competitiveRoundTimeExpired => 'Zeit abgelaufen';

  @override
  String get competitiveUnknownPlayer => 'Spieler';

  @override
  String get competitiveVictory => 'Sieg';

  @override
  String economyAvailableNow(String place) {
    return 'Jetzt verfügbar: $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'Bundle $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'Bundle';

  @override
  String get economyPlaceDaily => 'täglicher Shop';

  @override
  String get economyPlaceNightMarket => 'Nachtmarkt';

  @override
  String get economyPriceEstimated => 'Geschätzter Preis nach Edition';

  @override
  String get economyPriceFromOffers => 'Preis aus Riots Preisliste';

  @override
  String get economyPriceFromStore => 'Im Shop gesehener Preis';

  @override
  String get economyPriceFromTable => 'Listenpreis';

  @override
  String get economyPriceUnknown => 'Preis unbekannt';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Loadout $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Diese Änderung passt nicht zu deinem aktuellen Loadout.';

  @override
  String get loadoutNotPersisted =>
      'Riot hat deine Änderung nicht gespeichert, dein Loadout ist unverändert. Versuch es erneut.';

  @override
  String get loadoutSaveFailed => 'Loadout konnte nicht gespeichert werden';

  @override
  String battlePassActEndsIn(String time) {
    return 'Akt endet in $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Akt endet in $days Tagen',
      one: 'Akt endet in $days Tag',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Alle Missionen abgeschlossen';

  @override
  String get battlePassAllWeeklyDone => 'Alle Wochenmissionen abgeschlossen';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Ausstehende doppelte Belohnungen: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Kapitel $n';
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
      'Gewinne Runden, um Checkpoints zu füllen (Deathmatch zählt nicht).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Checkpoint $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Pro Checkpoint: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Checkpoints erreicht: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Aktuell';

  @override
  String get battlePassDailyAllDone => 'Alle Checkpoints für heute erreicht';

  @override
  String get battlePassDailyCaption => 'Tagesbelohnungen';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Tagesbelohnungen · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Die Checkpoints vom Vortag sind abgelaufen. Starte das Spiel oder aktualisiere hier.';

  @override
  String get battlePassDailyMissions => 'Tägliche Missionen';

  @override
  String get battlePassDailyNotReady =>
      'Die heutigen Checkpoints sind noch nicht bereit. Starte das Spiel oder aktualisiere hier.';

  @override
  String get battlePassDailyPlayToStart =>
      'Die heutigen Checkpoints sind noch nicht bereit. Starte das Spiel, um den neuen Tag zu beginnen.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Noch $days Tage',
      one: 'Noch $days Tag',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Endet $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilog';

  @override
  String get battlePassEstimateNote =>
      'Geschätzt ca. 4.000 XP pro Match, ohne Missionen.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Endet in $time';
  }

  @override
  String get battlePassEventPass => 'Event-Pass';

  @override
  String get battlePassFilterAll => 'Alle';

  @override
  String get battlePassFilterLocked => 'Gesperrt';

  @override
  String get battlePassFilterUnlocked => 'Freigeschaltet';

  @override
  String get battlePassFree => 'Gratis';

  @override
  String get battlePassFreeTrack => 'Gratis-Belohnungen';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Stufe $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Stufe $n';
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
      other: '$nString Matches',
      one: '$nString Match',
    );
    return '≈ $_temp0 in $queue';
  }

  @override
  String get battlePassMissionDone => 'Abgeschlossen';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total abgeschlossen';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Neue Missionen $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Neue Missionen in $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Nächster Checkpoint: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Bis Stufe $level';
  }

  @override
  String get battlePassNextReward => 'Als Nächstes';

  @override
  String get battlePassNoBattlePass =>
      'Noch keine Battle-Pass-Infos für den aktuellen Akt. Versuch es später erneut.';

  @override
  String get battlePassNoRewards =>
      'Für diesen Battle Pass gibt es noch keine Belohnungen.';

  @override
  String get battlePassNoRewardsInFilter =>
      'In dieser Kategorie gibt es keine Belohnungen.';

  @override
  String get battlePassNoRewardsTitle => 'Noch keine Belohnungen';

  @override
  String get battlePassNoWeeklyMissions =>
      'Zurzeit gibt es keine Wochenmissionen.';

  @override
  String get battlePassPassComplete => 'Battle Pass abgeschlossen';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Du hast Premium nicht gekauft und erhältst nur die Gratis-Belohnungen. Kauf Premium im Spiel, um die erreichten Stufen freizuschalten.';

  @override
  String get battlePassRenewButton => 'Checkpoints aktualisieren';

  @override
  String get battlePassRenewDone => 'Tägliche Checkpoints aktualisiert.';

  @override
  String get battlePassRenewFailed =>
      'Checkpoints konnten nicht aktualisiert werden. Versuch es später erneut.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Erneuerung $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Erneuerung in $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Stufe';

  @override
  String get battlePassRewardLocked => 'Gesperrt';

  @override
  String get battlePassRewardNeedsPremium => 'Premium nötig';

  @override
  String get battlePassRewardStatusLabel => 'Status';

  @override
  String get battlePassRewardTrackLabel => 'Belohnungsart';

  @override
  String get battlePassRewardTypeLabel => 'Typ';

  @override
  String get battlePassRewardUnlocked => 'Freigeschaltet';

  @override
  String get battlePassRewardsTitle => 'Belohnungen';

  @override
  String get battlePassShowAllRewards => 'Alle anzeigen';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'Gesamt-XP';

  @override
  String get battlePassUnknownMission =>
      'Neue Mission (noch ohne Beschreibung)';

  @override
  String get battlePassUnknownReward => 'Belohnung';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total freigeschaltet';
  }

  @override
  String get battlePassUnratedFallback => 'Ungewertet';

  @override
  String get battlePassViewAllRewards => 'Alle Belohnungen anzeigen';

  @override
  String get battlePassWeeklyMissions => 'Wochenmissionen';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Wochenmissionen: noch +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / Tag';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Pro Tag nötig, um rechtzeitig fertig zu werden';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Noch $xp XP nötig';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Loadout konnte nicht gespeichert werden. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Alle deine Skins, bewertet nach Shop-Preis',
      'buddy': 'Deine Talismane und Anzahl der Kopien',
      'spray': 'Sprays, die du in dein Ausdrucksrad legen kannst',
      'card':
          'Freigeschaltete Spielerkarten – zum Ansehen und Ausrüsten tippen',
      'title': 'Titel, die du unter deinem Namen zeigen kannst',
      'flex': 'Deine Flex-Gegenstände',
      'other': 'Sammlung durchsuchen',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Platz $position';
  }

  @override
  String get collectionApplyPreset => 'Anwenden';

  @override
  String get collectionApplyPresetBody =>
      'Deine aktuellen Skins, Talismane, Ausdrucksrad, Karte und Titel werden durch dieses Loadout ersetzt.';

  @override
  String collectionApplyPresetTitle(String name) {
    return '„$name“ anwenden?';
  }

  @override
  String get collectionBrowseBuddies => 'Talismane';

  @override
  String get collectionBrowseCards => 'Spielerkarten';

  @override
  String get collectionBrowseEmpty =>
      'Du hast in dieser Kategorie noch keine Gegenstände.';

  @override
  String get collectionBrowseEmptyTitle => 'Noch keine Gegenstände';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skins';

  @override
  String get collectionBrowseSprays => 'Sprays';

  @override
  String get collectionBrowseTitles => 'Titel';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Frei: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Für $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Talisman wählen';

  @override
  String get collectionBuddyRemoved => 'Talisman entfernt';

  @override
  String get collectionBuddySlot => 'Talisman';

  @override
  String get collectionBuddyUnavailable =>
      'Dieser Talisman kann nicht angebracht werden. Aktualisiere oder wähle einen anderen.';

  @override
  String get collectionCachedLoadout =>
      'Gespeichertes Loadout wird angezeigt. Zum Aktualisieren ziehen, bevor du etwas änderst.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Karten im Besitz',
      one: '$nString Karte im Besitz',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Ändern';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'Varianten: $owned/$total';
  }

  @override
  String get collectionClearTiers => 'Editionsfilter löschen';

  @override
  String get collectionCollectionValue => 'Wert der Sammlung';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standard';

  @override
  String get collectionDeletePreset => 'Löschen';

  @override
  String get collectionEmptySlot => 'Leer';

  @override
  String get collectionEquip => 'Ausrüsten';

  @override
  String get collectionEquipped => 'Ausgerüstet';

  @override
  String get collectionEquippedCard => 'Aktuelle Karte';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Aktuelle Karte: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$name ausgerüstet';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Ausgerüstet: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Ohne Belohnungs-Skins';

  @override
  String get collectionExpressionsHint =>
      'Tippe auf einen Platz, um ein Spray oder Flex zu wählen.';

  @override
  String get collectionExpressionsSlots => 'Plätze im Rad';

  @override
  String get collectionExpressionsTitle => 'Ausdrucksrad';

  @override
  String get collectionHideAccountLevel => 'Kontostufe verbergen';

  @override
  String get collectionHideAccountLevelHint =>
      'Andere Spieler sehen deine Kontostufe nicht.';

  @override
  String get collectionIncognito => 'Inkognito-Modus';

  @override
  String get collectionIncognitoHint =>
      'Verbirgt deinen Namen im Match vor Spielern außerhalb deiner Gruppe.';

  @override
  String get collectionLevelBorderAuto => 'Automatisch nach Stufe';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Ab Stufe $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Kontostufe $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Stufenrahmen wählen';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Stufe $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Stufe $n · $type';
  }

  @override
  String get collectionLevels => 'Stufen';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Stufen freigeschaltet: $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'Lobby-Bild';

  @override
  String get collectionLocked => 'Gesperrt';

  @override
  String get collectionMeleeNoBuddy =>
      'An Nahkampfwaffen lassen sich keine Talismane anbringen.';

  @override
  String get collectionMove => 'Verschieben';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy hängt an $from. Zu $to verschieben?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Talisman verschieben?';

  @override
  String get collectionNoBuddies => 'Du hast noch keine Talismane.';

  @override
  String get collectionNoBuddy => 'Kein Talisman';

  @override
  String get collectionNoFlex => 'Du hast noch kein Flex.';

  @override
  String get collectionNoResults => 'Keine passenden Ergebnisse gefunden.';

  @override
  String get collectionNoResultsTitle => 'Nichts gefunden';

  @override
  String get collectionNoSkinsForWeapon =>
      'Du hast noch keine Skins für diese Waffe.';

  @override
  String get collectionNoSprays => 'Du hast noch keine Sprays.';

  @override
  String get collectionNoTitle => 'Kein Titel';

  @override
  String get collectionOtherWeapons => 'Sonstige';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Skins im Besitz',
      one: '$n Skin im Besitz',
      zero: 'Noch keine Skins',
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
      other: '$nString Skins im Besitz',
      one: '$nString Skin im Besitz',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Video dieser Stufe ansehen';

  @override
  String get collectionPlayVideo => 'Video ansehen';

  @override
  String get collectionPlayerCardSubtitle =>
      'Wird in der Lobby, auf der Anzeigetafel und bei deinen Kills angezeigt.';

  @override
  String get collectionPlayerCardTitle => 'Spielerkarte ändern';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Wird in der Lobby und im Match unter deinem Namen angezeigt.';

  @override
  String get collectionPlayerTitleTitle => 'Titel ändern';

  @override
  String get collectionPresetActions => 'Optionen';

  @override
  String collectionPresetApplied(String name) {
    return '„$name“ angewendet';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Loadouts',
      one: '$n Loadout',
      zero: 'Keine',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '„$name“ gelöscht';
  }

  @override
  String get collectionPresetNameHint => 'Beispiel: Rank-Grind';

  @override
  String get collectionPresetNameTitle => 'Name des Loadouts';

  @override
  String collectionPresetSaved(String name) {
    return '„$name“ gespeichert';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Gespeichert am $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Gegenstände übersprungen, die du nicht mehr besitzt.',
      one: '$n Gegenstand übersprungen, den du nicht mehr besitzt.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Speichere dein aktuelles Loadout, um später schnell zwischen Skins, Karten und Ausdrucksrädern zu wechseln.';

  @override
  String get collectionPresetsEmptyTitle => 'Noch keine Loadouts';

  @override
  String get collectionPresetsFull =>
      'Maximal 50 Loadouts erreicht. Lösche welche, um neue zu speichern.';

  @override
  String get collectionPresetsNote =>
      'Loadouts werden nur auf diesem Gerät und für das ausgewählte Konto gespeichert.';

  @override
  String get collectionPresetsTitle => 'Gespeicherte Loadouts';

  @override
  String get collectionPreview => 'Vorschau';

  @override
  String get collectionRemoveBuddy => 'Talisman entfernen';

  @override
  String get collectionRenamePreset => 'Umbenennen';

  @override
  String get collectionRowExpressions => 'Ausdrucksrad';

  @override
  String get collectionRowLevelBorder => 'Stufenrahmen';

  @override
  String get collectionRowPresets => 'Gespeicherte Loadouts';

  @override
  String get collectionRowWeapons => 'Waffen-Loadout';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Loadout konnte nicht gespeichert werden';

  @override
  String get collectionSavePreset => 'Aktuelles Loadout speichern';

  @override
  String get collectionSaving => 'Wird gespeichert …';

  @override
  String get collectionSearchBuddies => 'Talismane suchen …';

  @override
  String get collectionSearchCards => 'Spielerkarten suchen …';

  @override
  String get collectionSearchFlex => 'Flex suchen …';

  @override
  String get collectionSearchItems => 'Suchen …';

  @override
  String get collectionSearchSkins => 'Skins suchen …';

  @override
  String get collectionSearchSprays => 'Sprays suchen …';

  @override
  String get collectionSearchTitles => 'Titel suchen …';

  @override
  String get collectionSearchWeapons => 'Waffen, Skins oder Talismane suchen …';

  @override
  String get collectionSectionBrowse => 'Sammlung durchsuchen';

  @override
  String get collectionSectionIdentity => 'Für andere Spieler sichtbar';

  @override
  String get collectionSectionLoadout => 'Loadout';

  @override
  String get collectionSkinCustomizeTitle => 'Skin anpassen';

  @override
  String get collectionSkinNotFound => 'Dieser Skin wurde nicht gefunden.';

  @override
  String get collectionSkinNotOwned => 'Du besitzt diesen Skin nicht.';

  @override
  String get collectionSlotNamesItem0 => 'Oben';

  @override
  String get collectionSlotNamesItem1 => 'Rechts';

  @override
  String get collectionSlotNamesItem2 => 'Unten';

  @override
  String get collectionSlotNamesItem3 => 'Links';

  @override
  String get collectionSortName => 'Name';

  @override
  String get collectionSortPrice => 'Preis';

  @override
  String get collectionSortRarity => 'Seltenheit';

  @override
  String get collectionSortWeapon => 'Waffe';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gefiltert: $count Skins · $value',
      one: 'Gefiltert: $count Skin · $value',
    );
    return '$_temp0';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Gefilterte Gegenstände: $count/$total';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gegenstände',
      one: '$count Gegenstand',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Skins · $value',
      one: '$count Skin · $value',
    );
    return '$_temp0';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Sprays';

  @override
  String get collectionTapToChangeCard => 'Tippen, um die Karte zu ändern';

  @override
  String get collectionTitle => 'Sammlung';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString Titel im Besitz';
  }

  @override
  String get collectionUndo => 'Rückgängig';

  @override
  String get collectionUnknownCard => 'Unbekannte Karte';

  @override
  String get collectionValueAtStorePrices => 'Nach Shop-Preisen berechnet';

  @override
  String get collectionValueHasEstimates => 'Enthält Schätzpreise (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Belohnungs-Skins nicht eingerechnet',
      one: '$n Belohnungs-Skin nicht eingerechnet',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Skins ansehen';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Berechnet aus $n Skins',
      one: 'Berechnet aus $n Skin',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Varianten';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'Waffen mit Skin: $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Waffen-Loadout';

  @override
  String get collectionWeaponNotFound => 'Diese Waffe wurde nicht gefunden.';

  @override
  String get collectionWeaponSkinsTitle => 'Skin wählen';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Skins',
      one: '$n Skin',
      zero: 'Leer',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Nicht gepostet, weil unpassende Wörter enthalten sind. Bearbeite den Text und versuch es erneut.';

  @override
  String get communityModerationContentScam =>
      'In der Community sind Werbung für Kontohandel, Boosting oder Telefonnummern nicht erlaubt. Entferne diese Inhalte und versuch es erneut.';

  @override
  String get communityModerationContentTooComplex =>
      'Der Text enthält zu viele einzelne Zeichen. Schreib ihn kürzer und versuch es erneut.';

  @override
  String get communityModerationAccountBanned =>
      'Dieses Konto wurde für die Community gesperrt. Falls du einen Fehler vermutest, kontaktiere ValHub unter Über & Rechtliches.';

  @override
  String get communityModerationAccountRestricted =>
      'Dieses Konto darf vorübergehend keine Beiträge, Kommentare, Mitspielersuchen oder Stimmen abgeben. Versuch es später erneut oder kontaktiere ValHub unter Über & Rechtliches.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Gewertet',
      'unrated': 'Ungewertet',
      'swiftplay': 'Schnelles Spiel',
      'spikerush': 'Spike-Ansturm',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Team-Deathmatch',
      'premier': 'Premier',
      'custom': 'Eigenes Spiel',
      'other': 'Andere',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asien-Pazifik',
      'na': 'Nordamerika',
      'eu': 'Europa',
      'kr': 'Korea',
      'latam': 'Lateinamerika',
      'br': 'Brasilien',
      'other': 'Server unbekannt',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle =>
      'Noch keine Skins in dieser Rangliste';

  @override
  String get communityRankingEmptyVotes =>
      'Noch keine Favoriten für den gewählten Bereich und Filter.';

  @override
  String get communityRankingEmptyRatings =>
      'Noch keine Sternebewertungen für den gewählten Bereich und Filter.';

  @override
  String get communityRankingEmptyReviews =>
      'Noch keine Rezensionen für den gewählten Bereich und Filter.';

  @override
  String get communityRankingExplore => 'Skins suchen, ansehen und bewerten';

  @override
  String get communityRankingExploreHint =>
      'Suche nach Skin- oder Waffennamen. In der Rangliste erscheinen nur echte Bewertungen der Community.';

  @override
  String get communityRankingClear => 'Waffen- und Zeitfilter löschen';

  @override
  String get communityRankingSort => 'Ranking nach';

  @override
  String get communityRankingWeapon => 'Waffe';

  @override
  String get communityRankingNoSearch =>
      'Keine passenden Skins gefunden. Versuch einen anderen Namen oder entferne den Waffenfilter.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Die Skin-Liste konnte nicht geladen werden. Schließe das Fenster und versuch es nach der Synchronisierung erneut.';

  @override
  String get communityConsentExitAccount => 'Ablehnen · Dieses Konto abmelden';

  @override
  String get communityRankingGlobalAllTime => 'Weltweit · Gesamte Zeit';

  @override
  String get communityRankingCatalogTitle => 'Alle Skins';

  @override
  String get communityReviewOwnershipRequired =>
      'Zum Bewerten muss dein Konto diesen Skin besitzen. Bewertungen und Kommentare der Community kannst du trotzdem lesen.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Der Skin-Besitz konnte nicht bestätigt werden. Lade die Sammlung neu oder versuch es mit Verbindung erneut.';

  @override
  String get communityReviewLegacyOwnership =>
      'Alte Bewertung · Besitz nicht bestätigt';

  @override
  String get communityReviewVerifiedOwner =>
      'Besitz bei der Bewertung bestätigt';

  @override
  String get communitySkinDiscussionHint =>
      'Jeder kann kommentieren. Nur Besitzer des Skins können Sterne vergeben und Rezensionen schreiben.';

  @override
  String get communityAddPhotos => 'Fotos hinzufügen';

  @override
  String get communityAllModes => 'Alle';

  @override
  String get communityAllWeapons => 'Alle Waffen';

  @override
  String get communityAnonymousBanner => 'Anonyme Ansicht';

  @override
  String get communityAnyLanguage => 'Jede Sprache';

  @override
  String get communityAnyRank => 'Jeder Rang';

  @override
  String get communityAnyRole => 'Jede Rolle';

  @override
  String get communityApply => 'Anwenden';

  @override
  String get communityBackToMyCountry => 'Zu meinem Land';

  @override
  String get communityBlockAuthor => 'Auf dem Gerät blockieren';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Auswahl aufheben';

  @override
  String get communityCodeAuto =>
      'Leer lassen: ValHub erstellt beim Posten automatisch einen Code aus deiner Gruppe im Spiel.';

  @override
  String get communityCodeAutoFailed =>
      'Gruppencode konnte nicht erstellt werden. Öffne VALORANT oder gib den Code manuell ein.';

  @override
  String get communityCodeInvalid =>
      'Der Code besteht aus genau 6 Großbuchstaben oder Ziffern.';

  @override
  String get communityCodeRequired =>
      'Gib einen Gruppencode ein oder erstelle einen.';

  @override
  String get communityCommentHint => 'Kommentar schreiben …';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Kommentare',
      one: '$nString Kommentar',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Kommentare · $n';
  }

  @override
  String get communityCommentsTitle => 'Kommentare';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Beiträge: $posts · Personen: $authors';
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
      other: '$nString Mitspielersuchen',
      one: '$nString Mitspielersuche',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Community-Favoriten';

  @override
  String get communityComposerHint => 'Was denkst du heute über VALORANT?';

  @override
  String get communityComposerTitle => 'Neuer Beitrag';

  @override
  String communityConsentAccount(String riotId) {
    return 'Konto: $riotId';
  }

  @override
  String get communityConsentAgree => 'Zustimmen und weiter';

  @override
  String get communityConsentGateAction => 'Beitreten';

  @override
  String get communityConsentGuidelines => 'Community-Richtlinien';

  @override
  String get communityConsentLater => 'Später';

  @override
  String get communityConsentLocal =>
      'Dein Passwort und andere Anmeldedaten bleiben immer auf diesem Gerät. Du kannst deine Zustimmung in den Einstellungen widerrufen.';

  @override
  String get communityConsentPrivacy => 'Datenschutzerklärung';

  @override
  String get communityConsentPublic =>
      'Andere sehen deine Riot ID, Spielerkarte, deinen Rang und dein Land.';

  @override
  String get communityConsentTitle => 'Datenschutz und ValHub-Community';

  @override
  String get communityConsentVerify =>
      'ValHub übermittelt deinen Riot-Zugang an den Community-Server, um beim Verbinden deine Riot ID zu bestätigen und beim Speichern einer Bewertung deinen Skin-Besitz zu prüfen. Der Server liest nur die nötigen Daten, verwirft den Zugang sofort danach und speichert ihn nicht.';

  @override
  String get communityConsentWithdrawn =>
      'Zustimmung widerrufen. Um die App weiter zu nutzen, musst du erneut zustimmen.';

  @override
  String get communityCountriesTitle => 'Communitys der Länder';

  @override
  String get communityCountryNamesAE => 'Vereinigte Arabische Emirate';

  @override
  String get communityCountryNamesAL => 'Albanien';

  @override
  String get communityCountryNamesAM => 'Armenien';

  @override
  String get communityCountryNamesAR => 'Argentinien';

  @override
  String get communityCountryNamesAT => 'Österreich';

  @override
  String get communityCountryNamesAU => 'Australien';

  @override
  String get communityCountryNamesAZ => 'Aserbaidschan';

  @override
  String get communityCountryNamesBA => 'Bosnien und Herzegowina';

  @override
  String get communityCountryNamesBD => 'Bangladesch';

  @override
  String get communityCountryNamesBE => 'Belgien';

  @override
  String get communityCountryNamesBG => 'Bulgarien';

  @override
  String get communityCountryNamesBH => 'Bahrain';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivien';

  @override
  String get communityCountryNamesBR => 'Brasilien';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Kanada';

  @override
  String get communityCountryNamesCH => 'Schweiz';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'China';

  @override
  String get communityCountryNamesCO => 'Kolumbien';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Kuba';

  @override
  String get communityCountryNamesCY => 'Zypern';

  @override
  String get communityCountryNamesCZ => 'Tschechien';

  @override
  String get communityCountryNamesDE => 'Deutschland';

  @override
  String get communityCountryNamesDK => 'Dänemark';

  @override
  String get communityCountryNamesDO => 'Dominikanische Republik';

  @override
  String get communityCountryNamesDZ => 'Algerien';

  @override
  String get communityCountryNamesEC => 'Ecuador';

  @override
  String get communityCountryNamesEE => 'Estland';

  @override
  String get communityCountryNamesEG => 'Ägypten';

  @override
  String get communityCountryNamesES => 'Spanien';

  @override
  String get communityCountryNamesET => 'Äthiopien';

  @override
  String get communityCountryNamesFI => 'Finnland';

  @override
  String get communityCountryNamesFR => 'Frankreich';

  @override
  String get communityCountryNamesGB => 'Vereinigtes Königreich';

  @override
  String get communityCountryNamesGE => 'Georgien';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Griechenland';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hongkong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Kroatien';

  @override
  String get communityCountryNamesHU => 'Ungarn';

  @override
  String get communityCountryNamesID => 'Indonesien';

  @override
  String get communityCountryNamesIE => 'Irland';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'Indien';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Island';

  @override
  String get communityCountryNamesIT => 'Italien';

  @override
  String get communityCountryNamesJO => 'Jordanien';

  @override
  String get communityCountryNamesJP => 'Japan';

  @override
  String get communityCountryNamesKE => 'Kenia';

  @override
  String get communityCountryNamesKH => 'Kambodscha';

  @override
  String get communityCountryNamesKR => 'Südkorea';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Kasachstan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Libanon';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Litauen';

  @override
  String get communityCountryNamesLU => 'Luxemburg';

  @override
  String get communityCountryNamesLV => 'Lettland';

  @override
  String get communityCountryNamesLY => 'Libyen';

  @override
  String get communityCountryNamesMA => 'Marokko';

  @override
  String get communityCountryNamesMD => 'Moldau';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Nordmazedonien';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolei';

  @override
  String get communityCountryNamesMO => 'Macau';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Mexiko';

  @override
  String get communityCountryNamesMY => 'Malaysia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Niederlande';

  @override
  String get communityCountryNamesNO => 'Norwegen';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Neuseeland';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Philippinen';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Polen';

  @override
  String get communityCountryNamesPR => 'Puerto Rico';

  @override
  String get communityCountryNamesPT => 'Portugal';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Katar';

  @override
  String get communityCountryNamesRO => 'Rumänien';

  @override
  String get communityCountryNamesRS => 'Serbien';

  @override
  String get communityCountryNamesRU => 'Russland';

  @override
  String get communityCountryNamesSA => 'Saudi-Arabien';

  @override
  String get communityCountryNamesSE => 'Schweden';

  @override
  String get communityCountryNamesSG => 'Singapur';

  @override
  String get communityCountryNamesSI => 'Slowenien';

  @override
  String get communityCountryNamesSK => 'Slowakei';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Thailand';

  @override
  String get communityCountryNamesTL => 'Osttimor';

  @override
  String get communityCountryNamesTN => 'Tunesien';

  @override
  String get communityCountryNamesTR => 'Türkei';

  @override
  String get communityCountryNamesTW => 'Taiwan';

  @override
  String get communityCountryNamesUA => 'Ukraine';

  @override
  String get communityCountryNamesUS => 'Vereinigte Staaten';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Usbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'Südafrika';

  @override
  String get communityCreateLfg => 'Mitspielersuche erstellen';

  @override
  String get communityCreateLfgShort => 'Erstellen';

  @override
  String get communityDataDeleted => 'Deine Community-Daten wurden gelöscht.';

  @override
  String communityDataFooter(String riotId) {
    return 'Gilt für das aktive Konto: $riotId. Die heruntergeladene Datei enthält weder Passwörter noch Riot-Anmeldedaten.';
  }

  @override
  String get communityDecrease => 'Verringern';

  @override
  String get communityDelete => 'Löschen';

  @override
  String get communityDeleteComment => 'Kommentar löschen';

  @override
  String get communityDeleteCommentBody =>
      'Dieser Kommentar wird endgültig gelöscht.';

  @override
  String get communityDeleteCommentTitle => 'Kommentar löschen?';

  @override
  String get communityDeleteDataConfirm => 'Endgültig löschen';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Alle Beiträge, Kommentare, Skin-Bewertungen, Likes, Stimmen, Mitspielersuchen und Fotos von $riotId in der ValHub-Community werden endgültig gelöscht und können nicht wiederhergestellt werden. Um dieses Konto in ValHub weiter zu nutzen, musst du erneut zustimmen; du kannst aber zu einem anderen Konto wechseln oder dieses abmelden.\n\nDein Riot-Konto und deine Spieldaten sind nicht betroffen. Lade deine Daten vorher herunter, wenn du eine Kopie behalten willst.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Community-Daten löschen?';

  @override
  String get communityDeleteDataSubtitle =>
      'Löscht endgültig alles, was du in der Community gepostet hast.';

  @override
  String get communityDeleteDataTitle => 'Meine Community-Daten löschen';

  @override
  String get communityDeletePost => 'Beitrag löschen';

  @override
  String get communityDeletePostBody =>
      'Der Beitrag und alle Kommentare werden endgültig gelöscht.';

  @override
  String get communityDeletePostTitle => 'Beitrag löschen?';

  @override
  String get communityDeleteReview => 'Bewertung löschen';

  @override
  String get communityDeleteReviewBody =>
      'Deine Punktzahl und Rezension für diesen Skin werden gelöscht.';

  @override
  String get communityDeleteReviewTitle => 'Deine Bewertung löschen?';

  @override
  String get communityDeleted => 'Gelöscht.';

  @override
  String get communityDiscard => 'Verwerfen';

  @override
  String get communityDiscardBody =>
      'Dein gerade geschriebener Text wird nicht gespeichert.';

  @override
  String get communityDiscardTitle => 'Beitrag verwerfen?';

  @override
  String get communityDownload => 'Laden und übersetzen';

  @override
  String get communityDownloadingModels => 'Übersetzungspaket wird geladen …';

  @override
  String get communityEditReview => 'Bearbeiten';

  @override
  String get communityEdited => 'bearbeitet';

  @override
  String get communityEmptyPost => 'Schreib etwas oder füge ein Foto hinzu.';

  @override
  String get communityExpired => 'Abgelaufen';

  @override
  String communityExpiresIn(String t) {
    return 'Noch $t';
  }

  @override
  String get communityExportPreparing => 'Wird vorbereitet …';

  @override
  String get communityExportSubject => 'ValHub-Community-Daten';

  @override
  String get communityExportSubtitle =>
      'Eine Kopie von allem, was du in der Community gepostet hast: Beiträge, Kommentare, Bewertungen, Likes, Stimmen und Mitspielersuchen.';

  @override
  String get communityExportTitle => 'Meine Daten herunterladen';

  @override
  String get communityExtend => 'Verlängern';

  @override
  String get communityExtended => 'Suche um 30 Minuten verlängert.';

  @override
  String get communityFeedEmptyBody =>
      'Teile als Erster deinen Shop, deinen Nachtmarkt oder deine Highlights!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Keine passenden Beiträge. Ändere die Sprache oder entferne Filter.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Noch keine neuen Beiträge. Schau später wieder vorbei oder tritt bei, um selbst etwas zu teilen.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Sieh dir Beiträge der internationalen Community an oder ändere die Filter.';

  @override
  String get communityFeedEmptyScopeTitle =>
      'Noch keine Beiträge in diesem Bereich';

  @override
  String get communityFeedEmptyTitle => 'Der Feed ist noch leer';

  @override
  String get communityFilters => 'Filter';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Übersetzung von Google';

  @override
  String get communityHelpful => 'Hilfreich';

  @override
  String communityHelpfulCount(String n) {
    return 'Hilfreich · $n';
  }

  @override
  String get communityHiddenAuthors => 'Ausgeblendete und blockierte Personen';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Niemand ausgeblendet oder blockiert';

  @override
  String get communityHiddenAuthorsHint =>
      'Gilt nur für dieses Konto auf diesem Gerät. Ihre Inhalte werden ausgeblendet; sie können deine öffentlichen Inhalte weiterhin sehen.';

  @override
  String communityImageOf(int i, int n) {
    return 'Bild $i/$n';
  }

  @override
  String get communityIncrease => 'Erhöhen';

  @override
  String get communityJoin => 'Beitreten';

  @override
  String get communityJoinCodeExpired =>
      'Der Gruppencode ist abgelaufen oder nicht mehr gültig.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Du verlässt deine aktuelle Gruppe in VALORANT, um der Gruppe von $name beizutreten.';
  }

  @override
  String get communityJoinConfirmTitle => 'Dieser Gruppe beitreten?';

  @override
  String get communityJoinGameNotRunning =>
      'Öffne VALORANT auf deinem PC oder deiner Konsole und versuch es erneut.';

  @override
  String get communityJoinParty => 'Gruppe beitreten';

  @override
  String get communityJoinPartyFull => 'Diese Gruppe ist voll.';

  @override
  String get communityJoinedHint =>
      'Gruppe beigetreten! Öffne VALORANT, um zusammen zu spielen.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Beitrittsanfragen',
      one: '$nString Beitrittsanfrage',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Nachtmarkt';

  @override
  String get communityKindStore => 'Heutiger Shop';

  @override
  String get communityLanguage => 'Sprache';

  @override
  String get communityLanguageFilter => 'Inhaltssprache';

  @override
  String get communityLanguageFilterHint =>
      'Zeigt nur Inhalte in den gewählten Sprachen. Leer lassen, um alles zu sehen.';

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
      other: '$n Sprachen',
      one: '$n Sprache',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Erstelle eine Suche, damit andere Spieler mit einem Tippen deiner Gruppe beitreten können.';

  @override
  String get communityLfgEmptyTitle => 'Noch niemand sucht Mitspieler';

  @override
  String get communityLfgExpiredRepost =>
      'Deine Suche ist abgelaufen. Erstelle eine neue, um Mitspieler zu finden.';

  @override
  String get communityLfgGateBody =>
      'Tritt bei (einmalige Bestätigung deiner Riot ID), um Suchen von Spielern auf deinem Server zu sehen und selbst Mitspieler zu suchen. Feed und Skin-Rangliste kannst du weiterhin normal ansehen.';

  @override
  String get communityLfgGateTitle => 'Mitspielersuche nur für Mitglieder';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Du siehst den Server $region – nur Spieler auf dem Server deines Kontos können Gruppen beitreten.';
  }

  @override
  String get communityLfgPosted => 'Mitspielersuche gepostet!';

  @override
  String get communityLfgPreviewTitle => 'Mitspieler mit passendem Rang finden';

  @override
  String get communityLfgRemoved => 'Suche entfernt.';

  @override
  String get communityLfgSameShardNote =>
      'Nur Spieler auf demselben Server können der Gruppe beitreten.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Region: $region · Suchen laufen nach 30 Minuten ab.';
  }

  @override
  String get communityLike => 'Gefällt mir';

  @override
  String get communityLiveMembers => 'Mitglieder';

  @override
  String get communityMatchMyRank => 'Passt zu deinem Rang';

  @override
  String communityMemberJoined(String name) {
    return '$name ist der Gruppe beigetreten';
  }

  @override
  String get communityMemberJoinedBody =>
      'Jemand ist über deine Mitspielersuche beigetreten.';

  @override
  String get communityMic => 'Mic nötig';

  @override
  String get communityMicOn => 'Mit Mic';

  @override
  String get communityMode => 'Modus';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Weitere Optionen';

  @override
  String get communityMuteAuthor => 'Diese Person ausblenden';

  @override
  String get communityNewPost => 'Posten';

  @override
  String communityNightMarketOf(String date) {
    return 'Nachtmarkt vom $date';
  }

  @override
  String get communityNoAccountBody =>
      'Füge ein Riot-Konto hinzu, um zu posten, Mitspieler zu suchen und für Skins abzustimmen.';

  @override
  String get communityNoAccountTitle => 'Zum Mitmachen anmelden';

  @override
  String get communityNoComments =>
      'Noch keine Kommentare. Schreib den ersten!';

  @override
  String get communityNoRatings => 'Noch keine Bewertungen';

  @override
  String get communityNote => 'Notiz';

  @override
  String get communityNoteHint =>
      'z. B.: 1 Taktiker gesucht, mit Mic, Spaß steht im Vordergrund';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Gesamt $amount';
  }

  @override
  String get communityOpenReviews => 'Bewertungen ansehen';

  @override
  String get communityOutOfRange => 'Außerhalb des Rangbereichs';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Gruppencode';

  @override
  String get communityPartyCodeHint => 'z. B. A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Gruppencode: $code';
  }

  @override
  String get communityPartySize => 'Aktuelle Gruppe';

  @override
  String get communityPartySizeFromGame => 'Aus der Gruppe im Spiel übernehmen';

  @override
  String communityPartySizeValue(int n) {
    return '$n Spieler';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return 'Fotos: $n/$max';
  }

  @override
  String get communityPlayVideo => 'Video ansehen';

  @override
  String get communityPostLfg => 'Posten';

  @override
  String get communityPostNotFound =>
      'Dieser Beitrag wurde gelöscht oder ausgeblendet.';

  @override
  String get communityPostTitle => 'Beitrag';

  @override
  String get communityPosted => 'Beitrag gepostet!';

  @override
  String get communityPublish => 'Posten';

  @override
  String get communityPublishing => 'Wird gepostet …';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Von';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Rangbereich';

  @override
  String get communityRankRangeInvalid =>
      'Der niedrigste Rang darf nicht höher als der höchste Rang sein.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Platz $n: $name';
  }

  @override
  String get communityRankTo => 'Bis';

  @override
  String get communityRateLimitedTitle => 'Warte einen Moment';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Bewertungen',
      one: '$nString Bewertung',
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
      other: '$nString Bewertungen',
      one: '$nString Bewertung',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Schlecht';

  @override
  String get communityRatingWordsItem1 => 'Naja';

  @override
  String get communityRatingWordsItem2 => 'Okay';

  @override
  String get communityRatingWordsItem3 => 'Schön';

  @override
  String get communityRatingWordsItem4 => 'Meisterwerk';

  @override
  String get communityRefreshList => 'Aktualisieren';

  @override
  String get communityRegion => 'Region';

  @override
  String get communityRemoveAttachment => 'Anhang entfernen';

  @override
  String get communityRemoveLfg => 'Suche entfernen';

  @override
  String get communityRemoveLfgBody =>
      'Andere sehen diese Suche dann nicht mehr.';

  @override
  String get communityRemoveLfgTitle => 'Mitspielersuche entfernen?';

  @override
  String get communityRemovePhoto => 'Foto entfernen';

  @override
  String get communityReport => 'Melden';

  @override
  String get communityReportConfirmBody =>
      'Inhalte, die von vielen gemeldet werden, werden in der Community ausgeblendet.';

  @override
  String get communityReportConfirmTitle => 'Meldung senden?';

  @override
  String get communityReportPrompt => 'Warum meldest du diesen Inhalt?';

  @override
  String get communityReportReasonsSpam => 'Spam oder Werbung';

  @override
  String get communityReportReasonsHarassment => 'Belästigung, Beleidigung';

  @override
  String get communityReportReasonsInappropriate => 'Unangemessener Inhalt';

  @override
  String get communityReportReasonsScam => 'Betrug, Kontohandel';

  @override
  String get communityReportReasonsOther => 'Anderer Grund';

  @override
  String get communityReportTitle => 'Inhalt melden';

  @override
  String get communityReported => 'Danke! Deine Meldung wurde gesendet.';

  @override
  String get communityReviewDeleted => 'Bewertung gelöscht.';

  @override
  String get communityReviewHint => 'Was hältst du von diesem Skin? (optional)';

  @override
  String get communityReviewSaved => 'Bewertung gespeichert!';

  @override
  String get communityReviewTitle => 'Skin bewerten';

  @override
  String get communityReviewsEmptyBody =>
      'Noch keine Bewertungen – sei der Erste!';

  @override
  String get communityReviewsEmptyTitle => 'Noch keine Bewertungen';

  @override
  String communityReviewsHeader(String n) {
    return 'Bewertungen · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Probleme bei Riot';

  @override
  String get communityRoleFlex => 'Flexibel';

  @override
  String get communityRoles => 'Gesuchte Rollen';

  @override
  String get communitySaveReview => 'Bewertung speichern';

  @override
  String get communityScopeCountry => 'Dein Land';

  @override
  String get communityScopeGlobal => 'International';

  @override
  String get communityScopeRegion => 'Region';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Teamsuche';

  @override
  String get communitySectionSkins => 'Skin-Ranking';

  @override
  String get communitySend => 'Senden';

  @override
  String get communitySendComment => 'Kommentar senden';

  @override
  String get communityShareNightMarketHint => 'Zeig allen deinen Nachtmarkt';

  @override
  String communitySharePostTitle(String name) {
    return 'Beitrag von $name auf ValHub';
  }

  @override
  String get communityShareStore => 'In der Community zeigen';

  @override
  String get communityShareStoreHint => 'Zeig allen deinen heutigen Shop';

  @override
  String get communityShowOriginal => 'Original anzeigen';

  @override
  String get communityShowTranslation => 'Übersetzung anzeigen';

  @override
  String get communitySignInToReview =>
      'Füge ein Riot-Konto hinzu, um Skins zu bewerten.';

  @override
  String get communitySkinNotFound => 'Dieser Skin wurde nicht gefunden.';

  @override
  String get communitySlots => 'Gesuchte Spieler';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Eine Gruppe hat maximal 5 Spieler: nur noch $max Plätze frei.',
      one: 'Eine Gruppe hat maximal 5 Spieler: nur noch $max Platz frei.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    return '$n Spieler gesucht';
  }

  @override
  String get communitySortHelpful => 'Hilfreichste';

  @override
  String get communitySortNewest => 'Neueste';

  @override
  String get communitySortRating => 'Beste Bewertung';

  @override
  String get communitySortReviews => 'Meiste Bewertungen';

  @override
  String get communitySortVotes => 'Beliebteste';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sterne',
      one: '$n Stern',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg von 5 Sternen';
  }

  @override
  String get communityStatusFull => 'Voll';

  @override
  String get communityStatusInGame => 'Im Match';

  @override
  String get communityStatusOpen => 'Sucht';

  @override
  String communityStoreOf(String date) {
    return 'Shop vom $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate =>
      'Tippe auf die Sterne, um diesen Skin zu bewerten';

  @override
  String get communityTitle => 'Community';

  @override
  String communityTooLong(int max) {
    return 'Maximal $max Zeichen.';
  }

  @override
  String get communityTranslate => 'Mit Google übersetzen';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Um von $from nach $to zu übersetzen, muss ValHub ein Sprachpaket von Google laden (ca. $size). Das passiert nur einmal; die Übersetzung läuft komplett auf deinem Gerät und nichts wird an einen Server gesendet.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Übersetzungspaket aufs Gerät laden?';

  @override
  String get communityTranslateFailed =>
      'Übersetzung fehlgeschlagen. Versuch es erneut.';

  @override
  String get communityTranslatedByGoogle => 'Automatisch übersetzt von Google';

  @override
  String get communityTranslating => 'Wird übersetzt …';

  @override
  String get communityTrendingTitle => 'Weltweit beliebte Skins';

  @override
  String get communityUnavailableBody =>
      'Keine Verbindung zur ValHub-Community. Versuch es in ein paar Minuten erneut.';

  @override
  String get communityUnavailableTitle => 'Keine Verbindung zur Community';

  @override
  String get communityUnhideAuthor => 'Einblenden / Blockierung aufheben';

  @override
  String get communityUnknownPlayer => 'Spieler';

  @override
  String get communityUnlike => 'Gefällt mir nicht mehr';

  @override
  String get communityUnvote => 'Herz entfernen';

  @override
  String get communityVote => 'Diesem Skin ein Herz geben';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Herzen',
      one: '$nString Herz',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Widerrufen';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub nutzt die Community nicht mehr mit $riotId und entfernt die Community-Verbindung auf diesem Gerät. Um dieses Konto in ValHub weiter zu nutzen, musst du erneut zustimmen; du kannst aber zu einem anderen Konto wechseln oder dieses abmelden.\n\nBereits gepostete Beiträge, Kommentare, Bewertungen, Stimmen und Mitspielersuchen bleiben in der Community und zeigen weiterhin deine Riot ID, bis du sie einzeln löschst oder „Meine Community-Daten löschen“ wählst.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Zustimmung widerrufen?';

  @override
  String get communityWithdrawSubtitle =>
      'Community mit diesem Konto nicht mehr nutzen. Deine Beiträge bleiben erhalten.';

  @override
  String get communityWithdrawTitle => 'Zustimmung widerrufen';

  @override
  String get communityWriteFirstReview => 'Erste Bewertung schreiben';

  @override
  String get communityYou => 'Du';

  @override
  String get communityYourCountry => 'Dein Land';

  @override
  String get communityYourReview => 'Deine Bewertung';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString Personen ausgeblendet',
      one: '$nString Person ausgeblendet',
    );
    return '$_temp0';
  }

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Du: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'In der Agentenauswahl';

  @override
  String get liveGameAnonymous => 'Anonym';

  @override
  String get liveGameAutoRefreshNote =>
      'Wird automatisch aktualisiert, sobald ein Match läuft.';

  @override
  String get liveGameCurrentGame => 'Aktuelles Match';

  @override
  String get liveGameEmptyTeam => 'Noch keine Spieler.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Das gegnerische Team wird angezeigt, sobald das Match beginnt.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Gegner festgelegt: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Diese Live-Match-Quelle liefert keine Kills/Tode/Assists. Die Anzeigetafel erscheint, sobald Riot die Daten nach dem Match veröffentlicht.';

  @override
  String get liveGameFinalScoreboard => 'Endstand-Anzeigetafel';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'In der Lobby';

  @override
  String get liveGameInMatch => 'Im Match';

  @override
  String get liveGameInQueue => 'In der Warteschlange';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'In der Warteschlange · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Stufe $n';
  }

  @override
  String get liveGameLiveScore => 'Live-Spielstand';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Loadout aus der Agentenauswahl';

  @override
  String get liveGameLoadoutFromMatch => 'Loadout in diesem Match';

  @override
  String get liveGameLobbyHint =>
      'Sobald ein Match gefunden ist, zeigt ValHub Aufstellungen und Ränge aller Spieler.';

  @override
  String get liveGameLockedTag => 'Festgelegt';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub versucht es automatisch erneut. Die Anzeigetafel ist meist nach etwa einer Minute da.';

  @override
  String get liveGameNoAgentYet => 'Noch kein Agent gewählt';

  @override
  String get liveGameNoLoadout => 'Keine Loadout-Infos für diesen Spieler.';

  @override
  String get liveGameNotInGame => 'Nicht im Match';

  @override
  String get liveGameNotInGameHint =>
      'Öffne VALORANT und such ein Match – die Matchdetails erscheinen hier automatisch, sobald du in der Agentenauswahl bist.';

  @override
  String get liveGameNotInGameTitle => 'Du bist in keinem Match';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Loadout von $name ansehen';
  }

  @override
  String get liveGameOpenParty => 'Gruppe & Warteschlange öffnen';

  @override
  String get liveGameParty => 'Gruppe';

  @override
  String liveGamePeak(String rank) {
    return 'Höchster: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Loadout von $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Loadout';

  @override
  String get liveGameQueueHint =>
      'Lass die App offen – die Matchdetails erscheinen, sobald ein Match gefunden ist.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Wenn du das Match verlässt, kannst du bestraft werden (RR-Verlust, Warteschlangensperre). Trotzdem verlassen?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Wenn du in der Agentenauswahl dodgst, kannst du bestraft werden (RR-Verlust, Warteschlangensperre). Trotzdem verlassen?';

  @override
  String get liveGameQuitConfirmTitle => 'Match verlassen?';

  @override
  String get liveGameQuitDone => 'Match verlassen.';

  @override
  String get liveGameQuitFailed => 'Match konnte nicht verlassen werden.';

  @override
  String get liveGameQuitMatch => 'Match verlassen';

  @override
  String get liveGameQuitMatchChanged =>
      'Das Match ist während deiner Bestätigung in eine andere Phase gewechselt. Du hast es nicht verlassen – versuch es erneut.';

  @override
  String get liveGameRankUnavailable => 'Rang unbekannt';

  @override
  String get liveGameRefresh => 'Aktualisieren';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Automatische Aktualisierung in $seconds Sekunden',
      one: 'Automatische Aktualisierung in $seconds Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Jetzt aktualisieren';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Matchdetails';

  @override
  String get liveGameSprays => 'Sprays';

  @override
  String get liveGameStatusAgentSelect => 'Agentenauswahl';

  @override
  String get liveGameStatusEnded => 'Beendet';

  @override
  String get liveGameStatusInProgress => 'Läuft';

  @override
  String get liveGameStatusUnavailable =>
      'Matchstatus konnte nicht aktualisiert werden';

  @override
  String get liveGameTabAllPlayers => 'Spieler';

  @override
  String get liveGameTabEnemyTeam => 'Gegnerteam';

  @override
  String get liveGameTabYourTeam => 'Dein Team';

  @override
  String liveGameTimeLeft(String t) {
    return 'Noch $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Matchdetails ansehen';

  @override
  String get liveGameWeapons => 'Waffen';

  @override
  String get liveGameYou => 'DU';

  @override
  String liveGameYouHover(String agent) {
    return 'Du wählst $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Du hast $agent festgelegt';
  }

  @override
  String get liveGamePickInGame =>
      'Wähle und bestätige deinen Agenten in VALORANT. ValHub zeigt nur die verbleibende Zeit und dein Team.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins Siege',
      one: '$wins Sieg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses Niederlagen',
      one: '$losses Niederlage',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws Unentschieden',
      one: ' – $draws Unentschieden',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown Matches mit unbekanntem Ergebnis',
      one: ' – $unknown Match mit unbekanntem Ergebnis',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'Gerätezeit ($offset)';
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
      'yes': ' mit $weapon',
      'other': '',
    });
    return '$killer eliminiert $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 Tage',
      'days7': '7 Tage',
      'other': 'Gesamt',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agenten',
      'maps': 'Karten',
      'queues': 'Modi',
      'sides': 'Angriff / Verteidigung',
      'trend': 'Trend',
      'other': 'Modi',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Alle Modi';

  @override
  String get profileAbility => 'Fähigkeit';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n Matches',
      one: '≈ $n Match',
    );
    return '$_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Durchschnittlicher Kampfwert';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins Siege',
      one: '$wins Sieg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games Matches',
      one: '$games Match',
    );
    return 'Dieser Akt: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Alle Spieler';

  @override
  String get profileAlreadyReached => 'Du hast diesen Rang bereits erreicht.';

  @override
  String get profileAtCurrentForm => 'Bei aktueller Form';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Bei aktueller Form ($gain / $loss pro Match)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Bestenfalls: $n Siege in Folge',
      one: 'Bestenfalls: $n Sieg',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Nach Siegquote';

  @override
  String get profileChooseMap => 'Nach Karte filtern';

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
  String get profileCopyRiotId => 'Riot ID kopieren';

  @override
  String get profileCurrentRank => 'Aktuell';

  @override
  String get profileDailyRrEmpty =>
      'Auf diesem Gerät ist noch kein gewertetes Match gespeichert.';

  @override
  String get profileDailyRrFootnote =>
      'Der RR-Verlauf wird direkt auf deinem Gerät gespeichert – auch Matches, die Riot nicht mehr liefert.';

  @override
  String get profileDailyRrTitle => 'RR pro Tag';

  @override
  String profileDayBoundary(String zone) {
    return 'Tageswechsel nach $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Tage mit Matches',
      one: '$n Tag mit Matches',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Alle Matches werden angezeigt';

  @override
  String get profileEnemyTeam => 'Gegnerteam';

  @override
  String get profileFallDamage => 'Fallschaden';

  @override
  String get profileFilterAll => 'Alle';

  @override
  String get profileFirstBloods => 'First Bloods';

  @override
  String get profileFirstDeaths => 'Erste Tode';

  @override
  String get profileFirstHalf => '1. Halbzeit';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS und HS% zählen nur in rundenbasierten Modi.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '$n Matches in der Liste wurden noch nicht zur Berechnung geladen.',
      one: '$n Match in der Liste wurde noch nicht zur Berechnung geladen.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR, HS% nur aus rundenbasierten Matches ($roundGames/$games)';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w Siege',
      one: '$w Sieg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l Niederlagen',
      one: '$l Niederlage',
    );
    return 'Letzte Matches: $games – $_temp0, $_temp1';
  }

  @override
  String get profileFriendsRow => 'Freunde & Chat';

  @override
  String get profileHideKills => 'Kills ausblenden';

  @override
  String get profileHitBody => 'Körper';

  @override
  String get profileHitDistribution => 'Trefferverteilung';

  @override
  String get profileHitHead => 'Kopf';

  @override
  String get profileHitLegs => 'Beine';

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
      'Anteil der Runden, in denen du einen Kill oder Assist hattest, überlebt hast oder von einem Teammitglied gerächt wurdest';

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
      other: 'Letzte $n Tage',
      one: 'Letzter $n Tag',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Letzte $n Matches',
      one: 'Letztes $n Match',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Rangliste #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Stufe $n';
  }

  @override
  String get profileLevelHidden => 'Stufe verborgen';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Niederlagen in Folge',
      one: '$n Niederlage in Folge',
    );
    return '$_temp0';
  }

  @override
  String profileMapFilter(String map) {
    return 'Karte: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Matches',
      one: '$n Match',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Matchdetails';

  @override
  String get profileMatchHistory => 'Matchverlauf';

  @override
  String get profileMatchUnavailable => 'Match konnte nicht geladen werden';

  @override
  String get profileMatchesNeeded => 'Nötige Matches';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Nie gewertet gespielt';

  @override
  String get profileNoKillsInRound => 'Keine Kill-Infos für diese Runde.';

  @override
  String get profileNoMatches => 'Noch keine Matches.';

  @override
  String get profileNoMatchesMap => 'Keine geladenen Matches auf dieser Karte.';

  @override
  String get profileNoMatchesQueue => 'Keine Matches in diesem Modus.';

  @override
  String get profileNoPlayers => 'Keine Spielerinfos für dieses Match.';

  @override
  String get profileNoRounds => 'Keine Rundeninfos für dieses Match.';

  @override
  String get profileOvertime => 'Verlängerung';

  @override
  String get profilePlayHubTitle => 'Match & Gruppe';

  @override
  String get profilePeakRank => 'Höchster Rang';

  @override
  String get profilePerformanceAttack => 'Angriff';

  @override
  String get profilePerformanceDefense => 'Verteidigung';

  @override
  String get profilePerformanceEmpty =>
      'Auf diesem Gerät sind noch keine Matches erfasst. Öffne den Matchverlauf, um deine gespielten Matches zu erfassen.';

  @override
  String get profilePerformanceNoMatches =>
      'Keine Matches im gewählten Zeitraum.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Runden erfasst',
      one: '$n Runde erfasst',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Quoten werden erst ab 3 Matches angezeigt. ACS, ADR, HS% und K/D zählen nur in rundenbasierten Modi.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Angriff oder Verteidigung in $known/$total Runden bestimmt.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Verlauf auf dem Gerät, seit $date';
  }

  @override
  String get profilePerformanceTitle => 'Leistung';

  @override
  String profilePlacement(int n) {
    return 'Platz $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike auf $site platziert';
  }

  @override
  String get profilePlayerProfileTitle => 'Spielerprofil';

  @override
  String get profilePlayerSummary => 'Bilanz';

  @override
  String profileProgressTo(String rank) {
    return 'Fortschritt bis $rank';
  }

  @override
  String get profileProgressToTarget => 'Fortschritt bis zum Zielrang';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Schätzung anhand deiner letzten gewerteten Matches, ohne Platzierungsmatches und Abstiegsschutz.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches Matches bis $rank',
      one: '≈ $matches Match bis $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'Du bist bereits Unsterblich oder höher – dieser Rechner geht nur bis Unsterblich 1.';

  @override
  String get profileRankUpNoForm =>
      'Keine aktuellen gewerteten Matches, um deine Form zu schätzen.';

  @override
  String get profileRankUpOpen => 'Aufstiegsrechner öffnen';

  @override
  String get profileRankUpTitle => 'Aufstiegsrechner';

  @override
  String get profileRankUpUnranked =>
      'Schließe deine Platzierungsmatches ab, um den Aufstiegsrechner zu nutzen.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Gewertete Anzeigetafel';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w Siege',
      one: '$w Sieg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l Niederlagen',
      one: '$l Niederlage',
    );
    return 'Aktuelle Form: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Aktuelle Form';

  @override
  String get profileRecentMatches => 'Letzte Matches';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}S · ${l}N · ${d}U',
      one: '${w}S · ${l}N · ${d}U',
      zero: '${w}S · ${l}N',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID kopiert';

  @override
  String profileRound(int n) {
    return 'Runde $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Kills',
      one: '$n Kill',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Runde verloren';

  @override
  String get profileRoundTimeline => 'Rundenverlauf';

  @override
  String get profileRoundWon => 'Runde gewonnen';

  @override
  String get profileRoundsHint =>
      'Tippe auf eine Runde, um die einzelnen Kills zu sehen.';

  @override
  String profileRrLeft(String n) {
    return 'Noch $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR-Verlauf';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Anzeigetafel';

  @override
  String get profileSecondHalf => '2. Halbzeit';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Kills anzeigen';

  @override
  String get profileSideSwitch => 'Seitenwechsel';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Zielrang';

  @override
  String get profileTeamBlue => 'Team Blau';

  @override
  String get profileTeamMvp => 'Team-MVP';

  @override
  String get profileTeamRed => 'Team Rot';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileToday(String text) {
    return 'Heute: $text';
  }

  @override
  String get profileTodayNone => 'Heute noch kein gewertetes Match';

  @override
  String get profileTruePeakLocal => 'Laut Verlauf auf dem Gerät';

  @override
  String get profileWeekdayShortItem0 => 'Mo';

  @override
  String get profileWeekdayShortItem1 => 'Di';

  @override
  String get profileWeekdayShortItem2 => 'Mi';

  @override
  String get profileWeekdayShortItem3 => 'Do';

  @override
  String get profileWeekdayShortItem4 => 'Fr';

  @override
  String get profileWeekdayShortItem5 => 'Sa';

  @override
  String get profileWeekdayShortItem6 => 'So';

  @override
  String get profileWinRate => 'Siegquote';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Siege in Folge',
      one: '$n Sieg in Folge',
    );
    return '$_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Dein Rang';

  @override
  String get profileYourSummary => 'Deine Bilanz';

  @override
  String get profileYourTeam => 'Dein Team';

  @override
  String get profileYourWinRate => 'Deine aktuelle Siegquote';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Modus: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Nach Modus filtern';

  @override
  String get profilePerformancePerMatchTitle => 'Pro Match';

  @override
  String get profilePerformancePerMatchHint =>
      'Tippe auf einen Balken, um das Match zu öffnen.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Durchschnitt $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Für das Diagramm brauchst du mindestens 2 rundenbasierte Matches mit diesem Wert.';

  @override
  String get profilePerformanceOpeningsTitle => 'Eröffnungsduelle';

  @override
  String get profilePerformanceOpeningWin => 'Eröffnungsduelle gewonnen';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Von den Runden, in denen du den ersten Kill geholt hast oder zuerst gestorben bist: wie oft du den Kill geholt hast.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'First Bloods pro Match';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Erste Tode pro Match';

  @override
  String get profilePerformanceMultiKillsTitle => 'Multi-Kills in einer Runde';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 Kills',
      'k4': '4 Kills',
      'ace': 'Ace',
      'other': '2 Kills',
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
      other: 'Basierend auf $nString Matches mit vollständigen Kill-Daten.',
      one: 'Basierend auf $nString Match mit vollständigen Kill-Daten.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Rundensiegquote';

  @override
  String get profilePerformanceDrillHint =>
      'Tippe auf eine Zeile, um nur diesen Agenten, diese Karte oder diesen Modus zu sehen.';

  @override
  String get profilePerformanceLoadOlder => 'Ältere Matches analysieren';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          'ValHub analysiert nur Matches, die auf diesem Gerät geöffnet wurden. Jedes Tippen fügt bis zu $nString ältere Matches hinzu.',
      one:
          'ValHub analysiert nur Matches, die auf diesem Gerät geöffnet wurden. Jedes Tippen fügt bis zu $nString älteres Match hinzu.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Suche ältere Matches…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analysiere Matches: $doneString/$totalString…';
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
      other: '$nString Matches zur Analyse hinzugefügt.',
      one: '$nString Match zur Analyse hinzugefügt.',
      zero: 'Keine neuen Matches zum Hinzufügen.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot speichert keine älteren Matches mehr.';

  @override
  String get profileEconomyTitle => 'Wirtschaft deines Teams';

  @override
  String get profileEconomyHint =>
      'Kauftyp nach dem Gesamtwert der Ausrüstung deines Teams zu Rundenbeginn (vlr.gg-Konvention für 5 Spieler): Eco unter 5.000, Semi-eco unter 10.000, Semi-buy unter 20.000, Full buy ab 20.000 Credits. Die erste Runde jeder Halbzeit ist Pistol.';

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

    return 'Gewonnen $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => 'Letzte Session';

  @override
  String profileSessionDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString Std. $minutesString Min.';
  }

  @override
  String profileSessionTopAgent(String agent, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Am meisten: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      'Dein VALORANT-Begleiter: täglicher Shop, Wishlist, Rang, Matches, mehrere Konten und eine Spieler-Community – direkt auf deinem Gerät.';

  @override
  String get legalBackToTop => 'Nach oben';

  @override
  String get legalConsentAnd => ' und der ';

  @override
  String get legalConsentPrefix => 'Indem du fortfährst, stimmst du den ';

  @override
  String get legalConsentPrivacy => 'Datenschutzerklärung';

  @override
  String get legalConsentSuffix => ' von ValHub zu.';

  @override
  String get legalConsentTerms => 'Nutzungsbedingungen';

  @override
  String get legalContact => 'Kontakt';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'KONTAKT';

  @override
  String legalEffectiveFrom(String date) {
    return 'Gültig ab $date';
  }

  @override
  String get legalLegalHeader => 'RECHTLICHES';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Alle Rechte vorbehalten.';

  @override
  String get legalThirdPartyLicenses => 'Software von Drittanbietern';

  @override
  String get legalThirdPartyLicensesBody =>
      'Lizenzen der Open-Source-Software, die ValHub verwendet';

  @override
  String get legalTocTitle => 'INHALT';

  @override
  String legalVersion(String version) {
    return 'Version $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Sprache, in der dieses Dokument derzeit angezeigt wird: $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Das rechtliche Dokument konnte nicht gelesen werden. Versuch es erneut oder wende dich an den Support.';

  @override
  String get legalTranslationNotice =>
      'Diese Übersetzung dient nur der Lesbarkeit. Bei Abweichungen gilt die vietnamesische Fassung.';

  @override
  String get settingsUiLanguageTitle => 'Sprache der Oberfläche';

  @override
  String get settingsLanguageFollowDevice => 'Wie Gerät';

  @override
  String get settingsLanguageSaveFailed =>
      'Sprache konnte nicht gespeichert werden. Versuch es erneut.';

  @override
  String get settingsGeoCountry => 'Land';

  @override
  String get settingsGeoSearchCountry => 'Ländername oder -code suchen';

  @override
  String get settingsGeoSupportedOnly => 'Nur bestätigt unterstützte Orte';

  @override
  String get settingsGeoUnknown => 'Unterstützung nicht bestätigt';

  @override
  String get settingsGeoRestricted => 'Eingeschränkt';

  @override
  String get settingsGeoSeparate => 'Eigener Dienst';

  @override
  String get settingsGeoAvailable => 'Unterstützt';

  @override
  String get settingsGeoNotApplicable => 'Nicht zutreffend';

  @override
  String get settingsGeoConnection => 'Riot-Verbindung';

  @override
  String get settingsGeoChooseRegion => 'Region wählen';

  @override
  String get settingsGeoAuto => 'Automatisch nach Konto';

  @override
  String get settingsGeoManual => 'Manuell wählen';

  @override
  String get settingsGeoNoRegion => 'Riot-Region konnte nicht ermittelt werden';

  @override
  String get settingsGeoManualWarning =>
      'Diese Auswahl ändert nur den Server, mit dem sich ValHub verbindet. Die Region deines Riot-Kontos wird dadurch nicht geändert. ValHub prüft die Verbindung vor dem Speichern.';

  @override
  String get settingsGeoConnectionSaved => 'Verbindung gespeichert';

  @override
  String get settingsGeoValidationFailed =>
      'Das Konto wurde auf diesem Server nicht bestätigt. Wähle die Region erneut.';

  @override
  String get settingsGeoHintOnly =>
      'Das Land dient nur zum Nachschlagen und für Vorschläge. Die Verbindungsregion richtet sich nach deinem Riot-Konto.';

  @override
  String get settingsGeoSave => 'Prüfen und speichern';

  @override
  String get settingsGeoCancel => 'Abbrechen';

  @override
  String get settingsGeoLoading => 'Verbindung wird geprüft …';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Diese Auswahl gilt für Ländernamen, Vorschläge und geschätzte VP-Preise. Den Verbindungsserver und das Land deines Community-Kontos legt weiterhin Riot fest.';

  @override
  String get settingsGeoCountryAutomatic =>
      'Land von Konto oder Gerät verwenden';

  @override
  String get settingsGeoSaveFailed =>
      'Auswahl konnte nicht gespeichert werden. Versuch es erneut.';

  @override
  String get settingsGeoAllRegions => 'Alle Regionen';

  @override
  String get settingsGeoSuggestions => 'Vorschläge';

  @override
  String get settingsGeoNoCountries => 'Kein Land passt zum Filter.';

  @override
  String get settingsGeoActiveCountries => 'Aktiv';

  @override
  String get settingsGeoAllCountries => 'Alle Länder';

  @override
  String get settingsGeoActivityUnavailable =>
      'Die Aktivität der Länder konnte nicht geladen werden. Du kannst trotzdem unter Alle Länder wählen.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Länder',
      one: '$count Land',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Du hast $manual gewählt, aber laut Riot ist dein Konto in $detected. Diese Verbindung trotzdem prüfen?';
  }

  @override
  String get settingsGeoUnverified =>
      'Die Verbindung konnte wegen eines Server- oder Netzwerkfehlers nicht geprüft werden. Auswahl speichern und später erneut versuchen?';

  @override
  String get settingsGeoContinue => 'Weiter';

  @override
  String settingsGeoMismatch(String region) {
    return 'Die manuelle Verbindung weicht von deiner Riot-Region ab: $region. Automatische Region verwenden?';
  }

  @override
  String get settingsGeoUseAuto => 'Automatisch nutzen';

  @override
  String get settingsGeoKeepManual => 'Manuell behalten';

  @override
  String get settingsGeoReviewConnection => 'Verbindung ansehen';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Zuletzt geprüft: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Erneut prüfen';

  @override
  String get settingsPlatformMobile => 'Mobil';

  @override
  String get settingsPlatformOther => 'Andere Plattform';

  @override
  String get settingsContentLanguageFollowApp => 'Wie App-Sprache';

  @override
  String get settingsContentLanguageHint =>
      'Wähle die Sprache der Gegenstandsnamen. Das ändert weder die Sprache der Oberfläche noch den Riot-Server.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Sprache: $language.';
  }

  @override
  String get settingsAboutRowSubtitle =>
      'Datenschutz, Bedingungen, Urheberrecht und Kontakt';

  @override
  String get settingsAboutTitle => 'Über & Rechtliches';

  @override
  String get settingsAppearanceHeader => 'DARSTELLUNG';

  @override
  String settingsBuildNumber(String build) {
    return 'Build $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '$size gelöscht';
  }

  @override
  String get settingsClearCache => 'Temporäre Daten löschen';

  @override
  String get settingsClearCacheFailed =>
      'Temporäre Daten konnten nicht gelöscht werden. Versuch es erneut.';

  @override
  String get settingsClearCacheSubtitle =>
      'Heruntergeladene Bilder und Daten, inklusive gespeicherter Fehlerberichte';

  @override
  String get settingsExportLog => 'Fehlerbericht an ValHub senden';

  @override
  String get settingsExportLogEmpty =>
      'Noch nichts zu senden. Nutze die App eine Weile und versuch es dann erneut.';

  @override
  String get settingsExportLogSubtitle =>
      'Der Fehlerbericht enthält weder dein Passwort noch deine Riot-Anmeldedaten.';

  @override
  String get settingsFeedback => 'Feedback an ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Feedback-Seite von ValHub öffnen';

  @override
  String get settingsItemLanguageEn => 'Englisch';

  @override
  String get settingsItemLanguageLabel => 'Gegenstandsnamen';

  @override
  String get settingsItemLanguagePickerTitle => 'Sprache der Gegenstandsnamen';

  @override
  String get settingsItemLanguageVi => 'Vietnamesisch';

  @override
  String get settingsLinkOpenFailed =>
      'Link konnte nicht geöffnet werden. Versuch es erneut.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version – Fehlerbericht';
  }

  @override
  String get settingsLogShareFailed =>
      'Fehlerbericht konnte nicht gesendet werden. Versuch es erneut.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Wenn der Nachtmarkt öffnet';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Erinnert dich, deine Nachtmarkt-Angebote aufzudecken';

  @override
  String get settingsNotifPermissionMissing =>
      'Die App darf noch keine Benachrichtigungen senden.';

  @override
  String get settingsNotifStoreReset => 'Wenn der Shop sich erneuert';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Täglich um $time';
  }

  @override
  String get settingsNotifWishlist => 'Wenn ein Wishlist-Skin auftaucht';

  @override
  String get settingsNotificationsHeader => 'BENACHRICHTIGUNGEN';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Matchdetails automatisch öffnen';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Öffnet das aktuelle Match, sobald eins gefunden wurde';

  @override
  String get settingsOptionOwnPrice => 'Preis deines VP-Pakets';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Nicht eingegeben – nutzt die Preisliste deiner Region, falls vorhanden';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Plattform';

  @override
  String get settingsOptionShowLiveScore => 'Live-Spielstand anzeigen';

  @override
  String get settingsOptionShowPeakRank =>
      'Höchsten Rang in den Matchdetails anzeigen';

  @override
  String get settingsOptionShowPrice => 'Geschätzten Umrechnungspreis anzeigen';

  @override
  String get settingsOptionShowPriceInfo => 'So wird umgerechnet';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Neben VP-Preisen, z. B. $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Für deine Region gibt es noch keine bestätigte Preisliste – gib den Preis deines VP-Pakets ein.';

  @override
  String get settingsOptionsHeader => 'OPTIONEN';

  @override
  String get settingsPhaseComplete => 'Abgeschlossen';

  @override
  String get settingsPhaseInProgress => 'Läuft';

  @override
  String get settingsPhaseScheduled => 'Geplant';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Gilt für $account';
  }

  @override
  String get settingsPlatformHint =>
      'Wähle PC, PlayStation oder Xbox – je nachdem, wo du spielst –, um den richtigen Matchverlauf zu sehen.';

  @override
  String get settingsPlatformPickerTitle => 'Plattform wählen';

  @override
  String get settingsPrimingBody =>
      'Aktiviere Benachrichtigungen, um zu erfahren, wann sich der Shop erneuert und wann Skins aus deiner Wishlist auftauchen.';

  @override
  String get settingsPrimingEnable => 'Benachrichtigungen aktivieren';

  @override
  String get settingsPrimingFootnote =>
      'Du kannst jede Art von Benachrichtigung jederzeit in den Einstellungen ein- oder ausschalten.';

  @override
  String get settingsPrimingLater => 'Später';

  @override
  String get settingsPrimingPointNightMarket =>
      'Erfahre, wann der Nachtmarkt öffnet';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Damit du deine Angebote rechtzeitig aufdeckst';

  @override
  String get settingsPrimingPointStore =>
      'Erinnerung, wenn sich der tägliche Shop erneuert';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Erinnert dich, nachdem sich der Shop eines Kontos erneuert hat';

  @override
  String get settingsPrimingPointWishlist =>
      'Meldet, wenn deine Wunsch-Skins auftauchen';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Prüft die Shops aller Konten, auch wenn du die App nicht öffnest';

  @override
  String get settingsPrimingTitle => 'Verpass keinen Wunsch-Skin';

  @override
  String settingsRemovedAccount(String account) {
    return '$account entfernt';
  }

  @override
  String get settingsServerStatus => 'Serverstatus';

  @override
  String get settingsServerStatusMaintenance => 'Wartung läuft';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Meldungen',
      one: '$n Meldung',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'VALORANT-Wartungen und -Störungen pro Server';

  @override
  String get settingsSessionLogTitle => 'ValHub-Fehlerbericht';

  @override
  String get settingsSeverityCritical => 'Kritisch';

  @override
  String get settingsSeverityInfo => 'Info';

  @override
  String get settingsSeverityWarning => 'Warnung';

  @override
  String get settingsSignedOutAll => 'Von allen Konten abgemeldet';

  @override
  String get settingsStatusAllGood => 'Server laufen normal';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Keine Störungen oder Wartungen auf dem Server $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Weniger anzeigen';

  @override
  String get settingsStatusIssues => 'Riot behebt gerade Probleme';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Für diesen Server gibt es $n Störungsmeldungen.',
      one: 'Für diesen Server gibt es $n Störungsmeldung.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Störung';

  @override
  String get settingsStatusKindMaintenance => 'Wartung';

  @override
  String get settingsStatusMaintenanceNow => 'Server werden gewartet';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Möglicherweise kannst du gerade nicht spielen und ValHub kann vorübergehend keine Infos laden.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weitere Updates anzeigen',
      one: '$n weiteres Update anzeigen',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Wartung geplant';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Riot hat $n Wartungen angekündigt.',
      one: 'Riot hat $n Wartung angekündigt.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Quelle: offizielle Statusseite von Riot Games. Zeiten in der Zeitzone deines Geräts.';

  @override
  String settingsStatusStarted(String when) {
    return 'Beginn: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Aktualisiert: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'UPDATES VON RIOT';

  @override
  String get settingsSupportHeader => 'SUPPORT';

  @override
  String settingsSwitchedTo(String account) {
    return 'Zu $account gewechselt';
  }

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeLabel => 'Design';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemePickerTitle => 'Design wählen';

  @override
  String get settingsThemeSystem => 'Wie System';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rang, Matchverlauf, laufende Matches';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR pro Match, Ränge der Gegner';

  @override
  String get settingsWelcomeBulletStore =>
      'Täglicher Shop, Nachtmarkt und Bundles';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Preise, Seltenheit und Countdown bis zur Erneuerung';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist & Benachrichtigungen';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Meldet, wenn deine Wunsch-Skins im Shop landen';

  @override
  String get settingsWelcomeFootnote =>
      'Du meldest dich auf der offiziellen Riot-Seite an. ValHub speichert dein Passwort nur, wenn du selbst das Speichern der Anmeldedaten wählst.';

  @override
  String get settingsWelcomeKicker => 'VALORANT-BEGLEITER';

  @override
  String get settingsCountryPriceHeader => 'Land & Preise';

  @override
  String get settingsDataHeader => 'Daten auf dem Gerät';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (Bewertungen: $count) · ',
      'other': '',
    });
    return 'Community: ${_temp0}Herzen: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Zur Wishlist hinzufügen';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Im Shop von: $accounts';
  }

  @override
  String get skinDetailHistoryDelete => 'Shop-Verlauf löschen';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Alle für dieses Konto auf dem Gerät erfassten Shop-Tage löschen?';

  @override
  String get skinDetailInWishlist => 'In der Wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Gesperrt';

  @override
  String get skinDetailMute => 'Stummschalten';

  @override
  String get skinDetailNotFound => 'Dieser Skin wurde nicht gefunden.';

  @override
  String get skinDetailOwned => 'Im Besitz';

  @override
  String get skinDetailPause => 'Pause';

  @override
  String get skinDetailPlay => 'Abspielen';

  @override
  String get skinDetailPlayVideo => 'Video ansehen';

  @override
  String get skinDetailRemoveFromWishlist => 'Aus der Wishlist entfernen';

  @override
  String get skinDetailTitle => 'Skin-Details';

  @override
  String get skinDetailUnmute => 'Ton an';

  @override
  String get skinDetailUpgrades => 'Upgrades';

  @override
  String get skinDetailVariants => 'Varianten';

  @override
  String get skinDetailVideoError =>
      'Video kann nicht abgespielt werden. Prüf deine Verbindung und versuch es erneut.';

  @override
  String skinDetailSeenDaily(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString-mal in deinem Shop',
      one: '$nString-mal in deinem Shop',
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
      other: 'Nachtmarkt: $nString-mal',
      one: 'Nachtmarkt: $nString-mal',
    );
    return '$_temp0';
  }

  @override
  String get socialPresenceInMatch => 'Im Match';

  @override
  String get socialPresenceAgentSelect => 'In der Agentenauswahl';

  @override
  String get socialPresenceQueue => 'In der Warteschlange';

  @override
  String get socialPresenceLobby => 'In der Lobby';

  @override
  String get socialPresenceCustom => 'Im eigenen Spiel';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Offene Gruppe',
      'other': 'Nur auf Einladung',
    });
    return '$size/$max Spieler · $_temp0';
  }

  @override
  String get socialAccept => 'Annehmen';

  @override
  String get socialAcceptInGame => 'Nimm diese Einladung im Spiel an.';

  @override
  String socialActionFailed(String message) {
    return 'Aktion nicht abgeschlossen. $message';
  }

  @override
  String get socialAutoRefresh => 'Automatisch aktualisieren';

  @override
  String get socialAway => 'Abwesend';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Suche abbrechen · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Suche abbrechen';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Die Gruppe kann nicht in $queue starten: $reason';
  }

  @override
  String get socialChangeQueue => 'Modus ändern';

  @override
  String get socialChatUnavailable => 'Der Chat ist offline.';

  @override
  String get socialCloseParty => 'Gruppe schließen';

  @override
  String get socialCodeInvalid =>
      'Der Gruppencode besteht nur aus Buchstaben und Ziffern.';

  @override
  String get socialConnecting => 'Chat wird verbunden …';

  @override
  String get socialCopyCode => 'Kopieren';

  @override
  String get socialCurrentQueue => 'Ausgewählt';

  @override
  String get socialCustomGameLobby =>
      'Die Gruppe ist in der Lobby für ein eigenes Spiel.';

  @override
  String get socialDecline => 'Ablehnen';

  @override
  String get socialDisableCode => 'Code deaktivieren';

  @override
  String get socialEmptyChat => 'Noch keine Nachrichten. Sag Hallo!';

  @override
  String get socialEmptyChatTitle => 'Chat starten';

  @override
  String get socialFailedBadge => 'Nicht gesendet';

  @override
  String get socialFilterAll => 'Alle';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Ungelesen';

  @override
  String get socialFriendsPrivacyNote =>
      'Freundesliste und Nachrichten kommen direkt von Riot. ValHub speichert sie nirgendwo anders.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total Freunde',
      one: '$total Freund',
    );
    return '$_temp0 · $online online';
  }

  @override
  String get socialFriendsTitle => 'Freunde & Chat';

  @override
  String get socialGameNotRunningBody =>
      'Gruppe & Warteschlange funktionieren nur, wenn VALORANT auf deinem PC oder deiner Konsole läuft. Starte das Spiel und zieh nach unten, um zu aktualisieren.';

  @override
  String get socialGameNotRunningTitle => 'Starte VALORANT auf PC oder Konsole';

  @override
  String get socialGenerateCode => 'Code erstellen';

  @override
  String get socialIdleQueue => 'Bereit für die Suche';

  @override
  String get socialInMatchBanner =>
      'Du bist in einem Match. Die Warteschlange ist wieder verfügbar, sobald das Match endet.';

  @override
  String get socialInValorant => 'In VALORANT';

  @override
  String get socialInviteByRiotId => 'Per Riot ID einladen';

  @override
  String get socialInviteByRiotIdHint =>
      'Auch Spieler einladen, die nicht in deiner Freundesliste sind';

  @override
  String get socialInviteFriends => 'Freunde einladen';

  @override
  String socialInviteFrom(String name) {
    return 'Einladung von $name';
  }

  @override
  String socialInviteLabel(String name) {
    return '$name einladen';
  }

  @override
  String get socialInviteNeedsName =>
      'Die Riot ID dieser Person ist unbekannt, daher ist keine Einladung möglich.';

  @override
  String socialInviteSent(String name) {
    return 'Einladung an $name gesendet.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Eingeladen';
  }

  @override
  String get socialInvitesSection => 'Einladungen';

  @override
  String get socialJoin => 'Beitreten';

  @override
  String get socialJoinConfirmBody =>
      'Du verlässt deine aktuelle Gruppe, um der Gruppe mit diesem Code beizutreten.';

  @override
  String get socialJoinConfirmTitle => 'Einer anderen Gruppe beitreten?';

  @override
  String get socialJoinSection => 'Anderer Gruppe beitreten';

  @override
  String get socialJoinWithCode => 'Code zum Beitreten eingeben';

  @override
  String get socialJoined => 'Gruppe beigetreten.';

  @override
  String socialLastOnline(String relative) {
    return 'Aktiv $relative';
  }

  @override
  String get socialLeader => 'Gruppenleiter';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Du verlässt deine aktuelle Gruppe und bist dann wieder in einer eigenen Gruppe.';

  @override
  String get socialLeaveConfirmTitle => 'Gruppe verlassen?';

  @override
  String get socialLeaveParty => 'Gruppe verlassen';

  @override
  String socialLevel(int n) {
    return 'Stufe $n';
  }

  @override
  String get socialMatchFound => 'Match gefunden!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Mitglieder ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Nachricht eingeben …';

  @override
  String get socialMoreActions => 'Weitere Optionen';

  @override
  String get socialNoCode =>
      'Erstelle einen Code, damit Freunde schnell per Code deiner Gruppe beitreten können.';

  @override
  String get socialNoCodeMember =>
      'Der Gruppenleiter kann einen Code für schnelle Einladungen erstellen.';

  @override
  String get socialNoFilterResults => 'Keine Freunde passen zu diesem Filter.';

  @override
  String get socialNoFriends =>
      'Deine Riot-Freundesliste ist leer. Füge im Spiel Freunde hinzu.';

  @override
  String get socialNoFriendsTitle => 'Noch keine Freunde';

  @override
  String get socialNoOnlineFriends =>
      'Gerade ist keiner deiner Freunde in VALORANT online.';

  @override
  String get socialNoSearchResults => 'Keine passenden Freunde gefunden.';

  @override
  String get socialNoSearchResultsTitle => 'Nichts gefunden';

  @override
  String get socialNotReady => 'Nicht bereit';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online auf dem Handy';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Nur der Gruppenleiter kann den Modus ändern und die Suche starten.';

  @override
  String get socialOpenParty => 'Gruppe öffnen';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Gruppencode';

  @override
  String socialPartyCodeValue(String code) {
    return 'Gruppencode: $code';
  }

  @override
  String get socialPartyInvite => 'Gruppeneinladung';

  @override
  String socialPartyOf(int size, int max) {
    return 'Gruppe $size/$max';
  }

  @override
  String get socialPartyTitle => 'Gruppe & Warteschlange';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Gruppe mit $size Spielern',
      one: 'Gruppe mit $size Spieler',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'Modus wählen';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Bester Ping zu den Spielservern';

  @override
  String socialPlayingOther(String game) {
    return 'Spielt $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Im Spiel ($n)';
  }

  @override
  String get socialQueueLabel => 'Warteschlange';

  @override
  String get socialQueueLocked =>
      'Während eines Matches kannst du den Modus nicht ändern.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Maximal $max Spieler',
      one: 'Maximal $max Spieler',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Der Spielstatus konnte nicht bestätigt werden. Aktualisiere, um Bereitschaft und Warteschlange zu nutzen.';

  @override
  String get socialReady => 'Bereit';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Bereit $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'ein Mitglied hat noch nicht die nötige Kontostufe';

  @override
  String get socialReasonGeneric =>
      'die Gruppe erfüllt die Voraussetzungen nicht';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'die Gruppe ist zu groß (maximal $max Spieler)';
  }

  @override
  String get socialReasonRankDisparity =>
      'der Rangunterschied ist für gewertete Matches zu groß';

  @override
  String socialReasonRestricted(String time) {
    return 'die Gruppe ist für die Suche gesperrt (noch $time)';
  }

  @override
  String get socialReconnecting =>
      'Chatverbindung unterbrochen. Verbinde neu …';

  @override
  String get socialRemoteNote =>
      'Änderungen werden nur an Riot gesendet, wenn du tippst. ValHub startet keine Suche und legt keine Agenten für dich fest.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name wird aus deiner Gruppe entfernt.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Aus der Gruppe entfernen?';

  @override
  String get socialRemoveMember => 'Aus der Gruppe entfernen';

  @override
  String socialRequestFrom(String name) {
    return '$name möchte der Gruppe beitreten';
  }

  @override
  String get socialRequestsSection => 'Beitrittsanfragen';

  @override
  String get socialRiotIdFieldHint => 'Name#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Eine Riot ID besteht aus Name (3–16 Zeichen), # und Tag (3–5 Buchstaben oder Ziffern).';

  @override
  String get socialSearchHint => 'Nach Riot ID suchen …';

  @override
  String socialSearching(String elapsed) {
    return 'Suche läuft · $elapsed';
  }

  @override
  String get socialSend => 'Senden';

  @override
  String get socialSendFailed =>
      'Nachricht konnte nicht gesendet werden. Prüf deine Verbindung und versuch es erneut.';

  @override
  String get socialSendInvite => 'Einladung senden';

  @override
  String get socialShareCode => 'Teilen';

  @override
  String socialShareCodeText(String code) {
    return 'Tritt meiner VALORANT-Gruppe mit diesem Code bei: $code';
  }

  @override
  String get socialShootingRange => 'Auf The Range';

  @override
  String get socialShowEveryone => 'Alle anzeigen';

  @override
  String get socialStartQueue => 'Suche starten';

  @override
  String get socialSuggestionsItem0 => 'Hey!';

  @override
  String get socialSuggestionsItem1 => 'Lust auf ein paar Matches?';

  @override
  String get socialSuggestionsItem2 => 'Komm in meine Gruppe!';

  @override
  String socialUnread(int n) {
    return '$n ungelesen';
  }

  @override
  String get socialUnready => 'Nicht mehr bereit';

  @override
  String get socialViewProfile => 'Profil ansehen';

  @override
  String get socialWaitingForConnection =>
      'Verbinde … Du kannst Nachrichten senden, sobald die Verbindung steht.';

  @override
  String get socialYou => 'Du';

  @override
  String get socialPartyUnavailable =>
      'Gruppe konnte nicht synchronisiert werden. Aktualisiere, um es erneut zu versuchen.';

  @override
  String get socialAcceptConfirmBody =>
      'Du verlässt deine aktuelle Gruppe, um der Gruppe beizutreten, die dich eingeladen hat.';

  @override
  String get storeAccessoryEmpty => 'Im Zubehörshop gibt es gerade nichts.';

  @override
  String get storeAccessoryEmptyTitle => 'Noch kein Zubehör';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Aus: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Erneuerung in $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Erneuerung $wall';
  }

  @override
  String get storeAddToWishlist => 'Zur Wishlist hinzufügen';

  @override
  String get storeBackToBundles => 'Aktuelle Bundles ansehen';

  @override
  String get storeBundleBuySeparateLabel => 'Einzeln kaufen';

  @override
  String get storeBundleDetailTitle => 'Bundle-Details';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Läuft ab $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Noch $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Gegenstände',
      one: '$n Gegenstand',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Gratis';

  @override
  String get storeBundleItemsTitle => 'Gegenstände im Bundle';

  @override
  String get storeBundleNotFound =>
      'Dieses Bundle wurde nicht gefunden. Möglicherweise ist es abgelaufen.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle abgelaufen';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Gegenstände im Besitz: $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Bundle-Preis';

  @override
  String get storeBundleSavingsLabel => 'Ersparnis';

  @override
  String get storeBundleWholesaleOnly =>
      'Nur komplett erhältlich, nicht einzeln.';

  @override
  String get storeBundlesEmpty => 'Zurzeit werden keine Bundles angeboten.';

  @override
  String get storeBundlesEmptyTitle => 'Noch keine Bundles';

  @override
  String get storeDailyEmpty => 'Heute gibt es keine Skins im Shop.';

  @override
  String get storeDailyEmptyTitle => 'Shop leer';

  @override
  String storeDailyResetAt(String time) {
    return 'Erneuert sich täglich um $time';
  }

  @override
  String get storeDailyTotalLabel => 'Gesamt';

  @override
  String get storeNightMarketEmpty => 'Zurzeit gibt es keinen Nachtmarkt.';

  @override
  String get storeNightMarketEmptyTitle => 'Nachtmarkt noch nicht geöffnet';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Endet $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Endet in $t';
  }

  @override
  String get storeNightMarketNote =>
      'Nachtmarkt-Angebote gelten nur für dein Konto und können nicht erneuert werden.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Gesamtersparnis $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Nicht aufgedeckt';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Im Besitz';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Im Besitz: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Aus der Wishlist entfernen';

  @override
  String get storeResetNotificationTitle => 'Der Shop wurde erneuert';

  @override
  String storeResetsIn(String t) {
    return 'Erneuerung in $t';
  }

  @override
  String get storeSegmentAccessories => 'Zubehör';

  @override
  String get storeSegmentBundles => 'Bundles';

  @override
  String get storeSegmentDaily => 'Täglich';

  @override
  String get storeSegmentNightMarket => 'Nachtmarkt';

  @override
  String get storeShareButton => 'Teilen';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Heutiger Shop';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Nachtmarkt';

  @override
  String get storeShareCardPriceNote =>
      'Umrechnungspreise sind nur Schätzungen nach VP-Paket.';

  @override
  String storeShareCardSaved(String vp) {
    return '$vp gespart';
  }

  @override
  String get storeShareCardTagline => 'Dein VALORANT-Begleiter';

  @override
  String storeShareCardTotal(String vp) {
    return 'Gesamt $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Bis $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Heutigen Shop teilen';

  @override
  String get storeShareFailed =>
      'Bild konnte nicht erstellt werden. Versuch es erneut.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-shop-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-nachtmarkt-$stamp.png';
  }

  @override
  String get storeShareImage => 'Bild teilen';

  @override
  String get storeShareNightMarketTitle => 'Nachtmarkt teilen';

  @override
  String get storeSharePreparing => 'Skin-Bilder werden geladen …';

  @override
  String get storeShareShowPrice => 'Geschätzten Umrechnungspreis anzeigen';

  @override
  String get storeShareShowPriceHint =>
      'Umgerechnet nach dem günstigsten VP-Paket.';

  @override
  String get storeShareShowRiotId => 'Riot ID auf dem Bild anzeigen';

  @override
  String get storeShareShowRiotIdHint =>
      'Standardmäßig aus, um deine Privatsphäre zu schützen.';

  @override
  String get storeShareSubjectDaily => 'Mein heutiger VALORANT-Shop';

  @override
  String get storeShareSubjectNightMarket => 'Mein VALORANT-Nachtmarkt';

  @override
  String get storeShareSubtitle =>
      'Teile ein Bild deines Shops mit Freunden über eine App deiner Wahl.';

  @override
  String get storeTitle => 'Shop';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Guthaben: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n in der Wishlist';
  }

  @override
  String get storeHistoryTitle => 'Shop-Verlauf';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString Tage',
      one: '$daysString Tag',
    );
    return 'Auf diesem Gerät erfasst seit $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Noch keine Tage erfasst. ValHub speichert deinen täglichen Shop jedes Mal, wenn du die App öffnest – nur auf diesem Gerät.';

  @override
  String get storeHistoryMostOffered => 'Am häufigsten angeboten';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString-mal',
      one: '$nString-mal',
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
      other: 'Nachtmarkt · $countString Angebote',
      one: 'Nachtmarkt · $countString Angebot',
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
      other: '$daysString Tage auf diesem Gerät erfasst',
      one: '$daysString Tag auf diesem Gerät erfasst',
      zero: 'Aufzeichnung seit heute',
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
      'yes': '$skin ist im Shop von $account – noch $left.',
      'other': '$skin ist im Shop von $account.',
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
      'discount': '$skin um $percent% reduziert, jetzt $price ($account).',
      'price': '$skin für nur $price ($account).',
      'other': '$skin ist im Nachtmarkt von $account.',
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
      'yes': '$skin ist im Bundle $bundle ($account).',
      'other': '$skin ist in einem aktuellen Bundle ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'Im Shop von $account: $names und $more weitere Skins.',
      one: 'Im Shop von $account: $names und $more weiterer Skin.',
      zero: 'Im Shop von $account: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', in der Wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Skins hinzufügen';

  @override
  String get wishlistAddToWishlist => 'Zur Wishlist hinzufügen';

  @override
  String get wishlistAllWeapons => 'Alle Waffen';

  @override
  String get wishlistBrowseCatalog => 'Alle Skins ansehen';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Skins',
      one: '$countString Skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Die Skin-Liste konnte nicht geladen werden. Aktualisiere, um es erneut zu versuchen.';

  @override
  String get wishlistCatalogEmptyTitle => 'Noch keine Skins';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'In der Wishlist: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Tippe auf ♡, um einen Skin zur Wishlist hinzuzufügen';

  @override
  String get wishlistCatalogTitle => 'Alle Skins';

  @override
  String get wishlistChooseWeapon => 'Waffe wählen';

  @override
  String get wishlistClearFilters => 'Filter löschen';

  @override
  String get wishlistEmpty =>
      'Deine Wishlist ist leer. Tippe bei einem Skin auf ♡, um ihn hinzuzufügen.';

  @override
  String get wishlistEmptyTitle => 'Noch keine Skins';

  @override
  String wishlistEndsIn(String time) {
    return 'Endet in $time';
  }

  @override
  String get wishlistExcludedRewards => 'Ohne Belohnungs-Skins';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Skins',
      one: '$countString Skin',
    );
    return 'Gefiltert: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Keine passenden Skins. Entferne Filter, um mehr zu sehen.';

  @override
  String get wishlistNoMatchTitle => 'Keine Skins gefunden';

  @override
  String get wishlistNotifBundleTitle => 'Neues Bundle mit Wishlist-Skin';

  @override
  String get wishlistNotifDailyTitle => 'Ein Wishlist-Skin ist da!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Dein Wunsch-Skin ist im Nachtmarkt!';

  @override
  String get wishlistNotifPermissionMissing =>
      'Die App darf noch keine Benachrichtigungen senden.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wishlist-Skins sind im Shop!',
      one: '$count Wishlist-Skin ist im Shop!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Wishlist-Benachrichtigungen';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Für dieses Konto, auch wenn du die App nicht öffnest';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist von $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Skins aus deiner Wishlist sind im Shop!',
      one: '$count Skin aus deiner Wishlist ist im Shop!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Tippe auf die markierte Zeile, um das Angebot zu sehen.';

  @override
  String get wishlistOpenSettings => 'Einstellungen öffnen';

  @override
  String get wishlistOwned => 'Im Besitz';

  @override
  String get wishlistRemoveAction => 'Aus der Wishlist entfernen';

  @override
  String get wishlistRemoveFromWishlist => 'Aus der Wishlist entfernen';

  @override
  String wishlistRemoved(String name) {
    return '$name aus der Wishlist entfernt';
  }

  @override
  String get wishlistSearchHint => 'Skins suchen …';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Skins',
      one: '$countString Skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'Name';

  @override
  String get wishlistSortPrice => 'Preis';

  @override
  String get wishlistSortRarity => 'Seltenheit';

  @override
  String get wishlistSortWeapon => 'Waffe';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Gesamtwert der Wishlist';

  @override
  String get wishlistUndo => 'Rückgängig';

  @override
  String get wishlistViewInStore => 'Im Shop ansehen';

  @override
  String get wishlistWeapon => 'Waffe';

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
      'yes': ', in der Wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', in der Wishlist',
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
      'gain': 'gewonnen',
      'other': 'verloren',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins Siege',
      one: '$wins Sieg',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses Niederlagen',
      one: '$losses Niederlage',
    );
    return 'Heute $rr RR $_temp0, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins Siege',
      one: '$wins Sieg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses Niederlagen',
      one: '$losses Niederlage',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws Unentschieden',
      one: ', $draws Unentschieden',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown Matches mit unbekanntem Ergebnis',
      one: ', $unknown Match mit unbekanntem Ergebnis',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Öffne „Startseite anpassen“, um sie wieder einzublenden.';

  @override
  String get homeAllHiddenTitle => 'Du hast alle Karten ausgeblendet';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Stufe, nötige XP pro Tag und Wochenmissionen.';

  @override
  String get homeCardCommunity => 'Community';

  @override
  String get homeCardCommunityDesc =>
      'Mitspieler mit passendem Rang und die beliebtesten Skins der Community.';

  @override
  String get homeCardFriends => 'Freunde im Spiel';

  @override
  String get homeCardFriendsDesc =>
      'Freunde, die gerade im Match oder in der Warteschlange sind.';

  @override
  String homeCardHidden(String name) {
    return '„$name“ ausgeblendet';
  }

  @override
  String get homeCardLive => 'Aktuelles Match';

  @override
  String get homeCardLiveDesc =>
      'Erscheint, wenn du in der Warteschlange, in der Agentenauswahl oder im Match bist.';

  @override
  String get homeCardOtherAccounts => 'Andere Konten';

  @override
  String get homeCardOtherAccountsDesc =>
      'Status und Wishlist deiner übrigen Konten.';

  @override
  String get homeCardRank => 'Rang & Form';

  @override
  String get homeCardRankDesc =>
      'Rang, RR von heute, Serien und Matches bis zum Aufstieg.';

  @override
  String get homeCardServerStatus => 'Serverstatus';

  @override
  String get homeCardServerStatusDesc =>
      'Erscheint nur bei Wartungen oder Störungen.';

  @override
  String get homeCardStore => 'Heutiger Shop';

  @override
  String get homeCardStoreDesc => 'Tägliche Skins, Wishlist und Nachtmarkt.';

  @override
  String get homeCustomize => 'Startseite anpassen';

  @override
  String get homeCustomizeHint =>
      'Zum Sortieren ziehen. Ausschalten, um Karten auszublenden.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Zu $name gesprungen';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Aktivieren';

  @override
  String get homeFriendsConsentBody =>
      'Damit du siehst, welche Freunde gerade spielen, verbindet sich ValHub bei jedem Öffnen der Startseite mit dem Riot-Chat des aktiven Kontos. Deine Freunde sehen dich dann als online. Du kannst das unter „Startseite anpassen“ ausschalten.';

  @override
  String get homeFriendsConsentDecline => 'Nein, Karte ausblenden';

  @override
  String get homeFriendsConsentTitle => 'Sehen, welche Freunde spielen?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Freunde spielen',
      one: '$n Freund spielt',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Alle anzeigen';

  @override
  String get homeHideCard => 'Diese Karte ausblenden';

  @override
  String homeLeaderboard(String pos) {
    return 'Platz $pos in der Rangliste';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Noch $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return '$n Spieler gesucht';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Mitspieler mit deinem Rang finden';

  @override
  String get homeLiveAllyLabel => 'Dein Team';

  @override
  String get homeLiveEnemyLabel => 'Gegner';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'In der Warteschlange, Wartezeit $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Dein Team $ally, Gegner $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gewertete Niederlagen in Folge',
      one: '$n gewertete Niederlage in Folge',
    );
    return '$_temp0';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n Matches bis $rank',
      one: '≈ $n Match bis $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Optionen für $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Melde dich erneut an, um Shop, Rang und Battle Pass von $riotId zu aktualisieren. Den gespeicherten Stand kannst du weiterhin ansehen.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Noch $time';
  }

  @override
  String get homeNightMarketNew => 'Neu';

  @override
  String get homeNightMarketTitle => 'Nachtmarkt';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Angebote warten aufs Aufdecken',
      one: '$n Angebot wartet aufs Aufdecken',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Heute noch nicht gewertet gespielt';

  @override
  String get homeOpenLfg => 'Alle Mitspielersuchen ansehen';

  @override
  String get homeOpenRanking => 'Skin-Rangliste ansehen';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Andere Konten ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n Konten',
      one: '+$n Konto',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Wishlist-Skin im Shop';

  @override
  String homePreviousAct(String rank) {
    return 'Letzter Akt: $rank';
  }

  @override
  String get homeQuietBody => 'Zum Aktualisieren nach unten ziehen.';

  @override
  String get homeQuietTitle => 'Nichts Neues';

  @override
  String homeRankToNext(int rr) {
    return 'Noch $rr RR bis zum Aufstieg';
  }

  @override
  String get homeResetLayout => 'Standard wiederherstellen';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Heute $value';
  }

  @override
  String get homeStatusDetails => 'Details';

  @override
  String homeStatusIncident(String region) {
    return 'Serverstörung · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Wartung läuft · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Wartung geplant · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n Meldungen',
      one: '+$n Meldung',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Wird aktualisiert …';

  @override
  String homeStoreResetsIn(String time) {
    return 'Erneuerung in $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Gesamt $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Guthaben $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Skins',
      one: '$n Skin',
    );
    return 'Guthaben $vp · reicht für bis zu $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Wishlist-Skin im Shop!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Wishlist-Skins im Shop',
      one: '$n Wishlist-Skin im Shop',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Startseite';

  @override
  String get homeTrendingTitle => 'Weltweit beliebte Skins';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Herzen',
      one: '$n Herz',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Rückgängig';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gewertete Siege in Folge',
      one: '$n gewerteter Sieg in Folge',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'Der Shop wurde erneuert. ValHub konnte den neuen noch nicht laden.';

  @override
  String get homeOfflineTitle => 'Keine Verbindung';

  @override
  String get homeOfflineBody =>
      'Gespeicherte Daten werden angezeigt. ValHub aktualisiert alles, sobald du wieder online bist.';

  @override
  String get homeCardOffline => 'Erscheint, sobald du online bist.';

  @override
  String get communityErrorConsent =>
      'Stimme zu, deine Riot ID mit der Community zu teilen, um fortzufahren.';

  @override
  String get communityErrorForbidden =>
      'Das kannst du noch nicht tun. Sieh dir die Community-Richtlinien an oder kontaktiere ValHub.';

  @override
  String get communityErrorGeneric =>
      'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get communityErrorImageTooLarge =>
      'Das Bild ist zu groß (maximal 2 MB). Wähle ein anderes.';

  @override
  String get communityErrorImageType => 'Wähle ein JPEG-, PNG- oder WebP-Bild.';

  @override
  String get communityErrorInvalid =>
      'Der Inhalt wurde nicht akzeptiert. Prüf ihn und versuch es erneut.';

  @override
  String get communityErrorNetwork =>
      'Keine Verbindung zur ValHub-Community. Prüf deine Verbindung und versuch es erneut.';

  @override
  String get communityErrorNotFound => 'Dieser Inhalt existiert nicht mehr.';

  @override
  String get communityErrorPickImage =>
      'Die Fotogalerie konnte nicht geöffnet werden. Versuch es erneut.';

  @override
  String get communityErrorRateLimited =>
      'Die Community ist gerade überlastet. Versuch es in ein paar Minuten erneut.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Die Community ist gerade überlastet. Versuch es in $duration erneut.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot konnte dein Konto nicht bestätigen. Melde dich erneut bei Riot an und versuch es noch einmal.';

  @override
  String get communityErrorRiotUnavailable =>
      'Bei Riot gibt es gerade Probleme. Versuch es in ein paar Minuten erneut.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Bei Riot gibt es gerade Probleme. Versuch es in $duration erneut.';
  }

  @override
  String get communityErrorServer =>
      'Bei der ValHub-Community gibt es gerade Probleme. Versuch es in ein paar Minuten erneut.';

  @override
  String get communityErrorStorageFull =>
      'Der Bildspeicher der Community ist voll. Du kannst weiterhin posten, aber noch keine Bilder anhängen. Versuch es später erneut.';

  @override
  String get communityErrorTimeout =>
      'Die ValHub-Community antwortet zu langsam. Versuch es erneut.';

  @override
  String get communityErrorTitle => 'Nicht abgeschlossen';

  @override
  String get communityErrorUnauthorized =>
      'Die Community-Verbindung ist abgelaufen. Versuch es erneut.';

  @override
  String get communityErrorImageQuota =>
      'Dein Bilderspeicher ist voll. Lösche ein paar Beiträge mit Bildern und versuche es erneut.';

  @override
  String get smokePlain => 'Generierungstest';

  @override
  String smokeGreeting(String name) {
    return 'Hallo, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Einträge',
      one: '$n Eintrag',
    );
    return '$_temp0';
  }
}
