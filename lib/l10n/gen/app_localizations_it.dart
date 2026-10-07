// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Vedi fonte dei prezzi';

  @override
  String get commonErrorApi =>
      'Riot ha qualche problema. Riprova tra qualche minuto.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClearFilters => 'Rimuovi filtri';

  @override
  String get commonClearSearch => 'Cancella ricerca';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonCopied => 'Copiato';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giorni',
      one: '$n giorno',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giorni fa',
      one: '$n giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonEmptyGeneric => 'Ancora niente qui.';

  @override
  String get commonErrorContentUnavailable =>
      'Impossibile caricare skin, agenti e mappe. Controlla la connessione e riprova.';

  @override
  String get commonErrorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get commonErrorMaintenance =>
      'I server di VALORANT sono in manutenzione. Torna più tardi.';

  @override
  String get commonErrorNeedsLogin =>
      'Il tuo accesso Riot è scaduto. Accedi di nuovo per continuare.';

  @override
  String get commonErrorNeedsLoginTitle => 'Accedi di nuovo';

  @override
  String get commonErrorNetwork =>
      'Nessuna connessione. Controlla il Wi-Fi o i dati mobili e riprova.';

  @override
  String get commonErrorNoAccount =>
      'Non hai effettuato l\'accesso a nessun account.';

  @override
  String get commonErrorNotFound => 'Impossibile trovare questo contenuto.';

  @override
  String get commonErrorTimeout =>
      'Riot sta impiegando troppo a rispondere. Controlla la connessione e riprova.';

  @override
  String get commonErrorTransient =>
      'Riot è occupato. Riprova tra qualche minuto.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot è occupato. Riprova tra $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Impossibile rilevare la tua regione Riot. Scegli una regione nelle Impostazioni.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Vai alla Home';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ore',
      one: '$n ora',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ore fa',
      one: '$n ora fa',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Problema ai server';

  @override
  String get commonJustNow => 'proprio ora';

  @override
  String get commonLoadMore => 'Carica altro';

  @override
  String get commonLoading => 'Caricamento…';

  @override
  String get commonMaintenanceTitle => 'Manutenzione server';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minuti',
      one: '$n minuto',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minuti fa',
      one: '$n minuto fa',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Ancora niente da mostrare';

  @override
  String commonOfflineCached(String time) {
    return 'Sei offline — mostriamo i dati salvati ($time).';
  }

  @override
  String get commonOpenSettings => 'Apri impostazioni';

  @override
  String get commonPageNotFound => 'Impossibile trovare questa schermata.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Pacchetto più conveniente: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Modifica il tuo prezzo';

  @override
  String get commonPriceEnterOwn => 'Inserisci il prezzo del tuo pacchetto VP';

  @override
  String get commonPriceEstimateBody =>
      'L\'importo “≈ …” accanto ai prezzi in VP è una stima, calcolata in base al pacchetto VP più conveniente. Nel gioco paghi in VP; l\'importo reale dipende dal pacchetto, dal metodo di pagamento, dalle tasse e dalle promozioni al momento dell\'acquisto.';

  @override
  String get commonPriceEstimateTitle => 'Prezzo stimato';

  @override
  String get commonPriceEstimateTooltip =>
      'Prezzo stimato — tocca per vedere come viene calcolato';

  @override
  String get commonPriceHidden =>
      'Prezzi stimati nascosti. Riattivali nelle Impostazioni.';

  @override
  String get commonPriceHide => 'Nascondi prezzi stimati';

  @override
  String get commonPriceOpenSource => 'Apri pagina della fonte';

  @override
  String get commonPriceOverrideBody =>
      'Inserisci l\'importo che hai pagato davvero per un pacchetto VP (controlla il negozio del gioco o la ricevuta). ValHub usa questo prezzo per stimare il prezzo di ogni oggetto; viene salvato solo su questo dispositivo.';

  @override
  String get commonPriceOverrideCurrency => 'Codice valuta';

  @override
  String get commonPriceOverrideCurrencyHint => 'Es.: EUR, USD, JPY, VND';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Esempio di stima: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Inserisci un codice valuta di 3 lettere, ad esempio EUR o USD.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Inserisci un numero maggiore di 0.';

  @override
  String get commonPriceOverridePrice => 'Prezzo del pacchetto';

  @override
  String get commonPriceOverrideRemove => 'Rimuovi il tuo prezzo';

  @override
  String get commonPriceOverrideRemoved => 'Il tuo prezzo è stato rimosso.';

  @override
  String get commonPriceOverrideSave => 'Salva prezzo';

  @override
  String get commonPriceOverrideSaved => 'Prezzo del tuo pacchetto VP salvato.';

  @override
  String get commonPriceOverrideTitle => 'Prezzo del tuo pacchetto VP';

  @override
  String get commonPriceOverrideVp => 'VP nel pacchetto';

  @override
  String get commonPricePacksTitle => 'Pacchetti VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'In base ai prezzi dei pacchetti VP nella regione $country';
  }

  @override
  String get commonPriceSourceUser =>
      'In base al prezzo del pacchetto VP che hai inserito';

  @override
  String get commonPriceUnavailable =>
      'Non c\'è ancora un listino prezzi verificato per la tua regione. Inserisci il prezzo di un pacchetto VP che hai acquistato per vedere i prezzi stimati.';

  @override
  String commonPriceUpdated(String date) {
    return 'Listino prezzi aggiornato: $date';
  }

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonRiotDisclaimer =>
      'ValHub non è approvato da Riot Games e non riflette le opinioni di Riot Games o di chiunque sia ufficialmente coinvolto nella produzione o nella gestione delle proprietà di Riot Games. Riot Games e tutte le proprietà associate sono marchi o marchi registrati di Riot Games, Inc.';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonSearch => 'Cerca…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n secondi',
      one: '$n secondo',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Condividi';

  @override
  String get commonSignInAgain => 'Accedi di nuovo';

  @override
  String get commonSort => 'Ordina';

  @override
  String commonSortBy(String option) {
    return 'Ordina: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Collezione';

  @override
  String get commonTabCommunity => 'Community';

  @override
  String get commonTabHome => 'Home';

  @override
  String get commonTabProfile => 'Profilo';

  @override
  String get commonTabSettings => 'Impostazioni';

  @override
  String get commonTabStore => 'Negozio';

  @override
  String get commonTagline => 'Il tuo compagno per VALORANT';

  @override
  String get commonToday => 'Oggi';

  @override
  String get commonTodayLower => 'oggi';

  @override
  String get commonTomorrow => 'domani';

  @override
  String get commonUnknownItem => 'Oggetto sconosciuto';

  @override
  String commonUpdatedAt(String time) {
    return 'Aggiornato alle $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Lunedì';

  @override
  String get commonWeekdaysItem1 => 'Martedì';

  @override
  String get commonWeekdaysItem2 => 'Mercoledì';

  @override
  String get commonWeekdaysItem3 => 'Giovedì';

  @override
  String get commonWeekdaysItem4 => 'Venerdì';

  @override
  String get commonWeekdaysItem5 => 'Sabato';

  @override
  String get commonWeekdaysItem6 => 'Domenica';

  @override
  String get commonYesterday => 'ieri';

  @override
  String get commonYesterdayTitle => 'Ieri';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'L\'accesso a Riot è scaduto — mostriamo i dati salvati ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Armi pesanti';

  @override
  String get contentCategoryMelee => 'Corpo a corpo';

  @override
  String get contentCategoryRifle => 'Fucili d\'assalto';

  @override
  String get contentCategoryShotgun => 'Fucili a pompa';

  @override
  String get contentCategorySidearm => 'Armi secondarie';

  @override
  String get contentCategorySmg => 'SMG';

  @override
  String get contentCategorySniper => 'Fucili di precisione';

  @override
  String get contentCurrencyAgentTokens => 'Gettoni agente';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Crediti Kingdom';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianite';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Point';

  @override
  String get contentItemAgent => 'Agente';

  @override
  String get contentItemBuddy => 'Ciondolo';

  @override
  String get contentItemCard => 'Carta giocatore';

  @override
  String get contentItemChroma => 'Variante';

  @override
  String get contentItemContract => 'Contratto';

  @override
  String get contentItemCurrency => 'Valuta';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Graffito';

  @override
  String get contentItemTitle => 'Titolo giocatore';

  @override
  String contentLevel(int n) {
    return 'Livello $n';
  }

  @override
  String get contentLevelBase => 'Base';

  @override
  String get contentLevelItemLabelsVFX => 'Effetti visivi';

  @override
  String get contentLevelItemLabelsAnimation => 'Animazione';

  @override
  String get contentLevelItemLabelsFinisher => 'Colpo di grazia';

  @override
  String get contentLevelItemLabelsKillCounter => 'Contatore uccisioni';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Effetti sonori';

  @override
  String get contentLevelItemLabelsTransformation => 'Trasformazione';

  @override
  String get contentLevelItemLabelsKillBanner => 'Banner uccisione';

  @override
  String get contentLevelItemLabelsKillEffect => 'Effetto uccisione';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Effetti ispezione e uccisione';

  @override
  String get contentLevelItemLabelsVoiceover => 'Doppiaggio';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Brani casuali';

  @override
  String get contentLevelItemLabelsRandomizer => 'Casuale';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Cambio attaccanti/difensori';

  @override
  String get contentLevelItemLabelsTopFrag => 'Effetto top frag';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Sensore battito cardiaco e mappa';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animazione pesce';

  @override
  String get contentNoTitle => 'Nessun titolo';

  @override
  String get contentNotForSale => 'Non in vendita';

  @override
  String get contentQueueNamesCompetitive => 'Competitiva';

  @override
  String get contentQueueNamesUnrated => 'Non competitiva';

  @override
  String get contentQueueNamesSwiftplay => 'Partita rapida';

  @override
  String get contentQueueNamesSpikerush => 'Assalto Spike';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Deathmatch a squadre';

  @override
  String get contentQueueNamesGgteam => 'Corsa alle armi';

  @override
  String get contentQueueNamesOnefa => 'Replicazione';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Personalizzata';

  @override
  String get contentQueueNames => 'Personalizzata';

  @override
  String get contentQueueNamesDodgeball => 'Eliminazione';

  @override
  String get contentQueueNamesFortcollins => 'Riconquista';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Schermaglia: 2 vs 2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Schermaglia: Ascensione 1 vs 1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Schermaglia: Ascensione 2 vs 2';

  @override
  String get contentQueueNamesValaram => 'All Random One Site';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Battaglia a palle di neve';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Competitiva';

  @override
  String get contentQueueShortNamesValaram => 'All Random';

  @override
  String get contentRewardSourceAgent => 'Contratto agente';

  @override
  String get contentRewardSourceBattlePass => 'Ricompensa Battle Pass';

  @override
  String get contentRewardSourceEvent => 'Pass evento';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Assassino';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Demolitore';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Stratega';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Guardiano';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Esclusiva';

  @override
  String contentTierFull(String shortName) {
    return 'Edizione $shortName';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Selezionata';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Senza grado';

  @override
  String get accountRegionUnknown => 'Regione sconosciuta';

  @override
  String accountRiotCountry(String country) {
    return 'Paese dell\'account Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown =>
      'Paese dell\'account Riot: sconosciuto';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'ACCOUNT ($count/$max)';
  }

  @override
  String get accountActive => 'In uso';

  @override
  String accountAddAccount(int count, int max) {
    return 'Aggiungi account ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Cancella dati locali';

  @override
  String get accountClearLocalDataConfirm =>
      'Cancellare la cronologia, gli equipaggiamenti salvati e i dati degli account disconnessi su questo dispositivo?';

  @override
  String get accountClearRrHistory => 'Cancella cronologia RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Cancellare la cronologia RR dell\'account selezionato su questo dispositivo?';

  @override
  String get accountCopyPassword => 'Copia password';

  @override
  String get accountCopyUsername => 'Copia nome utente';

  @override
  String get accountDeleteLoginNote => 'Elimina dati';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Eliminare il nome utente e la password salvati per questo account?';

  @override
  String get accountHidePassword => 'Nascondi password';

  @override
  String get accountKeepLocalData => 'Mantieni dati locali';

  @override
  String get accountKeepLocalDataHint =>
      'Mantieni wishlist, equipaggiamenti e cronologia su questo dispositivo';

  @override
  String accountLevelShort(int level) {
    return 'Liv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'L\'account di questa notifica è disconnesso. Accedi di nuovo, poi apri la notifica.';

  @override
  String get accountLocalDataCleared => 'Dati locali cancellati';

  @override
  String get accountLoginNote => 'Dati di accesso';

  @override
  String get accountLoginNoteDeleted => 'Dati di accesso eliminati';

  @override
  String get accountLoginNoteHint =>
      'Salvati solo su questo dispositivo e protetti in modo sicuro. Usali per consultarli o compilarli velocemente quando accedi di nuovo.';

  @override
  String get accountLoginNoteLocked => 'Sblocca dati di accesso';

  @override
  String get accountLoginNotePassword => 'Password';

  @override
  String get accountLoginNoteSaved => 'Dati di accesso salvati';

  @override
  String get accountLoginNoteUsername => 'Nome utente Riot';

  @override
  String accountMaxAccounts(int max) {
    return 'Hai raggiunto il massimo di $max account.';
  }

  @override
  String get accountNeedsLogin => 'Accedi di nuovo';

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
  String get accountQuickFill => 'Compila account salvato';

  @override
  String get accountQuickFillDone => 'Tutto compilato. Tocca Accedi.';

  @override
  String get accountQuickFillNotReady =>
      'La pagina di accesso non ha finito di caricarsi. Attendi un momento e riprova.';

  @override
  String get accountQuickFillSubtitle =>
      'Scegli un account da inserire nella pagina di accesso Riot';

  @override
  String get accountQuickFillTitle => 'Compila account salvato';

  @override
  String get accountRegionAp => 'Asia-Pacifico';

  @override
  String get accountRegionBr => 'Brasile';

  @override
  String get accountRegionEu => 'Europa';

  @override
  String get accountRegionKr => 'Corea';

  @override
  String get accountRegionLatam => 'America Latina';

  @override
  String get accountRegionNa => 'Nord America';

  @override
  String get accountRemoveAccount => 'Rimuovi account';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Rimuovere $account da questo dispositivo? Puoi scegliere di mantenere i dati salvati.';
  }

  @override
  String get accountRrHistoryCleared => 'Cronologia RR cancellata';

  @override
  String get accountShowPassword => 'Mostra password';

  @override
  String get accountSignOutAll => 'Esci da tutti gli account';

  @override
  String get accountSignOutAllConfirm =>
      'Uscire e rimuovere tutti gli account da questo dispositivo? Puoi scegliere di mantenere i dati salvati.';

  @override
  String get accountStatusAgentSelect => 'Selezione agente';

  @override
  String get accountStatusInMatch => 'In partita';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Stato sconosciuto';

  @override
  String accountSwitchTo(String account) {
    return 'Passa a $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Tocca per cambiare account';

  @override
  String get accountSwitcherTitle => 'Account';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Account ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Giocatore';

  @override
  String get accountUnlockLoginNote =>
      'Verifica la tua identità per sbloccare i dati di accesso Riot';

  @override
  String accountMoreActions(String riotId) {
    return 'Opzioni per $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Salva dati di accesso';

  @override
  String get accountClearRrHistorySubtitle => 'Solo l\'account selezionato';

  @override
  String get accountClearLocalDataSubtitle =>
      'Cronologia, equipaggiamenti salvati e dati degli account disconnessi';

  @override
  String get accountQuickFillLocked =>
      'Sblocca con impronta, volto o PIN del dispositivo per usare un account salvato. Se il telefono non ha un blocco schermo, impostane uno e riprova.';

  @override
  String get authAddAsNew => 'Aggiungi come nuovo account';

  @override
  String get authDifferentAccountBody =>
      'Hai effettuato l\'accesso con un account diverso da quello che deve accedere di nuovo. Aggiungere questo account come nuovo account?';

  @override
  String get authDifferentAccountTitle => 'Account diverso';

  @override
  String get authLoadingAccount => 'Caricamento account…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot ha rifiutato questo accesso. Riprova.';

  @override
  String get authLoginFailed => 'Impossibile completare l\'accesso';

  @override
  String get authLoginFailedBody =>
      'Riot non ha confermato il tuo accesso. Riprova.';

  @override
  String get authLoginTitle => 'Accesso Riot';

  @override
  String get authMissingCookies =>
      'Non è stato possibile salvare l\'accesso su questo dispositivo, quindi dovrai accedere di nuovo quando scadrà.';

  @override
  String get authOfficialHost => 'Pagina ufficiale · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Link aperto nel browser.';

  @override
  String get authPageLoadFailed =>
      'Impossibile caricare la pagina di accesso Riot. Controlla la connessione e riprova.';

  @override
  String get authPreparing => 'Preparazione della pagina di accesso…';

  @override
  String get authReloginDone => 'Accesso effettuato di nuovo';

  @override
  String get authSignInCta => 'Accedi con l\'account Riot';

  @override
  String get authSocialLoginHint =>
      'Se l\'accesso con Google o Facebook non funziona, usa il tuo nome utente Riot.';

  @override
  String get authStateMismatch =>
      'Questo tentativo di accesso non è valido. Ricomincia l\'accesso dall\'inizio.';

  @override
  String get notificationSessionExpiredBody =>
      'Accedi di nuovo per continuare a ricevere gli avvisi della wishlist.';

  @override
  String get notificationBackgroundTimingHint =>
      'Il risparmio batteria del dispositivo potrebbe ritardare le notifiche.';

  @override
  String get notificationChannelAccountDescription =>
      'Ti avvisa quando un account deve accedere di nuovo';

  @override
  String get notificationChannelAccountName => 'Account';

  @override
  String get notificationChannelBattlePassDescription =>
      'Promemoria su progressi e scadenza del Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Attività della community quando apri ValHub';

  @override
  String get notificationChannelCommunityName => 'Community';

  @override
  String get notificationChannelLfgDescription =>
      'Giocatori che si uniscono al tuo gruppo quando apri ValHub';

  @override
  String get notificationChannelLfgName => 'Gruppo';

  @override
  String get notificationChannelNightMarketDescription =>
      'Avvisi quando apre il Mercato notturno';

  @override
  String get notificationChannelNightMarketName => 'Mercato notturno';

  @override
  String get notificationChannelRankDescription =>
      'Cambi di grado quando aggiorni il profilo';

  @override
  String get notificationChannelRankName => 'Grado';

  @override
  String get notificationChannelStoreResetDescription =>
      'Ti avvisa quando il negozio giornaliero si aggiorna';

  @override
  String get notificationChannelStoreResetName => 'Aggiornamento negozio';

  @override
  String get notificationChannelWishlistDescription =>
      'Avvisi quando una skin della wishlist appare nel tuo negozio';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle =>
      'Un giocatore si è unito al tuo gruppo';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Carte offerta in attesa per $account: $cards. Girale ora.';
  }

  @override
  String get notificationNightMarketOpenTitle =>
      'Il Mercato notturno è aperto!';

  @override
  String get notificationPassEndingBody =>
      'Manca circa un giorno alla fine del Battle Pass. Apri ValHub per vedere i tuoi ultimi progressi.';

  @override
  String get notificationPassEndingTitle => 'Il Battle Pass sta per finire';

  @override
  String notificationPassProgressBody(int level) {
    return 'Hai raggiunto il livello $level nel Battle Pass attuale.';
  }

  @override
  String get notificationPassProgressTitle => 'Progressi Battle Pass';

  @override
  String get notificationPrivateAccount => 'il tuo account';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Grado attuale: $rank. Appena aggiornato da Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Grado cambiato';

  @override
  String get notificationResetTimingUnknown =>
      'Apri il negozio per aggiornare l\'orario di aggiornamento sul tuo dispositivo.';

  @override
  String get notificationSessionExpiredTitle => 'Accedi di nuovo';

  @override
  String get notificationStoreResetBody =>
      'Nuove skin ti aspettano nel negozio.';

  @override
  String get competitiveDivisionIron => 'Ferro';

  @override
  String get competitiveDivisionBronze => 'Bronzo';

  @override
  String get competitiveDivisionSilver => 'Argento';

  @override
  String get competitiveDivisionGold => 'Oro';

  @override
  String get competitiveDivisionPlatinum => 'Platino';

  @override
  String get competitiveDivisionDiamond => 'Diamante';

  @override
  String get competitiveDivisionAscendant => 'Ascendente';

  @override
  String get competitiveDivisionImmortal => 'Immortale';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiante';

  @override
  String get competitiveRankUnknown => 'Grado sconosciuto';

  @override
  String get competitiveAttack => 'Attacco';

  @override
  String get competitiveCannotEstimate => 'Impossibile stimare';

  @override
  String get competitiveDefeat => 'Sconfitta';

  @override
  String get competitiveDefense => 'Difesa';

  @override
  String get competitiveDraw => 'Pareggio';

  @override
  String get competitiveIncognitoPlayer => 'Giocatore nascosto';

  @override
  String get competitiveMatchPending =>
      'Riot sta ancora elaborando questa partita…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Mancano $n partite di piazzamento',
      one: 'Manca $n partita di piazzamento',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike disinnescata';

  @override
  String get competitiveRoundDetonate => 'Spike esplosa';

  @override
  String get competitiveRoundElimination => 'Eliminazione';

  @override
  String get competitiveRoundSurrendered => 'Resa';

  @override
  String get competitiveRoundTimeExpired => 'Tempo scaduto';

  @override
  String get competitiveUnknownPlayer => 'Giocatore';

  @override
  String get competitiveVictory => 'Vittoria';

  @override
  String economyAvailableNow(String place) {
    return 'Ora nel $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'bundle $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'bundle';

  @override
  String get economyPlaceDaily => 'negozio giornaliero';

  @override
  String get economyPlaceNightMarket => 'Mercato notturno';

  @override
  String get economyPriceEstimated => 'Stimato in base all\'edizione';

  @override
  String get economyPriceFromOffers => 'Prezzo dal listino di Riot';

  @override
  String get economyPriceFromStore => 'Prezzo visto nel negozio';

  @override
  String get economyPriceFromTable => 'Prezzo di listino';

  @override
  String get economyPriceUnknown => 'Prezzo sconosciuto';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Equipaggiamento $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Questa modifica non può essere applicata al tuo equipaggiamento attuale.';

  @override
  String get loadoutNotPersisted =>
      'Riot non ha salvato la modifica, quindi il tuo equipaggiamento non è cambiato. Riprova.';

  @override
  String get loadoutSaveFailed => 'Impossibile salvare l\'equipaggiamento';

  @override
  String battlePassActEndsIn(String time) {
    return 'L\'atto termina tra $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'L\'atto termina tra $days giorni',
      one: 'L\'atto termina tra $days giorno',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Tutte le missioni completate';

  @override
  String get battlePassAllWeeklyDone =>
      'Tutte le missioni settimanali completate';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Ricompense doppie in attesa: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Capitolo $n';
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
      'Vinci i round per avanzare verso i checkpoint (il Deathmatch non conta).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Checkpoint $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Ogni checkpoint: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Checkpoint raggiunti: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Attuale';

  @override
  String get battlePassDailyAllDone => 'Tutti i checkpoint di oggi completati';

  @override
  String get battlePassDailyCaption => 'Ricompense giornaliere';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Ricompense giornaliere · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'I checkpoint di ieri sono scaduti. Avvia il gioco o aggiorna qui.';

  @override
  String get battlePassDailyMissions => 'Missioni giornaliere';

  @override
  String get battlePassDailyNotReady =>
      'I checkpoint di oggi non sono ancora pronti. Avvia il gioco o aggiorna qui.';

  @override
  String get battlePassDailyPlayToStart =>
      'I checkpoint di oggi non sono ancora pronti. Avvia il gioco per iniziare un nuovo giorno.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Mancano $days giorni',
      one: 'Manca $days giorno',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Termina alle $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilogo';

  @override
  String get battlePassEstimateNote =>
      'Stima di circa 4.000 XP a partita, missioni escluse.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Termina tra $time';
  }

  @override
  String get battlePassEventPass => 'Pass evento';

  @override
  String get battlePassFilterAll => 'Tutto';

  @override
  String get battlePassFilterLocked => 'Bloccati';

  @override
  String get battlePassFilterUnlocked => 'Sbloccati';

  @override
  String get battlePassFree => 'Gratis';

  @override
  String get battlePassFreeTrack => 'Ricompense gratuite';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Livello $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Liv. $n';
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
      other: '$nString partite',
      one: '$nString partita',
    );
    return '≈ $_temp0 in modalità $queue';
  }

  @override
  String get battlePassMissionDone => 'Completata';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'Completate: $done/$total';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Nuove missioni alle $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Nuove missioni tra $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Prossimo checkpoint: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Verso il livello $level';
  }

  @override
  String get battlePassNextReward => 'Prossima';

  @override
  String get battlePassNoBattlePass =>
      'Nessuna informazione sul Battle Pass dell\'atto attuale. Riprova più tardi.';

  @override
  String get battlePassNoRewards =>
      'Questo Battle Pass non ha ancora ricompense.';

  @override
  String get battlePassNoRewardsInFilter =>
      'Nessuna ricompensa in questa sezione.';

  @override
  String get battlePassNoRewardsTitle => 'Ancora nessuna ricompensa';

  @override
  String get battlePassNoWeeklyMissions =>
      'Al momento non ci sono missioni settimanali.';

  @override
  String get battlePassPassComplete => 'Battle Pass completato';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Non hai il Premium: ricevi solo le ricompense gratuite. Acquista il Premium nel gioco per sbloccare i livelli che hai raggiunto.';

  @override
  String get battlePassRenewButton => 'Aggiorna checkpoint';

  @override
  String get battlePassRenewDone => 'Checkpoint giornalieri aggiornati.';

  @override
  String get battlePassRenewFailed =>
      'Impossibile aggiornare i checkpoint. Riprova più tardi.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Si aggiorna alle $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Si aggiorna tra $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Livello';

  @override
  String get battlePassRewardLocked => 'Bloccata';

  @override
  String get battlePassRewardNeedsPremium => 'Richiede Premium';

  @override
  String get battlePassRewardStatusLabel => 'Stato';

  @override
  String get battlePassRewardTrackLabel => 'Tipo di ricompensa';

  @override
  String get battlePassRewardTypeLabel => 'Tipo';

  @override
  String get battlePassRewardUnlocked => 'Sbloccata';

  @override
  String get battlePassRewardsTitle => 'Ricompense';

  @override
  String get battlePassShowAllRewards => 'Vedi tutto';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'XP totali';

  @override
  String get battlePassUnknownMission =>
      'Nuova missione (ancora senza descrizione)';

  @override
  String get battlePassUnknownReward => 'Ricompensa';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'Sbloccati: $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'Non competitiva';

  @override
  String get battlePassViewAllRewards => 'Vedi tutte le ricompense';

  @override
  String get battlePassWeeklyMissions => 'Missioni settimanali';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Missioni settimanali: ancora +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / giorno';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Necessari al giorno per finire in tempo';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Mancano $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Impossibile salvare l\'equipaggiamento. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Tutte le skin che possiedi, valutate ai prezzi del negozio',
      'buddy': 'I ciondoli che possiedi e quante copie',
      'spray': 'Graffiti che puoi aggiungere alla ruota delle espressioni',
      'card': 'Carte giocatore sbloccate, tocca per vederle ed equipaggiarle',
      'title': 'Titoli giocatore che puoi mostrare sotto il tuo nome',
      'flex': 'Oggetti Flex che possiedi',
      'other': 'Sfoglia collezione',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Slot: $position';
  }

  @override
  String get collectionApplyPreset => 'Applica';

  @override
  String get collectionApplyPresetBody =>
      'Skin, ciondoli, ruota delle espressioni, carta e titolo attuali verranno sostituiti con questo equipaggiamento.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Applicare “$name”?';
  }

  @override
  String get collectionBrowseBuddies => 'Ciondoli';

  @override
  String get collectionBrowseCards => 'Carte giocatore';

  @override
  String get collectionBrowseEmpty =>
      'Non hai ancora oggetti in questa sezione.';

  @override
  String get collectionBrowseEmptyTitle => 'Ancora nessun oggetto';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skin';

  @override
  String get collectionBrowseSprays => 'Graffiti';

  @override
  String get collectionBrowseTitles => 'Titoli giocatore';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Disponibili: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Per $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Scegli un ciondolo';

  @override
  String get collectionBuddyRemoved => 'Ciondolo rimosso';

  @override
  String get collectionBuddySlot => 'Ciondolo';

  @override
  String get collectionBuddyUnavailable =>
      'Impossibile agganciare questo ciondolo. Aggiorna o scegline un altro.';

  @override
  String get collectionCachedLoadout =>
      'Stai vedendo l\'equipaggiamento salvato. Trascina per aggiornare prima di fare modifiche.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString carte possedute',
      one: '$nString carta posseduta',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Cambia';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'Varianti: $owned/$total';
  }

  @override
  String get collectionClearTiers => 'Rimuovi filtro edizione';

  @override
  String get collectionCollectionValue => 'Valore della collezione';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standard';

  @override
  String get collectionDeletePreset => 'Elimina';

  @override
  String get collectionEmptySlot => 'Vuoto';

  @override
  String get collectionEquip => 'Equipaggia';

  @override
  String get collectionEquipped => 'Equipaggiato';

  @override
  String get collectionEquippedCard => 'Carta equipaggiata';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Carta equipaggiata: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Equipaggiato: $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Equipaggiata: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Skin ricompensa escluse';

  @override
  String get collectionExpressionsHint =>
      'Tocca uno slot per scegliere un graffito o un Flex.';

  @override
  String get collectionExpressionsSlots => 'Slot della ruota';

  @override
  String get collectionExpressionsTitle => 'Ruota delle espressioni';

  @override
  String get collectionHideAccountLevel => 'Nascondi livello account';

  @override
  String get collectionHideAccountLevelHint =>
      'Gli altri giocatori non vedranno il livello del tuo account.';

  @override
  String get collectionIncognito => 'Modalità incognito';

  @override
  String get collectionIncognitoHint =>
      'Nascondi il tuo nome ai giocatori fuori dal tuo gruppo durante le partite.';

  @override
  String get collectionLevelBorderAuto => 'Automatico in base al livello';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Dal livello $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Livello account $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Scegli bordo livello';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Livello $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Livello $n · $type';
  }

  @override
  String get collectionLevels => 'Livelli';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Livelli sbloccati: $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'Banner nella lobby';

  @override
  String get collectionLocked => 'Bloccato';

  @override
  String get collectionMeleeNoBuddy =>
      'Le armi corpo a corpo non possono avere un ciondolo.';

  @override
  String get collectionMove => 'Sposta';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy è agganciato a $from. Spostarlo su $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Spostare il ciondolo?';

  @override
  String get collectionNoBuddies => 'Non hai ancora nessun ciondolo.';

  @override
  String get collectionNoBuddy => 'Nessun ciondolo';

  @override
  String get collectionNoFlex => 'Non hai ancora nessun oggetto Flex.';

  @override
  String get collectionNoResults => 'Nessun risultato corrispondente.';

  @override
  String get collectionNoResultsTitle => 'Nessun risultato';

  @override
  String get collectionNoSkinsForWeapon =>
      'Non hai ancora nessuna skin per quest\'arma.';

  @override
  String get collectionNoSprays => 'Non hai ancora nessun graffito.';

  @override
  String get collectionNoTitle => 'Nessun titolo';

  @override
  String get collectionOtherWeapons => 'Altro';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin possedute',
      one: '$n skin posseduta',
      zero: 'Ancora nessuna skin',
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
      other: '$nString skin possedute',
      one: '$nString skin posseduta',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Guarda il video di questo livello';

  @override
  String get collectionPlayVideo => 'Guarda video';

  @override
  String get collectionPlayerCardSubtitle =>
      'Mostrata nella lobby, nel tabellone e quando elimini un nemico.';

  @override
  String get collectionPlayerCardTitle => 'Cambia carta giocatore';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Mostrato sotto il tuo nome nella lobby e in partita.';

  @override
  String get collectionPlayerTitleTitle => 'Cambia titolo giocatore';

  @override
  String get collectionPresetActions => 'Opzioni';

  @override
  String collectionPresetApplied(String name) {
    return '“$name” applicato';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n equipaggiamenti',
      one: '$n equipaggiamento',
      zero: 'Ancora nessuno',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '“$name” eliminato';
  }

  @override
  String get collectionPresetNameHint => 'Es.: Scalata di grado';

  @override
  String get collectionPresetNameTitle => 'Nome dell\'equipaggiamento';

  @override
  String collectionPresetSaved(String name) {
    return '“$name” salvato';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Salvato il $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Saltati $n oggetti che non possiedi più.',
      one: 'Saltato $n oggetto che non possiedi più.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Salva l\'equipaggiamento attuale per passare velocemente tra set di skin, carte e ruote delle espressioni in seguito.';

  @override
  String get collectionPresetsEmptyTitle =>
      'Ancora nessun equipaggiamento salvato';

  @override
  String get collectionPresetsFull =>
      'Hai raggiunto il massimo di 50 equipaggiamenti. Eliminane qualcuno per salvarne altri.';

  @override
  String get collectionPresetsNote =>
      'Gli equipaggiamenti vengono salvati solo su questo dispositivo, per l\'account selezionato.';

  @override
  String get collectionPresetsTitle => 'Equipaggiamenti salvati';

  @override
  String get collectionPreview => 'Anteprima';

  @override
  String get collectionRemoveBuddy => 'Rimuovi ciondolo';

  @override
  String get collectionRenamePreset => 'Rinomina';

  @override
  String get collectionRowExpressions => 'Ruota delle espressioni';

  @override
  String get collectionRowLevelBorder => 'Bordo livello';

  @override
  String get collectionRowPresets => 'Equipaggiamenti salvati';

  @override
  String get collectionRowWeapons => 'Equipaggiamento armi';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Impossibile salvare l\'equipaggiamento';

  @override
  String get collectionSavePreset => 'Salva equipaggiamento attuale';

  @override
  String get collectionSaving => 'Salvataggio…';

  @override
  String get collectionSearchBuddies => 'Cerca ciondoli…';

  @override
  String get collectionSearchCards => 'Cerca carte giocatore…';

  @override
  String get collectionSearchFlex => 'Cerca Flex…';

  @override
  String get collectionSearchItems => 'Cerca…';

  @override
  String get collectionSearchSkins => 'Cerca skin…';

  @override
  String get collectionSearchSprays => 'Cerca graffiti…';

  @override
  String get collectionSearchTitles => 'Cerca titoli…';

  @override
  String get collectionSearchWeapons => 'Cerca armi, skin o ciondoli…';

  @override
  String get collectionSectionBrowse => 'Sfoglia collezione';

  @override
  String get collectionSectionIdentity => 'Visibile agli altri giocatori';

  @override
  String get collectionSectionLoadout => 'Equipaggiamento';

  @override
  String get collectionSkinCustomizeTitle => 'Personalizza skin';

  @override
  String get collectionSkinNotFound => 'Impossibile trovare questa skin.';

  @override
  String get collectionSkinNotOwned => 'Non possiedi ancora questa skin.';

  @override
  String get collectionSlotNamesItem0 => 'In alto';

  @override
  String get collectionSlotNamesItem1 => 'Destra';

  @override
  String get collectionSlotNamesItem2 => 'In basso';

  @override
  String get collectionSlotNamesItem3 => 'Sinistra';

  @override
  String get collectionSortName => 'Nome';

  @override
  String get collectionSortPrice => 'Prezzo';

  @override
  String get collectionSortRarity => 'Rarità';

  @override
  String get collectionSortWeapon => 'Arma';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return 'Con filtri: $count skin · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Con filtri: oggetti $count/$total';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oggetti',
      one: '$count oggetto',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count skin · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Graffiti';

  @override
  String get collectionTapToChangeCard => 'Tocca per cambiare carta';

  @override
  String get collectionTitle => 'Collezione';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString titoli posseduti',
      one: '$nString titolo posseduto',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Annulla';

  @override
  String get collectionUnknownCard => 'Carta sconosciuta';

  @override
  String get collectionValueAtStorePrices => 'In base ai prezzi del negozio';

  @override
  String get collectionValueHasEstimates => 'Include stime (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin ricompensa non conteggiate',
      one: '$n skin ricompensa non conteggiata',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Vedi le skin';

  @override
  String collectionValueSkinCount(int n) {
    return 'Calcolato su $n skin';
  }

  @override
  String get collectionVariants => 'Varianti';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'Armi con skin: $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Equipaggiamento armi';

  @override
  String get collectionWeaponNotFound => 'Impossibile trovare quest\'arma.';

  @override
  String get collectionWeaponSkinsTitle => 'Scegli skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin',
      one: '$n skin',
      zero: 'Vuota',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Impossibile pubblicare a causa di un linguaggio inappropriato. Modifica il post e riprova.';

  @override
  String get communityModerationContentScam =>
      'La community non consente annunci di vendita di account, servizi di boosting o numeri di telefono. Rimuovi questi contenuti e riprova.';

  @override
  String get communityModerationContentTooComplex =>
      'Il tuo post contiene troppi caratteri sparsi. Scrivi in modo più semplice e riprova.';

  @override
  String get communityModerationAccountBanned =>
      'Questo account è stato bandito dalla community. Se pensi che si tratti di un errore, contatta ValHub in Info e note legali.';

  @override
  String get communityModerationAccountRestricted =>
      'Questo account non può pubblicare, commentare, cercare compagni di squadra o votare. Riprova più tardi o contatta ValHub in Info e note legali.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitiva',
      'unrated': 'Non competitiva',
      'swiftplay': 'Partita rapida',
      'spikerush': 'Assalto Spike',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Deathmatch a squadre',
      'premier': 'Premier',
      'custom': 'Personalizzata',
      'other': 'Altro',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asia-Pacifico',
      'na': 'Nord America',
      'eu': 'Europa',
      'kr': 'Corea',
      'latam': 'America Latina',
      'br': 'Brasile',
      'other': 'Regione sconosciuta',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle =>
      'Ancora nessuna skin in questa classifica';

  @override
  String get communityRankingEmptyVotes => 'Ancora nessun preferito.';

  @override
  String get communityRankingEmptyRatings =>
      'Ancora nessuna valutazione a stelle.';

  @override
  String get communityRankingEmptyReviews => 'Ancora nessuna recensione.';

  @override
  String get communityRankingExplore => 'Trova skin da vedere e valutare';

  @override
  String get communityRankingExploreHint =>
      'Cerca per nome della skin o dell\'arma. In classifica compaiono solo valutazioni reali della community.';

  @override
  String get communityRankingClear => 'Rimuovi filtro arma';

  @override
  String get communityRankingSort => 'Classifica per';

  @override
  String get communityRankingWeapon => 'Arma';

  @override
  String get communityRankingNoSearch =>
      'Nessuna skin corrispondente. Prova un altro nome.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Impossibile caricare il catalogo delle skin. Riprova più tardi.';

  @override
  String get communityConsentExitAccount => 'Rifiuta · Esci da questo account';

  @override
  String get communityRankingGlobalAllTime => 'Globale · Di sempre';

  @override
  String get communityRankingCatalogTitle => 'Tutte le skin';

  @override
  String get communityReviewOwnershipRequired =>
      'Il tuo account deve possedere questa skin per valutarla. Puoi comunque leggere valutazioni e commenti della community.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Impossibile verificare che possiedi questa skin. Ricarica la Collezione o riprova quando sei online.';

  @override
  String get communityReviewLegacyOwnership =>
      'Recensione precedente · Possesso non verificato';

  @override
  String get communityReviewVerifiedOwner =>
      'Possesso verificato al momento della recensione';

  @override
  String get communitySkinDiscussionHint =>
      'Tutti possono commentare. Solo chi possiede la skin può dare stelle e scrivere recensioni.';

  @override
  String get communityAddPhotos => 'Aggiungi foto';

  @override
  String get communityAllModes => 'Tutte';

  @override
  String get communityAllWeapons => 'Tutte le armi';

  @override
  String get communityAnonymousBanner => 'Navigazione anonima';

  @override
  String get communityAnyLanguage => 'Qualsiasi lingua';

  @override
  String get communityAnyRank => 'Qualsiasi grado';

  @override
  String get communityAnyRole => 'Qualsiasi ruolo';

  @override
  String get communityApply => 'Applica';

  @override
  String get communityBackToMyCountry => 'Torna al mio paese';

  @override
  String get communityBlockAuthor => 'Blocca su questo dispositivo';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Deseleziona';

  @override
  String get communityCodeAuto =>
      'Lascia vuoto: ValHub crea un codice dal tuo gruppo nel gioco quando pubblichi.';

  @override
  String get communityCodeAutoFailed =>
      'Impossibile creare un codice gruppo. Apri VALORANT o inserisci il codice manualmente.';

  @override
  String get communityCodeInvalid =>
      'Il codice deve avere esattamente 6 lettere maiuscole o cifre.';

  @override
  String get communityCodeRequired => 'Inserisci o crea un codice gruppo.';

  @override
  String get communityCommentHint => 'Scrivi un commento…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString commenti',
      one: '$nString commento',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Commenti · $n';
  }

  @override
  String get communityCommentsTitle => 'Commenti';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Post: $posts · Giocatori: $authors';
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
      other: '$nString annunci cerca compagni',
      one: '$nString annuncio cerca compagni',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Preferiti della community';

  @override
  String get communityComposerHint => 'Cosa pensi di VALORANT oggi?';

  @override
  String get communityComposerTitle => 'Nuovo post';

  @override
  String communityConsentAccount(String riotId) {
    return 'Account: $riotId';
  }

  @override
  String get communityConsentAgree => 'Accetta e continua';

  @override
  String get communityConsentGateAction => 'Partecipa';

  @override
  String get communityConsentGuidelines => 'Linee guida della community';

  @override
  String get communityConsentLater => 'Più tardi';

  @override
  String get communityConsentLocal =>
      'La tua password e gli altri dati di accesso restano sempre su questo dispositivo. Puoi revocare il consenso nelle Impostazioni.';

  @override
  String get communityConsentPrivacy => 'Informativa sulla privacy';

  @override
  String get communityConsentPublic =>
      'Gli altri vedranno il tuo Riot ID, la carta giocatore, il grado e il paese.';

  @override
  String get communityConsentTitle => 'Privacy e community di ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub invia il tuo accesso Riot al server della community per verificare il tuo Riot ID quando ti colleghi e per controllare il possesso delle skin quando salvi una recensione. Il server legge solo ciò che serve, elimina subito l\'accesso e non lo conserva mai.';

  @override
  String get communityConsentWithdrawn =>
      'Consenso revocato. Devi accettare di nuovo per continuare a usare l\'app.';

  @override
  String get communityCountriesTitle => 'Community per paese';

  @override
  String get communityCountryNamesAE => 'Emirati Arabi Uniti';

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
  String get communityCountryNamesAZ => 'Azerbaigian';

  @override
  String get communityCountryNamesBA => 'Bosnia ed Erzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Belgio';

  @override
  String get communityCountryNamesBG => 'Bulgaria';

  @override
  String get communityCountryNamesBH => 'Bahrein';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivia';

  @override
  String get communityCountryNamesBR => 'Brasile';

  @override
  String get communityCountryNamesBY => 'Bielorussia';

  @override
  String get communityCountryNamesCA => 'Canada';

  @override
  String get communityCountryNamesCH => 'Svizzera';

  @override
  String get communityCountryNamesCL => 'Cile';

  @override
  String get communityCountryNamesCN => 'Cina';

  @override
  String get communityCountryNamesCO => 'Colombia';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Cipro';

  @override
  String get communityCountryNamesCZ => 'Cechia';

  @override
  String get communityCountryNamesDE => 'Germania';

  @override
  String get communityCountryNamesDK => 'Danimarca';

  @override
  String get communityCountryNamesDO => 'Repubblica Dominicana';

  @override
  String get communityCountryNamesDZ => 'Algeria';

  @override
  String get communityCountryNamesEC => 'Ecuador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Egitto';

  @override
  String get communityCountryNamesES => 'Spagna';

  @override
  String get communityCountryNamesET => 'Etiopia';

  @override
  String get communityCountryNamesFI => 'Finlandia';

  @override
  String get communityCountryNamesFR => 'Francia';

  @override
  String get communityCountryNamesGB => 'Regno Unito';

  @override
  String get communityCountryNamesGE => 'Georgia';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Grecia';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croazia';

  @override
  String get communityCountryNamesHU => 'Ungheria';

  @override
  String get communityCountryNamesID => 'Indonesia';

  @override
  String get communityCountryNamesIE => 'Irlanda';

  @override
  String get communityCountryNamesIL => 'Israele';

  @override
  String get communityCountryNamesIN => 'India';

  @override
  String get communityCountryNamesIQ => 'Iraq';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Islanda';

  @override
  String get communityCountryNamesIT => 'Italia';

  @override
  String get communityCountryNamesJO => 'Giordania';

  @override
  String get communityCountryNamesJP => 'Giappone';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Cambogia';

  @override
  String get communityCountryNamesKR => 'Corea del Sud';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Kazakistan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Libano';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Lituania';

  @override
  String get communityCountryNamesLU => 'Lussemburgo';

  @override
  String get communityCountryNamesLV => 'Lettonia';

  @override
  String get communityCountryNamesLY => 'Libia';

  @override
  String get communityCountryNamesMA => 'Marocco';

  @override
  String get communityCountryNamesMD => 'Moldavia';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Macedonia del Nord';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolia';

  @override
  String get communityCountryNamesMO => 'Macao';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Messico';

  @override
  String get communityCountryNamesMY => 'Malaysia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Paesi Bassi';

  @override
  String get communityCountryNamesNO => 'Norvegia';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Nuova Zelanda';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Perù';

  @override
  String get communityCountryNamesPH => 'Filippine';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Polonia';

  @override
  String get communityCountryNamesPR => 'Porto Rico';

  @override
  String get communityCountryNamesPT => 'Portogallo';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Qatar';

  @override
  String get communityCountryNamesRO => 'Romania';

  @override
  String get communityCountryNamesRS => 'Serbia';

  @override
  String get communityCountryNamesRU => 'Russia';

  @override
  String get communityCountryNamesSA => 'Arabia Saudita';

  @override
  String get communityCountryNamesSE => 'Svezia';

  @override
  String get communityCountryNamesSG => 'Singapore';

  @override
  String get communityCountryNamesSI => 'Slovenia';

  @override
  String get communityCountryNamesSK => 'Slovacchia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Thailandia';

  @override
  String get communityCountryNamesTL => 'Timor Est';

  @override
  String get communityCountryNamesTN => 'Tunisia';

  @override
  String get communityCountryNamesTR => 'Turchia';

  @override
  String get communityCountryNamesTW => 'Taiwan';

  @override
  String get communityCountryNamesUA => 'Ucraina';

  @override
  String get communityCountryNamesUS => 'Stati Uniti';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Uzbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'Sudafrica';

  @override
  String get communityCreateLfg => 'Crea annuncio cerca compagni';

  @override
  String get communityCreateLfgShort => 'Pubblica';

  @override
  String get communityDataDeleted =>
      'I tuoi dati della community sono stati eliminati.';

  @override
  String communityDataFooter(String riotId) {
    return 'Si applica all\'account attuale: $riotId. Il file scaricato non contiene la tua password né i dati di accesso Riot.';
  }

  @override
  String get communityDecrease => 'Diminuisci';

  @override
  String get communityDelete => 'Elimina';

  @override
  String get communityDeleteComment => 'Elimina commento';

  @override
  String get communityDeleteCommentBody =>
      'Questo commento verrà eliminato definitivamente.';

  @override
  String get communityDeleteCommentTitle => 'Eliminare il commento?';

  @override
  String get communityDeleteDataConfirm => 'Elimina definitivamente';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Tutti i post, i commenti, le recensioni delle skin, i like, i voti, gli annunci cerca compagni e le foto di $riotId nella community di ValHub verranno eliminati definitivamente e non potranno essere recuperati. Per continuare a usare questo account in ValHub dovrai accettare di nuovo; puoi comunque passare a un altro account o disconnettere questo.\n\nIl tuo account Riot e i dati di gioco non vengono toccati. Scarica prima i tuoi dati se vuoi conservarne una copia.';
  }

  @override
  String get communityDeleteDataConfirmTitle =>
      'Eliminare i dati della community?';

  @override
  String get communityDeleteDataSubtitle =>
      'Elimina definitivamente tutto ciò che hai pubblicato nella community.';

  @override
  String get communityDeleteDataTitle => 'Elimina i miei dati della community';

  @override
  String get communityDeletePost => 'Elimina post';

  @override
  String get communityDeletePostBody =>
      'Questo post e tutti i suoi commenti verranno eliminati definitivamente.';

  @override
  String get communityDeletePostTitle => 'Eliminare il post?';

  @override
  String get communityDeleteReview => 'Elimina recensione';

  @override
  String get communityDeleteReviewBody =>
      'La tua valutazione e la tua recensione di questa skin verranno eliminate.';

  @override
  String get communityDeleteReviewTitle => 'Eliminare la tua recensione?';

  @override
  String get communityDeleted => 'Eliminato.';

  @override
  String get communityDiscard => 'Scarta';

  @override
  String get communityDiscardBody =>
      'Quello che hai appena scritto non verrà salvato.';

  @override
  String get communityDiscardTitle => 'Scartare il post?';

  @override
  String get communityDownload => 'Scarica e traduci';

  @override
  String get communityDownloadingModels => 'Download del pacchetto lingua…';

  @override
  String get communityEditReview => 'Modifica';

  @override
  String get communityEdited => 'modificato';

  @override
  String get communityEmptyPost => 'Scrivi qualcosa o aggiungi una foto.';

  @override
  String get communityExpired => 'Scaduto';

  @override
  String communityExpiresIn(String t) {
    return 'Scade tra $t';
  }

  @override
  String get communityExportPreparing => 'Preparazione…';

  @override
  String get communityExportSubject => 'Dati della community di ValHub';

  @override
  String get communityExportSubtitle =>
      'Una copia di tutto ciò che hai pubblicato nella community: post, commenti, recensioni, like, voti e annunci cerca compagni.';

  @override
  String get communityExportTitle => 'Scarica i miei dati';

  @override
  String get communityExtend => 'Estendi';

  @override
  String get communityExtended => 'Annuncio esteso di 30 minuti.';

  @override
  String get communityFeedEmptyBody =>
      'Condividi per primo il tuo negozio, il Mercato notturno o i tuoi momenti migliori!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Nessun post corrispondente. Prova un\'altra lingua o rimuovi i filtri.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Ancora nessun nuovo post. Torna più tardi o partecipa per condividere.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Prova i post della community internazionale o cambia i filtri.';

  @override
  String get communityFeedEmptyScopeTitle => 'Ancora nessun post qui';

  @override
  String get communityFeedEmptyTitle => 'Il feed è vuoto';

  @override
  String get communityFilters => 'Filtri';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Tradotto da Google';

  @override
  String get communityHelpful => 'Utile';

  @override
  String communityHelpfulCount(String n) {
    return 'Utile · $n';
  }

  @override
  String get communityHiddenAuthors => 'Giocatori nascosti e bloccati';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Non hai nascosto né bloccato nessuno';

  @override
  String get communityHiddenAuthorsHint =>
      'Vale solo per questo account su questo dispositivo. I loro contenuti vengono nascosti; possono comunque vedere i tuoi contenuti pubblici.';

  @override
  String communityImageOf(int i, int n) {
    return 'Foto $i/$n';
  }

  @override
  String get communityIncrease => 'Aumenta';

  @override
  String get communityJoin => 'Unisciti';

  @override
  String get communityJoinCodeExpired =>
      'Il codice gruppo è scaduto o non è più valido.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Lascerai il tuo gruppo attuale in VALORANT per unirti al gruppo di $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Unirti a questo gruppo?';

  @override
  String get communityJoinGameNotRunning =>
      'Apri VALORANT sul PC o sulla console e riprova.';

  @override
  String get communityJoinParty => 'Unisciti al gruppo';

  @override
  String get communityJoinPartyFull => 'Questo gruppo è al completo.';

  @override
  String get communityJoinedHint =>
      'Ti sei unito al gruppo! Apri VALORANT per giocare insieme.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString richieste di ingresso',
      one: '$nString richiesta di ingresso',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Mercato notturno';

  @override
  String get communityKindStore => 'Negozio di oggi';

  @override
  String get communityLanguage => 'Lingua';

  @override
  String get communityLanguageFilter => 'Lingua dei contenuti';

  @override
  String get communityLanguageFilterHint =>
      'Mostra solo i contenuti scritti nelle lingue selezionate. Lascia vuoto per vedere tutto.';

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
      other: '$n lingue',
      one: '$n lingua',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Crea un annuncio così gli altri giocatori possono unirsi al tuo gruppo con un tocco.';

  @override
  String get communityLfgEmptyTitle => 'Nessuno sta ancora cercando compagni';

  @override
  String get communityLfgExpiredRepost =>
      'Il tuo annuncio è scaduto. Creane uno nuovo per trovare compagni.';

  @override
  String get communityLfgGateBody =>
      'Partecipa (verifica il tuo Riot ID una volta) per vedere gli annunci dei giocatori del tuo server e pubblicare il tuo. Puoi comunque sfogliare il feed e la classifica delle skin come sempre.';

  @override
  String get communityLfgGateTitle => 'Cerca compagni è riservato ai membri';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Stai guardando il server $region — solo i giocatori sullo stesso server del tuo account possono unirsi ai gruppi.';
  }

  @override
  String get communityLfgPosted => 'Annuncio cerca compagni pubblicato!';

  @override
  String get communityLfgPreviewTitle => 'Trova compagni del tuo grado';

  @override
  String get communityLfgRemoved => 'Annuncio rimosso.';

  @override
  String get communityLfgSameShardNote =>
      'Solo i giocatori sullo stesso server possono unirsi al gruppo.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Regione: $region · Gli annunci scadono automaticamente dopo 30 minuti.';
  }

  @override
  String get communityLike => 'Mi piace';

  @override
  String get communityLiveMembers => 'Membri';

  @override
  String get communityMatchMyRank => 'Adatto al tuo grado';

  @override
  String communityMemberJoined(String name) {
    return '$name si è unito al gruppo';
  }

  @override
  String get communityMemberJoinedBody =>
      'Qualcuno si è appena unito tramite il tuo annuncio cerca compagni.';

  @override
  String get communityMic => 'Microfono richiesto';

  @override
  String get communityMicOn => 'Ha il microfono';

  @override
  String get communityMode => 'Modalità';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Altre opzioni';

  @override
  String get communityMuteAuthor => 'Nascondi questo giocatore';

  @override
  String get communityNewPost => 'Pubblica';

  @override
  String communityNightMarketOf(String date) {
    return 'Mercato notturno del $date';
  }

  @override
  String get communityNoAccountBody =>
      'Aggiungi un account Riot per pubblicare, cercare compagni e votare le skin.';

  @override
  String get communityNoAccountTitle => 'Accedi per partecipare';

  @override
  String get communityNoComments =>
      'Ancora nessun commento. Scrivi tu per primo!';

  @override
  String get communityNoRatings => 'Ancora nessuna valutazione';

  @override
  String get communityNote => 'Nota';

  @override
  String get communityNoteHint =>
      'Es.: serve 1 Stratega, con microfono, solo per divertirsi';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Totale $amount';
  }

  @override
  String get communityOpenReviews => 'Vedi recensioni';

  @override
  String get communityOutOfRange => 'Fuori dall\'intervallo di grado';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Codice gruppo';

  @override
  String get communityPartyCodeHint => 'Es.: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Codice gruppo: $code';
  }

  @override
  String get communityPartySize => 'Gruppo attuale';

  @override
  String get communityPartySizeFromGame => 'Preso dal tuo gruppo nel gioco';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giocatori',
      one: '$n giocatore',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max foto';
  }

  @override
  String get communityPlayVideo => 'Guarda video';

  @override
  String get communityPostLfg => 'Pubblica';

  @override
  String get communityPostNotFound =>
      'Questo post è stato eliminato o nascosto.';

  @override
  String get communityPostTitle => 'Post';

  @override
  String get communityPosted => 'Pubblicato!';

  @override
  String get communityPublish => 'Pubblica';

  @override
  String get communityPublishing => 'Pubblicazione…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Da';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Intervallo di grado';

  @override
  String get communityRankRangeInvalid =>
      'Il grado minimo non può essere più alto del grado massimo.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Posizione $n: $name';
  }

  @override
  String get communityRankTo => 'A';

  @override
  String get communityRateLimitedTitle => 'Aspetta un momento';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString valutazioni',
      one: '$nString valutazione',
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
      other: '$nString valutazioni',
      one: '$nString valutazione',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Pessima';

  @override
  String get communityRatingWordsItem1 => 'Mediocre';

  @override
  String get communityRatingWordsItem2 => 'Discreta';

  @override
  String get communityRatingWordsItem3 => 'Bella';

  @override
  String get communityRatingWordsItem4 => 'Capolavoro';

  @override
  String get communityRefreshList => 'Aggiorna';

  @override
  String get communityRegion => 'Regione';

  @override
  String get communityRemoveAttachment => 'Rimuovi allegato';

  @override
  String get communityRemoveLfg => 'Rimuovi annuncio';

  @override
  String get communityRemoveLfgBody =>
      'Gli altri giocatori non vedranno più questo annuncio.';

  @override
  String get communityRemoveLfgTitle => 'Rimuovere l\'annuncio cerca compagni?';

  @override
  String get communityRemovePhoto => 'Rimuovi foto';

  @override
  String get communityReport => 'Segnala';

  @override
  String get communityReportConfirmBody =>
      'I contenuti segnalati da molti giocatori verranno nascosti dalla community.';

  @override
  String get communityReportConfirmTitle => 'Inviare la segnalazione?';

  @override
  String get communityReportPrompt => 'Perché segnali questo contenuto?';

  @override
  String get communityReportReasonsSpam => 'Spam o pubblicità';

  @override
  String get communityReportReasonsHarassment => 'Molestie o insulti';

  @override
  String get communityReportReasonsInappropriate => 'Contenuto inappropriato';

  @override
  String get communityReportReasonsScam => 'Truffa o vendita di account';

  @override
  String get communityReportReasonsOther => 'Altro motivo';

  @override
  String get communityReportTitle => 'Segnala contenuto';

  @override
  String get communityReported =>
      'Grazie! La tua segnalazione è stata inviata.';

  @override
  String get communityReviewDeleted => 'Recensione eliminata.';

  @override
  String get communityReviewHint =>
      'Condividi cosa pensi di questa skin (facoltativo)';

  @override
  String get communityReviewSaved => 'Recensione salvata!';

  @override
  String get communityReviewTitle => 'Valuta skin';

  @override
  String get communityReviewsEmptyBody =>
      'Ancora nessuna recensione — scrivi tu la prima!';

  @override
  String get communityReviewsEmptyTitle => 'Ancora nessuna recensione';

  @override
  String communityReviewsHeader(String n) {
    return 'Recensioni · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot ha qualche problema';

  @override
  String get communityRoleFlex => 'Flessibile';

  @override
  String get communityRoles => 'Ruoli cercati';

  @override
  String get communitySaveReview => 'Salva recensione';

  @override
  String get communityScopeCountry => 'Il tuo paese';

  @override
  String get communityScopeGlobal => 'Internazionale';

  @override
  String get communityScopeRegion => 'Regione';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Cerca compagni';

  @override
  String get communitySectionSkins => 'Classifica skin';

  @override
  String get communitySend => 'Invia';

  @override
  String get communitySendComment => 'Invia commento';

  @override
  String get communityShareNightMarketHint =>
      'Mostra a tutti il tuo Mercato notturno';

  @override
  String communitySharePostTitle(String name) {
    return 'Post di $name su ValHub';
  }

  @override
  String get communityShareStore => 'Condividi nella community';

  @override
  String get communityShareStoreHint => 'Mostra a tutti il negozio di oggi';

  @override
  String get communityShowOriginal => 'Mostra originale';

  @override
  String get communityShowTranslation => 'Mostra traduzione';

  @override
  String get communitySignInToReview =>
      'Aggiungi un account Riot per valutare le skin.';

  @override
  String get communitySkinNotFound => 'Impossibile trovare questa skin.';

  @override
  String get communitySlots => 'Giocatori cercati';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Un gruppo ha al massimo 5 giocatori: restano solo $max posti.',
      one: 'Un gruppo ha al massimo 5 giocatori: resta solo $max posto.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Servono $n giocatori',
      one: 'Serve $n giocatore',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Più utili';

  @override
  String get communitySortNewest => 'Più recenti';

  @override
  String get communitySortRating => 'Più votate';

  @override
  String get communitySortReviews => 'Più recensite';

  @override
  String get communitySortVotes => 'Più amate';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stelle',
      one: '$n stella',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg su 5 stelle';
  }

  @override
  String get communityStatusFull => 'Al completo';

  @override
  String get communityStatusInGame => 'In partita';

  @override
  String get communityStatusOpen => 'In cerca';

  @override
  String communityStoreOf(String date) {
    return 'Negozio del $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Tocca le stelle per valutare questa skin';

  @override
  String get communityTitle => 'Community';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Massimo $max caratteri.',
      one: 'Massimo $max carattere.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Traduci con Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Per tradurre da $from a $to, ValHub deve scaricare un pacchetto lingua da Google (circa $size). Lo scarichi una sola volta; i contenuti vengono tradotti interamente sul tuo dispositivo e non vengono inviati a nessun server.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Scaricare il pacchetto lingua sul dispositivo?';

  @override
  String get communityTranslateFailed => 'Impossibile tradurre. Riprova.';

  @override
  String get communityTranslatedByGoogle =>
      'Tradotto automaticamente da Google';

  @override
  String get communityTranslating => 'Traduzione…';

  @override
  String get communityTrendingTitle => 'Le skin più amate nel mondo';

  @override
  String get communityUnavailableBody =>
      'Impossibile collegarsi alla community di ValHub. Riprova tra qualche minuto.';

  @override
  String get communityUnavailableTitle =>
      'Impossibile collegarsi alla community';

  @override
  String get communityUnhideAuthor => 'Mostra / sblocca';

  @override
  String get communityUnknownPlayer => 'Giocatore';

  @override
  String get communityUnlike => 'Non mi piace più';

  @override
  String get communityUnvote => 'Togli cuore';

  @override
  String get communityVote => 'Metti un cuore a questa skin';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString Mi piace';
  }

  @override
  String get communityWithdrawConfirm => 'Revoca';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub smetterà di usare la community con $riotId e rimuoverà il collegamento alla community su questo dispositivo. Per continuare a usare questo account in ValHub dovrai accettare di nuovo; puoi comunque passare a un altro account o disconnettere questo.\n\nI post, i commenti, le recensioni, i voti e gli annunci cerca compagni che hai pubblicato restano nella community e continuano a mostrare il tuo Riot ID finché non li elimini uno per uno o scegli \"Elimina i miei dati della community\".';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Revocare il consenso?';

  @override
  String get communityWithdrawSubtitle =>
      'Smetti di usare la community con questo account. I tuoi post restano.';

  @override
  String get communityWithdrawTitle => 'Revoca consenso';

  @override
  String get communityWriteFirstReview => 'Scrivi la prima recensione';

  @override
  String get communityYou => 'Tu';

  @override
  String get communityYourCountry => 'Il tuo paese';

  @override
  String get communityYourReview => 'La tua recensione';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString persone nascoste',
      one: '$nString persona nascosta',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgOtherServer => 'Non è il tuo server';

  @override
  String get communityLfgEmptyRankTitle => 'Nessun annuncio per il tuo grado';

  @override
  String get communityLfgEmptyRankBody =>
      'Gli annunci che non accettano il tuo grado sono nascosti.';

  @override
  String get communityLfgShowAllRanks => 'Mostra tutti i gradi';

  @override
  String communityRankingCatalogWeaponTitle(String weapon) {
    return 'Tutte le skin $weapon';
  }

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Tu: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Selezione agente';

  @override
  String get liveGameAnonymous => 'Anonimo';

  @override
  String get liveGameAutoRefreshNote =>
      'Si aggiorna automaticamente quando sei in partita.';

  @override
  String get liveGameCurrentGame => 'Partita in corso';

  @override
  String get liveGameEmptyTeam => 'Ancora nessun giocatore.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'La squadra nemica comparirà all\'inizio della partita.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Squadra nemica: bloccati $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'K/D/A e tabellone arrivano a fine partita.';

  @override
  String get liveGameFinalScoreboard => 'Tabellone finale';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'Nella lobby';

  @override
  String get liveGameInMatch => 'In partita';

  @override
  String get liveGameInQueue => 'In coda';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'In coda · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Livello $n';
  }

  @override
  String get liveGameLiveScore => 'Punteggio in diretta';

  @override
  String get liveGameLoadoutFromAgentSelect =>
      'Equipaggiamento dalla selezione agente';

  @override
  String get liveGameLoadoutFromMatch => 'Equipaggiamento in questa partita';

  @override
  String get liveGameLobbyHint =>
      'Quando viene trovata una partita, ValHub mostra le formazioni e i gradi di tutti.';

  @override
  String get liveGameLockedTag => 'Bloccato';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub riproverà automaticamente. Di solito il tabellone è pronto in circa un minuto.';

  @override
  String get liveGameNoAgentYet => 'Nessun agente selezionato';

  @override
  String get liveGameNoLoadout =>
      'Nessuna informazione sull\'equipaggiamento di questo giocatore.';

  @override
  String get liveGameNotInGame => 'Non in partita';

  @override
  String get liveGameNotInGameHint =>
      'Apri VALORANT e mettiti in coda — i dettagli della partita compariranno qui automaticamente quando arrivi alla selezione agente.';

  @override
  String get liveGameNotInGameTitle => 'Non sei in nessuna partita';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Vedi l\'equipaggiamento di $name';
  }

  @override
  String get liveGameOpenParty => 'Apri gruppo e coda';

  @override
  String get liveGameParty => 'Gruppo';

  @override
  String liveGamePeak(String rank) {
    return 'Massimo: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Equipaggiamento di $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Equipaggiamento';

  @override
  String get liveGameQueueHint =>
      'Tieni l\'app aperta — i dettagli della partita compariranno appena viene trovata una partita.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Abbandonare la partita può comportare penalità (perdita di RR, blocco della coda). Vuoi abbandonare comunque?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Uscire durante la selezione agente può comportare penalità (perdita di RR, blocco della coda). Vuoi uscire comunque?';

  @override
  String get liveGameQuitConfirmTitle => 'Abbandonare la partita?';

  @override
  String get liveGameQuitDone => 'Hai abbandonato la partita.';

  @override
  String get liveGameQuitFailed => 'Impossibile abbandonare la partita.';

  @override
  String get liveGameQuitMatch => 'Abbandona partita';

  @override
  String get liveGameQuitMatchChanged =>
      'La partita è passata a una nuova fase mentre confermavi. Non hai abbandonato; riprova.';

  @override
  String get liveGameRankUnavailable => 'Grado sconosciuto';

  @override
  String get liveGameRefresh => 'Aggiorna';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Aggiornamento tra $seconds secondi',
      one: 'Aggiornamento tra $seconds secondo',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Aggiorna ora';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Dettagli partita';

  @override
  String get liveGameSprays => 'Graffiti';

  @override
  String get liveGameStatusAgentSelect => 'Selezione agente';

  @override
  String get liveGameStatusEnded => 'Terminata';

  @override
  String get liveGameStatusInProgress => 'In corso';

  @override
  String get liveGameStatusUnavailable =>
      'Impossibile aggiornare lo stato della partita';

  @override
  String get liveGameTabAllPlayers => 'Giocatori';

  @override
  String get liveGameTabEnemyTeam => 'Squadra nemica';

  @override
  String get liveGameTabYourTeam => 'La tua squadra';

  @override
  String liveGameTimeLeft(String t) {
    return 'Mancano $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Vedi dettagli partita';

  @override
  String get liveGameWeapons => 'Armi';

  @override
  String get liveGameYou => 'TU';

  @override
  String liveGameYouHover(String agent) {
    return 'Stai selezionando $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Hai bloccato $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Scegli e blocca il tuo agente in VALORANT. ValHub mostra solo il tempo rimasto e la tua squadra.';

  @override
  String get liveGameLastMatchTitle => 'Ultima partita';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vittorie',
      one: '$wins vittoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses sconfitte',
      one: '$losses sconfitta',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws pareggi',
      one: ' – $draws pareggio',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown partite con esito sconosciuto',
      one: ' – $unknown partita con esito sconosciuto',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'ora del dispositivo ($offset)';
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
      'yes': ' con $weapon',
      'other': '',
    });
    return '$killer ha eliminato $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 giorni',
      'days7': '7 giorni',
      'other': 'Sempre',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agenti',
      'maps': 'Mappe',
      'queues': 'Modalità',
      'sides': 'Attacco / Difesa',
      'trend': 'Andamento',
      'other': 'Modalità',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Tutte le modalità';

  @override
  String get profileAbility => 'Abilità';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n partite',
      one: '$n partita',
    );
    return '≈ $_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Punteggio di combattimento medio';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vittorie',
      one: '$wins vittoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games partite',
      one: '$games partita',
    );
    return 'Questo atto: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Tutti i giocatori';

  @override
  String get profileAlreadyReached => 'Hai già raggiunto questo grado.';

  @override
  String get profileAtCurrentForm => 'Con la forma attuale';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Con la forma attuale ($gain / $loss a partita)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Nel migliore dei casi: $n vittorie di fila',
      one: 'Nel migliore dei casi: $n vittoria di fila',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Per percentuale di vittorie';

  @override
  String get profileChooseMap => 'Filtra per mappa';

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
  String get profileCopyRiotId => 'Copia Riot ID';

  @override
  String get profileCurrentRank => 'Attuale';

  @override
  String get profileDailyRrEmpty =>
      'Ancora nessuna partita Competitiva salvata su questo dispositivo.';

  @override
  String get profileDailyRrFootnote =>
      'La cronologia RR viene salvata direttamente sul tuo dispositivo, comprese le partite che Riot non restituisce più.';

  @override
  String get profileDailyRrTitle => 'RR giornalieri';

  @override
  String profileDayBoundary(String zone) {
    return 'Fuso orario dei giorni: $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giorni giocati',
      one: '$n giorno giocato',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Tutte le partite mostrate';

  @override
  String get profileEnemyTeam => 'Squadra nemica';

  @override
  String get profileFallDamage => 'Danni da caduta';

  @override
  String get profileFilterAll => 'Tutte';

  @override
  String get profileFirstBloods => 'First blood';

  @override
  String get profileFirstDeaths => 'Prime morti';

  @override
  String get profileFirstHalf => 'Primo tempo';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS e HS% contano solo le modalità a round.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '$n partite dell\'elenco non sono ancora state caricate per queste statistiche.',
      one:
          '$n partita dell\'elenco non è ancora stata caricata per queste statistiche.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR e HS% contano solo le partite a round: $roundGames/$games';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games partite recenti',
      one: '$games partita recente',
    );
    String _temp1 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w vittorie',
      one: '$w vittoria',
    );
    String _temp2 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l sconfitte',
      one: '$l sconfitta',
    );
    return '$_temp0: $_temp1, $_temp2';
  }

  @override
  String get profileFriendsRow => 'Amici e chat';

  @override
  String get profileHideKills => 'Nascondi uccisioni';

  @override
  String get profileHitBody => 'Corpo';

  @override
  String get profileHitDistribution => 'Distribuzione dei colpi';

  @override
  String get profileHitHead => 'Testa';

  @override
  String get profileHitLegs => 'Gambe';

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
      'Percentuale di round in cui hai ottenuto un\'uccisione o un assist, sei sopravvissuto o sei stato vendicato';

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
      other: 'Ultimi $n giorni',
      one: 'Ultimo $n giorno',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ultime $n partite',
      one: 'Ultima $n partita',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Classifica #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Livello $n';
  }

  @override
  String get profileLevelHidden => 'Livello nascosto';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sconfitte di fila',
      one: '$n sconfitta di fila',
    );
    return '$_temp0';
  }

  @override
  String profileMapFilter(String map) {
    return 'Mappa: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n partite',
      one: '$n partita',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Dettagli partita';

  @override
  String get profileMatchHistory => 'Cronologia partite';

  @override
  String get profileMatchUnavailable => 'Impossibile caricare la partita';

  @override
  String get profileMatchesNeeded => 'Partite necessarie';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Mai classificato';

  @override
  String get profileNoKillsInRound =>
      'Ancora nessuna informazione sulle uccisioni in questo round.';

  @override
  String get profileNoMatches => 'Ancora nessuna partita.';

  @override
  String get profileNoMatchesMap =>
      'Nessuna partita su questa mappa tra quelle caricate.';

  @override
  String get profileNoMatchesQueue => 'Nessuna partita in questa modalità.';

  @override
  String get profileNoPlayers =>
      'Ancora nessuna informazione sui giocatori di questa partita.';

  @override
  String get profileNoRounds =>
      'Ancora nessuna informazione round per round su questa partita.';

  @override
  String get profileOvertime => 'Supplementari';

  @override
  String get profilePlayHubTitle => 'Partita e gruppo';

  @override
  String get profilePeakRank => 'Massimo';

  @override
  String get profilePerformanceAttack => 'Attacco';

  @override
  String get profilePerformanceDefense => 'Difesa';

  @override
  String get profilePerformanceEmpty =>
      'Ancora nessuna partita registrata su questo dispositivo. Apri la cronologia partite per registrare le partite che hai giocato.';

  @override
  String get profilePerformanceNoMatches =>
      'Nessuna partita nel periodo selezionato.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n round registrati',
      one: '$n round registrato',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Le percentuali compaiono solo con almeno 3 partite. ACS, ADR, HS% e K/D contano solo le modalità a round.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Lato di attacco o difesa individuato in $known/$total round.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Cronologia su questo dispositivo, dal $date';
  }

  @override
  String get profilePerformanceTitle => 'Prestazioni';

  @override
  String profilePlacement(int n) {
    return '$n° posto';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike piazzata in $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Profilo giocatore';

  @override
  String get profilePlayerSummary => 'Prestazioni';

  @override
  String profileProgressTo(String rank) {
    return 'Progressi verso $rank';
  }

  @override
  String get profileProgressToTarget => 'Progressi verso il grado obiettivo';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Stima basata sulle partite Competitive recenti; non tiene conto delle partite di piazzamento né della protezione dalla retrocessione.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches partite per arrivare a $rank',
      one: '≈ $matches partita per arrivare a $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'Sei già Immortale o superiore — questo strumento arriva solo fino a Immortale 1.';

  @override
  String get profileRankUpNoForm =>
      'Nessuna partita Competitiva recente per stimare la tua forma.';

  @override
  String get profileRankUpOpen => 'Apri calcolatore di grado';

  @override
  String get profileRankUpTitle => 'Calcolatore di grado';

  @override
  String get profileRankUpUnranked =>
      'Completa le partite di piazzamento per usare il calcolatore di grado.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Tabellone Competitiva';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w vittorie',
      one: '$w vittoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l sconfitte',
      one: '$l sconfitta',
    );
    return 'Forma recente: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Forma recente';

  @override
  String get profileRecentMatches => 'Partite recenti';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}V · ${l}S · ${d}P',
      one: '${w}V · ${l}S · ${d}P',
      zero: '${w}V · ${l}S',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID copiato';

  @override
  String profileRound(int n) {
    return 'Round $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n uccisioni',
      one: '$n uccisione',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Round perso';

  @override
  String get profileRoundTimeline => 'Cronologia dei round';

  @override
  String get profileRoundWon => 'Round vinto';

  @override
  String get profileRoundsHint => 'Tocca un round per vedere ogni uccisione.';

  @override
  String profileRrLeft(String n) {
    return 'Ancora $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Andamento RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Tabellone';

  @override
  String get profileSecondHalf => 'Secondo tempo';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Mostra uccisioni';

  @override
  String get profileSideSwitch => 'Cambio lato';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Grado obiettivo';

  @override
  String get profileTeamBlue => 'Squadra blu';

  @override
  String get profileTeamMvp => 'MVP di squadra';

  @override
  String get profileTeamRed => 'Squadra rossa';

  @override
  String get profileTitle => 'Profilo';

  @override
  String profileToday(String text) {
    return 'Oggi: $text';
  }

  @override
  String get profileTodayNone => 'Nessuna partita Competitiva oggi';

  @override
  String get profileTruePeakLocal =>
      'In base alla cronologia su questo dispositivo';

  @override
  String get profileWeekdayShortItem0 => 'Lun';

  @override
  String get profileWeekdayShortItem1 => 'Mar';

  @override
  String get profileWeekdayShortItem2 => 'Mer';

  @override
  String get profileWeekdayShortItem3 => 'Gio';

  @override
  String get profileWeekdayShortItem4 => 'Ven';

  @override
  String get profileWeekdayShortItem5 => 'Sab';

  @override
  String get profileWeekdayShortItem6 => 'Dom';

  @override
  String get profileWinRate => 'Percentuale di vittorie';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vittorie di fila',
      one: '$n vittoria di fila',
    );
    return '$_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Il tuo grado';

  @override
  String get profileYourSummary => 'Le tue prestazioni';

  @override
  String get profileYourTeam => 'La tua squadra';

  @override
  String get profileYourWinRate => 'La tua percentuale di vittorie recente';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Modalità: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filtra per modalità';

  @override
  String get profilePerformancePerMatchTitle => 'Per partita';

  @override
  String get profilePerformancePerMatchHint =>
      'Tocca una barra per aprire quella partita.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Media $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Servono almeno 2 partite a round con questa statistica per disegnare il grafico.';

  @override
  String get profilePerformanceOpeningsTitle => 'Duelli d\'apertura';

  @override
  String get profilePerformanceOpeningWin => 'Duelli d\'apertura vinti';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Tra i round con la tua first blood o la tua prima morte, la quota di first blood.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'First blood per partita';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Prime morti per partita';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'Uccisioni multiple in un round';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 uccisioni',
      'k4': '4 uccisioni',
      'ace': 'Ace',
      'other': '2 uccisioni',
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
      other: 'Calcolato su $nString partite con dati completi sulle uccisioni.',
      one: 'Calcolato su $nString partita con dati completi sulle uccisioni.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Round vinti';

  @override
  String get profilePerformanceDrillHint =>
      'Tocca una riga per vedere solo quell\'agente, mappa o modalità.';

  @override
  String get profilePerformanceLoadOlder => 'Analizza partite precedenti';

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
          'ValHub analizza solo le partite aperte su questo dispositivo. Ogni tocco aggiunge fino a $nString partite precedenti.',
      one:
          'ValHub analizza solo le partite aperte su questo dispositivo. Ogni tocco aggiunge fino a $nString partita precedente.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder =>
      'Ricerca di partite precedenti…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analisi partite: $doneString/$totalString…';
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
      other: '$nString partite aggiunte all\'analisi.',
      one: '$nString partita aggiunta all\'analisi.',
      zero: 'Nessuna nuova partita da aggiungere.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot non conserva partite più vecchie.';

  @override
  String get profileEconomyTitle => 'Economia della tua squadra';

  @override
  String get profileEconomyHint =>
      'Tipo di acquisto in base al valore totale dell\'equipaggiamento della squadra a inizio round (convenzione vlr.gg per 5 giocatori): Eco sotto 5.000, Semi-eco sotto 10.000, Semi-buy sotto 20.000, Full buy da 20.000 crediti. Il primo round di ogni metà è Pistol.';

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

    return 'Vinti $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => 'Ultima sessione';

  @override
  String profileSessionDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String profileSessionTopAgent(String agent, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Più giocato: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      'Il tuo compagno per VALORANT: negozio giornaliero, wishlist, grado, partite, più account e una community di giocatori, direttamente sul tuo dispositivo.';

  @override
  String get legalBackToTop => 'Torna all\'inizio';

  @override
  String get legalConsentAnd => ' e ';

  @override
  String get legalConsentPrefix => 'Continuando, accetti ';

  @override
  String get legalConsentPrivacy => 'Informativa sulla privacy';

  @override
  String get legalConsentSuffix => ' di ValHub.';

  @override
  String get legalConsentTerms => 'Termini di utilizzo';

  @override
  String get legalContact => 'Contatti';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'CONTATTI';

  @override
  String legalEffectiveFrom(String date) {
    return 'In vigore dal $date';
  }

  @override
  String get legalLegalHeader => 'NOTE LEGALI';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Tutti i diritti riservati.';

  @override
  String get legalThirdPartyLicenses => 'Software di terze parti';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licenze del software open source usato da ValHub';

  @override
  String get legalTocTitle => 'INDICE';

  @override
  String legalVersion(String version) {
    return 'Versione $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Questo documento è attualmente mostrato in $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Impossibile leggere il documento legale. Riprova o contatta l\'assistenza.';

  @override
  String get legalTranslationNotice =>
      'Questa traduzione è fornita per comodità. In caso di differenze, prevale la versione in vietnamita.';

  @override
  String get settingsUiLanguageTitle => 'Lingua dell\'app';

  @override
  String get settingsLanguageFollowDevice => 'Usa la lingua del dispositivo';

  @override
  String get settingsLanguageSaveFailed =>
      'Impossibile salvare la lingua. Riprova.';

  @override
  String get settingsGeoCountry => 'Paese';

  @override
  String get settingsGeoSearchCountry => 'Cerca nome o codice del paese';

  @override
  String get settingsGeoSupportedOnly => 'Solo supporto confermato';

  @override
  String get settingsGeoUnknown => 'Supporto non verificato';

  @override
  String get settingsGeoRestricted => 'Con restrizioni';

  @override
  String get settingsGeoSeparate => 'Servizio separato';

  @override
  String get settingsGeoAvailable => 'Supportato';

  @override
  String get settingsGeoNotApplicable => 'Non applicabile';

  @override
  String get settingsGeoConnection => 'Connessione Riot';

  @override
  String get settingsGeoChooseRegion => 'Scegli regione';

  @override
  String get settingsGeoAuto => 'Automatica dall\'account';

  @override
  String get settingsGeoManual => 'Scegli manualmente';

  @override
  String get settingsGeoNoRegion => 'Impossibile rilevare la tua regione Riot';

  @override
  String get settingsGeoManualWarning =>
      'Questa opzione cambia solo il server a cui si collega ValHub. Non sposta la regione del tuo account Riot. ValHub controlla la connessione prima di salvare.';

  @override
  String get settingsGeoConnectionSaved => 'Connessione salvata';

  @override
  String get settingsGeoValidationFailed =>
      'Impossibile confermare il tuo account su questo server. Scegli di nuovo la regione.';

  @override
  String get settingsGeoHintOnly =>
      'Il paese serve solo per ricerche e suggerimenti. La regione di connessione segue il tuo account Riot.';

  @override
  String get settingsGeoSave => 'Controlla e salva';

  @override
  String get settingsGeoCancel => 'Annulla';

  @override
  String get settingsGeoLoading => 'Controllo della connessione…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Questa scelta viene usata per i nomi dei paesi, i suggerimenti e i prezzi VP stimati. La connessione al server e il paese dell\'account della community restano decisi da Riot.';

  @override
  String get settingsGeoCountryAutomatic =>
      'Usa il paese dell\'account o del dispositivo';

  @override
  String get settingsGeoSaveFailed => 'Impossibile salvare la scelta. Riprova.';

  @override
  String get settingsGeoAllRegions => 'Tutte le regioni';

  @override
  String get settingsGeoSuggestions => 'Suggerimenti';

  @override
  String get settingsGeoNoCountries => 'Nessun paese corrisponde al filtro.';

  @override
  String get settingsGeoActiveCountries => 'Attivi';

  @override
  String get settingsGeoAllCountries => 'Tutti i paesi';

  @override
  String get settingsGeoActivityUnavailable =>
      'Impossibile caricare l\'attività dei paesi. Puoi comunque scegliere da Tutti i paesi.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paesi',
      one: '$count paese',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Hai scelto $manual, ma Riot colloca il tuo account in $detected. Continuare a controllare questa connessione?';
  }

  @override
  String get settingsGeoUnverified =>
      'Impossibile verificare la connessione perché il server o la rete hanno problemi. Salvare questa scelta e riprovare più tardi?';

  @override
  String get settingsGeoContinue => 'Continua';

  @override
  String settingsGeoMismatch(String region) {
    return 'Hai scelto un server diverso da quello del tuo account ($region). Usare il server dell\'account?';
  }

  @override
  String get settingsGeoUseAuto => 'Usa automatica';

  @override
  String get settingsGeoKeepManual => 'Mantieni manuale';

  @override
  String get settingsGeoReviewConnection => 'Vedi connessione';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Ultimo controllo: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Controlla di nuovo';

  @override
  String get settingsPlatformMobile => 'Mobile';

  @override
  String get settingsPlatformOther => 'Altra piattaforma';

  @override
  String get settingsContentLanguageFollowApp => 'Uguale alla lingua dell\'app';

  @override
  String get settingsContentLanguageHint =>
      'Scegli la lingua dei nomi degli oggetti. Non cambia la lingua dell\'app né il tuo server Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Lingua: $language.';
  }

  @override
  String get settingsAboutRowSubtitle =>
      'Privacy, termini, copyright e contatti';

  @override
  String get settingsAboutTitle => 'Info e note legali';

  @override
  String get settingsAppearanceHeader => 'ASPETTO';

  @override
  String settingsBuildNumber(String build) {
    return 'Build $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Liberati $size';
  }

  @override
  String get settingsClearCache => 'Cancella dati temporanei';

  @override
  String get settingsClearCacheFailed =>
      'Impossibile cancellare i dati temporanei. Riprova.';

  @override
  String get settingsClearCacheSubtitle =>
      'Immagini e dati scaricati sul dispositivo, comprese le segnalazioni di errore registrate';

  @override
  String get settingsExportLog => 'Invia segnalazione di errore a ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Ancora niente da inviare. Usa l\'app per un po\' e riprova.';

  @override
  String get settingsExportLogSubtitle =>
      'Le segnalazioni di errore non contengono la tua password né i dati di accesso Riot.';

  @override
  String get settingsFeedback => 'Invia un feedback a ValHub';

  @override
  String get settingsFeedbackSubtitle =>
      'Apri la pagina dei feedback di ValHub';

  @override
  String get settingsItemLanguageEn => 'Inglese';

  @override
  String get settingsItemLanguageLabel => 'Nomi degli oggetti';

  @override
  String get settingsItemLanguagePickerTitle => 'Lingua dei nomi degli oggetti';

  @override
  String get settingsItemLanguageVi => 'Vietnamita';

  @override
  String get settingsLinkOpenFailed => 'Impossibile aprire il link. Riprova.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Segnalazione di errore';
  }

  @override
  String get settingsLogShareFailed =>
      'Impossibile inviare la segnalazione di errore. Riprova.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Quando apre il Mercato notturno';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Ti ricorda di girare le offerte del Mercato notturno';

  @override
  String get settingsNotifPermissionMissing =>
      'L\'app non ha il permesso di inviare notifiche.';

  @override
  String get settingsNotifStoreReset => 'Quando il negozio si aggiorna';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Ogni giorno alle $time';
  }

  @override
  String get settingsNotifWishlist => 'Quando appare una skin della wishlist';

  @override
  String get settingsNotificationsHeader => 'NOTIFICHE';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Apri automaticamente i dettagli partita';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Apri il pannello della partita in corso appena viene trovata una partita';

  @override
  String get settingsOptionOwnPrice => 'Prezzo del tuo pacchetto VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Non impostato — usa il listino della tua regione, se disponibile';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Piattaforma';

  @override
  String get settingsOptionShowLiveScore => 'Mostra punteggio in diretta';

  @override
  String get settingsOptionShowPeakRank =>
      'Mostra il grado massimo nei dettagli partita';

  @override
  String get settingsOptionShowPrice => 'Mostra prezzi stimati';

  @override
  String get settingsOptionShowPriceInfo => 'Come funzionano i prezzi stimati';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Accanto ai prezzi in VP, ad esempio $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Non c\'è ancora un listino verificato per la tua regione — inserisci il prezzo del tuo pacchetto VP.';

  @override
  String get settingsOptionsHeader => 'OPZIONI';

  @override
  String get settingsPhaseComplete => 'Completata';

  @override
  String get settingsPhaseInProgress => 'In corso';

  @override
  String get settingsPhaseScheduled => 'Programmata';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Si applica a $account';
  }

  @override
  String get settingsPlatformHint =>
      'Scegli PC, PlayStation o Xbox in base a dove giochi per vedere la cronologia partite corretta.';

  @override
  String get settingsPlatformPickerTitle => 'Scegli piattaforma';

  @override
  String get settingsPrimingBody =>
      'Attiva le notifiche per sapere quando il negozio si aggiorna e quando appare una skin della wishlist.';

  @override
  String get settingsPrimingEnable => 'Attiva notifiche';

  @override
  String get settingsPrimingFootnote =>
      'Puoi attivare o disattivare ogni tipo di notifica in qualsiasi momento nelle Impostazioni.';

  @override
  String get settingsPrimingLater => 'Più tardi';

  @override
  String get settingsPrimingPointNightMarket =>
      'Sappi quando apre il Mercato notturno';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Così puoi girare le offerte prima che scadano';

  @override
  String get settingsPrimingPointStore =>
      'Promemoria quando il negozio giornaliero si aggiorna';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Ti avvisa dopo l\'aggiornamento del negozio del tuo account';

  @override
  String get settingsPrimingPointWishlist =>
      'Avvisi quando appare una skin che stai cercando';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Controlla il negozio di tutti gli account, anche quando l\'app è chiusa';

  @override
  String get settingsPrimingTitle => 'Non perderti mai la skin che cerchi';

  @override
  String settingsRemovedAccount(String account) {
    return '$account rimosso';
  }

  @override
  String get settingsServerStatus => 'Stato dei server';

  @override
  String get settingsServerStatusMaintenance => 'In manutenzione';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n avvisi',
      one: '$n avviso',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Manutenzioni e problemi di VALORANT per server';

  @override
  String get settingsSessionLogTitle => 'Segnalazione di errore ValHub';

  @override
  String get settingsSeverityCritical => 'Critico';

  @override
  String get settingsSeverityInfo => 'Info';

  @override
  String get settingsSeverityWarning => 'Avviso';

  @override
  String get settingsSignedOutAll => 'Disconnesso da tutti gli account';

  @override
  String get settingsStatusAllGood => 'I server funzionano normalmente';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Nessun problema o manutenzione sul server $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Mostra meno';

  @override
  String get settingsStatusIssues => 'Riot sta risolvendo un problema';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Questo server ha $n avvisi di problemi.',
      one: 'Questo server ha $n avviso di problema.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Problema';

  @override
  String get settingsStatusKindMaintenance => 'Manutenzione';

  @override
  String get settingsStatusMaintenanceNow => 'Server in manutenzione';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Potresti non riuscire a giocare in questo momento, e ValHub potrebbe non riuscire a caricare le informazioni per un po\'.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Mostra altri $n aggiornamenti',
      one: 'Mostra $n altro aggiornamento',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Manutenzione in arrivo';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n manutenzioni annunciate da Riot.',
      one: '$n manutenzione annunciata da Riot.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Fonte: pagina di stato ufficiale di Riot Games. Gli orari sono mostrati nel fuso orario del tuo dispositivo.';

  @override
  String settingsStatusStarted(String when) {
    return 'Inizio: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Aggiornamento: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'AGGIORNAMENTI DA RIOT';

  @override
  String get settingsSupportHeader => 'ASSISTENZA';

  @override
  String settingsSwitchedTo(String account) {
    return 'Passato a $account';
  }

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemePickerTitle => 'Scegli tema';

  @override
  String get settingsThemeSystem => 'Predefinito di sistema';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Grado, cronologia partite, partite in diretta';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR per partita, gradi degli avversari';

  @override
  String get settingsWelcomeBulletStore =>
      'Negozio giornaliero, Mercato notturno e bundle';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Prezzi, rarità, conto alla rovescia dell\'aggiornamento';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist e notifiche';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Ricevi un avviso quando una skin che cerchi arriva nel tuo negozio';

  @override
  String get settingsWelcomeFootnote =>
      'Accedi dalla pagina ufficiale di Riot. ValHub salva la password solo se scegli di salvare i dati di accesso.';

  @override
  String get settingsWelcomeKicker => 'COMPAGNO PER VALORANT';

  @override
  String get settingsCountryPriceHeader => 'Paese e prezzi';

  @override
  String get settingsDataHeader => 'Dati sul dispositivo';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (Valutazioni: $count) · ',
      'other': '',
    });
    return 'Community: ${_temp0}Mi piace: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Aggiungi alla wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Nel negozio di: $accounts';
  }

  @override
  String get skinDetailHistoryDelete => 'Elimina cronologia negozio';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Eliminare tutti i giorni di negozio registrati per questo account su questo dispositivo?';

  @override
  String get skinDetailInWishlist => 'Nella wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Bloccato';

  @override
  String get skinDetailMute => 'Disattiva audio';

  @override
  String get skinDetailNotFound => 'Impossibile trovare questa skin.';

  @override
  String get skinDetailOwned => 'Posseduta';

  @override
  String get skinDetailPause => 'Pausa';

  @override
  String get skinDetailPlay => 'Riproduci';

  @override
  String get skinDetailPlayVideo => 'Guarda video';

  @override
  String get skinDetailRemoveFromWishlist => 'Rimuovi dalla wishlist';

  @override
  String get skinDetailTitle => 'Dettagli skin';

  @override
  String get skinDetailUnmute => 'Attiva audio';

  @override
  String get skinDetailUpgrades => 'Potenziamenti';

  @override
  String get skinDetailVariants => 'Varianti';

  @override
  String get skinDetailVideoError =>
      'Impossibile riprodurre il video. Controlla la connessione e riprova.';

  @override
  String skinDetailSeenDaily(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Nel tuo negozio $nString volte',
      one: 'Nel tuo negozio $nString volta',
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
      other: 'Mercato notturno $nString volte',
      one: 'Mercato notturno $nString volta',
    );
    return '$_temp0';
  }

  @override
  String get socialPresenceInMatch => 'In partita';

  @override
  String get socialPresenceAgentSelect => 'Selezione agente';

  @override
  String get socialPresenceQueue => 'In coda';

  @override
  String get socialPresenceLobby => 'Nella lobby';

  @override
  String get socialPresenceCustom => 'In una partita personalizzata';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Gruppo aperto',
      'other': 'Solo su invito',
    });
    return 'Giocatori: $size/$max · $_temp0';
  }

  @override
  String get socialAccept => 'Accetta';

  @override
  String get socialAcceptInGame => 'Accetta questo invito nel gioco.';

  @override
  String socialActionFailed(String message) {
    return 'Impossibile completare l\'operazione. $message';
  }

  @override
  String get socialAutoRefresh => 'Aggiornamento automatico';

  @override
  String get socialAway => 'Assente';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Annulla coda · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Annulla coda';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Il tuo gruppo non può mettersi in coda per $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Cambia coda';

  @override
  String get socialChatUnavailable => 'La chat è offline.';

  @override
  String get socialCloseParty => 'Chiudi gruppo';

  @override
  String get socialCodeInvalid =>
      'I codici gruppo contengono solo lettere e cifre.';

  @override
  String get socialConnecting => 'Connessione alla chat…';

  @override
  String get socialCopyCode => 'Copia';

  @override
  String get socialCurrentQueue => 'Selezionata';

  @override
  String get socialCustomGameLobby =>
      'Il tuo gruppo è in una lobby di partita personalizzata.';

  @override
  String get socialDecline => 'Rifiuta';

  @override
  String get socialDisableCode => 'Disattiva codice';

  @override
  String get socialEmptyChat => 'Ancora nessun messaggio. Saluta!';

  @override
  String get socialEmptyChatTitle => 'Inizia a chattare';

  @override
  String get socialFailedBadge => 'Non inviato';

  @override
  String get socialFilterAll => 'Tutti';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Non letti';

  @override
  String get socialFriendsPrivacyNote =>
      'L\'elenco amici e i messaggi arrivano direttamente da Riot. ValHub non li conserva da nessun\'altra parte.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total amici',
      one: '$total amico',
    );
    return '$_temp0 · $online online';
  }

  @override
  String get socialFriendsTitle => 'Amici e chat';

  @override
  String get socialGameNotRunningBody =>
      'Gruppo e coda funzionano solo mentre VALORANT è in esecuzione sul tuo PC o sulla tua console. Apri il gioco, poi trascina verso il basso per aggiornare.';

  @override
  String get socialGameNotRunningTitle =>
      'Apri VALORANT sul PC o sulla console';

  @override
  String get socialGenerateCode => 'Genera codice';

  @override
  String get socialIdleQueue => 'Pronto per la coda';

  @override
  String get socialInMatchBanner =>
      'Sei in partita. La coda si riapre quando la partita finisce.';

  @override
  String get socialInValorant => 'In VALORANT';

  @override
  String get socialInviteByRiotId => 'Invita con Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Invita giocatori che non sono ancora tuoi amici';

  @override
  String get socialInviteFriends => 'Invita amici';

  @override
  String socialInviteFrom(String name) {
    return 'Invito da $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Invita $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Il Riot ID di questo giocatore è sconosciuto, quindi non può ancora essere invitato.';

  @override
  String socialInviteSent(String name) {
    return 'Invito inviato a $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Invitato';
  }

  @override
  String get socialInvitesSection => 'Inviti';

  @override
  String get socialJoin => 'Unisciti';

  @override
  String get socialJoinConfirmBody =>
      'Lascerai il tuo gruppo attuale per unirti al gruppo con questo codice.';

  @override
  String get socialJoinConfirmTitle => 'Unirti a un altro gruppo?';

  @override
  String get socialJoinSection => 'Unisciti a un altro gruppo';

  @override
  String get socialJoinWithCode => 'Inserisci un codice per unirti';

  @override
  String get socialJoined => 'Ti sei unito al gruppo.';

  @override
  String socialLastOnline(String relative) {
    return 'Attivo $relative';
  }

  @override
  String get socialLeader => 'Leader';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Lascerai il tuo gruppo attuale e tornerai a giocare da solo.';

  @override
  String get socialLeaveConfirmTitle => 'Lasciare il gruppo?';

  @override
  String get socialLeaveParty => 'Lascia gruppo';

  @override
  String socialLevel(int n) {
    return 'Livello $n';
  }

  @override
  String get socialMatchFound => 'Partita trovata!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Membri ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Scrivi un messaggio…';

  @override
  String get socialMoreActions => 'Altre opzioni';

  @override
  String get socialNoCode =>
      'Genera un codice così gli amici possono unirsi velocemente al tuo gruppo.';

  @override
  String get socialNoCodeMember =>
      'Il leader del gruppo può generare un codice per inviti rapidi.';

  @override
  String get socialNoFilterResults =>
      'Nessun amico corrisponde a questo filtro.';

  @override
  String get socialNoFriends =>
      'Il tuo elenco amici Riot è vuoto. Aggiungi amici nel gioco.';

  @override
  String get socialNoFriendsTitle => 'Ancora nessun amico';

  @override
  String get socialNoOnlineFriends =>
      'Nessuno dei tuoi amici è online in VALORANT in questo momento.';

  @override
  String get socialNoSearchResults => 'Nessun amico corrispondente.';

  @override
  String get socialNoSearchResultsTitle => 'Nessun risultato';

  @override
  String get socialNotReady => 'Non pronto';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online da mobile';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Solo il leader del gruppo può cambiare la coda e avviare la ricerca della partita.';

  @override
  String get socialOpenParty => 'Apri gruppo';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Codice gruppo';

  @override
  String socialPartyCodeValue(String code) {
    return 'Codice gruppo: $code';
  }

  @override
  String get socialPartyInvite => 'Invito al gruppo';

  @override
  String socialPartyOf(int size, int max) {
    return 'Gruppo $size/$max';
  }

  @override
  String get socialPartyTitle => 'Gruppo e coda';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'Gruppo da $size';
  }

  @override
  String get socialPickQueueTitle => 'Scegli coda';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Ping migliore verso i server di gioco';

  @override
  String socialPlayingOther(String game) {
    return 'Sta giocando a $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'In gioco ($n)';
  }

  @override
  String get socialQueueLabel => 'Coda';

  @override
  String get socialQueueLocked =>
      'Non puoi cambiare coda mentre sei in partita.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Massimo $max giocatori',
      one: 'Massimo $max giocatore',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Impossibile verificare lo stato del gioco. Aggiorna per usare pronto e coda.';

  @override
  String get socialReady => 'Pronto';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Pronti $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'un membro ha un livello account troppo basso';

  @override
  String get socialReasonGeneric => 'il gruppo non soddisfa ancora i requisiti';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'il gruppo è troppo numeroso (massimo $max)';
  }

  @override
  String get socialReasonRankDisparity =>
      'la differenza di grado è troppo ampia per la Competitiva';

  @override
  String socialReasonRestricted(String time) {
    return 'il gruppo non può mettersi in coda (mancano $time)';
  }

  @override
  String get socialReconnecting => 'Chat disconnessa. Riconnessione…';

  @override
  String get socialRemoteNote =>
      'Le modifiche vengono inviate a Riot solo quando tocchi. ValHub non si mette mai in coda né blocca un agente al posto tuo.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name verrà rimosso dal tuo gruppo.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Rimuovere dal gruppo?';

  @override
  String get socialRemoveMember => 'Rimuovi dal gruppo';

  @override
  String socialRequestFrom(String name) {
    return '$name vuole unirsi al gruppo';
  }

  @override
  String get socialRequestsSection => 'Richieste di ingresso';

  @override
  String get socialRiotIdFieldHint => 'Nome#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Un Riot ID è formato da un nome (3–16 caratteri), un # e un tag (3–5 lettere o cifre).';

  @override
  String get socialSearchHint => 'Cerca per Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'In coda · $elapsed';
  }

  @override
  String get socialSend => 'Invia';

  @override
  String get socialSendFailed =>
      'Impossibile inviare il messaggio. Controlla la connessione e riprova.';

  @override
  String get socialSendInvite => 'Invia invito';

  @override
  String get socialShareCode => 'Condividi';

  @override
  String socialShareCodeText(String code) {
    return 'Unisciti al mio gruppo di VALORANT con il codice: $code';
  }

  @override
  String get socialShootingRange => 'Al Poligono';

  @override
  String get socialShowEveryone => 'Mostra tutti';

  @override
  String get socialStartQueue => 'Avvia coda';

  @override
  String get socialSuggestionsItem0 => 'Ciao!';

  @override
  String get socialSuggestionsItem1 => 'Facciamo qualche partita?';

  @override
  String get socialSuggestionsItem2 => 'Unisciti al mio gruppo!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n messaggi non letti',
      one: '$n messaggio non letto',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Annulla pronto';

  @override
  String get socialViewProfile => 'Vedi profilo';

  @override
  String get socialWaitingForConnection =>
      'Connessione… Potrai inviare messaggi appena collegato.';

  @override
  String get socialYou => 'Tu';

  @override
  String get socialPartyUnavailable =>
      'Impossibile sincronizzare il tuo gruppo. Aggiorna per riprovare.';

  @override
  String get socialAcceptConfirmBody =>
      'Lascerai il tuo gruppo attuale per unirti al gruppo che ti ha mandato l\'invito.';

  @override
  String get storeAccessoryEmpty =>
      'Il negozio degli accessori è vuoto al momento.';

  @override
  String get storeAccessoryEmptyTitle => 'Ancora nessun accessorio';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Da: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Si aggiorna tra $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Si aggiorna alle $wall';
  }

  @override
  String get storeAddToWishlist => 'Aggiungi alla wishlist';

  @override
  String get storeBackToBundles => 'Vedi i bundle in vendita';

  @override
  String get storeBundleBuySeparateLabel => 'Acquisto singolo';

  @override
  String get storeBundleDetailTitle => 'Dettagli bundle';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Scade alle $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Scade tra $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n oggetti',
      one: '$n oggetto',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Gratis';

  @override
  String get storeBundleItemsTitle => 'Oggetti nel bundle';

  @override
  String get storeBundleNotFound =>
      'Impossibile trovare questo bundle. Potrebbe essere scaduto.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle scaduto';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Oggetti posseduti: $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Prezzo del bundle';

  @override
  String get storeBundleSavingsLabel => 'Risparmi';

  @override
  String get storeBundleWholesaleOnly =>
      'Venduto solo come bundle completo, non singolarmente.';

  @override
  String get storeBundlesEmpty => 'Nessun bundle in vendita al momento.';

  @override
  String get storeBundlesEmptyTitle => 'Ancora nessun bundle';

  @override
  String get storeDailyEmpty => 'Oggi non ci sono skin nel negozio.';

  @override
  String get storeDailyEmptyTitle => 'Il negozio è vuoto';

  @override
  String storeDailyResetAt(String time) {
    return 'Si aggiorna ogni giorno alle $time';
  }

  @override
  String get storeDailyTotalLabel => 'Totale';

  @override
  String get storeNightMarketEmpty =>
      'Al momento non c\'è il Mercato notturno.';

  @override
  String get storeNightMarketEmptyTitle => 'Il Mercato notturno non è aperto';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Termina alle $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Termina tra $t';
  }

  @override
  String get storeNightMarketNote =>
      'Le offerte del Mercato notturno sono uniche per il tuo account e non possono essere aggiornate.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Risparmio totale $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Non girata';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Posseduto';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Già tuoi: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Rimuovi dalla wishlist';

  @override
  String get storeResetNotificationTitle => 'Il tuo negozio si è aggiornato';

  @override
  String storeResetsIn(String t) {
    return 'Si aggiorna tra $t';
  }

  @override
  String get storeSegmentAccessories => 'Accessori';

  @override
  String get storeSegmentBundles => 'Bundle';

  @override
  String get storeSegmentDaily => 'Giornaliero';

  @override
  String get storeSegmentNightMarket => 'Mercato notturno';

  @override
  String get storeShareButton => 'Condividi';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Negozio di oggi';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Mercato notturno';

  @override
  String get storeShareCardPriceNote =>
      'I prezzi convertiti sono solo stime basate sui pacchetti VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Risparmi $vp';
  }

  @override
  String get storeShareCardTagline => 'Il tuo compagno per VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Totale $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Fino alle $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Condividi il negozio di oggi';

  @override
  String get storeShareFailed => 'Impossibile creare l\'immagine. Riprova.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-negozio-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-mercato-notturno-$stamp.png';
  }

  @override
  String get storeShareImage => 'Condividi immagine';

  @override
  String get storeShareNightMarketTitle => 'Condividi Mercato notturno';

  @override
  String get storeSharePreparing => 'Caricamento immagini delle skin…';

  @override
  String get storeShareShowPrice => 'Mostra prezzi stimati';

  @override
  String get storeShareShowPriceHint =>
      'Convertiti in base al pacchetto VP più conveniente.';

  @override
  String get storeShareShowRiotId => 'Mostra il Riot ID nell\'immagine';

  @override
  String get storeShareShowRiotIdHint =>
      'Disattivato di default per proteggere la tua privacy.';

  @override
  String get storeShareSubjectDaily => 'Il mio negozio di VALORANT di oggi';

  @override
  String get storeShareSubjectNightMarket =>
      'Il mio Mercato notturno di VALORANT';

  @override
  String get storeShareSubtitle =>
      'Condividi un\'immagine del tuo negozio con gli amici tramite qualsiasi app.';

  @override
  String get storeTitle => 'Negozio';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Saldo: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n nella wishlist';
  }

  @override
  String get storeHistoryTitle => 'Cronologia del negozio';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString giorni',
      one: '$daysString giorno',
    );
    return 'Registrato su questo dispositivo dal $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Ancora nessun giorno registrato. ValHub salva il tuo negozio giornaliero ogni volta che apri l\'app, solo su questo dispositivo.';

  @override
  String get storeHistoryMostOffered => 'Più frequenti';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString volte',
      one: '$nString volta',
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
      other: 'Mercato notturno · $countString offerte',
      one: 'Mercato notturno · $countString offerta',
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
      other: '$daysString giorni registrati su questo dispositivo',
      one: '$daysString giorno registrato su questo dispositivo',
      zero: 'Registrazione iniziata oggi',
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
      'yes': '$skin è nel negozio di $account — scade tra $left.',
      'other': '$skin è nel negozio di $account.',
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
      'discount': '$skin è scontata del $percent%, ora a $price ($account).',
      'price': '$skin costa solo $price ($account).',
      'other': '$skin è nel Mercato notturno di $account.',
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
      'yes': '$skin è nel bundle $bundle ($account).',
      'other': '$skin è in un bundle in vendita ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'Ora nel negozio di $account: $names e altre $more skin.',
      one: 'Ora nel negozio di $account: $names e $more altra skin.',
      zero: 'Ora nel negozio di $account: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', nella wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Aggiungi skin';

  @override
  String get wishlistAddToWishlist => 'Aggiungi alla wishlist';

  @override
  String get wishlistAllWeapons => 'Tutte le armi';

  @override
  String get wishlistBrowseCatalog => 'Vedi tutte le skin';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Impossibile caricare l\'elenco delle skin. Aggiorna per riprovare.';

  @override
  String get wishlistCatalogEmptyTitle => 'Ancora nessuna skin';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'Nella wishlist: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Tocca ♡ per aggiungere una skin alla wishlist';

  @override
  String get wishlistCatalogTitle => 'Tutte le skin';

  @override
  String get wishlistChooseWeapon => 'Scegli arma';

  @override
  String get wishlistClearFilters => 'Rimuovi filtri';

  @override
  String get wishlistEmpty =>
      'La tua wishlist è vuota. Tocca ♡ su qualsiasi skin per aggiungerla.';

  @override
  String get wishlistEmptyTitle => 'Ancora nessuna skin';

  @override
  String wishlistEndsIn(String time) {
    return 'Termina tra $time';
  }

  @override
  String get wishlistExcludedRewards => 'Skin ricompensa escluse';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Con filtri: $countString skin · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Nessuna skin corrispondente. Rimuovi i filtri per vederne altre.';

  @override
  String get wishlistNoMatchTitle => 'Nessuna skin trovata';

  @override
  String get wishlistNotifBundleTitle =>
      'Un nuovo bundle contiene una skin della wishlist';

  @override
  String get wishlistNotifDailyTitle => 'È arrivata una skin della wishlist!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Il tuo Mercato notturno ha una skin che vuoi!';

  @override
  String get wishlistNotifPermissionMissing =>
      'L\'app non ha il permesso di inviare notifiche.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skin della wishlist sono in vendita!',
      one: '$count skin della wishlist è in vendita!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Notifiche wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Per questo account, anche quando l\'app è chiusa';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist di $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skin della wishlist sono in vendita!',
      one: '$count skin della wishlist è in vendita!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Tocca una riga evidenziata per vedere l\'offerta.';

  @override
  String get wishlistOpenSettings => 'Apri impostazioni';

  @override
  String get wishlistOwned => 'Posseduta';

  @override
  String get wishlistRemoveAction => 'Rimuovi dalla wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Rimuovi dalla wishlist';

  @override
  String wishlistRemoved(String name) {
    return '$name rimossa dalla wishlist';
  }

  @override
  String get wishlistSearchHint => 'Cerca skin…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistSortName => 'Nome';

  @override
  String get wishlistSortPrice => 'Prezzo';

  @override
  String get wishlistSortRarity => 'Rarità';

  @override
  String get wishlistSortWeapon => 'Arma';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Valore totale della wishlist';

  @override
  String get wishlistUndo => 'Annulla';

  @override
  String get wishlistViewInStore => 'Vedi nel negozio';

  @override
  String get wishlistWeapon => 'Arma';

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
      'yes': ', nella wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', nella wishlist',
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
      'gain': 'guadagnati',
      'other': 'persi',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vittorie',
      one: '$wins vittoria',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses sconfitte',
      one: '$losses sconfitta',
    );
    return 'Oggi $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vittorie',
      one: '$wins vittoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses sconfitte',
      one: '$losses sconfitta',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws pareggi',
      one: ', $draws pareggio',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown partite con esito sconosciuto',
      one: ', $unknown partita con esito sconosciuto',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Apri Personalizza Home per mostrarle di nuovo.';

  @override
  String get homeAllHiddenTitle => 'Hai nascosto tutte le schede';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Livello, XP necessari al giorno e missioni settimanali.';

  @override
  String get homeCardCommunity => 'Community';

  @override
  String get homeCardCommunityDesc =>
      'Trova compagni del tuo grado e le skin più amate dalla community.';

  @override
  String get homeCardFriends => 'Amici in gioco';

  @override
  String get homeCardFriendsDesc => 'Amici in partita o in coda.';

  @override
  String homeCardHidden(String name) {
    return 'Nascosta: \"$name\"';
  }

  @override
  String get homeCardLive => 'Partita in corso';

  @override
  String get homeCardLiveDesc =>
      'Visibile quando sei in coda, nella selezione agente o in partita.';

  @override
  String get homeCardOtherAccounts => 'Altri account';

  @override
  String get homeCardOtherAccountsDesc =>
      'Stato e wishlist dei tuoi altri account.';

  @override
  String get homeCardRank => 'Grado e forma';

  @override
  String get homeCardRankDesc =>
      'Grado, RR di oggi, serie e partite per salire di grado.';

  @override
  String get homeCardServerStatus => 'Stato dei server';

  @override
  String get homeCardServerStatusDesc =>
      'Visibile solo durante manutenzioni o problemi.';

  @override
  String get homeCardStore => 'Negozio di oggi';

  @override
  String get homeCardStoreDesc =>
      'Skin giornaliere, wishlist e Mercato notturno.';

  @override
  String get homeCustomize => 'Personalizza Home';

  @override
  String get homeCustomizeHint =>
      'Trascina per riordinare. Disattiva per nascondere una scheda.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Sei passato a $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Attiva';

  @override
  String get homeFriendsConsentBody =>
      'Per vedere quali amici stanno giocando, ValHub si collega alla chat Riot dell\'account attuale ogni volta che apri la Home. I tuoi amici ti vedranno online. Puoi disattivarlo in Personalizza Home.';

  @override
  String get homeFriendsConsentDecline => 'No, nascondi scheda';

  @override
  String get homeFriendsConsentTitle => 'Vedere quali amici stanno giocando?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n amici in gioco',
      one: '$n amico in gioco',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Vedi tutti';

  @override
  String get homeHideCard => 'Nascondi questa scheda';

  @override
  String homeLeaderboard(String pos) {
    return '#$pos in classifica';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Scade tra $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Servono $n giocatori',
      one: 'Serve $n giocatore',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Trova compagni del tuo grado';

  @override
  String get homeLiveAllyLabel => 'La tua squadra';

  @override
  String get homeLiveEnemyLabel => 'Squadra nemica';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'In coda, in attesa da $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'La tua squadra $ally, squadra nemica $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sconfitte di fila in Competitiva',
      one: '$n sconfitta di fila in Competitiva',
    );
    return '$_temp0';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n partite per arrivare a $rank',
      one: '≈ $n partita per arrivare a $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Opzioni per $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Accedi di nuovo per aggiornare negozio, grado e Battle Pass di $riotId. Puoi comunque vedere la versione salvata sul dispositivo.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Termina tra $time';
  }

  @override
  String get homeNightMarketNew => 'Nuovo';

  @override
  String get homeNightMarketTitle => 'Mercato notturno';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n offerte aspettano di essere girate',
      one: '$n offerta aspetta di essere girata',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Nessuna partita Competitiva oggi';

  @override
  String get homeOpenLfg => 'Vedi tutti gli annunci cerca compagni';

  @override
  String get homeOpenRanking => 'Vedi la classifica delle skin';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Altri account ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n account';
  }

  @override
  String get homeOtherWishlistHit => 'Skin della wishlist disponibile';

  @override
  String homePreviousAct(String rank) {
    return 'Atto precedente: $rank';
  }

  @override
  String get homeQuietBody => 'Trascina verso il basso per aggiornare.';

  @override
  String get homeQuietTitle => 'Ancora niente di nuovo';

  @override
  String homeRankToNext(int rr) {
    return 'Ancora $rr RR per salire di grado';
  }

  @override
  String get homeResetLayout => 'Ripristina predefinito';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Oggi $value';
  }

  @override
  String get homeStatusDetails => 'Dettagli';

  @override
  String homeStatusIncident(String region) {
    return 'Problema ai server · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'In manutenzione · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Manutenzione in arrivo · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n avvisi',
      one: '+$n avviso',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Aggiornamento…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Si aggiorna tra $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Totale $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Portafoglio $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return 'Portafoglio $vp · basta per un massimo di $n skin';
  }

  @override
  String get homeStoreWishlistHit => 'Skin della wishlist nel negozio!';

  @override
  String homeStoreWishlistHits(int n) {
    return '$n skin della wishlist in vendita';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get homeTrendingTitle => 'Le skin più amate nel mondo';

  @override
  String homeTrendingVotes(int n) {
    return '$n mi piace';
  }

  @override
  String get homeUndo => 'Annulla';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vittorie di fila in Competitiva',
      one: '$n vittoria di fila in Competitiva',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'Il negozio è cambiato. ValHub non è ancora riuscito a caricare quello nuovo.';

  @override
  String get homeOfflineTitle => 'Sei offline';

  @override
  String get homeOfflineBody =>
      'Mostriamo i dati salvati sul dispositivo. ValHub si aggiorna appena torni online.';

  @override
  String get homeCardOffline => 'Comparirà appena sei online.';

  @override
  String get communityErrorConsent =>
      'Accetta di condividere il tuo Riot ID con la community per continuare.';

  @override
  String get communityErrorForbidden =>
      'Non puoi ancora farlo. Consulta le Linee guida della community o contatta ValHub.';

  @override
  String get communityErrorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get communityErrorImageTooLarge =>
      'Immagine troppo grande (massimo 2 MB). Scegline un\'altra.';

  @override
  String get communityErrorImageType => 'Scegli un\'immagine JPEG, PNG o WebP.';

  @override
  String get communityErrorInvalid =>
      'Il tuo contenuto non è stato accettato. Controllalo e riprova.';

  @override
  String get communityErrorNetwork =>
      'Impossibile collegarsi alla community di ValHub. Controlla la connessione e riprova.';

  @override
  String get communityErrorNotFound => 'Questo contenuto non esiste più.';

  @override
  String get communityErrorPickImage =>
      'Impossibile aprire la galleria. Riprova.';

  @override
  String get communityErrorRateLimited =>
      'La community sta ricevendo troppe richieste. Riprova tra qualche minuto.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'La community sta ricevendo troppe richieste. Riprova tra $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot non è riuscito a verificare il tuo account. Accedi di nuovo al tuo account Riot e riprova.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot ha qualche problema. Riprova tra qualche minuto.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot ha qualche problema. Riprova tra $duration.';
  }

  @override
  String get communityErrorServer =>
      'La community di ValHub ha qualche problema. Riprova tra qualche minuto.';

  @override
  String get communityErrorStorageFull =>
      'Lo spazio per le foto della community è pieno. Puoi comunque pubblicare, ma per ora non puoi allegare foto. Riprova più tardi.';

  @override
  String get communityErrorTimeout =>
      'La community di ValHub sta impiegando troppo a rispondere. Riprova.';

  @override
  String get communityErrorTitle => 'Operazione non completata';

  @override
  String get communityErrorUnauthorized =>
      'Il collegamento alla community è scaduto. Riprova.';

  @override
  String get communityErrorImageQuota =>
      'Hai esaurito lo spazio per le immagini. Elimina qualche post con immagini e riprova.';

  @override
  String get smokePlain => 'Verifica generazione codice';

  @override
  String smokeGreeting(String name) {
    return 'Ciao, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n voci',
      one: '$n voce',
    );
    return '$_temp0';
  }
}
