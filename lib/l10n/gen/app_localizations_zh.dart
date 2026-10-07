// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonListSeparator => '、';

  @override
  String get commonPriceSourceLabel => '查看价格来源';

  @override
  String get commonErrorApi => 'Riot 出现故障，请过几分钟再试。';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonBack => '返回';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClearFilters => '清除筛选';

  @override
  String get commonClearSearch => '清除搜索';

  @override
  String get commonClose => '关闭';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonCopied => '已复制';

  @override
  String get commonCopy => '复制';

  @override
  String get commonDaily => '每日';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n天';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n天前';
  }

  @override
  String get commonDelete => '删除';

  @override
  String get commonDone => '完成';

  @override
  String get commonEmptyGeneric => '这里还什么都没有。';

  @override
  String get commonErrorContentUnavailable => '无法加载皮肤、英雄和地图信息。请检查网络后重试。';

  @override
  String get commonErrorGeneric => '出了点问题，请重试。';

  @override
  String get commonErrorMaintenance => 'VALORANT 服务器正在维护，请稍后再来。';

  @override
  String get commonErrorNeedsLogin => '你的 Riot 登录已过期，请重新登录以继续。';

  @override
  String get commonErrorNeedsLoginTitle => '需要重新登录';

  @override
  String get commonErrorNetwork => '无法连接网络。请检查 Wi-Fi 或移动数据后重试。';

  @override
  String get commonErrorNoAccount => '你尚未登录任何账号。';

  @override
  String get commonErrorNotFound => '找不到此内容。';

  @override
  String get commonErrorTimeout => 'Riot 响应时间过长。请检查网络连接后重试。';

  @override
  String get commonErrorTransient => 'Riot 当前繁忙，请过几分钟再试。';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot 当前繁忙，请在$duration后重试。';
  }

  @override
  String get commonErrorUnsupportedRegion => '无法确定你的 Riot 区域。请在设置中选择区域。';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonFilter => '筛选';

  @override
  String get commonGoHome => '返回首页';

  @override
  String commonHours(int n) {
    return '$n小时';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n小时前';
  }

  @override
  String get commonIncidentTitle => '服务器故障';

  @override
  String get commonJustNow => '刚刚';

  @override
  String get commonLoadMore => '加载更多';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonMaintenanceTitle => '服务器维护';

  @override
  String commonMinutes(int n) {
    return '$n分钟';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n分钟前';
  }

  @override
  String get commonNoData => '暂无内容';

  @override
  String commonOfflineCached(String time) {
    return '网络未连接——正在显示已保存的数据（$time）。';
  }

  @override
  String get commonOk => '确定';

  @override
  String get commonOpenSettings => '打开设置';

  @override
  String get commonPageNotFound => '找不到此页面。';

  @override
  String commonPriceBestPack(String vp, String price) {
    return '最划算的礼包：$vp = $price';
  }

  @override
  String get commonPriceEditOwn => '修改你输入的价格';

  @override
  String get commonPriceEnterOwn => '输入你的 VP 礼包价格';

  @override
  String get commonPriceEstimateBody =>
      'VP 价格旁的“≈ …”金额是估算值，按最划算的 VP 礼包换算。你在游戏内使用 VP 支付；实际金额取决于购买时的礼包、支付渠道、税费和促销活动。';

  @override
  String get commonPriceEstimateTitle => '估算价格';

  @override
  String get commonPriceEstimateTooltip => '估算价格——点按查看计算方式';

  @override
  String get commonPriceHidden => '已隐藏估算价格。可在设置中重新开启。';

  @override
  String get commonPriceHide => '隐藏估算价格';

  @override
  String get commonPriceOpenSource => '打开来源页面';

  @override
  String get commonPriceOverrideBody =>
      '输入你购买一个 VP 礼包实际支付的金额（可在游戏商店或收据中查看）。ValHub 会用这个价格估算所有物品的价格；价格只保存在此设备上。';

  @override
  String get commonPriceOverrideCurrency => '货币代码';

  @override
  String get commonPriceOverrideCurrencyHint => '例如：CNY、USD、EUR、JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return '估算示例：$vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      '请输入 3 个字母的货币代码，例如 CNY 或 USD。';

  @override
  String get commonPriceOverrideInvalidNumber => '请输入大于 0 的数字。';

  @override
  String get commonPriceOverridePrice => '礼包价格';

  @override
  String get commonPriceOverrideRemove => '删除你输入的价格';

  @override
  String get commonPriceOverrideRemoved => '已删除你输入的价格。';

  @override
  String get commonPriceOverrideSave => '保存价格';

  @override
  String get commonPriceOverrideSaved => '已保存你的 VP 礼包价格。';

  @override
  String get commonPriceOverrideTitle => '你的 VP 礼包价格';

  @override
  String get commonPriceOverrideVp => '礼包 VP 数量';

  @override
  String get commonPricePacksTitle => 'VP 礼包';

  @override
  String commonPriceSourceOfficial(String country) {
    return '依据 $country 区域的 VP 礼包价格';
  }

  @override
  String get commonPriceSourceUser => '依据你输入的 VP 礼包价格';

  @override
  String get commonPriceUnavailable =>
      '你所在区域暂无经过核实的价格表。输入你买过的某个 VP 礼包的价格，即可查看估算价格。';

  @override
  String commonPriceUpdated(String date) {
    return '价格表更新于：$date';
  }

  @override
  String get commonPullToRefresh => '下拉刷新';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonRetry => '重试';

  @override
  String get commonRiotDisclaimer =>
      'ValHub 未获得 Riot Games 认可，不代表 Riot Games 或任何正式参与制作或管理 Riot Games 产品的人员的观点或意见。Riot Games 及所有相关资产均为 Riot Games, Inc. 的商标或注册商标。';

  @override
  String get commonSave => '保存';

  @override
  String get commonSearch => '搜索…';

  @override
  String commonSeconds(int n) {
    return '$n秒';
  }

  @override
  String get commonSeeAll => '查看全部';

  @override
  String get commonShare => '分享';

  @override
  String get commonSignInAgain => '重新登录';

  @override
  String get commonSort => '排序';

  @override
  String commonSortBy(String option) {
    return '排序：$option';
  }

  @override
  String get commonSortName => '名称 A–Z';

  @override
  String get commonSortNewest => '最新';

  @override
  String get commonSortPriceHigh => '价格从高到低';

  @override
  String get commonSortPriceLow => '价格从低到高';

  @override
  String get commonSortRarity => '稀有度';

  @override
  String get commonSortWeapon => '武器';

  @override
  String get commonTabBattlePass => '通行证';

  @override
  String get commonTabCollection => '收藏';

  @override
  String get commonTabCommunity => '社区';

  @override
  String get commonTabHome => '首页';

  @override
  String get commonTabProfile => '个人资料';

  @override
  String get commonTabSettings => '设置';

  @override
  String get commonTabStore => '商店';

  @override
  String get commonTagline => '你的 VALORANT 助手';

  @override
  String get commonToday => '今天';

  @override
  String get commonTodayLower => '今天';

  @override
  String get commonTomorrow => '明天';

  @override
  String get commonUnknownItem => '未知物品';

  @override
  String commonUpdatedAt(String time) {
    return '更新于 $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day $time';
  }

  @override
  String get commonWeekdaysItem0 => '星期一';

  @override
  String get commonWeekdaysItem1 => '星期二';

  @override
  String get commonWeekdaysItem2 => '星期三';

  @override
  String get commonWeekdaysItem3 => '星期四';

  @override
  String get commonWeekdaysItem4 => '星期五';

  @override
  String get commonWeekdaysItem5 => '星期六';

  @override
  String get commonWeekdaysItem6 => '星期日';

  @override
  String get commonYesterday => '昨天';

  @override
  String get commonYesterdayTitle => '昨天';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot 登录已过期——正在显示已保存的数据（$time）。';
  }

  @override
  String get contentCategoryHeavy => '重武器';

  @override
  String get contentCategoryMelee => '近战武器';

  @override
  String get contentCategoryRifle => '突击步枪';

  @override
  String get contentCategoryShotgun => '霰弹枪';

  @override
  String get contentCategorySidearm => '佩枪';

  @override
  String get contentCategorySmg => '冲锋枪';

  @override
  String get contentCategorySniper => '狙击枪';

  @override
  String get contentCurrencyAgentTokens => '英雄令牌';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => '王国币';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => '源晶点数';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => '无畏点券';

  @override
  String get contentDefaultSkin => '标准';

  @override
  String get contentItemAgent => '英雄';

  @override
  String get contentItemBuddy => '枪挂';

  @override
  String get contentItemCard => '玩家卡片';

  @override
  String get contentItemChroma => '炫彩';

  @override
  String get contentItemContract => '合约';

  @override
  String get contentItemCurrency => '货币';

  @override
  String get contentItemFlex => '展示道具';

  @override
  String get contentItemLanguageEn => '英语';

  @override
  String get contentItemLanguageTitle => '物品名称';

  @override
  String get contentItemLanguageVi => '越南语';

  @override
  String get contentItemLevelBorder => '等级边框';

  @override
  String get contentItemSkin => '皮肤';

  @override
  String get contentItemSpray => '喷漆';

  @override
  String get contentItemTitle => '玩家头衔';

  @override
  String contentLevel(int n) {
    return '等级 $n';
  }

  @override
  String get contentLevelBase => '基础';

  @override
  String get contentLevelItemLabelsVFX => '视觉特效';

  @override
  String get contentLevelItemLabelsAnimation => '动画';

  @override
  String get contentLevelItemLabelsFinisher => '终结特效';

  @override
  String get contentLevelItemLabelsKillCounter => '击杀计数器';

  @override
  String get contentLevelItemLabelsSoundEffects => '音效';

  @override
  String get contentLevelItemLabelsTransformation => '变形';

  @override
  String get contentLevelItemLabelsKillBanner => '击杀横幅';

  @override
  String get contentLevelItemLabelsKillEffect => '击杀特效';

  @override
  String get contentLevelItemLabelsInspectAndKill => '检视与击杀特效';

  @override
  String get contentLevelItemLabelsVoiceover => '配音';

  @override
  String get contentLevelItemLabelsSongShuffle => '随机切歌';

  @override
  String get contentLevelItemLabelsRandomizer => '随机化';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap => '攻守方切换';

  @override
  String get contentLevelItemLabelsTopFrag => '头号杀手特效';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor => '心跳与地图感应器';

  @override
  String get contentLevelItemLabelsFishAnimation => '鱼类动画';

  @override
  String get contentLimitedEdition => '限定版';

  @override
  String get contentNoSpray => '无';

  @override
  String get contentNoTitle => '无头衔';

  @override
  String get contentNotForSale => '非卖品';

  @override
  String get contentQueueNamesCompetitive => '竞技模式';

  @override
  String get contentQueueNamesUnrated => '普通模式';

  @override
  String get contentQueueNamesSwiftplay => '极速模式';

  @override
  String get contentQueueNamesSpikerush => '爆能快攻';

  @override
  String get contentQueueNamesDeathmatch => '乱斗模式';

  @override
  String get contentQueueNamesHurm => '团队乱斗';

  @override
  String get contentQueueNamesGgteam => '武装升级';

  @override
  String get contentQueueNamesOnefa => '克隆模式';

  @override
  String get contentQueueNamesPremier => '超级赛';

  @override
  String get contentQueueNamesCustom => '自定义游戏';

  @override
  String get contentQueueNames => '自定义游戏';

  @override
  String get contentQueueNamesDodgeball => '夺还模式';

  @override
  String get contentQueueNamesFortcollins => '回防模式';

  @override
  String get contentQueueNamesSkirmish2v2 => '斗牛：经典 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => '斗牛：晋升赛 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => '斗牛：晋升赛 2v2';

  @override
  String get contentQueueNamesValaram => '爆能大乱斗';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => '雪球大战';

  @override
  String get contentQueueNamesNewmap => '天枢云阙';

  @override
  String get contentQueueShortNamesCompetitive => '竞技';

  @override
  String get contentQueueShortNamesValaram => '大乱斗';

  @override
  String get contentRewardSourceAgent => '英雄合约';

  @override
  String get contentRewardSourceBattlePass => '通行证奖励';

  @override
  String get contentRewardSourceEvent => '活动通行证';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => '决斗';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => '先锋';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => '控场';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => '哨卫';

  @override
  String get contentTierDeluxe => '豪华';

  @override
  String get contentTierExclusive => '传奇';

  @override
  String contentTierFull(String shortName) {
    return '$shortName版';
  }

  @override
  String get contentTierPremium => '卓越';

  @override
  String get contentTierSelect => '精选';

  @override
  String get contentTierUltra => '终极';

  @override
  String get contentUnranked => '未定级';

  @override
  String get accountRegionUnknown => '未知区域';

  @override
  String accountRiotCountry(String country) {
    return 'Riot 账号所属国家/地区：$country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riot 账号所属国家/地区：未知';

  @override
  String accountAccountCount(int count, int max) {
    return '$count/$max 个账号';
  }

  @override
  String accountAccountsHeader(int count, int max) {
    return '账号（$count/$max）';
  }

  @override
  String get accountActive => '使用中';

  @override
  String accountAddAccount(int count, int max) {
    return '添加账号（$count/$max）';
  }

  @override
  String get accountClearLocalData => '清除本地数据';

  @override
  String get accountClearLocalDataConfirm => '要清除此设备上已登出账号的历史记录、已保存的配置和数据吗？';

  @override
  String get accountClearRrHistory => '清除 RR 记录';

  @override
  String get accountClearRrHistoryConfirm => '要清除此设备上所选账号的 RR 记录吗？';

  @override
  String get accountCopyPassword => '复制密码';

  @override
  String get accountCopyUsername => '复制用户名';

  @override
  String get accountDeleteLoginNote => '删除信息';

  @override
  String get accountDeleteLoginNoteConfirm => '要删除此账号已保存的用户名和密码吗？';

  @override
  String get accountHidePassword => '隐藏密码';

  @override
  String get accountKeepLocalData => '保留本地数据';

  @override
  String get accountKeepLocalDataHint => '在此设备上保留心愿单、配置和历史记录';

  @override
  String accountLevelShort(int level) {
    return '等级 $level';
  }

  @override
  String get accountLinkAccountMissing => '通知中的账号已登出。请重新登录后再打开通知。';

  @override
  String get accountLocalDataCleared => '已清除本地数据';

  @override
  String get accountLoginNote => '登录信息';

  @override
  String get accountLoginNoteDeleted => '已删除登录信息';

  @override
  String get accountLoginNoteEmpty => '尚未保存登录信息';

  @override
  String get accountLoginNoteHint => '仅保存在此设备上，并经过安全加密。可用于查看或在重新登录时快速填写。';

  @override
  String get accountLoginNoteLocked => '解锁登录信息';

  @override
  String get accountLoginNotePassword => '密码';

  @override
  String get accountLoginNoteSaved => '已保存登录信息';

  @override
  String get accountLoginNoteUsername => 'Riot 用户名';

  @override
  String get accountManageHint => '可在设置中删除账号或修改登录信息。';

  @override
  String accountMaxAccounts(int max) {
    return '已达到账号上限（$max 个）。';
  }

  @override
  String get accountNeedsLogin => '需要重新登录';

  @override
  String accountOnlineCount(int count) {
    return '$count 人在线';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => '填写已保存账号';

  @override
  String get accountQuickFillDone => '已填写完毕，请点按“登录”。';

  @override
  String get accountQuickFillNotReady => '登录页面尚未加载完成。请稍等片刻后重试。';

  @override
  String get accountQuickFillSubtitle => '选择要填入 Riot 登录页面的账号';

  @override
  String get accountQuickFillTitle => '填写已保存账号';

  @override
  String get accountRegionAp => '亚太';

  @override
  String get accountRegionBr => '巴西';

  @override
  String get accountRegionEu => '欧洲';

  @override
  String get accountRegionKr => '韩国';

  @override
  String get accountRegionLatam => '拉丁美洲';

  @override
  String get accountRegionNa => '北美';

  @override
  String get accountRemoveAccount => '删除账号';

  @override
  String accountRemoveAccountConfirm(String account) {
    return '要从此设备删除 $account 吗？你可以选择保留已保存的数据。';
  }

  @override
  String get accountRrHistoryCleared => '已清除 RR 记录';

  @override
  String get accountShowPassword => '显示密码';

  @override
  String get accountSignOutAll => '登出所有账号';

  @override
  String get accountSignOutAllConfirm => '要登出并从此设备删除所有账号吗？你可以选择保留已保存的数据。';

  @override
  String get accountStatusAgentSelect => '正在选择英雄';

  @override
  String get accountStatusInMatch => '对局中';

  @override
  String get accountStatusOffline => '离线';

  @override
  String get accountStatusOnline => '在线';

  @override
  String get accountStatusUnknown => '状态未知';

  @override
  String get accountSwitchFailed => '无法切换账号，请重试。';

  @override
  String accountSwitchTo(String account) {
    return '切换到 $account';
  }

  @override
  String get accountSwitcherSubtitle => '点按以切换账号';

  @override
  String get accountSwitcherTitle => '账号';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return '账号（$count/$max）';
  }

  @override
  String get accountUnknownPlayer => '玩家';

  @override
  String get accountUnlockLoginNote => '验证身份以查看 Riot 登录信息';

  @override
  String get authAccountAlreadyAdded => '此账号已添加';

  @override
  String get authAddAsNew => '添加为新账号';

  @override
  String get authDifferentAccountBody => '你登录的账号与需要重新登录的账号不同。要将此账号添加为新账号吗？';

  @override
  String get authDifferentAccountTitle => '不同的账号';

  @override
  String get authLoadingAccount => '正在加载账号…';

  @override
  String get authLoginCancelledByRiot => 'Riot 拒绝了本次登录，请重试。';

  @override
  String get authLoginFailed => '无法完成登录';

  @override
  String get authLoginFailedBody => 'Riot 尚未确认你的登录，请重试。';

  @override
  String get authLoginTitle => 'Riot 登录';

  @override
  String get authMissingCookies => '无法在此设备上保存登录状态，登录过期后你需要重新登录。';

  @override
  String get authOfficialHost => '官方页面 · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => '已在浏览器中打开链接。';

  @override
  String get authPageLoadFailed => '无法加载 Riot 登录页面。请检查网络后重试。';

  @override
  String get authPreparing => '正在准备登录页面…';

  @override
  String get authReloginDone => '已重新登录';

  @override
  String get authRememberMeHint => '请开启“保持登录状态”，以免需要重新登录。';

  @override
  String get authSignInCta => '使用 Riot 账号登录';

  @override
  String get authSignInNote =>
      '你将在 Riot 官方页面登录。只有在你选择保存登录信息时，ValHub 才会保存密码；登录数据和已保存的信息只存储在你的设备上。';

  @override
  String get authSocialLoginHint =>
      '如果使用 Google 或 Facebook 登录失败，请改用 Riot 用户名登录。';

  @override
  String get authStateMismatch => '本次登录无效，请从头重新登录。';

  @override
  String get notificationSessionExpiredBody => '重新登录即可继续接收心愿单通知。';

  @override
  String get notificationBackgroundTimingHint => '设备的省电模式可能会导致通知延迟。';

  @override
  String get notificationChannelAccountDescription => '账号需要重新登录时提醒你';

  @override
  String get notificationChannelAccountName => '账号';

  @override
  String get notificationChannelBattlePassDescription => '提醒通行证进度和结束日期';

  @override
  String get notificationChannelBattlePassName => '通行证';

  @override
  String get notificationChannelCommunityDescription => '打开 ValHub 时提醒社区动态';

  @override
  String get notificationChannelCommunityName => '社区';

  @override
  String get notificationChannelLfgDescription => '打开 ValHub 时提醒有玩家加入队伍';

  @override
  String get notificationChannelLfgName => '队伍';

  @override
  String get notificationChannelNightMarketDescription => '夜市开放时提醒你';

  @override
  String get notificationChannelNightMarketName => '夜市';

  @override
  String get notificationChannelRankDescription => '刷新个人资料时提醒段位变化';

  @override
  String get notificationChannelRankName => '段位';

  @override
  String get notificationChannelStoreResetDescription => '每日商店刷新时提醒你';

  @override
  String get notificationChannelStoreResetName => '商店刷新';

  @override
  String get notificationChannelWishlistDescription => '心愿单中的皮肤出现在商店时提醒你';

  @override
  String get notificationChannelWishlistName => '心愿单';

  @override
  String get notificationLfgJoinedTitle => '有玩家加入了你的队伍';

  @override
  String get notificationLocalOnlyHint => '仅在 ValHub 更新数据时于此设备上提醒';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return '$account的 $cards 张优惠卡牌等你翻开，快去看看。';
  }

  @override
  String get notificationNightMarketOpenTitle => '夜市已开放！';

  @override
  String get notificationPassEndingBody => '通行证还剩约一天。打开 ValHub 查看最新进度。';

  @override
  String get notificationPassEndingTitle => '通行证即将结束';

  @override
  String notificationPassProgressBody(int level) {
    return '你已在当前通行证中达到 $level 级。';
  }

  @override
  String get notificationPassProgressTitle => '通行证进度';

  @override
  String get notificationPrivateAccount => '你的账号';

  @override
  String notificationRankChangedBody(String rank) {
    return '当前段位：$rank。数据刚从 Riot 更新。';
  }

  @override
  String get notificationRankChangedTitle => '段位已变化';

  @override
  String get notificationResetTimingUnknown => '打开商店即可在你的设备上更新刷新时间。';

  @override
  String get notificationSessionExpiredTitle => '需要重新登录';

  @override
  String get notificationStoreResetBody => '商店里有新皮肤在等你。';

  @override
  String get competitiveDivisionIron => '黑铁';

  @override
  String get competitiveDivisionBronze => '青铜';

  @override
  String get competitiveDivisionSilver => '白银';

  @override
  String get competitiveDivisionGold => '黄金';

  @override
  String get competitiveDivisionPlatinum => '铂金';

  @override
  String get competitiveDivisionDiamond => '钻石';

  @override
  String get competitiveDivisionAscendant => '超凡';

  @override
  String get competitiveDivisionImmortal => '神话';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division$number';
  }

  @override
  String get competitiveDivisionRadiant => '源能战魂';

  @override
  String get competitiveRankUnknown => '段位未知';

  @override
  String get competitiveAttack => '进攻';

  @override
  String get competitiveCannotEstimate => '无法估算';

  @override
  String get competitiveDefeat => '失败';

  @override
  String get competitiveDefense => '防守';

  @override
  String get competitiveDraw => '平局';

  @override
  String get competitiveIncognitoPlayer => '隐藏玩家';

  @override
  String get competitiveMatchPending => 'Riot 正在处理此对局…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return '还剩$n场定级赛';
  }

  @override
  String get competitiveRoundDefuse => '拆除爆能器';

  @override
  String get competitiveRoundDetonate => '爆能器引爆';

  @override
  String get competitiveRoundElimination => '全歼';

  @override
  String get competitiveRoundSurrendered => '投降';

  @override
  String get competitiveRoundTimeExpired => '时间耗尽';

  @override
  String get competitiveUnknownPlayer => '玩家';

  @override
  String get competitiveVictory => '胜利';

  @override
  String economyAvailableNow(String place) {
    return '现已出现在$place！';
  }

  @override
  String get economyCollectionValue => '收藏价值';

  @override
  String get economyExcludedRewards => '不含奖励皮肤';

  @override
  String economyPlaceBundle(String name) {
    return '$name组合包';
  }

  @override
  String get economyPlaceBundleGeneric => '组合包';

  @override
  String get economyPlaceDaily => '每日商店';

  @override
  String get economyPlaceNightMarket => '夜市';

  @override
  String get economyPriceEstimated => '按版本估算的价格';

  @override
  String get economyPriceFromOffers => '价格来自 Riot 价格表';

  @override
  String get economyPriceFromStore => '在商店中看到的价格';

  @override
  String get economyPriceFromTable => '标价';

  @override
  String get economyPriceUnknown => '价格未知';

  @override
  String get economyValueHasEstimates => '含估算价格（≈）';

  @override
  String get economyWishlistValue => '心愿单总价值';

  @override
  String loadoutDefaultPresetName(int n) {
    return '配置$n';
  }

  @override
  String get loadoutInvalidChange => '此更改无法应用于当前配置。';

  @override
  String get loadoutNotPersisted => 'Riot 未保存你的更改，配置保持不变。请重试。';

  @override
  String get loadoutSaveFailed => '无法保存配置';

  @override
  String get battlePassActEnded => '本幕已结束';

  @override
  String battlePassActEndsIn(String time) {
    return '本幕将在$time后结束';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return '本幕将在$days天后结束';
  }

  @override
  String get battlePassAllMissionsDone => '已完成所有任务';

  @override
  String get battlePassAllWeeklyDone => '已完成所有每周任务';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return '待领取双倍奖励：$n';
  }

  @override
  String battlePassChapter(int n) {
    return '第$n章';
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
  String get battlePassCheckpoint => '检查点';

  @override
  String get battlePassCheckpointHint => '赢得回合即可推进检查点（乱斗模式不计入）。';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return '检查点$index：$charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => '每个检查点：+XP、+KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return '已达成 $done/$total 个检查点';
  }

  @override
  String get battlePassCurrentChapter => '当前';

  @override
  String get battlePassDailyAllDone => '今日检查点已全部完成';

  @override
  String get battlePassDailyCaption => '每日奖励';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return '每日奖励 · $reset';
  }

  @override
  String get battlePassDailyExpired => '前一天的检查点已过期。请进入游戏或在此刷新。';

  @override
  String get battlePassDailyMissions => '每日任务';

  @override
  String get battlePassDailyNotReady => '今日检查点尚未就绪。请进入游戏或在此刷新。';

  @override
  String get battlePassDailyPlayToStart => '今日检查点尚未就绪。请进入游戏开始新的一天。';

  @override
  String battlePassDaysLeft(int days) {
    return '还剩$days天';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return '结束时间：$wall';
  }

  @override
  String get battlePassEpilogue => '尾声';

  @override
  String get battlePassEstimateNote => '按每场约 4,000 XP 估算，不含任务。';

  @override
  String battlePassEventEndsIn(String time) {
    return '$time后结束';
  }

  @override
  String get battlePassEventPass => '活动通行证';

  @override
  String get battlePassFilterAll => '全部';

  @override
  String get battlePassFilterLocked => '未解锁';

  @override
  String get battlePassFilterUnlocked => '已解锁';

  @override
  String get battlePassFree => '免费';

  @override
  String get battlePassFreeTrack => '免费奖励';

  @override
  String battlePassLevelOf(String level, String count) {
    return '等级 $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return '等级 $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$queue约 $nString 场';
  }

  @override
  String get battlePassMissionDone => '已完成';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '已完成 $done/$total';
  }

  @override
  String get battlePassMissionsProgressLabel => '每周任务进度';

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return '新任务刷新时间：$wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return '$time后刷新新任务';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return '下一个检查点：$charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return '升至$level级';
  }

  @override
  String get battlePassNextReward => '下一个';

  @override
  String get battlePassNoBattlePass => '暂无本幕的通行证信息。请稍后再试。';

  @override
  String get battlePassNoRewards => '此通行证暂无奖励。';

  @override
  String get battlePassNoRewardsInFilter => '此分类中没有奖励。';

  @override
  String get battlePassNoRewardsTitle => '暂无奖励';

  @override
  String get battlePassNoWeeklyMissions => '目前没有每周任务。';

  @override
  String get battlePassPassComplete => '已完成通行证';

  @override
  String get battlePassPremium => '高级';

  @override
  String get battlePassPremiumHint =>
      '你尚未购买高级通行证：只能获得免费奖励。在游戏内购买高级通行证即可解锁已达到的等级。';

  @override
  String get battlePassRenewButton => '刷新检查点';

  @override
  String get battlePassRenewDone => '已刷新每日检查点。';

  @override
  String get battlePassRenewFailed => '无法刷新检查点。请稍后再试。';

  @override
  String battlePassResetsAtWall(String wall) {
    return '刷新时间：$wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return '$time后刷新';
  }

  @override
  String get battlePassRewardLevelLabel => '等级';

  @override
  String get battlePassRewardLocked => '未解锁';

  @override
  String get battlePassRewardNeedsPremium => '需要高级通行证';

  @override
  String get battlePassRewardStatusLabel => '状态';

  @override
  String get battlePassRewardTrackLabel => '奖励类型';

  @override
  String get battlePassRewardTypeLabel => '类型';

  @override
  String get battlePassRewardUnlocked => '已解锁';

  @override
  String get battlePassRewardsTitle => '奖励';

  @override
  String get battlePassShowAllRewards => '查看全部';

  @override
  String get battlePassTitle => '通行证';

  @override
  String get battlePassTotalXpCaption => '总 XP';

  @override
  String get battlePassUnknownMission => '新任务（暂无描述）';

  @override
  String get battlePassUnknownReward => '奖励';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '已解锁 $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => '普通模式';

  @override
  String get battlePassViewAllRewards => '查看全部奖励';

  @override
  String get battlePassWeeklyMissions => '每周任务';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return '每周任务还剩 +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / 天';
  }

  @override
  String get battlePassXpPerDayCaption => '每天所需 XP，以便按时完成';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return '还需 $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return '无法保存配置。$detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': '你拥有的所有皮肤，按商店价格计算价值',
      'buddy': '已拥有的枪挂及副本数量',
      'spray': '可添加到表情轮盘的喷漆',
      'card': '已解锁的玩家卡片，点按即可查看并装备',
      'title': '可显示在名字下方的玩家头衔',
      'flex': '已拥有的展示道具',
      'other': '浏览收藏',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return '位置：$position';
  }

  @override
  String get collectionApplyPreset => '应用';

  @override
  String get collectionApplyPresetBody => '当前使用的皮肤、枪挂、表情轮盘、卡片和头衔将被替换为此配置。';

  @override
  String collectionApplyPresetTitle(String name) {
    return '要应用“$name”吗？';
  }

  @override
  String get collectionBannerTitlePrefix => '头衔：';

  @override
  String get collectionBrowseBuddies => '枪挂';

  @override
  String get collectionBrowseCards => '玩家卡片';

  @override
  String get collectionBrowseEmpty => '你在此分类中还没有任何物品。';

  @override
  String get collectionBrowseEmptyTitle => '暂无物品';

  @override
  String get collectionBrowseFlex => '展示道具';

  @override
  String get collectionBrowseSkins => '皮肤';

  @override
  String get collectionBrowseSprays => '喷漆';

  @override
  String get collectionBrowseTitle => '浏览收藏';

  @override
  String get collectionBrowseTitles => '玩家头衔';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return '剩余 $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return '用于$weapon';
  }

  @override
  String get collectionBuddyPickerTitle => '选择枪挂';

  @override
  String get collectionBuddyRemoved => '已移除枪挂';

  @override
  String get collectionBuddySlot => '枪挂';

  @override
  String get collectionBuddyUnavailable => '无法挂上此枪挂。请刷新或选择其他枪挂。';

  @override
  String get collectionCachedLoadout => '正在显示已保存的配置。更改前请下拉刷新。';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已拥有 $nString 张卡片';
  }

  @override
  String get collectionChangeBuddy => '更换';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total 款炫彩';
  }

  @override
  String get collectionClearFilters => '清除筛选';

  @override
  String get collectionClearSearch => '清除搜索';

  @override
  String get collectionClearTiers => '清除版本筛选';

  @override
  String get collectionCollectionValue => '收藏价值';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => '标准';

  @override
  String get collectionDeletePreset => '删除';

  @override
  String get collectionEmptySlot => '空';

  @override
  String get collectionEquip => '装备';

  @override
  String get collectionEquipped => '已装备';

  @override
  String get collectionEquippedCard => '已装备卡片';

  @override
  String collectionEquippedCardLabel(String name) {
    return '已装备卡片：$name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '已装备$name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return '已装备：$skin';
  }

  @override
  String get collectionExcludedRewards => '不含奖励皮肤';

  @override
  String get collectionExpressionsHint => '点按一个位置以选择喷漆或展示道具。';

  @override
  String get collectionExpressionsSlots => '轮盘位置';

  @override
  String get collectionExpressionsTitle => '表情轮盘';

  @override
  String get collectionFilterTiers => '版本';

  @override
  String get collectionHideAccountLevel => '隐藏账号等级';

  @override
  String get collectionHideAccountLevelHint => '其他玩家将看不到你的账号等级。';

  @override
  String get collectionIncognito => '隐身模式';

  @override
  String get collectionIncognitoHint => '在对局中向非队友玩家隐藏你的名字。';

  @override
  String collectionItemsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 件物品';
  }

  @override
  String get collectionLevelBorderAuto => '随等级自动切换';

  @override
  String get collectionLevelBorderEmpty => '你的等级暂无可用的等级边框。';

  @override
  String collectionLevelBorderFrom(int level) {
    return '$level级起';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return '账号等级 $level';
  }

  @override
  String get collectionLevelBorderTitle => '选择等级边框';

  @override
  String collectionLevelCount(int owned, int total) {
    return '等级 $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return '等级 $n · $type';
  }

  @override
  String get collectionLevels => '等级';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '已解锁 $owned/$total 级';
  }

  @override
  String get collectionLobbyBanner => '大厅横幅';

  @override
  String get collectionLocked => '未解锁';

  @override
  String get collectionMeleeNoBuddy => '近战武器无法挂枪挂。';

  @override
  String get collectionMove => '移动';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy目前挂在$from上。要移到$to吗？';
  }

  @override
  String get collectionMoveBuddyTitle => '要移动枪挂吗？';

  @override
  String get collectionNoBuddies => '你还没有任何枪挂。';

  @override
  String get collectionNoBuddy => '未挂枪挂';

  @override
  String get collectionNoFlex => '你还没有任何展示道具。';

  @override
  String get collectionNoResults => '没有找到匹配的结果。';

  @override
  String get collectionNoResultsTitle => '未找到';

  @override
  String get collectionNoSkinsForWeapon => '你还没有这把武器的皮肤。';

  @override
  String get collectionNoSprays => '你还没有任何喷漆。';

  @override
  String get collectionNoTitle => '无头衔';

  @override
  String get collectionOtherWeapons => '其他';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '已拥有$n款皮肤',
      zero: '暂无皮肤',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已拥有 $nString 款皮肤';
  }

  @override
  String get collectionPlayLevelVideo => '观看此等级视频';

  @override
  String get collectionPlayVideo => '观看视频';

  @override
  String get collectionPlayerCardSubtitle => '显示在大厅、计分板以及你击杀敌人时。';

  @override
  String get collectionPlayerCardTitle => '更换玩家卡片';

  @override
  String get collectionPlayerTitleSubtitle => '显示在大厅和对局中你的名字下方。';

  @override
  String get collectionPlayerTitleTitle => '更换玩家头衔';

  @override
  String get collectionPresetActions => '选项';

  @override
  String collectionPresetApplied(String name) {
    return '已应用“$name”';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n套',
      zero: '暂无',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '已删除“$name”';
  }

  @override
  String get collectionPresetNameHint => '例如：冲分';

  @override
  String get collectionPresetNameTitle => '配置名称';

  @override
  String collectionPresetSaved(String name) {
    return '已保存“$name”';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return '保存于$date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return '已跳过$n件你不再拥有的物品。';
  }

  @override
  String get collectionPresetsEmpty => '保存当前配置，以后可在不同的皮肤、卡片和表情轮盘组合之间快速切换。';

  @override
  String get collectionPresetsEmptyTitle => '暂无已保存的配置';

  @override
  String get collectionPresetsFull => '已达到 50 套配置的上限。请删除一些后再保存。';

  @override
  String get collectionPresetsNote => '配置仅保存在此设备上，且仅适用于所选账号。';

  @override
  String get collectionPresetsTitle => '已保存的配置';

  @override
  String get collectionPreview => '预览';

  @override
  String get collectionPreviewing => '预览中';

  @override
  String get collectionRemoveBuddy => '移除枪挂';

  @override
  String get collectionRenamePreset => '重命名';

  @override
  String get collectionRowCard => '玩家卡片';

  @override
  String get collectionRowExpressions => '表情轮盘';

  @override
  String get collectionRowLevelBorder => '等级边框';

  @override
  String get collectionRowPresets => '已保存的配置';

  @override
  String get collectionRowTitle => '玩家头衔';

  @override
  String get collectionRowWeapons => '武器配置';

  @override
  String get collectionRowWishlist => '心愿单';

  @override
  String get collectionSaveFailed => '无法保存配置';

  @override
  String get collectionSavePreset => '保存当前配置';

  @override
  String get collectionSaving => '保存中…';

  @override
  String get collectionSearchBuddies => '搜索枪挂…';

  @override
  String get collectionSearchCards => '搜索玩家卡片…';

  @override
  String get collectionSearchFlex => '搜索展示道具…';

  @override
  String get collectionSearchItems => '搜索…';

  @override
  String get collectionSearchSkins => '搜索皮肤…';

  @override
  String get collectionSearchSprays => '搜索喷漆…';

  @override
  String get collectionSearchTitles => '搜索头衔…';

  @override
  String get collectionSearchWeapons => '搜索武器、皮肤或枪挂…';

  @override
  String get collectionSectionBrowse => '浏览收藏';

  @override
  String get collectionSectionIdentity => '其他玩家可见';

  @override
  String get collectionSectionLoadout => '配置';

  @override
  String get collectionSkinCustomizeTitle => '自定义皮肤';

  @override
  String get collectionSkinNotFound => '找不到此皮肤。';

  @override
  String get collectionSkinNotOwned => '你尚未拥有此皮肤。';

  @override
  String get collectionSlotNamesItem0 => '上';

  @override
  String get collectionSlotNamesItem1 => '右';

  @override
  String get collectionSlotNamesItem2 => '下';

  @override
  String get collectionSlotNamesItem3 => '左';

  @override
  String get collectionSortLabel => '排序';

  @override
  String get collectionSortName => '名称';

  @override
  String get collectionSortPrice => '价格';

  @override
  String get collectionSortRarity => '稀有度';

  @override
  String get collectionSortWeapon => '武器';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return '已筛选：$count款皮肤 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return '已筛选：$count/$total 件物品';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count件物品';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count款皮肤 · $value';
  }

  @override
  String get collectionTabFlex => '展示道具';

  @override
  String get collectionTabSprays => '喷漆';

  @override
  String get collectionTapToChangeCard => '点按更换卡片';

  @override
  String get collectionTitle => '收藏';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已拥有 $nString 个头衔';
  }

  @override
  String get collectionUndo => '撤销';

  @override
  String get collectionUnknownCard => '未知卡片';

  @override
  String get collectionValueAtStorePrices => '按商店价格计算';

  @override
  String get collectionValueHasEstimates => '含估算价格（≈）';

  @override
  String collectionValueRewardCount(int n) {
    return '$n款奖励皮肤未计入';
  }

  @override
  String get collectionValueSeeSkins => '查看皮肤';

  @override
  String collectionValueSkinCount(int n) {
    return '基于$n款皮肤计算';
  }

  @override
  String get collectionVariants => '炫彩';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total 把武器使用了皮肤';
  }

  @override
  String get collectionWeaponLoadoutTitle => '武器配置';

  @override
  String get collectionWeaponNotFound => '找不到此武器。';

  @override
  String get collectionWeaponSkinsTitle => '选择皮肤';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n款皮肤',
      zero: '空',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate => '内容包含不当用语，无法发布。请修改后重试。';

  @override
  String get communityModerationContentScam =>
      '社区不允许发布买卖账号、代练或留电话号码的广告。请删除这些内容后重试。';

  @override
  String get communityModerationContentTooComplex => '内容包含过多零散字符。请写得简洁一些后重试。';

  @override
  String get communityModerationAccountBanned =>
      '此账号已被禁止使用社区。如果你认为有误，请在“关于与法律信息”中联系 ValHub。';

  @override
  String get communityModerationAccountRestricted =>
      '此账号目前被限制发帖、评论、寻找队友和投票。请稍后再试，或在“关于与法律信息”中联系 ValHub。';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': '竞技模式',
      'unrated': '普通模式',
      'swiftplay': '极速模式',
      'spikerush': '爆能快攻',
      'deathmatch': '乱斗模式',
      'teamdeathmatch': '团队乱斗',
      'premier': '超级赛',
      'custom': '自定义游戏',
      'other': '其他',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': '亚太',
      'na': '北美',
      'eu': '欧洲',
      'kr': '韩国',
      'latam': '拉丁美洲',
      'br': '巴西',
      'other': '未知区域',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => '此排行榜中暂无皮肤';

  @override
  String get communityRankingEmptyVotes => '暂无符合所选范围和筛选条件的喜爱记录。';

  @override
  String get communityRankingEmptyRatings => '暂无符合所选范围和筛选条件的星级评分。';

  @override
  String get communityRankingEmptyReviews => '暂无符合所选范围和筛选条件的评价。';

  @override
  String get communityRankingExplore => '查找皮肤以查看和评分';

  @override
  String get communityRankingExploreHint => '按皮肤或武器名称搜索。只有社区的真实评分才会出现在排行榜中。';

  @override
  String get communityRankingClear => '清除武器和时间筛选';

  @override
  String get communityRankingPeriod => '时间';

  @override
  String get communityRankingSort => '排名依据';

  @override
  String get communityRankingWeapon => '武器';

  @override
  String get communityRankingNoSearch => '没有找到匹配的皮肤。请尝试其他名称或清除武器筛选。';

  @override
  String get communityRankingCatalogUnavailable => '无法加载皮肤列表。请关闭此面板，待数据同步后重试。';

  @override
  String get communityConsentExitAccount => '不同意 · 登出此账号';

  @override
  String get communityRankingGlobalAllTime => '全球 · 历史总榜';

  @override
  String get communityRankingCatalogTitle => '全部皮肤';

  @override
  String get communityReviewOwnershipRequired => '账号必须拥有此皮肤才能评分。你仍可查看社区的评分和评论。';

  @override
  String get communityReviewOwnershipUnavailable =>
      '无法验证你是否拥有此皮肤。请重新加载收藏，或在联网后重试。';

  @override
  String get communityReviewLegacyOwnership => '旧评价 · 未验证拥有权';

  @override
  String get communityReviewVerifiedOwner => '评价时已验证拥有此皮肤';

  @override
  String get communitySkinDiscussionHint => '所有人都可以评论。只有皮肤拥有者才能评星和撰写评价。';

  @override
  String get communityAddPhotos => '添加图片';

  @override
  String get communityAgentsPicked => '已选英雄';

  @override
  String get communityAllModes => '全部';

  @override
  String get communityAllWeapons => '全部武器';

  @override
  String get communityAnonymousBanner => '正在匿名浏览';

  @override
  String get communityAnyLanguage => '任何语言';

  @override
  String get communityAnyRank => '任何段位';

  @override
  String get communityAnyRole => '任何职业';

  @override
  String get communityApply => '应用';

  @override
  String get communityAutoRefresh => '每 20 秒自动刷新';

  @override
  String get communityBackToMyCountry => '返回我的国家/地区';

  @override
  String get communityBlockAuthor => '在此设备上屏蔽';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => '清除';

  @override
  String get communityCodeAuto => '留空：发布时 ValHub 会根据你的游戏内队伍自动生成队伍码。';

  @override
  String get communityCodeAutoFailed => '无法生成队伍码。请打开 VALORANT 或手动输入队伍码。';

  @override
  String get communityCodeGenerated => '已根据你当前的队伍生成队伍码。';

  @override
  String get communityCodeInvalid => '队伍码必须为 6 位大写字母或数字。';

  @override
  String get communityCodeRequired => '请输入或生成队伍码。';

  @override
  String get communityComment => '评论';

  @override
  String get communityCommentHint => '写评论…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 条评论';
  }

  @override
  String communityCommentsHeader(String n) {
    return '评论 · $n';
  }

  @override
  String get communityCommentsTitle => '评论';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '帖子：$posts · 玩家：$authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 条组队帖';
  }

  @override
  String get communityCommunityVotes => '社区最爱';

  @override
  String get communityComposerHint => '今天你对 VALORANT 有什么想法？';

  @override
  String get communityComposerTitle => '新帖子';

  @override
  String communityConsentAccount(String riotId) {
    return '账号：$riotId';
  }

  @override
  String get communityConsentAgree => '同意并继续';

  @override
  String get communityConsentGateAction => '加入';

  @override
  String get communityConsentGuidelines => '社区准则';

  @override
  String get communityConsentLater => '稍后';

  @override
  String get communityConsentLocal => '你的密码和其他登录数据始终保留在此设备上。你可以在设置中撤回同意。';

  @override
  String get communityConsentPrivacy => '隐私政策';

  @override
  String get communityConsentPublic => '其他人将看到你的 Riot ID、玩家卡片、段位和国家/地区。';

  @override
  String get communityConsentTitle => '隐私与 ValHub 社区';

  @override
  String get communityConsentVerify =>
      'ValHub 会将你的 Riot 访问权限发送给社区服务器，用于在连接时验证 Riot ID，以及在你保存评价时检查皮肤拥有权。服务器只读取必要的数据，用完立即丢弃访问权限，不会保存。';

  @override
  String get communityConsentWithdrawn => '已撤回同意。需要重新同意才能继续使用本应用。';

  @override
  String get communityCountriesEmpty => '没有找到匹配的国家/地区。';

  @override
  String get communityCountriesSearchHint => '搜索国家/地区…';

  @override
  String get communityCountriesTitle => '各国家/地区社区';

  @override
  String get communityCountryNamesAE => '阿联酋';

  @override
  String get communityCountryNamesAL => '阿尔巴尼亚';

  @override
  String get communityCountryNamesAM => '亚美尼亚';

  @override
  String get communityCountryNamesAR => '阿根廷';

  @override
  String get communityCountryNamesAT => '奥地利';

  @override
  String get communityCountryNamesAU => '澳大利亚';

  @override
  String get communityCountryNamesAZ => '阿塞拜疆';

  @override
  String get communityCountryNamesBA => '波黑';

  @override
  String get communityCountryNamesBD => '孟加拉国';

  @override
  String get communityCountryNamesBE => '比利时';

  @override
  String get communityCountryNamesBG => '保加利亚';

  @override
  String get communityCountryNamesBH => '巴林';

  @override
  String get communityCountryNamesBN => '文莱';

  @override
  String get communityCountryNamesBO => '玻利维亚';

  @override
  String get communityCountryNamesBR => '巴西';

  @override
  String get communityCountryNamesBY => '白俄罗斯';

  @override
  String get communityCountryNamesCA => '加拿大';

  @override
  String get communityCountryNamesCH => '瑞士';

  @override
  String get communityCountryNamesCL => '智利';

  @override
  String get communityCountryNamesCN => '中国';

  @override
  String get communityCountryNamesCO => '哥伦比亚';

  @override
  String get communityCountryNamesCR => '哥斯达黎加';

  @override
  String get communityCountryNamesCU => '古巴';

  @override
  String get communityCountryNamesCY => '塞浦路斯';

  @override
  String get communityCountryNamesCZ => '捷克';

  @override
  String get communityCountryNamesDE => '德国';

  @override
  String get communityCountryNamesDK => '丹麦';

  @override
  String get communityCountryNamesDO => '多米尼加';

  @override
  String get communityCountryNamesDZ => '阿尔及利亚';

  @override
  String get communityCountryNamesEC => '厄瓜多尔';

  @override
  String get communityCountryNamesEE => '爱沙尼亚';

  @override
  String get communityCountryNamesEG => '埃及';

  @override
  String get communityCountryNamesES => '西班牙';

  @override
  String get communityCountryNamesET => '埃塞俄比亚';

  @override
  String get communityCountryNamesFI => '芬兰';

  @override
  String get communityCountryNamesFR => '法国';

  @override
  String get communityCountryNamesGB => '英国';

  @override
  String get communityCountryNamesGE => '格鲁吉亚';

  @override
  String get communityCountryNamesGH => '加纳';

  @override
  String get communityCountryNamesGR => '希腊';

  @override
  String get communityCountryNamesGT => '危地马拉';

  @override
  String get communityCountryNamesHK => '香港';

  @override
  String get communityCountryNamesHN => '洪都拉斯';

  @override
  String get communityCountryNamesHR => '克罗地亚';

  @override
  String get communityCountryNamesHU => '匈牙利';

  @override
  String get communityCountryNamesID => '印度尼西亚';

  @override
  String get communityCountryNamesIE => '爱尔兰';

  @override
  String get communityCountryNamesIL => '以色列';

  @override
  String get communityCountryNamesIN => '印度';

  @override
  String get communityCountryNamesIQ => '伊拉克';

  @override
  String get communityCountryNamesIR => '伊朗';

  @override
  String get communityCountryNamesIS => '冰岛';

  @override
  String get communityCountryNamesIT => '意大利';

  @override
  String get communityCountryNamesJO => '约旦';

  @override
  String get communityCountryNamesJP => '日本';

  @override
  String get communityCountryNamesKE => '肯尼亚';

  @override
  String get communityCountryNamesKH => '柬埔寨';

  @override
  String get communityCountryNamesKR => '韩国';

  @override
  String get communityCountryNamesKW => '科威特';

  @override
  String get communityCountryNamesKZ => '哈萨克斯坦';

  @override
  String get communityCountryNamesLA => '老挝';

  @override
  String get communityCountryNamesLB => '黎巴嫩';

  @override
  String get communityCountryNamesLK => '斯里兰卡';

  @override
  String get communityCountryNamesLT => '立陶宛';

  @override
  String get communityCountryNamesLU => '卢森堡';

  @override
  String get communityCountryNamesLV => '拉脱维亚';

  @override
  String get communityCountryNamesLY => '利比亚';

  @override
  String get communityCountryNamesMA => '摩洛哥';

  @override
  String get communityCountryNamesMD => '摩尔多瓦';

  @override
  String get communityCountryNamesME => '黑山';

  @override
  String get communityCountryNamesMK => '北马其顿';

  @override
  String get communityCountryNamesMM => '缅甸';

  @override
  String get communityCountryNamesMN => '蒙古';

  @override
  String get communityCountryNamesMO => '澳门';

  @override
  String get communityCountryNamesMT => '马耳他';

  @override
  String get communityCountryNamesMX => '墨西哥';

  @override
  String get communityCountryNamesMY => '马来西亚';

  @override
  String get communityCountryNamesNG => '尼日利亚';

  @override
  String get communityCountryNamesNI => '尼加拉瓜';

  @override
  String get communityCountryNamesNL => '荷兰';

  @override
  String get communityCountryNamesNO => '挪威';

  @override
  String get communityCountryNamesNP => '尼泊尔';

  @override
  String get communityCountryNamesNZ => '新西兰';

  @override
  String get communityCountryNamesOM => '阿曼';

  @override
  String get communityCountryNamesPA => '巴拿马';

  @override
  String get communityCountryNamesPE => '秘鲁';

  @override
  String get communityCountryNamesPH => '菲律宾';

  @override
  String get communityCountryNamesPK => '巴基斯坦';

  @override
  String get communityCountryNamesPL => '波兰';

  @override
  String get communityCountryNamesPR => '波多黎各';

  @override
  String get communityCountryNamesPT => '葡萄牙';

  @override
  String get communityCountryNamesPY => '巴拉圭';

  @override
  String get communityCountryNamesQA => '卡塔尔';

  @override
  String get communityCountryNamesRO => '罗马尼亚';

  @override
  String get communityCountryNamesRS => '塞尔维亚';

  @override
  String get communityCountryNamesRU => '俄罗斯';

  @override
  String get communityCountryNamesSA => '沙特阿拉伯';

  @override
  String get communityCountryNamesSE => '瑞典';

  @override
  String get communityCountryNamesSG => '新加坡';

  @override
  String get communityCountryNamesSI => '斯洛文尼亚';

  @override
  String get communityCountryNamesSK => '斯洛伐克';

  @override
  String get communityCountryNamesSV => '萨尔瓦多';

  @override
  String get communityCountryNamesTH => '泰国';

  @override
  String get communityCountryNamesTL => '东帝汶';

  @override
  String get communityCountryNamesTN => '突尼斯';

  @override
  String get communityCountryNamesTR => '土耳其';

  @override
  String get communityCountryNamesTW => '台湾';

  @override
  String get communityCountryNamesUA => '乌克兰';

  @override
  String get communityCountryNamesUS => '美国';

  @override
  String get communityCountryNamesUY => '乌拉圭';

  @override
  String get communityCountryNamesUZ => '乌兹别克斯坦';

  @override
  String get communityCountryNamesVE => '委内瑞拉';

  @override
  String get communityCountryNamesVN => '越南';

  @override
  String get communityCountryNamesZA => '南非';

  @override
  String get communityCreateLfg => '发布组队帖';

  @override
  String get communityCreateLfgShort => '发帖';

  @override
  String get communityDataDeleted => '已删除你的社区数据。';

  @override
  String communityDataFooter(String riotId) {
    return '适用于当前账号：$riotId。下载的文件不包含你的密码或 Riot 登录数据。';
  }

  @override
  String get communityDataTitle => '你的社区数据';

  @override
  String get communityDecrease => '减少';

  @override
  String get communityDelete => '删除';

  @override
  String get communityDeleteComment => '删除评论';

  @override
  String get communityDeleteCommentBody => '此评论将被永久删除。';

  @override
  String get communityDeleteCommentTitle => '要删除评论吗？';

  @override
  String get communityDeleteDataConfirm => '永久删除';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return '$riotId在 ValHub 社区的所有帖子、评论、皮肤评价、点赞、投票、组队帖和图片都将被永久删除，且无法恢复。你将回到匿名浏览模式，如需再次加入需要重新同意。\n\n你的 Riot 账号和游戏内数据不受影响。如果想保留副本，请先下载你的数据。';
  }

  @override
  String get communityDeleteDataConfirmTitle => '要删除社区数据吗？';

  @override
  String get communityDeleteDataSubtitle => '永久删除你在社区发布的所有内容。';

  @override
  String get communityDeleteDataTitle => '删除我的社区数据';

  @override
  String get communityDeletePost => '删除帖子';

  @override
  String get communityDeletePostBody => '帖子及其所有评论将被永久删除。';

  @override
  String get communityDeletePostTitle => '要删除帖子吗？';

  @override
  String get communityDeleteReview => '删除评价';

  @override
  String get communityDeleteReviewBody => '你对此皮肤的评分和评价将被删除。';

  @override
  String get communityDeleteReviewTitle => '要删除你的评价吗？';

  @override
  String get communityDeleted => '已删除。';

  @override
  String get communityDiscard => '放弃';

  @override
  String get communityDiscardBody => '你刚才写的内容将不会被保存。';

  @override
  String get communityDiscardTitle => '要放弃此帖子吗？';

  @override
  String get communityDownload => '下载并翻译';

  @override
  String get communityDownloadingModels => '正在下载语言包…';

  @override
  String get communityEditReview => '编辑';

  @override
  String get communityEdited => '已编辑';

  @override
  String get communityEmptyPost => '请写点什么或添加图片。';

  @override
  String get communityExpired => '已过期';

  @override
  String communityExpiresIn(String t) {
    return '剩余$t';
  }

  @override
  String get communityExportPreparing => '正在准备…';

  @override
  String get communityExportSubject => 'ValHub 社区数据';

  @override
  String get communityExportSubtitle => '你在社区发布的所有内容的副本：帖子、评论、评价、点赞、投票和组队帖。';

  @override
  String get communityExportTitle => '下载我的数据';

  @override
  String get communityExtend => '延长';

  @override
  String get communityExtended => '已将帖子延长 30 分钟。';

  @override
  String get communityFeedEmptyBody => '快来第一个分享你的商店、夜市或精彩瞬间吧！';

  @override
  String get communityFeedEmptyFilteredBody => '没有符合条件的帖子。请尝试更换语言或清除筛选。';

  @override
  String get communityFeedEmptyGuestBody => '暂无新帖子。稍后再来看看，或加入社区参与分享。';

  @override
  String get communityFeedEmptyScopeBody => '试试查看国际社区的帖子，或更改筛选条件。';

  @override
  String get communityFeedEmptyScopeTitle => '此范围内暂无帖子';

  @override
  String get communityFeedEmptyTitle => '动态还是空的';

  @override
  String get communityFilters => '筛选';

  @override
  String get communityGenerateCode => '生成队伍码';

  @override
  String get communityGeneratingCode => '正在生成队伍码…';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => '由 Google 翻译';

  @override
  String get communityHelpful => '有帮助';

  @override
  String communityHelpfulCount(String n) {
    return '有帮助 · $n';
  }

  @override
  String get communityHiddenAuthors => '已隐藏和屏蔽的玩家';

  @override
  String get communityHiddenAuthorsEmpty => '你还没有隐藏或屏蔽任何人';

  @override
  String get communityHiddenAuthorsHint =>
      '仅对此设备上的此账号生效。他们的内容将被隐藏；他们仍可看到你的公开内容。';

  @override
  String communityImageOf(int i, int n) {
    return '图片 $i/$n';
  }

  @override
  String get communityIncrease => '增加';

  @override
  String get communityJoin => '加入';

  @override
  String get communityJoinCodeExpired => '队伍码已过期或已失效。';

  @override
  String communityJoinConfirmBody(String name) {
    return '你将离开当前的 VALORANT 队伍，加入$name的队伍。';
  }

  @override
  String get communityJoinConfirmTitle => '要加入这个队伍吗？';

  @override
  String get communityJoinGameNotRunning => '请在电脑或主机上打开 VALORANT 后重试。';

  @override
  String get communityJoinInvalidCode => '队伍码已失效或队伍已满员。';

  @override
  String get communityJoinParty => '加入队伍';

  @override
  String get communityJoinPartyFull => '此队伍已满员。';

  @override
  String get communityJoined => '已加入队伍！打开 VALORANT 一起游戏吧。';

  @override
  String get communityJoinedHint => '已加入队伍！打开 VALORANT 一起游戏吧。';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 人申请加入';
  }

  @override
  String get communityKeepEditing => '继续编辑';

  @override
  String get communityKindNightMarket => '夜市';

  @override
  String get communityKindStore => '今日商店';

  @override
  String get communityLanguage => '语言';

  @override
  String get communityLanguageFilter => '内容语言';

  @override
  String get communityLanguageFilterHint => '只显示用所选语言撰写的内容。留空则显示全部。';

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
    return '$n种语言';
  }

  @override
  String get communityLfgEmptyBody => '发布组队帖，其他玩家只需点按一下即可加入你的队伍。';

  @override
  String get communityLfgEmptyTitle => '还没有人在寻找队友';

  @override
  String get communityLfgExpiredRepost => '你的帖子已过期。请发布新帖寻找队友。';

  @override
  String get communityLfgExpiryNote => '帖子将在 30 分钟后自动过期。';

  @override
  String get communityLfgGateBody =>
      '加入社区（只需验证一次 Riot ID）即可查看同服务器玩家的组队帖并发布你自己的组队帖。你仍可照常浏览动态和皮肤排行。';

  @override
  String get communityLfgGateTitle => '寻找队友仅限成员使用';

  @override
  String communityLfgOtherShardNote(String region) {
    return '你正在查看$region服务器——只有与你的账号同服务器的玩家才能加入队伍。';
  }

  @override
  String get communityLfgPosted => '组队帖已发布！';

  @override
  String get communityLfgPreviewTitle => '寻找段位相近的队友';

  @override
  String get communityLfgRemoved => '已撤下帖子。';

  @override
  String get communityLfgSameShardNote => '只有同服务器的玩家才能加入队伍。';

  @override
  String communityLfgSheetSubtitle(String region) {
    return '区域：$region · 帖子将在 30 分钟后自动过期。';
  }

  @override
  String get communityLike => '点赞';

  @override
  String communityLikes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 个赞';
  }

  @override
  String get communityLiveMembers => '成员';

  @override
  String get communityLoadMoreFailed => '无法加载更多帖子，请重试。';

  @override
  String get communityMatchMyRank => '符合你的段位';

  @override
  String communityMaxPhotos(int max) {
    return '最多$max张图片。';
  }

  @override
  String communityMemberJoined(String name) {
    return '$name已加入队伍';
  }

  @override
  String get communityMemberJoinedBody => '有人通过你的组队帖加入了队伍。';

  @override
  String get communityMic => '需要麦克风';

  @override
  String get communityMicOn => '有麦克风';

  @override
  String get communityMode => '模式';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => '更多选项';

  @override
  String get communityMuteAuthor => '隐藏此玩家';

  @override
  String get communityMyPost => '你的帖子';

  @override
  String get communityNewPost => '发帖';

  @override
  String communityNightMarketOf(String date) {
    return '$date的夜市';
  }

  @override
  String get communityNoAccountBody => '添加 Riot 账号即可发帖、寻找队友和为皮肤投票。';

  @override
  String get communityNoAccountTitle => '登录以加入';

  @override
  String get communityNoComments => '暂无评论，快来抢沙发吧！';

  @override
  String get communityNoParty => '找不到你的队伍。请打开 VALORANT 后重试，或手动输入队伍码。';

  @override
  String communityNoPartyWithReason(String reason) {
    return '找不到你的队伍。请打开 VALORANT 后重试，或手动输入队伍码。\n$reason';
  }

  @override
  String get communityNoRatings => '暂无评分';

  @override
  String get communityNote => '备注';

  @override
  String get communityNoteHint => '例如：缺 1 个控场，开麦，开心就好';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name，$price';
  }

  @override
  String communityOffersTotal(String amount) {
    return '合计 $amount';
  }

  @override
  String get communityOpenReviews => '查看评价';

  @override
  String get communityOutOfRange => '超出段位范围';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => '队伍码';

  @override
  String get communityPartyCodeHint => '例如：A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return '队伍码：$code';
  }

  @override
  String get communityPartySize => '当前队伍人数';

  @override
  String get communityPartySizeFromGame => '取自你的游戏内队伍';

  @override
  String communityPartySizeValue(int n) {
    return '$n人';
  }

  @override
  String get communityPeriodAll => '全部';

  @override
  String get communityPeriodAllTime => '历史总榜';

  @override
  String get communityPeriodWeek => '本周';

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max 张图片';
  }

  @override
  String get communityPickRating => '请选择星级。';

  @override
  String get communityPlayVideo => '观看视频';

  @override
  String get communityPostLfg => '发布';

  @override
  String get communityPostNotFound => '此帖子已被删除或隐藏。';

  @override
  String get communityPostTitle => '帖子';

  @override
  String get communityPosted => '已发布！';

  @override
  String get communityPrivacyNote =>
      'ValHub 会在你连接社区时验证 Riot ID，并在你发表评价时验证皮肤拥有权。社区不会保存你的密码或 Riot 登录数据。';

  @override
  String get communityPublish => '发布';

  @override
  String get communityPublishing => '正在发布…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => '从';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => '段位范围';

  @override
  String get communityRankRangeInvalid => '最低段位不能高于最高段位。';

  @override
  String communityRankSemantics(String n, String name) {
    return '第$n名：$name';
  }

  @override
  String get communityRankTo => '至';

  @override
  String get communityRateLimitedTitle => '请稍等片刻';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 人评分';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString 人评分';
  }

  @override
  String get communityRatingWordsItem0 => '很差';

  @override
  String get communityRatingWordsItem1 => '一般';

  @override
  String get communityRatingWordsItem2 => '还行';

  @override
  String get communityRatingWordsItem3 => '很棒';

  @override
  String get communityRatingWordsItem4 => '神作';

  @override
  String get communityRefreshList => '刷新';

  @override
  String get communityRegion => '区域';

  @override
  String get communityRemoveAttachment => '移除附件';

  @override
  String get communityRemoveLfg => '撤下帖子';

  @override
  String get communityRemoveLfgBody => '其他玩家将无法再看到此帖子。';

  @override
  String get communityRemoveLfgTitle => '要撤下组队帖吗？';

  @override
  String get communityRemovePhoto => '移除图片';

  @override
  String get communityReport => '举报';

  @override
  String get communityReportConfirmBody => '被多名玩家举报的内容将从社区中隐藏。';

  @override
  String get communityReportConfirmTitle => '要提交举报吗？';

  @override
  String get communityReportPrompt => '你为什么要举报此内容？';

  @override
  String get communityReportReasonsSpam => '垃圾信息或广告';

  @override
  String get communityReportReasonsHarassment => '骚扰或辱骂';

  @override
  String get communityReportReasonsInappropriate => '不当内容';

  @override
  String get communityReportReasonsScam => '诈骗或买卖账号';

  @override
  String get communityReportReasonsOther => '其他原因';

  @override
  String get communityReportTitle => '举报内容';

  @override
  String get communityReported => '感谢你！举报已提交。';

  @override
  String get communityRetry => '重试';

  @override
  String get communityReviewDeleted => '已删除评价。';

  @override
  String get communityReviewHint => '分享你对此皮肤的看法（选填）';

  @override
  String get communityReviewSaved => '评价已保存！';

  @override
  String get communityReviewTitle => '评价皮肤';

  @override
  String get communityReviewsEmptyBody => '暂无评价——快来第一个评价吧！';

  @override
  String get communityReviewsEmptyTitle => '暂无评价';

  @override
  String communityReviewsHeader(String n) {
    return '评价 · $n';
  }

  @override
  String get communityReviewsSection => '评价';

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot 出现故障';

  @override
  String get communityRoleFlex => '补位';

  @override
  String get communityRoles => '所需职业';

  @override
  String get communitySaveReview => '保存评价';

  @override
  String get communityScopeCountry => '你的国家/地区';

  @override
  String get communityScopeGlobal => '国际';

  @override
  String get communityScopeRegion => '区域';

  @override
  String get communityScopeWorldwide => '全球';

  @override
  String get communitySectionFeed => '动态';

  @override
  String get communitySectionLfg => '寻找队友';

  @override
  String get communitySectionSkins => '皮肤排行';

  @override
  String get communitySend => '发送';

  @override
  String get communitySendComment => '发送评论';

  @override
  String get communityShareNightMarketHint => '向大家炫耀你的夜市';

  @override
  String communitySharePostTitle(String name) {
    return '$name在 ValHub 上的帖子';
  }

  @override
  String get communityShareStore => '分享到社区';

  @override
  String get communityShareStoreHint => '向大家炫耀你的今日商店';

  @override
  String get communityShowOriginal => '查看原文';

  @override
  String get communityShowTranslation => '查看译文';

  @override
  String get communitySignInToReview => '添加 Riot 账号即可评价皮肤。';

  @override
  String get communitySkinNotFound => '找不到此皮肤。';

  @override
  String get communitySkinsEmptyBody => '为你最喜欢的皮肤点亮爱心，把它推上排行榜吧！';

  @override
  String get communitySkinsEmptyTitle => '暂无投票';

  @override
  String get communitySlots => '所需人数';

  @override
  String communitySlotsTooMany(int max) {
    return '队伍最多 5 人：只剩$max个位置。';
  }

  @override
  String communitySlotsWanted(int n) {
    return '需要$n人';
  }

  @override
  String get communitySortHelpful => '最有帮助';

  @override
  String get communitySortNewest => '最新';

  @override
  String get communitySortRating => '评分最高';

  @override
  String get communitySortReviews => '评价最多';

  @override
  String get communitySortVotes => '最受喜爱';

  @override
  String communityStarLabel(int n) {
    return '$n星';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg星（满分 5 星）';
  }

  @override
  String get communityStatusFull => '已满员';

  @override
  String get communityStatusInGame => '对局中';

  @override
  String get communityStatusOpen => '招募中';

  @override
  String communityStoreOf(String date) {
    return '$date的商店';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => '点按星星为此皮肤评分';

  @override
  String get communityTitle => '社区';

  @override
  String communityTooLong(int max) {
    return '最多$max个字符。';
  }

  @override
  String get communityTranslate => '使用 Google 翻译';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return '要从$from翻译成$to，ValHub 需要从 Google 下载语言包（约 $size）。只需下载一次；内容完全在你的设备上翻译，不会发送到任何服务器。';
  }

  @override
  String get communityTranslateDownloadTitle => '要下载本地语言包吗？';

  @override
  String get communityTranslateFailed => '无法翻译，请重试。';

  @override
  String get communityTranslateUnavailable => '此设备暂不支持本地翻译。';

  @override
  String get communityTranslatedByGoogle => '由 Google 自动翻译';

  @override
  String get communityTranslating => '正在翻译…';

  @override
  String get communityTrendingTitle => '全球最受喜爱的皮肤';

  @override
  String get communityUnavailableBody => '无法连接 ValHub 社区。请过几分钟再试。';

  @override
  String get communityUnavailableTitle => '无法连接社区';

  @override
  String get communityUnhideAuthor => '取消隐藏 / 取消屏蔽';

  @override
  String get communityUnknownPlayer => '玩家';

  @override
  String get communityUnlike => '取消点赞';

  @override
  String get communityUnvote => '取消爱心';

  @override
  String get communityUploading => '正在上传图片…';

  @override
  String get communityViewImage => '查看图片';

  @override
  String get communityVote => '为此皮肤点亮爱心';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 人喜爱';
  }

  @override
  String get communityWithdrawConfirm => '撤回';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub 将停止以$riotId使用社区：此设备上的社区连接将被移除，你将回到匿名浏览模式。\n\n你已发布的帖子、评论、评价、投票和组队帖仍会保留在社区中并显示你的 Riot ID，直到你逐条删除，或选择“删除我的社区数据”。你可以随时重新加入。';
  }

  @override
  String get communityWithdrawConfirmTitle => '要撤回同意吗？';

  @override
  String get communityWithdrawSubtitle => '停止以此账号使用社区。已发布的帖子会保留。';

  @override
  String get communityWithdrawTitle => '撤回同意';

  @override
  String get communityWriteFirstReview => '撰写第一条评价';

  @override
  String get communityWritePost => '写帖子';

  @override
  String get communityYou => '你';

  @override
  String get communityYourCountry => '你的国家/地区';

  @override
  String get communityYourReview => '你的评价';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return '你：$kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => '英雄选择中';

  @override
  String get liveGameAnonymous => '匿名';

  @override
  String get liveGameAutoRefreshNote => '进入对局时自动刷新。';

  @override
  String get liveGameBuddy => '枪挂';

  @override
  String get liveGameClose => '关闭';

  @override
  String get liveGameCurrentGame => '当前对局';

  @override
  String get liveGameEmptyTeam => '暂无玩家。';

  @override
  String get liveGameEnemyHiddenInAgentSelect => '对局开始后将显示敌方队伍。';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return '敌方已锁定 $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      '此实时对局数据不提供击杀/死亡/助攻。Riot 发布赛后数据后将显示计分板。';

  @override
  String get liveGameFinalScoreboard => '最终计分板';

  @override
  String get liveGameFlex => '展示道具';

  @override
  String get liveGameInLobby => '在大厅中';

  @override
  String get liveGameInMatch => '对局中';

  @override
  String get liveGameInQueue => '匹配中';

  @override
  String liveGameInQueueFor(String elapsed) {
    return '匹配中 · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return '等级 $n';
  }

  @override
  String get liveGameLiveScore => '实时比分';

  @override
  String get liveGameLoadoutFromAgentSelect => '英雄选择时的配置';

  @override
  String get liveGameLoadoutFromMatch => '本场对局的配置';

  @override
  String get liveGameLobbyHint => '匹配成功后，ValHub 将显示所有人的阵容和段位。';

  @override
  String get liveGameLockedTag => '已锁定';

  @override
  String get liveGameMatchPendingHint => 'ValHub 会自动重试。计分板通常在约一分钟后可用。';

  @override
  String get liveGameNoAgentYet => '尚未选择英雄';

  @override
  String get liveGameNoLoadout => '暂无此玩家的配置信息。';

  @override
  String get liveGameNotInGame => '不在对局中';

  @override
  String get liveGameNotInGameHint =>
      '打开 VALORANT 并开始匹配——进入英雄选择界面后，对局详情会自动显示在这里。';

  @override
  String get liveGameNotInGameTitle => '你不在任何对局中';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return '查看$name的配置';
  }

  @override
  String get liveGameOpenParty => '打开队伍与匹配';

  @override
  String get liveGameParty => '队伍';

  @override
  String liveGamePeak(String rank) {
    return '最高：$rank';
  }

  @override
  String get liveGamePlayerCard => '玩家卡片';

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return '$name的配置';
  }

  @override
  String get liveGamePlayerLoadoutTitle => '配置';

  @override
  String get liveGameQueueHint => '请保持应用打开——匹配成功后会立即显示对局详情。';

  @override
  String get liveGameQuitConfirmBodyInGame => '离开对局可能会受到处罚（扣除 RR、限制匹配）。仍要离开吗？';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      '在英雄选择界面逃跑可能会受到处罚（扣除 RR、限制匹配）。仍要离开吗？';

  @override
  String get liveGameQuitConfirmTitle => '要离开对局吗？';

  @override
  String get liveGameQuitDone => '已离开对局。';

  @override
  String get liveGameQuitFailed => '无法离开对局。';

  @override
  String get liveGameQuitMatch => '离开对局';

  @override
  String get liveGameQuitMatchChanged => '你确认时对局已进入新阶段。你尚未离开，请重试。';

  @override
  String get liveGameRankUnavailable => '段位未知';

  @override
  String get liveGameRefresh => '刷新';

  @override
  String liveGameRefreshIn(int seconds) {
    return '$seconds秒后自动刷新';
  }

  @override
  String get liveGameRefreshNow => '立即刷新';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => '对局详情';

  @override
  String get liveGameSprays => '喷漆';

  @override
  String get liveGameStatusAgentSelect => '英雄选择中';

  @override
  String get liveGameStatusEnded => '已结束';

  @override
  String get liveGameStatusInProgress => '进行中';

  @override
  String get liveGameStatusUnavailable => '无法更新对局状态';

  @override
  String get liveGameTabAllPlayers => '玩家';

  @override
  String get liveGameTabEnemyTeam => '敌方队伍';

  @override
  String get liveGameTabYourTeam => '你的队伍';

  @override
  String liveGameTimeLeft(String t) {
    return '剩余$t';
  }

  @override
  String get liveGameViewMatchDetails => '查看对局详情';

  @override
  String get liveGameWeapons => '武器';

  @override
  String get liveGameYou => '你';

  @override
  String liveGameYouHover(String agent) {
    return '你正在选择$agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return '你已锁定$agent';
  }

  @override
  String get liveGamePickInGame => '请在 VALORANT 中选择并锁定英雄。ValHub 只显示剩余时间和你的队伍。';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws平',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown场结果未知',
      zero: '',
    );
    return '$wins胜 – $losses负$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return '设备时间（$offset）';
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
      'yes': '使用$weapon',
      'other': '',
    });
    return '$killer$_temp0击杀了$victim（$time）';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30天',
      'days7': '7天',
      'other': '全部',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': '英雄',
      'maps': '地图',
      'queues': '模式',
      'sides': '进攻 / 防守',
      'trend': '趋势',
      'other': '模式',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => '所有模式';

  @override
  String get profileAbility => '技能';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n场';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => '平均战斗评分';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return '本幕：$wins胜 / $games场 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => '所有玩家';

  @override
  String get profileAlreadyReached => '你已达到此段位。';

  @override
  String get profileAtCurrentForm => '按当前状态';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return '按当前状态（每场 $gain / $loss）';
  }

  @override
  String profileBestCase(int n) {
    return '最佳情况：连胜$n场';
  }

  @override
  String get profileByWinRateTitle => '按胜率';

  @override
  String get profileChooseMap => '按地图筛选';

  @override
  String get profileClearMap => '清除地图筛选';

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
  String get profileCopyRiotId => '复制 Riot ID';

  @override
  String get profileCurrentRank => '当前';

  @override
  String get profileDailyRrEmpty => '此设备上尚未保存任何竞技模式对局。';

  @override
  String get profileDailyRrFootnote => 'RR 记录直接保存在你的设备上，包括 Riot 已不再返回的对局。';

  @override
  String get profileDailyRrTitle => '每日 RR';

  @override
  String profileDayBoundary(String zone) {
    return '日期按$zone计算';
  }

  @override
  String profileDaysPlayed(int n) {
    return '$n天有对局';
  }

  @override
  String get profileDuration => '时长';

  @override
  String profileDurationOf(String d) {
    return '时长 $d';
  }

  @override
  String get profileEndOfHistory => '已显示所有对局';

  @override
  String get profileEnemyTeam => '敌方队伍';

  @override
  String get profileFallDamage => '坠落伤害';

  @override
  String get profileFilterAll => '全部';

  @override
  String get profileFilterMap => '地图';

  @override
  String get profileFirstBloods => '首杀';

  @override
  String get profileFirstDeaths => '首死';

  @override
  String get profileFirstHalf => '上半场';

  @override
  String get profileFormNoRoundStats => 'K/D、ACS、HS% 仅统计回合制模式。';

  @override
  String profileFormPending(int n) {
    return '列表中有$n场对局尚未加载，暂未计入统计。';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D、ACS、ADR、HS% 仅统计 $roundGames/$games 场回合制对局';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '最近$games场：$w胜，$l负';
  }

  @override
  String get profileFriendsRow => '好友与聊天';

  @override
  String profileGainPerWin(String rr) {
    return '胜利 $rr RR';
  }

  @override
  String get profileHideKills => '隐藏击杀';

  @override
  String get profileHitBody => '身体';

  @override
  String get profileHitDistribution => '命中分布';

  @override
  String get profileHitHead => '头部';

  @override
  String get profileHitLegs => '腿部';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint => '你获得击杀、助攻、存活或被队友补枪的回合占比';

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
    return '最近$n天';
  }

  @override
  String profileLastMatches(int n) {
    return '最近$n场';
  }

  @override
  String profileLeaderboard(String n) {
    return '排行榜 #$n';
  }

  @override
  String profileLevel(int n) {
    return '等级 $n';
  }

  @override
  String get profileLevelHidden => '等级已隐藏';

  @override
  String profileLossPerLoss(String rr) {
    return '失败 $rr RR';
  }

  @override
  String profileLossStreak(int n) {
    return '$n连败';
  }

  @override
  String profileMapFilter(String map) {
    return '地图：$map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n场';
  }

  @override
  String get profileMatchDetailTitle => '对局详情';

  @override
  String get profileMatchHistory => '对战记录';

  @override
  String get profileMatchUnavailable => '无法加载对局';

  @override
  String get profileMatchesNeeded => '所需场数';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => '从未定级';

  @override
  String get profileNoKillsInRound => '此回合暂无击杀信息。';

  @override
  String get profileNoMatches => '暂无对局。';

  @override
  String get profileNoMatchesMap => '已加载的对局中没有这张地图的对局。';

  @override
  String get profileNoMatchesQueue => '此模式下没有对局。';

  @override
  String get profileNoPlayers => '暂无此对局的玩家信息。';

  @override
  String get profileNoRounds => '暂无此对局的逐回合信息。';

  @override
  String get profileOvertime => '加时';

  @override
  String get profilePlayHubTitle => '对局与队伍';

  @override
  String get profilePartyRow => '队伍与匹配';

  @override
  String get profilePeakRank => '最高';

  @override
  String profilePeakRankOf(String actTitle) {
    return '最高 · $actTitle';
  }

  @override
  String get profilePerformanceAttack => '进攻';

  @override
  String get profilePerformanceDefense => '防守';

  @override
  String get profilePerformanceEmpty => '此设备上尚未记录任何对局。打开对战记录即可记录你玩过的对局。';

  @override
  String get profilePerformanceGames => '场数';

  @override
  String get profilePerformanceNoMatches => '所选时间范围内没有对局。';

  @override
  String profilePerformanceRounds(int n) {
    return '已记录$n个回合';
  }

  @override
  String get profilePerformanceSample =>
      '至少有 3 场对局时才显示比率。ACS、ADR、HS% 和 K/D 仅统计回合制模式。';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return '$known/$total 个回合已识别进攻或防守方。';
  }

  @override
  String profilePerformanceSince(String date) {
    return '设备上的记录，自$date起';
  }

  @override
  String get profilePerformanceTitle => '表现';

  @override
  String get profilePerformanceTrendEmpty => '至少需要两个各有 3 场以上对局的时段才能比较趋势。';

  @override
  String get profilePickTargetHint => '选择你想达到的段位';

  @override
  String profilePlacement(int n) {
    return '第$n名';
  }

  @override
  String profilePlantedAt(String site) {
    return '在 $site 点安放爆能器';
  }

  @override
  String get profilePlayerProfileTitle => '玩家资料';

  @override
  String get profilePlayerSummary => '战绩';

  @override
  String profileProgressTo(String rank) {
    return '距$rank的进度';
  }

  @override
  String get profileProgressToTarget => '距目标段位的进度';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote => '根据最近的竞技模式对局估算，未计入定级赛和降级保护机制。';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches场可升至$rank';
  }

  @override
  String get profileRankUpImmortal => '你已达到神话或更高段位——此功能最高只计算到神话一。';

  @override
  String get profileRankUpNoForm => '最近没有竞技模式对局，无法估算你的状态。';

  @override
  String get profileRankUpOpen => '打开升段计算器';

  @override
  String get profileRankUpTitle => '升段计算器';

  @override
  String get profileRankUpUnranked => '完成定级赛后即可使用升段计算器。';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => '竞技计分板';

  @override
  String profileRecentForm(int w, int l) {
    return '近期状态：$w胜 – $l负';
  }

  @override
  String get profileRecentFormTitle => '近期状态';

  @override
  String get profileRecentMatches => '最近对局';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$w胜 · $l负 · $d平',
      zero: '$w胜 · $l负',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => '已复制 Riot ID';

  @override
  String profileRound(int n) {
    return '第$n回合';
  }

  @override
  String profileRoundKills(int n) {
    return '$n次击杀';
  }

  @override
  String get profileRoundLost => '回合失利';

  @override
  String get profileRoundTimeline => '回合进程';

  @override
  String get profileRoundWon => '回合获胜';

  @override
  String get profileRoundsHint => '点按一个回合即可查看每次击杀。';

  @override
  String get profileRr => 'RR';

  @override
  String profileRrLeft(String n) {
    return '还差 $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR 走势';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => '计分板';

  @override
  String get profileSecondHalf => '下半场';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => '查看击杀';

  @override
  String get profileSideSwitch => '攻防互换';

  @override
  String get profileSpike => '爆能器';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => '目标段位';

  @override
  String get profileTeamBlue => '蓝队';

  @override
  String get profileTeamMvp => '队伍 MVP';

  @override
  String get profileTeamRed => '红队';

  @override
  String get profileTitle => '个人资料';

  @override
  String profileToday(String text) {
    return '今天：$text';
  }

  @override
  String get profileTodayNone => '今天暂无竞技模式对局';

  @override
  String get profileTruePeakLocal => '基于此设备上的记录';

  @override
  String get profileWeekdayShortItem0 => '周一';

  @override
  String get profileWeekdayShortItem1 => '周二';

  @override
  String get profileWeekdayShortItem2 => '周三';

  @override
  String get profileWeekdayShortItem3 => '周四';

  @override
  String get profileWeekdayShortItem4 => '周五';

  @override
  String get profileWeekdayShortItem5 => '周六';

  @override
  String get profileWeekdayShortItem6 => '周日';

  @override
  String get profileWinRate => '胜率';

  @override
  String profileWinStreak(int n) {
    return '$n连胜';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => '你的段位';

  @override
  String get profileYourSummary => '你的战绩';

  @override
  String get profileYourTeam => '你的队伍';

  @override
  String get profileYourWinRate => '你最近的胜率';

  @override
  String profilePerformanceQueueChip(String queue) {
    return '模式：$queue';
  }

  @override
  String get profilePerformanceChooseQueue => '按模式筛选';

  @override
  String get profilePerformancePerMatchTitle => '逐场';

  @override
  String get profilePerformancePerMatchHint => '点按柱形即可打开该场对局。';

  @override
  String profilePerformanceAverage(String value) {
    return '平均 $value';
  }

  @override
  String get profilePerformanceChartEmpty => '至少需要 2 场包含此数据的回合制对局才能绘制图表。';

  @override
  String get profilePerformanceOpeningsTitle => '开局对枪';

  @override
  String get profilePerformanceOpeningWin => '开局对枪胜率';

  @override
  String get profilePerformanceOpeningWinHint => '在你拿到首杀或首死的回合中，你拿到首杀的比例。';

  @override
  String get profilePerformanceFirstBloodsPerGame => '场均首杀';

  @override
  String get profilePerformanceFirstDeathsPerGame => '场均首死';

  @override
  String get profilePerformanceMultiKillsTitle => '单回合多杀';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '三杀',
      'k4': '四杀',
      'ace': 'ACE',
      'other': '双杀',
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
      other: '基于 $nString 场击杀数据完整的对局。',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => '回合胜率';

  @override
  String get profilePerformanceDrillHint => '点按一行即可只看该英雄、地图或模式。';

  @override
  String get profilePerformanceLoadOlder => '分析更早的对局';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub 只分析在此设备上打开过的对局。每点按一次最多再添加 $nString 场更早的对局。';
  }

  @override
  String get profilePerformanceSearchingOlder => '正在查找更早的对局…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '正在分析对局 $doneString/$totalString…';
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
      other: '已将 $nString 场对局加入分析。',
      zero: '没有可添加的新对局。',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'Riot 没有保存更早的对局了。';

  @override
  String get profileEconomyTitle => '你方经济';

  @override
  String get profileEconomyHint =>
      '购买类型按回合开始时你方队伍的装备总价值判定（vlr.gg 的 5 人标准）：Eco 低于 5,000，Semi-eco 低于 10,000，Semi-buy 低于 20,000，Full buy 为 20,000 积分及以上。每个半场的第一回合为 Pistol。';

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

    return '胜 $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      '你的 VALORANT 助手：每日商店、心愿单、段位、对局、多账号和玩家社区，尽在你的设备上。';

  @override
  String get legalBackToTop => '返回顶部';

  @override
  String get legalConsentAnd => '和';

  @override
  String get legalConsentPrefix => '继续使用即表示你同意 ValHub 的';

  @override
  String get legalConsentPrivacy => '隐私政策';

  @override
  String get legalConsentSuffix => '中的规定。';

  @override
  String get legalConsentTerms => '使用条款';

  @override
  String get legalContact => '联系我们';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => '联系我们';

  @override
  String get legalCreditsHeader => '数据来源与致谢';

  @override
  String legalEffectiveFrom(String date) {
    return '生效日期：$date';
  }

  @override
  String get legalLegalHeader => '法律信息';

  @override
  String get legalLicensePageLegalese => '© 2026 Nguyễn Đức Huy。保留所有权利。';

  @override
  String get legalThirdPartyLicenses => '第三方软件';

  @override
  String get legalThirdPartyLicensesBody => 'ValHub 使用的开源软件的许可证';

  @override
  String get legalTocTitle => '目录';

  @override
  String legalVersion(String version) {
    return '版本 $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return '本文档当前以$language显示。';
  }

  @override
  String get legalContentUnavailable => '无法读取法律文档。请重试或联系客服。';

  @override
  String get legalTranslationNotice => '此译文仅供参考。如有任何差异，以越南语版本为准。';

  @override
  String get settingsUiLanguageTitle => '界面语言';

  @override
  String get settingsLanguageFollowDevice => '跟随设备';

  @override
  String get settingsLanguageSaveFailed => '无法保存语言设置，请重试。';

  @override
  String get settingsGeoCountry => '国家/地区';

  @override
  String get settingsGeoSearchCountry => '搜索国家/地区名称或代码';

  @override
  String get settingsGeoSupportedOnly => '仅显示已确认支持的';

  @override
  String get settingsGeoUnknown => '支持情况未验证';

  @override
  String get settingsGeoRestricted => '受限';

  @override
  String get settingsGeoSeparate => '独立服务';

  @override
  String get settingsGeoAvailable => '支持';

  @override
  String get settingsGeoNotApplicable => '不适用';

  @override
  String get settingsGeoConnection => 'Riot 连接';

  @override
  String get settingsGeoChooseRegion => '选择区域';

  @override
  String get settingsGeoAuto => '根据账号自动选择';

  @override
  String get settingsGeoManual => '手动选择';

  @override
  String get settingsGeoNoRegion => '无法确定你的 Riot 区域';

  @override
  String get settingsGeoManualWarning =>
      '此选项只会更改 ValHub 连接的服务器，不会转移你 Riot 账号的区域。ValHub 会在保存前检查连接。';

  @override
  String get settingsGeoConnectionSaved => '已保存连接方式';

  @override
  String get settingsGeoValidationFailed => '无法在此服务器上确认你的账号。请重新选择区域。';

  @override
  String get settingsGeoHintOnly => '国家/地区仅用于查询和推荐。连接区域以你的 Riot 账号为准。';

  @override
  String get settingsGeoUnsupported => '暂不支持此 Riot 区域。请在设置中选择区域。';

  @override
  String get settingsGeoSave => '检查并保存';

  @override
  String get settingsGeoCancel => '取消';

  @override
  String get settingsGeoLoading => '正在检查连接…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      '此选项用于国家/地区名称、推荐内容和 VP 估算价格。连接的服务器和社区账号所属国家/地区仍由 Riot 决定。';

  @override
  String get settingsGeoCountryAutomatic => '使用账号或设备的国家/地区';

  @override
  String get settingsGeoSaveFailed => '无法保存你的选择，请重试。';

  @override
  String get settingsGeoAllRegions => '所有区域';

  @override
  String get settingsGeoSuggestions => '推荐';

  @override
  String get settingsGeoNoCountries => '没有符合筛选条件的国家/地区。';

  @override
  String get settingsGeoActiveCountries => '活跃';

  @override
  String get settingsGeoAllCountries => '所有国家/地区';

  @override
  String get settingsGeoActivityUnavailable =>
      '无法加载各国家/地区的活跃度。你仍可在“所有国家/地区”中选择。';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个国家/地区',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return '你选择了$manual，但 Riot 判定你的账号位于$detected。要继续检查此连接吗？';
  }

  @override
  String get settingsGeoUnverified => '由于服务器或网络出现问题，无法验证连接。要保存此选择并稍后重试吗？';

  @override
  String get settingsGeoContinue => '继续';

  @override
  String settingsGeoMismatch(String region) {
    return '你手动选择的连接与 Riot 区域不同：$region。要改用自动选择吗？';
  }

  @override
  String get settingsGeoUseAuto => '使用自动';

  @override
  String get settingsGeoKeepManual => '保持手动';

  @override
  String get settingsGeoReviewConnection => '查看连接';

  @override
  String settingsGeoCheckedAt(String time) {
    return '上次检查：$time';
  }

  @override
  String get settingsGeoCheckAgain => '重新检查';

  @override
  String get settingsPlatformMobile => '移动设备';

  @override
  String get settingsPlatformOther => '其他平台';

  @override
  String get settingsContentLanguageFollowApp => '跟随应用语言';

  @override
  String get settingsContentLanguageHint =>
      '选择物品名称的语言。此选项不会更改界面语言或你的 Riot 服务器。';

  @override
  String settingsLanguageChanged(String language) {
    return '语言：$language。';
  }

  @override
  String get settingsAboutCreditContent => 'valorant-api.com';

  @override
  String get settingsAboutCreditContentBody => '皮肤、英雄、地图和段位的名称、图片及信息。';

  @override
  String get settingsAboutCreditDocs => '社区文档';

  @override
  String get settingsAboutCreditDocsBody =>
      'techchrism/valorant-api-docs 项目及 VALORANT 开发者社区。';

  @override
  String get settingsAboutCreditRiot => 'Riot Games';

  @override
  String get settingsAboutCreditRiotBody => '商店、钱包、收藏、对局和段位数据直接来自你登录的 Riot 账号。';

  @override
  String get settingsAboutCreditsHeader => '数据来源';

  @override
  String get settingsAboutHeader => '信息';

  @override
  String get settingsAboutLegalHeader => '法律信息';

  @override
  String get settingsAboutRowSubtitle => '隐私、条款、版权和联系方式';

  @override
  String get settingsAboutTitle => '关于与法律信息';

  @override
  String get settingsAppHeader => '高级';

  @override
  String get settingsAppearanceHeader => '外观';

  @override
  String settingsBuildNumber(String build) {
    return '构建版本 $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '已清除 $size';
  }

  @override
  String get settingsClearCache => '清除临时数据';

  @override
  String get settingsClearCacheFailed => '无法清除临时数据，请重试。';

  @override
  String get settingsClearCacheSubtitle => '已下载到设备的图片和数据，包括已记录的错误报告';

  @override
  String get settingsClearLog => '清除已记录的错误报告';

  @override
  String get settingsClearLogConfirm => '要清除此设备上已记录的错误报告吗？';

  @override
  String get settingsExportLog => '向 ValHub 发送错误报告';

  @override
  String get settingsExportLogEmpty => '暂无可发送的内容。请使用应用一段时间后再试。';

  @override
  String get settingsExportLogEmptyTitle => '暂无可发送的内容';

  @override
  String get settingsExportLogNote => '错误报告不包含你的密码或 Riot 登录数据。';

  @override
  String get settingsExportLogSubtitle => '错误报告不包含你的密码或 Riot 登录数据。';

  @override
  String get settingsFeedback => '向 ValHub 提供反馈';

  @override
  String get settingsFeedbackSubtitle => '打开 ValHub 反馈页面';

  @override
  String get settingsItemLanguageEn => '英语';

  @override
  String get settingsItemLanguageHint => '皮肤、英雄、地图等名称将以此语言显示。';

  @override
  String get settingsItemLanguageLabel => '物品名称';

  @override
  String get settingsItemLanguagePickerTitle => '物品名称语言';

  @override
  String get settingsItemLanguageVi => '越南语';

  @override
  String get settingsLegalNotice => '法律声明';

  @override
  String get settingsLinkOpenFailed => '无法打开链接，请重试。';

  @override
  String get settingsLogCleared => '已清除错误报告';

  @override
  String settingsLogEntryCount(int count) {
    return '$count条';
  }

  @override
  String settingsLogEntryShown(int shown, int total) {
    return '$shown / $total 条';
  }

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — 错误报告';
  }

  @override
  String get settingsLogFilterAll => '全部';

  @override
  String get settingsLogFilterAuth => '登录';

  @override
  String get settingsLogFilterEmpty => '没有匹配的条目。清除筛选可查看更多。';

  @override
  String get settingsLogFilterErrors => '问题';

  @override
  String get settingsLogFilterHttp => '连接';

  @override
  String get settingsLogMore => '更多选项';

  @override
  String get settingsLogSearchEmpty => '没有匹配的条目。';

  @override
  String get settingsLogSearchHint => '搜索错误报告…';

  @override
  String get settingsLogShareFailed => '无法发送错误报告，请重试。';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => '夜市开放时';

  @override
  String get settingsNotifNightMarketSubtitle => '提醒你翻开夜市优惠卡牌';

  @override
  String get settingsNotifPermissionMissing => '应用尚未获得发送通知的权限。';

  @override
  String get settingsNotifStoreReset => '商店刷新时';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return '每天 $time';
  }

  @override
  String get settingsNotifWishlist => '心愿单中的皮肤出现时';

  @override
  String get settingsNotifWishlistSubtitle => '即使你没有打开应用，也会检查所有账号的商店';

  @override
  String get settingsNotificationsHeader => '通知';

  @override
  String get settingsOptionAutoOpenLiveGame => '自动打开对局详情';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle => '匹配成功后立即打开当前对局面板';

  @override
  String get settingsOptionOwnPrice => '你的 VP 礼包价格';

  @override
  String get settingsOptionOwnPriceEmpty => '未设置——如有区域价格表则使用该价格表';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => '平台';

  @override
  String get settingsOptionShowLiveScore => '显示实时比分';

  @override
  String get settingsOptionShowPeakRank => '在对局详情中显示最高段位';

  @override
  String get settingsOptionShowPrice => '显示估算价格';

  @override
  String get settingsOptionShowPriceInfo => '估算价格的计算方式';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return '显示在 VP 价格旁，例如 $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      '你所在区域暂无经过核实的价格表——请输入你的 VP 礼包价格。';

  @override
  String get settingsOptionsHeader => '选项';

  @override
  String get settingsPhaseComplete => '已完成';

  @override
  String get settingsPhaseInProgress => '进行中';

  @override
  String get settingsPhaseScheduled => '已计划';

  @override
  String settingsPlatformAppliesTo(String account) {
    return '适用于 $account';
  }

  @override
  String get settingsPlatformHint =>
      '根据你的游戏平台选择 PC、PlayStation 或 Xbox，以查看正确的对战记录。';

  @override
  String get settingsPlatformPickerTitle => '选择平台';

  @override
  String get settingsPrimingBody => '开启通知，及时了解商店刷新以及心愿单皮肤上架。';

  @override
  String get settingsPrimingEnable => '开启通知';

  @override
  String get settingsPrimingFootnote => '你可以随时在设置中开启或关闭各类通知。';

  @override
  String get settingsPrimingLater => '稍后';

  @override
  String get settingsPrimingPointNightMarket => '夜市开放时通知你';

  @override
  String get settingsPrimingPointNightMarketDetail => '以便在过期前翻开优惠卡牌';

  @override
  String get settingsPrimingPointStore => '每日商店刷新时提醒你';

  @override
  String get settingsPrimingPointStoreDetail => '在你账号的商店刷新后提醒你';

  @override
  String get settingsPrimingPointWishlist => '你想要的皮肤出现时通知你';

  @override
  String get settingsPrimingPointWishlistDetail => '即使你没有打开应用，也会检查所有账号的商店';

  @override
  String get settingsPrimingTitle => '不再错过心仪的皮肤';

  @override
  String settingsRemovedAccount(String account) {
    return '已删除 $account';
  }

  @override
  String get settingsServerStatus => '服务器状态';

  @override
  String get settingsServerStatusMaintenance => '维护中';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n条公告';
  }

  @override
  String get settingsServerStatusSubtitle => '各服务器的 VALORANT 维护和故障信息';

  @override
  String get settingsSessionLogTitle => 'ValHub 错误报告';

  @override
  String get settingsSeverityCritical => '严重';

  @override
  String get settingsSeverityInfo => '信息';

  @override
  String get settingsSeverityWarning => '警告';

  @override
  String get settingsSignedOutAll => '已登出所有账号';

  @override
  String get settingsStatusAllGood => '服务器运行正常';

  @override
  String settingsStatusAllGoodBody(String region) {
    return '$region服务器目前没有故障或维护。';
  }

  @override
  String get settingsStatusFewerUpdates => '收起';

  @override
  String get settingsStatusIssues => 'Riot 正在处理故障';

  @override
  String settingsStatusIssuesBody(int n) {
    return '此服务器有$n条故障公告。';
  }

  @override
  String get settingsStatusKindIncident => '故障';

  @override
  String get settingsStatusKindMaintenance => '维护';

  @override
  String get settingsStatusMaintenanceNow => '服务器维护中';

  @override
  String get settingsStatusMaintenanceNowBody =>
      '你可能暂时无法进入游戏，ValHub 也可能暂时无法加载信息。';

  @override
  String settingsStatusMoreUpdates(int n) {
    return '查看另外$n条更新';
  }

  @override
  String get settingsStatusRegionPicker => '服务器';

  @override
  String get settingsStatusScheduled => '即将维护';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riot 已公布$n次维护计划。';
  }

  @override
  String get settingsStatusSourceNote => '来源：Riot Games 官方状态页面。时间按设备时区显示。';

  @override
  String settingsStatusStarted(String when) {
    return '开始于$when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return '更新于$when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'RIOT 最新动态';

  @override
  String get settingsSupportHeader => '支持';

  @override
  String settingsSwitchedTo(String account) {
    return '已切换到 $account';
  }

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLabel => '主题';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemePickerTitle => '选择主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsTitle => '设置';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsWelcomeBulletProfile => '段位、对战记录、进行中的对局';

  @override
  String get settingsWelcomeBulletProfileDetail => '每场 RR 变化、对手段位';

  @override
  String get settingsWelcomeBulletStore => '每日商店、夜市和组合包';

  @override
  String get settingsWelcomeBulletStoreDetail => '查看价格、稀有度和刷新倒计时';

  @override
  String get settingsWelcomeBulletWishlist => '心愿单与通知';

  @override
  String get settingsWelcomeBulletWishlistDetail => '心仪的皮肤上架时提醒你';

  @override
  String get settingsWelcomeFootnote =>
      '你将在 Riot 官方页面登录。只有在你选择保存登录信息时，ValHub 才会保存密码。';

  @override
  String get settingsWelcomeKicker => 'VALORANT 助手';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average（评分：$count）· ',
      'other': '',
    });
    return '社区：$_temp0喜爱：$votes';
  }

  @override
  String get skinDetailAddToWishlist => '加入心愿单';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return '出现在以下账号的商店中：$accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return '在你的商店中：每日商店出现$daily次，夜市出现$night次。仅统计此设备上自$since起记录的数据。';
  }

  @override
  String get skinDetailHistoryDelete => '删除商店记录';

  @override
  String get skinDetailHistoryDeleteBody => '要删除此设备上为此账号记录的所有商店日期吗？';

  @override
  String get skinDetailInWishlist => '已在心愿单中';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => '未解锁';

  @override
  String get skinDetailMute => '静音';

  @override
  String get skinDetailNotFound => '找不到此皮肤。';

  @override
  String get skinDetailOwned => '已拥有';

  @override
  String get skinDetailPause => '暂停';

  @override
  String get skinDetailPlay => '播放';

  @override
  String get skinDetailPlayVideo => '观看视频';

  @override
  String get skinDetailRemoveFromWishlist => '从心愿单中移除';

  @override
  String get skinDetailTitle => '皮肤详情';

  @override
  String get skinDetailUnmute => '取消静音';

  @override
  String get skinDetailUpgrades => '升级';

  @override
  String get skinDetailVariants => '炫彩';

  @override
  String get skinDetailVideoError => '无法播放视频。请检查网络后重试。';

  @override
  String get socialPresenceInMatch => '对局中';

  @override
  String get socialPresenceAgentSelect => '英雄选择中';

  @override
  String get socialPresenceQueue => '匹配中';

  @override
  String get socialPresenceLobby => '在大厅中';

  @override
  String get socialPresenceCustom => '自定义游戏中';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': '公开队伍',
      'other': '仅限受邀',
    });
    return '$size/$max 人 · $_temp0';
  }

  @override
  String get socialAccept => '接受';

  @override
  String get socialAcceptInGame => '请在游戏内接受此邀请。';

  @override
  String socialActionFailed(String message) {
    return '操作未完成。$message';
  }

  @override
  String get socialAutoRefresh => '自动刷新';

  @override
  String get socialAway => '离开';

  @override
  String socialCancelQueue(String elapsed) {
    return '取消匹配 · $elapsed';
  }

  @override
  String get socialCancelQueueShort => '取消匹配';

  @override
  String socialCantQueue(String queue, String reason) {
    return '队伍暂时无法匹配$queue：$reason';
  }

  @override
  String get socialChangeQueue => '更换模式';

  @override
  String get socialChatTitle => '聊天';

  @override
  String get socialChatUnavailable => '聊天处于离线状态。';

  @override
  String get socialCloseParty => '关闭队伍';

  @override
  String get socialClosedState => '仅限受邀';

  @override
  String get socialCodeInvalid => '队伍码只能包含字母和数字。';

  @override
  String get socialConnecting => '正在连接聊天…';

  @override
  String get socialCopyCode => '复制';

  @override
  String get socialCurrentQueue => '已选择';

  @override
  String get socialCustomGameLobby => '队伍正在自定义游戏大厅中。';

  @override
  String get socialDecline => '拒绝';

  @override
  String get socialDisableCode => '停用队伍码';

  @override
  String get socialEmptyChat => '暂无消息。打个招呼吧！';

  @override
  String get socialEmptyChatTitle => '开始聊天';

  @override
  String get socialFailedBadge => '未发送';

  @override
  String get socialFilterAll => '全部';

  @override
  String get socialFilterOnline => '在线';

  @override
  String get socialFilterUnread => '未读';

  @override
  String get socialFriendsPrivacyNote =>
      '好友列表和消息直接来自 Riot。ValHub 不会将其存储在其他任何地方。';

  @override
  String socialFriendsSummary(int total, int online) {
    return '$total位好友 · $online人在线';
  }

  @override
  String get socialFriendsTitle => '好友与聊天';

  @override
  String get socialGameNotRunningBody =>
      '队伍与匹配功能仅在 VALORANT 于你的电脑或主机上运行时可用。打开游戏后下拉刷新。';

  @override
  String get socialGameNotRunningTitle => '在电脑或主机上打开 VALORANT';

  @override
  String get socialGenerateCode => '生成队伍码';

  @override
  String get socialHistoryFailed => '无法加载更早的消息。请重新连接后重试。';

  @override
  String get socialIdleQueue => '准备匹配';

  @override
  String get socialInMatchBanner => '你正在对局中。对局结束后可再次匹配。';

  @override
  String get socialInValorant => '在 VALORANT 中';

  @override
  String get socialInviteByRiotId => '通过 Riot ID 邀请';

  @override
  String get socialInviteByRiotIdHint => '也可邀请尚未成为好友的玩家';

  @override
  String get socialInviteFriends => '邀请好友';

  @override
  String socialInviteFrom(String name) {
    return '来自$name的邀请';
  }

  @override
  String socialInviteLabel(String name) {
    return '邀请$name';
  }

  @override
  String get socialInviteNeedsName => '此玩家的 Riot ID 未知，暂时无法邀请。';

  @override
  String socialInviteSent(String name) {
    return '已向$name发送邀请。';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · 已邀请';
  }

  @override
  String get socialInvitesSection => '邀请';

  @override
  String get socialJoin => '加入';

  @override
  String get socialJoinConfirmBody => '你将离开当前队伍，加入使用此队伍码的队伍。';

  @override
  String get socialJoinConfirmTitle => '要加入其他队伍吗？';

  @override
  String get socialJoinSection => '加入其他队伍';

  @override
  String get socialJoinWithCode => '输入队伍码加入';

  @override
  String get socialJoined => '已加入队伍。';

  @override
  String socialLastOnline(String relative) {
    return '$relative活跃';
  }

  @override
  String get socialLeader => '队长';

  @override
  String socialLeaderboardTop(String position) {
    return '第 $position 名';
  }

  @override
  String get socialLeaveConfirmBody => '你将离开当前队伍，回到单人队伍。';

  @override
  String get socialLeaveConfirmTitle => '要离开队伍吗？';

  @override
  String get socialLeaveParty => '离开队伍';

  @override
  String socialLevel(int n) {
    return '等级 $n';
  }

  @override
  String get socialMatchFound => '匹配成功！';

  @override
  String socialMembersSection(int n, int max) {
    return '成员（$n/$max）';
  }

  @override
  String get socialMessageHint => '输入消息…';

  @override
  String get socialMoreActions => '更多选项';

  @override
  String get socialNoCode => '生成队伍码，好友即可通过队伍码快速加入你的队伍。';

  @override
  String get socialNoCodeMember => '队长可以生成队伍码以便快速邀请。';

  @override
  String get socialNoFilterResults => '没有符合此筛选条件的好友。';

  @override
  String get socialNoFriends => '你的 Riot 好友列表为空。请在游戏内添加好友。';

  @override
  String get socialNoFriendsTitle => '暂无好友';

  @override
  String get socialNoOnlineFriends => '目前没有好友在 VALORANT 中在线。';

  @override
  String get socialNoSearchResults => '没有找到匹配的好友。';

  @override
  String get socialNoSearchResultsTitle => '未找到';

  @override
  String get socialNotFriend => '此玩家不在你的好友列表中。';

  @override
  String get socialNotReady => '未准备';

  @override
  String socialOfflineSection(int n) {
    return '离线（$n）';
  }

  @override
  String get socialOfflineStatus => '离线';

  @override
  String get socialOnlineMobile => '手机在线';

  @override
  String socialOnlineSection(int n) {
    return '在线（$n）';
  }

  @override
  String get socialOnlineStatus => '在线';

  @override
  String get socialOnlyLeader => '只有队长才能更换模式并开始匹配。';

  @override
  String get socialOpenParty => '公开队伍';

  @override
  String get socialOpenState => '公开队伍';

  @override
  String get socialOtherGamesLeagueOfLegends => '英雄联盟';

  @override
  String get socialOtherGamesBacon => '符文之地传说';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => '队伍码';

  @override
  String socialPartyCodeValue(String code) {
    return '队伍码：$code';
  }

  @override
  String get socialPartyInvite => '队伍邀请';

  @override
  String socialPartyOf(int size, int max) {
    return '队伍 $size/$max';
  }

  @override
  String get socialPartyTitle => '队伍与匹配';

  @override
  String socialPickQueueSubtitle(int size) {
    return '$size人队伍';
  }

  @override
  String get socialPickQueueTitle => '选择模式';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => '到对局服务器的最佳延迟';

  @override
  String socialPlayingOther(String game) {
    return '正在玩$game';
  }

  @override
  String socialPlayingSection(int n) {
    return '游戏中（$n）';
  }

  @override
  String get socialQueueLabel => '模式';

  @override
  String get socialQueueLocked => '对局中无法更换模式。';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '最多$max人',
      one: '仅限单人',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable => '无法验证游戏状态。刷新后即可使用准备和匹配功能。';

  @override
  String get socialReady => '准备';

  @override
  String socialReadyCount(int ready, int total) {
    return '已准备 $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => '有成员的账号等级不足';

  @override
  String get socialReasonGeneric => '队伍尚不满足条件';

  @override
  String socialReasonPartyTooLarge(int max) {
    return '队伍人数过多（最多$max人）';
  }

  @override
  String get socialReasonRankDisparity => '段位差距过大，无法进行竞技模式';

  @override
  String socialReasonRestricted(String time) {
    return '队伍被限制匹配（剩余$time）';
  }

  @override
  String get socialReconnecting => '聊天连接已断开，正在重新连接…';

  @override
  String get socialRemoteNote => '只有在你点按时，更改才会发送给 Riot。ValHub 绝不会替你开始匹配或锁定英雄。';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name将被移出你的队伍。';
  }

  @override
  String get socialRemoveConfirmTitle => '要移出队伍吗？';

  @override
  String get socialRemoveMember => '移出队伍';

  @override
  String socialRequestFrom(String name) {
    return '$name想加入队伍';
  }

  @override
  String get socialRequestsSection => '加入请求';

  @override
  String get socialRiotIdFieldHint => '名称#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID 由名称（3–16 个字符）、# 和标签（3–5 个字母或数字）组成。';

  @override
  String get socialSearchHint => '按 Riot ID 搜索…';

  @override
  String socialSearching(String elapsed) {
    return '匹配中 · $elapsed';
  }

  @override
  String get socialSend => '发送';

  @override
  String get socialSendFailed => '消息发送失败。请检查网络连接后重试。';

  @override
  String get socialSendInvite => '发送邀请';

  @override
  String get socialShareCode => '分享';

  @override
  String socialShareCodeText(String code) {
    return '用队伍码加入我的 VALORANT 队伍：$code';
  }

  @override
  String get socialShootingRange => '在靶场中';

  @override
  String get socialShowEveryone => '显示全部';

  @override
  String get socialStartQueue => '开始匹配';

  @override
  String get socialSuggestionsItem0 => '你好呀！';

  @override
  String get socialSuggestionsItem1 => '来几把吗？';

  @override
  String get socialSuggestionsItem2 => '来我队伍一起玩吧！';

  @override
  String socialUnread(int n) {
    return '$n条未读消息';
  }

  @override
  String get socialUnready => '取消准备';

  @override
  String get socialViewProfile => '查看资料';

  @override
  String get socialWaitingForConnection => '正在连接…连接成功后即可发送消息。';

  @override
  String get socialYou => '你';

  @override
  String get socialPartyUnavailable => '无法同步你的队伍。请刷新后重试。';

  @override
  String get storeAccessoryEmpty => '配件商店目前没有商品。';

  @override
  String get storeAccessoryEmptyTitle => '暂无配件';

  @override
  String storeAccessoryFrom(String contract) {
    return '来自：$contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return '$t后刷新';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return '刷新时间：$wall';
  }

  @override
  String get storeAddToWishlist => '加入心愿单';

  @override
  String get storeBackToBundles => '查看在售组合包';

  @override
  String get storeBundleBuySeparateLabel => '单独购买';

  @override
  String get storeBundleDetailTitle => '组合包详情';

  @override
  String storeBundleEndsAt(String wall) {
    return '结束时间：$wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return '剩余$t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n件物品';
  }

  @override
  String get storeBundleItemFree => '免费';

  @override
  String get storeBundleItemsTitle => '组合包内物品';

  @override
  String get storeBundleNotFound => '找不到此组合包，可能已经下架。';

  @override
  String get storeBundleNotFoundTitle => '组合包已下架';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return '已拥有 $owned/$total 件物品';
  }

  @override
  String get storeBundlePriceLabel => '组合包价格';

  @override
  String get storeBundleSavingsLabel => '节省';

  @override
  String get storeBundleWholesaleOnly => '仅整套出售，不可单独购买。';

  @override
  String get storeBundlesEmpty => '目前没有在售的组合包。';

  @override
  String get storeBundlesEmptyTitle => '暂无组合包';

  @override
  String get storeDailyEmpty => '今日商店中没有皮肤。';

  @override
  String get storeDailyEmptyTitle => '商店为空';

  @override
  String storeDailyResetAt(String time) {
    return '每天 $time 刷新';
  }

  @override
  String get storeDailyTotalLabel => '合计';

  @override
  String get storeNightMarketEmpty => '目前没有夜市。';

  @override
  String get storeNightMarketEmptyTitle => '夜市未开放';

  @override
  String storeNightMarketEndsAt(String wall) {
    return '结束时间：$wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return '$t后结束';
  }

  @override
  String get storeNightMarketNote => '夜市优惠为你的账号专属，且无法刷新。';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return '共节省 $amount';
  }

  @override
  String get storeNightMarketUnrevealed => '未翻开';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name，$price';
  }

  @override
  String get storeOwnedBadge => '已拥有';

  @override
  String storeOwnedCount(int owned, int total) {
    return '已拥有 $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => '从心愿单中移除';

  @override
  String storeResetNotificationBody(int skinCount, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      skinCount,
      locale: localeName,
      other: '查看$account今日的$skinCount款新皮肤。',
      zero: '查看$account今日的新皮肤。',
    );
    return '$_temp0';
  }

  @override
  String get storeResetNotificationTitle => '商店已刷新';

  @override
  String storeResetsIn(String t) {
    return '$t后刷新';
  }

  @override
  String get storeSegmentAccessories => '配件';

  @override
  String get storeSegmentBundles => '组合包';

  @override
  String get storeSegmentDaily => '每日';

  @override
  String get storeSegmentNightMarket => '夜市';

  @override
  String get storeShareButton => '分享';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => '今日商店';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => '夜市';

  @override
  String get storeShareCardPriceNote => '换算价格仅为根据 VP 礼包得出的估算值。';

  @override
  String storeShareCardSaved(String vp) {
    return '节省 $vp';
  }

  @override
  String get storeShareCardTagline => '你的 VALORANT 助手';

  @override
  String storeShareCardTotal(String vp) {
    return '合计 $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return '截至 $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => '分享今日商店';

  @override
  String get storeShareFailed => '无法生成图片，请重试。';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => '分享图片';

  @override
  String get storeShareNightMarketTitle => '分享夜市';

  @override
  String get storeSharePreparing => '正在加载皮肤图片…';

  @override
  String get storeShareShowPrice => '显示估算价格';

  @override
  String get storeShareShowPriceHint => '按最划算的 VP 礼包换算。';

  @override
  String get storeShareShowRiotId => '在图片上显示 Riot ID';

  @override
  String get storeShareShowRiotIdHint => '默认关闭，以保护你的隐私。';

  @override
  String get storeShareSubjectDaily => '我今天的 VALORANT 商店';

  @override
  String get storeShareSubjectNightMarket => '我的 VALORANT 夜市';

  @override
  String get storeShareSubtitle => '通过你选择的应用与好友分享商店图片。';

  @override
  String get storeTitle => '商店';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return '余额：$vp VP，$kc KC，$rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '心愿单中 $n 款';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin正在$account的商店中——剩余$left。',
      'other': '$skin正在$account的商店中。',
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
      'discount': '$skin打折 $percent%，现价$price（$account）。',
      'price': '$skin仅需$price（$account）。',
      'other': '$skin出现在$account的夜市中。',
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
      'yes': '$skin包含在$bundle组合包中（$account）。',
      'other': '$skin包含在一个在售组合包中（$account）。',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names及另外$more款皮肤正在$account的商店中。',
      zero: '$names正在$account的商店中。',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '，已在心愿单中',
      'other': '',
    });
    return '$name，$price$_temp0';
  }

  @override
  String get wishlistAddSkins => '添加皮肤';

  @override
  String get wishlistAddToWishlist => '加入心愿单';

  @override
  String get wishlistAllWeapons => '全部武器';

  @override
  String get wishlistBrowseCatalog => '查看全部皮肤';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 款皮肤';
  }

  @override
  String get wishlistCatalogEmpty => '无法加载皮肤列表。请刷新后重试。';

  @override
  String get wishlistCatalogEmptyTitle => '暂无皮肤';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '心愿单中：$count';
  }

  @override
  String get wishlistCatalogSubtitle => '点按 ♡ 将皮肤加入心愿单';

  @override
  String get wishlistCatalogTitle => '全部皮肤';

  @override
  String get wishlistChooseWeapon => '选择武器';

  @override
  String get wishlistClearFilters => '清除筛选';

  @override
  String get wishlistClearSearch => '清除搜索';

  @override
  String get wishlistEmpty => '心愿单为空。在任意皮肤上点按 ♡ 即可添加。';

  @override
  String get wishlistEmptyTitle => '暂无皮肤';

  @override
  String wishlistEndsIn(String time) {
    return '$time后结束';
  }

  @override
  String get wishlistExcludedRewards => '不含奖励皮肤';

  @override
  String get wishlistFilterTiers => '版本';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '已筛选：$countString 款皮肤 · $value';
  }

  @override
  String get wishlistHasEstimates => '含估算价格（≈）';

  @override
  String get wishlistInWishlist => '已在心愿单中';

  @override
  String get wishlistInWishlistLabel => '已在心愿单中';

  @override
  String get wishlistNoMatch => '没有匹配的皮肤。清除筛选可查看更多。';

  @override
  String get wishlistNoMatchTitle => '未找到皮肤';

  @override
  String get wishlistNotifBundleTitle => '新组合包中有心愿单皮肤';

  @override
  String get wishlistNotifDailyTitle => '心愿单中的皮肤上架了！';

  @override
  String get wishlistNotifNightMarketTitle => '夜市里有你想要的皮肤！';

  @override
  String get wishlistNotifPermissionMissing => '应用尚未获得发送通知的权限。';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return '心愿单中有$count款皮肤正在出售！';
  }

  @override
  String get wishlistNotifToggle => '心愿单通知';

  @override
  String get wishlistNotifToggleSubtitle => '适用于此账号，即使你没有打开应用';

  @override
  String wishlistOfAccount(String riotId) {
    return '$riotId的心愿单';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '心愿单中有$count款皮肤正在出售！',
      one: '心愿单中有一款皮肤正在出售！',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => '点按高亮的条目即可查看优惠。';

  @override
  String get wishlistOpenSettings => '打开设置';

  @override
  String get wishlistOwned => '已拥有';

  @override
  String get wishlistRemoveAction => '从心愿单中移除';

  @override
  String get wishlistRemoveFromWishlist => '从心愿单中移除';

  @override
  String wishlistRemoved(String name) {
    return '已将$name从心愿单中移除';
  }

  @override
  String get wishlistSearchHint => '搜索皮肤…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 款皮肤';
  }

  @override
  String get wishlistSortBy => '排序';

  @override
  String wishlistSortLabel(String sort) {
    return '排序：$sort';
  }

  @override
  String get wishlistSortName => '名称';

  @override
  String get wishlistSortPrice => '价格';

  @override
  String get wishlistSortRarity => '稀有度';

  @override
  String get wishlistSortWeapon => '武器';

  @override
  String get wishlistStoreCheckTitle => '无法检查商店';

  @override
  String get wishlistSubtitle => '你心仪的皮肤';

  @override
  String get wishlistTitle => '心愿单';

  @override
  String get wishlistTotalValue => '心愿单总价值';

  @override
  String get wishlistUndo => '撤销';

  @override
  String get wishlistViewInStore => '在商店中查看';

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
      'yes': '，在心愿单中',
      'other': '',
    });
    return '$name，$price，$tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '，在心愿单中',
      'other': '',
    });
    return '$name，$votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': '上升',
      'other': '下降',
    });
    return '今天$_temp0 $rr RR，$wins胜，$losses负';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: '，$draws平',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: '，$unknown场结果未知',
      zero: '',
    );
    return '$wins胜 – $losses负$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => '打开“自定义首页”即可重新显示。';

  @override
  String get homeAllHiddenTitle => '你已隐藏所有卡片';

  @override
  String get homeCardBattlePass => '通行证';

  @override
  String get homeCardBattlePassDesc => '等级、每日所需 XP 和每周任务。';

  @override
  String get homeCardCommunity => '社区';

  @override
  String get homeCardCommunityDesc => '寻找段位相近的队友，以及本周最受喜爱的皮肤。';

  @override
  String get homeCardFriends => '正在游戏的好友';

  @override
  String get homeCardFriendsDesc => '正在对局中或匹配中的好友。';

  @override
  String homeCardHidden(String name) {
    return '已隐藏“$name”';
  }

  @override
  String get homeCardLive => '当前对局';

  @override
  String get homeCardLiveDesc => '在你匹配、选择英雄或对局中时显示。';

  @override
  String get homeCardOtherAccounts => '其他账号';

  @override
  String get homeCardOtherAccountsDesc => '其余账号的状态和心愿单。';

  @override
  String get homeCardRank => '段位与状态';

  @override
  String get homeCardRankDesc => '段位、今日 RR、连胜/连败和升段所需场数。';

  @override
  String get homeCardServerStatus => '服务器状态';

  @override
  String get homeCardServerStatusDesc => '仅在维护或出现故障时显示。';

  @override
  String get homeCardStore => '今日商店';

  @override
  String get homeCardStoreDesc => '每日皮肤、心愿单和夜市。';

  @override
  String get homeCustomize => '自定义首页';

  @override
  String get homeCustomizeHint => '拖动以排序，关闭以隐藏卡片。';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return '已跳转到$name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name，$status';
  }

  @override
  String get homeFriendsConsentAllow => '开启';

  @override
  String get homeFriendsConsentBody =>
      '为了显示哪些好友正在游戏，ValHub 会在你每次打开首页时连接当前账号的 Riot 聊天。好友会看到你处于在线状态。你可以在“自定义首页”中关闭此功能。';

  @override
  String get homeFriendsConsentDecline => '不了，隐藏卡片';

  @override
  String get homeFriendsConsentTitle => '查看哪些好友正在游戏？';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n位好友正在游戏';
  }

  @override
  String get homeFriendsSeeAll => '查看全部';

  @override
  String get homeHideCard => '隐藏此卡片';

  @override
  String homeLeaderboard(String pos) {
    return '排行榜第 $pos 名';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return '剩余$time';
  }

  @override
  String homeLfgNeeds(int n) {
    return '需要$n人';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author，$details';
  }

  @override
  String get homeLfgTitle => '寻找段位相近的队友';

  @override
  String get homeLiveAllyLabel => '我方';

  @override
  String get homeLiveEnemyLabel => '敌方';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return '匹配中，已等待$coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return '我方 $ally，敌方 $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '竞技模式$n连败';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n场可升至$rank';
  }

  @override
  String homeMoreActions(String name) {
    return '$name的选项';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return '重新登录即可更新$riotId的商店、段位和通行证。你仍可查看设备上保存的版本。';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return '剩余$time';
  }

  @override
  String get homeNightMarketNew => '新';

  @override
  String get homeNightMarketTitle => '夜市';

  @override
  String homeNightMarketWaiting(int n) {
    return '$n个优惠等你翻开';
  }

  @override
  String get homeNoRankedToday => '今天还没有进行竞技模式对局';

  @override
  String get homeOpenLfg => '查看所有组队帖';

  @override
  String get homeOpenRanking => '查看皮肤排行';

  @override
  String homeOtherAccountsTitle(int n) {
    return '其他账号（$n）';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n个账号';
  }

  @override
  String get homeOtherWishlistHit => '有心愿单皮肤';

  @override
  String homePreviousAct(String rank) {
    return '上一幕：$rank';
  }

  @override
  String get homeQuietBody => '下拉即可刷新。';

  @override
  String get homeQuietTitle => '暂无新动态';

  @override
  String homeRankToNext(int rr) {
    return '还差 $rr RR 升段';
  }

  @override
  String get homeResetLayout => '恢复默认';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day：$value';
  }

  @override
  String homeRrToday(String value) {
    return '今天 $value';
  }

  @override
  String get homeStatusDetails => '详情';

  @override
  String homeStatusIncident(String region) {
    return '服务器故障 · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return '维护中 · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return '即将维护 · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n条公告';
  }

  @override
  String get homeStoreRefreshing => '正在刷新…';

  @override
  String homeStoreResetsIn(String time) {
    return '$time后刷新';
  }

  @override
  String homeStoreTotal(String vp) {
    return '合计 $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return '钱包 $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return '钱包 $vp · 最多可买$n款皮肤';
  }

  @override
  String get homeStoreWishlistHit => '商店里有心愿单皮肤！';

  @override
  String homeStoreWishlistHits(int n) {
    return '心愿单中有$n款皮肤正在出售';
  }

  @override
  String get homeTitle => '首页';

  @override
  String get homeTrendingTitle => '全球最受喜爱的皮肤';

  @override
  String homeTrendingVotes(int n) {
    return '$n个赞';
  }

  @override
  String get homeUndo => '撤销';

  @override
  String homeWinStreak(int n) {
    return '竞技模式$n连胜';
  }

  @override
  String get homeStoreOutdated => '商店已刷新。ValHub 暂时无法加载新的商店。';

  @override
  String get communityErrorConsent => '请同意与社区分享你的 Riot ID 以继续。';

  @override
  String get communityErrorForbidden => '你暂时无法执行此操作。请查看社区准则或联系 ValHub。';

  @override
  String get communityErrorGeneric => '出了点问题，请重试。';

  @override
  String get communityErrorImageTooLarge => '图片过大（最大 2 MB）。请选择其他图片。';

  @override
  String get communityErrorImageType => '请选择 JPEG、PNG 或 WebP 格式的图片。';

  @override
  String get communityErrorInvalid => '内容未被接受。请检查后重试。';

  @override
  String get communityErrorNetwork => '无法连接 ValHub 社区。请检查网络后重试。';

  @override
  String get communityErrorNotFound => '此内容已不存在。';

  @override
  String get communityErrorPickImage => '无法打开相册，请重试。';

  @override
  String get communityErrorRateLimited => '社区当前请求过多。请过几分钟再试。';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return '社区当前请求过多。请在$duration后重试。';
  }

  @override
  String get communityErrorRiotRejected => 'Riot 无法验证你的账号。请重新登录 Riot 账号后重试。';

  @override
  String get communityErrorRiotUnavailable => 'Riot 出现故障，请过几分钟再试。';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot 出现故障，请在$duration后重试。';
  }

  @override
  String get communityErrorServer => 'ValHub 社区出现故障，请过几分钟再试。';

  @override
  String get communityErrorStorageFull => '社区图片存储空间已满。你仍可发帖，但暂时无法附加图片。请稍后再试。';

  @override
  String get communityErrorTimeout => 'ValHub 社区响应时间过长，请重试。';

  @override
  String get communityErrorTitle => '未能完成';

  @override
  String get communityErrorUnauthorized => '你的社区连接已过期，请重试。';

  @override
  String get communityErrorImageQuota => '你的图片存储空间已用完。请删除一些带图片的帖子后再试。';

  @override
  String get smokePlain => '代码生成检查';

  @override
  String smokeGreeting(String name) {
    return '你好，$name！';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n项');
    return '$_temp0';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get commonListSeparator => '、';

  @override
  String get commonPriceSourceLabel => '查看價目表來源';

  @override
  String get commonErrorApi => 'Riot 目前發生問題，請稍後再試。';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonBack => '返回';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClearFilters => '清除篩選';

  @override
  String get commonClearSearch => '清除搜尋';

  @override
  String get commonClose => '關閉';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonCopied => '已複製';

  @override
  String get commonCopy => '複製';

  @override
  String get commonDaily => '每日';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n 天';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n 天前';
  }

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDone => '完成';

  @override
  String get commonEmptyGeneric => '這裡還沒有任何內容。';

  @override
  String get commonErrorContentUnavailable => '無法載入造型、特務與地圖資訊。請檢查網路後再試一次。';

  @override
  String get commonErrorGeneric => '發生了一些問題，請再試一次。';

  @override
  String get commonErrorMaintenance => 'VALORANT 伺服器維護中，請稍後再回來。';

  @override
  String get commonErrorNeedsLogin => '你的 Riot 登入已過期，請重新登入以繼續。';

  @override
  String get commonErrorNeedsLoginTitle => '需要重新登入';

  @override
  String get commonErrorNetwork => '無法連上網路。請檢查 Wi-Fi 或行動網路後再試一次。';

  @override
  String get commonErrorNoAccount => '你尚未登入任何帳號。';

  @override
  String get commonErrorNotFound => '找不到此內容。';

  @override
  String get commonErrorTimeout => 'Riot 回應時間過長。請檢查連線後再試一次。';

  @override
  String get commonErrorTransient => 'Riot 目前忙碌中，請稍後再試。';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot 目前忙碌中，請在 $duration後再試。';
  }

  @override
  String get commonErrorUnsupportedRegion => '無法確認你的 Riot 地區。請在設定中選擇地區。';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonFilter => '篩選';

  @override
  String get commonGoHome => '回到首頁';

  @override
  String commonHours(int n) {
    return '$n 小時';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n 小時前';
  }

  @override
  String get commonIncidentTitle => '伺服器異常';

  @override
  String get commonJustNow => '剛剛';

  @override
  String get commonLoadMore => '載入更多';

  @override
  String get commonLoading => '載入中…';

  @override
  String get commonMaintenanceTitle => '伺服器維護';

  @override
  String commonMinutes(int n) {
    return '$n 分鐘';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n 分鐘前';
  }

  @override
  String get commonNoData => '目前沒有可顯示的內容';

  @override
  String commonOfflineCached(String time) {
    return '目前離線 — 正在顯示已儲存的資料（$time）。';
  }

  @override
  String get commonOk => '確定';

  @override
  String get commonOpenSettings => '開啟設定';

  @override
  String get commonPageNotFound => '找不到此畫面。';

  @override
  String commonPriceBestPack(String vp, String price) {
    return '最划算的方案：$vp = $price';
  }

  @override
  String get commonPriceEditOwn => '編輯你輸入的價格';

  @override
  String get commonPriceEnterOwn => '輸入你的 VP 方案價格';

  @override
  String get commonPriceEstimateBody =>
      'VP 價格旁的「≈ …」金額為估算值，依最划算的 VP 方案換算。遊戲內以 VP 付款；實際金額依購買時的儲值方案、付款管道、稅金與優惠而定。';

  @override
  String get commonPriceEstimateTitle => '估算換算價格';

  @override
  String get commonPriceEstimateTooltip => '估算價格 — 點一下查看計算方式';

  @override
  String get commonPriceHidden => '已隱藏換算價格。可在設定中重新開啟。';

  @override
  String get commonPriceHide => '隱藏換算價格';

  @override
  String get commonPriceOpenSource => '開啟來源頁面';

  @override
  String get commonPriceOverrideBody =>
      '輸入你購買一個 VP 方案實際支付的金額（可在遊戲內商店或收據查看）。ValHub 會用此價格估算所有物品的換算價格；價格只會儲存在這台裝置上。';

  @override
  String get commonPriceOverrideCurrency => '貨幣代碼';

  @override
  String get commonPriceOverrideCurrencyHint => '例如：TWD、USD、EUR、JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return '估算範例：$vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      '請輸入 3 個字母的貨幣代碼，例如 TWD 或 USD。';

  @override
  String get commonPriceOverrideInvalidNumber => '請輸入大於 0 的數字。';

  @override
  String get commonPriceOverridePrice => '方案價格';

  @override
  String get commonPriceOverrideRemove => '刪除已輸入的價格';

  @override
  String get commonPriceOverrideRemoved => '已刪除你輸入的價格。';

  @override
  String get commonPriceOverrideSave => '儲存價格';

  @override
  String get commonPriceOverrideSaved => '已儲存你的 VP 方案價格。';

  @override
  String get commonPriceOverrideTitle => '你的 VP 方案價格';

  @override
  String get commonPriceOverrideVp => '方案的 VP 數量';

  @override
  String get commonPricePacksTitle => 'VP 方案';

  @override
  String commonPriceSourceOfficial(String country) {
    return '依據 $country 地區的 VP 方案價目表';
  }

  @override
  String get commonPriceSourceUser => '依據你輸入的 VP 方案價格';

  @override
  String get commonPriceUnavailable =>
      '你所在的地區尚無已驗證的價目表。輸入你曾購買的 VP 方案價格，即可查看估算換算價格。';

  @override
  String commonPriceUpdated(String date) {
    return '價目表更新：$date';
  }

  @override
  String get commonPullToRefresh => '下拉以重新整理';

  @override
  String get commonRefresh => '重新整理';

  @override
  String get commonRetry => '重試';

  @override
  String get commonRiotDisclaimer =>
      'ValHub 並未獲得 Riot Games 認可，亦不代表 Riot Games 或任何正式參與製作或管理 Riot Games 產品之人士的觀點或意見。Riot Games 及所有相關資產皆為 Riot Games, Inc. 的商標或註冊商標。';

  @override
  String get commonSave => '儲存';

  @override
  String get commonSearch => '搜尋…';

  @override
  String commonSeconds(int n) {
    return '$n 秒';
  }

  @override
  String get commonSeeAll => '查看全部';

  @override
  String get commonShare => '分享';

  @override
  String get commonSignInAgain => '重新登入';

  @override
  String get commonSort => '排序';

  @override
  String commonSortBy(String option) {
    return '排序：$option';
  }

  @override
  String get commonSortName => '名稱 A–Z';

  @override
  String get commonSortNewest => '最新';

  @override
  String get commonSortPriceHigh => '價格由高到低';

  @override
  String get commonSortPriceLow => '價格由低到高';

  @override
  String get commonSortRarity => '稀有度';

  @override
  String get commonSortWeapon => '武器';

  @override
  String get commonTabBattlePass => '戰鬥通行證';

  @override
  String get commonTabCollection => '收藏庫';

  @override
  String get commonTabCommunity => '社群';

  @override
  String get commonTabHome => '首頁';

  @override
  String get commonTabProfile => '個人檔案';

  @override
  String get commonTabSettings => '設定';

  @override
  String get commonTabStore => '商店';

  @override
  String get commonTagline => '你的 VALORANT 好幫手';

  @override
  String get commonToday => '今天';

  @override
  String get commonTodayLower => '今天';

  @override
  String get commonTomorrow => '明天';

  @override
  String get commonUnknownItem => '未知名稱的物品';

  @override
  String commonUpdatedAt(String time) {
    return '更新於 $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day $time';
  }

  @override
  String get commonWeekdaysItem0 => '星期一';

  @override
  String get commonWeekdaysItem1 => '星期二';

  @override
  String get commonWeekdaysItem2 => '星期三';

  @override
  String get commonWeekdaysItem3 => '星期四';

  @override
  String get commonWeekdaysItem4 => '星期五';

  @override
  String get commonWeekdaysItem5 => '星期六';

  @override
  String get commonWeekdaysItem6 => '星期日';

  @override
  String get commonYesterday => '昨天';

  @override
  String get commonYesterdayTitle => '昨天';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot 登入已過期 — 正在顯示已儲存的資料（$time）。';
  }

  @override
  String get contentCategoryHeavy => '重型武器';

  @override
  String get contentCategoryMelee => '近戰武器';

  @override
  String get contentCategoryRifle => '突擊步槍';

  @override
  String get contentCategoryShotgun => '霰彈槍';

  @override
  String get contentCategorySidearm => '隨身武器';

  @override
  String get contentCategorySmg => '衝鋒槍';

  @override
  String get contentCategorySniper => '狙擊槍';

  @override
  String get contentCurrencyAgentTokens => '特務代幣';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => '王國幣';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => '輻能點數';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => '特務幣';

  @override
  String get contentDefaultSkin => '預設';

  @override
  String get contentItemAgent => '特務';

  @override
  String get contentItemBuddy => '槍枝吊飾';

  @override
  String get contentItemCard => '玩家卡片';

  @override
  String get contentItemChroma => '色彩';

  @override
  String get contentItemContract => '合約';

  @override
  String get contentItemCurrency => '貨幣';

  @override
  String get contentItemFlex => '炫耀道具';

  @override
  String get contentItemLanguageEn => '英文';

  @override
  String get contentItemLanguageTitle => '物品名稱';

  @override
  String get contentItemLanguageVi => '越南文';

  @override
  String get contentItemLevelBorder => '等級邊框';

  @override
  String get contentItemSkin => '造型';

  @override
  String get contentItemSpray => '噴漆';

  @override
  String get contentItemTitle => '玩家稱號';

  @override
  String contentLevel(int n) {
    return '等級 $n';
  }

  @override
  String get contentLevelBase => '基本';

  @override
  String get contentLevelItemLabelsVFX => '視覺特效';

  @override
  String get contentLevelItemLabelsAnimation => '動畫';

  @override
  String get contentLevelItemLabelsFinisher => '終結特效';

  @override
  String get contentLevelItemLabelsKillCounter => '擊殺計數器';

  @override
  String get contentLevelItemLabelsSoundEffects => '音效';

  @override
  String get contentLevelItemLabelsTransformation => '變形';

  @override
  String get contentLevelItemLabelsKillBanner => '擊殺旗幟';

  @override
  String get contentLevelItemLabelsKillEffect => '擊殺特效';

  @override
  String get contentLevelItemLabelsInspectAndKill => '檢視與擊殺特效';

  @override
  String get contentLevelItemLabelsVoiceover => '語音';

  @override
  String get contentLevelItemLabelsSongShuffle => '隨機播放歌曲';

  @override
  String get contentLevelItemLabelsRandomizer => '隨機化';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap => '依攻守方切換';

  @override
  String get contentLevelItemLabelsTopFrag => '最高擊殺特效';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor => '心跳與地圖感應器';

  @override
  String get contentLevelItemLabelsFishAnimation => '魚類動畫';

  @override
  String get contentLimitedEdition => '限量版';

  @override
  String get contentNoSpray => '無';

  @override
  String get contentNoTitle => '無稱號';

  @override
  String get contentNotForSale => '非賣品';

  @override
  String get contentQueueNamesCompetitive => '競技模式';

  @override
  String get contentQueueNamesUnrated => '一般模式';

  @override
  String get contentQueueNamesSwiftplay => '超速衝點';

  @override
  String get contentQueueNamesSpikerush => '輻能搶攻戰';

  @override
  String get contentQueueNamesDeathmatch => '死鬥模式';

  @override
  String get contentQueueNamesHurm => '團隊死鬥模式';

  @override
  String get contentQueueNamesGgteam => '超激進戰';

  @override
  String get contentQueueNamesOnefa => '複製亂戰';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => '自訂對戰';

  @override
  String get contentQueueNames => '自訂對戰';

  @override
  String get contentQueueNamesDodgeball => '殲滅戰';

  @override
  String get contentQueueNamesFortcollins => '奪還作戰';

  @override
  String get contentQueueNamesSkirmish2v2 => '火線交鋒：2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => '「火線交鋒：晉級賽」1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => '「火線交鋒：晉級賽」2v2';

  @override
  String get contentQueueNamesValaram => '隨機單點';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => '打雪仗';

  @override
  String get contentQueueNamesNewmap => '頂峰亭閣';

  @override
  String get contentQueueShortNamesCompetitive => '競技';

  @override
  String get contentQueueShortNamesValaram => '隨機單點';

  @override
  String get contentRewardSourceAgent => '特務合約';

  @override
  String get contentRewardSourceBattlePass => '戰鬥通行證獎勵';

  @override
  String get contentRewardSourceEvent => '活動通行證';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => '決鬥者';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => '先鋒';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => '控場者';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => '守衛';

  @override
  String get contentTierDeluxe => '奢華';

  @override
  String get contentTierExclusive => '限定';

  @override
  String contentTierFull(String shortName) {
    return '$shortName版本';
  }

  @override
  String get contentTierPremium => '尊爵';

  @override
  String get contentTierSelect => '精選';

  @override
  String get contentTierUltra => '究極';

  @override
  String get contentUnranked => '未排名';

  @override
  String get accountRegionUnknown => '伺服器不明';

  @override
  String accountRiotCountry(String country) {
    return 'Riot 帳號國家／地區：$country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riot 帳號國家／地區：未確定';

  @override
  String accountAccountCount(int count, int max) {
    return '$count/$max 個帳號';
  }

  @override
  String accountAccountsHeader(int count, int max) {
    return '帳號（$count/$max）';
  }

  @override
  String get accountActive => '使用中';

  @override
  String accountAddAccount(int count, int max) {
    return '新增帳號（$count/$max）';
  }

  @override
  String get accountClearLocalData => '清除本機資料';

  @override
  String get accountClearLocalDataConfirm =>
      '要清除這台裝置上的紀錄、已儲存的裝備組合，以及已登出帳號的資料嗎？';

  @override
  String get accountClearRrHistory => '清除 RR 紀錄';

  @override
  String get accountClearRrHistoryConfirm => '要清除這台裝置上所選帳號的 RR 紀錄嗎？';

  @override
  String get accountCopyPassword => '複製密碼';

  @override
  String get accountCopyUsername => '複製使用者名稱';

  @override
  String get accountDeleteLoginNote => '刪除資訊';

  @override
  String get accountDeleteLoginNoteConfirm => '要刪除此帳號已儲存的使用者名稱與密碼嗎？';

  @override
  String get accountHidePassword => '隱藏密碼';

  @override
  String get accountKeepLocalData => '保留本機資料';

  @override
  String get accountKeepLocalDataHint => '在這台裝置上保留願望清單、裝備組合與紀錄';

  @override
  String accountLevelShort(int level) {
    return '等級 $level';
  }

  @override
  String get accountLinkAccountMissing => '此通知中的帳號已登出。請重新登入後再開啟通知。';

  @override
  String get accountLocalDataCleared => '已清除本機資料';

  @override
  String get accountLoginNote => '登入資訊';

  @override
  String get accountLoginNoteDeleted => '已刪除登入資訊';

  @override
  String get accountLoginNoteEmpty => '尚未儲存登入資訊';

  @override
  String get accountLoginNoteHint => '只會加密儲存在這台裝置上。可在重新登入時查看或快速填入。';

  @override
  String get accountLoginNoteLocked => '解鎖登入資訊';

  @override
  String get accountLoginNotePassword => '密碼';

  @override
  String get accountLoginNoteSaved => '已儲存登入資訊';

  @override
  String get accountLoginNoteUsername => 'Riot 使用者名稱';

  @override
  String get accountManageHint => '可在設定中移除帳號或編輯登入資訊。';

  @override
  String accountMaxAccounts(int max) {
    return '已達帳號上限（$max 個）。';
  }

  @override
  String get accountNeedsLogin => '需要重新登入';

  @override
  String accountOnlineCount(int count) {
    return '$count 人在線上';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => '填入已儲存的帳號';

  @override
  String get accountQuickFillDone => '已填入完成，請點選「登入」。';

  @override
  String get accountQuickFillNotReady => '登入頁面尚未載入完成。請稍等一下再試一次。';

  @override
  String get accountQuickFillSubtitle => '選擇要填入 Riot 登入頁面的帳號';

  @override
  String get accountQuickFillTitle => '填入已儲存的帳號';

  @override
  String get accountRegionAp => '亞太地區';

  @override
  String get accountRegionBr => '巴西';

  @override
  String get accountRegionEu => '歐洲';

  @override
  String get accountRegionKr => '韓國';

  @override
  String get accountRegionLatam => '拉丁美洲';

  @override
  String get accountRegionNa => '北美';

  @override
  String get accountRemoveAccount => '移除帳號';

  @override
  String accountRemoveAccountConfirm(String account) {
    return '要從這台裝置移除 $account 嗎？你可以選擇保留已儲存的資料。';
  }

  @override
  String get accountRrHistoryCleared => '已清除 RR 紀錄';

  @override
  String get accountShowPassword => '顯示密碼';

  @override
  String get accountSignOutAll => '登出所有帳號';

  @override
  String get accountSignOutAllConfirm => '要登出並從這台裝置移除所有帳號嗎？你可以選擇保留已儲存的資料。';

  @override
  String get accountStatusAgentSelect => '選擇特務中';

  @override
  String get accountStatusInMatch => '對戰中';

  @override
  String get accountStatusOffline => '離線';

  @override
  String get accountStatusOnline => '線上';

  @override
  String get accountStatusUnknown => '狀態不明';

  @override
  String get accountSwitchFailed => '無法切換帳號，請再試一次。';

  @override
  String accountSwitchTo(String account) {
    return '切換至 $account';
  }

  @override
  String get accountSwitcherSubtitle => '點一下即可切換帳號';

  @override
  String get accountSwitcherTitle => '帳號';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return '帳號（$count/$max）';
  }

  @override
  String get accountUnknownPlayer => '玩家';

  @override
  String get accountUnlockLoginNote => '驗證身分以解鎖 Riot 登入資訊';

  @override
  String get authAccountAlreadyAdded => '此帳號已新增過';

  @override
  String get authAddAsNew => '新增為新帳號';

  @override
  String get authDifferentAccountBody => '你登入的帳號與需要重新登入的帳號不同。要將此帳號新增為新帳號嗎？';

  @override
  String get authDifferentAccountTitle => '不同的帳號';

  @override
  String get authLoadingAccount => '正在載入帳號…';

  @override
  String get authLoginCancelledByRiot => 'Riot 拒絕了這次登入，請再試一次。';

  @override
  String get authLoginFailed => '無法完成登入';

  @override
  String get authLoginFailedBody => 'Riot 尚未確認你的登入，請再試一次。';

  @override
  String get authLoginTitle => 'Riot 登入';

  @override
  String get authMissingCookies => '無法在這台裝置上保存登入狀態，登入過期時你需要重新登入。';

  @override
  String get authOfficialHost => '官方頁面 · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => '已在瀏覽器中開啟連結。';

  @override
  String get authPageLoadFailed => '無法載入 Riot 登入頁面。請檢查網路後再試一次。';

  @override
  String get authPreparing => '正在準備登入頁面…';

  @override
  String get authReloginDone => '已重新登入';

  @override
  String get authRememberMeHint => '請開啟「保持登入」，就不必再重新登入。';

  @override
  String get authSignInCta => '使用 Riot 帳號登入';

  @override
  String get authSignInNote =>
      '你會在 Riot 官方頁面登入。只有在你自行選擇儲存登入資訊時，ValHub 才會儲存密碼；登入資料與已儲存的資訊只會保留在你的裝置上。';

  @override
  String get authSocialLoginHint =>
      '如果無法使用 Google 或 Facebook 登入，請改用 Riot 使用者名稱。';

  @override
  String get authStateMismatch => '這次登入無效，請從頭重新登入。';

  @override
  String get notificationSessionExpiredBody => '重新登入即可繼續接收願望清單通知。';

  @override
  String get notificationBackgroundTimingHint => '裝置的省電模式可能會延遲通知。';

  @override
  String get notificationChannelAccountDescription => '在帳號需要重新登入時提醒你';

  @override
  String get notificationChannelAccountName => '帳號';

  @override
  String get notificationChannelBattlePassDescription => '提醒戰鬥通行證進度與結束日期';

  @override
  String get notificationChannelBattlePassName => '戰鬥通行證';

  @override
  String get notificationChannelCommunityDescription => '開啟 ValHub 時通知社群動態';

  @override
  String get notificationChannelCommunityName => '社群';

  @override
  String get notificationChannelLfgDescription => '開啟 ValHub 時通知有玩家加入隊伍';

  @override
  String get notificationChannelLfgName => '隊伍';

  @override
  String get notificationChannelNightMarketDescription => '夜市開放時通知你';

  @override
  String get notificationChannelNightMarketName => '夜市';

  @override
  String get notificationChannelRankDescription => '更新個人檔案時通知牌位變化';

  @override
  String get notificationChannelRankName => '牌位';

  @override
  String get notificationChannelStoreResetDescription => '每日商店更新時提醒你';

  @override
  String get notificationChannelStoreResetName => '商店更新';

  @override
  String get notificationChannelWishlistDescription => '願望清單中的造型出現在商店時通知你';

  @override
  String get notificationChannelWishlistName => '願望清單';

  @override
  String get notificationLfgJoinedTitle => '有玩家加入了隊伍';

  @override
  String get notificationLocalOnlyHint => '只會在 ValHub 更新資料時於這台裝置上通知';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return '$account 的 $cards 張優惠卡片正等你翻開！';
  }

  @override
  String get notificationNightMarketOpenTitle => '夜市開張了！';

  @override
  String get notificationPassEndingBody => '戰鬥通行證剩下約一天。開啟 ValHub 查看最新進度。';

  @override
  String get notificationPassEndingTitle => '戰鬥通行證即將結束';

  @override
  String notificationPassProgressBody(int level) {
    return '你已在目前的戰鬥通行證達到等級 $level。';
  }

  @override
  String get notificationPassProgressTitle => '戰鬥通行證進度';

  @override
  String get notificationPrivateAccount => '你的帳號';

  @override
  String notificationRankChangedBody(String rank) {
    return '目前牌位：$rank。資料剛從 Riot 更新。';
  }

  @override
  String get notificationRankChangedTitle => '牌位已變動';

  @override
  String get notificationResetTimingUnknown => '開啟商店以更新你裝置上的商店更新時間。';

  @override
  String get notificationSessionExpiredTitle => '需要重新登入';

  @override
  String get notificationStoreResetBody => '商店裡有新造型等著你。';

  @override
  String get competitiveDivisionIron => '鐵牌';

  @override
  String get competitiveDivisionBronze => '銅牌';

  @override
  String get competitiveDivisionSilver => '銀牌';

  @override
  String get competitiveDivisionGold => '金牌';

  @override
  String get competitiveDivisionPlatinum => '白金';

  @override
  String get competitiveDivisionDiamond => '鑽石';

  @override
  String get competitiveDivisionAscendant => '超凡入聖';

  @override
  String get competitiveDivisionImmortal => '神話';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division$number';
  }

  @override
  String get competitiveDivisionRadiant => '輻能戰魂';

  @override
  String get competitiveRankUnknown => '牌位不明';

  @override
  String get competitiveAttack => '進攻';

  @override
  String get competitiveCannotEstimate => '無法估算';

  @override
  String get competitiveDefeat => '落敗';

  @override
  String get competitiveDefense => '防守';

  @override
  String get competitiveDraw => '平手';

  @override
  String get competitiveIncognitoPlayer => '隱藏的玩家';

  @override
  String get competitiveMatchPending => 'Riot 正在處理這場對戰…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return '還剩 $n 場定位賽';
  }

  @override
  String get competitiveRoundDefuse => '拆除輻能核心';

  @override
  String get competitiveRoundDetonate => '輻能核心引爆';

  @override
  String get competitiveRoundElimination => '全數殲滅';

  @override
  String get competitiveRoundSurrendered => '投降';

  @override
  String get competitiveRoundTimeExpired => '時間到';

  @override
  String get competitiveUnknownPlayer => '玩家';

  @override
  String get competitiveVictory => '勝利';

  @override
  String economyAvailableNow(String place) {
    return '現已出現在$place！';
  }

  @override
  String get economyCollectionValue => '收藏庫價值';

  @override
  String get economyExcludedRewards => '不含獎勵造型';

  @override
  String economyPlaceBundle(String name) {
    return '$name組合包';
  }

  @override
  String get economyPlaceBundleGeneric => '組合包';

  @override
  String get economyPlaceDaily => '每日商店';

  @override
  String get economyPlaceNightMarket => '夜市';

  @override
  String get economyPriceEstimated => '依版本估算的價格';

  @override
  String get economyPriceFromOffers => '價格來自 Riot 價目表';

  @override
  String get economyPriceFromStore => '在商店中看到的價格';

  @override
  String get economyPriceFromTable => '標價';

  @override
  String get economyPriceUnknown => '價格不明';

  @override
  String get economyValueHasEstimates => '含估算價格（≈）';

  @override
  String get economyWishlistValue => '願望清單總價值';

  @override
  String loadoutDefaultPresetName(int n) {
    return '裝備組合 $n';
  }

  @override
  String get loadoutInvalidChange => '此變更無法套用到目前的裝備。';

  @override
  String get loadoutNotPersisted => 'Riot 尚未儲存你的變更，裝備維持原樣。請再試一次。';

  @override
  String get loadoutSaveFailed => '無法儲存裝備';

  @override
  String get battlePassActEnded => '本章已結束';

  @override
  String battlePassActEndsIn(String time) {
    return '本章將於 $time後結束';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return '本章將於 $days 天後結束';
  }

  @override
  String get battlePassAllMissionsDone => '已完成所有任務';

  @override
  String get battlePassAllWeeklyDone => '已完成所有每週任務';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return '待領取雙倍獎勵：$n';
  }

  @override
  String battlePassChapter(int n) {
    return '階段 $n';
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
  String get battlePassCheckpoint => '檢查點';

  @override
  String get battlePassCheckpointHint => '贏得回合即可推進檢查點（死鬥模式不計）。';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return '檢查點 $index：$charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => '每個檢查點：+XP、+KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return '已達成 $done/$total 個檢查點';
  }

  @override
  String get battlePassCurrentChapter => '目前';

  @override
  String get battlePassDailyAllDone => '已完成今天的所有檢查點';

  @override
  String get battlePassDailyCaption => '每日獎勵';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return '每日獎勵 · $reset';
  }

  @override
  String get battlePassDailyExpired => '前一天的檢查點已過期。請進入遊戲或在這裡重新整理。';

  @override
  String get battlePassDailyMissions => '每日任務';

  @override
  String get battlePassDailyNotReady => '今天的檢查點尚未準備好。請進入遊戲或在這裡重新整理。';

  @override
  String get battlePassDailyPlayToStart => '今天的檢查點尚未準備好。請進入遊戲以開始新的一天。';

  @override
  String battlePassDaysLeft(int days) {
    return '剩下 $days 天';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return '結束時間：$wall';
  }

  @override
  String get battlePassEpilogue => '尾聲';

  @override
  String get battlePassEstimateNote => '以每場約 4,000 XP 估算，不含任務。';

  @override
  String battlePassEventEndsIn(String time) {
    return '將於 $time後結束';
  }

  @override
  String get battlePassEventPass => '活動通行證';

  @override
  String get battlePassFilterAll => '全部';

  @override
  String get battlePassFilterLocked => '未解鎖';

  @override
  String get battlePassFilterUnlocked => '已解鎖';

  @override
  String get battlePassFree => '免費';

  @override
  String get battlePassFreeTrack => '免費獎勵';

  @override
  String battlePassLevelOf(String level, String count) {
    return '等級 $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return '等級 $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$queue：≈ $nString 場';
  }

  @override
  String get battlePassMissionDone => '已完成';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '已完成 $done/$total';
  }

  @override
  String get battlePassMissionsProgressLabel => '每週任務進度';

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return '新任務時間：$wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return '新任務將於 $time後出現';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return '下一個檢查點：$charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return '升至等級 $level';
  }

  @override
  String get battlePassNextReward => '下一個';

  @override
  String get battlePassNoBattlePass => '目前尚無本章的戰鬥通行證資訊。請稍後再試。';

  @override
  String get battlePassNoRewards => '此戰鬥通行證尚無任何獎勵。';

  @override
  String get battlePassNoRewardsInFilter => '此分類中沒有任何獎勵。';

  @override
  String get battlePassNoRewardsTitle => '尚無獎勵';

  @override
  String get battlePassNoWeeklyMissions => '目前沒有每週任務。';

  @override
  String get battlePassPassComplete => '已完成戰鬥通行證';

  @override
  String get battlePassPremium => '高級版';

  @override
  String get battlePassPremiumHint => '你尚未購買高級版：只能獲得免費獎勵。在遊戲內購買高級版即可解鎖已達成的等級。';

  @override
  String get battlePassRenewButton => '重新整理檢查點';

  @override
  String get battlePassRenewDone => '已重新整理每日檢查點。';

  @override
  String get battlePassRenewFailed => '無法重新整理檢查點。請稍後再試。';

  @override
  String battlePassResetsAtWall(String wall) {
    return '重置時間：$wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return '將於 $time後重置';
  }

  @override
  String get battlePassRewardLevelLabel => '等級';

  @override
  String get battlePassRewardLocked => '未解鎖';

  @override
  String get battlePassRewardNeedsPremium => '需要高級版';

  @override
  String get battlePassRewardStatusLabel => '狀態';

  @override
  String get battlePassRewardTrackLabel => '獎勵類型';

  @override
  String get battlePassRewardTypeLabel => '類型';

  @override
  String get battlePassRewardUnlocked => '已解鎖';

  @override
  String get battlePassRewardsTitle => '獎勵';

  @override
  String get battlePassShowAllRewards => '查看全部';

  @override
  String get battlePassTitle => '戰鬥通行證';

  @override
  String get battlePassTotalXpCaption => '總 XP';

  @override
  String get battlePassUnknownMission => '新任務（尚無說明）';

  @override
  String get battlePassUnknownReward => '獎勵';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '已解鎖 $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => '一般模式';

  @override
  String get battlePassViewAllRewards => '查看所有獎勵';

  @override
  String get battlePassWeeklyMissions => '每週任務';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return '每週任務尚有 +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / 天';
  }

  @override
  String get battlePassXpPerDayCaption => '每天需要的 XP，才能及時完成';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return '還需要 $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return '無法儲存裝備。$detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': '你擁有的所有造型，依商店價格計算價值',
      'buddy': '已擁有的槍枝吊飾與複本數量',
      'spray': '可加入表情輪盤的噴漆',
      'card': '已解鎖的玩家卡片，點一下即可查看與裝備',
      'title': '可顯示在名稱下方的玩家稱號',
      'flex': '已擁有的炫耀道具',
      'other': '瀏覽收藏庫',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return '欄位：$position';
  }

  @override
  String get collectionApplyPreset => '套用';

  @override
  String get collectionApplyPresetBody => '目前使用中的造型、槍枝吊飾、表情輪盤、卡片與稱號將替換為此組合。';

  @override
  String collectionApplyPresetTitle(String name) {
    return '要套用「$name」嗎？';
  }

  @override
  String get collectionBannerTitlePrefix => '稱號：';

  @override
  String get collectionBrowseBuddies => '槍枝吊飾';

  @override
  String get collectionBrowseCards => '玩家卡片';

  @override
  String get collectionBrowseEmpty => '你在此分類中還沒有任何物品。';

  @override
  String get collectionBrowseEmptyTitle => '尚無物品';

  @override
  String get collectionBrowseFlex => '炫耀道具';

  @override
  String get collectionBrowseSkins => '造型';

  @override
  String get collectionBrowseSprays => '噴漆';

  @override
  String get collectionBrowseTitle => '瀏覽收藏庫';

  @override
  String get collectionBrowseTitles => '玩家稱號';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return '剩餘 $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return '用於 $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => '選擇槍枝吊飾';

  @override
  String get collectionBuddyRemoved => '已卸下槍枝吊飾';

  @override
  String get collectionBuddySlot => '槍枝吊飾';

  @override
  String get collectionBuddyUnavailable => '無法裝上此槍枝吊飾。請重新整理或選擇其他吊飾。';

  @override
  String get collectionCachedLoadout => '正在顯示已儲存的裝備。進行變更前，請先下拉重新整理。';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已擁有 $nString 張卡片';
  }

  @override
  String get collectionChangeBuddy => '更換';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total 種色彩';
  }

  @override
  String get collectionClearFilters => '清除篩選';

  @override
  String get collectionClearSearch => '清除搜尋';

  @override
  String get collectionClearTiers => '清除版本篩選';

  @override
  String get collectionCollectionValue => '收藏庫價值';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => '預設';

  @override
  String get collectionDeletePreset => '刪除';

  @override
  String get collectionEmptySlot => '空';

  @override
  String get collectionEquip => '裝備';

  @override
  String get collectionEquipped => '使用中';

  @override
  String get collectionEquippedCard => '使用中的卡片';

  @override
  String collectionEquippedCardLabel(String name) {
    return '使用中的卡片：$name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '已裝備 $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return '使用中：$skin';
  }

  @override
  String get collectionExcludedRewards => '不含獎勵造型';

  @override
  String get collectionExpressionsHint => '點一下欄位即可選擇噴漆或炫耀道具。';

  @override
  String get collectionExpressionsSlots => '輪盤欄位';

  @override
  String get collectionExpressionsTitle => '表情輪盤';

  @override
  String get collectionFilterTiers => '版本';

  @override
  String get collectionHideAccountLevel => '隱藏帳號等級';

  @override
  String get collectionHideAccountLevelHint => '其他玩家將看不到你的帳號等級。';

  @override
  String get collectionIncognito => '匿名模式';

  @override
  String get collectionIncognitoHint => '在對戰中對非隊伍成員的玩家隱藏你的名稱。';

  @override
  String collectionItemsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 件物品';
  }

  @override
  String get collectionLevelBorderAuto => '依等級自動';

  @override
  String get collectionLevelBorderEmpty => '你目前的等級還沒有可用的等級邊框。';

  @override
  String collectionLevelBorderFrom(int level) {
    return '等級 $level 起';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return '帳號等級 $level';
  }

  @override
  String get collectionLevelBorderTitle => '選擇等級邊框';

  @override
  String collectionLevelCount(int owned, int total) {
    return '等級 $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return '等級 $n · $type';
  }

  @override
  String get collectionLevels => '等級';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '已解鎖 $owned/$total 個等級';
  }

  @override
  String get collectionLobbyBanner => '大廳橫幅';

  @override
  String get collectionLocked => '未解鎖';

  @override
  String get collectionMeleeNoBuddy => '近戰武器無法裝上槍枝吊飾。';

  @override
  String get collectionMove => '移動';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy 目前裝在 $from 上。要移到 $to 嗎？';
  }

  @override
  String get collectionMoveBuddyTitle => '要移動槍枝吊飾嗎？';

  @override
  String get collectionNoBuddies => '你還沒有任何槍枝吊飾。';

  @override
  String get collectionNoBuddy => '未裝上吊飾';

  @override
  String get collectionNoFlex => '你還沒有任何炫耀道具。';

  @override
  String get collectionNoResults => '找不到符合的結果。';

  @override
  String get collectionNoResultsTitle => '找不到結果';

  @override
  String get collectionNoSkinsForWeapon => '你還沒有這把武器的任何造型。';

  @override
  String get collectionNoSprays => '你還沒有任何噴漆。';

  @override
  String get collectionNoTitle => '無稱號';

  @override
  String get collectionOtherWeapons => '其他';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '已擁有 $n 款造型',
      zero: '還沒有造型',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已擁有 $nString 款造型';
  }

  @override
  String get collectionPlayLevelVideo => '觀看此等級的影片';

  @override
  String get collectionPlayVideo => '觀看影片';

  @override
  String get collectionPlayerCardSubtitle => '會顯示在大廳、計分板，以及你擊殺敵人時。';

  @override
  String get collectionPlayerCardTitle => '更換玩家卡片';

  @override
  String get collectionPlayerTitleSubtitle => '會顯示在大廳與對戰中你的名稱下方。';

  @override
  String get collectionPlayerTitleTitle => '更換玩家稱號';

  @override
  String get collectionPresetActions => '選項';

  @override
  String collectionPresetApplied(String name) {
    return '已套用「$name」';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 組',
      zero: '尚無',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '已刪除「$name」';
  }

  @override
  String get collectionPresetNameHint => '例如：衝牌位';

  @override
  String get collectionPresetNameTitle => '裝備組合名稱';

  @override
  String collectionPresetSaved(String name) {
    return '已儲存「$name」';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return '儲存於 $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return '已略過 $n 個你不再擁有的物品。';
  }

  @override
  String get collectionPresetsEmpty => '儲存目前的裝備，之後就能快速切換不同的造型、卡片與表情輪盤組合。';

  @override
  String get collectionPresetsEmptyTitle => '尚無裝備組合';

  @override
  String get collectionPresetsFull => '已達 50 組裝備組合的上限。請刪除部分組合後再儲存。';

  @override
  String get collectionPresetsNote => '裝備組合只會儲存在這台裝置上，並僅適用於所選帳號。';

  @override
  String get collectionPresetsTitle => '已儲存的裝備組合';

  @override
  String get collectionPreview => '預覽';

  @override
  String get collectionPreviewing => '預覽中';

  @override
  String get collectionRemoveBuddy => '卸下吊飾';

  @override
  String get collectionRenamePreset => '重新命名';

  @override
  String get collectionRowCard => '玩家卡片';

  @override
  String get collectionRowExpressions => '表情輪盤';

  @override
  String get collectionRowLevelBorder => '等級邊框';

  @override
  String get collectionRowPresets => '已儲存的裝備組合';

  @override
  String get collectionRowTitle => '玩家稱號';

  @override
  String get collectionRowWeapons => '武器裝備';

  @override
  String get collectionRowWishlist => '願望清單';

  @override
  String get collectionSaveFailed => '無法儲存裝備';

  @override
  String get collectionSavePreset => '儲存目前的裝備';

  @override
  String get collectionSaving => '正在儲存…';

  @override
  String get collectionSearchBuddies => '搜尋槍枝吊飾…';

  @override
  String get collectionSearchCards => '搜尋玩家卡片…';

  @override
  String get collectionSearchFlex => '搜尋炫耀道具…';

  @override
  String get collectionSearchItems => '搜尋…';

  @override
  String get collectionSearchSkins => '搜尋造型…';

  @override
  String get collectionSearchSprays => '搜尋噴漆…';

  @override
  String get collectionSearchTitles => '搜尋稱號…';

  @override
  String get collectionSearchWeapons => '搜尋武器、造型或吊飾…';

  @override
  String get collectionSectionBrowse => '瀏覽收藏庫';

  @override
  String get collectionSectionIdentity => '其他玩家可見';

  @override
  String get collectionSectionLoadout => '裝備';

  @override
  String get collectionSkinCustomizeTitle => '自訂造型';

  @override
  String get collectionSkinNotFound => '找不到此造型。';

  @override
  String get collectionSkinNotOwned => '你尚未擁有此造型。';

  @override
  String get collectionSlotNamesItem0 => '上';

  @override
  String get collectionSlotNamesItem1 => '右';

  @override
  String get collectionSlotNamesItem2 => '下';

  @override
  String get collectionSlotNamesItem3 => '左';

  @override
  String get collectionSortLabel => '排序';

  @override
  String get collectionSortName => '名稱';

  @override
  String get collectionSortPrice => '價格';

  @override
  String get collectionSortRarity => '稀有度';

  @override
  String get collectionSortWeapon => '武器';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return '篩選中：$count 款造型 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return '篩選中：$count/$total 個物品';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count 個物品';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count 款造型 · $value';
  }

  @override
  String get collectionTabFlex => '炫耀道具';

  @override
  String get collectionTabSprays => '噴漆';

  @override
  String get collectionTapToChangeCard => '點一下即可更換卡片';

  @override
  String get collectionTitle => '收藏庫';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '已擁有 $nString 個稱號';
  }

  @override
  String get collectionUndo => '復原';

  @override
  String get collectionUnknownCard => '未知名稱的卡片';

  @override
  String get collectionValueAtStorePrices => '依商店價格計算';

  @override
  String get collectionValueHasEstimates => '含估算價格（≈）';

  @override
  String collectionValueRewardCount(int n) {
    return '未計入 $n 款獎勵造型';
  }

  @override
  String get collectionValueSeeSkins => '查看造型';

  @override
  String collectionValueSkinCount(int n) {
    return '依 $n 款造型計算';
  }

  @override
  String get collectionVariants => '色彩';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total 把武器使用造型中';
  }

  @override
  String get collectionWeaponLoadoutTitle => '武器裝備';

  @override
  String get collectionWeaponNotFound => '找不到此武器。';

  @override
  String get collectionWeaponSkinsTitle => '選擇造型';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 款造型',
      zero: '空',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      '內容含有不當用語，無法發布。請修改內容後再試一次。';

  @override
  String get communityModerationContentScam =>
      '社群不允許買賣帳號、代打廣告或留下電話號碼。請移除這些內容後再試一次。';

  @override
  String get communityModerationContentTooComplex =>
      '內容含有過多零散的字元。請寫得簡潔一點後再試一次。';

  @override
  String get communityModerationAccountBanned =>
      '此帳號已被停用社群功能。如果你認為有誤，請透過「關於與法律資訊」聯絡 ValHub。';

  @override
  String get communityModerationAccountRestricted =>
      '此帳號目前被限制發文、留言、尋找隊友與投票。請稍後再試，或透過「關於與法律資訊」聯絡 ValHub。';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': '競技模式',
      'unrated': '一般模式',
      'swiftplay': '超速衝點',
      'spikerush': '輻能搶攻戰',
      'deathmatch': '死鬥模式',
      'teamdeathmatch': '團隊死鬥模式',
      'premier': 'Premier',
      'custom': '自訂對戰',
      'other': '其他',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': '亞太地區',
      'na': '北美',
      'eu': '歐洲',
      'kr': '韓國',
      'latam': '拉丁美洲',
      'br': '巴西',
      'other': '伺服器不明',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => '此排行榜還沒有造型';

  @override
  String get communityRankingEmptyVotes => '目前沒有符合所選範圍與篩選條件的最愛投票。';

  @override
  String get communityRankingEmptyRatings => '目前沒有符合所選範圍與篩選條件的星級評分。';

  @override
  String get communityRankingEmptyReviews => '目前沒有符合所選範圍與篩選條件的評論。';

  @override
  String get communityRankingExplore => '尋找造型以查看與評分';

  @override
  String get communityRankingExploreHint => '可依造型或武器名稱搜尋。只有社群的真實評分才會出現在排行榜中。';

  @override
  String get communityRankingClear => '清除武器與時間篩選';

  @override
  String get communityRankingPeriod => '時間';

  @override
  String get communityRankingSort => '排名依據';

  @override
  String get communityRankingWeapon => '武器';

  @override
  String get communityRankingNoSearch => '找不到符合的造型。請試試其他名稱或清除武器篩選。';

  @override
  String get communityRankingCatalogUnavailable => '無法載入造型清單。請關閉面板，待資料同步後再試一次。';

  @override
  String get communityConsentExitAccount => '不同意 · 登出此帳號';

  @override
  String get communityRankingGlobalAllTime => '全球 · 歷來';

  @override
  String get communityRankingCatalogTitle => '所有造型';

  @override
  String get communityReviewOwnershipRequired => '帳號必須擁有此造型才能評分。你仍可查看社群的評分與留言。';

  @override
  String get communityReviewOwnershipUnavailable =>
      '無法驗證你是否擁有此造型。請重新載入收藏庫，或在連上網路後再試一次。';

  @override
  String get communityReviewLegacyOwnership => '舊評論 · 未驗證擁有權';

  @override
  String get communityReviewVerifiedOwner => '評論時已驗證擁有權';

  @override
  String get communitySkinDiscussionHint => '所有人都可以留言。只有造型擁有者可以給星與撰寫評論。';

  @override
  String get communityAddPhotos => '新增相片';

  @override
  String get communityAgentsPicked => '已選擇的特務';

  @override
  String get communityAllModes => '全部';

  @override
  String get communityAllWeapons => '所有武器';

  @override
  String get communityAnonymousBanner => '正在匿名瀏覽';

  @override
  String get communityAnyLanguage => '所有語言';

  @override
  String get communityAnyRank => '所有牌位';

  @override
  String get communityAnyRole => '所有職業';

  @override
  String get communityApply => '套用';

  @override
  String get communityAutoRefresh => '每 20 秒自動重新整理';

  @override
  String get communityBackToMyCountry => '回到我的國家';

  @override
  String get communityBlockAuthor => '在此裝置上封鎖';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => '清除';

  @override
  String get communityCodeAuto => '留空：發布時 ValHub 會依你的遊戲內隊伍自動產生代碼。';

  @override
  String get communityCodeAutoFailed => '無法產生隊伍代碼。請開啟 VALORANT 或手動輸入代碼。';

  @override
  String get communityCodeGenerated => '已依你目前的隊伍產生代碼。';

  @override
  String get communityCodeInvalid => '代碼必須是 6 個大寫字母或數字。';

  @override
  String get communityCodeRequired => '請輸入或產生隊伍代碼。';

  @override
  String get communityComment => '留言';

  @override
  String get communityCommentHint => '撰寫留言…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 則留言';
  }

  @override
  String communityCommentsHeader(String n) {
    return '留言 · $n';
  }

  @override
  String get communityCommentsTitle => '留言';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '貼文：$posts · 玩家：$authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 則找隊友貼文';
  }

  @override
  String get communityCommunityVotes => '社群最愛';

  @override
  String get communityComposerHint => '今天對 VALORANT 有什麼想法？';

  @override
  String get communityComposerTitle => '新貼文';

  @override
  String communityConsentAccount(String riotId) {
    return '帳號：$riotId';
  }

  @override
  String get communityConsentAgree => '同意並繼續';

  @override
  String get communityConsentGateAction => '加入';

  @override
  String get communityConsentGuidelines => '社群守則';

  @override
  String get communityConsentLater => '稍後再說';

  @override
  String get communityConsentLocal => '你的密碼與其他登入資料一律只保留在這台裝置上。你可以在設定中撤回同意。';

  @override
  String get communityConsentPrivacy => '隱私權政策';

  @override
  String get communityConsentPublic => '其他人會看到你的 Riot ID、玩家卡片、牌位與國家／地區。';

  @override
  String get communityConsentTitle => '隱私權與 ValHub 社群';

  @override
  String get communityConsentVerify =>
      'ValHub 會將你的 Riot 存取權限傳送給社群伺服器，以便在連線時驗證 Riot ID，並在你儲存評論時確認造型擁有權。伺服器只讀取必要的資料，使用後立即捨棄存取權限，絕不保存。';

  @override
  String get communityConsentWithdrawn => '已撤回同意。需要再次同意才能繼續使用 App。';

  @override
  String get communityCountriesEmpty => '找不到符合的國家／地區。';

  @override
  String get communityCountriesSearchHint => '搜尋國家／地區…';

  @override
  String get communityCountriesTitle => '各國社群';

  @override
  String get communityCountryNamesAE => '阿拉伯聯合大公國';

  @override
  String get communityCountryNamesAL => '阿爾巴尼亞';

  @override
  String get communityCountryNamesAM => '亞美尼亞';

  @override
  String get communityCountryNamesAR => '阿根廷';

  @override
  String get communityCountryNamesAT => '奧地利';

  @override
  String get communityCountryNamesAU => '澳洲';

  @override
  String get communityCountryNamesAZ => '亞塞拜然';

  @override
  String get communityCountryNamesBA => '波士尼亞與赫塞哥維納';

  @override
  String get communityCountryNamesBD => '孟加拉';

  @override
  String get communityCountryNamesBE => '比利時';

  @override
  String get communityCountryNamesBG => '保加利亞';

  @override
  String get communityCountryNamesBH => '巴林';

  @override
  String get communityCountryNamesBN => '汶萊';

  @override
  String get communityCountryNamesBO => '玻利維亞';

  @override
  String get communityCountryNamesBR => '巴西';

  @override
  String get communityCountryNamesBY => '白俄羅斯';

  @override
  String get communityCountryNamesCA => '加拿大';

  @override
  String get communityCountryNamesCH => '瑞士';

  @override
  String get communityCountryNamesCL => '智利';

  @override
  String get communityCountryNamesCN => '中國';

  @override
  String get communityCountryNamesCO => '哥倫比亞';

  @override
  String get communityCountryNamesCR => '哥斯大黎加';

  @override
  String get communityCountryNamesCU => '古巴';

  @override
  String get communityCountryNamesCY => '賽普勒斯';

  @override
  String get communityCountryNamesCZ => '捷克';

  @override
  String get communityCountryNamesDE => '德國';

  @override
  String get communityCountryNamesDK => '丹麥';

  @override
  String get communityCountryNamesDO => '多明尼加共和國';

  @override
  String get communityCountryNamesDZ => '阿爾及利亞';

  @override
  String get communityCountryNamesEC => '厄瓜多';

  @override
  String get communityCountryNamesEE => '愛沙尼亞';

  @override
  String get communityCountryNamesEG => '埃及';

  @override
  String get communityCountryNamesES => '西班牙';

  @override
  String get communityCountryNamesET => '衣索比亞';

  @override
  String get communityCountryNamesFI => '芬蘭';

  @override
  String get communityCountryNamesFR => '法國';

  @override
  String get communityCountryNamesGB => '英國';

  @override
  String get communityCountryNamesGE => '喬治亞';

  @override
  String get communityCountryNamesGH => '迦納';

  @override
  String get communityCountryNamesGR => '希臘';

  @override
  String get communityCountryNamesGT => '瓜地馬拉';

  @override
  String get communityCountryNamesHK => '香港';

  @override
  String get communityCountryNamesHN => '宏都拉斯';

  @override
  String get communityCountryNamesHR => '克羅埃西亞';

  @override
  String get communityCountryNamesHU => '匈牙利';

  @override
  String get communityCountryNamesID => '印尼';

  @override
  String get communityCountryNamesIE => '愛爾蘭';

  @override
  String get communityCountryNamesIL => '以色列';

  @override
  String get communityCountryNamesIN => '印度';

  @override
  String get communityCountryNamesIQ => '伊拉克';

  @override
  String get communityCountryNamesIR => '伊朗';

  @override
  String get communityCountryNamesIS => '冰島';

  @override
  String get communityCountryNamesIT => '義大利';

  @override
  String get communityCountryNamesJO => '約旦';

  @override
  String get communityCountryNamesJP => '日本';

  @override
  String get communityCountryNamesKE => '肯亞';

  @override
  String get communityCountryNamesKH => '柬埔寨';

  @override
  String get communityCountryNamesKR => '韓國';

  @override
  String get communityCountryNamesKW => '科威特';

  @override
  String get communityCountryNamesKZ => '哈薩克';

  @override
  String get communityCountryNamesLA => '寮國';

  @override
  String get communityCountryNamesLB => '黎巴嫩';

  @override
  String get communityCountryNamesLK => '斯里蘭卡';

  @override
  String get communityCountryNamesLT => '立陶宛';

  @override
  String get communityCountryNamesLU => '盧森堡';

  @override
  String get communityCountryNamesLV => '拉脫維亞';

  @override
  String get communityCountryNamesLY => '利比亞';

  @override
  String get communityCountryNamesMA => '摩洛哥';

  @override
  String get communityCountryNamesMD => '摩爾多瓦';

  @override
  String get communityCountryNamesME => '蒙特內哥羅';

  @override
  String get communityCountryNamesMK => '北馬其頓';

  @override
  String get communityCountryNamesMM => '緬甸';

  @override
  String get communityCountryNamesMN => '蒙古';

  @override
  String get communityCountryNamesMO => '澳門';

  @override
  String get communityCountryNamesMT => '馬爾他';

  @override
  String get communityCountryNamesMX => '墨西哥';

  @override
  String get communityCountryNamesMY => '馬來西亞';

  @override
  String get communityCountryNamesNG => '奈及利亞';

  @override
  String get communityCountryNamesNI => '尼加拉瓜';

  @override
  String get communityCountryNamesNL => '荷蘭';

  @override
  String get communityCountryNamesNO => '挪威';

  @override
  String get communityCountryNamesNP => '尼泊爾';

  @override
  String get communityCountryNamesNZ => '紐西蘭';

  @override
  String get communityCountryNamesOM => '阿曼';

  @override
  String get communityCountryNamesPA => '巴拿馬';

  @override
  String get communityCountryNamesPE => '秘魯';

  @override
  String get communityCountryNamesPH => '菲律賓';

  @override
  String get communityCountryNamesPK => '巴基斯坦';

  @override
  String get communityCountryNamesPL => '波蘭';

  @override
  String get communityCountryNamesPR => '波多黎各';

  @override
  String get communityCountryNamesPT => '葡萄牙';

  @override
  String get communityCountryNamesPY => '巴拉圭';

  @override
  String get communityCountryNamesQA => '卡達';

  @override
  String get communityCountryNamesRO => '羅馬尼亞';

  @override
  String get communityCountryNamesRS => '塞爾維亞';

  @override
  String get communityCountryNamesRU => '俄羅斯';

  @override
  String get communityCountryNamesSA => '沙烏地阿拉伯';

  @override
  String get communityCountryNamesSE => '瑞典';

  @override
  String get communityCountryNamesSG => '新加坡';

  @override
  String get communityCountryNamesSI => '斯洛維尼亞';

  @override
  String get communityCountryNamesSK => '斯洛伐克';

  @override
  String get communityCountryNamesSV => '薩爾瓦多';

  @override
  String get communityCountryNamesTH => '泰國';

  @override
  String get communityCountryNamesTL => '東帝汶';

  @override
  String get communityCountryNamesTN => '突尼西亞';

  @override
  String get communityCountryNamesTR => '土耳其';

  @override
  String get communityCountryNamesTW => '台灣';

  @override
  String get communityCountryNamesUA => '烏克蘭';

  @override
  String get communityCountryNamesUS => '美國';

  @override
  String get communityCountryNamesUY => '烏拉圭';

  @override
  String get communityCountryNamesUZ => '烏茲別克';

  @override
  String get communityCountryNamesVE => '委內瑞拉';

  @override
  String get communityCountryNamesVN => '越南';

  @override
  String get communityCountryNamesZA => '南非';

  @override
  String get communityCreateLfg => '發布找隊友貼文';

  @override
  String get communityCreateLfgShort => '發布';

  @override
  String get communityDataDeleted => '已刪除你的社群資料。';

  @override
  String communityDataFooter(String riotId) {
    return '適用於目前使用的帳號：$riotId。下載的檔案不包含密碼或 Riot 登入資料。';
  }

  @override
  String get communityDataTitle => '你的社群資料';

  @override
  String get communityDecrease => '減少';

  @override
  String get communityDelete => '刪除';

  @override
  String get communityDeleteComment => '刪除留言';

  @override
  String get communityDeleteCommentBody => '此留言將被永久刪除。';

  @override
  String get communityDeleteCommentTitle => '要刪除留言嗎？';

  @override
  String get communityDeleteDataConfirm => '永久刪除';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return '$riotId 在 ValHub 社群的所有貼文、留言、造型評論、按讚、投票、找隊友貼文與相片都將被永久刪除，且無法復原。你會回到匿名瀏覽模式，若想再次加入需要重新同意。\n\nRiot 帳號與遊戲內資料不受影響。如果想保留一份副本，請先下載你的資料。';
  }

  @override
  String get communityDeleteDataConfirmTitle => '要刪除社群資料嗎？';

  @override
  String get communityDeleteDataSubtitle => '永久刪除你在社群發布過的所有內容。';

  @override
  String get communityDeleteDataTitle => '刪除我的社群資料';

  @override
  String get communityDeletePost => '刪除貼文';

  @override
  String get communityDeletePostBody => '此貼文與所有留言將被永久刪除。';

  @override
  String get communityDeletePostTitle => '要刪除貼文嗎？';

  @override
  String get communityDeleteReview => '刪除評論';

  @override
  String get communityDeleteReviewBody => '你對此造型的評分與評論將被刪除。';

  @override
  String get communityDeleteReviewTitle => '要刪除你的評論嗎？';

  @override
  String get communityDeleted => '已刪除。';

  @override
  String get communityDiscard => '捨棄';

  @override
  String get communityDiscardBody => '你剛寫的內容將不會儲存。';

  @override
  String get communityDiscardTitle => '要捨棄貼文嗎？';

  @override
  String get communityDownload => '下載並翻譯';

  @override
  String get communityDownloadingModels => '正在下載語言包…';

  @override
  String get communityEditReview => '編輯';

  @override
  String get communityEdited => '已編輯';

  @override
  String get communityEmptyPost => '請輸入內容或新增相片。';

  @override
  String get communityExpired => '已過期';

  @override
  String communityExpiresIn(String t) {
    return '剩餘 $t';
  }

  @override
  String get communityExportPreparing => '正在準備…';

  @override
  String get communityExportSubject => 'ValHub 社群資料';

  @override
  String get communityExportSubtitle => '你在社群發布過的所有內容副本：貼文、留言、評論、按讚、投票與找隊友貼文。';

  @override
  String get communityExportTitle => '下載我的資料';

  @override
  String get communityExtend => '延長';

  @override
  String get communityExtended => '已將貼文延長 30 分鐘。';

  @override
  String get communityFeedEmptyBody => '成為第一個分享商店、夜市或精彩時刻的人吧！';

  @override
  String get communityFeedEmptyFilteredBody => '沒有符合的貼文。請試試更換語言或清除篩選。';

  @override
  String get communityFeedEmptyGuestBody => '目前還沒有新貼文。請稍後再來看看，或加入社群一起分享。';

  @override
  String get communityFeedEmptyScopeBody => '試試查看國際社群的貼文，或更換篩選條件。';

  @override
  String get communityFeedEmptyScopeTitle => '此範圍內還沒有貼文';

  @override
  String get communityFeedEmptyTitle => '動態牆還是空的';

  @override
  String get communityFilters => '篩選';

  @override
  String get communityGenerateCode => '產生隊伍代碼';

  @override
  String get communityGeneratingCode => '正在產生代碼…';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Google 翻譯';

  @override
  String get communityHelpful => '有幫助';

  @override
  String communityHelpfulCount(String n) {
    return '有幫助 · $n';
  }

  @override
  String get communityHiddenAuthors => '已隱藏與封鎖的玩家';

  @override
  String get communityHiddenAuthorsEmpty => '你尚未隱藏或封鎖任何人';

  @override
  String get communityHiddenAuthorsHint =>
      '僅適用於此裝置上的這個帳號。對方的內容會被隱藏；對方仍可看到你的公開內容。';

  @override
  String communityImageOf(int i, int n) {
    return '相片 $i/$n';
  }

  @override
  String get communityIncrease => '增加';

  @override
  String get communityJoin => '加入';

  @override
  String get communityJoinCodeExpired => '隊伍代碼已過期或已失效。';

  @override
  String communityJoinConfirmBody(String name) {
    return '你將離開目前的 VALORANT 隊伍，加入 $name 的隊伍。';
  }

  @override
  String get communityJoinConfirmTitle => '要加入這個隊伍嗎？';

  @override
  String get communityJoinGameNotRunning => '請在電腦或主機上開啟 VALORANT 後再試一次。';

  @override
  String get communityJoinInvalidCode => '隊伍代碼已失效，或隊伍已滿。';

  @override
  String get communityJoinParty => '加入隊伍';

  @override
  String get communityJoinPartyFull => '此隊伍已滿。';

  @override
  String get communityJoined => '已加入隊伍！開啟 VALORANT 一起玩吧。';

  @override
  String get communityJoinedHint => '已加入隊伍！開啟 VALORANT 一起玩吧。';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 人申請加入';
  }

  @override
  String get communityKeepEditing => '繼續撰寫';

  @override
  String get communityKindNightMarket => '夜市';

  @override
  String get communityKindStore => '今日商店';

  @override
  String get communityLanguage => '語言';

  @override
  String get communityLanguageFilter => '內容語言';

  @override
  String get communityLanguageFilterHint => '只顯示以所選語言撰寫的內容。留空即可查看全部。';

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
    return '$n 種語言';
  }

  @override
  String get communityLfgEmptyBody => '發布貼文，讓其他玩家一鍵加入你的隊伍。';

  @override
  String get communityLfgEmptyTitle => '還沒有人在找隊友';

  @override
  String get communityLfgExpiredRepost => '你的貼文已過期。請發布新貼文來尋找隊友。';

  @override
  String get communityLfgExpiryNote => '貼文會在 30 分鐘後自動過期。';

  @override
  String get communityLfgGateBody =>
      '加入社群（只需驗證一次 Riot ID）即可查看同伺服器玩家的貼文，並發布你的找隊友貼文。你仍可照常瀏覽動態牆與造型排行榜。';

  @override
  String get communityLfgGateTitle => '找隊友功能僅限會員';

  @override
  String communityLfgOtherShardNote(String region) {
    return '你正在查看 $region 伺服器 — 只有與你的帳號位於相同伺服器的玩家才能加入隊伍。';
  }

  @override
  String get communityLfgPosted => '已發布找隊友貼文！';

  @override
  String get communityLfgPreviewTitle => '尋找牌位相近的隊友';

  @override
  String get communityLfgRemoved => '已移除貼文。';

  @override
  String get communityLfgSameShardNote => '只有相同伺服器的玩家才能加入隊伍。';

  @override
  String communityLfgSheetSubtitle(String region) {
    return '地區：$region · 貼文會在 30 分鐘後自動過期。';
  }

  @override
  String get communityLike => '讚';

  @override
  String communityLikes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 個讚';
  }

  @override
  String get communityLiveMembers => '成員';

  @override
  String get communityLoadMoreFailed => '無法載入更多貼文，請再試一次。';

  @override
  String get communityMatchMyRank => '符合你的牌位';

  @override
  String communityMaxPhotos(int max) {
    return '最多 $max 張相片。';
  }

  @override
  String communityMemberJoined(String name) {
    return '$name 已加入隊伍';
  }

  @override
  String get communityMemberJoinedBody => '有人透過你的找隊友貼文加入了。';

  @override
  String get communityMic => '需要麥克風';

  @override
  String get communityMicOn => '有麥克風';

  @override
  String get communityMode => '模式';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => '更多選項';

  @override
  String get communityMuteAuthor => '隱藏此玩家';

  @override
  String get communityMyPost => '你的貼文';

  @override
  String get communityNewPost => '發文';

  @override
  String communityNightMarketOf(String date) {
    return '$date 的夜市';
  }

  @override
  String get communityNoAccountBody => '新增 Riot 帳號即可發文、尋找隊友與為造型投票。';

  @override
  String get communityNoAccountTitle => '登入以加入';

  @override
  String get communityNoComments => '還沒有留言。來搶頭香吧！';

  @override
  String get communityNoParty => '找不到隊伍。請開啟 VALORANT 後再試一次，或手動輸入代碼。';

  @override
  String communityNoPartyWithReason(String reason) {
    return '找不到隊伍。請開啟 VALORANT 後再試一次，或手動輸入代碼。\n$reason';
  }

  @override
  String get communityNoRatings => '尚無評分';

  @override
  String get communityNote => '備註';

  @override
  String get communityNoteHint => '例如：缺 1 位控場者、有麥克風、開心玩就好';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name，$price';
  }

  @override
  String communityOffersTotal(String amount) {
    return '總計 $amount';
  }

  @override
  String get communityOpenReviews => '查看評論';

  @override
  String get communityOutOfRange => '不在牌位範圍內';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => '隊伍代碼';

  @override
  String get communityPartyCodeHint => '例如：A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return '隊伍代碼：$code';
  }

  @override
  String get communityPartySize => '目前隊伍';

  @override
  String get communityPartySizeFromGame => '取自遊戲內的隊伍';

  @override
  String communityPartySizeValue(int n) {
    return '$n 人';
  }

  @override
  String get communityPeriodAll => '全部';

  @override
  String get communityPeriodAllTime => '歷來';

  @override
  String get communityPeriodWeek => '本週';

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max 張相片';
  }

  @override
  String get communityPickRating => '請選擇星級。';

  @override
  String get communityPlayVideo => '觀看影片';

  @override
  String get communityPostLfg => '發布';

  @override
  String get communityPostNotFound => '此貼文已被刪除或隱藏。';

  @override
  String get communityPostTitle => '貼文';

  @override
  String get communityPosted => '已發文！';

  @override
  String get communityPrivacyNote =>
      'ValHub 會在你連線社群時驗證 Riot ID，並在你評論時驗證造型擁有權。社群絕不會儲存你的密碼或 Riot 登入資料。';

  @override
  String get communityPublish => '發布';

  @override
  String get communityPublishing => '正在發布…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => '從';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => '牌位範圍';

  @override
  String get communityRankRangeInvalid => '最低牌位不能高於最高牌位。';

  @override
  String communityRankSemantics(String n, String name) {
    return '第 $n 名：$name';
  }

  @override
  String get communityRankTo => '到';

  @override
  String get communityRateLimitedTitle => '請稍等一下';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 人評分';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString 人評分';
  }

  @override
  String get communityRatingWordsItem0 => '很差';

  @override
  String get communityRatingWordsItem1 => '普通偏下';

  @override
  String get communityRatingWordsItem2 => '還可以';

  @override
  String get communityRatingWordsItem3 => '好看';

  @override
  String get communityRatingWordsItem4 => '神作';

  @override
  String get communityRefreshList => '重新整理';

  @override
  String get communityRegion => '地區';

  @override
  String get communityRemoveAttachment => '移除附件';

  @override
  String get communityRemoveLfg => '移除貼文';

  @override
  String get communityRemoveLfgBody => '其他玩家將不會再看到此貼文。';

  @override
  String get communityRemoveLfgTitle => '要移除找隊友貼文嗎？';

  @override
  String get communityRemovePhoto => '移除相片';

  @override
  String get communityReport => '檢舉';

  @override
  String get communityReportConfirmBody => '被許多玩家檢舉的內容將從社群中隱藏。';

  @override
  String get communityReportConfirmTitle => '要送出檢舉嗎？';

  @override
  String get communityReportPrompt => '你為什麼要檢舉此內容？';

  @override
  String get communityReportReasonsSpam => '垃圾訊息或廣告';

  @override
  String get communityReportReasonsHarassment => '騷擾、辱罵';

  @override
  String get communityReportReasonsInappropriate => '不當內容';

  @override
  String get communityReportReasonsScam => '詐騙、買賣帳號';

  @override
  String get communityReportReasonsOther => '其他原因';

  @override
  String get communityReportTitle => '檢舉內容';

  @override
  String get communityReported => '感謝你！已送出檢舉。';

  @override
  String get communityRetry => '重試';

  @override
  String get communityReviewDeleted => '已刪除評論。';

  @override
  String get communityReviewHint => '分享你對此造型的感想（選填）';

  @override
  String get communityReviewSaved => '已儲存評論！';

  @override
  String get communityReviewTitle => '評價造型';

  @override
  String get communityReviewsEmptyBody => '還沒有評論 — 來當第一個吧！';

  @override
  String get communityReviewsEmptyTitle => '尚無評論';

  @override
  String communityReviewsHeader(String n) {
    return '評論 · $n';
  }

  @override
  String get communityReviewsSection => '評論';

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot 目前發生問題';

  @override
  String get communityRoleFlex => '彈性補位';

  @override
  String get communityRoles => '需要的職業';

  @override
  String get communitySaveReview => '儲存評論';

  @override
  String get communityScopeCountry => '你的國家';

  @override
  String get communityScopeGlobal => '國際';

  @override
  String get communityScopeRegion => '地區';

  @override
  String get communityScopeWorldwide => '全球';

  @override
  String get communitySectionFeed => '動態牆';

  @override
  String get communitySectionLfg => '找隊友';

  @override
  String get communitySectionSkins => '造型排行榜';

  @override
  String get communitySend => '送出';

  @override
  String get communitySendComment => '送出留言';

  @override
  String get communityShareNightMarketHint => '向大家炫耀你的夜市';

  @override
  String communitySharePostTitle(String name) {
    return '$name 在 ValHub 的貼文';
  }

  @override
  String get communityShareStore => '分享到社群';

  @override
  String get communityShareStoreHint => '向大家炫耀今天的商店';

  @override
  String get communityShowOriginal => '查看原文';

  @override
  String get communityShowTranslation => '查看翻譯';

  @override
  String get communitySignInToReview => '新增 Riot 帳號即可評價造型。';

  @override
  String get communitySkinNotFound => '找不到此造型。';

  @override
  String get communitySkinsEmptyBody => '為你最喜歡的造型按愛心，讓它登上排行榜！';

  @override
  String get communitySkinsEmptyTitle => '尚無投票';

  @override
  String get communitySlots => '需要人數';

  @override
  String communitySlotsTooMany(int max) {
    return '隊伍最多 5 人：只剩 $max 個空位。';
  }

  @override
  String communitySlotsWanted(int n) {
    return '需要 $n 人';
  }

  @override
  String get communitySortHelpful => '最有幫助';

  @override
  String get communitySortNewest => '最新';

  @override
  String get communitySortRating => '評分最高';

  @override
  String get communitySortReviews => '評論最多';

  @override
  String get communitySortVotes => '最受喜愛';

  @override
  String communityStarLabel(int n) {
    return '$n 星';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg 星（滿分 5 星）';
  }

  @override
  String get communityStatusFull => '已滿';

  @override
  String get communityStatusInGame => '對戰中';

  @override
  String get communityStatusOpen => '尋找中';

  @override
  String communityStoreOf(String date) {
    return '$date 的商店';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => '點選星星為此造型評分';

  @override
  String get communityTitle => '社群';

  @override
  String communityTooLong(int max) {
    return '最多 $max 個字元。';
  }

  @override
  String get communityTranslate => '使用 Google 翻譯';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return '若要從$from翻譯成$to，ValHub 需要從 Google 下載語言包（約 $size）。只需下載一次；內容會完全在你的裝置上翻譯，不會傳送到任何伺服器。';
  }

  @override
  String get communityTranslateDownloadTitle => '要下載裝置端語言包嗎？';

  @override
  String get communityTranslateFailed => '無法翻譯，請再試一次。';

  @override
  String get communityTranslateUnavailable => '此裝置尚不支援裝置端翻譯。';

  @override
  String get communityTranslatedByGoogle => '由 Google 自動翻譯';

  @override
  String get communityTranslating => '正在翻譯…';

  @override
  String get communityTrendingTitle => '全球最受喜愛的造型';

  @override
  String get communityUnavailableBody => '無法連線至 ValHub 社群。請稍後再試。';

  @override
  String get communityUnavailableTitle => '無法連線至社群';

  @override
  String get communityUnhideAuthor => '取消隱藏／解除封鎖';

  @override
  String get communityUnknownPlayer => '玩家';

  @override
  String get communityUnlike => '收回讚';

  @override
  String get communityUnvote => '取消愛心';

  @override
  String get communityUploading => '正在上傳相片…';

  @override
  String get communityViewImage => '查看相片';

  @override
  String get communityVote => '為此造型按愛心';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString 個讚';
  }

  @override
  String get communityWithdrawConfirm => '撤回';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub 將停止以 $riotId 使用社群：這台裝置上的社群連線會被移除，你將回到匿名瀏覽模式。\n\n你已發布的貼文、留言、評論、投票與找隊友貼文仍會保留在社群上，並繼續顯示你的 Riot ID，直到你逐一刪除，或選擇「刪除我的社群資料」為止。你隨時可以重新加入。';
  }

  @override
  String get communityWithdrawConfirmTitle => '要撤回同意嗎？';

  @override
  String get communityWithdrawSubtitle => '停止以此帳號使用社群。已發布的貼文會保留。';

  @override
  String get communityWithdrawTitle => '撤回同意';

  @override
  String get communityWriteFirstReview => '撰寫第一則評論';

  @override
  String get communityWritePost => '撰寫貼文';

  @override
  String get communityYou => '你';

  @override
  String get communityYourCountry => '你的國家';

  @override
  String get communityYourReview => '你的評論';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return '你：$kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => '特務選擇';

  @override
  String get liveGameAnonymous => '匿名';

  @override
  String get liveGameAutoRefreshNote => '進入對戰時會自動重新整理。';

  @override
  String get liveGameBuddy => '槍枝吊飾';

  @override
  String get liveGameClose => '關閉';

  @override
  String get liveGameCurrentGame => '目前對戰';

  @override
  String get liveGameEmptyTeam => '尚無玩家。';

  @override
  String get liveGameEnemyHiddenInAgentSelect => '對戰開始後才會顯示敵隊。';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return '敵隊已鎖定 $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      '此即時對戰資料未提供擊殺／死亡／助攻。Riot 公佈賽後資料後即會顯示計分板。';

  @override
  String get liveGameFinalScoreboard => '最終計分板';

  @override
  String get liveGameFlex => '炫耀道具';

  @override
  String get liveGameInLobby => '在大廳中';

  @override
  String get liveGameInMatch => '對戰中';

  @override
  String get liveGameInQueue => '配對中';

  @override
  String liveGameInQueueFor(String elapsed) {
    return '配對中 · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return '等級 $n';
  }

  @override
  String get liveGameLiveScore => '即時比分';

  @override
  String get liveGameLoadoutFromAgentSelect => '特務選擇時的裝備';

  @override
  String get liveGameLoadoutFromMatch => '本場對戰的裝備';

  @override
  String get liveGameLobbyHint => '找到對戰後，ValHub 會顯示所有人的陣容與牌位。';

  @override
  String get liveGameLockedTag => '已鎖定';

  @override
  String get liveGameMatchPendingHint => 'ValHub 會自動重試。計分板通常約一分鐘後就會出現。';

  @override
  String get liveGameNoAgentYet => '尚未選擇特務';

  @override
  String get liveGameNoLoadout => '沒有此玩家的裝備資訊。';

  @override
  String get liveGameNotInGame => '不在對戰中';

  @override
  String get liveGameNotInGameHint =>
      '開啟 VALORANT 並開始配對 — 進入特務選擇畫面後，對戰詳情會自動顯示在這裡。';

  @override
  String get liveGameNotInGameTitle => '你目前不在任何對戰中';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return '查看 $name 的裝備';
  }

  @override
  String get liveGameOpenParty => '開啟隊伍與配對';

  @override
  String get liveGameParty => '隊伍';

  @override
  String liveGamePeak(String rank) {
    return '最高：$rank';
  }

  @override
  String get liveGamePlayerCard => '玩家卡片';

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return '$name 的裝備';
  }

  @override
  String get liveGamePlayerLoadoutTitle => '裝備';

  @override
  String get liveGameQueueHint => '請保持 App 開啟 — 一找到對戰就會顯示對戰詳情。';

  @override
  String get liveGameQuitConfirmBodyInGame => '離開對戰可能會受到懲罰（扣 RR、限制配對）。仍要離開嗎？';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      '在特務選擇畫面離開可能會受到懲罰（扣 RR、限制配對）。仍要離開嗎？';

  @override
  String get liveGameQuitConfirmTitle => '要離開對戰嗎？';

  @override
  String get liveGameQuitDone => '已離開對戰。';

  @override
  String get liveGameQuitFailed => '無法離開對戰。';

  @override
  String get liveGameQuitMatch => '離開對戰';

  @override
  String get liveGameQuitMatchChanged => '你在確認時對戰已進入下一個階段。你尚未離開，請再試一次。';

  @override
  String get liveGameRankUnavailable => '牌位不明';

  @override
  String get liveGameRefresh => '重新整理';

  @override
  String liveGameRefreshIn(int seconds) {
    return '$seconds 秒後自動重新整理';
  }

  @override
  String get liveGameRefreshNow => '立即重新整理';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => '對戰詳情';

  @override
  String get liveGameSprays => '噴漆';

  @override
  String get liveGameStatusAgentSelect => '特務選擇';

  @override
  String get liveGameStatusEnded => '已結束';

  @override
  String get liveGameStatusInProgress => '進行中';

  @override
  String get liveGameStatusUnavailable => '無法更新對戰狀態';

  @override
  String get liveGameTabAllPlayers => '玩家';

  @override
  String get liveGameTabEnemyTeam => '敵隊';

  @override
  String get liveGameTabYourTeam => '你的隊伍';

  @override
  String liveGameTimeLeft(String t) {
    return '剩餘 $t';
  }

  @override
  String get liveGameViewMatchDetails => '查看對戰詳情';

  @override
  String get liveGameWeapons => '武器';

  @override
  String get liveGameYou => '你';

  @override
  String liveGameYouHover(String agent) {
    return '你正在選擇 $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return '你已鎖定 $agent';
  }

  @override
  String get liveGamePickInGame => '請在 VALORANT 中選擇並鎖定特務。ValHub 只會顯示剩餘時間和你的隊伍。';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws 平',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown 場結果不明',
      zero: '',
    );
    return '$wins 勝 – $losses 敗$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return '裝置時間（$offset）';
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
      'yes': ' 使用 $weapon',
      'other': '',
    });
    return '$killer$_temp0 擊殺了 $victim（$time）';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 天',
      'days7': '7 天',
      'other': '全部',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': '特務',
      'maps': '地圖',
      'queues': '模式',
      'sides': '進攻／防守',
      'trend': '趨勢',
      'other': '模式',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => '所有模式';

  @override
  String get profileAbility => '技能';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n 場';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => '平均戰鬥分數';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return '本章：$wins 勝／$games 場 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => '所有玩家';

  @override
  String get profileAlreadyReached => '你已達到此牌位。';

  @override
  String get profileAtCurrentForm => '以目前的狀態';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return '以目前的狀態（每場 $gain / $loss）';
  }

  @override
  String profileBestCase(int n) {
    return '最佳情況：連贏 $n 場';
  }

  @override
  String get profileByWinRateTitle => '依勝率';

  @override
  String get profileChooseMap => '依地圖篩選';

  @override
  String get profileClearMap => '清除地圖篩選';

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
  String get profileCopyRiotId => '複製 Riot ID';

  @override
  String get profileCurrentRank => '目前';

  @override
  String get profileDailyRrEmpty => '這台裝置上尚未儲存任何競技模式對戰。';

  @override
  String get profileDailyRrFootnote => 'RR 紀錄會直接儲存在你的裝置上，包括 Riot 已不再提供的對戰。';

  @override
  String get profileDailyRrTitle => '每日 RR';

  @override
  String profileDayBoundary(String zone) {
    return '日期依$zone計算';
  }

  @override
  String profileDaysPlayed(int n) {
    return '$n 天有對戰';
  }

  @override
  String get profileDuration => '時長';

  @override
  String profileDurationOf(String d) {
    return '時長 $d';
  }

  @override
  String get profileEndOfHistory => '已顯示所有對戰';

  @override
  String get profileEnemyTeam => '敵隊';

  @override
  String get profileFallDamage => '墜落傷害';

  @override
  String get profileFilterAll => '全部';

  @override
  String get profileFilterMap => '地圖';

  @override
  String get profileFirstBloods => '首殺';

  @override
  String get profileFirstDeaths => '首位陣亡';

  @override
  String get profileFirstHalf => '上半場';

  @override
  String get profileFormNoRoundStats => 'K/D、ACS、HS% 只計算回合制模式。';

  @override
  String profileFormPending(int n) {
    return '清單中有 $n 場對戰尚未載入，無法計算。';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D、ACS、ADR、HS% 只計算 $roundGames/$games 場回合制對戰';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '最近 $games 場：$w 勝，$l 敗';
  }

  @override
  String get profileFriendsRow => '好友與聊天';

  @override
  String profileGainPerWin(String rr) {
    return '勝利時 $rr RR';
  }

  @override
  String get profileHideKills => '隱藏擊殺';

  @override
  String get profileHitBody => '身體';

  @override
  String get profileHitDistribution => '命中分佈';

  @override
  String get profileHitHead => '頭部';

  @override
  String get profileHitLegs => '腿部';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint => '你取得擊殺、助攻、存活或被隊友報仇的回合比例';

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
    return '過去 $n 天';
  }

  @override
  String profileLastMatches(int n) {
    return '最近 $n 場';
  }

  @override
  String profileLeaderboard(String n) {
    return '排行榜 #$n';
  }

  @override
  String profileLevel(int n) {
    return '等級 $n';
  }

  @override
  String get profileLevelHidden => '等級已隱藏';

  @override
  String profileLossPerLoss(String rr) {
    return '落敗時 $rr RR';
  }

  @override
  String profileLossStreak(int n) {
    return '$n 連敗';
  }

  @override
  String profileMapFilter(String map) {
    return '地圖：$map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n 場';
  }

  @override
  String get profileMatchDetailTitle => '對戰詳情';

  @override
  String get profileMatchHistory => '對戰紀錄';

  @override
  String get profileMatchUnavailable => '無法載入對戰';

  @override
  String get profileMatchesNeeded => '所需場數';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => '從未取得牌位';

  @override
  String get profileNoKillsInRound => '此回合尚無擊殺資訊。';

  @override
  String get profileNoMatches => '尚無對戰。';

  @override
  String get profileNoMatchesMap => '已載入的對戰中沒有此地圖的對戰。';

  @override
  String get profileNoMatchesQueue => '此模式沒有任何對戰。';

  @override
  String get profileNoPlayers => '此對戰尚無玩家資訊。';

  @override
  String get profileNoRounds => '此對戰尚無各回合資訊。';

  @override
  String get profileOvertime => '延長賽';

  @override
  String get profilePlayHubTitle => '對戰與隊伍';

  @override
  String get profilePartyRow => '隊伍與配對';

  @override
  String get profilePeakRank => '最高';

  @override
  String profilePeakRankOf(String actTitle) {
    return '最高 · $actTitle';
  }

  @override
  String get profilePerformanceAttack => '進攻';

  @override
  String get profilePerformanceDefense => '防守';

  @override
  String get profilePerformanceEmpty => '這台裝置上尚未記錄任何對戰。開啟對戰紀錄即可記錄你玩過的對戰。';

  @override
  String get profilePerformanceGames => '場數';

  @override
  String get profilePerformanceNoMatches => '所選時間範圍內沒有對戰。';

  @override
  String profilePerformanceRounds(int n) {
    return '已記錄 $n 個回合';
  }

  @override
  String get profilePerformanceSample =>
      '至少有 3 場對戰才會顯示比率。ACS、ADR、HS% 與 K/D 只計算回合制模式。';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return '已確認 $known/$total 個回合的進攻或防守方。';
  }

  @override
  String profilePerformanceSince(String date) {
    return '裝置上的紀錄，自 $date 起';
  }

  @override
  String get profilePerformanceTitle => '表現';

  @override
  String get profilePerformanceTrendEmpty => '至少需要兩個各有 3 場以上對戰的時段，才能比較趨勢。';

  @override
  String get profilePickTargetHint => '選擇你想達到的牌位';

  @override
  String profilePlacement(int n) {
    return '第 $n 名';
  }

  @override
  String profilePlantedAt(String site) {
    return '在 $site 安裝輻能核心';
  }

  @override
  String get profilePlayerProfileTitle => '玩家個人檔案';

  @override
  String get profilePlayerSummary => '戰績';

  @override
  String profileProgressTo(String rank) {
    return '邁向$rank的進度';
  }

  @override
  String get profileProgressToTarget => '邁向目標牌位的進度';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote => '依據近期的競技模式對戰估算，未計入定位賽與降牌保護機制。';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches 場即可升上$rank';
  }

  @override
  String get profileRankUpImmortal => '你已達到神話以上 — 此功能最多只計算到神話1。';

  @override
  String get profileRankUpNoForm => '近期沒有競技模式對戰，無法估算你的狀態。';

  @override
  String get profileRankUpOpen => '開啟升牌計算器';

  @override
  String get profileRankUpTitle => '升牌計算器';

  @override
  String get profileRankUpUnranked => '完成定位賽後即可使用升牌計算器。';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => '競技模式計分板';

  @override
  String profileRecentForm(int w, int l) {
    return '近期狀態：$w 勝 – $l 敗';
  }

  @override
  String get profileRecentFormTitle => '近期狀態';

  @override
  String get profileRecentMatches => '近期對戰';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$w勝 · $l敗 · $d平',
      zero: '$w勝 · $l敗',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => '已複製 Riot ID';

  @override
  String profileRound(int n) {
    return '第 $n 回合';
  }

  @override
  String profileRoundKills(int n) {
    return '$n 次擊殺';
  }

  @override
  String get profileRoundLost => '回合落敗';

  @override
  String get profileRoundTimeline => '回合過程';

  @override
  String get profileRoundWon => '回合勝利';

  @override
  String get profileRoundsHint => '點一下回合即可查看每次擊殺。';

  @override
  String get profileRr => 'RR';

  @override
  String profileRrLeft(String n) {
    return '還差 $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR 走勢';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => '計分板';

  @override
  String get profileSecondHalf => '下半場';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => '查看擊殺';

  @override
  String get profileSideSwitch => '攻守交換';

  @override
  String get profileSpike => '輻能核心';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => '目標牌位';

  @override
  String get profileTeamBlue => '藍隊';

  @override
  String get profileTeamMvp => '隊伍 MVP';

  @override
  String get profileTeamRed => '紅隊';

  @override
  String get profileTitle => '個人檔案';

  @override
  String profileToday(String text) {
    return '今天：$text';
  }

  @override
  String get profileTodayNone => '今天還沒有競技模式對戰';

  @override
  String get profileTruePeakLocal => '依據裝置上的紀錄';

  @override
  String get profileWeekdayShortItem0 => '週一';

  @override
  String get profileWeekdayShortItem1 => '週二';

  @override
  String get profileWeekdayShortItem2 => '週三';

  @override
  String get profileWeekdayShortItem3 => '週四';

  @override
  String get profileWeekdayShortItem4 => '週五';

  @override
  String get profileWeekdayShortItem5 => '週六';

  @override
  String get profileWeekdayShortItem6 => '週日';

  @override
  String get profileWinRate => '勝率';

  @override
  String profileWinStreak(int n) {
    return '$n 連勝';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => '你的牌位';

  @override
  String get profileYourSummary => '你的戰績';

  @override
  String get profileYourTeam => '你的隊伍';

  @override
  String get profileYourWinRate => '你的近期勝率';

  @override
  String profilePerformanceQueueChip(String queue) {
    return '模式：$queue';
  }

  @override
  String get profilePerformanceChooseQueue => '依模式篩選';

  @override
  String get profilePerformancePerMatchTitle => '逐場';

  @override
  String get profilePerformancePerMatchHint => '點一下長條即可開啟該場對戰。';

  @override
  String profilePerformanceAverage(String value) {
    return '平均 $value';
  }

  @override
  String get profilePerformanceChartEmpty => '至少需要 2 場含有此數據的回合制對戰才能繪製圖表。';

  @override
  String get profilePerformanceOpeningsTitle => '開局對槍';

  @override
  String get profilePerformanceOpeningWin => '開局對槍勝率';

  @override
  String get profilePerformanceOpeningWinHint => '在你取得首殺或首位陣亡的回合中，你取得首殺的比例。';

  @override
  String get profilePerformanceFirstBloodsPerGame => '每場首殺';

  @override
  String get profilePerformanceFirstDeathsPerGame => '每場首位陣亡';

  @override
  String get profilePerformanceMultiKillsTitle => '單回合多殺';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '三殺',
      'k4': '四殺',
      'ace': 'ACE',
      'other': '雙殺',
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
      other: '根據 $nString 場擊殺數據完整的對戰計算。',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => '回合勝率';

  @override
  String get profilePerformanceDrillHint => '點一下任一列即可只看該特務、地圖或模式。';

  @override
  String get profilePerformanceLoadOlder => '分析更早的對戰';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub 只會分析在這台裝置上開啟過的對戰。每點一下最多再加入 $nString 場更早的對戰。';
  }

  @override
  String get profilePerformanceSearchingOlder => '正在尋找更早的對戰…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '正在分析對戰 $doneString/$totalString…';
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
      other: '已將 $nString 場對戰加入分析。',
      zero: '沒有可加入的新對戰。',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'Riot 已沒有保存更早的對戰。';

  @override
  String get profileEconomyTitle => '我方經濟';

  @override
  String get profileEconomyHint =>
      '購買類型依回合開始時我方隊伍的裝備總價值判定（vlr.gg 的 5 人標準）：Eco 低於 5,000，Semi-eco 低於 10,000，Semi-buy 低於 20,000，Full buy 為 20,000 點以上。每個半場的第一回合為 Pistol。';

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

    return '勝 $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      '你的 VALORANT 好幫手：每日商店、願望清單、牌位、對戰、多帳號與玩家社群，全都在你的裝置上。';

  @override
  String get legalBackToTop => '回到頂端';

  @override
  String get legalConsentAnd => '與';

  @override
  String get legalConsentPrefix => '繼續即表示你同意 ValHub ';

  @override
  String get legalConsentPrivacy => '隱私權政策';

  @override
  String get legalConsentSuffix => '之規定。';

  @override
  String get legalConsentTerms => '使用條款';

  @override
  String get legalContact => '聯絡我們';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => '聯絡方式';

  @override
  String get legalCreditsHeader => '資料來源與致謝';

  @override
  String legalEffectiveFrom(String date) {
    return '自 $date 起生效';
  }

  @override
  String get legalLegalHeader => '法律資訊';

  @override
  String get legalLicensePageLegalese => '© 2026 Nguyễn Đức Huy. 保留所有權利。';

  @override
  String get legalThirdPartyLicenses => '第三方軟體';

  @override
  String get legalThirdPartyLicensesBody => 'ValHub 所使用之開放原始碼軟體的授權條款';

  @override
  String get legalTocTitle => '目錄';

  @override
  String legalVersion(String version) {
    return '版本 $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return '此文件目前以$language顯示。';
  }

  @override
  String get legalContentUnavailable => '無法讀取法律文件。請再試一次或聯絡客服。';

  @override
  String get legalTranslationNotice => '此譯文僅供參考。如有任何差異，以越南語版本為準。';

  @override
  String get settingsUiLanguageTitle => '介面語言';

  @override
  String get settingsLanguageFollowDevice => '跟隨裝置';

  @override
  String get settingsLanguageSaveFailed => '無法儲存語言，請再試一次。';

  @override
  String get settingsGeoCountry => '國家／地區';

  @override
  String get settingsGeoSearchCountry => '搜尋國家／地區名稱或代碼';

  @override
  String get settingsGeoSupportedOnly => '僅顯示已確認支援的地點';

  @override
  String get settingsGeoUnknown => '尚未確認是否支援';

  @override
  String get settingsGeoRestricted => '受限制';

  @override
  String get settingsGeoSeparate => '獨立服務';

  @override
  String get settingsGeoAvailable => '支援';

  @override
  String get settingsGeoNotApplicable => '不適用';

  @override
  String get settingsGeoConnection => 'Riot 連線';

  @override
  String get settingsGeoChooseRegion => '選擇地區';

  @override
  String get settingsGeoAuto => '依帳號自動設定';

  @override
  String get settingsGeoManual => '手動選擇';

  @override
  String get settingsGeoNoRegion => '無法確認你的 Riot 地區';

  @override
  String get settingsGeoManualWarning =>
      '此選項只會變更 ValHub 連線的伺服器，不會轉移你 Riot 帳號的地區。ValHub 會在儲存前檢查連線。';

  @override
  String get settingsGeoConnectionSaved => '已儲存連線方式';

  @override
  String get settingsGeoValidationFailed => '無法在此伺服器上確認你的帳號。請重新選擇地區。';

  @override
  String get settingsGeoHintOnly => '國家／地區僅用於查詢與建議。連線地區依你的 Riot 帳號而定。';

  @override
  String get settingsGeoUnsupported => '尚未支援此 Riot 地區。請在設定中選擇地區。';

  @override
  String get settingsGeoSave => '檢查並儲存';

  @override
  String get settingsGeoCancel => '取消';

  @override
  String get settingsGeoLoading => '正在檢查連線…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      '此選項用於國家／地區名稱、建議與 VP 估算價格。連線的伺服器與社群帳號的國家／地區仍由 Riot 決定。';

  @override
  String get settingsGeoCountryAutomatic => '使用帳號或裝置的國家／地區';

  @override
  String get settingsGeoSaveFailed => '無法儲存你的選擇，請再試一次。';

  @override
  String get settingsGeoAllRegions => '所有地區';

  @override
  String get settingsGeoSuggestions => '建議';

  @override
  String get settingsGeoNoCountries => '沒有符合篩選條件的國家／地區。';

  @override
  String get settingsGeoActiveCountries => '活躍中';

  @override
  String get settingsGeoAllCountries => '所有國家／地區';

  @override
  String get settingsGeoActivityUnavailable => '無法載入各國活動狀況。你仍可從「所有國家／地區」中選擇。';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個國家／地區',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return '你選擇了$manual，但 Riot 判定你的帳號位於$detected。要繼續檢查此連線嗎？';
  }

  @override
  String get settingsGeoUnverified => '伺服器或網路發生問題，無法驗證連線。要先儲存此選項，稍後再試嗎？';

  @override
  String get settingsGeoContinue => '繼續';

  @override
  String settingsGeoMismatch(String region) {
    return '手動連線與你的 Riot 地區（$region）不同。要改用自動設定嗎？';
  }

  @override
  String get settingsGeoUseAuto => '使用自動';

  @override
  String get settingsGeoKeepManual => '保留手動';

  @override
  String get settingsGeoReviewConnection => '查看連線';

  @override
  String settingsGeoCheckedAt(String time) {
    return '上次檢查：$time';
  }

  @override
  String get settingsGeoCheckAgain => '重新檢查';

  @override
  String get settingsPlatformMobile => '行動裝置';

  @override
  String get settingsPlatformOther => '其他平台';

  @override
  String get settingsContentLanguageFollowApp => '跟隨 App 語言';

  @override
  String get settingsContentLanguageHint => '選擇物品名稱的語言。此選項不會變更介面語言或 Riot 伺服器。';

  @override
  String settingsLanguageChanged(String language) {
    return '語言：$language。';
  }

  @override
  String get settingsAboutCreditContent => 'valorant-api.com';

  @override
  String get settingsAboutCreditContentBody => '造型、特務、地圖與牌位的名稱、圖片與資訊。';

  @override
  String get settingsAboutCreditDocs => '社群文件';

  @override
  String get settingsAboutCreditDocsBody =>
      'techchrism/valorant-api-docs 專案與 VALORANT 開發者社群。';

  @override
  String get settingsAboutCreditRiot => 'Riot Games';

  @override
  String get settingsAboutCreditRiotBody =>
      '商店、錢包、收藏庫、對戰與牌位資料直接取自你登入的 Riot 帳號。';

  @override
  String get settingsAboutCreditsHeader => '資料來源';

  @override
  String get settingsAboutHeader => '資訊';

  @override
  String get settingsAboutLegalHeader => '法律資訊';

  @override
  String get settingsAboutRowSubtitle => '隱私權、條款、著作權與聯絡方式';

  @override
  String get settingsAboutTitle => '關於與法律資訊';

  @override
  String get settingsAppHeader => '進階';

  @override
  String get settingsAppearanceHeader => '外觀';

  @override
  String settingsBuildNumber(String build) {
    return '組建 $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '已清除 $size';
  }

  @override
  String get settingsClearCache => '清除暫存資料';

  @override
  String get settingsClearCacheFailed => '無法清除暫存資料，請再試一次。';

  @override
  String get settingsClearCacheSubtitle => '已下載到裝置的圖片與資料，包括已記錄的錯誤回報';

  @override
  String get settingsClearLog => '清除已記錄的錯誤回報';

  @override
  String get settingsClearLogConfirm => '要清除這台裝置上已記錄的錯誤回報嗎？';

  @override
  String get settingsExportLog => '向 ValHub 傳送錯誤回報';

  @override
  String get settingsExportLogEmpty => '目前沒有可傳送的內容。請先使用 App 一段時間後再試一次。';

  @override
  String get settingsExportLogEmptyTitle => '目前沒有可傳送的內容';

  @override
  String get settingsExportLogNote => '錯誤回報不含你的密碼或 Riot 登入資料。';

  @override
  String get settingsExportLogSubtitle => '錯誤回報不含你的密碼或 Riot 登入資料。';

  @override
  String get settingsFeedback => '向 ValHub 提供意見';

  @override
  String get settingsFeedbackSubtitle => '開啟 ValHub 的意見回饋頁面';

  @override
  String get settingsItemLanguageEn => '英文';

  @override
  String get settingsItemLanguageHint => '造型、特務、地圖等名稱會以此語言顯示。';

  @override
  String get settingsItemLanguageLabel => '物品名稱';

  @override
  String get settingsItemLanguagePickerTitle => '物品名稱語言';

  @override
  String get settingsItemLanguageVi => '越南文';

  @override
  String get settingsLegalNotice => '法律聲明';

  @override
  String get settingsLinkOpenFailed => '無法開啟連結，請再試一次。';

  @override
  String get settingsLogCleared => '已清除錯誤回報';

  @override
  String settingsLogEntryCount(int count) {
    return '$count 個項目';
  }

  @override
  String settingsLogEntryShown(int shown, int total) {
    return '$shown / $total 個項目';
  }

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — 錯誤回報';
  }

  @override
  String get settingsLogFilterAll => '全部';

  @override
  String get settingsLogFilterAuth => '登入';

  @override
  String get settingsLogFilterEmpty => '沒有符合的項目。清除篩選即可查看更多。';

  @override
  String get settingsLogFilterErrors => '問題';

  @override
  String get settingsLogFilterHttp => '連線';

  @override
  String get settingsLogMore => '更多選項';

  @override
  String get settingsLogSearchEmpty => '沒有符合的項目。';

  @override
  String get settingsLogSearchHint => '搜尋錯誤回報…';

  @override
  String get settingsLogShareFailed => '無法傳送錯誤回報，請再試一次。';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => '夜市開放時';

  @override
  String get settingsNotifNightMarketSubtitle => '提醒你翻開夜市優惠卡片';

  @override
  String get settingsNotifPermissionMissing => 'App 尚未取得傳送通知的權限。';

  @override
  String get settingsNotifStoreReset => '商店更新時';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return '每天 $time';
  }

  @override
  String get settingsNotifWishlist => '願望清單中的造型出現時';

  @override
  String get settingsNotifWishlistSubtitle => '檢查所有帳號的商店，即使你沒有開啟 App';

  @override
  String get settingsNotificationsHeader => '通知';

  @override
  String get settingsOptionAutoOpenLiveGame => '自動開啟對戰詳情';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle => '找到對戰後立即開啟目前對戰面板';

  @override
  String get settingsOptionOwnPrice => '你的 VP 方案價格';

  @override
  String get settingsOptionOwnPriceEmpty => '尚未輸入 — 若有地區價目表則使用該價目表';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => '平台';

  @override
  String get settingsOptionShowLiveScore => '顯示即時比分';

  @override
  String get settingsOptionShowPeakRank => '在對戰詳情中顯示最高牌位';

  @override
  String get settingsOptionShowPrice => '顯示估算換算價格';

  @override
  String get settingsOptionShowPriceInfo => '換算價格的計算方式';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return '顯示在 VP 價格旁，例如 $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      '你所在的地區尚無已驗證的價目表 — 請輸入你的 VP 方案價格。';

  @override
  String get settingsOptionsHeader => '選項';

  @override
  String get settingsPhaseComplete => '已完成';

  @override
  String get settingsPhaseInProgress => '進行中';

  @override
  String get settingsPhaseScheduled => '已排定';

  @override
  String settingsPlatformAppliesTo(String account) {
    return '適用於 $account';
  }

  @override
  String get settingsPlatformHint =>
      '請依你遊玩的平台選擇 PC、PlayStation 或 Xbox，才能查看正確的對戰紀錄。';

  @override
  String get settingsPlatformPickerTitle => '選擇平台';

  @override
  String get settingsPrimingBody => '開啟通知，就能在商店更新以及願望清單中的造型出現時收到提醒。';

  @override
  String get settingsPrimingEnable => '開啟通知';

  @override
  String get settingsPrimingFootnote => '你隨時可以在設定中開啟或關閉各類通知。';

  @override
  String get settingsPrimingLater => '稍後再說';

  @override
  String get settingsPrimingPointNightMarket => '掌握夜市開放時間';

  @override
  String get settingsPrimingPointNightMarketDetail => '趕在優惠到期前翻開卡片';

  @override
  String get settingsPrimingPointStore => '每日商店更新時提醒你';

  @override
  String get settingsPrimingPointStoreDetail => '帳號的商店更新後提醒你';

  @override
  String get settingsPrimingPointWishlist => '你想要的造型出現時通知你';

  @override
  String get settingsPrimingPointWishlistDetail => '檢查所有帳號的商店，即使你沒有開啟 App';

  @override
  String get settingsPrimingTitle => '別錯過你想要的造型';

  @override
  String settingsRemovedAccount(String account) {
    return '已移除 $account';
  }

  @override
  String get settingsServerStatus => '伺服器狀態';

  @override
  String get settingsServerStatusMaintenance => '維護中';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n 則公告';
  }

  @override
  String get settingsServerStatusSubtitle => '各伺服器的 VALORANT 維護與異常狀況';

  @override
  String get settingsSessionLogTitle => 'ValHub 錯誤回報';

  @override
  String get settingsSeverityCritical => '嚴重';

  @override
  String get settingsSeverityInfo => '資訊';

  @override
  String get settingsSeverityWarning => '警告';

  @override
  String get settingsSignedOutAll => '已登出所有帳號';

  @override
  String get settingsStatusAllGood => '伺服器運作正常';

  @override
  String settingsStatusAllGoodBody(String region) {
    return '$region 伺服器目前沒有任何異常或維護。';
  }

  @override
  String get settingsStatusFewerUpdates => '收合';

  @override
  String get settingsStatusIssues => 'Riot 正在處理問題';

  @override
  String settingsStatusIssuesBody(int n) {
    return '此伺服器有 $n 則異常公告。';
  }

  @override
  String get settingsStatusKindIncident => '異常';

  @override
  String get settingsStatusKindMaintenance => '維護';

  @override
  String get settingsStatusMaintenanceNow => '伺服器維護中';

  @override
  String get settingsStatusMaintenanceNowBody =>
      '你目前可能無法進入遊戲，ValHub 也可能暫時無法載入資訊。';

  @override
  String settingsStatusMoreUpdates(int n) {
    return '查看其他 $n 則更新';
  }

  @override
  String get settingsStatusRegionPicker => '伺服器';

  @override
  String get settingsStatusScheduled => '即將進行維護';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riot 已公告 $n 個維護時段。';
  }

  @override
  String get settingsStatusSourceNote => '來源：Riot Games 官方狀態頁面。時間依裝置的時區顯示。';

  @override
  String settingsStatusStarted(String when) {
    return '開始於 $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return '更新於 $when';
  }

  @override
  String get settingsStatusUpdatesHeader => '來自 RIOT 的更新';

  @override
  String get settingsSupportHeader => '支援';

  @override
  String settingsSwitchedTo(String account) {
    return '已切換至 $account';
  }

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLabel => '主題';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemePickerTitle => '選擇主題';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsTitle => '設定';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsWelcomeBulletProfile => '牌位、對戰紀錄、進行中的對戰';

  @override
  String get settingsWelcomeBulletProfileDetail => '每場 RR、對手牌位';

  @override
  String get settingsWelcomeBulletStore => '每日商店、夜市與組合包';

  @override
  String get settingsWelcomeBulletStoreDetail => '價格、稀有度、更新倒數';

  @override
  String get settingsWelcomeBulletWishlist => '願望清單與通知';

  @override
  String get settingsWelcomeBulletWishlistDetail => '你想要的造型上架時通知你';

  @override
  String get settingsWelcomeFootnote =>
      '你會在 Riot 官方頁面登入。只有在你自行選擇儲存登入資訊時，ValHub 才會儲存密碼。';

  @override
  String get settingsWelcomeKicker => 'VALORANT 好幫手';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average（$count 則評分）· ',
      'other': '',
    });
    return '社群：$_temp0$votes 個讚';
  }

  @override
  String get skinDetailAddToWishlist => '加入願望清單';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return '出現在以下帳號的商店：$accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return '在你的商店中：每日商店出現 $daily 次，夜市出現 $night 次。僅計算此裝置上自 $since 起記錄的資料。';
  }

  @override
  String get skinDetailHistoryDelete => '刪除商店紀錄';

  @override
  String get skinDetailHistoryDeleteBody => '要刪除此帳號在這台裝置上記錄的所有商店紀錄嗎？';

  @override
  String get skinDetailInWishlist => '已在願望清單中';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => '未解鎖';

  @override
  String get skinDetailMute => '靜音';

  @override
  String get skinDetailNotFound => '找不到此造型。';

  @override
  String get skinDetailOwned => '已擁有';

  @override
  String get skinDetailPause => '暫停';

  @override
  String get skinDetailPlay => '播放';

  @override
  String get skinDetailPlayVideo => '觀看影片';

  @override
  String get skinDetailRemoveFromWishlist => '從願望清單移除';

  @override
  String get skinDetailTitle => '造型詳情';

  @override
  String get skinDetailUnmute => '取消靜音';

  @override
  String get skinDetailUpgrades => '升級';

  @override
  String get skinDetailVariants => '色彩';

  @override
  String get skinDetailVideoError => '無法播放影片。請檢查網路後再試一次。';

  @override
  String get socialPresenceInMatch => '對戰中';

  @override
  String get socialPresenceAgentSelect => '選擇特務中';

  @override
  String get socialPresenceQueue => '配對中';

  @override
  String get socialPresenceLobby => '在大廳中';

  @override
  String get socialPresenceCustom => '自訂對戰中';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': '開放隊伍',
      'other': '僅限受邀者',
    });
    return '$size/$max 人 · $_temp0';
  }

  @override
  String get socialAccept => '接受';

  @override
  String get socialAcceptInGame => '請在遊戲中接受此邀請。';

  @override
  String socialActionFailed(String message) {
    return '無法完成操作。$message';
  }

  @override
  String get socialAutoRefresh => '自動重新整理';

  @override
  String get socialAway => '暫離';

  @override
  String socialCancelQueue(String elapsed) {
    return '取消配對 · $elapsed';
  }

  @override
  String get socialCancelQueueShort => '取消配對';

  @override
  String socialCantQueue(String queue, String reason) {
    return '隊伍目前無法進行$queue配對：$reason';
  }

  @override
  String get socialChangeQueue => '更換模式';

  @override
  String get socialChatTitle => '聊天';

  @override
  String get socialChatUnavailable => '聊天目前離線。';

  @override
  String get socialCloseParty => '關閉隊伍';

  @override
  String get socialClosedState => '僅限受邀者';

  @override
  String get socialCodeInvalid => '隊伍代碼只能包含字母與數字。';

  @override
  String get socialConnecting => '正在連線至聊天…';

  @override
  String get socialCopyCode => '複製';

  @override
  String get socialCurrentQueue => '已選擇';

  @override
  String get socialCustomGameLobby => '隊伍目前在自訂對戰大廳。';

  @override
  String get socialDecline => '拒絕';

  @override
  String get socialDisableCode => '停用代碼';

  @override
  String get socialEmptyChat => '還沒有訊息。打聲招呼吧！';

  @override
  String get socialEmptyChatTitle => '開始聊天';

  @override
  String get socialFailedBadge => '未送出';

  @override
  String get socialFilterAll => '全部';

  @override
  String get socialFilterOnline => '線上';

  @override
  String get socialFilterUnread => '未讀';

  @override
  String get socialFriendsPrivacyNote =>
      '好友清單與訊息直接取自 Riot。ValHub 不會將它們儲存在其他地方。';

  @override
  String socialFriendsSummary(int total, int online) {
    return '$total 位好友 · $online 位在線上';
  }

  @override
  String get socialFriendsTitle => '好友與聊天';

  @override
  String get socialGameNotRunningBody =>
      '隊伍與配對功能只在 VALORANT 於你的電腦或主機上執行時才能使用。請開啟遊戲，然後下拉重新整理。';

  @override
  String get socialGameNotRunningTitle => '請在電腦或遊戲主機上開啟 VALORANT';

  @override
  String get socialGenerateCode => '產生代碼';

  @override
  String get socialHistoryFailed => '無法載入舊訊息。請重新連線後再試一次。';

  @override
  String get socialIdleQueue => '準備配對';

  @override
  String get socialInMatchBanner => '你正在對戰中。對戰結束後即可重新配對。';

  @override
  String get socialInValorant => '在 VALORANT 中';

  @override
  String get socialInviteByRiotId => '透過 Riot ID 邀請';

  @override
  String get socialInviteByRiotIdHint => '也能邀請還不是好友的玩家';

  @override
  String get socialInviteFriends => '邀請好友';

  @override
  String socialInviteFrom(String name) {
    return '來自 $name 的邀請';
  }

  @override
  String socialInviteLabel(String name) {
    return '邀請 $name';
  }

  @override
  String get socialInviteNeedsName => '目前不知道此玩家的 Riot ID，因此還無法邀請。';

  @override
  String socialInviteSent(String name) {
    return '已向 $name 送出邀請。';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · 已邀請';
  }

  @override
  String get socialInvitesSection => '邀請';

  @override
  String get socialJoin => '加入';

  @override
  String get socialJoinConfirmBody => '你將離開目前的隊伍，加入此代碼的隊伍。';

  @override
  String get socialJoinConfirmTitle => '要加入其他隊伍嗎？';

  @override
  String get socialJoinSection => '加入其他隊伍';

  @override
  String get socialJoinWithCode => '輸入代碼以加入';

  @override
  String get socialJoined => '已加入隊伍。';

  @override
  String socialLastOnline(String relative) {
    return '$relative上線';
  }

  @override
  String get socialLeader => '隊長';

  @override
  String socialLeaderboardTop(String position) {
    return '前 $position 名';
  }

  @override
  String get socialLeaveConfirmBody => '你將離開目前的隊伍，回到單人隊伍。';

  @override
  String get socialLeaveConfirmTitle => '要離開隊伍嗎？';

  @override
  String get socialLeaveParty => '離開隊伍';

  @override
  String socialLevel(int n) {
    return '等級 $n';
  }

  @override
  String get socialMatchFound => '已找到對戰！';

  @override
  String socialMembersSection(int n, int max) {
    return '成員（$n/$max）';
  }

  @override
  String get socialMessageHint => '輸入訊息…';

  @override
  String get socialMoreActions => '更多選項';

  @override
  String get socialNoCode => '產生代碼，讓好友透過代碼快速加入你的隊伍。';

  @override
  String get socialNoCodeMember => '隊長可以產生代碼以便快速邀請。';

  @override
  String get socialNoFilterResults => '沒有符合此篩選條件的好友。';

  @override
  String get socialNoFriends => '你的 Riot 好友清單是空的。請在遊戲中新增好友。';

  @override
  String get socialNoFriendsTitle => '尚無好友';

  @override
  String get socialNoOnlineFriends => '目前沒有好友在 VALORANT 線上。';

  @override
  String get socialNoSearchResults => '找不到符合的好友。';

  @override
  String get socialNoSearchResultsTitle => '找不到結果';

  @override
  String get socialNotFriend => '此玩家不在你的好友清單中。';

  @override
  String get socialNotReady => '未準備';

  @override
  String socialOfflineSection(int n) {
    return '離線（$n）';
  }

  @override
  String get socialOfflineStatus => '離線';

  @override
  String get socialOnlineMobile => '在手機上線上';

  @override
  String socialOnlineSection(int n) {
    return '線上（$n）';
  }

  @override
  String get socialOnlineStatus => '線上';

  @override
  String get socialOnlyLeader => '只有隊長可以更換模式並開始配對。';

  @override
  String get socialOpenParty => '開放隊伍';

  @override
  String get socialOpenState => '開放隊伍';

  @override
  String get socialOtherGamesLeagueOfLegends => '英雄聯盟';

  @override
  String get socialOtherGamesBacon => '符文大地傳說';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => '隊伍代碼';

  @override
  String socialPartyCodeValue(String code) {
    return '隊伍代碼：$code';
  }

  @override
  String get socialPartyInvite => '隊伍邀請';

  @override
  String socialPartyOf(int size, int max) {
    return '隊伍 $size/$max';
  }

  @override
  String get socialPartyTitle => '隊伍與配對';

  @override
  String socialPickQueueSubtitle(int size) {
    return '$size 人隊伍';
  }

  @override
  String get socialPickQueueTitle => '選擇模式';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => '與對戰伺服器的最佳延遲';

  @override
  String socialPlayingOther(String game) {
    return '正在玩 $game';
  }

  @override
  String socialPlayingSection(int n) {
    return '遊戲中（$n）';
  }

  @override
  String get socialQueueLabel => '模式';

  @override
  String get socialQueueLocked => '對戰中無法更換模式。';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '最多 $max 人',
      one: '僅限單人',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable => '無法確認遊戲狀態。請重新整理以使用準備與配對功能。';

  @override
  String get socialReady => '準備';

  @override
  String socialReadyCount(int ready, int total) {
    return '已準備 $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => '有成員的帳號等級不足';

  @override
  String get socialReasonGeneric => '隊伍尚未符合資格';

  @override
  String socialReasonPartyTooLarge(int max) {
    return '隊伍人數過多（最多 $max 人）';
  }

  @override
  String get socialReasonRankDisparity => '牌位差距過大，無法進行競技模式';

  @override
  String socialReasonRestricted(String time) {
    return '隊伍目前被限制配對（剩餘 $time）';
  }

  @override
  String get socialReconnecting => '聊天連線中斷，正在重新連線…';

  @override
  String get socialRemoteNote => '所有變更只會在你點選時傳送給 Riot。ValHub 絕不會替你開始配對或鎖定特務。';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name 將被移出你的隊伍。';
  }

  @override
  String get socialRemoveConfirmTitle => '要移出隊伍嗎？';

  @override
  String get socialRemoveMember => '移出隊伍';

  @override
  String socialRequestFrom(String name) {
    return '$name 想加入隊伍';
  }

  @override
  String get socialRequestsSection => '加入請求';

  @override
  String get socialRiotIdFieldHint => '名稱#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID 由名稱（3–16 個字元）、# 與標籤（3–5 個字母或數字）組成。';

  @override
  String get socialSearchHint => '依 Riot ID 搜尋…';

  @override
  String socialSearching(String elapsed) {
    return '配對中 · $elapsed';
  }

  @override
  String get socialSend => '送出';

  @override
  String get socialSendFailed => '無法送出訊息。請檢查連線後再試一次。';

  @override
  String get socialSendInvite => '送出邀請';

  @override
  String get socialShareCode => '分享';

  @override
  String socialShareCodeText(String code) {
    return '用這個代碼加入我的 VALORANT 隊伍：$code';
  }

  @override
  String get socialShootingRange => '在訓練場';

  @override
  String get socialShowEveryone => '查看全部';

  @override
  String get socialStartQueue => '開始配對';

  @override
  String get socialSuggestionsItem0 => '嗨！';

  @override
  String get socialSuggestionsItem1 => '要不要一起打幾場？';

  @override
  String get socialSuggestionsItem2 => '來加入我的隊伍吧！';

  @override
  String socialUnread(int n) {
    return '$n 則未讀訊息';
  }

  @override
  String get socialUnready => '取消準備';

  @override
  String get socialViewProfile => '查看個人檔案';

  @override
  String get socialWaitingForConnection => '正在連線…連線完成後即可傳送訊息。';

  @override
  String get socialYou => '你';

  @override
  String get socialPartyUnavailable => '無法同步隊伍。請重新整理再試一次。';

  @override
  String get storeAccessoryEmpty => '配件商店目前沒有任何商品。';

  @override
  String get storeAccessoryEmptyTitle => '尚無配件';

  @override
  String storeAccessoryFrom(String contract) {
    return '來源：$contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return '$t後更新';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return '更新時間：$wall';
  }

  @override
  String get storeAddToWishlist => '加入願望清單';

  @override
  String get storeBackToBundles => '查看販售中的組合包';

  @override
  String get storeBundleBuySeparateLabel => '單獨購買';

  @override
  String get storeBundleDetailTitle => '組合包詳情';

  @override
  String storeBundleEndsAt(String wall) {
    return '結束時間：$wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return '剩餘 $t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n 個物品';
  }

  @override
  String get storeBundleItemFree => '免費';

  @override
  String get storeBundleItemsTitle => '組合包內容';

  @override
  String get storeBundleNotFound => '找不到此組合包，可能已經下架。';

  @override
  String get storeBundleNotFoundTitle => '組合包已下架';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return '已擁有 $owned/$total 個物品';
  }

  @override
  String get storeBundlePriceLabel => '組合包價格';

  @override
  String get storeBundleSavingsLabel => '省下';

  @override
  String get storeBundleWholesaleOnly => '僅以整組販售，無法單獨購買。';

  @override
  String get storeBundlesEmpty => '目前沒有販售中的組合包。';

  @override
  String get storeBundlesEmptyTitle => '尚無組合包';

  @override
  String get storeDailyEmpty => '今天的商店沒有任何造型。';

  @override
  String get storeDailyEmptyTitle => '商店是空的';

  @override
  String storeDailyResetAt(String time) {
    return '每天 $time 更新';
  }

  @override
  String get storeDailyTotalLabel => '總計';

  @override
  String get storeNightMarketEmpty => '目前沒有夜市。';

  @override
  String get storeNightMarketEmptyTitle => '夜市尚未開張';

  @override
  String storeNightMarketEndsAt(String wall) {
    return '結束時間：$wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return '$t後結束';
  }

  @override
  String get storeNightMarketNote => '夜市優惠為你的帳號專屬，且無法重新整理。';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return '總共省下 $amount';
  }

  @override
  String get storeNightMarketUnrevealed => '未翻開';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name，$price';
  }

  @override
  String get storeOwnedBadge => '已擁有';

  @override
  String storeOwnedCount(int owned, int total) {
    return '已擁有 $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => '從願望清單移除';

  @override
  String storeResetNotificationBody(int skinCount, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      skinCount,
      locale: localeName,
      other: '查看 $account 今天的 $skinCount 款新造型。',
      zero: '查看 $account 今天的新造型。',
    );
    return '$_temp0';
  }

  @override
  String get storeResetNotificationTitle => '商店已更新';

  @override
  String storeResetsIn(String t) {
    return '$t後更新';
  }

  @override
  String get storeSegmentAccessories => '配件';

  @override
  String get storeSegmentBundles => '組合包';

  @override
  String get storeSegmentDaily => '每日';

  @override
  String get storeSegmentNightMarket => '夜市';

  @override
  String get storeShareButton => '分享';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => '今日商店';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => '夜市';

  @override
  String get storeShareCardPriceNote => '換算價格僅為依 VP 方案的估算值。';

  @override
  String storeShareCardSaved(String vp) {
    return '省下 $vp';
  }

  @override
  String get storeShareCardTagline => '你的 VALORANT 好幫手';

  @override
  String storeShareCardTotal(String vp) {
    return '總計 $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return '至 $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => '分享今日商店';

  @override
  String get storeShareFailed => '無法產生圖片，請再試一次。';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => '分享圖片';

  @override
  String get storeShareNightMarketTitle => '分享夜市';

  @override
  String get storeSharePreparing => '正在載入造型圖片…';

  @override
  String get storeShareShowPrice => '顯示估算換算價格';

  @override
  String get storeShareShowPriceHint => '依最划算的 VP 方案換算。';

  @override
  String get storeShareShowRiotId => '在圖片上顯示 Riot ID';

  @override
  String get storeShareShowRiotIdHint => '預設關閉，以保護你的隱私。';

  @override
  String get storeShareSubjectDaily => '我今天的 VALORANT 商店';

  @override
  String get storeShareSubjectNightMarket => '我的 VALORANT 夜市';

  @override
  String get storeShareSubtitle => '透過你選擇的 App 與好友分享商店圖片。';

  @override
  String get storeTitle => '商店';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return '餘額：$vp VP、$kc KC、$rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '願望清單中有 $n 款';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin 出現在 $account 的商店中 — 剩餘 $left。',
      'other': '$skin 出現在 $account 的商店中。',
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
      'discount': '$skin 降價 $percent%，現在只要 $price（$account）。',
      'price': '$skin 只要 $price（$account）。',
      'other': '$skin 出現在 $account 的夜市中。',
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
      'yes': '$skin 包含在「$bundle」組合包中（$account）。',
      'other': '$skin 包含在販售中的組合包內（$account）。',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names 及其他 $more 款造型出現在 $account 的商店中。',
      zero: '$names 出現在 $account 的商店中。',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '，已在願望清單中',
      'other': '',
    });
    return '$name，$price$_temp0';
  }

  @override
  String get wishlistAddSkins => '新增造型';

  @override
  String get wishlistAddToWishlist => '加入願望清單';

  @override
  String get wishlistAllWeapons => '所有武器';

  @override
  String get wishlistBrowseCatalog => '查看所有造型';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 款造型';
  }

  @override
  String get wishlistCatalogEmpty => '無法載入造型清單。請重新整理再試一次。';

  @override
  String get wishlistCatalogEmptyTitle => '尚無造型';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '願望清單中：$count';
  }

  @override
  String get wishlistCatalogSubtitle => '點選 ♡ 即可將造型加入願望清單';

  @override
  String get wishlistCatalogTitle => '所有造型';

  @override
  String get wishlistChooseWeapon => '選擇武器';

  @override
  String get wishlistClearFilters => '清除篩選';

  @override
  String get wishlistClearSearch => '清除搜尋';

  @override
  String get wishlistEmpty => '願望清單是空的。在任何造型上點選 ♡ 即可加入。';

  @override
  String get wishlistEmptyTitle => '還沒有任何造型';

  @override
  String wishlistEndsIn(String time) {
    return '$time後結束';
  }

  @override
  String get wishlistExcludedRewards => '不含獎勵造型';

  @override
  String get wishlistFilterTiers => '版本';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '篩選中：$countString 款造型 · $value';
  }

  @override
  String get wishlistHasEstimates => '含估算價格（≈）';

  @override
  String get wishlistInWishlist => '已在願望清單中';

  @override
  String get wishlistInWishlistLabel => '已在願望清單中';

  @override
  String get wishlistNoMatch => '沒有符合的造型。清除篩選即可查看更多。';

  @override
  String get wishlistNoMatchTitle => '找不到造型';

  @override
  String get wishlistNotifBundleTitle => '新組合包含有願望清單中的造型';

  @override
  String get wishlistNotifDailyTitle => '願望清單中的造型出現了！';

  @override
  String get wishlistNotifNightMarketTitle => '夜市有你想要的造型！';

  @override
  String get wishlistNotifPermissionMissing => 'App 尚未取得傳送通知的權限。';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return '願望清單中有 $count 款造型正在販售！';
  }

  @override
  String get wishlistNotifToggle => '願望清單通知';

  @override
  String get wishlistNotifToggleSubtitle => '適用於此帳號，即使你沒有開啟 App';

  @override
  String wishlistOfAccount(String riotId) {
    return '$riotId 的願望清單';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '願望清單中有 $count 款造型正在販售！',
      one: '願望清單中有一款造型正在販售！',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => '點選標示的項目即可查看優惠。';

  @override
  String get wishlistOpenSettings => '開啟設定';

  @override
  String get wishlistOwned => '已擁有';

  @override
  String get wishlistRemoveAction => '從願望清單移除';

  @override
  String get wishlistRemoveFromWishlist => '從願望清單移除';

  @override
  String wishlistRemoved(String name) {
    return '已將 $name 從願望清單移除';
  }

  @override
  String get wishlistSearchHint => '搜尋造型…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 款造型';
  }

  @override
  String get wishlistSortBy => '排序';

  @override
  String wishlistSortLabel(String sort) {
    return '排序：$sort';
  }

  @override
  String get wishlistSortName => '名稱';

  @override
  String get wishlistSortPrice => '價格';

  @override
  String get wishlistSortRarity => '稀有度';

  @override
  String get wishlistSortWeapon => '武器';

  @override
  String get wishlistStoreCheckTitle => '無法檢查商店';

  @override
  String get wishlistSubtitle => '你想要的造型';

  @override
  String get wishlistTitle => '願望清單';

  @override
  String get wishlistTotalValue => '願望清單總價值';

  @override
  String get wishlistUndo => '復原';

  @override
  String get wishlistViewInStore => '在商店中查看';

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
      'yes': '，在願望清單中',
      'other': '',
    });
    return '$name，$price，$tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '，在願望清單中',
      'other': '',
    });
    return '$name，$votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': '上升',
      'other': '下降',
    });
    return '今天$_temp0 $rr RR，$wins 勝，$losses 敗';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: '，$draws 平',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: '，$unknown 場結果不明',
      zero: '',
    );
    return '$wins 勝 – $losses 敗$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => '開啟「自訂首頁」即可重新顯示。';

  @override
  String get homeAllHiddenTitle => '你已隱藏所有卡片';

  @override
  String get homeCardBattlePass => '戰鬥通行證';

  @override
  String get homeCardBattlePassDesc => '等級、每日所需 XP 與每週任務。';

  @override
  String get homeCardCommunity => '社群';

  @override
  String get homeCardCommunityDesc => '尋找牌位相近的隊友，以及本週最受喜愛的造型。';

  @override
  String get homeCardFriends => '遊戲中的好友';

  @override
  String get homeCardFriendsDesc => '正在對戰或配對中的好友。';

  @override
  String homeCardHidden(String name) {
    return '已隱藏「$name」';
  }

  @override
  String get homeCardLive => '目前對戰';

  @override
  String get homeCardLiveDesc => '在你配對、選擇特務或對戰中時顯示。';

  @override
  String get homeCardOtherAccounts => '其他帳號';

  @override
  String get homeCardOtherAccountsDesc => '其他帳號的狀態與願望清單。';

  @override
  String get homeCardRank => '牌位與狀態';

  @override
  String get homeCardRankDesc => '牌位、今日 RR、連勝連敗與升牌所需場數。';

  @override
  String get homeCardServerStatus => '伺服器狀態';

  @override
  String get homeCardServerStatusDesc => '只在維護或異常時顯示。';

  @override
  String get homeCardStore => '今日商店';

  @override
  String get homeCardStoreDesc => '每日造型、願望清單與夜市。';

  @override
  String get homeCustomize => '自訂首頁';

  @override
  String get homeCustomizeHint => '拖曳即可排序。關閉即可隱藏卡片。';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return '已跳至 $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name，$status';
  }

  @override
  String get homeFriendsConsentAllow => '開啟';

  @override
  String get homeFriendsConsentBody =>
      '為了顯示哪些好友正在遊戲中，ValHub 會在你每次開啟首頁時，連線至目前帳號的 Riot 聊天。好友會看到你顯示為線上。你可以在「自訂首頁」中關閉此功能。';

  @override
  String get homeFriendsConsentDecline => '不用，隱藏卡片';

  @override
  String get homeFriendsConsentTitle => '要查看哪些好友正在遊戲中嗎？';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n 位好友正在遊戲中';
  }

  @override
  String get homeFriendsSeeAll => '查看全部';

  @override
  String get homeHideCard => '隱藏此卡片';

  @override
  String homeLeaderboard(String pos) {
    return '排行榜第 $pos 名';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return '剩餘 $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return '需要 $n 人';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author，$details';
  }

  @override
  String get homeLfgTitle => '尋找與你牌位相近的隊友';

  @override
  String get homeLiveAllyLabel => '我方';

  @override
  String get homeLiveEnemyLabel => '敵隊';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return '配對中，已等待 $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return '我方 $ally，敵隊 $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '競技模式 $n 連敗';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n 場即可升上$rank';
  }

  @override
  String homeMoreActions(String name) {
    return '$name 的選項';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return '重新登入即可更新 $riotId 的商店、牌位與戰鬥通行證。你仍可查看儲存在裝置上的版本。';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return '剩餘 $time';
  }

  @override
  String get homeNightMarketNew => '新';

  @override
  String get homeNightMarketTitle => '夜市';

  @override
  String homeNightMarketWaiting(int n) {
    return '有 $n 個優惠等你翻開';
  }

  @override
  String get homeNoRankedToday => '今天還沒有進行競技模式';

  @override
  String get homeOpenLfg => '查看所有找隊友貼文';

  @override
  String get homeOpenRanking => '查看造型排行榜';

  @override
  String homeOtherAccountsTitle(int n) {
    return '其他帳號（$n）';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n 個帳號';
  }

  @override
  String get homeOtherWishlistHit => '有願望清單中的造型';

  @override
  String homePreviousAct(String rank) {
    return '上一章：$rank';
  }

  @override
  String get homeQuietBody => '下拉即可重新整理。';

  @override
  String get homeQuietTitle => '目前沒有新消息';

  @override
  String homeRankToNext(int rr) {
    return '還差 $rr RR 升牌';
  }

  @override
  String get homeResetLayout => '恢復預設';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day：$value';
  }

  @override
  String homeRrToday(String value) {
    return '今天 $value';
  }

  @override
  String get homeStatusDetails => '詳情';

  @override
  String homeStatusIncident(String region) {
    return '伺服器異常 · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return '維護中 · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return '即將維護 · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n 則公告';
  }

  @override
  String get homeStoreRefreshing => '正在重新整理…';

  @override
  String homeStoreResetsIn(String time) {
    return '$time後更新';
  }

  @override
  String homeStoreTotal(String vp) {
    return '總計 $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return '錢包 $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return '錢包 $vp · 最多可購買 $n 款造型';
  }

  @override
  String get homeStoreWishlistHit => '商店中有願望清單的造型！';

  @override
  String homeStoreWishlistHits(int n) {
    return '願望清單中有 $n 款造型正在販售';
  }

  @override
  String get homeTitle => '首頁';

  @override
  String get homeTrendingTitle => '全球最受喜愛的造型';

  @override
  String homeTrendingVotes(int n) {
    return '$n 個讚';
  }

  @override
  String get homeUndo => '復原';

  @override
  String homeWinStreak(int n) {
    return '競技模式 $n 連勝';
  }

  @override
  String get homeStoreOutdated => '商店已更新。ValHub 暫時無法載入新的商店。';

  @override
  String get communityErrorConsent => '請同意與社群分享你的 Riot ID 以繼續。';

  @override
  String get communityErrorForbidden => '你目前還無法執行此操作。請查看社群守則或聯絡 ValHub。';

  @override
  String get communityErrorGeneric => '發生了一些問題，請再試一次。';

  @override
  String get communityErrorImageTooLarge => '圖片過大（上限 2 MB）。請選擇其他圖片。';

  @override
  String get communityErrorImageType => '請選擇 JPEG、PNG 或 WebP 圖片。';

  @override
  String get communityErrorInvalid => '內容未被接受。請檢查後再試一次。';

  @override
  String get communityErrorNetwork => '無法連線至 ValHub 社群。請檢查網路後再試一次。';

  @override
  String get communityErrorNotFound => '此內容已不存在。';

  @override
  String get communityErrorPickImage => '無法開啟相簿，請再試一次。';

  @override
  String get communityErrorRateLimited => '社群目前收到過多請求。請稍後再試。';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return '社群目前收到過多請求。請在 $duration後再試。';
  }

  @override
  String get communityErrorRiotRejected => 'Riot 無法驗證你的帳號。請重新登入 Riot 帳號後再試一次。';

  @override
  String get communityErrorRiotUnavailable => 'Riot 目前發生問題，請稍後再試。';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot 目前發生問題，請在 $duration後再試。';
  }

  @override
  String get communityErrorServer => 'ValHub 社群目前發生問題，請稍後再試。';

  @override
  String get communityErrorStorageFull => '社群的相片空間已滿。你仍可發文，但暫時無法附加相片。請稍後再試。';

  @override
  String get communityErrorTimeout => 'ValHub 社群回應時間過長，請再試一次。';

  @override
  String get communityErrorTitle => '未完成';

  @override
  String get communityErrorUnauthorized => '社群連線已過期，請再試一次。';

  @override
  String get communityErrorImageQuota => '你的圖片儲存空間已用完。請刪除一些含圖片的貼文後再試。';

  @override
  String get smokePlain => '產生程式碼檢查';

  @override
  String smokeGreeting(String name) {
    return '你好，$name！';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 個項目',
    );
    return '$_temp0';
  }
}
