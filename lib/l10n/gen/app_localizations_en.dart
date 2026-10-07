// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'View price source';

  @override
  String get commonErrorApi =>
      'Riot is having issues. Try again in a few minutes.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClearFilters => 'Clear filters';

  @override
  String get commonClearSearch => 'Clear search';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '$n day ago',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEmptyGeneric => 'Nothing here yet.';

  @override
  String get commonErrorContentUnavailable =>
      'Couldn\'t load skins, agents and maps. Check your connection and try again.';

  @override
  String get commonErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get commonErrorMaintenance =>
      'VALORANT servers are under maintenance. Check back later.';

  @override
  String get commonErrorNeedsLogin =>
      'Your Riot sign-in has expired. Sign in again to continue.';

  @override
  String get commonErrorNeedsLoginTitle => 'Sign in again';

  @override
  String get commonErrorNetwork =>
      'No connection. Check your Wi-Fi or mobile data and try again.';

  @override
  String get commonErrorNoAccount => 'You\'re not signed in to any account.';

  @override
  String get commonErrorNotFound => 'Couldn\'t find this content.';

  @override
  String get commonErrorTimeout =>
      'Riot is taking too long to respond. Check your connection and try again.';

  @override
  String get commonErrorTransient =>
      'Riot is busy. Try again in a few minutes.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot is busy. Try again in $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Couldn\'t detect your Riot region. Choose a region in Settings.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Go to Home';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '$n hour',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours ago',
      one: '$n hour ago',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Server incident';

  @override
  String get commonJustNow => 'just now';

  @override
  String get commonLoadMore => 'Load more';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonMaintenanceTitle => 'Server maintenance';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '$n minute',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes ago',
      one: '$n minute ago',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Nothing to show yet';

  @override
  String commonOfflineCached(String time) {
    return 'You\'re offline — showing saved data ($time).';
  }

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonPageNotFound => 'Couldn\'t find this screen.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Best-value pack: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Edit your price';

  @override
  String get commonPriceEnterOwn => 'Enter your VP pack price';

  @override
  String get commonPriceEstimateBody =>
      'The “≈ …” amount next to VP prices is an estimate, converted using the best-value VP pack. You pay in VP in game; the real amount depends on the pack, payment method, taxes and promotions when you buy.';

  @override
  String get commonPriceEstimateTitle => 'Estimated price';

  @override
  String get commonPriceEstimateTooltip =>
      'Estimated price — tap to see how it\'s calculated';

  @override
  String get commonPriceHidden =>
      'Estimated prices hidden. Turn them back on in Settings.';

  @override
  String get commonPriceHide => 'Hide estimated prices';

  @override
  String get commonPriceOpenSource => 'Open source page';

  @override
  String get commonPriceOverrideBody =>
      'Enter the amount you actually paid for a VP pack (check the in-game store or your receipt). ValHub uses this price to estimate prices for every item; it\'s only saved on this device.';

  @override
  String get commonPriceOverrideCurrency => 'Currency code';

  @override
  String get commonPriceOverrideCurrencyHint => 'e.g. USD, EUR, JPY, VND';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Example estimate: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Enter a 3-letter currency code, like USD or EUR.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Enter a number greater than 0.';

  @override
  String get commonPriceOverridePrice => 'Pack price';

  @override
  String get commonPriceOverrideRemove => 'Remove your price';

  @override
  String get commonPriceOverrideRemoved => 'Your price was removed.';

  @override
  String get commonPriceOverrideSave => 'Save price';

  @override
  String get commonPriceOverrideSaved => 'Your VP pack price was saved.';

  @override
  String get commonPriceOverrideTitle => 'Your VP pack price';

  @override
  String get commonPriceOverrideVp => 'VP in pack';

  @override
  String get commonPricePacksTitle => 'VP packs';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Based on VP pack prices in region $country';
  }

  @override
  String get commonPriceSourceUser => 'Based on the VP pack price you entered';

  @override
  String get commonPriceUnavailable =>
      'No verified price list for your region yet. Enter the price of a VP pack you\'ve bought to see estimated prices.';

  @override
  String commonPriceUpdated(String date) {
    return 'Price list updated: $date';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRiotDisclaimer =>
      'ValHub isn\'t endorsed by Riot Games and doesn\'t reflect the views or opinions of Riot Games or anyone officially involved in producing or managing Riot Games properties. Riot Games, and all associated properties are trademarks or registered trademarks of Riot Games, Inc.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n seconds',
      one: '$n second',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Share';

  @override
  String get commonSignInAgain => 'Sign in again';

  @override
  String get commonSort => 'Sort';

  @override
  String commonSortBy(String option) {
    return 'Sort: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Collection';

  @override
  String get commonTabCommunity => 'Community';

  @override
  String get commonTabHome => 'Home';

  @override
  String get commonTabProfile => 'Profile';

  @override
  String get commonTabSettings => 'Settings';

  @override
  String get commonTabStore => 'Store';

  @override
  String get commonTagline => 'Your VALORANT companion';

  @override
  String get commonToday => 'Today';

  @override
  String get commonTodayLower => 'today';

  @override
  String get commonTomorrow => 'tomorrow';

  @override
  String get commonUnknownItem => 'Unknown item';

  @override
  String commonUpdatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Monday';

  @override
  String get commonWeekdaysItem1 => 'Tuesday';

  @override
  String get commonWeekdaysItem2 => 'Wednesday';

  @override
  String get commonWeekdaysItem3 => 'Thursday';

  @override
  String get commonWeekdaysItem4 => 'Friday';

  @override
  String get commonWeekdaysItem5 => 'Saturday';

  @override
  String get commonWeekdaysItem6 => 'Sunday';

  @override
  String get commonYesterday => 'yesterday';

  @override
  String get commonYesterdayTitle => 'Yesterday';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot sign-in expired — showing saved data ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Heavy Weapons';

  @override
  String get contentCategoryMelee => 'Melee';

  @override
  String get contentCategoryRifle => 'Rifles';

  @override
  String get contentCategoryShotgun => 'Shotguns';

  @override
  String get contentCategorySidearm => 'Sidearms';

  @override
  String get contentCategorySmg => 'SMGs';

  @override
  String get contentCategorySniper => 'Sniper Rifles';

  @override
  String get contentCurrencyAgentTokens => 'Agent Tokens';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kingdom Credits';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianite';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Points';

  @override
  String get contentItemAgent => 'Agent';

  @override
  String get contentItemBuddy => 'Gun Buddy';

  @override
  String get contentItemCard => 'Player Card';

  @override
  String get contentItemChroma => 'Variant';

  @override
  String get contentItemContract => 'Contract';

  @override
  String get contentItemCurrency => 'Currency';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Spray';

  @override
  String get contentItemTitle => 'Player Title';

  @override
  String contentLevel(int n) {
    return 'Level $n';
  }

  @override
  String get contentLevelBase => 'Base';

  @override
  String get contentLevelItemLabelsVFX => 'VFX';

  @override
  String get contentLevelItemLabelsAnimation => 'Animation';

  @override
  String get contentLevelItemLabelsFinisher => 'Finisher';

  @override
  String get contentLevelItemLabelsKillCounter => 'Kill Counter';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Sound Effects';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformation';

  @override
  String get contentLevelItemLabelsKillBanner => 'Kill Banner';

  @override
  String get contentLevelItemLabelsKillEffect => 'Kill Effect';

  @override
  String get contentLevelItemLabelsInspectAndKill => 'Inspect & Kill Effects';

  @override
  String get contentLevelItemLabelsVoiceover => 'Voiceover';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Song Shuffle';

  @override
  String get contentLevelItemLabelsRandomizer => 'Randomizer';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Attacker/Defender Swap';

  @override
  String get contentLevelItemLabelsTopFrag => 'Top Frag Effect';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Heartbeat & Map Sensor';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Fish Animation';

  @override
  String get contentNoTitle => 'No title';

  @override
  String get contentNotForSale => 'Not for sale';

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
  String get contentQueueNamesCustom => 'Custom Game';

  @override
  String get contentQueueNames => 'Custom Game';

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
  String get contentRewardSourceAgent => 'Agent contract';

  @override
  String get contentRewardSourceBattlePass => 'Battle Pass reward';

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
  String get accountRegionUnknown => 'Unknown region';

  @override
  String accountRiotCountry(String country) {
    return 'Riot account country: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riot account country: Unknown';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'ACCOUNTS ($count/$max)';
  }

  @override
  String get accountActive => 'Active';

  @override
  String accountAddAccount(int count, int max) {
    return 'Add account ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Clear local data';

  @override
  String get accountClearLocalDataConfirm =>
      'Clear history, saved loadouts and data from signed-out accounts on this device?';

  @override
  String get accountClearRrHistory => 'Clear RR history';

  @override
  String get accountClearRrHistoryConfirm =>
      'Clear RR history for the selected account on this device?';

  @override
  String get accountCopyPassword => 'Copy password';

  @override
  String get accountCopyUsername => 'Copy username';

  @override
  String get accountDeleteLoginNote => 'Delete info';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Delete the saved username and password for this account?';

  @override
  String get accountHidePassword => 'Hide password';

  @override
  String get accountKeepLocalData => 'Keep local data';

  @override
  String get accountKeepLocalDataHint =>
      'Keep wishlist, loadouts and history on this device';

  @override
  String accountLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'The account in this notification is signed out. Sign in again, then open the notification.';

  @override
  String get accountLocalDataCleared => 'Local data cleared';

  @override
  String get accountLoginNote => 'Sign-in info';

  @override
  String get accountLoginNoteDeleted => 'Sign-in info deleted';

  @override
  String get accountLoginNoteEmpty => 'No sign-in info saved';

  @override
  String get accountLoginNoteHint =>
      'Saved only on this device and securely locked. Use it to look up or quickly fill in your details when you sign in again.';

  @override
  String get accountLoginNoteLocked => 'Unlock sign-in info';

  @override
  String get accountLoginNotePassword => 'Password';

  @override
  String get accountLoginNoteSaved => 'Sign-in info saved';

  @override
  String get accountLoginNoteUsername => 'Riot username';

  @override
  String get accountManageHint =>
      'Remove accounts or edit sign-in info in Settings.';

  @override
  String accountMaxAccounts(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'You\'ve reached the maximum of $max accounts.',
      one: 'You\'ve reached the maximum of $max account.',
    );
    return '$_temp0';
  }

  @override
  String get accountNeedsLogin => 'Sign in again';

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
  String get accountQuickFill => 'Fill saved account';

  @override
  String get accountQuickFillDone => 'All filled in. Tap Sign in.';

  @override
  String get accountQuickFillNotReady =>
      'The sign-in page hasn\'t finished loading. Wait a moment and try again.';

  @override
  String get accountQuickFillSubtitle =>
      'Choose an account to fill in on the Riot sign-in page';

  @override
  String get accountQuickFillTitle => 'Fill saved account';

  @override
  String get accountRegionAp => 'Asia Pacific';

  @override
  String get accountRegionBr => 'Brazil';

  @override
  String get accountRegionEu => 'Europe';

  @override
  String get accountRegionKr => 'Korea';

  @override
  String get accountRegionLatam => 'Latin America';

  @override
  String get accountRegionNa => 'North America';

  @override
  String get accountRemoveAccount => 'Remove account';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Remove $account from this device? You can choose to keep saved data.';
  }

  @override
  String get accountRrHistoryCleared => 'RR history cleared';

  @override
  String get accountShowPassword => 'Show password';

  @override
  String get accountSignOutAll => 'Sign out of all accounts';

  @override
  String get accountSignOutAllConfirm =>
      'Sign out and remove all accounts from this device? You can choose to keep saved data.';

  @override
  String get accountStatusAgentSelect => 'In agent select';

  @override
  String get accountStatusInMatch => 'In match';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Status unknown';

  @override
  String accountSwitchTo(String account) {
    return 'Switch to $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Tap to switch accounts';

  @override
  String get accountSwitcherTitle => 'Accounts';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Accounts ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Player';

  @override
  String get accountUnlockLoginNote =>
      'Verify to unlock your Riot sign-in info';

  @override
  String accountMoreActions(String riotId) {
    return 'Options for $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Save sign-in info';

  @override
  String get accountClearRrHistorySubtitle => 'Only the selected account';

  @override
  String get accountClearLocalDataSubtitle =>
      'History, saved loadouts and data of signed-out accounts';

  @override
  String get accountQuickFillLocked =>
      'Unlock with your fingerprint, face or device PIN to use a saved account. If your phone has no screen lock, set one and try again.';

  @override
  String get authAddAsNew => 'Add as new account';

  @override
  String get authDifferentAccountBody =>
      'You signed in with a different account than the one that needs to sign in again. Add this account as a new account?';

  @override
  String get authDifferentAccountTitle => 'Different account';

  @override
  String get authLoadingAccount => 'Loading account…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot declined this sign-in. Try again.';

  @override
  String get authLoginFailed => 'Couldn\'t finish signing in';

  @override
  String get authLoginFailedBody =>
      'Riot hasn\'t confirmed your sign-in. Try again.';

  @override
  String get authLoginTitle => 'Riot sign-in';

  @override
  String get authMissingCookies =>
      'Your sign-in couldn\'t be saved on this device, so you\'ll need to sign in again when it expires.';

  @override
  String get authOfficialHost => 'Official page · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Link opened in your browser.';

  @override
  String get authPageLoadFailed =>
      'Couldn\'t load the Riot sign-in page. Check your connection and try again.';

  @override
  String get authPreparing => 'Preparing sign-in page…';

  @override
  String get authReloginDone => 'Signed in again';

  @override
  String get authSignInCta => 'Sign in with Riot account';

  @override
  String get authSocialLoginHint =>
      'If signing in with Google or Facebook doesn\'t work, use your Riot username.';

  @override
  String get authStateMismatch =>
      'This sign-in attempt isn\'t valid. Start signing in again from the beginning.';

  @override
  String get notificationSessionExpiredBody =>
      'Sign in again to keep getting wishlist alerts.';

  @override
  String get notificationBackgroundTimingHint =>
      'Your device\'s battery saver may delay notifications.';

  @override
  String get notificationChannelAccountDescription =>
      'Reminds you when an account needs to sign in again';

  @override
  String get notificationChannelAccountName => 'Accounts';

  @override
  String get notificationChannelBattlePassDescription =>
      'Reminders for Battle Pass progress and end date';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Community activity when you open ValHub';

  @override
  String get notificationChannelCommunityName => 'Community';

  @override
  String get notificationChannelLfgDescription =>
      'Players joining your party when you open ValHub';

  @override
  String get notificationChannelLfgName => 'Party';

  @override
  String get notificationChannelNightMarketDescription =>
      'Alerts when the Night Market opens';

  @override
  String get notificationChannelNightMarketName => 'Night Market';

  @override
  String get notificationChannelRankDescription =>
      'Rank changes when you refresh your profile';

  @override
  String get notificationChannelRankName => 'Rank';

  @override
  String get notificationChannelStoreResetDescription =>
      'Reminds you when the daily store refreshes';

  @override
  String get notificationChannelStoreResetName => 'Store refresh';

  @override
  String get notificationChannelWishlistDescription =>
      'Alerts when a wishlisted skin shows up in your store';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle => 'A player joined your party';

  @override
  String get notificationLocalOnlyHint =>
      'Only shown on this device when ValHub updates its data';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Offer cards waiting for $account: $cards. Flip them now.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'The Night Market is open!';

  @override
  String get notificationPassEndingBody =>
      'About one day left on the Battle Pass. Open ValHub to see your latest progress.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass ending soon';

  @override
  String notificationPassProgressBody(int level) {
    return 'You\'ve reached level $level in the current Battle Pass.';
  }

  @override
  String get notificationPassProgressTitle => 'Battle Pass progress';

  @override
  String get notificationPrivateAccount => 'your account';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Current rank: $rank. Just updated from Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Rank changed';

  @override
  String get notificationResetTimingUnknown =>
      'Open the store to update the refresh time on your device.';

  @override
  String get notificationSessionExpiredTitle => 'Sign in again';

  @override
  String get notificationStoreResetBody =>
      'New skins are waiting for you in the store.';

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
  String get competitiveRankUnknown => 'Rank unknown';

  @override
  String get competitiveAttack => 'Attack';

  @override
  String get competitiveCannotEstimate => 'Can\'t estimate';

  @override
  String get competitiveDefeat => 'Defeat';

  @override
  String get competitiveDefense => 'Defense';

  @override
  String get competitiveDraw => 'Draw';

  @override
  String get competitiveIncognitoPlayer => 'Hidden player';

  @override
  String get competitiveMatchPending => 'Riot is still processing this match…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n placement matches left',
      one: '$n placement match left',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike defused';

  @override
  String get competitiveRoundDetonate => 'Spike detonated';

  @override
  String get competitiveRoundElimination => 'Elimination';

  @override
  String get competitiveRoundSurrendered => 'Surrender';

  @override
  String get competitiveRoundTimeExpired => 'Time expired';

  @override
  String get competitiveUnknownPlayer => 'Player';

  @override
  String get competitiveVictory => 'Victory';

  @override
  String economyAvailableNow(String place) {
    return 'Now in the $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return '$name bundle';
  }

  @override
  String get economyPlaceBundleGeneric => 'bundle';

  @override
  String get economyPlaceDaily => 'daily store';

  @override
  String get economyPlaceNightMarket => 'Night Market';

  @override
  String get economyPriceEstimated => 'Estimated from edition';

  @override
  String get economyPriceFromOffers => 'Price from Riot\'s price list';

  @override
  String get economyPriceFromStore => 'Price seen in the store';

  @override
  String get economyPriceFromTable => 'List price';

  @override
  String get economyPriceUnknown => 'Price unknown';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Loadout $n';
  }

  @override
  String get loadoutInvalidChange =>
      'This change can\'t be applied to your current loadout.';

  @override
  String get loadoutNotPersisted =>
      'Riot didn\'t save your change, so your loadout is unchanged. Try again.';

  @override
  String get loadoutSaveFailed => 'Couldn\'t save loadout';

  @override
  String battlePassActEndsIn(String time) {
    return 'Act ends in $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Act ends in $days days',
      one: 'Act ends in $days day',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'All missions completed';

  @override
  String get battlePassAllWeeklyDone => 'All weekly missions completed';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Double rewards pending: $n';
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
      'Win rounds to progress toward checkpoints (Deathmatch doesn\'t count).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Checkpoint $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Each checkpoint: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return '$done/$total checkpoints reached';
  }

  @override
  String get battlePassCurrentChapter => 'Current';

  @override
  String get battlePassDailyAllDone => 'All of today\'s checkpoints completed';

  @override
  String get battlePassDailyCaption => 'Daily rewards';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Daily rewards · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Yesterday\'s checkpoints have expired. Launch the game or refresh here.';

  @override
  String get battlePassDailyMissions => 'Daily missions';

  @override
  String get battlePassDailyNotReady =>
      'Today\'s checkpoints aren\'t ready yet. Launch the game or refresh here.';

  @override
  String get battlePassDailyPlayToStart =>
      'Today\'s checkpoints aren\'t ready yet. Launch the game to start a new day.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '$days day left',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Ends at $wall';
  }

  @override
  String get battlePassEpilogue => 'Epilogue';

  @override
  String get battlePassEstimateNote =>
      'Estimated at about 4,000 XP per match, not counting missions.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String get battlePassEventPass => 'Event Pass';

  @override
  String get battlePassFilterAll => 'All';

  @override
  String get battlePassFilterLocked => 'Locked';

  @override
  String get battlePassFilterUnlocked => 'Unlocked';

  @override
  String get battlePassFree => 'Free';

  @override
  String get battlePassFreeTrack => 'Free rewards';

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

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString $queue matches',
      one: '$nString $queue match',
    );
    return '≈ $_temp0';
  }

  @override
  String get battlePassMissionDone => 'Completed';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total completed';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'New missions at $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'New missions in $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Next checkpoint: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'To level $level';
  }

  @override
  String get battlePassNextReward => 'Next';

  @override
  String get battlePassNoBattlePass =>
      'No Battle Pass info for the current act yet. Try again later.';

  @override
  String get battlePassNoRewards => 'This Battle Pass has no rewards yet.';

  @override
  String get battlePassNoRewardsInFilter => 'No rewards in this section.';

  @override
  String get battlePassNoRewardsTitle => 'No rewards yet';

  @override
  String get battlePassNoWeeklyMissions => 'No weekly missions right now.';

  @override
  String get battlePassPassComplete => 'Battle Pass completed';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'You don\'t have Premium: you only get Free rewards. Buy Premium in game to unlock the levels you\'ve reached.';

  @override
  String get battlePassRenewButton => 'Refresh checkpoints';

  @override
  String get battlePassRenewDone => 'Daily checkpoints refreshed.';

  @override
  String get battlePassRenewFailed =>
      'Couldn\'t refresh checkpoints. Try again later.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Resets at $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Resets in $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Level';

  @override
  String get battlePassRewardLocked => 'Locked';

  @override
  String get battlePassRewardNeedsPremium => 'Requires Premium';

  @override
  String get battlePassRewardStatusLabel => 'Status';

  @override
  String get battlePassRewardTrackLabel => 'Reward track';

  @override
  String get battlePassRewardTypeLabel => 'Type';

  @override
  String get battlePassRewardUnlocked => 'Unlocked';

  @override
  String get battlePassRewardsTitle => 'Rewards';

  @override
  String get battlePassShowAllRewards => 'See all';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'Total XP';

  @override
  String get battlePassUnknownMission => 'New mission (no description yet)';

  @override
  String get battlePassUnknownReward => 'Reward';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total unlocked';
  }

  @override
  String get battlePassUnratedFallback => 'Unrated';

  @override
  String get battlePassViewAllRewards => 'View all rewards';

  @override
  String get battlePassWeeklyMissions => 'Weekly missions';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Weekly missions: +$xp XP left';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / day';
  }

  @override
  String get battlePassXpPerDayCaption => 'Needed per day to finish in time';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return '$xp XP to go';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Couldn\'t save loadout. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Every skin you own, valued at store prices',
      'buddy': 'Gun Buddies you own and how many copies',
      'spray': 'Sprays you can add to your expression wheel',
      'card': 'Unlocked Player Cards, tap to view and equip',
      'title': 'Player Titles you can show under your name',
      'flex': 'Flex items you own',
      'other': 'Browse collection',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Slot: $position';
  }

  @override
  String get collectionApplyPreset => 'Apply';

  @override
  String get collectionApplyPresetBody =>
      'Your current skins, Gun Buddies, expression wheel, card and title will be replaced with this loadout.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Apply “$name”?';
  }

  @override
  String get collectionBrowseBuddies => 'Gun Buddies';

  @override
  String get collectionBrowseCards => 'Player Cards';

  @override
  String get collectionBrowseEmpty =>
      'You don\'t have any items in this section yet.';

  @override
  String get collectionBrowseEmptyTitle => 'No items yet';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skins';

  @override
  String get collectionBrowseSprays => 'Sprays';

  @override
  String get collectionBrowseTitles => 'Player Titles';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return '$free/$total left';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'For $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Choose a Gun Buddy';

  @override
  String get collectionBuddyRemoved => 'Gun Buddy removed';

  @override
  String get collectionBuddySlot => 'Gun Buddy';

  @override
  String get collectionBuddyUnavailable =>
      'Couldn\'t attach this Gun Buddy. Refresh or choose another one.';

  @override
  String get collectionCachedLoadout =>
      'Showing your saved loadout. Pull to refresh before making changes.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString cards owned',
      one: '$nString card owned',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Change';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total variants';
  }

  @override
  String get collectionClearTiers => 'Clear edition filter';

  @override
  String get collectionCollectionValue => 'Collection value';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Standard';

  @override
  String get collectionDeletePreset => 'Delete';

  @override
  String get collectionEmptySlot => 'Empty';

  @override
  String get collectionEquip => 'Equip';

  @override
  String get collectionEquipped => 'Equipped';

  @override
  String get collectionEquippedCard => 'Equipped card';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Equipped card: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Equipped $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Equipped: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Excludes reward skins';

  @override
  String get collectionExpressionsHint =>
      'Tap a slot to choose a Spray or Flex.';

  @override
  String get collectionExpressionsSlots => 'Wheel slots';

  @override
  String get collectionExpressionsTitle => 'Expression wheel';

  @override
  String get collectionHideAccountLevel => 'Hide account level';

  @override
  String get collectionHideAccountLevelHint =>
      'Other players won\'t see your account level.';

  @override
  String get collectionIncognito => 'Incognito mode';

  @override
  String get collectionIncognitoHint =>
      'Hide your name from players outside your party in matches.';

  @override
  String get collectionLevelBorderAuto => 'Auto by level';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'From level $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Account level $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Choose level border';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Level $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Level $n · $type';
  }

  @override
  String get collectionLevels => 'Levels';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$total levels unlocked';
  }

  @override
  String get collectionLobbyBanner => 'Lobby banner';

  @override
  String get collectionLocked => 'Locked';

  @override
  String get collectionMeleeNoBuddy => 'Melee weapons can\'t hold a Gun Buddy.';

  @override
  String get collectionMove => 'Move';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy is attached to $from. Move it to $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Move Gun Buddy?';

  @override
  String get collectionNoBuddies => 'You don\'t have any Gun Buddies yet.';

  @override
  String get collectionNoBuddy => 'No Gun Buddy';

  @override
  String get collectionNoFlex => 'You don\'t have any Flex items yet.';

  @override
  String get collectionNoResults => 'No matching results.';

  @override
  String get collectionNoResultsTitle => 'Nothing found';

  @override
  String get collectionNoSkinsForWeapon =>
      'You don\'t have any skins for this weapon yet.';

  @override
  String get collectionNoSprays => 'You don\'t have any Sprays yet.';

  @override
  String get collectionNoTitle => 'No title';

  @override
  String get collectionOtherWeapons => 'Other';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins owned',
      one: '$n skin owned',
      zero: 'No skins yet',
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
      other: '$nString skins owned',
      one: '$nString skin owned',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Watch this level\'s video';

  @override
  String get collectionPlayVideo => 'Watch video';

  @override
  String get collectionPlayerCardSubtitle =>
      'Shown in the lobby, on the scoreboard and when you eliminate an enemy.';

  @override
  String get collectionPlayerCardTitle => 'Change Player Card';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Shown under your name in the lobby and in matches.';

  @override
  String get collectionPlayerTitleTitle => 'Change Player Title';

  @override
  String get collectionPresetActions => 'Options';

  @override
  String collectionPresetApplied(String name) {
    return 'Applied “$name”';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n loadouts',
      one: '$n loadout',
      zero: 'None yet',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'Deleted “$name”';
  }

  @override
  String get collectionPresetNameHint => 'e.g. Rank grind';

  @override
  String get collectionPresetNameTitle => 'Loadout name';

  @override
  String collectionPresetSaved(String name) {
    return 'Saved “$name”';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Saved on $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Skipped $n items you no longer own.',
      one: 'Skipped $n item you no longer own.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Save your current loadout to quickly switch between sets of skins, cards and expression wheels later.';

  @override
  String get collectionPresetsEmptyTitle => 'No saved loadouts yet';

  @override
  String get collectionPresetsFull =>
      'You\'ve reached the maximum of 50 loadouts. Delete some to save more.';

  @override
  String get collectionPresetsNote =>
      'Loadouts are only saved on this device, for the selected account.';

  @override
  String get collectionPresetsTitle => 'Saved loadouts';

  @override
  String get collectionPreview => 'Preview';

  @override
  String get collectionRemoveBuddy => 'Remove Gun Buddy';

  @override
  String get collectionRenamePreset => 'Rename';

  @override
  String get collectionRowExpressions => 'Expression wheel';

  @override
  String get collectionRowLevelBorder => 'Level Border';

  @override
  String get collectionRowPresets => 'Saved loadouts';

  @override
  String get collectionRowWeapons => 'Weapon loadout';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Couldn\'t save loadout';

  @override
  String get collectionSavePreset => 'Save current loadout';

  @override
  String get collectionSaving => 'Saving…';

  @override
  String get collectionSearchBuddies => 'Search Gun Buddies…';

  @override
  String get collectionSearchCards => 'Search Player Cards…';

  @override
  String get collectionSearchFlex => 'Search Flex…';

  @override
  String get collectionSearchItems => 'Search…';

  @override
  String get collectionSearchSkins => 'Search skins…';

  @override
  String get collectionSearchSprays => 'Search Sprays…';

  @override
  String get collectionSearchTitles => 'Search titles…';

  @override
  String get collectionSearchWeapons => 'Search weapons, skins or Gun Buddies…';

  @override
  String get collectionSectionBrowse => 'Browse collection';

  @override
  String get collectionSectionIdentity => 'Visible to other players';

  @override
  String get collectionSectionLoadout => 'Loadout';

  @override
  String get collectionSkinCustomizeTitle => 'Customize skin';

  @override
  String get collectionSkinNotFound => 'Couldn\'t find this skin.';

  @override
  String get collectionSkinNotOwned => 'You don\'t own this skin yet.';

  @override
  String get collectionSlotNamesItem0 => 'Top';

  @override
  String get collectionSlotNamesItem1 => 'Right';

  @override
  String get collectionSlotNamesItem2 => 'Bottom';

  @override
  String get collectionSlotNamesItem3 => 'Left';

  @override
  String get collectionSortName => 'Name';

  @override
  String get collectionSortPrice => 'Price';

  @override
  String get collectionSortRarity => 'Rarity';

  @override
  String get collectionSortWeapon => 'Weapon';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins',
      one: '$count skin',
    );
    return 'Filtered: $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Filtered: $count/$total items';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins',
      one: '$count skin',
    );
    return '$_temp0 · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Sprays';

  @override
  String get collectionTapToChangeCard => 'Tap to change card';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString titles owned',
      one: '$nString title owned',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Undo';

  @override
  String get collectionUnknownCard => 'Unknown card';

  @override
  String get collectionValueAtStorePrices => 'Based on store prices';

  @override
  String get collectionValueHasEstimates => 'Includes estimates (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n reward skins not counted',
      one: '$n reward skin not counted',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'See skins';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Based on $n skins',
      one: 'Based on $n skin',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Variants';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total weapons using skins';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Weapon loadout';

  @override
  String get collectionWeaponNotFound => 'Couldn\'t find this weapon.';

  @override
  String get collectionWeaponSkinsTitle => 'Choose skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Couldn\'t post because of inappropriate language. Edit your post and try again.';

  @override
  String get communityModerationContentScam =>
      'Community doesn\'t allow ads for selling accounts, boosting services or phone numbers. Remove that content and try again.';

  @override
  String get communityModerationContentTooComplex =>
      'Your post has too many scattered characters. Keep it simpler and try again.';

  @override
  String get communityModerationAccountBanned =>
      'This account has been banned from Community. If you think this is a mistake, contact ValHub in About & legal.';

  @override
  String get communityModerationAccountRestricted =>
      'This account is restricted from posting, commenting, finding teammates and voting. Try again later or contact ValHub in About & legal.';

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
      'custom': 'Custom Game',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asia Pacific',
      'na': 'North America',
      'eu': 'Europe',
      'kr': 'Korea',
      'latam': 'Latin America',
      'br': 'Brazil',
      'other': 'Unknown region',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'No skins in this ranking yet';

  @override
  String get communityRankingEmptyVotes =>
      'No favorites match the selected scope and filters yet.';

  @override
  String get communityRankingEmptyRatings =>
      'No star ratings match the selected scope and filters yet.';

  @override
  String get communityRankingEmptyReviews =>
      'No reviews match the selected scope and filters yet.';

  @override
  String get communityRankingExplore => 'Find skins to view and rate';

  @override
  String get communityRankingExploreHint =>
      'Search by skin or weapon name. Only real community ratings appear in the rankings.';

  @override
  String get communityRankingClear => 'Clear weapon and time filters';

  @override
  String get communityRankingSort => 'Rank by';

  @override
  String get communityRankingWeapon => 'Weapon';

  @override
  String get communityRankingNoSearch =>
      'No matching skins. Try another name or clear the weapon filter.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Couldn\'t load the skin list. Close this panel and try again once data has synced.';

  @override
  String get communityConsentExitAccount =>
      'Decline · Sign out of this account';

  @override
  String get communityRankingGlobalAllTime => 'Global · All time';

  @override
  String get communityRankingCatalogTitle => 'All skins';

  @override
  String get communityReviewOwnershipRequired =>
      'Your account must own this skin to rate it. You can still read community ratings and comments.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Couldn\'t verify you own this skin. Reload your Collection or try again when you\'re online.';

  @override
  String get communityReviewLegacyOwnership =>
      'Older review · Ownership not verified';

  @override
  String get communityReviewVerifiedOwner =>
      'Ownership verified at time of review';

  @override
  String get communitySkinDiscussionHint =>
      'Anyone can comment. Only skin owners can give stars and write reviews.';

  @override
  String get communityAddPhotos => 'Add photos';

  @override
  String get communityAllModes => 'All';

  @override
  String get communityAllWeapons => 'All weapons';

  @override
  String get communityAnonymousBanner => 'Browsing anonymously';

  @override
  String get communityAnyLanguage => 'Any language';

  @override
  String get communityAnyRank => 'Any rank';

  @override
  String get communityAnyRole => 'Any role';

  @override
  String get communityApply => 'Apply';

  @override
  String get communityBackToMyCountry => 'Back to my country';

  @override
  String get communityBlockAuthor => 'Block on this device';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Clear';

  @override
  String get communityCodeAuto =>
      'Leave blank: ValHub creates a code from your in-game party when you post.';

  @override
  String get communityCodeAutoFailed =>
      'Couldn\'t create a party code. Open VALORANT or enter the code manually.';

  @override
  String get communityCodeInvalid =>
      'The code must be exactly 6 capital letters or digits.';

  @override
  String get communityCodeRequired => 'Enter or create a party code.';

  @override
  String get communityCommentHint => 'Write a comment…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString comments',
      one: '$nString comment',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Comments · $n';
  }

  @override
  String get communityCommentsTitle => 'Comments';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Posts: $posts · Players: $authors';
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
      other: '$nString LFG posts',
      one: '$nString LFG post',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Community favorites';

  @override
  String get communityComposerHint =>
      'What\'s on your mind about VALORANT today?';

  @override
  String get communityComposerTitle => 'New post';

  @override
  String communityConsentAccount(String riotId) {
    return 'Account: $riotId';
  }

  @override
  String get communityConsentAgree => 'Agree and continue';

  @override
  String get communityConsentGateAction => 'Join';

  @override
  String get communityConsentGuidelines => 'Community Guidelines';

  @override
  String get communityConsentLater => 'Later';

  @override
  String get communityConsentLocal =>
      'Your password and other sign-in data always stay on this device. You can withdraw consent in Settings.';

  @override
  String get communityConsentPrivacy => 'Privacy Policy';

  @override
  String get communityConsentPublic =>
      'Others will see your Riot ID, Player Card, rank and country.';

  @override
  String get communityConsentTitle => 'Privacy and ValHub Community';

  @override
  String get communityConsentVerify =>
      'ValHub sends your Riot access to the Community server to verify your Riot ID when you connect and to check skin ownership when you save a review. The server only reads what it needs, discards the access right after, and never stores it.';

  @override
  String get communityConsentWithdrawn =>
      'Consent withdrawn. You need to agree again to keep using the app.';

  @override
  String get communityCountriesTitle => 'Communities by country';

  @override
  String get communityCountryNamesAE => 'United Arab Emirates';

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
  String get communityCountryNamesBA => 'Bosnia and Herzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Belgium';

  @override
  String get communityCountryNamesBG => 'Bulgaria';

  @override
  String get communityCountryNamesBH => 'Bahrain';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivia';

  @override
  String get communityCountryNamesBR => 'Brazil';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Canada';

  @override
  String get communityCountryNamesCH => 'Switzerland';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'China';

  @override
  String get communityCountryNamesCO => 'Colombia';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Cyprus';

  @override
  String get communityCountryNamesCZ => 'Czechia';

  @override
  String get communityCountryNamesDE => 'Germany';

  @override
  String get communityCountryNamesDK => 'Denmark';

  @override
  String get communityCountryNamesDO => 'Dominican Republic';

  @override
  String get communityCountryNamesDZ => 'Algeria';

  @override
  String get communityCountryNamesEC => 'Ecuador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Egypt';

  @override
  String get communityCountryNamesES => 'Spain';

  @override
  String get communityCountryNamesET => 'Ethiopia';

  @override
  String get communityCountryNamesFI => 'Finland';

  @override
  String get communityCountryNamesFR => 'France';

  @override
  String get communityCountryNamesGB => 'United Kingdom';

  @override
  String get communityCountryNamesGE => 'Georgia';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Greece';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croatia';

  @override
  String get communityCountryNamesHU => 'Hungary';

  @override
  String get communityCountryNamesID => 'Indonesia';

  @override
  String get communityCountryNamesIE => 'Ireland';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'India';

  @override
  String get communityCountryNamesIQ => 'Iraq';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Iceland';

  @override
  String get communityCountryNamesIT => 'Italy';

  @override
  String get communityCountryNamesJO => 'Jordan';

  @override
  String get communityCountryNamesJP => 'Japan';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Cambodia';

  @override
  String get communityCountryNamesKR => 'South Korea';

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
  String get communityCountryNamesLT => 'Lithuania';

  @override
  String get communityCountryNamesLU => 'Luxembourg';

  @override
  String get communityCountryNamesLV => 'Latvia';

  @override
  String get communityCountryNamesLY => 'Libya';

  @override
  String get communityCountryNamesMA => 'Morocco';

  @override
  String get communityCountryNamesMD => 'Moldova';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'North Macedonia';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolia';

  @override
  String get communityCountryNamesMO => 'Macao';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Mexico';

  @override
  String get communityCountryNamesMY => 'Malaysia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Netherlands';

  @override
  String get communityCountryNamesNO => 'Norway';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'New Zealand';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Philippines';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Poland';

  @override
  String get communityCountryNamesPR => 'Puerto Rico';

  @override
  String get communityCountryNamesPT => 'Portugal';

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
  String get communityCountryNamesSA => 'Saudi Arabia';

  @override
  String get communityCountryNamesSE => 'Sweden';

  @override
  String get communityCountryNamesSG => 'Singapore';

  @override
  String get communityCountryNamesSI => 'Slovenia';

  @override
  String get communityCountryNamesSK => 'Slovakia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Thailand';

  @override
  String get communityCountryNamesTL => 'Timor-Leste';

  @override
  String get communityCountryNamesTN => 'Tunisia';

  @override
  String get communityCountryNamesTR => 'Türkiye';

  @override
  String get communityCountryNamesTW => 'Taiwan';

  @override
  String get communityCountryNamesUA => 'Ukraine';

  @override
  String get communityCountryNamesUS => 'United States';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Uzbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'South Africa';

  @override
  String get communityCreateLfg => 'Create LFG post';

  @override
  String get communityCreateLfgShort => 'Post';

  @override
  String get communityDataDeleted => 'Your Community data has been deleted.';

  @override
  String communityDataFooter(String riotId) {
    return 'Applies to the current account: $riotId. The download doesn\'t include your password or Riot sign-in data.';
  }

  @override
  String get communityDataTitle => 'Your Community data';

  @override
  String get communityDecrease => 'Decrease';

  @override
  String get communityDelete => 'Delete';

  @override
  String get communityDeleteComment => 'Delete comment';

  @override
  String get communityDeleteCommentBody =>
      'This comment will be permanently deleted.';

  @override
  String get communityDeleteCommentTitle => 'Delete comment?';

  @override
  String get communityDeleteDataConfirm => 'Delete permanently';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'All posts, comments, skin reviews, likes, votes, LFG posts and photos from $riotId on ValHub Community will be permanently deleted and can\'t be recovered. You\'ll go back to browsing anonymously and need to agree again if you want to rejoin.\n\nYour Riot account and in-game data aren\'t affected. Download your data first if you want to keep a copy.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Delete Community data?';

  @override
  String get communityDeleteDataSubtitle =>
      'Permanently delete everything you\'ve posted to Community.';

  @override
  String get communityDeleteDataTitle => 'Delete my Community data';

  @override
  String get communityDeletePost => 'Delete post';

  @override
  String get communityDeletePostBody =>
      'This post and all its comments will be permanently deleted.';

  @override
  String get communityDeletePostTitle => 'Delete post?';

  @override
  String get communityDeleteReview => 'Delete review';

  @override
  String get communityDeleteReviewBody =>
      'Your rating and review for this skin will be deleted.';

  @override
  String get communityDeleteReviewTitle => 'Delete your review?';

  @override
  String get communityDeleted => 'Deleted.';

  @override
  String get communityDiscard => 'Discard';

  @override
  String get communityDiscardBody => 'What you just wrote won\'t be saved.';

  @override
  String get communityDiscardTitle => 'Discard post?';

  @override
  String get communityDownload => 'Download and translate';

  @override
  String get communityDownloadingModels => 'Downloading language pack…';

  @override
  String get communityEditReview => 'Edit';

  @override
  String get communityEdited => 'edited';

  @override
  String get communityEmptyPost => 'Write something or add a photo.';

  @override
  String get communityExpired => 'Expired';

  @override
  String communityExpiresIn(String t) {
    return '$t left';
  }

  @override
  String get communityExportPreparing => 'Preparing…';

  @override
  String get communityExportSubject => 'ValHub Community data';

  @override
  String get communityExportSubtitle =>
      'A copy of everything you\'ve posted in Community: posts, comments, reviews, likes, votes and LFG posts.';

  @override
  String get communityExportTitle => 'Download my data';

  @override
  String get communityExtend => 'Extend';

  @override
  String get communityExtended => 'Post extended by 30 minutes.';

  @override
  String get communityFeedEmptyBody =>
      'Be the first to share your store, Night Market or best moments!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'No matching posts. Try another language or clear the filters.';

  @override
  String get communityFeedEmptyGuestBody =>
      'No new posts yet. Check back later or join to share.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Try posts from the international community or change the filters.';

  @override
  String get communityFeedEmptyScopeTitle => 'No posts here yet';

  @override
  String get communityFeedEmptyTitle => 'The feed is empty';

  @override
  String get communityFilters => 'Filters';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Translated by Google';

  @override
  String get communityHelpful => 'Helpful';

  @override
  String communityHelpfulCount(String n) {
    return 'Helpful · $n';
  }

  @override
  String get communityHiddenAuthors => 'Hidden and blocked players';

  @override
  String get communityHiddenAuthorsEmpty =>
      'You haven\'t hidden or blocked anyone';

  @override
  String get communityHiddenAuthorsHint =>
      'Applies only to this account on this device. Their content is hidden; they can still see your public content.';

  @override
  String communityImageOf(int i, int n) {
    return 'Photo $i/$n';
  }

  @override
  String get communityIncrease => 'Increase';

  @override
  String get communityJoin => 'Join';

  @override
  String get communityJoinCodeExpired =>
      'The party code has expired or is no longer valid.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'You\'ll leave your current VALORANT party to join $name\'s party.';
  }

  @override
  String get communityJoinConfirmTitle => 'Join this party?';

  @override
  String get communityJoinGameNotRunning =>
      'Open VALORANT on your PC or console and try again.';

  @override
  String get communityJoinParty => 'Join party';

  @override
  String get communityJoinPartyFull => 'This party is full.';

  @override
  String get communityJoinedHint =>
      'You joined the party! Open VALORANT to play together.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString join requests',
      one: '$nString join request',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Night Market';

  @override
  String get communityKindStore => 'Today\'s store';

  @override
  String get communityLanguage => 'Language';

  @override
  String get communityLanguageFilter => 'Content language';

  @override
  String get communityLanguageFilterHint =>
      'Only show content written in the selected languages. Leave empty to see everything.';

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
      other: '$n languages',
      one: '$n language',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Create a post so other players can join your party with one tap.';

  @override
  String get communityLfgEmptyTitle => 'No one is looking for teammates yet';

  @override
  String get communityLfgExpiredRepost =>
      'Your post has expired. Create a new one to find teammates.';

  @override
  String get communityLfgGateBody =>
      'Join (verify your Riot ID once) to see posts from players on your server and post your own LFG. You can still browse the Feed and Skin rankings as usual.';

  @override
  String get communityLfgGateTitle => 'Find teammates is for members';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'You\'re viewing the $region server — only players on the same server as your account can join parties.';
  }

  @override
  String get communityLfgPosted => 'LFG post published!';

  @override
  String get communityLfgPreviewTitle => 'Find teammates at your rank';

  @override
  String get communityLfgRemoved => 'Post removed.';

  @override
  String get communityLfgSameShardNote =>
      'Only players on the same server can join the party.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Region: $region · Posts expire automatically after 30 minutes.';
  }

  @override
  String get communityLike => 'Like';

  @override
  String get communityLiveMembers => 'Members';

  @override
  String get communityMatchMyRank => 'Matches your rank';

  @override
  String communityMemberJoined(String name) {
    return '$name joined the party';
  }

  @override
  String get communityMemberJoinedBody =>
      'Someone just joined from your LFG post.';

  @override
  String get communityMic => 'Mic required';

  @override
  String get communityMicOn => 'Has mic';

  @override
  String get communityMode => 'Mode';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'More options';

  @override
  String get communityMuteAuthor => 'Hide this player';

  @override
  String get communityNewPost => 'Post';

  @override
  String communityNightMarketOf(String date) {
    return 'Night Market on $date';
  }

  @override
  String get communityNoAccountBody =>
      'Add a Riot account to post, find teammates and vote on skins.';

  @override
  String get communityNoAccountTitle => 'Sign in to join';

  @override
  String get communityNoComments =>
      'No comments yet. Be the first to say something!';

  @override
  String get communityNoRatings => 'No ratings yet';

  @override
  String get communityNote => 'Note';

  @override
  String get communityNoteHint =>
      'e.g. need 1 Controller, mic on, just here for fun';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get communityOpenReviews => 'See reviews';

  @override
  String get communityOutOfRange => 'Outside rank range';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Party code';

  @override
  String get communityPartyCodeHint => 'e.g. A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Party code: $code';
  }

  @override
  String get communityPartySize => 'Current party';

  @override
  String get communityPartySizeFromGame => 'Taken from your in-game party';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n players',
      one: '$n player',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max photos';
  }

  @override
  String get communityPlayVideo => 'Watch video';

  @override
  String get communityPostLfg => 'Post';

  @override
  String get communityPostNotFound => 'This post has been deleted or hidden.';

  @override
  String get communityPostTitle => 'Post';

  @override
  String get communityPosted => 'Posted!';

  @override
  String get communityPublish => 'Post';

  @override
  String get communityPublishing => 'Posting…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'From';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Rank range';

  @override
  String get communityRankRangeInvalid =>
      'The lowest rank can\'t be higher than the highest rank.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Rank $n: $name';
  }

  @override
  String get communityRankTo => 'To';

  @override
  String get communityRateLimitedTitle => 'Hold on a moment';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString ratings',
      one: '$nString rating',
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
      other: '$nString ratings',
      one: '$nString rating',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Bad';

  @override
  String get communityRatingWordsItem1 => 'Meh';

  @override
  String get communityRatingWordsItem2 => 'Okay';

  @override
  String get communityRatingWordsItem3 => 'Great';

  @override
  String get communityRatingWordsItem4 => 'Masterpiece';

  @override
  String get communityRefreshList => 'Refresh';

  @override
  String get communityRegion => 'Region';

  @override
  String get communityRemoveAttachment => 'Remove attachment';

  @override
  String get communityRemoveLfg => 'Remove post';

  @override
  String get communityRemoveLfgBody =>
      'Other players won\'t see this post anymore.';

  @override
  String get communityRemoveLfgTitle => 'Remove LFG post?';

  @override
  String get communityRemovePhoto => 'Remove photo';

  @override
  String get communityReport => 'Report';

  @override
  String get communityReportConfirmBody =>
      'Content reported by many players will be hidden from Community.';

  @override
  String get communityReportConfirmTitle => 'Send report?';

  @override
  String get communityReportPrompt => 'Why are you reporting this?';

  @override
  String get communityReportReasonsSpam => 'Spam or advertising';

  @override
  String get communityReportReasonsHarassment => 'Harassment or insults';

  @override
  String get communityReportReasonsInappropriate => 'Inappropriate content';

  @override
  String get communityReportReasonsScam => 'Scam or account selling';

  @override
  String get communityReportReasonsOther => 'Other reason';

  @override
  String get communityReportTitle => 'Report content';

  @override
  String get communityReported => 'Thanks! Your report has been sent.';

  @override
  String get communityReviewDeleted => 'Review deleted.';

  @override
  String get communityReviewHint =>
      'Share what you think of this skin (optional)';

  @override
  String get communityReviewSaved => 'Review saved!';

  @override
  String get communityReviewTitle => 'Rate skin';

  @override
  String get communityReviewsEmptyBody => 'No reviews yet — be the first!';

  @override
  String get communityReviewsEmptyTitle => 'No reviews yet';

  @override
  String communityReviewsHeader(String n) {
    return 'Reviews · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot is having issues';

  @override
  String get communityRoleFlex => 'Flex';

  @override
  String get communityRoles => 'Roles needed';

  @override
  String get communitySaveReview => 'Save review';

  @override
  String get communityScopeCountry => 'Your country';

  @override
  String get communityScopeGlobal => 'International';

  @override
  String get communityScopeRegion => 'Region';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Find teammates';

  @override
  String get communitySectionSkins => 'Skin rankings';

  @override
  String get communitySend => 'Send';

  @override
  String get communitySendComment => 'Send comment';

  @override
  String get communityShareNightMarketHint =>
      'Show off your Night Market to everyone';

  @override
  String communitySharePostTitle(String name) {
    return '$name\'s post on ValHub';
  }

  @override
  String get communityShareStore => 'Share to Community';

  @override
  String get communityShareStoreHint => 'Show off today\'s store to everyone';

  @override
  String get communityShowOriginal => 'Show original';

  @override
  String get communityShowTranslation => 'Show translation';

  @override
  String get communitySignInToReview => 'Add a Riot account to rate skins.';

  @override
  String get communitySkinNotFound => 'Couldn\'t find this skin.';

  @override
  String get communitySlots => 'Players needed';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'A party has up to 5 players: only $max spots left.',
      one: 'A party has up to 5 players: only $max spot left.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Need $n players',
      one: 'Need $n player',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Most helpful';

  @override
  String get communitySortNewest => 'Newest';

  @override
  String get communitySortRating => 'Highest rated';

  @override
  String get communitySortReviews => 'Most reviewed';

  @override
  String get communitySortVotes => 'Most loved';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stars',
      one: '$n star',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg out of 5 stars';
  }

  @override
  String get communityStatusFull => 'Full';

  @override
  String get communityStatusInGame => 'In match';

  @override
  String get communityStatusOpen => 'Looking';

  @override
  String communityStoreOf(String date) {
    return 'Store on $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Tap the stars to rate this skin';

  @override
  String get communityTitle => 'Community';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Up to $max characters.',
      one: 'Up to $max character.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Translate with Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'To translate from $from to $to, ValHub needs to download a language pack from Google (about $size). You only download it once; content is translated entirely on your device and isn\'t sent to any server.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Download on-device language pack?';

  @override
  String get communityTranslateFailed => 'Couldn\'t translate. Try again.';

  @override
  String get communityTranslatedByGoogle =>
      'Automatically translated by Google';

  @override
  String get communityTranslating => 'Translating…';

  @override
  String get communityTrendingTitle => 'Most loved skins worldwide';

  @override
  String get communityUnavailableBody =>
      'Couldn\'t connect to ValHub Community. Try again in a few minutes.';

  @override
  String get communityUnavailableTitle => 'Couldn\'t connect to Community';

  @override
  String get communityUnhideAuthor => 'Unhide / unblock';

  @override
  String get communityUnknownPlayer => 'Player';

  @override
  String get communityUnlike => 'Unlike';

  @override
  String get communityUnvote => 'Remove heart';

  @override
  String get communityVote => 'Heart this skin';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString likes',
      one: '$nString like',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Withdraw';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub will stop using Community with $riotId: the Community connection on this device is removed and you go back to browsing anonymously.\n\nPosts, comments, reviews, votes and LFG posts you\'ve published stay on Community and keep showing your Riot ID until you delete them one by one, or choose \"Delete my Community data\". You can rejoin at any time.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Withdraw consent?';

  @override
  String get communityWithdrawSubtitle =>
      'Stop using Community with this account. Your posts are kept.';

  @override
  String get communityWithdrawTitle => 'Withdraw consent';

  @override
  String get communityWriteFirstReview => 'Write the first review';

  @override
  String get communityYou => 'You';

  @override
  String get communityYourCountry => 'Your country';

  @override
  String get communityYourReview => 'Your review';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString people hidden',
      one: '$nString person hidden',
    );
    return '$_temp0';
  }

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'You: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Agent select';

  @override
  String get liveGameAnonymous => 'Anonymous';

  @override
  String get liveGameAutoRefreshNote =>
      'Refreshes automatically when you\'re in a match.';

  @override
  String get liveGameCurrentGame => 'Current match';

  @override
  String get liveGameEmptyTeam => 'No players yet.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'The enemy team appears once the match starts.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Enemy team locked $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'This live match feed doesn\'t provide Kills/Deaths/Assists. The scoreboard appears once Riot publishes the post-match data.';

  @override
  String get liveGameFinalScoreboard => 'Final scoreboard';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'In lobby';

  @override
  String get liveGameInMatch => 'In match';

  @override
  String get liveGameInQueue => 'In queue';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'In queue · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Level $n';
  }

  @override
  String get liveGameLiveScore => 'Live score';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Loadout from agent select';

  @override
  String get liveGameLoadoutFromMatch => 'Loadout in this match';

  @override
  String get liveGameLobbyHint =>
      'Once a match is found, ValHub shows every team\'s lineup and ranks.';

  @override
  String get liveGameLockedTag => 'Locked in';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub will retry automatically. The scoreboard is usually ready in about a minute.';

  @override
  String get liveGameNoAgentYet => 'No agent selected';

  @override
  String get liveGameNoLoadout => 'No loadout info for this player.';

  @override
  String get liveGameNotInGame => 'Not in a match';

  @override
  String get liveGameNotInGameHint =>
      'Open VALORANT and queue up — match details show up here automatically once you reach agent select.';

  @override
  String get liveGameNotInGameTitle => 'You\'re not in a match';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'View $name\'s loadout';
  }

  @override
  String get liveGameOpenParty => 'Open party & queue';

  @override
  String get liveGameParty => 'Party';

  @override
  String liveGamePeak(String rank) {
    return 'Peak: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return '$name\'s loadout';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Loadout';

  @override
  String get liveGameQueueHint =>
      'Keep the app open — match details show up as soon as a match is found.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Leaving the match may get you penalized (RR loss, queue restriction). Leave anyway?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Dodging in agent select may get you penalized (RR loss, queue restriction). Leave anyway?';

  @override
  String get liveGameQuitConfirmTitle => 'Leave match?';

  @override
  String get liveGameQuitDone => 'You left the match.';

  @override
  String get liveGameQuitFailed => 'Couldn\'t leave the match.';

  @override
  String get liveGameQuitMatch => 'Leave match';

  @override
  String get liveGameQuitMatchChanged =>
      'The match moved to a new phase while you were confirming. You haven\'t left; try again.';

  @override
  String get liveGameRankUnavailable => 'Rank unknown';

  @override
  String get liveGameRefresh => 'Refresh';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Refreshing in $seconds seconds',
      one: 'Refreshing in $seconds second',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Refresh now';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Match details';

  @override
  String get liveGameSprays => 'Sprays';

  @override
  String get liveGameStatusAgentSelect => 'Agent select';

  @override
  String get liveGameStatusEnded => 'Ended';

  @override
  String get liveGameStatusInProgress => 'In progress';

  @override
  String get liveGameStatusUnavailable => 'Couldn\'t update match status';

  @override
  String get liveGameTabAllPlayers => 'Players';

  @override
  String get liveGameTabEnemyTeam => 'Enemy team';

  @override
  String get liveGameTabYourTeam => 'Your team';

  @override
  String liveGameTimeLeft(String t) {
    return '$t left';
  }

  @override
  String get liveGameViewMatchDetails => 'View match details';

  @override
  String get liveGameWeapons => 'Weapons';

  @override
  String get liveGameYou => 'YOU';

  @override
  String liveGameYouHover(String agent) {
    return 'You\'re selecting $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'You locked in $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Pick and lock in your agent in VALORANT. ValHub only shows the time left and your team.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wins',
      one: '$wins win',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses losses',
      one: '$losses loss',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws draws',
      one: ' – $draws draw',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown matches with unknown result',
      one: ' – $unknown match with unknown result',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'device time ($offset)';
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
      'yes': ' with $weapon',
      'other': '',
    });
    return '$killer eliminated $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 days',
      'days7': '7 days',
      'other': 'All time',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agents',
      'maps': 'Maps',
      'queues': 'Modes',
      'sides': 'Attack / Defense',
      'trend': 'Trend',
      'other': 'Modes',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'All modes';

  @override
  String get profileAbility => 'Ability';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n matches',
      one: '$n match',
    );
    return '≈ $_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Average combat score';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wins',
      one: '$wins win',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games matches',
      one: '$games match',
    );
    return 'This act: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'All players';

  @override
  String get profileAlreadyReached => 'You\'ve already reached this rank.';

  @override
  String get profileAtCurrentForm => 'At your current form';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'At your current form ($gain / $loss per match)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Best case: $n wins in a row',
      one: 'Best case: $n win in a row',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'By win rate';

  @override
  String get profileChooseMap => 'Filter by map';

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
  String get profileCopyRiotId => 'Copy Riot ID';

  @override
  String get profileCurrentRank => 'Current';

  @override
  String get profileDailyRrEmpty =>
      'No Competitive matches saved on this device yet.';

  @override
  String get profileDailyRrFootnote =>
      'RR history is saved right on your device, including matches Riot no longer returns.';

  @override
  String get profileDailyRrTitle => 'Daily RR';

  @override
  String profileDayBoundary(String zone) {
    return 'Days are based on $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days played',
      one: '$n day played',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'All matches shown';

  @override
  String get profileEnemyTeam => 'Enemy team';

  @override
  String get profileFallDamage => 'Fall damage';

  @override
  String get profileFilterAll => 'All';

  @override
  String get profileFirstBloods => 'First bloods';

  @override
  String get profileFirstDeaths => 'First deaths';

  @override
  String get profileFirstHalf => 'First half';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS and HS% only count round-based modes.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n listed matches haven\'t loaded yet for these stats.',
      one: '$n listed match hasn\'t loaded yet for these stats.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR and HS% only count $roundGames/$games round-based matches';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'Last $games matches',
      one: 'Last $games match',
    );
    String _temp1 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w wins',
      one: '$w win',
    );
    String _temp2 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l losses',
      one: '$l loss',
    );
    return '$_temp0: $_temp1, $_temp2';
  }

  @override
  String get profileFriendsRow => 'Friends & chat';

  @override
  String get profileHideKills => 'Hide kills';

  @override
  String get profileHitBody => 'Body';

  @override
  String get profileHitDistribution => 'Hit distribution';

  @override
  String get profileHitHead => 'Head';

  @override
  String get profileHitLegs => 'Legs';

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
      'Share of rounds where you got a kill, assist, survived or were traded';

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
      other: 'Last $n days',
      one: 'Last $n day',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Last $n matches',
      one: 'Last $n match',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Leaderboard #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Level $n';
  }

  @override
  String get profileLevelHidden => 'Level hidden';

  @override
  String profileLossStreak(int n) {
    return '$n-match losing streak';
  }

  @override
  String profileMapFilter(String map) {
    return 'Map: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n matches',
      one: '$n match',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Match details';

  @override
  String get profileMatchHistory => 'Match history';

  @override
  String get profileMatchUnavailable => 'Couldn\'t load match';

  @override
  String get profileMatchesNeeded => 'Matches needed';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Never ranked';

  @override
  String get profileNoKillsInRound => 'No kill info for this round yet.';

  @override
  String get profileNoMatches => 'No matches yet.';

  @override
  String get profileNoMatchesMap =>
      'No matches on this map among the loaded matches.';

  @override
  String get profileNoMatchesQueue => 'No matches in this mode.';

  @override
  String get profileNoPlayers => 'No player info for this match yet.';

  @override
  String get profileNoRounds => 'No round-by-round info for this match yet.';

  @override
  String get profileOvertime => 'Overtime';

  @override
  String get profilePlayHubTitle => 'Match & party';

  @override
  String get profilePeakRank => 'Peak';

  @override
  String get profilePerformanceAttack => 'Attack';

  @override
  String get profilePerformanceDefense => 'Defense';

  @override
  String get profilePerformanceEmpty =>
      'No matches recorded on this device yet. Open your match history to record the matches you\'ve played.';

  @override
  String get profilePerformanceNoMatches =>
      'No matches in the selected time range.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rounds recorded',
      one: '$n round recorded',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Rates only show with at least 3 matches. ACS, ADR, HS% and K/D only count round-based modes.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Attack or defense side identified in $known/$total rounds.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'History on this device, since $date';
  }

  @override
  String get profilePerformanceTitle => 'Performance';

  @override
  String profilePlacement(int n) {
    return 'Place $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike planted at $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Player profile';

  @override
  String get profilePlayerSummary => 'Performance';

  @override
  String profileProgressTo(String rank) {
    return 'Progress to $rank';
  }

  @override
  String get profileProgressToTarget => 'Progress to target rank';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Estimate based on recent Competitive matches; doesn\'t account for placement matches or demotion protection.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches matches to reach $rank',
      one: '≈ $matches match to reach $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'You\'re already Immortal or higher — this tool only goes up to Immortal 1.';

  @override
  String get profileRankUpNoForm =>
      'No recent Competitive matches to estimate your form.';

  @override
  String get profileRankUpOpen => 'Open rank-up calculator';

  @override
  String get profileRankUpTitle => 'Rank-up calculator';

  @override
  String get profileRankUpUnranked =>
      'Finish your placement matches to use the rank-up calculator.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Competitive scoreboard';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w wins',
      one: '$w win',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l losses',
      one: '$l loss',
    );
    return 'Recent form: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Recent form';

  @override
  String get profileRecentMatches => 'Recent matches';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}W · ${l}L · ${d}D',
      one: '${w}W · ${l}L · ${d}D',
      zero: '${w}W · ${l}L',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID copied';

  @override
  String profileRound(int n) {
    return 'Round $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n kills',
      one: '$n kill',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Round lost';

  @override
  String get profileRoundTimeline => 'Round timeline';

  @override
  String get profileRoundWon => 'Round won';

  @override
  String get profileRoundsHint => 'Tap a round to see each kill.';

  @override
  String profileRrLeft(String n) {
    return '$n RR to go';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR trend';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Scoreboard';

  @override
  String get profileSecondHalf => 'Second half';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Show kills';

  @override
  String get profileSideSwitch => 'Side switch';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Target rank';

  @override
  String get profileTeamBlue => 'Blue team';

  @override
  String get profileTeamMvp => 'Team MVP';

  @override
  String get profileTeamRed => 'Red team';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileToday(String text) {
    return 'Today: $text';
  }

  @override
  String get profileTodayNone => 'No Competitive matches today';

  @override
  String get profileTruePeakLocal => 'Based on history on this device';

  @override
  String get profileWeekdayShortItem0 => 'Mon';

  @override
  String get profileWeekdayShortItem1 => 'Tue';

  @override
  String get profileWeekdayShortItem2 => 'Wed';

  @override
  String get profileWeekdayShortItem3 => 'Thu';

  @override
  String get profileWeekdayShortItem4 => 'Fri';

  @override
  String get profileWeekdayShortItem5 => 'Sat';

  @override
  String get profileWeekdayShortItem6 => 'Sun';

  @override
  String get profileWinRate => 'Win rate';

  @override
  String profileWinStreak(int n) {
    return '$n-match win streak';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Your rank';

  @override
  String get profileYourSummary => 'Your performance';

  @override
  String get profileYourTeam => 'Your team';

  @override
  String get profileYourWinRate => 'Your recent win rate';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Mode: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filter by mode';

  @override
  String get profilePerformancePerMatchTitle => 'Per match';

  @override
  String get profilePerformancePerMatchHint => 'Tap a bar to open that match.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Average $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Needs at least 2 round-based matches with this stat to draw the chart.';

  @override
  String get profilePerformanceOpeningsTitle => 'Opening duels';

  @override
  String get profilePerformanceOpeningWin => 'Opening win rate';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Of the rounds where you got the first kill or died first, how often you got the kill.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'First bloods per match';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'First deaths per match';

  @override
  String get profilePerformanceMultiKillsTitle => 'Multi-kills in a round';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 kills',
      'k4': '4 kills',
      'ace': 'Ace',
      'other': '2 kills',
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
      other: 'Based on $nString matches with full kill data.',
      one: 'Based on $nString match with full kill data.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Round win rate';

  @override
  String get profilePerformanceDrillHint =>
      'Tap a row to see just that agent, map or mode.';

  @override
  String get profilePerformanceLoadOlder => 'Analyze older matches';

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
          'ValHub only analyzes matches opened on this device. Each tap adds up to $nString older matches.',
      one:
          'ValHub only analyzes matches opened on this device. Each tap adds up to $nString older match.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Looking for older matches…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analyzing matches: $doneString/$totalString…';
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
      other: 'Added $nString matches to the analysis.',
      one: 'Added $nString match to the analysis.',
      zero: 'No new matches to add.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot doesn\'t keep any older matches.';

  @override
  String get profileEconomyTitle => 'Your team economy';

  @override
  String get profileEconomyHint =>
      'Buy type from your team\'s total loadout value at the start of the round (vlr.gg convention for 5 players): Eco under 5,000, Semi-eco under 10,000, Semi-buy under 20,000, Full buy from 20,000 credits. The first round of each half is Pistol.';

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

    return 'Won $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => 'Latest session';

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

    return 'Most played: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      'Your VALORANT companion: daily store, wishlist, rank, matches, multiple accounts and a player community, right on your device.';

  @override
  String get legalBackToTop => 'Back to top';

  @override
  String get legalConsentAnd => ' and ';

  @override
  String get legalConsentPrefix => 'By continuing, you agree to the ';

  @override
  String get legalConsentPrivacy => 'Privacy Policy';

  @override
  String get legalConsentSuffix => ' of ValHub.';

  @override
  String get legalConsentTerms => 'Terms of Use';

  @override
  String get legalContact => 'Contact';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'CONTACT';

  @override
  String legalEffectiveFrom(String date) {
    return 'Effective from $date';
  }

  @override
  String get legalLegalHeader => 'LEGAL';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. All rights reserved.';

  @override
  String get legalThirdPartyLicenses => 'Third-party software';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licenses for the open-source software ValHub uses';

  @override
  String get legalTocTitle => 'CONTENTS';

  @override
  String legalVersion(String version) {
    return 'Version $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'This document is currently shown in $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Couldn\'t read the legal document. Try again or contact support.';

  @override
  String get legalTranslationNotice =>
      'This translation is provided for convenience. If there is any difference, the Vietnamese version prevails.';

  @override
  String get settingsUiLanguageTitle => 'App language';

  @override
  String get settingsLanguageFollowDevice => 'Use device language';

  @override
  String get settingsLanguageSaveFailed =>
      'Couldn\'t save the language. Please try again.';

  @override
  String get settingsGeoCountry => 'Country';

  @override
  String get settingsGeoSearchCountry => 'Search country name or code';

  @override
  String get settingsGeoSupportedOnly => 'Confirmed supported only';

  @override
  String get settingsGeoUnknown => 'Support not verified';

  @override
  String get settingsGeoRestricted => 'Restricted';

  @override
  String get settingsGeoSeparate => 'Separate service';

  @override
  String get settingsGeoAvailable => 'Supported';

  @override
  String get settingsGeoNotApplicable => 'Not applicable';

  @override
  String get settingsGeoConnection => 'Riot connection';

  @override
  String get settingsGeoChooseRegion => 'Choose region';

  @override
  String get settingsGeoAuto => 'Automatic from account';

  @override
  String get settingsGeoManual => 'Choose manually';

  @override
  String get settingsGeoNoRegion => 'Couldn\'t detect your Riot region';

  @override
  String get settingsGeoManualWarning =>
      'This only changes which server ValHub connects to. It doesn\'t move your Riot account\'s region. ValHub checks the connection before saving.';

  @override
  String get settingsGeoConnectionSaved => 'Connection saved';

  @override
  String get settingsGeoValidationFailed =>
      'Your account couldn\'t be confirmed on this server. Choose your region again.';

  @override
  String get settingsGeoHintOnly =>
      'Country is only used for lookups and suggestions. Your connection region follows your Riot account.';

  @override
  String get settingsGeoSave => 'Check and save';

  @override
  String get settingsGeoCancel => 'Cancel';

  @override
  String get settingsGeoLoading => 'Checking connection…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'This choice is used for country names, suggestions and estimated VP prices. Your server connection and Community account country are still set by Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'Use account or device country';

  @override
  String get settingsGeoSaveFailed => 'Couldn\'t save your choice. Try again.';

  @override
  String get settingsGeoAllRegions => 'All regions';

  @override
  String get settingsGeoSuggestions => 'Suggestions';

  @override
  String get settingsGeoNoCountries => 'No countries match the filter.';

  @override
  String get settingsGeoActiveCountries => 'Active';

  @override
  String get settingsGeoAllCountries => 'All countries';

  @override
  String get settingsGeoActivityUnavailable =>
      'Couldn\'t load country activity. You can still choose from All countries.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '$count country',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'You chose $manual, but Riot places your account in $detected. Continue checking this connection?';
  }

  @override
  String get settingsGeoUnverified =>
      'Couldn\'t verify the connection because the server or network is having issues. Save this choice and try again later?';

  @override
  String get settingsGeoContinue => 'Continue';

  @override
  String settingsGeoMismatch(String region) {
    return 'Your manual connection differs from your Riot region: $region. Switch to automatic?';
  }

  @override
  String get settingsGeoUseAuto => 'Use automatic';

  @override
  String get settingsGeoKeepManual => 'Keep manual';

  @override
  String get settingsGeoReviewConnection => 'View connection';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Last checked: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Check again';

  @override
  String get settingsPlatformMobile => 'Mobile';

  @override
  String get settingsPlatformOther => 'Other platform';

  @override
  String get settingsContentLanguageFollowApp => 'Same as app language';

  @override
  String get settingsContentLanguageHint =>
      'Choose the language for item names. This doesn\'t change the app language or your Riot server.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Language: $language.';
  }

  @override
  String get settingsAboutHeader => 'INFO';

  @override
  String get settingsAboutRowSubtitle =>
      'Privacy, terms, copyright and contact';

  @override
  String get settingsAboutTitle => 'About & legal';

  @override
  String get settingsAppHeader => 'ADVANCED';

  @override
  String get settingsAppearanceHeader => 'APPEARANCE';

  @override
  String settingsBuildNumber(String build) {
    return 'Build $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Cleared $size';
  }

  @override
  String get settingsClearCache => 'Clear temporary data';

  @override
  String get settingsClearCacheFailed =>
      'Couldn\'t clear temporary data. Try again.';

  @override
  String get settingsClearCacheSubtitle =>
      'Images and data downloaded to your device, including recorded bug reports';

  @override
  String get settingsExportLog => 'Send bug report to ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Nothing to send yet. Use the app for a while and try again.';

  @override
  String get settingsExportLogSubtitle =>
      'Bug reports don\'t include your password or Riot sign-in data.';

  @override
  String get settingsFeedback => 'Send feedback to ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Open ValHub\'s feedback page';

  @override
  String get settingsItemLanguageEn => 'English';

  @override
  String get settingsItemLanguageLabel => 'Item names';

  @override
  String get settingsItemLanguagePickerTitle => 'Item name language';

  @override
  String get settingsItemLanguageVi => 'Vietnamese';

  @override
  String get settingsLinkOpenFailed => 'Couldn\'t open the link. Try again.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Bug report';
  }

  @override
  String get settingsLogShareFailed =>
      'Couldn\'t send the bug report. Try again.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'When the Night Market opens';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Reminds you to flip your Night Market offers';

  @override
  String get settingsNotifPermissionMissing =>
      'The app doesn\'t have permission to send notifications.';

  @override
  String get settingsNotifStoreReset => 'When the store refreshes';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Daily at $time';
  }

  @override
  String get settingsNotifWishlist => 'When a wishlisted skin shows up';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Checks the store on every account, even when the app is closed';

  @override
  String get settingsNotificationsHeader => 'NOTIFICATIONS';

  @override
  String get settingsOptionAutoOpenLiveGame => 'Auto-open match details';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Open the current match panel as soon as a match is found';

  @override
  String get settingsOptionOwnPrice => 'Your VP pack price';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Not set — uses your region\'s price list if available';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Platform';

  @override
  String get settingsOptionShowLiveScore => 'Show live score';

  @override
  String get settingsOptionShowPeakRank => 'Show peak rank in match details';

  @override
  String get settingsOptionShowPrice => 'Show estimated prices';

  @override
  String get settingsOptionShowPriceInfo => 'How estimated prices work';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Next to VP prices, e.g. $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'No verified price list for your region yet — enter your VP pack price.';

  @override
  String get settingsOptionsHeader => 'OPTIONS';

  @override
  String get settingsPhaseComplete => 'Completed';

  @override
  String get settingsPhaseInProgress => 'In progress';

  @override
  String get settingsPhaseScheduled => 'Scheduled';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Applies to $account';
  }

  @override
  String get settingsPlatformHint =>
      'Choose PC, PlayStation or Xbox based on where you play to see the right match history.';

  @override
  String get settingsPlatformPickerTitle => 'Choose platform';

  @override
  String get settingsPrimingBody =>
      'Turn on notifications to know when your store refreshes and when a wishlisted skin shows up.';

  @override
  String get settingsPrimingEnable => 'Turn on notifications';

  @override
  String get settingsPrimingFootnote =>
      'You can turn each type of notification on or off at any time in Settings.';

  @override
  String get settingsPrimingLater => 'Later';

  @override
  String get settingsPrimingPointNightMarket =>
      'Know when the Night Market opens';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'So you can flip your offers before they expire';

  @override
  String get settingsPrimingPointStore =>
      'Reminders when the daily store refreshes';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Reminds you after your account\'s store refreshes';

  @override
  String get settingsPrimingPointWishlist =>
      'Alerts when a skin you\'re hunting shows up';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Checks the store on every account, even when the app is closed';

  @override
  String get settingsPrimingTitle => 'Never miss a skin you\'re hunting';

  @override
  String settingsRemovedAccount(String account) {
    return 'Removed $account';
  }

  @override
  String get settingsServerStatus => 'Server status';

  @override
  String get settingsServerStatusMaintenance => 'Under maintenance';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n notices',
      one: '$n notice',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'VALORANT maintenance and incidents by server';

  @override
  String get settingsSessionLogTitle => 'ValHub bug report';

  @override
  String get settingsSeverityCritical => 'Critical';

  @override
  String get settingsSeverityInfo => 'Info';

  @override
  String get settingsSeverityWarning => 'Warning';

  @override
  String get settingsSignedOutAll => 'Signed out of all accounts';

  @override
  String get settingsStatusAllGood => 'Servers are running normally';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'No incidents or maintenance on the $region server.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Show less';

  @override
  String get settingsStatusIssues => 'Riot is working on an issue';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'This server has $n incident notices.',
      one: 'This server has $n incident notice.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Incident';

  @override
  String get settingsStatusKindMaintenance => 'Maintenance';

  @override
  String get settingsStatusMaintenanceNow => 'Server under maintenance';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'You may not be able to play right now, and ValHub may temporarily be unable to load info.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Show $n more updates',
      one: 'Show $n more update',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Maintenance coming up';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n maintenance windows announced by Riot.',
      one: '$n maintenance window announced by Riot.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Source: Riot Games\' official status page. Times are shown in your device\'s time zone.';

  @override
  String settingsStatusStarted(String when) {
    return 'Started $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Updated $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'UPDATES FROM RIOT';

  @override
  String get settingsSupportHeader => 'SUPPORT';

  @override
  String settingsSwitchedTo(String account) {
    return 'Switched to $account';
  }

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemePickerTitle => 'Choose theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rank, match history, live matches';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR per match, opponents\' ranks';

  @override
  String get settingsWelcomeBulletStore =>
      'Daily store, Night Market and bundles';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Prices, rarity, refresh countdown';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist & notifications';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Get alerted when a skin you\'re hunting hits your store';

  @override
  String get settingsWelcomeFootnote =>
      'You sign in on Riot\'s official page. ValHub only saves your password if you choose to save your sign-in info.';

  @override
  String get settingsWelcomeKicker => 'VALORANT COMPANION';

  @override
  String get settingsCountryPriceHeader => 'Country & prices';

  @override
  String get settingsDataHeader => 'Data on this device';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (Ratings: $count) · ',
      'other': '',
    });
    return 'Community: ${_temp0}Likes: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Add to wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'In the store of: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      daily,
      locale: localeName,
      other: '$daily times in the daily store',
      one: '$daily time in the daily store',
    );
    String _temp1 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night Night Markets',
      one: '$night Night Market',
    );
    return 'In your store: $_temp0, $_temp1. Only counts data on this device, recorded since $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Delete store history';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Delete all recorded store days for this account on this device?';

  @override
  String get skinDetailInWishlist => 'In wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Locked';

  @override
  String get skinDetailMute => 'Mute';

  @override
  String get skinDetailNotFound => 'Couldn\'t find this skin.';

  @override
  String get skinDetailOwned => 'Owned';

  @override
  String get skinDetailPause => 'Pause';

  @override
  String get skinDetailPlay => 'Play';

  @override
  String get skinDetailPlayVideo => 'Watch video';

  @override
  String get skinDetailRemoveFromWishlist => 'Remove from wishlist';

  @override
  String get skinDetailTitle => 'Skin details';

  @override
  String get skinDetailUnmute => 'Unmute';

  @override
  String get skinDetailUpgrades => 'Upgrades';

  @override
  String get skinDetailVariants => 'Variants';

  @override
  String get skinDetailVideoError =>
      'Couldn\'t play the video. Check your connection and try again.';

  @override
  String get socialPresenceInMatch => 'In match';

  @override
  String get socialPresenceAgentSelect => 'In agent select';

  @override
  String get socialPresenceQueue => 'In queue';

  @override
  String get socialPresenceLobby => 'In lobby';

  @override
  String get socialPresenceCustom => 'In a custom game';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Open party',
      'other': 'Invite only',
    });
    return '$size/$max players · $_temp0';
  }

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialAcceptInGame => 'Accept this invite in game.';

  @override
  String socialActionFailed(String message) {
    return 'Couldn\'t complete that. $message';
  }

  @override
  String get socialAutoRefresh => 'Auto-refresh';

  @override
  String get socialAway => 'Away';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Cancel queue · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Cancel queue';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Your party can\'t queue for $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Change queue';

  @override
  String get socialChatUnavailable => 'Chat is offline.';

  @override
  String get socialCloseParty => 'Close party';

  @override
  String get socialCodeInvalid =>
      'Party codes only contain letters and digits.';

  @override
  String get socialConnecting => 'Connecting to chat…';

  @override
  String get socialCopyCode => 'Copy';

  @override
  String get socialCurrentQueue => 'Selected';

  @override
  String get socialCustomGameLobby => 'Your party is in a Custom Game lobby.';

  @override
  String get socialDecline => 'Decline';

  @override
  String get socialDisableCode => 'Disable code';

  @override
  String get socialEmptyChat => 'No messages yet. Say hi!';

  @override
  String get socialEmptyChatTitle => 'Start chatting';

  @override
  String get socialFailedBadge => 'Not sent';

  @override
  String get socialFilterAll => 'All';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Unread';

  @override
  String get socialFriendsPrivacyNote =>
      'Your friends list and messages come straight from Riot. ValHub doesn\'t store them anywhere else.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total friends',
      one: '$total friend',
    );
    return '$_temp0 · $online online';
  }

  @override
  String get socialFriendsTitle => 'Friends & chat';

  @override
  String get socialGameNotRunningBody =>
      'Party & queue only work while VALORANT is running on your PC or console. Open the game, then pull down to refresh.';

  @override
  String get socialGameNotRunningTitle => 'Open VALORANT on your PC or console';

  @override
  String get socialGenerateCode => 'Generate code';

  @override
  String get socialIdleQueue => 'Ready to queue';

  @override
  String get socialInMatchBanner =>
      'You\'re in a match. The queue reopens when the match ends.';

  @override
  String get socialInValorant => 'In VALORANT';

  @override
  String get socialInviteByRiotId => 'Invite by Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Invite players who aren\'t your friends yet';

  @override
  String get socialInviteFriends => 'Invite friends';

  @override
  String socialInviteFrom(String name) {
    return 'Invite from $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Invite $name';
  }

  @override
  String get socialInviteNeedsName =>
      'This player\'s Riot ID is unknown, so they can\'t be invited yet.';

  @override
  String socialInviteSent(String name) {
    return 'Invite sent to $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Invited';
  }

  @override
  String get socialInvitesSection => 'Invites';

  @override
  String get socialJoin => 'Join';

  @override
  String get socialJoinConfirmBody =>
      'You\'ll leave your current party to join the party with this code.';

  @override
  String get socialJoinConfirmTitle => 'Join another party?';

  @override
  String get socialJoinSection => 'Join another party';

  @override
  String get socialJoinWithCode => 'Enter a code to join';

  @override
  String get socialJoined => 'Joined the party.';

  @override
  String socialLastOnline(String relative) {
    return 'Active $relative';
  }

  @override
  String get socialLeader => 'Leader';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'You\'ll leave your current party and go back to a solo party.';

  @override
  String get socialLeaveConfirmTitle => 'Leave party?';

  @override
  String get socialLeaveParty => 'Leave party';

  @override
  String socialLevel(int n) {
    return 'Level $n';
  }

  @override
  String get socialMatchFound => 'Match found!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Members ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Type a message…';

  @override
  String get socialMoreActions => 'More options';

  @override
  String get socialNoCode =>
      'Generate a code so friends can quickly join your party.';

  @override
  String get socialNoCodeMember =>
      'The party leader can generate a code for quick invites.';

  @override
  String get socialNoFilterResults => 'No friends match this filter.';

  @override
  String get socialNoFriends =>
      'Your Riot friends list is empty. Add friends in game.';

  @override
  String get socialNoFriendsTitle => 'No friends yet';

  @override
  String get socialNoOnlineFriends =>
      'None of your friends are online in VALORANT right now.';

  @override
  String get socialNoSearchResults => 'No matching friends.';

  @override
  String get socialNoSearchResultsTitle => 'Nothing found';

  @override
  String get socialNotReady => 'Not ready';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online on mobile';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Only the party leader can change the queue and start matchmaking.';

  @override
  String get socialOpenParty => 'Open party';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Party code';

  @override
  String socialPartyCodeValue(String code) {
    return 'Party code: $code';
  }

  @override
  String get socialPartyInvite => 'Party invite';

  @override
  String socialPartyOf(int size, int max) {
    return 'Party $size/$max';
  }

  @override
  String get socialPartyTitle => 'Party & queue';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'Party of $size';
  }

  @override
  String get socialPickQueueTitle => 'Choose queue';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Best ping to match servers';

  @override
  String socialPlayingOther(String game) {
    return 'Playing $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Playing ($n)';
  }

  @override
  String get socialQueueLabel => 'Queue';

  @override
  String get socialQueueLocked => 'You can\'t change queues while in a match.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Up to $max players',
      one: 'Up to $max player',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Couldn\'t verify your game status. Refresh to use ready and queue.';

  @override
  String get socialReady => 'Ready';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Ready $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => 'a member\'s account level is too low';

  @override
  String get socialReasonGeneric => 'the party isn\'t eligible yet';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'the party is too large (max $max)';
  }

  @override
  String get socialReasonRankDisparity =>
      'the rank gap is too large for Competitive';

  @override
  String socialReasonRestricted(String time) {
    return 'the party is restricted from queuing ($time left)';
  }

  @override
  String get socialReconnecting => 'Chat disconnected. Reconnecting…';

  @override
  String get socialRemoteNote =>
      'Changes are only sent to Riot when you tap. ValHub never queues or locks in an agent for you.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name will be removed from your party.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Remove from party?';

  @override
  String get socialRemoveMember => 'Remove from party';

  @override
  String socialRequestFrom(String name) {
    return '$name wants to join the party';
  }

  @override
  String get socialRequestsSection => 'Join requests';

  @override
  String get socialRiotIdFieldHint => 'Name#TAG';

  @override
  String get socialRiotIdInvalid =>
      'A Riot ID is a name (3–16 characters), a # and a tag (3–5 letters or digits).';

  @override
  String get socialSearchHint => 'Search by Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'In queue · $elapsed';
  }

  @override
  String get socialSend => 'Send';

  @override
  String get socialSendFailed =>
      'Couldn\'t send the message. Check your connection and try again.';

  @override
  String get socialSendInvite => 'Send invite';

  @override
  String get socialShareCode => 'Share';

  @override
  String socialShareCodeText(String code) {
    return 'Join my VALORANT party with code: $code';
  }

  @override
  String get socialShootingRange => 'In The Range';

  @override
  String get socialShowEveryone => 'Show all';

  @override
  String get socialStartQueue => 'Start queue';

  @override
  String get socialSuggestionsItem0 => 'Hey there!';

  @override
  String get socialSuggestionsItem1 => 'Wanna play a few games?';

  @override
  String get socialSuggestionsItem2 => 'Come join my party!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unread messages',
      one: '$n unread message',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Unready';

  @override
  String get socialViewProfile => 'View profile';

  @override
  String get socialWaitingForConnection =>
      'Connecting… You can send messages once connected.';

  @override
  String get socialYou => 'You';

  @override
  String get socialPartyUnavailable =>
      'Couldn\'t sync your party. Refresh to try again.';

  @override
  String get socialAcceptConfirmBody =>
      'You\'ll leave your current party to join the party that invited you.';

  @override
  String get storeAccessoryEmpty => 'The accessory store is empty right now.';

  @override
  String get storeAccessoryEmptyTitle => 'No accessories yet';

  @override
  String storeAccessoryFrom(String contract) {
    return 'From: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Refreshes in $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Refreshes at $wall';
  }

  @override
  String get storeAddToWishlist => 'Add to wishlist';

  @override
  String get storeBackToBundles => 'See bundles on sale';

  @override
  String get storeBundleBuySeparateLabel => 'Buy separately';

  @override
  String get storeBundleDetailTitle => 'Bundle details';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Ends at $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return '$t left';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items',
      one: '$n item',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Free';

  @override
  String get storeBundleItemsTitle => 'Items in bundle';

  @override
  String get storeBundleNotFound =>
      'Couldn\'t find this bundle. It may have expired.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle expired';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Owned $owned/$total items';
  }

  @override
  String get storeBundlePriceLabel => 'Bundle price';

  @override
  String get storeBundleSavingsLabel => 'You save';

  @override
  String get storeBundleWholesaleOnly =>
      'Only sold as a full bundle, not separately.';

  @override
  String get storeBundlesEmpty => 'No bundles on sale right now.';

  @override
  String get storeBundlesEmptyTitle => 'No bundles yet';

  @override
  String get storeDailyEmpty => 'There are no skins in the store today.';

  @override
  String get storeDailyEmptyTitle => 'Store is empty';

  @override
  String storeDailyResetAt(String time) {
    return 'Refreshes daily at $time';
  }

  @override
  String get storeDailyTotalLabel => 'Total';

  @override
  String get storeNightMarketEmpty => 'There\'s no Night Market right now.';

  @override
  String get storeNightMarketEmptyTitle => 'Night Market isn\'t open';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Ends at $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Ends in $t';
  }

  @override
  String get storeNightMarketNote =>
      'Night Market offers are unique to your account and can\'t be refreshed.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Total savings $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Not flipped';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Owned';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Owned $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Remove from wishlist';

  @override
  String get storeResetNotificationTitle => 'Your store has refreshed';

  @override
  String storeResetsIn(String t) {
    return 'Refreshes in $t';
  }

  @override
  String get storeSegmentAccessories => 'Accessories';

  @override
  String get storeSegmentBundles => 'Bundles';

  @override
  String get storeSegmentDaily => 'Daily';

  @override
  String get storeSegmentNightMarket => 'Night Market';

  @override
  String get storeShareButton => 'Share';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Today\'s store';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Night Market';

  @override
  String get storeShareCardPriceNote =>
      'Converted prices are only estimates based on VP packs.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Save $vp';
  }

  @override
  String get storeShareCardTagline => 'Your VALORANT companion';

  @override
  String storeShareCardTotal(String vp) {
    return 'Total $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Until $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Share today\'s store';

  @override
  String get storeShareFailed => 'Couldn\'t create the image. Try again.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Share image';

  @override
  String get storeShareNightMarketTitle => 'Share Night Market';

  @override
  String get storeSharePreparing => 'Loading skin images…';

  @override
  String get storeShareShowPrice => 'Show estimated prices';

  @override
  String get storeShareShowPriceHint =>
      'Converted using the best-value VP pack.';

  @override
  String get storeShareShowRiotId => 'Show Riot ID on image';

  @override
  String get storeShareShowRiotIdHint => 'Off by default to keep you private.';

  @override
  String get storeShareSubjectDaily => 'My VALORANT store today';

  @override
  String get storeShareSubjectNightMarket => 'My VALORANT Night Market';

  @override
  String get storeShareSubtitle =>
      'Share a picture of your store with friends through any app.';

  @override
  String get storeTitle => 'Store';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Balance: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n in wishlist';
  }

  @override
  String get storeHistoryTitle => 'Store history';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString days',
      one: '$daysString day',
    );
    return 'Recorded on this device since $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'No days recorded yet. ValHub saves your daily store each time you open the app, on this device only.';

  @override
  String get storeHistoryMostOffered => 'Most offered';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString times',
      one: '$nString time',
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
      other: 'Night Market · $countString offers',
      one: 'Night Market · $countString offer',
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
      other: '$daysString days recorded on this device',
      one: '$daysString day recorded on this device',
      zero: 'Recording started today',
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
      'yes': '$skin is in $account\'s store — $left left.',
      'other': '$skin is in $account\'s store.',
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
      'discount': '$skin is $percent% off, now $price ($account).',
      'price': '$skin is only $price ($account).',
      'other': '$skin is in $account\'s Night Market.',
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
      'yes': '$skin is in the $bundle bundle ($account).',
      'other': '$skin is in a bundle on sale ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'In $account\'s store now: $names and $more other skins.',
      one: 'In $account\'s store now: $names and $more other skin.',
      zero: 'In $account\'s store now: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', in wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Add skins';

  @override
  String get wishlistAddToWishlist => 'Add to wishlist';

  @override
  String get wishlistAllWeapons => 'All weapons';

  @override
  String get wishlistBrowseCatalog => 'See all skins';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Couldn\'t load the skin list. Refresh to try again.';

  @override
  String get wishlistCatalogEmptyTitle => 'No skins yet';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'In wishlist: $count';
  }

  @override
  String get wishlistCatalogSubtitle => 'Tap ♡ to add a skin to your wishlist';

  @override
  String get wishlistCatalogTitle => 'All skins';

  @override
  String get wishlistChooseWeapon => 'Choose weapon';

  @override
  String get wishlistClearFilters => 'Clear filters';

  @override
  String get wishlistEmpty =>
      'Your wishlist is empty. Tap ♡ on any skin to add it.';

  @override
  String get wishlistEmptyTitle => 'No skins yet';

  @override
  String wishlistEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String get wishlistExcludedRewards => 'Excludes reward skins';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return 'Filtered: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch => 'No matching skins. Clear filters to see more.';

  @override
  String get wishlistNoMatchTitle => 'No skins found';

  @override
  String get wishlistNotifBundleTitle => 'New bundle has a wishlisted skin';

  @override
  String get wishlistNotifDailyTitle => 'A wishlisted skin is here!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Your Night Market has a skin you want!';

  @override
  String get wishlistNotifPermissionMissing =>
      'The app doesn\'t have permission to send notifications.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wishlisted skins are on sale!',
      one: '$count wishlisted skin is on sale!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Wishlist notifications';

  @override
  String get wishlistNotifToggleSubtitle =>
      'For this account, even when the app is closed';

  @override
  String wishlistOfAccount(String riotId) {
    return '$riotId\'s wishlist';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wishlisted skins are on sale!',
      one: '$count wishlisted skin is on sale!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Tap a highlighted row to see the offer.';

  @override
  String get wishlistOpenSettings => 'Open settings';

  @override
  String get wishlistOwned => 'Owned';

  @override
  String get wishlistRemoveAction => 'Remove from wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Remove from wishlist';

  @override
  String wishlistRemoved(String name) {
    return 'Removed $name from wishlist';
  }

  @override
  String get wishlistSearchHint => 'Search skins…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'Name';

  @override
  String get wishlistSortPrice => 'Price';

  @override
  String get wishlistSortRarity => 'Rarity';

  @override
  String get wishlistSortWeapon => 'Weapon';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Wishlist total value';

  @override
  String get wishlistUndo => 'Undo';

  @override
  String get wishlistViewInStore => 'View in store';

  @override
  String get wishlistWeapon => 'Weapon';

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
      'yes': ', in wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', in wishlist',
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
      'gain': 'up',
      'other': 'down',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wins',
      one: '$wins win',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses losses',
      one: '$losses loss',
    );
    return 'Today $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wins',
      one: '$wins win',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses losses',
      one: '$losses loss',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws draws',
      one: ', $draws draw',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown matches with unknown result',
      one: ', $unknown match with unknown result',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody => 'Open Customize Home to show them again.';

  @override
  String get homeAllHiddenTitle => 'You\'ve hidden every card';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Level, XP needed per day and weekly missions.';

  @override
  String get homeCardCommunity => 'Community';

  @override
  String get homeCardCommunityDesc =>
      'Find teammates at your rank and the skins the community loves most.';

  @override
  String get homeCardFriends => 'Friends playing';

  @override
  String get homeCardFriendsDesc => 'Friends who are in a match or in queue.';

  @override
  String homeCardHidden(String name) {
    return 'Hid \"$name\"';
  }

  @override
  String get homeCardLive => 'Current match';

  @override
  String get homeCardLiveDesc =>
      'Shown while you\'re in queue, in agent select or in a match.';

  @override
  String get homeCardOtherAccounts => 'Other accounts';

  @override
  String get homeCardOtherAccountsDesc =>
      'Status and wishlist of your other accounts.';

  @override
  String get homeCardRank => 'Rank & form';

  @override
  String get homeCardRankDesc =>
      'Rank, today\'s RR, streaks and matches to rank up.';

  @override
  String get homeCardServerStatus => 'Server status';

  @override
  String get homeCardServerStatusDesc =>
      'Only shown during maintenance or incidents.';

  @override
  String get homeCardStore => 'Today\'s store';

  @override
  String get homeCardStoreDesc => 'Daily skins, wishlist and Night Market.';

  @override
  String get homeCustomize => 'Customize Home';

  @override
  String get homeCustomizeHint => 'Drag to reorder. Turn off to hide a card.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Jumped to $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Turn on';

  @override
  String get homeFriendsConsentBody =>
      'To see which friends are playing, ValHub connects to Riot chat for the current account each time you open Home. Your friends will see you as online. You can turn this off in Customize Home.';

  @override
  String get homeFriendsConsentDecline => 'No, hide card';

  @override
  String get homeFriendsConsentTitle => 'See which friends are playing?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n friends playing',
      one: '$n friend playing',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'See all';

  @override
  String get homeHideCard => 'Hide this card';

  @override
  String homeLeaderboard(String pos) {
    return '#$pos on the leaderboard';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return '$time left';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Need $n players',
      one: 'Need $n player',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Find teammates at your rank';

  @override
  String get homeLiveAllyLabel => 'Your team';

  @override
  String get homeLiveEnemyLabel => 'Enemy team';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'In queue, waiting $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Your team $ally, enemy team $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '$n-match Competitive losing streak';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n matches to reach $rank',
      one: '≈ $n match to reach $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Options for $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Sign in again to update the store, rank and Battle Pass for $riotId. You can still view the version saved on your device.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return '$time left';
  }

  @override
  String get homeNightMarketNew => 'New';

  @override
  String get homeNightMarketTitle => 'Night Market';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n offers waiting for you to flip',
      one: '$n offer waiting for you to flip',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'No Competitive matches today';

  @override
  String get homeOpenLfg => 'See all LFG posts';

  @override
  String get homeOpenRanking => 'See skin rankings';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Other accounts ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n accounts',
      one: '+$n account',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Wishlisted skin available';

  @override
  String homePreviousAct(String rank) {
    return 'Previous act: $rank';
  }

  @override
  String get homeQuietBody => 'Pull down to refresh.';

  @override
  String get homeQuietTitle => 'Nothing new yet';

  @override
  String homeRankToNext(int rr) {
    return '$rr RR to rank up';
  }

  @override
  String get homeResetLayout => 'Restore default';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Today $value';
  }

  @override
  String get homeStatusDetails => 'Details';

  @override
  String homeStatusIncident(String region) {
    return 'Server incident · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Under maintenance · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Maintenance coming up · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n notices',
      one: '+$n notice',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Refreshing…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Refreshes in $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Total $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Wallet $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
    );
    return 'Wallet $vp · enough for up to $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Wishlisted skin in store!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n wishlisted skins on sale',
      one: '$n wishlisted skin on sale',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get homeTrendingTitle => 'Most loved skins worldwide';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n likes',
      one: '$n like',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Undo';

  @override
  String homeWinStreak(int n) {
    return '$n-match Competitive win streak';
  }

  @override
  String get homeStoreOutdated =>
      'The store has refreshed. ValHub couldn\'t load the new one yet.';

  @override
  String get homeOfflineTitle => 'You\'re offline';

  @override
  String get homeOfflineBody =>
      'Showing what\'s saved on this device. ValHub updates everything once you\'re back online.';

  @override
  String get homeCardOffline => 'Shows up once you\'re online.';

  @override
  String get communityErrorConsent =>
      'Agree to share your Riot ID with Community to continue.';

  @override
  String get communityErrorForbidden =>
      'You can\'t do this yet. Check the Community Guidelines or contact ValHub.';

  @override
  String get communityErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get communityErrorImageTooLarge =>
      'Image too large (max 2 MB). Choose another one.';

  @override
  String get communityErrorImageType => 'Choose a JPEG, PNG or WebP image.';

  @override
  String get communityErrorInvalid =>
      'Your content wasn\'t accepted. Check it and try again.';

  @override
  String get communityErrorNetwork =>
      'Couldn\'t connect to ValHub Community. Check your connection and try again.';

  @override
  String get communityErrorNotFound => 'This content no longer exists.';

  @override
  String get communityErrorPickImage =>
      'Couldn\'t open your photo library. Try again.';

  @override
  String get communityErrorRateLimited =>
      'Community is getting too many requests. Try again in a few minutes.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Community is getting too many requests. Try again in $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot couldn\'t verify your account. Sign in to your Riot account again and try again.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot is having issues. Try again in a few minutes.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot is having issues. Try again in $duration.';
  }

  @override
  String get communityErrorServer =>
      'ValHub Community is having issues. Try again in a few minutes.';

  @override
  String get communityErrorStorageFull =>
      'Community photo storage is full. You can still post, but can\'t attach photos right now. Try again later.';

  @override
  String get communityErrorTimeout =>
      'ValHub Community is taking too long to respond. Try again.';

  @override
  String get communityErrorTitle => 'Couldn\'t finish';

  @override
  String get communityErrorUnauthorized =>
      'Your Community connection has expired. Try again.';

  @override
  String get communityErrorImageQuota =>
      'You\'ve used up your image storage. Delete some posts with images and try again.';

  @override
  String get smokePlain => 'Codegen check';

  @override
  String smokeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items',
      one: '$n item',
    );
    return '$_temp0';
  }
}
