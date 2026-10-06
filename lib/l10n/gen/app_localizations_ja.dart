// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get commonListSeparator => '、 ';

  @override
  String get commonPriceSourceLabel => '価格表の出典を見る';

  @override
  String get commonErrorApi => 'Riotで問題が発生しています。しばらくしてからもう一度お試しください。';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonBack => '戻る';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClearFilters => 'フィルター解除';

  @override
  String get commonClearSearch => '検索をクリア';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonCopied => 'コピーしました';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonDaily => '毎日';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n日';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n日前';
  }

  @override
  String get commonDelete => '削除';

  @override
  String get commonDone => '完了';

  @override
  String get commonEmptyGeneric => 'まだ何もありません。';

  @override
  String get commonErrorContentUnavailable =>
      'スキン、エージェント、マップの情報を読み込めませんでした。ネットワークを確認してもう一度お試しください。';

  @override
  String get commonErrorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get commonErrorMaintenance => 'VALORANTのサーバーはメンテナンス中です。後でもう一度お越しください。';

  @override
  String get commonErrorNeedsLogin => 'Riotのログイン期限が切れました。続けるには再度ログインしてください。';

  @override
  String get commonErrorNeedsLoginTitle => '再ログインが必要です';

  @override
  String get commonErrorNetwork =>
      'ネットワークに接続できません。Wi-Fiまたはモバイルデータを確認してもう一度お試しください。';

  @override
  String get commonErrorNoAccount => 'まだアカウントにログインしていません。';

  @override
  String get commonErrorNotFound => 'このコンテンツが見つかりません。';

  @override
  String get commonErrorTimeout => 'Riotの応答に時間がかかっています。接続を確認してもう一度お試しください。';

  @override
  String get commonErrorTransient => 'Riotが混み合っています。しばらくしてからもう一度お試しください。';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riotが混み合っています。$duration後にもう一度お試しください。';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Riotの地域を特定できませんでした。設定で地域を選択してください。';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonFilter => 'フィルター';

  @override
  String get commonGoHome => 'ホームへ';

  @override
  String commonHours(int n) {
    return '$n時間';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n時間前';
  }

  @override
  String get commonIncidentTitle => 'サーバー障害';

  @override
  String get commonJustNow => 'たった今';

  @override
  String get commonLoadMore => 'さらに読み込む';

  @override
  String get commonLoading => '読み込み中…';

  @override
  String get commonMaintenanceTitle => 'サーバーメンテナンス';

  @override
  String commonMinutes(int n) {
    return '$n分';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n分前';
  }

  @override
  String get commonNoData => '表示するものがまだありません';

  @override
  String commonOfflineCached(String time) {
    return 'オフライン — 保存済みのデータを表示中（$time）。';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonOpenSettings => '設定を開く';

  @override
  String get commonPageNotFound => 'この画面が見つかりません。';

  @override
  String commonPriceBestPack(String vp, String price) {
    return '最もお得なパック：$vp = $price';
  }

  @override
  String get commonPriceEditOwn => '入力した価格を編集';

  @override
  String get commonPriceEnterOwn => 'VPパックの価格を入力';

  @override
  String get commonPriceEstimateBody =>
      'VP価格の横にある「≈ …」の金額は、最もお得なVPパックで換算した推定額です。ゲーム内ではVPで支払います。実際の金額は、購入時のパック、決済方法、税金、セールによって異なります。';

  @override
  String get commonPriceEstimateTitle => '推定換算価格';

  @override
  String get commonPriceEstimateTooltip => '推定価格 — タップで計算方法を表示';

  @override
  String get commonPriceHidden => '換算価格を非表示にしました。設定で再表示できます。';

  @override
  String get commonPriceHide => '換算価格を非表示';

  @override
  String get commonPriceOpenSource => '出典ページを開く';

  @override
  String get commonPriceOverrideBody =>
      'VPパック1つに実際に支払った金額を入力してください（ゲーム内ストアや領収書で確認できます）。ValHubはこの価格をもとにすべてのアイテムの換算価格を推定します。価格はこの端末にのみ保存されます。';

  @override
  String get commonPriceOverrideCurrency => '通貨コード';

  @override
  String get commonPriceOverrideCurrencyHint => '例：JPY、USD、EUR、VND';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return '推定例：$vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      '3文字の通貨コードを入力してください（例：JPY、USD）。';

  @override
  String get commonPriceOverrideInvalidNumber => '0より大きい数値を入力してください。';

  @override
  String get commonPriceOverridePrice => 'パック価格';

  @override
  String get commonPriceOverrideRemove => '入力した価格を削除';

  @override
  String get commonPriceOverrideRemoved => '入力した価格を削除しました。';

  @override
  String get commonPriceOverrideSave => '価格を保存';

  @override
  String get commonPriceOverrideSaved => 'VPパックの価格を保存しました。';

  @override
  String get commonPriceOverrideTitle => 'VPパックの価格';

  @override
  String get commonPriceOverrideVp => 'パックのVP数';

  @override
  String get commonPricePacksTitle => 'VPパック';

  @override
  String commonPriceSourceOfficial(String country) {
    return '$country地域のVPパック価格表に基づく';
  }

  @override
  String get commonPriceSourceUser => '入力したVPパック価格に基づく';

  @override
  String get commonPriceUnavailable =>
      'お住まいの地域の確認済み価格表はまだありません。購入したことのあるVPパックの価格を入力すると、推定換算価格が表示されます。';

  @override
  String commonPriceUpdated(String date) {
    return '価格表の更新：$date';
  }

  @override
  String get commonPullToRefresh => '引っ張って更新';

  @override
  String get commonRefresh => '更新';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonRiotDisclaimer =>
      'ValHubはRiot Gamesによって承認されたものではなく、Riot GamesまたはRiot Gamesのプロパティの制作・管理に正式に関与するいかなる者の見解や意見も反映していません。Riot Gamesおよび関連するすべてのプロパティは、Riot Games, Inc.の商標または登録商標です。';

  @override
  String get commonSave => '保存';

  @override
  String get commonSearch => '検索…';

  @override
  String commonSeconds(int n) {
    return '$n秒';
  }

  @override
  String get commonSeeAll => 'すべて表示';

  @override
  String get commonShare => '共有';

  @override
  String get commonSignInAgain => '再ログイン';

  @override
  String get commonSort => '並べ替え';

  @override
  String commonSortBy(String option) {
    return '並べ替え：$option';
  }

  @override
  String get commonSortName => '名前順（A–Z）';

  @override
  String get commonSortNewest => '新しい順';

  @override
  String get commonSortPriceHigh => '価格が高い順';

  @override
  String get commonSortPriceLow => '価格が安い順';

  @override
  String get commonSortRarity => 'レア度';

  @override
  String get commonSortWeapon => '武器';

  @override
  String get commonTabBattlePass => 'バトルパス';

  @override
  String get commonTabCollection => 'コレクション';

  @override
  String get commonTabCommunity => 'コミュニティ';

  @override
  String get commonTabHome => 'ホーム';

  @override
  String get commonTabProfile => 'プロフィール';

  @override
  String get commonTabSettings => '設定';

  @override
  String get commonTabStore => 'ストア';

  @override
  String get commonTagline => 'あなたのVALORANTパートナー';

  @override
  String get commonToday => '今日';

  @override
  String get commonTodayLower => '今日';

  @override
  String get commonTomorrow => '明日';

  @override
  String get commonUnknownItem => '名称不明のアイテム';

  @override
  String commonUpdatedAt(String time) {
    return '$timeに更新';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day $time';
  }

  @override
  String get commonWeekdaysItem0 => '月曜日';

  @override
  String get commonWeekdaysItem1 => '火曜日';

  @override
  String get commonWeekdaysItem2 => '水曜日';

  @override
  String get commonWeekdaysItem3 => '木曜日';

  @override
  String get commonWeekdaysItem4 => '金曜日';

  @override
  String get commonWeekdaysItem5 => '土曜日';

  @override
  String get commonWeekdaysItem6 => '日曜日';

  @override
  String get commonYesterday => '昨日';

  @override
  String get commonYesterdayTitle => '昨日';

  @override
  String get contentCategoryHeavy => 'ヘヴィー武器';

  @override
  String get contentCategoryMelee => '近接武器';

  @override
  String get contentCategoryRifle => 'アサルトライフル';

  @override
  String get contentCategoryShotgun => 'ショットガン';

  @override
  String get contentCategorySidearm => 'サイドアーム';

  @override
  String get contentCategorySmg => 'サブマシンガン';

  @override
  String get contentCategorySniper => 'スナイパーライフル';

  @override
  String get contentCurrencyAgentTokens => 'エージェントトークン';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'キングダムクレジット';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'レディアナイト';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'ヴァロラントポイント';

  @override
  String get contentDefaultSkin => 'デフォルト';

  @override
  String get contentItemAgent => 'エージェント';

  @override
  String get contentItemBuddy => 'ガンバディー';

  @override
  String get contentItemCard => 'プレイヤーカード';

  @override
  String get contentItemChroma => 'クロマ';

  @override
  String get contentItemContract => 'コントラクト';

  @override
  String get contentItemCurrency => '通貨';

  @override
  String get contentItemFlex => 'フレックス';

  @override
  String get contentItemLanguageEn => '英語';

  @override
  String get contentItemLanguageTitle => 'アイテム名';

  @override
  String get contentItemLanguageVi => 'ベトナム語';

  @override
  String get contentItemLevelBorder => 'レベルボーダー';

  @override
  String get contentItemSkin => 'スキン';

  @override
  String get contentItemSpray => 'スプレー';

  @override
  String get contentItemTitle => 'プレイヤータイトル';

  @override
  String contentLevel(int n) {
    return 'レベル$n';
  }

  @override
  String get contentLevelBase => 'ベース';

  @override
  String get contentLevelItemLabelsVFX => 'ビジュアルエフェクト';

  @override
  String get contentLevelItemLabelsAnimation => 'アニメーション';

  @override
  String get contentLevelItemLabelsFinisher => 'フィニッシャー';

  @override
  String get contentLevelItemLabelsKillCounter => 'キルカウンター';

  @override
  String get contentLevelItemLabelsSoundEffects => 'サウンドエフェクト';

  @override
  String get contentLevelItemLabelsTransformation => 'トランスフォーム';

  @override
  String get contentLevelItemLabelsKillBanner => 'キルバナー';

  @override
  String get contentLevelItemLabelsKillEffect => 'キルエフェクト';

  @override
  String get contentLevelItemLabelsInspectAndKill => 'インスペクト＆キルエフェクト';

  @override
  String get contentLevelItemLabelsVoiceover => 'ボイスオーバー';

  @override
  String get contentLevelItemLabelsSongShuffle => '曲のシャッフル';

  @override
  String get contentLevelItemLabelsRandomizer => 'ランダマイザー';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap => '攻守で切り替え';

  @override
  String get contentLevelItemLabelsTopFrag => 'トップフラグエフェクト';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor => '心拍＆マップセンサー';

  @override
  String get contentLevelItemLabelsFishAnimation => '魚のアニメーション';

  @override
  String get contentLimitedEdition => 'リミテッドエディション';

  @override
  String get contentNoSpray => 'なし';

  @override
  String get contentNoTitle => 'タイトルなし';

  @override
  String get contentNotForSale => '非売品';

  @override
  String get contentQueueNamesCompetitive => 'コンペティティブ';

  @override
  String get contentQueueNamesUnrated => 'アンレート';

  @override
  String get contentQueueNamesSwiftplay => 'スイフトプレイ';

  @override
  String get contentQueueNamesSpikerush => 'スパイクラッシュ';

  @override
  String get contentQueueNamesDeathmatch => 'デスマッチ';

  @override
  String get contentQueueNamesHurm => 'チームデスマッチ';

  @override
  String get contentQueueNamesGgteam => 'エスカレーション';

  @override
  String get contentQueueNamesOnefa => 'レプリケーション';

  @override
  String get contentQueueNamesPremier => 'プレミア';

  @override
  String get contentQueueNamesCustom => 'カスタムゲーム';

  @override
  String get contentQueueNames => 'カスタムゲーム';

  @override
  String get contentQueueNamesDodgeball => 'ノックアウト';

  @override
  String get contentQueueNamesFortcollins => 'リテイク';

  @override
  String get contentQueueNamesSkirmish2v2 => 'スカーミッシュ: 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => 'スカーミッシュ: Ascension 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => 'スカーミッシュ: Ascension 2v2';

  @override
  String get contentQueueNamesValaram => 'オールランダム ワンサイト';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'スノーボールファイト';

  @override
  String get contentQueueNamesNewmap => 'サミット';

  @override
  String get contentQueueShortNamesCompetitive => 'コンペ';

  @override
  String get contentQueueShortNamesValaram => 'ARワンサイト';

  @override
  String get contentRewardSourceAgent => 'エージェントコントラクト';

  @override
  String get contentRewardSourceBattlePass => 'バトルパス報酬';

  @override
  String get contentRewardSourceEvent => 'イベントパス';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'デュエリスト';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'イニシエーター';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'コントローラー';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'センチネル';

  @override
  String get contentTierDeluxe => 'デラックス';

  @override
  String get contentTierExclusive => 'エクスクルーシブ';

  @override
  String contentTierFull(String shortName) {
    return '$shortNameエディション';
  }

  @override
  String get contentTierPremium => 'プレミアム';

  @override
  String get contentTierSelect => 'セレクト';

  @override
  String get contentTierUltra => 'ウルトラ';

  @override
  String get contentUnranked => 'ランクなし';

  @override
  String get accountRegionUnknown => 'サーバー不明';

  @override
  String accountRiotCountry(String country) {
    return 'Riotアカウントの国：$country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riotアカウントの国：不明';

  @override
  String accountAccountCount(int count, int max) {
    return 'アカウント $count/$max';
  }

  @override
  String accountAccountsHeader(int count, int max) {
    return 'アカウント（$count/$max）';
  }

  @override
  String get accountActive => '使用中';

  @override
  String accountAddAccount(int count, int max) {
    return 'アカウントを追加（$count/$max）';
  }

  @override
  String get accountClearLocalData => 'ローカルデータを削除';

  @override
  String get accountClearLocalDataConfirm =>
      'この端末に保存されている履歴、ロードアウト、ログアウト済みアカウントのデータを削除しますか？';

  @override
  String get accountClearRrHistory => 'RR履歴を削除';

  @override
  String get accountClearRrHistoryConfirm => 'この端末から選択中のアカウントのRR履歴を削除しますか？';

  @override
  String get accountCopyPassword => 'パスワードをコピー';

  @override
  String get accountCopyUsername => 'ユーザー名をコピー';

  @override
  String get accountDeleteLoginNote => '情報を削除';

  @override
  String get accountDeleteLoginNoteConfirm => 'このアカウントの保存済みユーザー名とパスワードを削除しますか？';

  @override
  String get accountHidePassword => 'パスワードを隠す';

  @override
  String get accountKeepLocalData => 'ローカルデータを残す';

  @override
  String get accountKeepLocalDataHint => 'この端末のウィッシュリスト、ロードアウト、履歴を残します';

  @override
  String accountLevelShort(int level) {
    return 'Lv.$level';
  }

  @override
  String get accountLinkAccountMissing =>
      '通知のアカウントはログアウトされています。再度ログインしてから通知を開いてください。';

  @override
  String get accountLocalDataCleared => 'ローカルデータを削除しました';

  @override
  String get accountLoginNote => 'ログイン情報';

  @override
  String get accountLoginNoteDeleted => 'ログイン情報を削除しました';

  @override
  String get accountLoginNoteEmpty => 'ログイン情報は保存されていません';

  @override
  String get accountLoginNoteHint =>
      'この端末にのみ安全にロックして保存されます。再ログイン時の確認や自動入力に使えます。';

  @override
  String get accountLoginNoteLocked => 'ログイン情報のロックを解除';

  @override
  String get accountLoginNotePassword => 'パスワード';

  @override
  String get accountLoginNoteSaved => 'ログイン情報を保存しました';

  @override
  String get accountLoginNoteUsername => 'Riotユーザー名';

  @override
  String get accountManageHint => 'アカウントの削除やログイン情報の編集は設定から行えます。';

  @override
  String accountMaxAccounts(int max) {
    return 'アカウントの上限（$max件）に達しました。';
  }

  @override
  String get accountNeedsLogin => '再ログインが必要です';

  @override
  String accountOnlineCount(int count) {
    return '$count人がオンライン';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => '保存済みアカウントを入力';

  @override
  String get accountQuickFillDone => '入力しました。「サインイン」をタップしてください。';

  @override
  String get accountQuickFillNotReady =>
      'ログインページの読み込みが完了していません。少し待ってからもう一度お試しください。';

  @override
  String get accountQuickFillSubtitle => 'Riotのログインページに入力するアカウントを選択';

  @override
  String get accountQuickFillTitle => '保存済みアカウントを入力';

  @override
  String get accountRegionAp => 'アジア太平洋';

  @override
  String get accountRegionBr => 'ブラジル';

  @override
  String get accountRegionEu => 'ヨーロッパ';

  @override
  String get accountRegionKr => '韓国';

  @override
  String get accountRegionLatam => 'ラテンアメリカ';

  @override
  String get accountRegionNa => '北米';

  @override
  String get accountRemoveAccount => 'アカウントを削除';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'この端末から$accountを削除しますか？保存済みデータは残すこともできます。';
  }

  @override
  String get accountRrHistoryCleared => 'RR履歴を削除しました';

  @override
  String get accountShowPassword => 'パスワードを表示';

  @override
  String get accountSignOutAll => 'すべてのアカウントからログアウト';

  @override
  String get accountSignOutAllConfirm =>
      'ログアウトして、この端末からすべてのアカウントを削除しますか？保存済みデータは残すこともできます。';

  @override
  String get accountStatusAgentSelect => 'エージェント選択中';

  @override
  String get accountStatusInMatch => '試合中';

  @override
  String get accountStatusOffline => 'オフライン';

  @override
  String get accountStatusOnline => 'オンライン';

  @override
  String get accountStatusUnknown => '状態不明';

  @override
  String get accountSwitchFailed => 'アカウントを切り替えられませんでした。もう一度お試しください。';

  @override
  String accountSwitchTo(String account) {
    return '$accountに切り替え';
  }

  @override
  String get accountSwitcherSubtitle => 'タップしてアカウントを切り替え';

  @override
  String get accountSwitcherTitle => 'アカウント';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'アカウント（$count/$max）';
  }

  @override
  String get accountUnknownPlayer => 'プレイヤー';

  @override
  String get accountUnlockLoginNote => '認証してRiotのログイン情報を表示';

  @override
  String get authAccountAlreadyAdded => 'このアカウントは追加済みです';

  @override
  String get authAddAsNew => '新しいアカウントとして追加';

  @override
  String get authDifferentAccountBody =>
      '再ログインが必要なアカウントとは別のアカウントでログインしました。このアカウントを新しいアカウントとして追加しますか？';

  @override
  String get authDifferentAccountTitle => '別のアカウント';

  @override
  String get authLoadingAccount => 'アカウントを読み込み中…';

  @override
  String get authLoginCancelledByRiot => 'Riotがこのログインを拒否しました。もう一度お試しください。';

  @override
  String get authLoginFailed => 'ログインを完了できませんでした';

  @override
  String get authLoginFailedBody => 'Riotでログインを確認できませんでした。もう一度お試しください。';

  @override
  String get authLoginTitle => 'Riotにログイン';

  @override
  String get authMissingCookies => 'この端末ではログイン状態を保存できないため、期限が切れたら再度ログインが必要です。';

  @override
  String get authOfficialHost => '公式ページ · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'ブラウザでリンクを開きました。';

  @override
  String get authPageLoadFailed =>
      'Riotのログインページを読み込めませんでした。ネットワークを確認してもう一度お試しください。';

  @override
  String get authPreparing => 'ログインページを準備中…';

  @override
  String get authReloginDone => '再ログインしました';

  @override
  String get authRememberMeHint => '再ログインの手間を省くには「サインインしたままにする」をオンにしてください。';

  @override
  String get authSignInCta => 'Riotアカウントでログイン';

  @override
  String get authSignInNote =>
      'ログインはRiotの公式ページで行います。ValHubがパスワードを保存するのは、ログイン情報の保存を選んだ場合のみです。ログインデータと保存した情報はあなたの端末にのみ保存されます。';

  @override
  String get authSocialLoginHint =>
      'GoogleまたはFacebookでログインできない場合は、Riotのユーザー名を使用してください。';

  @override
  String get authStateMismatch => 'このログインは無効です。最初からログインし直してください。';

  @override
  String get notificationSessionExpiredBody =>
      'ウィッシュリストの通知を受け取り続けるには、再度ログインしてください。';

  @override
  String get notificationBackgroundTimingHint => '端末の省電力モードにより、通知が遅れることがあります。';

  @override
  String get notificationChannelAccountDescription =>
      'アカウントの再ログインが必要なときにお知らせします';

  @override
  String get notificationChannelAccountName => 'アカウント';

  @override
  String get notificationChannelBattlePassDescription =>
      'バトルパスの進行状況と終了日をお知らせします';

  @override
  String get notificationChannelBattlePassName => 'バトルパス';

  @override
  String get notificationChannelCommunityDescription =>
      'ValHubを開いたときにコミュニティのアクティビティをお知らせします';

  @override
  String get notificationChannelCommunityName => 'コミュニティ';

  @override
  String get notificationChannelLfgDescription =>
      'ValHubを開いたときにパーティーへの参加をお知らせします';

  @override
  String get notificationChannelLfgName => 'パーティー';

  @override
  String get notificationChannelNightMarketDescription => 'ナイトマーケットの開催をお知らせします';

  @override
  String get notificationChannelNightMarketName => 'ナイトマーケット';

  @override
  String get notificationChannelRankDescription => 'プロフィール更新時にランクの変動をお知らせします';

  @override
  String get notificationChannelRankName => 'ランク';

  @override
  String get notificationChannelStoreResetDescription => 'デイリーストアの更新をお知らせします';

  @override
  String get notificationChannelStoreResetName => 'ストア更新';

  @override
  String get notificationChannelWishlistDescription =>
      'ウィッシュリストのスキンがストアに登場したらお知らせします';

  @override
  String get notificationChannelWishlistName => 'ウィッシュリスト';

  @override
  String get notificationLfgJoinedTitle => 'パーティーにプレイヤーが参加しました';

  @override
  String get notificationLocalOnlyHint => 'ValHubがデータを更新したときに、この端末でのみ通知します';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return '$accountのオファー$cards枚を今すぐめくりましょう。';
  }

  @override
  String get notificationNightMarketOpenTitle => 'ナイトマーケット開催中！';

  @override
  String get notificationPassEndingBody =>
      'バトルパスの残りは約1日です。ValHubを開いて最新の進行状況を確認しましょう。';

  @override
  String get notificationPassEndingTitle => 'バトルパスがまもなく終了';

  @override
  String notificationPassProgressBody(int level) {
    return '現在のバトルパスでティア$levelに到達しました。';
  }

  @override
  String get notificationPassProgressTitle => 'バトルパスの進行状況';

  @override
  String get notificationPrivateAccount => 'あなたのアカウント';

  @override
  String notificationRankChangedBody(String rank) {
    return '現在のランク：$rank。Riotからデータが更新されました。';
  }

  @override
  String get notificationRankChangedTitle => 'ランクが変動しました';

  @override
  String get notificationResetTimingUnknown => 'ストアを開くと、この端末での更新時刻が反映されます。';

  @override
  String get notificationSessionExpiredTitle => '再ログインが必要です';

  @override
  String get notificationStoreResetBody => 'ストアに新しいスキンが並んでいます。';

  @override
  String get competitiveDivisionIron => 'アイアン';

  @override
  String get competitiveDivisionBronze => 'ブロンズ';

  @override
  String get competitiveDivisionSilver => 'シルバー';

  @override
  String get competitiveDivisionGold => 'ゴールド';

  @override
  String get competitiveDivisionPlatinum => 'プラチナ';

  @override
  String get competitiveDivisionDiamond => 'ダイヤモンド';

  @override
  String get competitiveDivisionAscendant => 'アセンダント';

  @override
  String get competitiveDivisionImmortal => 'イモータル';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'レディアント';

  @override
  String get competitiveRankUnknown => 'ランク不明';

  @override
  String get competitiveAttack => 'アタッカー';

  @override
  String get competitiveCannotEstimate => '推定できません';

  @override
  String get competitiveDefeat => '敗北';

  @override
  String get competitiveDefense => 'ディフェンダー';

  @override
  String get competitiveDraw => '引き分け';

  @override
  String get competitiveIncognitoPlayer => '匿名プレイヤー';

  @override
  String get competitiveMatchPending => 'Riotが試合データを処理中です…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return 'ランク決定戦 残り$n試合';
  }

  @override
  String get competitiveRoundDefuse => 'スパイク解除';

  @override
  String get competitiveRoundDetonate => 'スパイク爆発';

  @override
  String get competitiveRoundElimination => '全滅';

  @override
  String get competitiveRoundSurrendered => '降参';

  @override
  String get competitiveRoundTimeExpired => '時間切れ';

  @override
  String get competitiveUnknownPlayer => 'プレイヤー';

  @override
  String get competitiveVictory => '勝利';

  @override
  String economyAvailableNow(String place) {
    return '$placeに登場中！';
  }

  @override
  String get economyCollectionValue => 'コレクションの価値';

  @override
  String get economyExcludedRewards => '報酬スキンは含みません';

  @override
  String economyPlaceBundle(String name) {
    return 'バンドル「$name」';
  }

  @override
  String get economyPlaceBundleGeneric => 'バンドル';

  @override
  String get economyPlaceDaily => 'デイリーストア';

  @override
  String get economyPlaceNightMarket => 'ナイトマーケット';

  @override
  String get economyPriceEstimated => 'エディション別の推定価格';

  @override
  String get economyPriceFromOffers => 'Riotの価格表による価格';

  @override
  String get economyPriceFromStore => 'ストアで確認した価格';

  @override
  String get economyPriceFromTable => '定価';

  @override
  String get economyPriceUnknown => '価格不明';

  @override
  String get economyValueHasEstimates => '推定価格を含む（≈）';

  @override
  String get economyWishlistValue => 'ウィッシュリストの合計額';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'ロードアウト$n';
  }

  @override
  String get loadoutInvalidChange => 'この変更は現在のロードアウトに適用できません。';

  @override
  String get loadoutNotPersisted =>
      'Riotに変更が保存されなかったため、ロードアウトは変わっていません。もう一度お試しください。';

  @override
  String get loadoutSaveFailed => 'ロードアウトを保存できません';

  @override
  String get battlePassActEnded => 'このACTは終了しました';

  @override
  String battlePassActEndsIn(String time) {
    return 'ACT終了まで$time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return 'ACT終了まで$days日';
  }

  @override
  String get battlePassAllMissionsDone => 'すべてのミッションを完了しました';

  @override
  String get battlePassAllWeeklyDone => 'すべてのウィークリーミッションを完了しました';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return '獲得待ちのダブルボーナス：$n';
  }

  @override
  String battlePassChapter(int n) {
    return 'チャプター$n';
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
  String get battlePassCheckpoint => 'チェックポイント';

  @override
  String get battlePassCheckpointHint => 'ラウンドに勝利するとチェックポイントが進みます（デスマッチは対象外）。';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'チェックポイント$index：$charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => '各チェックポイント：+XP、+KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'チェックポイント $done/$total 達成';
  }

  @override
  String get battlePassCurrentChapter => '現在';

  @override
  String get battlePassDailyAllDone => '今日のチェックポイントをすべて達成しました';

  @override
  String get battlePassDailyCaption => 'デイリー報酬';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'デイリー報酬 · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      '前日のチェックポイントは期限切れです。ゲームを起動するか、ここで更新してください。';

  @override
  String get battlePassDailyMissions => 'デイリーミッション';

  @override
  String get battlePassDailyNotReady =>
      '今日のチェックポイントはまだ準備できていません。ゲームを起動するか、ここで更新してください。';

  @override
  String get battlePassDailyPlayToStart =>
      '今日のチェックポイントはまだ準備できていません。ゲームを起動して新しい日を始めましょう。';

  @override
  String battlePassDaysLeft(int days) {
    return '残り$days日';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return '終了：$wall';
  }

  @override
  String get battlePassEpilogue => 'エピローグ';

  @override
  String get battlePassEstimateNote => '1試合あたり約4,000 XPで推定（ミッションは含みません）。';

  @override
  String battlePassEventEndsIn(String time) {
    return '終了まで$time';
  }

  @override
  String get battlePassEventPass => 'イベントパス';

  @override
  String get battlePassFilterAll => 'すべて';

  @override
  String get battlePassFilterLocked => 'ロック中';

  @override
  String get battlePassFilterUnlocked => 'アンロック済み';

  @override
  String get battlePassFree => '無料';

  @override
  String get battlePassFreeTrack => '無料報酬';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'ティア $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'ティア$n';
  }

  @override
  String battlePassMatchesEstimate(String n, String queue) {
    return '≈ $queue $n試合';
  }

  @override
  String get battlePassMissionDone => '完了';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total 完了';
  }

  @override
  String get battlePassMissionsProgressLabel => 'ウィークリーミッションの進行状況';

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return '新しいミッション：$wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return '新しいミッションまで$time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return '次のチェックポイント：$charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'ティア$levelまで';
  }

  @override
  String get battlePassNextReward => '次';

  @override
  String get battlePassNoBattlePass => '現在のACTのバトルパス情報はまだありません。後でもう一度お試しください。';

  @override
  String get battlePassNoRewards => 'このバトルパスにはまだ報酬がありません。';

  @override
  String get battlePassNoRewardsInFilter => 'この項目に該当する報酬はありません。';

  @override
  String get battlePassNoRewardsTitle => '報酬はまだありません';

  @override
  String get battlePassNoWeeklyMissions => '現在ウィークリーミッションはありません。';

  @override
  String get battlePassPassComplete => 'バトルパス完了';

  @override
  String get battlePassPremium => 'プレミアム';

  @override
  String get battlePassPremiumHint =>
      'プレミアムを購入していないため、無料報酬のみ受け取れます。ゲーム内でプレミアムを購入すると、到達済みのティアがアンロックされます。';

  @override
  String get battlePassRenewButton => 'チェックポイントを更新';

  @override
  String get battlePassRenewDone => 'デイリーチェックポイントを更新しました。';

  @override
  String get battlePassRenewFailed => 'チェックポイントを更新できません。後でもう一度お試しください。';

  @override
  String battlePassResetsAtWall(String wall) {
    return '更新：$wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return '更新まで$time';
  }

  @override
  String get battlePassRewardLevelLabel => 'ティア';

  @override
  String get battlePassRewardLocked => 'ロック中';

  @override
  String get battlePassRewardNeedsPremium => 'プレミアムが必要';

  @override
  String get battlePassRewardStatusLabel => '状態';

  @override
  String get battlePassRewardTrackLabel => '報酬の種類';

  @override
  String get battlePassRewardTypeLabel => '種類';

  @override
  String get battlePassRewardUnlocked => 'アンロック済み';

  @override
  String get battlePassRewardsTitle => '報酬';

  @override
  String get battlePassShowAllRewards => 'すべて表示';

  @override
  String get battlePassTitle => 'バトルパス';

  @override
  String get battlePassTotalXpCaption => '合計XP';

  @override
  String get battlePassUnknownMission => '新しいミッション（説明なし）';

  @override
  String get battlePassUnknownReward => '報酬';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total アンロック済み';
  }

  @override
  String get battlePassUnratedFallback => 'アンレート';

  @override
  String get battlePassViewAllRewards => 'すべての報酬を見る';

  @override
  String get battlePassWeeklyMissions => 'ウィークリーミッション';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'ウィークリーミッション残り +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / 日';
  }

  @override
  String get battlePassXpPerDayCaption => '期限内に完了するための1日あたりの必要量';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return '残り$xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'ロードアウトを保存できません。$detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': '所持しているすべてのスキン（ストア価格で価値を計算）',
      'buddy': '所持しているガンバディーとその数',
      'spray': 'エクスプレッションホイールにセットできるスプレー',
      'card': 'アンロック済みのプレイヤーカード。タップして表示・装備',
      'title': '名前の下に表示できるプレイヤータイトル',
      'flex': '所持しているフレックス',
      'other': 'コレクションを見る',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'スロット$position';
  }

  @override
  String get collectionApplyPreset => '適用';

  @override
  String get collectionApplyPresetBody =>
      '現在のスキン、ガンバディー、エクスプレッションホイール、カード、タイトルがこのセットに置き換わります。';

  @override
  String collectionApplyPresetTitle(String name) {
    return '「$name」を適用しますか？';
  }

  @override
  String get collectionBannerTitlePrefix => 'タイトル： ';

  @override
  String get collectionBrowseBuddies => 'ガンバディー';

  @override
  String get collectionBrowseCards => 'プレイヤーカード';

  @override
  String get collectionBrowseEmpty => 'この項目のアイテムはまだありません。';

  @override
  String get collectionBrowseEmptyTitle => 'アイテムなし';

  @override
  String get collectionBrowseFlex => 'フレックス';

  @override
  String get collectionBrowseSkins => 'スキン';

  @override
  String get collectionBrowseSprays => 'スプレー';

  @override
  String get collectionBrowseTitle => 'コレクションを見る';

  @override
  String get collectionBrowseTitles => 'プレイヤータイトル';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return '残り $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return '$weapon用';
  }

  @override
  String get collectionBuddyPickerTitle => 'ガンバディーを選択';

  @override
  String get collectionBuddyRemoved => 'ガンバディーを外しました';

  @override
  String get collectionBuddySlot => 'ガンバディー';

  @override
  String get collectionBuddyUnavailable =>
      'このガンバディーは装備できませんでした。更新するか、別のガンバディーを選んでください。';

  @override
  String get collectionCachedLoadout =>
      '保存済みのロードアウトを表示中です。変更する前に引っ張って更新してください。';

  @override
  String collectionCardsCount(String n) {
    return '所持カード：$n';
  }

  @override
  String get collectionChangeBuddy => '変更';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'クロマ $owned/$total';
  }

  @override
  String get collectionClearFilters => 'フィルター解除';

  @override
  String get collectionClearSearch => '検索をクリア';

  @override
  String get collectionClearTiers => 'エディションの絞り込みを解除';

  @override
  String get collectionCollectionValue => 'コレクションの価値';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'デフォルト';

  @override
  String get collectionDeletePreset => '削除';

  @override
  String get collectionEmptySlot => '空き';

  @override
  String get collectionEquip => '装備';

  @override
  String get collectionEquipped => '装備中';

  @override
  String get collectionEquippedCard => '装備中のカード';

  @override
  String collectionEquippedCardLabel(String name) {
    return '装備中のカード：$name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$nameを装備しました';
  }

  @override
  String collectionEquippedLine(String skin) {
    return '装備中：$skin';
  }

  @override
  String get collectionExcludedRewards => '報酬スキンは含みません';

  @override
  String get collectionExpressionsHint => 'スロットをタップしてスプレーまたはフレックスを選択します。';

  @override
  String get collectionExpressionsSlots => 'ホイールのスロット';

  @override
  String get collectionExpressionsTitle => 'エクスプレッションホイール';

  @override
  String get collectionFilterTiers => 'エディション';

  @override
  String get collectionHideAccountLevel => 'アカウントレベルを非表示';

  @override
  String get collectionHideAccountLevelHint => '他のプレイヤーにアカウントレベルが表示されなくなります。';

  @override
  String get collectionIncognito => '匿名モード';

  @override
  String get collectionIncognitoHint => '試合中、パーティー外のプレイヤーにあなたの名前を表示しません。';

  @override
  String collectionItemsCount(String n) {
    return 'アイテム数：$n';
  }

  @override
  String get collectionLevelBorderAuto => 'レベルに合わせて自動';

  @override
  String get collectionLevelBorderEmpty => 'あなたのレベルで使えるレベルボーダーはまだありません。';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'レベル$levelから';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'アカウントレベル$level';
  }

  @override
  String get collectionLevelBorderTitle => 'レベルボーダーを選択';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'レベル $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'レベル$n · $type';
  }

  @override
  String get collectionLevels => 'レベル';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$totalレベル アンロック済み';
  }

  @override
  String get collectionLobbyBanner => 'ロビーの画像';

  @override
  String get collectionLocked => 'ロック中';

  @override
  String get collectionMeleeNoBuddy => '近接武器にはガンバディーを装備できません。';

  @override
  String get collectionMove => '移動';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddyは$fromに装備されています。$toに移動しますか？';
  }

  @override
  String get collectionMoveBuddyTitle => 'ガンバディーを移動しますか？';

  @override
  String get collectionNoBuddies => 'ガンバディーをまだ持っていません。';

  @override
  String get collectionNoBuddy => 'ガンバディーなし';

  @override
  String get collectionNoFlex => 'フレックスをまだ持っていません。';

  @override
  String get collectionNoResults => '一致する結果が見つかりません。';

  @override
  String get collectionNoResultsTitle => '見つかりません';

  @override
  String get collectionNoSkinsForWeapon => 'この武器のスキンをまだ持っていません。';

  @override
  String get collectionNoSprays => 'スプレーをまだ持っていません。';

  @override
  String get collectionNoTitle => 'タイトルなし';

  @override
  String get collectionOtherWeapons => 'その他';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '所持スキン$n個',
      zero: 'スキンなし',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(String n) {
    return '所持スキン：$n';
  }

  @override
  String get collectionPlayLevelVideo => 'このレベルの動画を見る';

  @override
  String get collectionPlayVideo => '動画を見る';

  @override
  String get collectionPlayerCardSubtitle => 'ロビー、スコアボード、敵をキルしたときに表示されます。';

  @override
  String get collectionPlayerCardTitle => 'プレイヤーカードを変更';

  @override
  String get collectionPlayerTitleSubtitle => 'ロビーと試合中にあなたの名前の下に表示されます。';

  @override
  String get collectionPlayerTitleTitle => 'プレイヤータイトルを変更';

  @override
  String get collectionPresetActions => 'オプション';

  @override
  String collectionPresetApplied(String name) {
    return '「$name」を適用しました';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nセット',
      zero: 'なし',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '「$name」を削除しました';
  }

  @override
  String get collectionPresetNameHint => '例：ランク上げ用';

  @override
  String get collectionPresetNameTitle => 'ロードアウト名';

  @override
  String collectionPresetSaved(String name) {
    return '「$name」を保存しました';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return '保存日：$date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return '所持していないアイテム$n個をスキップしました。';
  }

  @override
  String get collectionPresetsEmpty =>
      '現在の装備を保存しておくと、スキン、カード、エクスプレッションホイールのセットをすばやく切り替えられます。';

  @override
  String get collectionPresetsEmptyTitle => 'ロードアウトはまだありません';

  @override
  String get collectionPresetsFull => 'ロードアウトの上限（50件）に達しました。追加で保存するには削除してください。';

  @override
  String get collectionPresetsNote => 'ロードアウトはこの端末の、選択中のアカウントにのみ保存されます。';

  @override
  String get collectionPresetsTitle => '保存済みロードアウト';

  @override
  String get collectionPreview => 'プレビュー';

  @override
  String get collectionPreviewing => '表示中';

  @override
  String get collectionRemoveBuddy => 'ガンバディーを外す';

  @override
  String get collectionRenamePreset => '名前を変更';

  @override
  String get collectionRowCard => 'プレイヤーカード';

  @override
  String get collectionRowExpressions => 'エクスプレッションホイール';

  @override
  String get collectionRowLevelBorder => 'レベルボーダー';

  @override
  String get collectionRowPresets => '保存済みロードアウト';

  @override
  String get collectionRowTitle => 'プレイヤータイトル';

  @override
  String get collectionRowWeapons => '武器のロードアウト';

  @override
  String get collectionRowWishlist => 'ウィッシュリスト';

  @override
  String get collectionSaveFailed => 'ロードアウトを保存できません';

  @override
  String get collectionSavePreset => '現在のロードアウトを保存';

  @override
  String get collectionSaving => '保存中…';

  @override
  String get collectionSearchBuddies => 'ガンバディーを検索…';

  @override
  String get collectionSearchCards => 'プレイヤーカードを検索…';

  @override
  String get collectionSearchFlex => 'フレックスを検索…';

  @override
  String get collectionSearchItems => '検索…';

  @override
  String get collectionSearchSkins => 'スキンを検索…';

  @override
  String get collectionSearchSprays => 'スプレーを検索…';

  @override
  String get collectionSearchTitles => 'プレイヤータイトルを検索…';

  @override
  String get collectionSearchWeapons => '武器、スキン、ガンバディーを検索…';

  @override
  String get collectionSectionBrowse => 'コレクションを見る';

  @override
  String get collectionSectionIdentity => '他のプレイヤーへの表示';

  @override
  String get collectionSectionLoadout => 'ロードアウト';

  @override
  String get collectionSkinCustomizeTitle => 'スキンをカスタマイズ';

  @override
  String get collectionSkinNotFound => 'このスキンが見つかりません。';

  @override
  String get collectionSkinNotOwned => 'このスキンをまだ所持していません。';

  @override
  String get collectionSlotNamesItem0 => '上';

  @override
  String get collectionSlotNamesItem1 => '右';

  @override
  String get collectionSlotNamesItem2 => '下';

  @override
  String get collectionSlotNamesItem3 => '左';

  @override
  String get collectionSortLabel => '並べ替え';

  @override
  String get collectionSortName => '名前';

  @override
  String get collectionSortPrice => '価格';

  @override
  String get collectionSortRarity => 'レア度';

  @override
  String get collectionSortWeapon => '武器';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return '絞り込み中：スキン$count個 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return '絞り込み中：$count/$totalアイテム';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$countアイテム';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return 'スキン$count個 · $value';
  }

  @override
  String get collectionTabFlex => 'フレックス';

  @override
  String get collectionTabSprays => 'スプレー';

  @override
  String get collectionTapToChangeCard => 'タップしてカードを変更';

  @override
  String get collectionTitle => 'コレクション';

  @override
  String collectionTitlesCount(String n) {
    return '所持タイトル：$n';
  }

  @override
  String get collectionUndo => '元に戻す';

  @override
  String get collectionUnknownCard => '名称不明のカード';

  @override
  String get collectionValueAtStorePrices => 'ストア価格で計算';

  @override
  String get collectionValueHasEstimates => '推定価格を含む（≈）';

  @override
  String collectionValueRewardCount(int n) {
    return '報酬スキン$n個は含まれていません';
  }

  @override
  String get collectionValueSeeSkins => 'スキンを見る';

  @override
  String collectionValueSkinCount(int n) {
    return 'スキン$n個で計算';
  }

  @override
  String get collectionVariants => 'バリエーション';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$totalの武器にスキンを装備中';
  }

  @override
  String get collectionWeaponLoadoutTitle => '武器のロードアウト';

  @override
  String get collectionWeaponNotFound => 'この武器が見つかりません。';

  @override
  String get collectionWeaponSkinsTitle => 'スキンを選択';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'スキン$n個',
      zero: '空',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      '不適切な表現が含まれているため投稿できませんでした。内容を修正してもう一度お試しください。';

  @override
  String get communityModerationContentScam =>
      'コミュニティでは、アカウント売買、代行プレイの宣伝、電話番号の掲載は禁止されています。これらの内容を削除してもう一度お試しください。';

  @override
  String get communityModerationContentTooComplex =>
      'バラバラな文字が多すぎます。簡潔に書き直してもう一度お試しください。';

  @override
  String get communityModerationAccountBanned =>
      'このアカウントはコミュニティの利用を禁止されています。誤りだと思われる場合は、「情報と規約」からValHubにお問い合わせください。';

  @override
  String get communityModerationAccountRestricted =>
      'このアカウントは、投稿、コメント、チームメイト募集、投票が制限されています。後でもう一度お試しいただくか、「情報と規約」からValHubにお問い合わせください。';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'コンペティティブ',
      'unrated': 'アンレート',
      'swiftplay': 'スイフトプレイ',
      'spikerush': 'スパイクラッシュ',
      'deathmatch': 'デスマッチ',
      'teamdeathmatch': 'チームデスマッチ',
      'premier': 'プレミア',
      'custom': 'カスタムゲーム',
      'other': 'その他',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'アジア・太平洋',
      'na': '北米',
      'eu': 'ヨーロッパ',
      'kr': '韓国',
      'latam': 'ラテンアメリカ',
      'br': 'ブラジル',
      'other': 'サーバー不明',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'このランキングにはまだスキンがありません';

  @override
  String get communityRankingEmptyVotes => '選択中の範囲とフィルターに一致する「いいね」はまだありません。';

  @override
  String get communityRankingEmptyRatings => '選択中の範囲とフィルターに一致する星評価はまだありません。';

  @override
  String get communityRankingEmptyReviews => '選択中の範囲とフィルターに一致するレビューはまだありません。';

  @override
  String get communityRankingExplore => 'スキンを探して見る・評価する';

  @override
  String get communityRankingExploreHint =>
      'スキン名または武器名で検索します。ランキングにはコミュニティの実際の評価のみが表示されます。';

  @override
  String get communityRankingClear => '武器と期間の絞り込みを解除';

  @override
  String get communityRankingPeriod => '期間';

  @override
  String get communityRankingSort => 'ランキング基準';

  @override
  String get communityRankingWeapon => '武器';

  @override
  String get communityRankingNoSearch =>
      '一致するスキンが見つかりません。別の名前を試すか、武器の絞り込みを解除してください。';

  @override
  String get communityRankingCatalogUnavailable =>
      'スキン一覧を読み込めませんでした。パネルを閉じ、データの同期後にもう一度お試しください。';

  @override
  String get communityConsentExitAccount => '同意しない · このアカウントからログアウト';

  @override
  String get communityRankingGlobalAllTime => 'グローバル · 全期間';

  @override
  String get communityRankingCatalogTitle => 'すべてのスキン';

  @override
  String get communityReviewOwnershipRequired =>
      '評価するには、このスキンを所持している必要があります。コミュニティの評価やコメントは引き続き閲覧できます。';

  @override
  String get communityReviewOwnershipUnavailable =>
      'スキンの所持を確認できませんでした。コレクションを再読み込みするか、ネットワーク接続時にもう一度お試しください。';

  @override
  String get communityReviewLegacyOwnership => '以前の評価 · 所持未確認';

  @override
  String get communityReviewVerifiedOwner => '評価時に所持を確認済み';

  @override
  String get communitySkinDiscussionHint =>
      'コメントは誰でもできます。星評価とレビューはスキンの所持者のみ可能です。';

  @override
  String get communityAddPhotos => '写真を追加';

  @override
  String get communityAgentsPicked => '選択したエージェント';

  @override
  String get communityAllModes => 'すべて';

  @override
  String get communityAllWeapons => 'すべての武器';

  @override
  String get communityAnonymousBanner => '匿名で閲覧中';

  @override
  String get communityAnyLanguage => 'すべての言語';

  @override
  String get communityAnyRank => 'すべてのランク';

  @override
  String get communityAnyRole => 'すべてのロール';

  @override
  String get communityApply => '適用';

  @override
  String get communityAutoRefresh => '20秒ごとに自動更新';

  @override
  String get communityBackToMyCountry => '自分の国に戻る';

  @override
  String get communityBlockAuthor => 'この端末でブロック';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => '選択解除';

  @override
  String get communityCodeAuto =>
      '空欄の場合：募集を投稿するときに、ValHubがゲーム内のパーティーからコードを自動作成します。';

  @override
  String get communityCodeAutoFailed =>
      'パーティーコードを作成できませんでした。VALORANTを起動するか、コードを手動で入力してください。';

  @override
  String get communityCodeGenerated => '現在のパーティーからコードを作成しました。';

  @override
  String get communityCodeInvalid => 'コードは大文字の英字または数字6文字です。';

  @override
  String get communityCodeRequired => 'パーティーコードを入力するか作成してください。';

  @override
  String get communityComment => 'コメント';

  @override
  String get communityCommentHint => 'コメントを書く…';

  @override
  String communityComments(String n) {
    return 'コメント$n件';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'コメント · $n';
  }

  @override
  String get communityCommentsTitle => 'コメント';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '投稿$posts件 · $authors人';
  }

  @override
  String communityCommunityLfg(String n) {
    return 'チームメイト募集$n件';
  }

  @override
  String get communityCommunityVotes => 'コミュニティのお気に入り';

  @override
  String get communityComposerHint => '今日のVALORANTについて、何を考えていますか？';

  @override
  String get communityComposerTitle => '新しい投稿';

  @override
  String communityConsentAccount(String riotId) {
    return 'アカウント：$riotId';
  }

  @override
  String get communityConsentAgree => '同意して続ける';

  @override
  String get communityConsentGateAction => '参加する';

  @override
  String get communityConsentGuidelines => 'コミュニティガイドライン';

  @override
  String get communityConsentLater => '後で';

  @override
  String get communityConsentLocal =>
      'パスワードやその他のログインデータは、常にこの端末に保存されます。同意は設定からいつでも取り消せます。';

  @override
  String get communityConsentPrivacy => 'プライバシーポリシー';

  @override
  String get communityConsentPublic =>
      '他のプレイヤーに、あなたのRiot ID、プレイヤーカード、ランク、国が表示されます。';

  @override
  String get communityConsentTitle => 'プライバシーとValHubコミュニティ';

  @override
  String get communityConsentVerify =>
      'ValHubは、接続時のRiot ID確認と、評価を保存するときのスキン所持確認のために、Riotへのアクセス権をコミュニティサーバーに送信します。サーバーは必要なデータのみを読み取り、使用後すぐにアクセス権を破棄し、保存しません。';

  @override
  String get communityConsentWithdrawn =>
      '同意を取り消しました。アプリを引き続き利用するには、再度同意が必要です。';

  @override
  String get communityCountriesEmpty => '一致する国が見つかりません。';

  @override
  String get communityCountriesSearchHint => '国を検索…';

  @override
  String get communityCountriesTitle => '各国のコミュニティ';

  @override
  String get communityCountryNamesAE => 'アラブ首長国連邦';

  @override
  String get communityCountryNamesAL => 'アルバニア';

  @override
  String get communityCountryNamesAM => 'アルメニア';

  @override
  String get communityCountryNamesAR => 'アルゼンチン';

  @override
  String get communityCountryNamesAT => 'オーストリア';

  @override
  String get communityCountryNamesAU => 'オーストラリア';

  @override
  String get communityCountryNamesAZ => 'アゼルバイジャン';

  @override
  String get communityCountryNamesBA => 'ボスニア・ヘルツェゴビナ';

  @override
  String get communityCountryNamesBD => 'バングラデシュ';

  @override
  String get communityCountryNamesBE => 'ベルギー';

  @override
  String get communityCountryNamesBG => 'ブルガリア';

  @override
  String get communityCountryNamesBH => 'バーレーン';

  @override
  String get communityCountryNamesBN => 'ブルネイ';

  @override
  String get communityCountryNamesBO => 'ボリビア';

  @override
  String get communityCountryNamesBR => 'ブラジル';

  @override
  String get communityCountryNamesBY => 'ベラルーシ';

  @override
  String get communityCountryNamesCA => 'カナダ';

  @override
  String get communityCountryNamesCH => 'スイス';

  @override
  String get communityCountryNamesCL => 'チリ';

  @override
  String get communityCountryNamesCN => '中国';

  @override
  String get communityCountryNamesCO => 'コロンビア';

  @override
  String get communityCountryNamesCR => 'コスタリカ';

  @override
  String get communityCountryNamesCU => 'キューバ';

  @override
  String get communityCountryNamesCY => 'キプロス';

  @override
  String get communityCountryNamesCZ => 'チェコ';

  @override
  String get communityCountryNamesDE => 'ドイツ';

  @override
  String get communityCountryNamesDK => 'デンマーク';

  @override
  String get communityCountryNamesDO => 'ドミニカ共和国';

  @override
  String get communityCountryNamesDZ => 'アルジェリア';

  @override
  String get communityCountryNamesEC => 'エクアドル';

  @override
  String get communityCountryNamesEE => 'エストニア';

  @override
  String get communityCountryNamesEG => 'エジプト';

  @override
  String get communityCountryNamesES => 'スペイン';

  @override
  String get communityCountryNamesET => 'エチオピア';

  @override
  String get communityCountryNamesFI => 'フィンランド';

  @override
  String get communityCountryNamesFR => 'フランス';

  @override
  String get communityCountryNamesGB => 'イギリス';

  @override
  String get communityCountryNamesGE => 'ジョージア';

  @override
  String get communityCountryNamesGH => 'ガーナ';

  @override
  String get communityCountryNamesGR => 'ギリシャ';

  @override
  String get communityCountryNamesGT => 'グアテマラ';

  @override
  String get communityCountryNamesHK => '香港';

  @override
  String get communityCountryNamesHN => 'ホンジュラス';

  @override
  String get communityCountryNamesHR => 'クロアチア';

  @override
  String get communityCountryNamesHU => 'ハンガリー';

  @override
  String get communityCountryNamesID => 'インドネシア';

  @override
  String get communityCountryNamesIE => 'アイルランド';

  @override
  String get communityCountryNamesIL => 'イスラエル';

  @override
  String get communityCountryNamesIN => 'インド';

  @override
  String get communityCountryNamesIQ => 'イラク';

  @override
  String get communityCountryNamesIR => 'イラン';

  @override
  String get communityCountryNamesIS => 'アイスランド';

  @override
  String get communityCountryNamesIT => 'イタリア';

  @override
  String get communityCountryNamesJO => 'ヨルダン';

  @override
  String get communityCountryNamesJP => '日本';

  @override
  String get communityCountryNamesKE => 'ケニア';

  @override
  String get communityCountryNamesKH => 'カンボジア';

  @override
  String get communityCountryNamesKR => '韓国';

  @override
  String get communityCountryNamesKW => 'クウェート';

  @override
  String get communityCountryNamesKZ => 'カザフスタン';

  @override
  String get communityCountryNamesLA => 'ラオス';

  @override
  String get communityCountryNamesLB => 'レバノン';

  @override
  String get communityCountryNamesLK => 'スリランカ';

  @override
  String get communityCountryNamesLT => 'リトアニア';

  @override
  String get communityCountryNamesLU => 'ルクセンブルク';

  @override
  String get communityCountryNamesLV => 'ラトビア';

  @override
  String get communityCountryNamesLY => 'リビア';

  @override
  String get communityCountryNamesMA => 'モロッコ';

  @override
  String get communityCountryNamesMD => 'モルドバ';

  @override
  String get communityCountryNamesME => 'モンテネグロ';

  @override
  String get communityCountryNamesMK => '北マケドニア';

  @override
  String get communityCountryNamesMM => 'ミャンマー';

  @override
  String get communityCountryNamesMN => 'モンゴル';

  @override
  String get communityCountryNamesMO => 'マカオ';

  @override
  String get communityCountryNamesMT => 'マルタ';

  @override
  String get communityCountryNamesMX => 'メキシコ';

  @override
  String get communityCountryNamesMY => 'マレーシア';

  @override
  String get communityCountryNamesNG => 'ナイジェリア';

  @override
  String get communityCountryNamesNI => 'ニカラグア';

  @override
  String get communityCountryNamesNL => 'オランダ';

  @override
  String get communityCountryNamesNO => 'ノルウェー';

  @override
  String get communityCountryNamesNP => 'ネパール';

  @override
  String get communityCountryNamesNZ => 'ニュージーランド';

  @override
  String get communityCountryNamesOM => 'オマーン';

  @override
  String get communityCountryNamesPA => 'パナマ';

  @override
  String get communityCountryNamesPE => 'ペルー';

  @override
  String get communityCountryNamesPH => 'フィリピン';

  @override
  String get communityCountryNamesPK => 'パキスタン';

  @override
  String get communityCountryNamesPL => 'ポーランド';

  @override
  String get communityCountryNamesPR => 'プエルトリコ';

  @override
  String get communityCountryNamesPT => 'ポルトガル';

  @override
  String get communityCountryNamesPY => 'パラグアイ';

  @override
  String get communityCountryNamesQA => 'カタール';

  @override
  String get communityCountryNamesRO => 'ルーマニア';

  @override
  String get communityCountryNamesRS => 'セルビア';

  @override
  String get communityCountryNamesRU => 'ロシア';

  @override
  String get communityCountryNamesSA => 'サウジアラビア';

  @override
  String get communityCountryNamesSE => 'スウェーデン';

  @override
  String get communityCountryNamesSG => 'シンガポール';

  @override
  String get communityCountryNamesSI => 'スロベニア';

  @override
  String get communityCountryNamesSK => 'スロバキア';

  @override
  String get communityCountryNamesSV => 'エルサルバドル';

  @override
  String get communityCountryNamesTH => 'タイ';

  @override
  String get communityCountryNamesTL => '東ティモール';

  @override
  String get communityCountryNamesTN => 'チュニジア';

  @override
  String get communityCountryNamesTR => 'トルコ';

  @override
  String get communityCountryNamesTW => '台湾';

  @override
  String get communityCountryNamesUA => 'ウクライナ';

  @override
  String get communityCountryNamesUS => 'アメリカ合衆国';

  @override
  String get communityCountryNamesUY => 'ウルグアイ';

  @override
  String get communityCountryNamesUZ => 'ウズベキスタン';

  @override
  String get communityCountryNamesVE => 'ベネズエラ';

  @override
  String get communityCountryNamesVN => 'ベトナム';

  @override
  String get communityCountryNamesZA => '南アフリカ';

  @override
  String get communityCreateLfg => 'チームメイトを募集';

  @override
  String get communityCreateLfgShort => '募集する';

  @override
  String get communityDataDeleted => 'あなたのコミュニティデータを削除しました。';

  @override
  String communityDataFooter(String riotId) {
    return '使用中のアカウント（$riotId）に適用されます。ダウンロードするファイルには、パスワードやRiotのログインデータは含まれません。';
  }

  @override
  String get communityDataTitle => 'あなたのコミュニティデータ';

  @override
  String get communityDecrease => '減らす';

  @override
  String get communityDelete => '削除';

  @override
  String get communityDeleteComment => 'コメントを削除';

  @override
  String get communityDeleteCommentBody => 'このコメントは完全に削除されます。';

  @override
  String get communityDeleteCommentTitle => 'コメントを削除しますか？';

  @override
  String get communityDeleteDataConfirm => '完全に削除';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'ValHubコミュニティ上の$riotIdのすべての投稿、コメント、スキン評価、いいね、投票、チームメイト募集、写真が完全に削除され、復元できなくなります。匿名閲覧モードに戻り、再び参加するには改めて同意が必要です。\n\nRiotアカウントとゲーム内データには影響しません。コピーを残したい場合は、先にデータをダウンロードしてください。';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'コミュニティデータを削除しますか？';

  @override
  String get communityDeleteDataSubtitle => 'コミュニティに投稿したすべての内容を完全に削除します。';

  @override
  String get communityDeleteDataTitle => 'コミュニティデータを削除';

  @override
  String get communityDeletePost => '投稿を削除';

  @override
  String get communityDeletePostBody => '投稿とすべてのコメントが完全に削除されます。';

  @override
  String get communityDeletePostTitle => '投稿を削除しますか？';

  @override
  String get communityDeleteReview => '評価を削除';

  @override
  String get communityDeleteReviewBody => 'このスキンに対するあなたの点数とレビューが削除されます。';

  @override
  String get communityDeleteReviewTitle => '評価を削除しますか？';

  @override
  String get communityDeleted => '削除しました。';

  @override
  String get communityDiscard => '破棄';

  @override
  String get communityDiscardBody => '入力した内容は保存されません。';

  @override
  String get communityDiscardTitle => '投稿を破棄しますか？';

  @override
  String get communityDownload => 'ダウンロードして翻訳';

  @override
  String get communityDownloadingModels => '翻訳パックをダウンロード中…';

  @override
  String get communityEditReview => '編集';

  @override
  String get communityEdited => '編集済み';

  @override
  String get communityEmptyPost => '何か書くか、写真を追加してください。';

  @override
  String get communityExpired => '期限切れ';

  @override
  String communityExpiresIn(String t) {
    return '残り$t';
  }

  @override
  String get communityExportPreparing => '準備中…';

  @override
  String get communityExportSubject => 'ValHubコミュニティデータ';

  @override
  String get communityExportSubtitle =>
      'コミュニティに投稿したすべての内容のコピー：投稿、コメント、評価、いいね、投票、チームメイト募集。';

  @override
  String get communityExportTitle => 'データをダウンロード';

  @override
  String get communityExtend => '延長';

  @override
  String get communityExtended => '募集を30分延長しました。';

  @override
  String get communityFeedEmptyBody => 'ストアやナイトマーケット、あなたの名場面を最初にシェアしましょう！';

  @override
  String get communityFeedEmptyFilteredBody =>
      '一致する投稿がありません。言語を変更するか、フィルターを解除してください。';

  @override
  String get communityFeedEmptyGuestBody =>
      '新しい投稿はまだありません。後でもう一度確認するか、参加してシェアしましょう。';

  @override
  String get communityFeedEmptyScopeBody => '海外コミュニティの投稿を見るか、フィルターを変更してみてください。';

  @override
  String get communityFeedEmptyScopeTitle => 'この範囲の投稿はまだありません';

  @override
  String get communityFeedEmptyTitle => 'フィードはまだ空です';

  @override
  String get communityFilters => 'フィルター';

  @override
  String get communityGenerateCode => 'パーティーコードを作成';

  @override
  String get communityGeneratingCode => 'コードを作成中…';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Googleによる翻訳';

  @override
  String get communityHelpful => '参考になった';

  @override
  String communityHelpfulCount(String n) {
    return '参考になった · $n';
  }

  @override
  String get communityHiddenAuthors => '非表示・ブロックしたユーザー';

  @override
  String get communityHiddenAuthorsEmpty => '非表示・ブロックしたユーザーはいません';

  @override
  String get communityHiddenAuthorsHint =>
      'この端末のこのアカウントにのみ適用されます。相手のコンテンツは非表示になりますが、相手はあなたの公開コンテンツを引き続き閲覧できます。';

  @override
  String communityImageOf(int i, int n) {
    return '画像 $i/$n';
  }

  @override
  String get communityIncrease => '増やす';

  @override
  String get communityJoin => '参加';

  @override
  String get communityJoinCodeExpired => 'パーティーコードの期限が切れているか、無効になっています。';

  @override
  String communityJoinConfirmBody(String name) {
    return '$nameのパーティーに参加するため、VALORANTの現在のパーティーから抜けます。';
  }

  @override
  String get communityJoinConfirmTitle => 'このパーティーに参加しますか？';

  @override
  String get communityJoinGameNotRunning =>
      'PCまたはコンソールでVALORANTを起動してから、もう一度お試しください。';

  @override
  String get communityJoinInvalidCode => 'パーティーコードが無効になっているか、パーティーが満員です。';

  @override
  String get communityJoinParty => 'パーティーに参加';

  @override
  String get communityJoinPartyFull => 'このパーティーは満員です。';

  @override
  String get communityJoined => 'パーティーに参加しました！VALORANTを起動して一緒にプレイしましょう。';

  @override
  String get communityJoinedHint => 'パーティーに参加しました！VALORANTを起動して一緒にプレイしましょう。';

  @override
  String communityJoinsCount(String n) {
    return '参加リクエスト：$n人';
  }

  @override
  String get communityKeepEditing => '編集を続ける';

  @override
  String get communityKindNightMarket => 'ナイトマーケット';

  @override
  String get communityKindStore => '今日のストア';

  @override
  String get communityLanguage => '言語';

  @override
  String get communityLanguageFilter => 'コンテンツの言語';

  @override
  String get communityLanguageFilterHint =>
      '選択した言語で書かれたコンテンツのみ表示します。すべて表示するには空欄のままにしてください。';

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
    return '$n言語';
  }

  @override
  String get communityLfgEmptyBody =>
      '募集を投稿すれば、他のプレイヤーがワンタップであなたのパーティーに参加できます。';

  @override
  String get communityLfgEmptyTitle => 'まだ誰も募集していません';

  @override
  String get communityLfgExpiredRepost => '募集の期限が切れました。チームメイトを探すには新しく投稿してください。';

  @override
  String get communityLfgExpiryNote => '募集は30分後に自動で期限切れになります。';

  @override
  String get communityLfgGateBody =>
      '参加（Riot IDの確認は1回のみ）すると、同じサーバーのプレイヤーの募集を見たり、自分で募集を投稿したりできます。フィードとスキンランキングは引き続き閲覧できます。';

  @override
  String get communityLfgGateTitle => 'チームメイト募集はメンバー限定です';

  @override
  String communityLfgOtherShardNote(String region) {
    return '$regionサーバーを表示中です — パーティーに参加できるのは、あなたのアカウントと同じサーバーのプレイヤーのみです。';
  }

  @override
  String get communityLfgPosted => 'チームメイト募集を投稿しました！';

  @override
  String get communityLfgPreviewTitle => 'ランクの合うチームメイトを探す';

  @override
  String get communityLfgRemoved => '募集を取り下げました。';

  @override
  String get communityLfgSameShardNote => 'パーティーに参加できるのは同じサーバーのプレイヤーのみです。';

  @override
  String communityLfgSheetSubtitle(String region) {
    return '地域：$region · 募集は30分後に自動で期限切れになります。';
  }

  @override
  String get communityLike => 'いいね';

  @override
  String communityLikes(String n) {
    return 'いいね$n件';
  }

  @override
  String get communityLiveMembers => 'メンバー';

  @override
  String get communityLoadMoreFailed => '投稿を読み込めませんでした。もう一度お試しください。';

  @override
  String get communityMatchMyRank => '自分のランクに合う';

  @override
  String communityMaxPhotos(int max) {
    return '写真は最大$max枚です。';
  }

  @override
  String communityMemberJoined(String name) {
    return '$nameがパーティーに参加しました';
  }

  @override
  String get communityMemberJoinedBody => 'あなたのチームメイト募集に参加者が来ました。';

  @override
  String get communityMic => 'マイク必須';

  @override
  String get communityMicOn => 'マイクあり';

  @override
  String get communityMode => 'モード';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'その他のオプション';

  @override
  String get communityMuteAuthor => 'このユーザーを非表示';

  @override
  String get communityMyPost => 'あなたの募集';

  @override
  String get communityNewPost => '投稿する';

  @override
  String communityNightMarketOf(String date) {
    return '$dateのナイトマーケット';
  }

  @override
  String get communityNoAccountBody =>
      'Riotアカウントを追加すると、投稿、チームメイト募集、スキンへの投票ができます。';

  @override
  String get communityNoAccountTitle => 'ログインして参加';

  @override
  String get communityNoComments => 'コメントはまだありません。最初にコメントしてみましょう！';

  @override
  String get communityNoParty =>
      'パーティーが見つかりません。VALORANTを起動してもう一度お試しいただくか、コードを手動で入力してください。';

  @override
  String communityNoPartyWithReason(String reason) {
    return 'パーティーが見つかりません。VALORANTを起動してもう一度お試しいただくか、コードを手動で入力してください。\n$reason';
  }

  @override
  String get communityNoRatings => '評価はまだありません';

  @override
  String get communityNote => 'メモ';

  @override
  String get communityNoteHint => '例：コントローラー1人募集、マイクあり、エンジョイ勢';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name、$price';
  }

  @override
  String communityOffersTotal(String amount) {
    return '合計 $amount';
  }

  @override
  String get communityOpenReviews => '評価を見る';

  @override
  String get communityOutOfRange => 'ランク範囲外';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'パーティーコード';

  @override
  String get communityPartyCodeHint => '例：A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'パーティーコード：$code';
  }

  @override
  String get communityPartySize => '現在のパーティー人数';

  @override
  String get communityPartySizeFromGame => 'ゲーム内のパーティーから取得';

  @override
  String communityPartySizeValue(int n) {
    return '$n人';
  }

  @override
  String get communityPeriodAll => 'すべて';

  @override
  String get communityPeriodAllTime => '全期間';

  @override
  String get communityPeriodWeek => '今週';

  @override
  String communityPhotoCount(int n, int max) {
    return '写真 $n/$max';
  }

  @override
  String get communityPickRating => '星の数を選んでください。';

  @override
  String get communityPlayVideo => '動画を見る';

  @override
  String get communityPostLfg => '募集を投稿';

  @override
  String get communityPostNotFound => 'この投稿は削除されたか、非表示になっています。';

  @override
  String get communityPostTitle => '投稿';

  @override
  String get communityPosted => '投稿しました！';

  @override
  String get communityPrivacyNote =>
      'ValHubは、コミュニティ接続時にRiot IDを、評価時にスキンの所持を確認します。コミュニティにパスワードやRiotのログインデータが保存されることはありません。';

  @override
  String get communityPublish => '投稿';

  @override
  String get communityPublishing => '投稿中…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => '最低';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'ランク範囲';

  @override
  String get communityRankRangeInvalid => '最低ランクは最高ランク以下にしてください。';

  @override
  String communityRankSemantics(String n, String name) {
    return '$n位：$name';
  }

  @override
  String get communityRankTo => '最高';

  @override
  String get communityRateLimitedTitle => '少しお待ちください';

  @override
  String communityRatingCount(String n) {
    return '評価$n件';
  }

  @override
  String communityRatingSummary(String avg, String n) {
    return '$avg · 評価$n件';
  }

  @override
  String get communityRatingWordsItem0 => 'ひどい';

  @override
  String get communityRatingWordsItem1 => 'いまいち';

  @override
  String get communityRatingWordsItem2 => '普通';

  @override
  String get communityRatingWordsItem3 => '良い';

  @override
  String get communityRatingWordsItem4 => '最高';

  @override
  String get communityRefreshList => '更新';

  @override
  String get communityRegion => '地域';

  @override
  String get communityRemoveAttachment => '添付を削除';

  @override
  String get communityRemoveLfg => '募集を取り下げ';

  @override
  String get communityRemoveLfgBody => '他のプレイヤーにこの募集が表示されなくなります。';

  @override
  String get communityRemoveLfgTitle => 'チームメイト募集を取り下げますか？';

  @override
  String get communityRemovePhoto => '写真を削除';

  @override
  String get communityReport => '報告';

  @override
  String get communityReportConfirmBody =>
      '多くのユーザーから報告されたコンテンツは、コミュニティで非表示になります。';

  @override
  String get communityReportConfirmTitle => '報告を送信しますか？';

  @override
  String get communityReportPrompt => 'このコンテンツを報告する理由は何ですか？';

  @override
  String get communityReportReasonsSpam => 'スパムまたは宣伝';

  @override
  String get communityReportReasonsHarassment => '嫌がらせ・暴言';

  @override
  String get communityReportReasonsInappropriate => '不適切なコンテンツ';

  @override
  String get communityReportReasonsScam => '詐欺・アカウント売買';

  @override
  String get communityReportReasonsOther => 'その他の理由';

  @override
  String get communityReportTitle => 'コンテンツを報告';

  @override
  String get communityReported => 'ありがとうございます！報告を送信しました。';

  @override
  String get communityRetry => '再試行';

  @override
  String get communityReviewDeleted => '評価を削除しました。';

  @override
  String get communityReviewHint => 'このスキンの感想をシェア（任意）';

  @override
  String get communityReviewSaved => '評価を保存しました！';

  @override
  String get communityReviewTitle => 'スキンを評価';

  @override
  String get communityReviewsEmptyBody => '評価はまだありません — 最初の評価を書いてみましょう！';

  @override
  String get communityReviewsEmptyTitle => '評価はまだありません';

  @override
  String communityReviewsHeader(String n) {
    return '評価 · $n';
  }

  @override
  String get communityReviewsSection => '評価';

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riotで問題が発生しています';

  @override
  String get communityRoleFlex => 'どれでも可';

  @override
  String get communityRoles => '募集ロール';

  @override
  String get communitySaveReview => '評価を保存';

  @override
  String get communityScopeCountry => '自分の国';

  @override
  String get communityScopeGlobal => '海外';

  @override
  String get communityScopeRegion => '地域';

  @override
  String get communityScopeWorldwide => 'グローバル';

  @override
  String get communitySectionFeed => 'フィード';

  @override
  String get communitySectionLfg => '募集';

  @override
  String get communitySectionSkins => 'スキンランキング';

  @override
  String get communitySend => '送信';

  @override
  String get communitySendComment => 'コメントを送信';

  @override
  String get communityShareNightMarketHint => 'ナイトマーケットをみんなに自慢しよう';

  @override
  String communitySharePostTitle(String name) {
    return 'ValHubの$nameの投稿';
  }

  @override
  String get communityShareStore => 'コミュニティでシェア';

  @override
  String get communityShareStoreHint => '今日のストアをみんなに自慢しよう';

  @override
  String get communityShowOriginal => '原文を表示';

  @override
  String get communityShowTranslation => '翻訳を表示';

  @override
  String get communitySignInToReview => 'スキンを評価するにはRiotアカウントを追加してください。';

  @override
  String get communitySkinNotFound => 'このスキンが見つかりません。';

  @override
  String get communitySkinsEmptyBody => '一番好きなスキンにハートを付けて、ランキングに押し上げよう！';

  @override
  String get communitySkinsEmptyTitle => 'まだ投票はありません';

  @override
  String get communitySlots => '募集人数';

  @override
  String communitySlotsTooMany(int max) {
    return 'パーティーは最大5人です：空きは残り$max人です。';
  }

  @override
  String communitySlotsWanted(int n) {
    return '$n人募集';
  }

  @override
  String get communitySortHelpful => '参考になった順';

  @override
  String get communitySortNewest => '新しい順';

  @override
  String get communitySortRating => '評価が高い順';

  @override
  String get communitySortReviews => '評価が多い順';

  @override
  String get communitySortVotes => '人気順';

  @override
  String communityStarLabel(int n) {
    return '星$n';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '5つ星中$avg';
  }

  @override
  String get communityStatusFull => '満員';

  @override
  String get communityStatusInGame => '試合中';

  @override
  String get communityStatusOpen => '募集中';

  @override
  String communityStoreOf(String date) {
    return '$dateのストア';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => '星をタップしてこのスキンを評価';

  @override
  String get communityTitle => 'コミュニティ';

  @override
  String communityTooLong(int max) {
    return '最大$max文字です。';
  }

  @override
  String get communityTranslate => 'Googleで翻訳';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return '$fromから$toに翻訳するには、ValHubがGoogleから言語パック（約$size）をダウンロードする必要があります。ダウンロードは1回のみで、翻訳はすべて端末上で行われ、どのサーバーにも送信されません。';
  }

  @override
  String get communityTranslateDownloadTitle => '端末翻訳パックをダウンロードしますか？';

  @override
  String get communityTranslateFailed => '翻訳できませんでした。もう一度お試しください。';

  @override
  String get communityTranslateUnavailable => 'この端末は端末上での翻訳に対応していません。';

  @override
  String get communityTranslatedByGoogle => 'Googleによる自動翻訳';

  @override
  String get communityTranslating => '翻訳中…';

  @override
  String get communityTrendingTitle => '世界で人気のスキン';

  @override
  String get communityUnavailableBody =>
      'ValHubコミュニティに接続できませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get communityUnavailableTitle => 'コミュニティに接続できません';

  @override
  String get communityUnhideAuthor => '非表示 / ブロックを解除';

  @override
  String get communityUnknownPlayer => 'プレイヤー';

  @override
  String get communityUnlike => 'いいねを取り消す';

  @override
  String get communityUnvote => 'ハートを外す';

  @override
  String get communityUploading => '写真をアップロード中…';

  @override
  String get communityViewImage => '画像を見る';

  @override
  String get communityVote => 'このスキンにハートを付ける';

  @override
  String communityVotes(String n) {
    return 'いいね$n件';
  }

  @override
  String get communityWithdrawConfirm => '取り消す';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHubは$riotIdでのコミュニティ利用を停止します。この端末のコミュニティ接続は削除され、匿名閲覧モードに戻ります。\n\n投稿済みの投稿、コメント、評価、投票、チームメイト募集はコミュニティに残り、個別に削除するか「コミュニティデータを削除」を選択するまで、あなたのRiot IDが表示されたままになります。いつでも再参加できます。';
  }

  @override
  String get communityWithdrawConfirmTitle => '同意を取り消しますか？';

  @override
  String get communityWithdrawSubtitle =>
      'このアカウントでのコミュニティ利用を停止します。投稿済みの内容は残ります。';

  @override
  String get communityWithdrawTitle => '同意を取り消す';

  @override
  String get communityWriteFirstReview => '最初の評価を書く';

  @override
  String get communityWritePost => '投稿を書く';

  @override
  String get communityYou => 'あなた';

  @override
  String get communityYourCountry => 'あなたの国';

  @override
  String get communityYourReview => 'あなたの評価';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'あなた：$kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentNotOwned => 'このエージェントはまだ所持していません。';

  @override
  String get liveGameAgentSelect => 'エージェント選択中';

  @override
  String get liveGameAgentTaken => '味方がこのエージェントをロックインしています。';

  @override
  String get liveGameAnonymous => '匿名';

  @override
  String get liveGameAutoRefreshNote => '試合が見つかると自動で更新されます。';

  @override
  String get liveGameBuddy => 'ガンバディー';

  @override
  String get liveGameClose => '閉じる';

  @override
  String get liveGameCurrentGame => '現在の試合';

  @override
  String get liveGameEmptyTeam => 'プレイヤーがいません。';

  @override
  String get liveGameEnemyHiddenInAgentSelect => '敵チームは試合開始時に表示されます。';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return '敵チーム ロックイン $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'この試合のライブデータにはキル/デス/アシストが含まれていません。スコアボードは試合後にRiotがデータを公開すると表示されます。';

  @override
  String get liveGameFinalScoreboard => '最終スコアボード';

  @override
  String get liveGameFlex => 'フレックス';

  @override
  String get liveGameHoverLockHint => 'タップで仮選択、長押しでロックイン。';

  @override
  String get liveGameInLobby => 'ロビーにいます';

  @override
  String get liveGameInMatch => '試合中';

  @override
  String get liveGameInQueue => 'マッチング中';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'マッチング中 · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'レベル$n';
  }

  @override
  String get liveGameLiveScore => 'ライブスコア';

  @override
  String get liveGameLoadoutFromAgentSelect => 'エージェント選択時のロードアウト';

  @override
  String get liveGameLoadoutFromMatch => 'この試合のロードアウト';

  @override
  String get liveGameLobbyHint => '試合が見つかると、ValHubに全員の構成とランクが表示されます。';

  @override
  String get liveGameLockFailed => 'このエージェントをロックインできませんでした。更新してもう一度お試しください。';

  @override
  String liveGameLockedAgent(String agent) {
    return '$agentをロックインしました';
  }

  @override
  String get liveGameLockedTag => 'ロックイン済み';

  @override
  String get liveGameMatchPendingHint =>
      'ValHubが自動で再試行します。スコアボードは通常1分ほどで表示されます。';

  @override
  String get liveGameNoAgentYet => 'エージェント未選択';

  @override
  String get liveGameNoAgents => 'エージェント一覧を読み込めませんでした。更新してもう一度お試しください。';

  @override
  String get liveGameNoLoadout => 'このプレイヤーのロードアウト情報はありません。';

  @override
  String get liveGameNotInGame => '試合外';

  @override
  String get liveGameNotInGameHint =>
      'VALORANTを起動してマッチングを開始しましょう — エージェント選択画面に入ると、試合の詳細がここに自動で表示されます。';

  @override
  String get liveGameNotInGameTitle => '現在試合に参加していません';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return '$nameのロードアウトを見る';
  }

  @override
  String get liveGameOpenParty => 'パーティーとキューを開く';

  @override
  String get liveGameParty => 'パーティー';

  @override
  String liveGamePeak(String rank) {
    return '最高：$rank';
  }

  @override
  String get liveGamePlayerCard => 'プレイヤーカード';

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return '$nameのロードアウト';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'ロードアウト';

  @override
  String get liveGameQueueHint => 'アプリを開いたままにしてください — 試合が見つかるとすぐに詳細が表示されます。';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      '試合から抜けるとペナルティ（RRの減少、キュー制限）を受ける可能性があります。それでも抜けますか？';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'エージェント選択中に抜けるとペナルティ（RRの減少、キュー制限）を受ける可能性があります。それでも抜けますか？';

  @override
  String get liveGameQuitConfirmTitle => '試合から抜けますか？';

  @override
  String get liveGameQuitDone => '試合から抜けました。';

  @override
  String get liveGameQuitFailed => '試合から抜けられませんでした。';

  @override
  String get liveGameQuitMatch => '試合から抜ける';

  @override
  String get liveGameQuitMatchChanged =>
      '確認中に試合のフェーズが変わりました。まだ試合から抜けていません。もう一度お試しください。';

  @override
  String get liveGameRankUnavailable => 'ランク不明';

  @override
  String get liveGameRefresh => '更新';

  @override
  String liveGameRefreshIn(int seconds) {
    return '$seconds秒後に自動更新';
  }

  @override
  String get liveGameRefreshNow => '今すぐ更新';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSelectFailed => 'このエージェントを選択できませんでした。更新してもう一度お試しください。';

  @override
  String get liveGameSheetTitle => '試合の詳細';

  @override
  String get liveGameSprays => 'スプレー';

  @override
  String get liveGameStatusAgentSelect => 'エージェント選択中';

  @override
  String get liveGameStatusEnded => '終了';

  @override
  String get liveGameStatusInProgress => '進行中';

  @override
  String get liveGameStatusUnavailable => '試合の状態を更新できませんでした';

  @override
  String get liveGameTabAgents => 'エージェント';

  @override
  String get liveGameTabAllPlayers => 'プレイヤー';

  @override
  String get liveGameTabEnemyTeam => '敵チーム';

  @override
  String get liveGameTabYourTeam => '味方チーム';

  @override
  String liveGameTimeLeft(String t) {
    return '残り$t';
  }

  @override
  String get liveGameViewMatchDetails => '試合の詳細を見る';

  @override
  String get liveGameWeapons => '武器';

  @override
  String get liveGameYou => 'あなた';

  @override
  String liveGameYouHover(String agent) {
    return '$agentを選択中';
  }

  @override
  String liveGameYouLocked(String agent) {
    return '$agentをロックインしました';
  }

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws分',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – 結果不明$unknown試合',
      zero: '',
    );
    return '$wins勝 – $losses敗$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return '端末の時刻（$offset）';
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
      'yes': '（$weapon）',
      'other': '',
    });
    return '$killerが$victimをキル$_temp0（$time）';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30日間',
      'days7': '7日間',
      'other': '全期間',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'エージェント',
      'maps': 'マップ',
      'queues': 'モード',
      'sides': 'アタッカー / ディフェンダー',
      'trend': '傾向',
      'other': 'モード',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'すべてのモード';

  @override
  String get profileAbility => 'アビリティ';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n試合';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => '平均コンバットスコア';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return '今ACT：$games試合中$wins勝 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => '全プレイヤー';

  @override
  String get profileAlreadyReached => 'このランクにはすでに到達しています。';

  @override
  String get profileAtCurrentForm => '現在の調子の場合';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return '現在の調子の場合（1試合あたり $gain / $loss）';
  }

  @override
  String profileBestCase(int n) {
    return '最短：$n連勝';
  }

  @override
  String get profileByWinRateTitle => '勝率別';

  @override
  String get profileChooseMap => 'マップで絞り込み';

  @override
  String get profileClearMap => 'マップの絞り込みを解除';

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
  String get profileCopyRiotId => 'Riot IDをコピー';

  @override
  String get profileCurrentRank => '現在';

  @override
  String get profileDailyRrEmpty => 'この端末に保存されたコンペティティブの試合はまだありません。';

  @override
  String get profileDailyRrFootnote =>
      'RR履歴はあなたの端末に直接保存されます。Riotから取得できなくなった試合も含まれます。';

  @override
  String get profileDailyRrTitle => '日別RR';

  @override
  String profileDayBoundary(String zone) {
    return '日付の区切り：$zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return 'プレイ日数：$n日';
  }

  @override
  String get profileDuration => '試合時間';

  @override
  String profileDurationOf(String d) {
    return '試合時間 $d';
  }

  @override
  String get profileEndOfHistory => 'すべての試合を表示しました';

  @override
  String get profileEnemyTeam => '敵チーム';

  @override
  String get profileFallDamage => '落下ダメージ';

  @override
  String get profileFilterAll => 'すべて';

  @override
  String get profileFilterMap => 'マップ';

  @override
  String get profileFirstBloods => 'ファーストブラッド';

  @override
  String get profileFirstDeaths => 'ファーストデス';

  @override
  String get profileFirstHalf => '前半';

  @override
  String get profileFormNoRoundStats => 'K/D、ACS、HS%はラウンド制のモードでのみ集計されます。';

  @override
  String profileFormPending(int n) {
    return '一覧のうち$n試合はまだ読み込まれていないため、集計に含まれていません。';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D、ACS、ADR、HS%はラウンド制の$roundGames/$games試合のみで集計';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '直近$games試合：$w勝、$l敗';
  }

  @override
  String get profileFriendsRow => 'フレンドとチャット';

  @override
  String profileGainPerWin(String rr) {
    return '勝利時 $rr RR';
  }

  @override
  String get profileHideKills => 'キルを隠す';

  @override
  String get profileHitBody => '胴体';

  @override
  String get profileHitDistribution => '命中部位の分布';

  @override
  String get profileHitHead => '頭';

  @override
  String get profileHitLegs => '脚';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint => 'キル、アシスト、生存、またはトレードのいずれかを記録したラウンドの割合';

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
    return '過去$n日間';
  }

  @override
  String profileLastMatches(int n) {
    return '直近$n試合';
  }

  @override
  String profileLeaderboard(String n) {
    return 'リーダーボード #$n';
  }

  @override
  String profileLevel(int n) {
    return 'レベル$n';
  }

  @override
  String get profileLevelHidden => 'レベル非公開';

  @override
  String profileLossPerLoss(String rr) {
    return '敗北時 $rr RR';
  }

  @override
  String profileLossStreak(int n) {
    return '$n連敗';
  }

  @override
  String profileMapFilter(String map) {
    return 'マップ：$map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n試合';
  }

  @override
  String get profileMatchDetailTitle => '試合の詳細';

  @override
  String get profileMatchHistory => '戦績';

  @override
  String get profileMatchUnavailable => '試合を読み込めませんでした';

  @override
  String get profileMatchesNeeded => '必要な試合数';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'ランク経験なし';

  @override
  String get profileNoKillsInRound => 'このラウンドのキル情報はありません。';

  @override
  String get profileNoMatches => '試合はまだありません。';

  @override
  String get profileNoMatchesMap => '読み込んだ試合の中に、このマップの試合はありません。';

  @override
  String get profileNoMatchesQueue => 'このモードの試合はありません。';

  @override
  String get profileNoPlayers => 'この試合のプレイヤー情報はありません。';

  @override
  String get profileNoRounds => 'この試合のラウンド情報はありません。';

  @override
  String get profileOvertime => 'オーバータイム';

  @override
  String get profilePlayHubTitle => '試合とパーティー';

  @override
  String get profilePartyRow => 'パーティーとキュー';

  @override
  String get profilePeakRank => '最高';

  @override
  String profilePeakRankOf(String actTitle) {
    return '最高 · $actTitle';
  }

  @override
  String get profilePerformanceAttack => 'アタッカー';

  @override
  String get profilePerformanceDefense => 'ディフェンダー';

  @override
  String get profilePerformanceEmpty =>
      'この端末に記録された試合はまだありません。戦績を開くと、プレイした試合が記録されます。';

  @override
  String get profilePerformanceGames => '試合数';

  @override
  String get profilePerformanceNoMatches => '選択した期間に試合はありません。';

  @override
  String profilePerformanceRounds(int n) {
    return '記録済み $nラウンド';
  }

  @override
  String get profilePerformanceSample =>
      '割合は3試合以上ある場合のみ表示されます。ACS、ADR、HS%、K/Dはラウンド制のモードのみで集計されます。';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return '$known/$totalラウンドでアタッカー/ディフェンダーを判別できました。';
  }

  @override
  String profilePerformanceSince(String date) {
    return '端末上の履歴（$dateから）';
  }

  @override
  String get profilePerformanceTitle => 'パフォーマンス';

  @override
  String get profilePerformanceTrendEmpty => '傾向を比較するには、3試合以上ある期間が2つ以上必要です。';

  @override
  String get profilePickTargetHint => '目標のランクを選択';

  @override
  String profilePlacement(int n) {
    return '$n位';
  }

  @override
  String profilePlantedAt(String site) {
    return '$siteにスパイク設置';
  }

  @override
  String get profilePlayerProfileTitle => 'プレイヤープロフィール';

  @override
  String get profilePlayerSummary => '成績';

  @override
  String profileProgressTo(String rank) {
    return '$rankまでの進行状況';
  }

  @override
  String get profileProgressToTarget => '目標ランクまでの進行状況';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      '最近のコンペティティブの試合に基づく推定です。ランク決定戦と降格保護は考慮していません。';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches試合で$rankに到達';
  }

  @override
  String get profileRankUpImmortal => 'すでにイモータル以上です — この機能はイモータル1までが対象です。';

  @override
  String get profileRankUpNoForm => '調子を推定するための最近のコンペティティブの試合がありません。';

  @override
  String get profileRankUpOpen => 'ランクアップ計算を開く';

  @override
  String get profileRankUpTitle => 'ランクアップ計算';

  @override
  String get profileRankUpUnranked => 'ランクアップ計算を使うには、ランク決定戦を完了してください。';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'ランクスコアボード';

  @override
  String profileRecentForm(int w, int l) {
    return '最近の調子：$w勝 – $l敗';
  }

  @override
  String get profileRecentFormTitle => '最近の調子';

  @override
  String get profileRecentMatches => '最近の試合';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$w勝 · $l敗 · $d分',
      zero: '$w勝 · $l敗',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot IDをコピーしました';

  @override
  String profileRound(int n) {
    return 'ラウンド$n';
  }

  @override
  String profileRoundKills(int n) {
    return '$nキル';
  }

  @override
  String get profileRoundLost => 'ラウンド敗北';

  @override
  String get profileRoundTimeline => 'ラウンドの経過';

  @override
  String get profileRoundWon => 'ラウンド勝利';

  @override
  String get profileRoundsHint => 'ラウンドをタップすると各キルを確認できます。';

  @override
  String get profileRr => 'RR';

  @override
  String profileRrLeft(String n) {
    return 'あと$n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RRの推移';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'スコアボード';

  @override
  String get profileSecondHalf => '後半';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'キルを表示';

  @override
  String get profileSideSwitch => '攻守交代';

  @override
  String get profileSpike => 'スパイク';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => '目標ランク';

  @override
  String get profileTeamBlue => 'ブルーチーム';

  @override
  String get profileTeamMvp => 'チームMVP';

  @override
  String get profileTeamRed => 'レッドチーム';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String profileToday(String text) {
    return '今日：$text';
  }

  @override
  String get profileTodayNone => '今日はまだコンペティティブの試合がありません';

  @override
  String get profileTruePeakLocal => '端末上の履歴に基づく';

  @override
  String get profileWeekdayShortItem0 => '月';

  @override
  String get profileWeekdayShortItem1 => '火';

  @override
  String get profileWeekdayShortItem2 => '水';

  @override
  String get profileWeekdayShortItem3 => '木';

  @override
  String get profileWeekdayShortItem4 => '金';

  @override
  String get profileWeekdayShortItem5 => '土';

  @override
  String get profileWeekdayShortItem6 => '日';

  @override
  String get profileWinRate => '勝率';

  @override
  String profileWinStreak(int n) {
    return '$n連勝';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'あなたのランク';

  @override
  String get profileYourSummary => 'あなたの成績';

  @override
  String get profileYourTeam => '味方チーム';

  @override
  String get profileYourWinRate => 'あなたの最近の勝率';

  @override
  String get legalAboutIntro =>
      'あなたのVALORANTパートナー：デイリーストア、ウィッシュリスト、ランク、試合、複数アカウント、プレイヤーコミュニティを、あなたの端末で。';

  @override
  String get legalBackToTop => 'ページの先頭へ';

  @override
  String get legalConsentAnd => ' と ';

  @override
  String get legalConsentPrefix => '続行すると、ValHubの ';

  @override
  String get legalConsentPrivacy => 'プライバシーポリシー';

  @override
  String get legalConsentSuffix => ' に同意したものとみなされます。';

  @override
  String get legalConsentTerms => '利用規約';

  @override
  String get legalContact => 'お問い合わせ';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'お問い合わせ';

  @override
  String get legalCreditsHeader => 'データソースとクレジット';

  @override
  String legalEffectiveFrom(String date) {
    return '$dateより有効';
  }

  @override
  String get legalLegalHeader => '法的事項';

  @override
  String get legalLicensePageLegalese => '© 2026 Nguyễn Đức Huy. 全著作権所有。';

  @override
  String get legalThirdPartyLicenses => 'サードパーティソフトウェア';

  @override
  String get legalThirdPartyLicensesBody => 'ValHubが使用しているオープンソースソフトウェアのライセンス';

  @override
  String get legalTocTitle => '目次';

  @override
  String legalVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'この文書は現在$languageで表示されています。';
  }

  @override
  String get legalContentUnavailable =>
      '法的文書を読み込めませんでした。もう一度お試しいただくか、サポートにお問い合わせください。';

  @override
  String get settingsUiLanguageTitle => '表示言語';

  @override
  String get settingsLanguageFollowDevice => '端末の設定に従う';

  @override
  String get settingsLanguageSaveFailed => '言語を保存できませんでした。もう一度お試しください。';

  @override
  String get settingsGeoCountry => '国';

  @override
  String get settingsGeoSearchCountry => '国名または国コードで検索';

  @override
  String get settingsGeoSupportedOnly => '対応が確認済みの国のみ';

  @override
  String get settingsGeoUnknown => '対応状況は未確認';

  @override
  String get settingsGeoRestricted => '制限あり';

  @override
  String get settingsGeoSeparate => '別サービス';

  @override
  String get settingsGeoAvailable => '対応';

  @override
  String get settingsGeoNotApplicable => '該当なし';

  @override
  String get settingsGeoConnection => 'Riotへの接続';

  @override
  String get settingsGeoChooseRegion => '地域を選択';

  @override
  String get settingsGeoAuto => 'アカウントに合わせて自動';

  @override
  String get settingsGeoManual => '手動で選択';

  @override
  String get settingsGeoNoRegion => 'Riotの地域を特定できませんでした';

  @override
  String get settingsGeoManualWarning =>
      'この設定で変わるのは、ValHubが接続するサーバーのみです。Riotアカウントの地域は変更されません。保存する前に、ValHubが接続を確認します。';

  @override
  String get settingsGeoConnectionSaved => '接続方法を保存しました';

  @override
  String get settingsGeoValidationFailed =>
      'このサーバーではアカウントを確認できませんでした。地域を選び直してください。';

  @override
  String get settingsGeoHintOnly =>
      '国は検索と候補表示にのみ使用されます。接続する地域はRiotアカウントによって決まります。';

  @override
  String get settingsGeoUnsupported => 'このRiotの地域にはまだ対応していません。設定で地域を選択してください。';

  @override
  String get settingsGeoSave => '確認して保存';

  @override
  String get settingsGeoCancel => 'キャンセル';

  @override
  String get settingsGeoLoading => '接続を確認中…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'この設定は国名、候補表示、推定VP価格に使用されます。接続するサーバーとコミュニティのアカウントの国は、引き続きRiotによって決まります。';

  @override
  String get settingsGeoCountryAutomatic => 'アカウントまたは端末の国を使用';

  @override
  String get settingsGeoSaveFailed => '設定を保存できませんでした。もう一度お試しください。';

  @override
  String get settingsGeoAllRegions => 'すべての地域';

  @override
  String get settingsGeoSuggestions => 'おすすめ';

  @override
  String get settingsGeoNoCountries => 'フィルターに一致する国はありません。';

  @override
  String get settingsGeoActiveCountries => 'アクティブ';

  @override
  String get settingsGeoAllCountries => 'すべての国';

  @override
  String get settingsGeoActivityUnavailable =>
      '各国のアクティビティを読み込めませんでした。「すべての国」からは引き続き選択できます。';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか国',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return '$manualが選択されていますが、Riotはアカウントの地域を$detectedと判定しています。この接続の確認を続けますか？';
  }

  @override
  String get settingsGeoUnverified =>
      'サーバーまたはネットワークの問題により、接続を確認できませんでした。この設定を保存して後でもう一度お試しになりますか？';

  @override
  String get settingsGeoContinue => '続ける';

  @override
  String settingsGeoMismatch(String region) {
    return '手動で選んだ接続先がRiotの地域（$region）と異なります。自動の地域を使いますか？';
  }

  @override
  String get settingsGeoUseAuto => '自動を使用';

  @override
  String get settingsGeoKeepManual => '手動のまま';

  @override
  String get settingsGeoReviewConnection => '接続を確認';

  @override
  String settingsGeoCheckedAt(String time) {
    return '最終確認：$time';
  }

  @override
  String get settingsGeoCheckAgain => '再確認';

  @override
  String get settingsPlatformMobile => 'モバイル';

  @override
  String get settingsPlatformOther => 'その他のプラットフォーム';

  @override
  String get settingsContentLanguageFollowApp => 'アプリの言語に従う';

  @override
  String get settingsContentLanguageHint =>
      'アイテム名の言語を選択します。この設定で表示言語やRiotのサーバーは変わりません。';

  @override
  String settingsLanguageChanged(String language) {
    return '言語：$language。';
  }

  @override
  String get settingsAboutCreditContent => 'valorant-api.com';

  @override
  String get settingsAboutCreditContentBody => 'スキン、エージェント、マップ、ランクの名前、画像、情報。';

  @override
  String get settingsAboutCreditDocs => 'コミュニティのドキュメント';

  @override
  String get settingsAboutCreditDocsBody =>
      'techchrism/valorant-api-docs プロジェクトとVALORANT開発者コミュニティ。';

  @override
  String get settingsAboutCreditRiot => 'Riot Games';

  @override
  String get settingsAboutCreditRiotBody =>
      'ストア、ウォレット、コレクション、試合、ランクは、ログインしたRiotアカウントから直接取得しています。';

  @override
  String get settingsAboutCreditsHeader => 'データソース';

  @override
  String get settingsAboutHeader => '情報';

  @override
  String get settingsAboutLegalHeader => '法的事項';

  @override
  String get settingsAboutRowSubtitle => 'プライバシー、規約、著作権、お問い合わせ';

  @override
  String get settingsAboutTitle => '情報と規約';

  @override
  String get settingsAppHeader => '詳細設定';

  @override
  String get settingsAppearanceHeader => '表示';

  @override
  String settingsBuildNumber(String build) {
    return 'ビルド $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '$sizeを削除しました';
  }

  @override
  String get settingsClearCache => '一時データを削除';

  @override
  String get settingsClearCacheFailed => '一時データを削除できませんでした。もう一度お試しください。';

  @override
  String get settingsClearCacheSubtitle => '端末にダウンロードした画像とデータ（記録済みのエラーレポートを含む）';

  @override
  String get settingsClearLog => '記録済みのエラーレポートを削除';

  @override
  String get settingsClearLogConfirm => 'この端末に記録されたエラーレポートを削除しますか？';

  @override
  String get settingsExportLog => 'ValHubにエラーレポートを送信';

  @override
  String get settingsExportLogEmpty =>
      '送信する内容はまだありません。アプリをしばらく使ってからもう一度お試しください。';

  @override
  String get settingsExportLogEmptyTitle => '送信する内容はありません';

  @override
  String get settingsExportLogNote => 'エラーレポートには、パスワードやRiotのログインデータは含まれません。';

  @override
  String get settingsExportLogSubtitle =>
      'エラーレポートには、パスワードやRiotのログインデータは含まれません。';

  @override
  String get settingsFeedback => 'ValHubへのご意見';

  @override
  String get settingsFeedbackSubtitle => 'ValHubのフィードバックページを開く';

  @override
  String get settingsItemLanguageEn => '英語';

  @override
  String get settingsItemLanguageHint => 'スキン、エージェント、マップなどの名前がこの言語で表示されます。';

  @override
  String get settingsItemLanguageLabel => 'アイテム名';

  @override
  String get settingsItemLanguagePickerTitle => 'アイテム名の言語';

  @override
  String get settingsItemLanguageVi => 'ベトナム語';

  @override
  String get settingsLegalNotice => '法的通知';

  @override
  String get settingsLinkOpenFailed => 'リンクを開けませんでした。もう一度お試しください。';

  @override
  String get settingsLogCleared => 'エラーレポートを削除しました';

  @override
  String settingsLogEntryCount(int count) {
    return '$count件';
  }

  @override
  String settingsLogEntryShown(int shown, int total) {
    return '$shown / $total件';
  }

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — エラーレポート';
  }

  @override
  String get settingsLogFilterAll => 'すべて';

  @override
  String get settingsLogFilterAuth => 'ログイン';

  @override
  String get settingsLogFilterEmpty => '一致する項目はありません。フィルターを解除するとさらに表示されます。';

  @override
  String get settingsLogFilterErrors => '問題';

  @override
  String get settingsLogFilterHttp => '接続';

  @override
  String get settingsLogMore => 'その他のオプション';

  @override
  String get settingsLogSearchEmpty => '一致する項目はありません。';

  @override
  String get settingsLogSearchHint => 'エラーレポートを検索…';

  @override
  String get settingsLogShareFailed => 'エラーレポートを送信できませんでした。もう一度お試しください。';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'ナイトマーケット開催時';

  @override
  String get settingsNotifNightMarketSubtitle => 'ナイトマーケットのオファーをめくるようお知らせします';

  @override
  String get settingsNotifPermissionMissing => 'アプリに通知の権限がありません。';

  @override
  String get settingsNotifStoreReset => 'ストア更新時';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return '毎日$time';
  }

  @override
  String get settingsNotifWishlist => 'ウィッシュリストのスキン登場時';

  @override
  String get settingsNotifWishlistSubtitle =>
      'アプリを開いていなくても、すべてのアカウントのストアを確認します';

  @override
  String get settingsNotificationsHeader => '通知';

  @override
  String get settingsOptionAutoOpenLiveGame => '試合の詳細を自動で開く';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      '試合が見つかったらすぐに現在の試合画面を開きます';

  @override
  String get settingsOptionOwnPrice => 'VPパックの価格';

  @override
  String get settingsOptionOwnPriceEmpty => '未入力 — 地域の価格表があればそれを使用';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'プラットフォーム';

  @override
  String get settingsOptionShowLiveScore => 'ライブスコアを表示';

  @override
  String get settingsOptionShowPeakRank => '試合の詳細に最高ランクを表示';

  @override
  String get settingsOptionShowPrice => '推定換算価格を表示';

  @override
  String get settingsOptionShowPriceInfo => '換算価格の計算方法';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'VP価格の横に表示（例：$vp $price）';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'お住まいの地域の確認済み価格表はまだありません — VPパックの価格を入力してください。';

  @override
  String get settingsOptionsHeader => 'オプション';

  @override
  String get settingsPhaseComplete => '完了';

  @override
  String get settingsPhaseInProgress => '進行中';

  @override
  String get settingsPhaseScheduled => '予定';

  @override
  String settingsPlatformAppliesTo(String account) {
    return '$accountに適用';
  }

  @override
  String get settingsPlatformHint =>
      '正しい戦績を表示するため、プレイしているPC、PlayStation、Xboxを選択してください。';

  @override
  String get settingsPlatformPickerTitle => 'プラットフォームを選択';

  @override
  String get settingsPrimingBody => '通知をオンにすると、ストアの更新やウィッシュリストのスキンの登場をお知らせします。';

  @override
  String get settingsPrimingEnable => '通知をオンにする';

  @override
  String get settingsPrimingFootnote => '通知の種類ごとのオン/オフは、設定からいつでも変更できます。';

  @override
  String get settingsPrimingLater => '後で';

  @override
  String get settingsPrimingPointNightMarket => 'ナイトマーケットの開催がわかる';

  @override
  String get settingsPrimingPointNightMarketDetail => '期限が切れる前にオファーをめくれます';

  @override
  String get settingsPrimingPointStore => 'デイリーストアの更新をお知らせ';

  @override
  String get settingsPrimingPointStoreDetail => 'アカウントのストアが更新されたらお知らせします';

  @override
  String get settingsPrimingPointWishlist => '狙っているスキンの登場をお知らせ';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'アプリを開いていなくても、すべてのアカウントのストアを確認します';

  @override
  String get settingsPrimingTitle => '狙っているスキンを見逃さない';

  @override
  String settingsRemovedAccount(String account) {
    return '$accountを削除しました';
  }

  @override
  String get settingsServerStatus => 'サーバーの状態';

  @override
  String get settingsServerStatusMaintenance => 'メンテナンス中';

  @override
  String settingsServerStatusNotices(int n) {
    return 'お知らせ$n件';
  }

  @override
  String get settingsServerStatusSubtitle => 'サーバーごとのVALORANTのメンテナンスと障害';

  @override
  String get settingsSessionLogTitle => 'ValHubエラーレポート';

  @override
  String get settingsSeverityCritical => '重大';

  @override
  String get settingsSeverityInfo => '情報';

  @override
  String get settingsSeverityWarning => '警告';

  @override
  String get settingsSignedOutAll => 'すべてのアカウントからログアウトしました';

  @override
  String get settingsStatusAllGood => 'サーバーは正常に稼働しています';

  @override
  String settingsStatusAllGoodBody(String region) {
    return '$regionサーバーで障害やメンテナンスはありません。';
  }

  @override
  String get settingsStatusFewerUpdates => '折りたたむ';

  @override
  String get settingsStatusIssues => 'Riotが障害に対応中です';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'このサーバーには障害のお知らせが$n件あります。';
  }

  @override
  String get settingsStatusKindIncident => '障害';

  @override
  String get settingsStatusKindMaintenance => 'メンテナンス';

  @override
  String get settingsStatusMaintenanceNow => 'サーバーはメンテナンス中です';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'ゲームにログインできない場合があり、ValHubも一時的に情報を読み込めない場合があります。';

  @override
  String settingsStatusMoreUpdates(int n) {
    return 'さらに$n件の更新を表示';
  }

  @override
  String get settingsStatusRegionPicker => 'サーバー';

  @override
  String get settingsStatusScheduled => 'メンテナンス予定あり';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riotから告知されたメンテナンス予定が$n件あります。';
  }

  @override
  String get settingsStatusSourceNote =>
      '出典：Riot Games公式のステータスページ。時刻は端末のタイムゾーンで表示されます。';

  @override
  String settingsStatusStarted(String when) {
    return '開始：$when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return '更新：$when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'Riotからの更新';

  @override
  String get settingsSupportHeader => 'サポート';

  @override
  String settingsSwitchedTo(String account) {
    return '$accountに切り替えました';
  }

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsThemeLabel => 'テーマ';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemePickerTitle => 'テーマを選択';

  @override
  String get settingsThemeSystem => 'システムに従う';

  @override
  String get settingsTitle => '設定';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsWelcomeBulletProfile => 'ランク、戦績、進行中の試合';

  @override
  String get settingsWelcomeBulletProfileDetail => '試合ごとのRR、相手のランク';

  @override
  String get settingsWelcomeBulletStore => 'デイリーストア、ナイトマーケット、バンドル';

  @override
  String get settingsWelcomeBulletStoreDetail => '価格、レア度、更新までのカウントダウン';

  @override
  String get settingsWelcomeBulletWishlist => 'ウィッシュリストと通知';

  @override
  String get settingsWelcomeBulletWishlistDetail => '狙っているスキンがストアに並んだらお知らせ';

  @override
  String get settingsWelcomeFootnote =>
      'ログインはRiotの公式ページで行います。ValHubがパスワードを保存するのは、ログイン情報の保存を選んだ場合のみです。';

  @override
  String get settingsWelcomeKicker => 'VALORANTパートナー';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average（評価$count件） · ',
      'other': '',
    });
    return 'コミュニティ：$_temp0いいね$votes件';
  }

  @override
  String get skinDetailAddToWishlist => 'ウィッシュリストに追加';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'ストアに登場中のアカウント：$accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return 'あなたのストアでの登場回数：デイリーストア$daily回、ナイトマーケット$night回。端末上のデータのみ（$sinceから記録）。';
  }

  @override
  String get skinDetailHistoryDelete => 'ストア履歴を削除';

  @override
  String get skinDetailHistoryDeleteBody =>
      'この端末に記録された、このアカウントのストア履歴をすべて削除しますか？';

  @override
  String get skinDetailInWishlist => 'ウィッシュリストに追加済み';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'ロック中';

  @override
  String get skinDetailMute => 'ミュート';

  @override
  String get skinDetailNotFound => 'このスキンが見つかりません。';

  @override
  String get skinDetailOwned => '所持済み';

  @override
  String get skinDetailPause => '一時停止';

  @override
  String get skinDetailPlay => '再生';

  @override
  String get skinDetailPlayVideo => '動画を見る';

  @override
  String get skinDetailRemoveFromWishlist => 'ウィッシュリストから削除';

  @override
  String get skinDetailTitle => 'スキンの詳細';

  @override
  String get skinDetailUnmute => 'ミュート解除';

  @override
  String get skinDetailUpgrades => 'アップグレード';

  @override
  String get skinDetailVariants => 'バリエーション';

  @override
  String get skinDetailVideoError => '動画を再生できません。ネットワークを確認してもう一度お試しください。';

  @override
  String get socialPresenceInMatch => '試合中';

  @override
  String get socialPresenceAgentSelect => 'エージェント選択中';

  @override
  String get socialPresenceQueue => 'マッチング中';

  @override
  String get socialPresenceLobby => 'ロビーにいます';

  @override
  String get socialPresenceCustom => 'カスタムゲーム中';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'オープンパーティー',
      'other': '招待のみ',
    });
    return '$size/$max人 · $_temp0';
  }

  @override
  String get socialAccept => '承諾';

  @override
  String get socialAcceptInGame => 'この招待はゲーム内で承諾してください。';

  @override
  String socialActionFailed(String message) {
    return '操作を完了できませんでした。$message';
  }

  @override
  String get socialAutoRefresh => '自動更新';

  @override
  String get socialAway => '退席中';

  @override
  String socialCancelQueue(String elapsed) {
    return 'マッチングをキャンセル · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'マッチングをキャンセル';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'パーティーは$queueに参加できません：$reason';
  }

  @override
  String get socialChangeQueue => 'キューを変更';

  @override
  String get socialChatTitle => 'チャット';

  @override
  String get socialChatUnavailable => 'チャットはオフラインです。';

  @override
  String get socialCloseParty => 'パーティーを閉じる';

  @override
  String get socialClosedState => '招待のみ';

  @override
  String get socialCodeInvalid => 'パーティーコードは英字と数字のみです。';

  @override
  String get socialConnecting => 'チャットに接続中…';

  @override
  String get socialCopyCode => 'コピー';

  @override
  String get socialCurrentQueue => '選択中';

  @override
  String get socialCustomGameLobby => 'パーティーはカスタムゲームのロビーにいます。';

  @override
  String get socialDecline => '拒否';

  @override
  String get socialDisableCode => 'コードを無効化';

  @override
  String get socialEmptyChat => 'メッセージはまだありません。挨拶を送ってみましょう！';

  @override
  String get socialEmptyChatTitle => 'チャットを始める';

  @override
  String get socialFailedBadge => '送信失敗';

  @override
  String get socialFilterAll => 'すべて';

  @override
  String get socialFilterOnline => 'オンライン';

  @override
  String get socialFilterUnread => '未読';

  @override
  String get socialFriendsPrivacyNote =>
      'フレンドリストとメッセージはRiotから直接取得しています。ValHubがそれらを他の場所に保存することはありません。';

  @override
  String socialFriendsSummary(int total, int online) {
    return 'フレンド$total人 · $online人がオンライン';
  }

  @override
  String get socialFriendsTitle => 'フレンドとチャット';

  @override
  String get socialGameNotRunningBody =>
      'パーティーとキューは、PCまたはコンソールでVALORANTが起動しているときのみ利用できます。ゲームを起動してから、下に引っ張って更新してください。';

  @override
  String get socialGameNotRunningTitle => 'PCまたはゲーム機でVALORANTを起動してください';

  @override
  String get socialGenerateCode => 'コードを作成';

  @override
  String get socialHistoryFailed => '過去のメッセージを読み込めませんでした。再接続してもう一度お試しください。';

  @override
  String get socialIdleQueue => 'マッチング準備完了';

  @override
  String get socialInMatchBanner => '試合中です。キューは試合終了後に再び利用できます。';

  @override
  String get socialInValorant => 'VALORANTをプレイ中';

  @override
  String get socialInviteByRiotId => 'Riot IDで招待';

  @override
  String get socialInviteByRiotIdHint => 'フレンドでないプレイヤーも招待できます';

  @override
  String get socialInviteFriends => 'フレンドを招待';

  @override
  String socialInviteFrom(String name) {
    return '$nameからの招待';
  }

  @override
  String socialInviteLabel(String name) {
    return '$nameを招待';
  }

  @override
  String get socialInviteNeedsName => 'このプレイヤーのRiot IDが不明なため、招待できません。';

  @override
  String socialInviteSent(String name) {
    return '$nameに招待を送信しました。';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · 招待済み';
  }

  @override
  String get socialInvitesSection => '招待';

  @override
  String get socialJoin => '参加';

  @override
  String get socialJoinConfirmBody => 'このコードのパーティーに参加するため、現在のパーティーから抜けます。';

  @override
  String get socialJoinConfirmTitle => '別のパーティーに参加しますか？';

  @override
  String get socialJoinSection => '別のパーティーに参加';

  @override
  String get socialJoinWithCode => 'コードを入力して参加';

  @override
  String get socialJoined => 'パーティーに参加しました。';

  @override
  String socialLastOnline(String relative) {
    return '最終オンライン：$relative';
  }

  @override
  String get socialLeader => 'リーダー';

  @override
  String socialLeaderboardTop(String position) {
    return 'トップ$position';
  }

  @override
  String get socialLeaveConfirmBody => '現在のパーティーから抜けて、ソロパーティーに戻ります。';

  @override
  String get socialLeaveConfirmTitle => 'パーティーから抜けますか？';

  @override
  String get socialLeaveParty => 'パーティーから抜ける';

  @override
  String socialLevel(int n) {
    return 'レベル$n';
  }

  @override
  String get socialMatchFound => '試合が見つかりました！';

  @override
  String socialMembersSection(int n, int max) {
    return 'メンバー（$n/$max）';
  }

  @override
  String get socialMessageHint => 'メッセージを入力…';

  @override
  String get socialMoreActions => 'その他のオプション';

  @override
  String get socialNoCode => 'コードを作成すると、フレンドがコードでパーティーにすばやく参加できます。';

  @override
  String get socialNoCodeMember => 'リーダーはすばやく招待するためのコードを作成できます。';

  @override
  String get socialNoFilterResults => 'このフィルターに一致するフレンドはいません。';

  @override
  String get socialNoFriends => 'Riotのフレンドリストは空です。ゲーム内でフレンドを追加しましょう。';

  @override
  String get socialNoFriendsTitle => 'フレンドはまだいません';

  @override
  String get socialNoOnlineFriends => 'VALORANTでオンラインのフレンドはいません。';

  @override
  String get socialNoSearchResults => '一致するフレンドが見つかりません。';

  @override
  String get socialNoSearchResultsTitle => '見つかりません';

  @override
  String get socialNotFriend => 'このプレイヤーはフレンドリストにいません。';

  @override
  String get socialNotReady => '準備未完了';

  @override
  String socialOfflineSection(int n) {
    return 'オフライン（$n）';
  }

  @override
  String get socialOfflineStatus => 'オフライン';

  @override
  String get socialOnlineMobile => 'モバイルでオンライン';

  @override
  String socialOnlineSection(int n) {
    return 'オンライン（$n）';
  }

  @override
  String get socialOnlineStatus => 'オンライン';

  @override
  String get socialOnlyLeader => 'キューの変更とマッチング開始はリーダーのみ可能です。';

  @override
  String get socialOpenParty => 'パーティーを公開';

  @override
  String get socialOpenState => 'オープンパーティー';

  @override
  String get socialOtherGamesLeagueOfLegends => 'リーグ・オブ・レジェンド';

  @override
  String get socialOtherGamesBacon => 'レジェンド・オブ・ルーンテラ';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'パーティーコード';

  @override
  String socialPartyCodeValue(String code) {
    return 'パーティーコード：$code';
  }

  @override
  String get socialPartyInvite => 'パーティーへの招待';

  @override
  String socialPartyOf(int size, int max) {
    return 'パーティー $size/$max';
  }

  @override
  String get socialPartyTitle => 'パーティーとキュー';

  @override
  String socialPickQueueSubtitle(int size) {
    return '$size人パーティー';
  }

  @override
  String get socialPickQueueTitle => 'キューを選択';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'ゲームサーバーへの最良Ping';

  @override
  String socialPlayingOther(String game) {
    return '$gameをプレイ中';
  }

  @override
  String socialPlayingSection(int n) {
    return 'プレイ中（$n）';
  }

  @override
  String get socialQueueLabel => 'キュー';

  @override
  String get socialQueueLocked => '試合中はキューを変更できません。';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '最大$max人',
      one: 'ソロ専用',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'ゲームの状態を確認できませんでした。準備完了とキューを使うには更新してください。';

  @override
  String get socialReady => '準備完了';

  @override
  String socialReadyCount(int ready, int total) {
    return '準備完了 $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => 'アカウントレベルが足りないメンバーがいます';

  @override
  String get socialReasonGeneric => 'パーティーが条件を満たしていません';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'パーティーの人数が多すぎます（最大$max人）';
  }

  @override
  String get socialReasonRankDisparity => 'コンペティティブに参加するにはランク差が大きすぎます';

  @override
  String socialReasonRestricted(String time) {
    return 'パーティーはマッチングを制限されています（残り$time）';
  }

  @override
  String get socialReconnecting => 'チャットの接続が切れました。再接続中…';

  @override
  String get socialRemoteNote =>
      '変更は、あなたがタップしたときにのみRiotに送信されます。ValHubが代わりにマッチングを開始したり、エージェントをロックインしたりすることはありません。';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$nameをあなたのパーティーから外します。';
  }

  @override
  String get socialRemoveConfirmTitle => 'パーティーから外しますか？';

  @override
  String get socialRemoveMember => 'パーティーから外す';

  @override
  String socialRequestFrom(String name) {
    return '$nameがパーティーへの参加を希望しています';
  }

  @override
  String get socialRequestsSection => '参加リクエスト';

  @override
  String get socialRiotIdFieldHint => '名前#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot IDは、名前（3～16文字）、#、タグ（英数字3～5文字）で構成されます。';

  @override
  String get socialSearchHint => 'Riot IDで検索…';

  @override
  String socialSearching(String elapsed) {
    return 'マッチング中 · $elapsed';
  }

  @override
  String get socialSend => '送信';

  @override
  String get socialSendFailed => 'メッセージを送信できませんでした。接続を確認してもう一度お試しください。';

  @override
  String get socialSendInvite => '招待を送信';

  @override
  String get socialShareCode => '共有';

  @override
  String socialShareCodeText(String code) {
    return 'このコードで私のVALORANTパーティーに参加してね：$code';
  }

  @override
  String get socialShootingRange => '射撃場にいます';

  @override
  String get socialShowEveryone => 'すべて表示';

  @override
  String get socialStartQueue => 'マッチング開始';

  @override
  String get socialSuggestionsItem0 => 'こんにちは！';

  @override
  String get socialSuggestionsItem1 => '何戦かやらない？';

  @override
  String get socialSuggestionsItem2 => '一緒にパーティー組もう！';

  @override
  String socialUnread(int n) {
    return '未読$n件';
  }

  @override
  String get socialUnready => '準備完了を取り消す';

  @override
  String get socialViewProfile => 'プロフィールを見る';

  @override
  String get socialWaitingForConnection => '接続中… 接続が完了するとメッセージを送信できます。';

  @override
  String get socialYou => 'あなた';

  @override
  String get socialPartyUnavailable => 'パーティーを同期できませんでした。更新してもう一度お試しください。';

  @override
  String get storeAccessoryEmpty => 'アクセサリーストアには現在何もありません。';

  @override
  String get storeAccessoryEmptyTitle => 'アクセサリーはまだありません';

  @override
  String storeAccessoryFrom(String contract) {
    return '入手元：$contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return '更新まで$t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return '更新：$wall';
  }

  @override
  String get storeAddToWishlist => 'ウィッシュリストに追加';

  @override
  String get storeBackToBundles => '販売中のバンドルを見る';

  @override
  String get storeBundleBuySeparateLabel => '個別購入';

  @override
  String get storeBundleDetailTitle => 'バンドルの詳細';

  @override
  String storeBundleEndsAt(String wall) {
    return '終了：$wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return '残り$t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$nアイテム';
  }

  @override
  String get storeBundleItemFree => '無料';

  @override
  String get storeBundleItemsTitle => 'バンドルの内容';

  @override
  String get storeBundleNotFound => 'このバンドルが見つかりません。販売期間が終了した可能性があります。';

  @override
  String get storeBundleNotFoundTitle => 'バンドルの販売は終了しました';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return '$owned/$totalアイテム所持済み';
  }

  @override
  String get storeBundlePriceLabel => 'バンドル価格';

  @override
  String get storeBundleSavingsLabel => 'お得額';

  @override
  String get storeBundleWholesaleOnly => 'セット販売のみで、個別には購入できません。';

  @override
  String get storeBundlesEmpty => '現在販売中のバンドルはありません。';

  @override
  String get storeBundlesEmptyTitle => 'バンドルはまだありません';

  @override
  String get storeDailyEmpty => '今日のストアにはスキンがありません。';

  @override
  String get storeDailyEmptyTitle => 'ストアは空です';

  @override
  String storeDailyResetAt(String time) {
    return '毎日$timeに更新';
  }

  @override
  String get storeDailyTotalLabel => '合計';

  @override
  String get storeNightMarketEmpty => '現在ナイトマーケットは開催されていません。';

  @override
  String get storeNightMarketEmptyTitle => 'ナイトマーケットは未開催です';

  @override
  String storeNightMarketEndsAt(String wall) {
    return '終了：$wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return '終了まで$t';
  }

  @override
  String get storeNightMarketNote => 'ナイトマーケットのオファーはあなたのアカウント専用で、更新することはできません。';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return '合計 $amount お得';
  }

  @override
  String get storeNightMarketUnrevealed => '未公開';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name、$price';
  }

  @override
  String get storeOwnedBadge => '所持済み';

  @override
  String storeOwnedCount(int owned, int total) {
    return '所持済み $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'ウィッシュリストから削除';

  @override
  String storeResetNotificationBody(int skinCount, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      skinCount,
      locale: localeName,
      other: '$accountの今日の新しいスキン$skinCount個をチェックしましょう。',
      zero: '$accountの今日の新しいスキンをチェックしましょう。',
    );
    return '$_temp0';
  }

  @override
  String get storeResetNotificationTitle => 'ストアが更新されました';

  @override
  String storeResetsIn(String t) {
    return '更新まで$t';
  }

  @override
  String get storeSegmentAccessories => 'アクセサリー';

  @override
  String get storeSegmentBundles => 'バンドル';

  @override
  String get storeSegmentDaily => 'デイリー';

  @override
  String get storeSegmentNightMarket => 'ナイトマーケット';

  @override
  String get storeShareButton => '共有';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => '今日のストア';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'ナイトマーケット';

  @override
  String get storeShareCardPriceNote => '換算価格はVPパックに基づく推定です。';

  @override
  String storeShareCardSaved(String vp) {
    return '$vp お得';
  }

  @override
  String get storeShareCardTagline => 'あなたのVALORANTパートナー';

  @override
  String storeShareCardTotal(String vp) {
    return '合計 $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return '$wallまで';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => '今日のストアを共有';

  @override
  String get storeShareFailed => '画像を作成できませんでした。もう一度お試しください。';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => '画像を共有';

  @override
  String get storeShareNightMarketTitle => 'ナイトマーケットを共有';

  @override
  String get storeSharePreparing => 'スキン画像を読み込み中…';

  @override
  String get storeShareShowPrice => '推定換算価格を表示';

  @override
  String get storeShareShowPriceHint => '最もお得なVPパックで換算します。';

  @override
  String get storeShareShowRiotId => '画像にRiot IDを表示';

  @override
  String get storeShareShowRiotIdHint => 'プライバシー保護のため、初期設定ではオフです。';

  @override
  String get storeShareSubjectDaily => '私の今日のVALORANTストア';

  @override
  String get storeShareSubjectNightMarket => '私のVALORANTナイトマーケット';

  @override
  String get storeShareSubtitle => '選んだアプリでストアの画像をフレンドに共有できます。';

  @override
  String get storeTitle => 'ストア';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return '残高：$vp VP、$kc KC、$rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'ウィッシュリスト内 $n';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skinが$accountのストアに登場中 — 残り$left。',
      'other': '$skinが$accountのストアに登場中です。',
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
      'discount': '$skinが$percent%オフの$priceに（$account）。',
      'price': '$skinがたったの$price（$account）。',
      'other': '$skinが$accountのナイトマーケットに登場中です。',
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
      'yes': '$skinがバンドル「$bundle」に含まれています（$account）。',
      'other': '$skinが販売中のバンドルに含まれています（$account）。',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$namesほか$more個のスキンが$accountのストアに登場中です。',
      zero: '$namesが$accountのストアに登場中です。',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '、ウィッシュリストに追加済み',
      'other': '',
    });
    return '$name、$price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'スキンを追加';

  @override
  String get wishlistAddToWishlist => 'ウィッシュリストに追加';

  @override
  String get wishlistAllWeapons => 'すべての武器';

  @override
  String get wishlistBrowseCatalog => 'すべてのスキンを見る';

  @override
  String wishlistCatalogCount(String count) {
    return 'スキン$count個';
  }

  @override
  String get wishlistCatalogEmpty => 'スキン一覧を読み込めませんでした。更新してもう一度お試しください。';

  @override
  String get wishlistCatalogEmptyTitle => 'スキンはまだありません';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'ウィッシュリスト内 $count';
  }

  @override
  String get wishlistCatalogSubtitle => '♡をタップしてスキンをウィッシュリストに追加';

  @override
  String get wishlistCatalogTitle => 'すべてのスキン';

  @override
  String get wishlistChooseWeapon => '武器を選択';

  @override
  String get wishlistClearFilters => 'フィルター解除';

  @override
  String get wishlistClearSearch => '検索をクリア';

  @override
  String get wishlistEmpty => 'ウィッシュリストは空です。スキンの♡をタップすると追加できます。';

  @override
  String get wishlistEmptyTitle => 'スキンはまだありません';

  @override
  String wishlistEndsIn(String time) {
    return '終了まで$time';
  }

  @override
  String get wishlistExcludedRewards => '報酬スキンは含みません';

  @override
  String get wishlistFilterTiers => 'エディション';

  @override
  String wishlistFiltered(String count, String value) {
    return '絞り込み中：スキン$count個 · $value';
  }

  @override
  String get wishlistHasEstimates => '推定価格を含む（≈）';

  @override
  String get wishlistInWishlist => 'ウィッシュリストに追加済み';

  @override
  String get wishlistInWishlistLabel => 'ウィッシュリストに追加済み';

  @override
  String get wishlistNoMatch => '一致するスキンがありません。フィルターを解除するとさらに表示されます。';

  @override
  String get wishlistNoMatchTitle => 'スキンが見つかりません';

  @override
  String get wishlistNotifBundleTitle => 'ウィッシュリストのスキンを含む新しいバンドル';

  @override
  String get wishlistNotifDailyTitle => 'ウィッシュリストのスキンが登場しました！';

  @override
  String get wishlistNotifNightMarketTitle => 'ナイトマーケットにお気に入りのスキンが！';

  @override
  String get wishlistNotifPermissionMissing => 'アプリに通知の権限がありません。';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return 'ウィッシュリストのスキン$count個が販売中！';
  }

  @override
  String get wishlistNotifToggle => 'ウィッシュリストの通知';

  @override
  String get wishlistNotifToggleSubtitle => 'このアカウントが対象。アプリを開いていなくても通知します';

  @override
  String wishlistOfAccount(String riotId) {
    return '$riotIdのウィッシュリスト';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ウィッシュリストのスキン$count個が販売中！',
      one: 'ウィッシュリストのスキン1個が販売中！',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => 'マークの付いた行をタップするとオファーを確認できます。';

  @override
  String get wishlistOpenSettings => '設定を開く';

  @override
  String get wishlistOwned => '所持済み';

  @override
  String get wishlistRemoveAction => 'ウィッシュリストから削除';

  @override
  String get wishlistRemoveFromWishlist => 'ウィッシュリストから削除';

  @override
  String wishlistRemoved(String name) {
    return '$nameをウィッシュリストから削除しました';
  }

  @override
  String get wishlistSearchHint => 'スキンを検索…';

  @override
  String wishlistSkinCount(String count) {
    return 'スキン$count個';
  }

  @override
  String get wishlistSortBy => '並べ替え';

  @override
  String wishlistSortLabel(String sort) {
    return '並べ替え：$sort';
  }

  @override
  String get wishlistSortName => '名前';

  @override
  String get wishlistSortPrice => '価格';

  @override
  String get wishlistSortRarity => 'レア度';

  @override
  String get wishlistSortWeapon => '武器';

  @override
  String get wishlistStoreCheckTitle => 'ストアを確認できませんでした';

  @override
  String get wishlistSubtitle => '狙っているスキン';

  @override
  String get wishlistTitle => 'ウィッシュリスト';

  @override
  String get wishlistTotalValue => 'ウィッシュリストの合計額';

  @override
  String get wishlistUndo => '元に戻す';

  @override
  String get wishlistViewInStore => 'ストアで見る';

  @override
  String get wishlistWeapon => '武器';

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
      'yes': '、ウィッシュリスト内',
      'other': '',
    });
    return '$name、$price、$tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '、ウィッシュリスト内',
      'other': '',
    });
    return '$name、$votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': 'アップ',
      'other': 'ダウン',
    });
    return '今日は$rr RR$_temp0、$wins勝、$losses敗';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: '、$draws分',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: '、結果不明$unknown試合',
      zero: '',
    );
    return '$wins勝 – $losses敗$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => '「ホームをカスタマイズ」を開くと再表示できます。';

  @override
  String get homeAllHiddenTitle => 'すべてのカードを非表示にしています';

  @override
  String get homeCardBattlePass => 'バトルパス';

  @override
  String get homeCardBattlePassDesc => 'ティア、1日あたりの必要XP、ウィークリーミッション。';

  @override
  String get homeCardCommunity => 'コミュニティ';

  @override
  String get homeCardCommunityDesc => 'ランクの合うチームメイト募集と、今週人気のスキン。';

  @override
  String get homeCardFriends => 'プレイ中のフレンド';

  @override
  String get homeCardFriendsDesc => '試合中またはマッチング中のフレンド。';

  @override
  String homeCardHidden(String name) {
    return '「$name」を非表示にしました';
  }

  @override
  String get homeCardLive => '現在の試合';

  @override
  String get homeCardLiveDesc => 'マッチング中、エージェント選択中、試合中に表示されます。';

  @override
  String get homeCardOtherAccounts => 'その他のアカウント';

  @override
  String get homeCardOtherAccountsDesc => '他のアカウントの状態とウィッシュリスト。';

  @override
  String get homeCardRank => 'ランクと調子';

  @override
  String get homeCardRankDesc => 'ランク、今日のRR、連勝・連敗、ランクアップまでの試合数。';

  @override
  String get homeCardServerStatus => 'サーバーの状態';

  @override
  String get homeCardServerStatusDesc => 'メンテナンスや障害があるときのみ表示されます。';

  @override
  String get homeCardStore => '今日のストア';

  @override
  String get homeCardStoreDesc => 'デイリースキン、ウィッシュリスト、ナイトマーケット。';

  @override
  String get homeCustomize => 'ホームをカスタマイズ';

  @override
  String get homeCustomizeHint => 'ドラッグで並べ替え。オフにするとカードを非表示にします。';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return '$nameに移動しました';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name、$status';
  }

  @override
  String get homeFriendsConsentAllow => 'オンにする';

  @override
  String get homeFriendsConsentBody =>
      'プレイ中のフレンドを表示するため、ホームを開くたびにValHubが使用中アカウントのRiotチャットに接続します。フレンドにはあなたがオンラインと表示されます。「ホームをカスタマイズ」でオフにできます。';

  @override
  String get homeFriendsConsentDecline => 'いいえ、カードを非表示';

  @override
  String get homeFriendsConsentTitle => 'プレイ中のフレンドを表示しますか？';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n人のフレンドがプレイ中';
  }

  @override
  String get homeFriendsSeeAll => 'すべて表示';

  @override
  String get homeHideCard => 'このカードを非表示';

  @override
  String homeLeaderboard(String pos) {
    return 'リーダーボード$pos位';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return '残り$time';
  }

  @override
  String homeLfgNeeds(int n) {
    return '$n人募集';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author、$details';
  }

  @override
  String get homeLfgTitle => 'ランクの合うチームメイトを探す';

  @override
  String get homeLiveAllyLabel => '味方チーム';

  @override
  String get homeLiveEnemyLabel => '敵チーム';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'マッチング中、待ち時間$coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return '味方チーム $ally、敵チーム $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return 'コンペティティブ$n連敗';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n試合で$rankに到達';
  }

  @override
  String homeMoreActions(String name) {
    return '$nameのオプション';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return '$riotIdのストア、ランク、バトルパスを更新するには再度ログインしてください。端末に保存されたデータは引き続き閲覧できます。';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return '残り$time';
  }

  @override
  String get homeNightMarketNew => 'NEW';

  @override
  String get homeNightMarketTitle => 'ナイトマーケット';

  @override
  String homeNightMarketWaiting(int n) {
    return 'めくられるのを待っているオファー：$n枚';
  }

  @override
  String get homeNoRankedToday => '今日はまだコンペティティブをプレイしていません';

  @override
  String get homeOpenLfg => 'すべてのチームメイト募集を見る';

  @override
  String get homeOpenRanking => 'スキンランキングを見る';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'その他のアカウント（$n）';
  }

  @override
  String homeOtherMore(int n) {
    return '+$nアカウント';
  }

  @override
  String get homeOtherWishlistHit => 'ウィッシュリストのスキンあり';

  @override
  String homePreviousAct(String rank) {
    return '前ACT：$rank';
  }

  @override
  String get homeQuietBody => '下に引っ張って更新します。';

  @override
  String get homeQuietTitle => '新しい情報はありません';

  @override
  String homeRankToNext(int rr) {
    return 'ランクアップまであと$rr RR';
  }

  @override
  String get homeResetLayout => 'デフォルトに戻す';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day：$value';
  }

  @override
  String homeRrToday(String value) {
    return '今日 $value';
  }

  @override
  String get homeStatusDetails => '詳細';

  @override
  String homeStatusIncident(String region) {
    return 'サーバー障害 · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'メンテナンス中 · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'メンテナンス予定 · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n件のお知らせ';
  }

  @override
  String get homeStoreRefreshing => '更新中…';

  @override
  String homeStoreResetsIn(String time) {
    return '更新まで$time';
  }

  @override
  String homeStoreTotal(String vp) {
    return '合計 $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return '所持 $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return '所持 $vp · 最大$n個のスキンを購入可能';
  }

  @override
  String get homeStoreWishlistHit => 'ウィッシュリストのスキンあり！';

  @override
  String homeStoreWishlistHits(int n) {
    return 'ウィッシュリストのスキン$n個が販売中';
  }

  @override
  String get homeTitle => 'ホーム';

  @override
  String get homeTrendingTitle => '世界で人気のスキン';

  @override
  String homeTrendingVotes(int n) {
    return 'いいね$n件';
  }

  @override
  String get homeUndo => '元に戻す';

  @override
  String homeWinStreak(int n) {
    return 'コンペティティブ$n連勝';
  }

  @override
  String get communityErrorConsent => '続けるには、コミュニティとのRiot IDの共有に同意してください。';

  @override
  String get communityErrorForbidden =>
      'この操作はまだ行えません。コミュニティガイドラインを確認するか、ValHubにお問い合わせください。';

  @override
  String get communityErrorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get communityErrorImageTooLarge => '画像が大きすぎます（最大2 MB）。別の画像を選んでください。';

  @override
  String get communityErrorImageType => 'JPEG、PNG、WebPのいずれかの画像を選んでください。';

  @override
  String get communityErrorInvalid => '内容が受け付けられませんでした。確認してもう一度お試しください。';

  @override
  String get communityErrorNetwork =>
      'ValHubコミュニティに接続できません。ネットワークを確認してもう一度お試しください。';

  @override
  String get communityErrorNotFound => 'このコンテンツは存在しません。';

  @override
  String get communityErrorPickImage => 'フォトライブラリを開けませんでした。もう一度お試しください。';

  @override
  String get communityErrorRateLimited =>
      'コミュニティへのリクエストが集中しています。しばらくしてからもう一度お試しください。';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'コミュニティへのリクエストが集中しています。$duration後にもう一度お試しください。';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riotでアカウントを確認できませんでした。Riotアカウントに再度ログインしてから、もう一度お試しください。';

  @override
  String get communityErrorRiotUnavailable =>
      'Riotで問題が発生しています。しばらくしてからもう一度お試しください。';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riotで問題が発生しています。$duration後にもう一度お試しください。';
  }

  @override
  String get communityErrorServer =>
      'ValHubコミュニティで問題が発生しています。しばらくしてからもう一度お試しください。';

  @override
  String get communityErrorStorageFull =>
      'コミュニティの画像保存容量がいっぱいです。投稿はできますが、画像は添付できません。後でもう一度お試しください。';

  @override
  String get communityErrorTimeout => 'ValHubコミュニティの応答に時間がかかっています。もう一度お試しください。';

  @override
  String get communityErrorTitle => '完了できませんでした';

  @override
  String get communityErrorUnauthorized => 'コミュニティへの接続の期限が切れました。もう一度お試しください。';

  @override
  String get smokePlain => 'コード生成テスト';

  @override
  String smokeGreeting(String name) {
    return 'こんにちは、$nameさん！';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n件');
    return '$_temp0';
  }
}
