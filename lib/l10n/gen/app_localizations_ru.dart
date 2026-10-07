// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Источник цен';

  @override
  String get commonErrorApi =>
      'У Riot возникли неполадки. Повторите попытку через несколько минут.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClearFilters => 'Сбросить фильтры';

  @override
  String get commonClearSearch => 'Очистить поиск';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonCopied => 'Скопировано';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня',
      many: '$n дней',
      few: '$n дня',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня назад',
      many: '$n дней назад',
      few: '$n дня назад',
      one: '$n день назад',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEmptyGeneric => 'Здесь пока ничего нет.';

  @override
  String get commonErrorContentUnavailable =>
      'Не удалось загрузить скины, агентов и карты. Проверьте подключение и повторите попытку.';

  @override
  String get commonErrorGeneric => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get commonErrorMaintenance =>
      'На серверах VALORANT идут технические работы. Загляните позже.';

  @override
  String get commonErrorNeedsLogin =>
      'Срок входа в Riot истек. Войдите снова, чтобы продолжить.';

  @override
  String get commonErrorNeedsLoginTitle => 'Войдите снова';

  @override
  String get commonErrorNetwork =>
      'Нет подключения. Проверьте Wi-Fi или мобильный интернет и повторите попытку.';

  @override
  String get commonErrorNoAccount => 'Вы не вошли ни в один аккаунт.';

  @override
  String get commonErrorNotFound => 'Не удалось найти этот контент.';

  @override
  String get commonErrorTimeout =>
      'Riot слишком долго не отвечает. Проверьте подключение и повторите попытку.';

  @override
  String get commonErrorTransient =>
      'Riot сейчас перегружен. Повторите попытку через несколько минут.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot сейчас перегружен. Повторите попытку через $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Не удалось определить ваш регион Riot. Выберите регион в настройках.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'На главную';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n часа',
      many: '$n часов',
      few: '$n часа',
      one: '$n час',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n часа назад',
      many: '$n часов назад',
      few: '$n часа назад',
      one: '$n час назад',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Неполадки на сервере';

  @override
  String get commonJustNow => 'только что';

  @override
  String get commonLoadMore => 'Загрузить еще';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonMaintenanceTitle => 'Технические работы';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n минуты',
      many: '$n минут',
      few: '$n минуты',
      one: '$n минута',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n минуты назад',
      many: '$n минут назад',
      few: '$n минуты назад',
      one: '$n минуту назад',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Пока нечего показать';

  @override
  String commonOfflineCached(String time) {
    return 'Нет сети — показаны сохраненные данные ($time).';
  }

  @override
  String get commonOpenSettings => 'Открыть настройки';

  @override
  String get commonPageNotFound => 'Не удалось найти этот экран.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Самый выгодный набор: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Изменить вашу цену';

  @override
  String get commonPriceEnterOwn => 'Укажите цену набора VP';

  @override
  String get commonPriceEstimateBody =>
      'Сумма «≈ …» рядом с ценой в VP — это примерная оценка по самому выгодному набору VP. В игре вы платите VP; реальная сумма зависит от набора, способа оплаты, налогов и акций на момент покупки.';

  @override
  String get commonPriceEstimateTitle => 'Примерная цена';

  @override
  String get commonPriceEstimateTooltip =>
      'Примерная цена — нажмите, чтобы узнать, как она рассчитана';

  @override
  String get commonPriceHidden =>
      'Примерные цены скрыты. Их можно снова включить в настройках.';

  @override
  String get commonPriceHide => 'Скрыть примерные цены';

  @override
  String get commonPriceOpenSource => 'Открыть источник';

  @override
  String get commonPriceOverrideBody =>
      'Укажите сумму, которую вы на самом деле заплатили за набор VP (см. магазин в игре или чек). ValHub использует эту цену, чтобы оценить стоимость любого предмета; она хранится только на этом устройстве.';

  @override
  String get commonPriceOverrideCurrency => 'Код валюты';

  @override
  String get commonPriceOverrideCurrencyHint => 'Например: RUB, USD, EUR, KZT';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Пример оценки: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Введите трехбуквенный код валюты, например RUB или USD.';

  @override
  String get commonPriceOverrideInvalidNumber => 'Введите число больше 0.';

  @override
  String get commonPriceOverridePrice => 'Цена набора';

  @override
  String get commonPriceOverrideRemove => 'Удалить вашу цену';

  @override
  String get commonPriceOverrideRemoved => 'Ваша цена удалена.';

  @override
  String get commonPriceOverrideSave => 'Сохранить цену';

  @override
  String get commonPriceOverrideSaved => 'Цена набора VP сохранена.';

  @override
  String get commonPriceOverrideTitle => 'Ваша цена набора VP';

  @override
  String get commonPriceOverrideVp => 'VP в наборе';

  @override
  String get commonPricePacksTitle => 'Наборы VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'По ценам наборов VP в регионе $country';
  }

  @override
  String get commonPriceSourceUser => 'По указанной вами цене набора VP';

  @override
  String get commonPriceUnavailable =>
      'Для вашего региона пока нет проверенного прайс-листа. Укажите цену набора VP, который вы покупали, чтобы видеть примерные цены.';

  @override
  String commonPriceUpdated(String date) {
    return 'Цены обновлены: $date';
  }

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonRiotDisclaimer =>
      'ValHub не одобрен Riot Games и не отражает взгляды или мнения Riot Games или кого-либо из официально участвующих в создании или управлении проектами Riot Games. Riot Games и все связанные с ней проекты являются товарными знаками или зарегистрированными товарными знаками Riot Games, Inc.';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSearch => 'Поиск…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n секунды',
      many: '$n секунд',
      few: '$n секунды',
      one: '$n секунда',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Поделиться';

  @override
  String get commonSignInAgain => 'Войти снова';

  @override
  String get commonSort => 'Сортировка';

  @override
  String commonSortBy(String option) {
    return 'Сортировка: $option';
  }

  @override
  String get commonTabBattlePass => 'Боевой пропуск';

  @override
  String get commonTabCollection => 'Коллекция';

  @override
  String get commonTabCommunity => 'Сообщество';

  @override
  String get commonTabHome => 'Главная';

  @override
  String get commonTabProfile => 'Профиль';

  @override
  String get commonTabSettings => 'Настройки';

  @override
  String get commonTabStore => 'Магазин';

  @override
  String get commonTagline => 'Ваш помощник в VALORANT';

  @override
  String get commonToday => 'Сегодня';

  @override
  String get commonTodayLower => 'сегодня';

  @override
  String get commonTomorrow => 'завтра';

  @override
  String get commonUnknownItem => 'Неизвестный предмет';

  @override
  String commonUpdatedAt(String time) {
    return 'Обновлено в $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Понедельник';

  @override
  String get commonWeekdaysItem1 => 'Вторник';

  @override
  String get commonWeekdaysItem2 => 'Среда';

  @override
  String get commonWeekdaysItem3 => 'Четверг';

  @override
  String get commonWeekdaysItem4 => 'Пятница';

  @override
  String get commonWeekdaysItem5 => 'Суббота';

  @override
  String get commonWeekdaysItem6 => 'Воскресенье';

  @override
  String get commonYesterday => 'вчера';

  @override
  String get commonYesterdayTitle => 'Вчера';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Вход в Riot истёк — показаны сохраненные данные ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Тяжелое оружие';

  @override
  String get contentCategoryMelee => 'Ближний бой';

  @override
  String get contentCategoryRifle => 'Автоматы';

  @override
  String get contentCategoryShotgun => 'Дробовики';

  @override
  String get contentCategorySidearm => 'Личное оружие';

  @override
  String get contentCategorySmg => 'ПП';

  @override
  String get contentCategorySniper => 'Снайперские винтовки';

  @override
  String get contentCurrencyAgentTokens => 'Жетоны агентов';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Кредиты Kingdom';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Радианит';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT POINTS';

  @override
  String get contentItemAgent => 'Агент';

  @override
  String get contentItemBuddy => 'Брелок';

  @override
  String get contentItemCard => 'Карточка игрока';

  @override
  String get contentItemChroma => 'Вариант';

  @override
  String get contentItemContract => 'Контракт';

  @override
  String get contentItemCurrency => 'Валюта';

  @override
  String get contentItemFlex => 'Флекс';

  @override
  String get contentItemSkin => 'Скин';

  @override
  String get contentItemSpray => 'Граффити';

  @override
  String get contentItemTitle => 'Звание';

  @override
  String contentLevel(int n) {
    return 'Уровень $n';
  }

  @override
  String get contentLevelBase => 'Базовый';

  @override
  String get contentLevelItemLabelsVFX => 'Визуальные эффекты';

  @override
  String get contentLevelItemLabelsAnimation => 'Анимация';

  @override
  String get contentLevelItemLabelsFinisher => 'Добивание';

  @override
  String get contentLevelItemLabelsKillCounter => 'Счетчик убийств';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Звуковые эффекты';

  @override
  String get contentLevelItemLabelsTransformation => 'Трансформация';

  @override
  String get contentLevelItemLabelsKillBanner => 'Баннер убийства';

  @override
  String get contentLevelItemLabelsKillEffect => 'Эффект убийства';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Эффекты осмотра и убийства';

  @override
  String get contentLevelItemLabelsVoiceover => 'Озвучка';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Смена трека';

  @override
  String get contentLevelItemLabelsRandomizer => 'Случайный выбор';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Смена за атаку/защиту';

  @override
  String get contentLevelItemLabelsTopFrag => 'Эффект лучшего игрока';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Датчик пульса и карты';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Анимация рыбы';

  @override
  String get contentNoTitle => 'Без звания';

  @override
  String get contentNotForSale => 'Не продается';

  @override
  String get contentQueueNamesCompetitive => 'Рейтинговая игра';

  @override
  String get contentQueueNamesUnrated => 'Без ранга';

  @override
  String get contentQueueNamesSwiftplay => 'Быстрая игра';

  @override
  String get contentQueueNamesSpikerush => 'Быстр. установка Spike';

  @override
  String get contentQueueNamesDeathmatch => 'Бой насмерть';

  @override
  String get contentQueueNamesHurm => 'Командный бой насмерть';

  @override
  String get contentQueueNamesGgteam => 'Эскалация';

  @override
  String get contentQueueNamesOnefa => 'Репликация';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Своя игра';

  @override
  String get contentQueueNames => 'Своя игра';

  @override
  String get contentQueueNamesDodgeball => 'Нокаут';

  @override
  String get contentQueueNamesFortcollins => 'Захват';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Столкновение: 2x2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Столкновение: возвышение 1x1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Столкновение: возвышение 2x2';

  @override
  String get contentQueueNamesValaram => 'Случайные агенты, одна точка';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Игра в снежки';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Рейтинг';

  @override
  String get contentQueueShortNamesValaram => 'Случайные';

  @override
  String get contentRewardSourceAgent => 'Контракт агента';

  @override
  String get contentRewardSourceBattlePass => 'Награда боевого пропуска';

  @override
  String get contentRewardSourceEvent => 'Пропуск события';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Дуэлянт';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Зачинщик';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Специалист';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Страж';

  @override
  String get contentTierDeluxe => 'Специальное';

  @override
  String get contentTierExclusive => 'Эксклюзивное';

  @override
  String contentTierFull(String shortName) {
    return '$shortName издание';
  }

  @override
  String get contentTierPremium => 'Премиальное';

  @override
  String get contentTierSelect => 'Стандартное';

  @override
  String get contentTierUltra => 'Ультра';

  @override
  String get contentUnranked => 'Без ранга';

  @override
  String get accountRegionUnknown => 'Регион неизвестен';

  @override
  String accountRiotCountry(String country) {
    return 'Страна аккаунта Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Страна аккаунта Riot: не определена';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'АККАУНТЫ ($count/$max)';
  }

  @override
  String get accountActive => 'Активен';

  @override
  String accountAddAccount(int count, int max) {
    return 'Добавить аккаунт ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Удалить локальные данные';

  @override
  String get accountClearLocalDataConfirm =>
      'Удалить историю, сохраненные комплекты снаряжения и данные аккаунтов, из которых вы вышли, на этом устройстве?';

  @override
  String get accountClearRrHistory => 'Очистить историю RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Очистить историю RR выбранного аккаунта на этом устройстве?';

  @override
  String get accountCopyPassword => 'Копировать пароль';

  @override
  String get accountCopyUsername => 'Копировать имя пользователя';

  @override
  String get accountDeleteLoginNote => 'Удалить данные';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Удалить сохраненные имя пользователя и пароль этого аккаунта?';

  @override
  String get accountHidePassword => 'Скрыть пароль';

  @override
  String get accountKeepLocalData => 'Сохранить локальные данные';

  @override
  String get accountKeepLocalDataHint =>
      'Оставить список желаемого, комплекты снаряжения и историю на этом устройстве';

  @override
  String accountLevelShort(int level) {
    return 'Ур. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Вы вышли из аккаунта, указанного в уведомлении. Войдите снова, а затем откройте уведомление.';

  @override
  String get accountLocalDataCleared => 'Локальные данные удалены';

  @override
  String get accountLoginNote => 'Данные для входа';

  @override
  String get accountLoginNoteDeleted => 'Данные для входа удалены';

  @override
  String get accountLoginNoteEmpty => 'Данные для входа не сохранены';

  @override
  String get accountLoginNoteHint =>
      'Хранятся только на этом устройстве под надежной защитой. Пригодятся, чтобы посмотреть или быстро заполнить данные при повторном входе.';

  @override
  String get accountLoginNoteLocked => 'Открыть данные для входа';

  @override
  String get accountLoginNotePassword => 'Пароль';

  @override
  String get accountLoginNoteSaved => 'Данные для входа сохранены';

  @override
  String get accountLoginNoteUsername => 'Имя пользователя Riot';

  @override
  String get accountManageHint =>
      'Удалить аккаунт или изменить данные для входа можно в настройках.';

  @override
  String accountMaxAccounts(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Достигнут предел: $max аккаунта.',
      many: 'Достигнут предел: $max аккаунтов.',
      few: 'Достигнут предел: $max аккаунта.',
      one: 'Достигнут предел: $max аккаунт.',
    );
    return '$_temp0';
  }

  @override
  String get accountNeedsLogin => 'Войдите снова';

  @override
  String accountOnlineCount(int count) {
    return 'В сети: $count';
  }

  @override
  String get accountPlatformPc => 'ПК';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Заполнить сохраненным';

  @override
  String get accountQuickFillDone => 'Готово. Нажмите «Войти».';

  @override
  String get accountQuickFillNotReady =>
      'Страница входа еще не загрузилась. Подождите немного и повторите попытку.';

  @override
  String get accountQuickFillSubtitle =>
      'Выберите аккаунт, чтобы заполнить страницу входа Riot';

  @override
  String get accountQuickFillTitle => 'Заполнить сохраненным';

  @override
  String get accountRegionAp => 'Азиатско-Тихоокеанский регион';

  @override
  String get accountRegionBr => 'Бразилия';

  @override
  String get accountRegionEu => 'Европа';

  @override
  String get accountRegionKr => 'Корея';

  @override
  String get accountRegionLatam => 'Латинская Америка';

  @override
  String get accountRegionNa => 'Северная Америка';

  @override
  String get accountRemoveAccount => 'Удалить аккаунт';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Удалить $account с этого устройства? Сохраненные данные можно оставить.';
  }

  @override
  String get accountRrHistoryCleared => 'История RR очищена';

  @override
  String get accountShowPassword => 'Показать пароль';

  @override
  String get accountSignOutAll => 'Выйти из всех аккаунтов';

  @override
  String get accountSignOutAllConfirm =>
      'Выйти и удалить все аккаунты с этого устройства? Сохраненные данные можно оставить.';

  @override
  String get accountStatusAgentSelect => 'Выбирает агента';

  @override
  String get accountStatusInMatch => 'В матче';

  @override
  String get accountStatusOffline => 'Не в сети';

  @override
  String get accountStatusOnline => 'В сети';

  @override
  String get accountStatusUnknown => 'Статус неизвестен';

  @override
  String accountSwitchTo(String account) {
    return 'Перейти на $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Нажмите, чтобы сменить аккаунт';

  @override
  String get accountSwitcherTitle => 'Аккаунты';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Аккаунты ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Игрок';

  @override
  String get accountUnlockLoginNote =>
      'Подтвердите личность, чтобы открыть данные для входа Riot';

  @override
  String accountMoreActions(String riotId) {
    return 'Действия с $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Сохранить данные для входа';

  @override
  String get accountClearRrHistorySubtitle => 'Только выбранный аккаунт';

  @override
  String get accountClearLocalDataSubtitle =>
      'История, сохраненные комплекты и данные аккаунтов, из которых вы вышли';

  @override
  String get authAddAsNew => 'Добавить как новый';

  @override
  String get authDifferentAccountBody =>
      'Вы вошли в другой аккаунт, а не в тот, для которого нужен повторный вход. Добавить его как новый аккаунт?';

  @override
  String get authDifferentAccountTitle => 'Другой аккаунт';

  @override
  String get authLoadingAccount => 'Загрузка аккаунта…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot отклонил эту попытку входа. Повторите попытку.';

  @override
  String get authLoginFailed => 'Не удалось завершить вход';

  @override
  String get authLoginFailedBody =>
      'Riot не подтвердил ваш вход. Повторите попытку.';

  @override
  String get authLoginTitle => 'Вход в Riot';

  @override
  String get authMissingCookies =>
      'Не удалось сохранить вход на этом устройстве, поэтому, когда срок его действия истечет, нужно будет войти снова.';

  @override
  String get authOfficialHost => 'Официальная страница · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Ссылка открыта в браузере.';

  @override
  String get authPageLoadFailed =>
      'Не удалось загрузить страницу входа Riot. Проверьте подключение и повторите попытку.';

  @override
  String get authPreparing => 'Подготовка страницы входа…';

  @override
  String get authReloginDone => 'Вход выполнен снова';

  @override
  String get authSignInCta => 'Войти через аккаунт Riot';

  @override
  String get authSocialLoginHint =>
      'Если вход через Google или Facebook не работает, используйте имя пользователя Riot.';

  @override
  String get authStateMismatch =>
      'Эта попытка входа недействительна. Начните вход заново.';

  @override
  String get notificationSessionExpiredBody =>
      'Войдите снова, чтобы и дальше получать уведомления о списке желаемого.';

  @override
  String get notificationBackgroundTimingHint =>
      'Режим энергосбережения устройства может задерживать уведомления.';

  @override
  String get notificationChannelAccountDescription =>
      'Напоминает, когда аккаунту нужен повторный вход';

  @override
  String get notificationChannelAccountName => 'Аккаунты';

  @override
  String get notificationChannelBattlePassDescription =>
      'Напоминания о прогрессе и окончании боевого пропуска';

  @override
  String get notificationChannelBattlePassName => 'Боевой пропуск';

  @override
  String get notificationChannelCommunityDescription =>
      'Активность сообщества при запуске ValHub';

  @override
  String get notificationChannelCommunityName => 'Сообщество';

  @override
  String get notificationChannelLfgDescription =>
      'Игроки, вступившие в вашу группу, при запуске ValHub';

  @override
  String get notificationChannelLfgName => 'Группа';

  @override
  String get notificationChannelNightMarketDescription =>
      'Сообщает об открытии Ночного рынка';

  @override
  String get notificationChannelNightMarketName => 'Ночной рынок';

  @override
  String get notificationChannelRankDescription =>
      'Изменения ранга при обновлении профиля';

  @override
  String get notificationChannelRankName => 'Ранг';

  @override
  String get notificationChannelStoreResetDescription =>
      'Напоминает об обновлении ежедневного магазина';

  @override
  String get notificationChannelStoreResetName => 'Обновление магазина';

  @override
  String get notificationChannelWishlistDescription =>
      'Сообщает, когда скин из списка желаемого появляется в магазине';

  @override
  String get notificationChannelWishlistName => 'Список желаемого';

  @override
  String get notificationLfgJoinedTitle => 'Игрок вступил в вашу группу';

  @override
  String get notificationLocalOnlyHint =>
      'Показываются только на этом устройстве, когда ValHub обновляет данные';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Карт предложений: $cards ($account). Откройте их!';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Ночной рынок открыт!';

  @override
  String get notificationPassEndingBody =>
      'До конца боевого пропуска остался примерно день. Откройте ValHub, чтобы увидеть свой прогресс.';

  @override
  String get notificationPassEndingTitle => 'Боевой пропуск скоро закончится';

  @override
  String notificationPassProgressBody(int level) {
    return 'Вы достигли уровня $level в текущем боевом пропуске.';
  }

  @override
  String get notificationPassProgressTitle => 'Прогресс боевого пропуска';

  @override
  String get notificationPrivateAccount => 'ваш аккаунт';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Текущий ранг: $rank. Данные только что обновлены из Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Ранг изменился';

  @override
  String get notificationResetTimingUnknown =>
      'Откройте магазин, чтобы обновить время сброса на устройстве.';

  @override
  String get notificationSessionExpiredTitle => 'Войдите снова';

  @override
  String get notificationStoreResetBody => 'В магазине вас ждут новые скины.';

  @override
  String get competitiveDivisionIron => 'Железо';

  @override
  String get competitiveDivisionBronze => 'Бронза';

  @override
  String get competitiveDivisionSilver => 'Серебро';

  @override
  String get competitiveDivisionGold => 'Золото';

  @override
  String get competitiveDivisionPlatinum => 'Платина';

  @override
  String get competitiveDivisionDiamond => 'Алмаз';

  @override
  String get competitiveDivisionAscendant => 'Расцвет';

  @override
  String get competitiveDivisionImmortal => 'Бессмертный';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Радиант';

  @override
  String get competitiveRankUnknown => 'Ранг неизвестен';

  @override
  String get competitiveAttack => 'Атака';

  @override
  String get competitiveCannotEstimate => 'Не удается оценить';

  @override
  String get competitiveDefeat => 'Поражение';

  @override
  String get competitiveDefense => 'Защита';

  @override
  String get competitiveDraw => 'Ничья';

  @override
  String get competitiveIncognitoPlayer => 'Скрытый игрок';

  @override
  String get competitiveMatchPending => 'Riot еще обрабатывает этот матч…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Осталось $n квалификационного матча',
      many: 'Осталось $n квалификационных матчей',
      few: 'Осталось $n квалификационных матча',
      one: 'Остался $n квалификационный матч',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike обезврежен';

  @override
  String get competitiveRoundDetonate => 'Spike взорван';

  @override
  String get competitiveRoundElimination => 'Уничтожение';

  @override
  String get competitiveRoundSurrendered => 'Капитуляция';

  @override
  String get competitiveRoundTimeExpired => 'Время вышло';

  @override
  String get competitiveUnknownPlayer => 'Игрок';

  @override
  String get competitiveVictory => 'Победа';

  @override
  String economyAvailableNow(String place) {
    return 'Доступно сейчас: $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'набор $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'набор';

  @override
  String get economyPlaceDaily => 'ежедневный магазин';

  @override
  String get economyPlaceNightMarket => 'Ночной рынок';

  @override
  String get economyPriceEstimated => 'Примерная цена по изданию';

  @override
  String get economyPriceFromOffers => 'Цена из прайс-листа Riot';

  @override
  String get economyPriceFromStore => 'Цена, замеченная в магазине';

  @override
  String get economyPriceFromTable => 'Цена по прайс-листу';

  @override
  String get economyPriceUnknown => 'Цена неизвестна';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Комплект $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Это изменение нельзя применить к текущему снаряжению.';

  @override
  String get loadoutNotPersisted =>
      'Riot не сохранил изменение, поэтому снаряжение осталось прежним. Повторите попытку.';

  @override
  String get loadoutSaveFailed => 'Не удалось сохранить снаряжение';

  @override
  String battlePassActEndsIn(String time) {
    return 'До конца акта: $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Акт закончится через $days дня',
      many: 'Акт закончится через $days дней',
      few: 'Акт закончится через $days дня',
      one: 'Акт закончится через $days день',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Все задания выполнены';

  @override
  String get battlePassAllWeeklyDone => 'Все еженедельные задания выполнены';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Двойные награды в ожидании: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Глава $n';
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
      'Побеждайте в раундах, чтобы продвигаться по этапам (бой насмерть не учитывается).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Этап $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'За каждый этап: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Пройдено этапов: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Текущая';

  @override
  String get battlePassDailyAllDone => 'Все этапы на сегодня пройдены';

  @override
  String get battlePassDailyCaption => 'Ежедневные награды';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Ежедневные награды · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Вчерашние этапы истекли. Зайдите в игру или обновите здесь.';

  @override
  String get battlePassDailyMissions => 'Ежедневные задания';

  @override
  String get battlePassDailyNotReady =>
      'Сегодняшние этапы еще не готовы. Зайдите в игру или обновите здесь.';

  @override
  String get battlePassDailyPlayToStart =>
      'Сегодняшние этапы еще не готовы. Зайдите в игру, чтобы начать новый день.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Осталось $days дня',
      many: 'Осталось $days дней',
      few: 'Осталось $days дня',
      one: 'Остался $days день',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Завершится: $wall';
  }

  @override
  String get battlePassEpilogue => 'Эпилог';

  @override
  String get battlePassEstimateNote =>
      'Примерно 4000 XP за матч, без учета заданий.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Завершится через $time';
  }

  @override
  String get battlePassEventPass => 'Пропуск события';

  @override
  String get battlePassFilterAll => 'Все';

  @override
  String get battlePassFilterLocked => 'Закрытые';

  @override
  String get battlePassFilterUnlocked => 'Открытые';

  @override
  String get battlePassFree => 'Бесплатно';

  @override
  String get battlePassFreeTrack => 'Бесплатные награды';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Уровень $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Ур. $n';
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
      other: '$nString матча',
      many: '$nString матчей',
      few: '$nString матча',
      one: '$nString матч',
    );
    return '≈ $_temp0 ($queue)';
  }

  @override
  String get battlePassMissionDone => 'Выполнено';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'Выполнено: $done/$total';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Новые задания: $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Новые задания через $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Следующий этап: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'До уровня $level';
  }

  @override
  String get battlePassNextReward => 'Далее';

  @override
  String get battlePassNoBattlePass =>
      'Пока нет данных о боевом пропуске текущего акта. Повторите попытку позже.';

  @override
  String get battlePassNoRewards => 'В этом боевом пропуске пока нет наград.';

  @override
  String get battlePassNoRewardsInFilter => 'В этом разделе нет наград.';

  @override
  String get battlePassNoRewardsTitle => 'Наград пока нет';

  @override
  String get battlePassNoWeeklyMissions => 'Сейчас нет еженедельных заданий.';

  @override
  String get battlePassPassComplete => 'Боевой пропуск пройден';

  @override
  String get battlePassPremium => 'Премиум';

  @override
  String get battlePassPremiumHint =>
      'У вас нет премиум-версии: вы получаете только бесплатные награды. Купите премиум-версию в игре, чтобы открыть достигнутые уровни.';

  @override
  String get battlePassRenewButton => 'Обновить этапы';

  @override
  String get battlePassRenewDone => 'Ежедневные этапы обновлены.';

  @override
  String get battlePassRenewFailed =>
      'Не удалось обновить этапы. Повторите попытку позже.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Сброс: $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Сброс через $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Уровень';

  @override
  String get battlePassRewardLocked => 'Закрыто';

  @override
  String get battlePassRewardNeedsPremium => 'Нужен премиум';

  @override
  String get battlePassRewardStatusLabel => 'Статус';

  @override
  String get battlePassRewardTrackLabel => 'Тип награды';

  @override
  String get battlePassRewardTypeLabel => 'Тип';

  @override
  String get battlePassRewardUnlocked => 'Открыто';

  @override
  String get battlePassRewardsTitle => 'Награды';

  @override
  String get battlePassShowAllRewards => 'Все';

  @override
  String get battlePassTitle => 'Боевой пропуск';

  @override
  String get battlePassTotalXpCaption => 'Всего XP';

  @override
  String get battlePassUnknownMission => 'Новое задание (без описания)';

  @override
  String get battlePassUnknownReward => 'Награда';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'Открыто: $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'Без ранга';

  @override
  String get battlePassViewAllRewards => 'Все награды';

  @override
  String get battlePassWeeklyMissions => 'Еженедельные задания';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Еженедельные задания: осталось +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / день';
  }

  @override
  String get battlePassXpPerDayCaption => 'Нужно в день, чтобы успеть';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Осталось набрать: $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Не удалось сохранить снаряжение. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Все ваши скины, оцененные по ценам магазина',
      'buddy': 'Ваши брелоки и количество копий',
      'spray': 'Граффити, которые можно добавить в колесо выражений',
      'card':
          'Открытые карточки игрока: нажмите, чтобы посмотреть и экипировать',
      'title': 'Звания, которые можно показать под именем',
      'flex': 'Ваши предметы флекс',
      'other': 'Просмотр коллекции',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Слот: $position';
  }

  @override
  String get collectionApplyPreset => 'Применить';

  @override
  String get collectionApplyPresetBody =>
      'Текущие скины, брелоки, колесо выражений, карточка и звание будут заменены этим комплектом.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Применить «$name»?';
  }

  @override
  String get collectionBrowseBuddies => 'Брелоки';

  @override
  String get collectionBrowseCards => 'Карточки игрока';

  @override
  String get collectionBrowseEmpty =>
      'В этом разделе у вас пока нет предметов.';

  @override
  String get collectionBrowseEmptyTitle => 'Предметов пока нет';

  @override
  String get collectionBrowseFlex => 'Флекс';

  @override
  String get collectionBrowseSkins => 'Скины';

  @override
  String get collectionBrowseSprays => 'Граффити';

  @override
  String get collectionBrowseTitles => 'Звания';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Осталось $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Для: $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Выберите брелок';

  @override
  String get collectionBuddyRemoved => 'Брелок снят';

  @override
  String get collectionBuddySlot => 'Брелок';

  @override
  String get collectionBuddyUnavailable =>
      'Не удалось повесить этот брелок. Обновите данные или выберите другой.';

  @override
  String get collectionCachedLoadout =>
      'Показано сохраненное снаряжение. Потяните, чтобы обновить, прежде чем что-то менять.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString карточки в коллекции',
      many: '$nString карточек в коллекции',
      few: '$nString карточки в коллекции',
      one: '$nString карточка в коллекции',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Сменить';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'Варианты: $owned/$total';
  }

  @override
  String get collectionClearTiers => 'Сбросить фильтр изданий';

  @override
  String get collectionCollectionValue => 'Стоимость коллекции';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Стандарт';

  @override
  String get collectionDeletePreset => 'Удалить';

  @override
  String get collectionEmptySlot => 'Пусто';

  @override
  String get collectionEquip => 'Экипировать';

  @override
  String get collectionEquipped => 'Экипировано';

  @override
  String get collectionEquippedCard => 'Текущая карточка';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Текущая карточка: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Экипировано: $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Экипировано: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Без учета скинов-наград';

  @override
  String get collectionExpressionsHint =>
      'Нажмите на слот, чтобы выбрать граффити или флекс.';

  @override
  String get collectionExpressionsSlots => 'Слоты колеса';

  @override
  String get collectionExpressionsTitle => 'Колесо выражений';

  @override
  String get collectionHideAccountLevel => 'Скрыть уровень аккаунта';

  @override
  String get collectionHideAccountLevelHint =>
      'Другие игроки не увидят уровень вашего аккаунта.';

  @override
  String get collectionIncognito => 'Режим инкогнито';

  @override
  String get collectionIncognitoHint =>
      'Скрывать ваше имя в матчах от игроков не из вашей группы.';

  @override
  String get collectionLevelBorderAuto => 'Авто по уровню';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'С уровня $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Уровень аккаунта: $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Выберите рамку уровня';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Уровень $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Уровень $n · $type';
  }

  @override
  String get collectionLevels => 'Уровни';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Открыто уровней: $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'Баннер в лобби';

  @override
  String get collectionLocked => 'Закрыто';

  @override
  String get collectionMeleeNoBuddy =>
      'На оружие ближнего боя нельзя повесить брелок.';

  @override
  String get collectionMove => 'Перенести';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy сейчас висит на оружии $from. Перенести на $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Перенести брелок?';

  @override
  String get collectionNoBuddies => 'У вас пока нет брелоков.';

  @override
  String get collectionNoBuddy => 'Без брелока';

  @override
  String get collectionNoFlex => 'У вас пока нет предметов флекс.';

  @override
  String get collectionNoResults => 'Ничего не найдено.';

  @override
  String get collectionNoResultsTitle => 'Ничего не найдено';

  @override
  String get collectionNoSkinsForWeapon =>
      'У вас пока нет скинов для этого оружия.';

  @override
  String get collectionNoSprays => 'У вас пока нет граффити.';

  @override
  String get collectionNoTitle => 'Без звания';

  @override
  String get collectionOtherWeapons => 'Другое';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n скина в коллекции',
      many: '$n скинов в коллекции',
      few: '$n скина в коллекции',
      one: '$n скин в коллекции',
      zero: 'Скинов пока нет',
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
      other: '$nString скина в коллекции',
      many: '$nString скинов в коллекции',
      few: '$nString скина в коллекции',
      one: '$nString скин в коллекции',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Видео этого уровня';

  @override
  String get collectionPlayVideo => 'Смотреть видео';

  @override
  String get collectionPlayerCardSubtitle =>
      'Отображается в лобби, в таблице счета и когда вы убиваете противника.';

  @override
  String get collectionPlayerCardTitle => 'Сменить карточку игрока';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Отображается под вашим именем в лобби и в матчах.';

  @override
  String get collectionPlayerTitleTitle => 'Сменить звание';

  @override
  String get collectionPresetActions => 'Действия';

  @override
  String collectionPresetApplied(String name) {
    return 'Применено: «$name»';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n комплекта',
      many: '$n комплектов',
      few: '$n комплекта',
      one: '$n комплект',
      zero: 'Пока нет',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'Удалено: «$name»';
  }

  @override
  String get collectionPresetNameHint => 'Например: Подъем ранга';

  @override
  String get collectionPresetNameTitle => 'Название комплекта';

  @override
  String collectionPresetSaved(String name) {
    return 'Сохранено: «$name»';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Сохранено $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Пропущено $n предмета, которых у вас больше нет.',
      many: 'Пропущено $n предметов, которых у вас больше нет.',
      few: 'Пропущено $n предмета, которых у вас больше нет.',
      one: 'Пропущен $n предмет, которого у вас больше нет.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Сохраните текущее снаряжение, чтобы потом быстро переключаться между наборами скинов, карточек и колес выражений.';

  @override
  String get collectionPresetsEmptyTitle => 'Сохраненных комплектов пока нет';

  @override
  String get collectionPresetsFull =>
      'Достигнут предел в 50 комплектов. Удалите лишние, чтобы сохранить новые.';

  @override
  String get collectionPresetsNote =>
      'Комплекты хранятся только на этом устройстве и только для выбранного аккаунта.';

  @override
  String get collectionPresetsTitle => 'Сохраненные комплекты';

  @override
  String get collectionPreview => 'Просмотр';

  @override
  String get collectionRemoveBuddy => 'Снять брелок';

  @override
  String get collectionRenamePreset => 'Переименовать';

  @override
  String get collectionRowExpressions => 'Колесо выражений';

  @override
  String get collectionRowLevelBorder => 'Рамка уровня';

  @override
  String get collectionRowPresets => 'Сохраненные комплекты';

  @override
  String get collectionRowWeapons => 'Снаряжение оружия';

  @override
  String get collectionRowWishlist => 'Список желаемого';

  @override
  String get collectionSaveFailed => 'Не удалось сохранить снаряжение';

  @override
  String get collectionSavePreset => 'Сохранить текущее снаряжение';

  @override
  String get collectionSaving => 'Сохранение…';

  @override
  String get collectionSearchBuddies => 'Поиск брелоков…';

  @override
  String get collectionSearchCards => 'Поиск карточек игрока…';

  @override
  String get collectionSearchFlex => 'Поиск флекс…';

  @override
  String get collectionSearchItems => 'Поиск…';

  @override
  String get collectionSearchSkins => 'Поиск скинов…';

  @override
  String get collectionSearchSprays => 'Поиск граффити…';

  @override
  String get collectionSearchTitles => 'Поиск званий…';

  @override
  String get collectionSearchWeapons => 'Поиск оружия, скинов или брелоков…';

  @override
  String get collectionSectionBrowse => 'Просмотр коллекции';

  @override
  String get collectionSectionIdentity => 'Видно другим игрокам';

  @override
  String get collectionSectionLoadout => 'Снаряжение';

  @override
  String get collectionSkinCustomizeTitle => 'Настройка скина';

  @override
  String get collectionSkinNotFound => 'Не удалось найти этот скин.';

  @override
  String get collectionSkinNotOwned => 'У вас пока нет этого скина.';

  @override
  String get collectionSlotNamesItem0 => 'Верх';

  @override
  String get collectionSlotNamesItem1 => 'Право';

  @override
  String get collectionSlotNamesItem2 => 'Низ';

  @override
  String get collectionSlotNamesItem3 => 'Лево';

  @override
  String get collectionSortName => 'Название';

  @override
  String get collectionSortPrice => 'Цена';

  @override
  String get collectionSortRarity => 'Редкость';

  @override
  String get collectionSortWeapon => 'Оружие';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count скина',
      many: '$count скинов',
      few: '$count скина',
      one: '$count скин',
    );
    return 'Фильтр: $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Фильтр: $count/$total';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предмета',
      many: '$count предметов',
      few: '$count предмета',
      one: '$count предмет',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count скина',
      many: '$count скинов',
      few: '$count скина',
      one: '$count скин',
    );
    return '$_temp0 · $value';
  }

  @override
  String get collectionTabFlex => 'Флекс';

  @override
  String get collectionTabSprays => 'Граффити';

  @override
  String get collectionTapToChangeCard => 'Нажмите, чтобы сменить карточку';

  @override
  String get collectionTitle => 'Коллекция';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString звания в коллекции',
      many: '$nString званий в коллекции',
      few: '$nString звания в коллекции',
      one: '$nString звание в коллекции',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Отменить';

  @override
  String get collectionUnknownCard => 'Неизвестная карточка';

  @override
  String get collectionValueAtStorePrices => 'По ценам магазина';

  @override
  String get collectionValueHasEstimates => 'Включает примерные цены (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Не учтено $n скина-награды',
      many: 'Не учтено $n скинов-наград',
      few: 'Не учтено $n скина-награды',
      one: 'Не учтен $n скин-награда',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Смотреть скины';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Учтено $n скина',
      many: 'Учтено $n скинов',
      few: 'Учтено $n скина',
      one: 'Учтен $n скин',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Варианты';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'Оружие со скинами: $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Снаряжение оружия';

  @override
  String get collectionWeaponNotFound => 'Не удалось найти это оружие.';

  @override
  String get collectionWeaponSkinsTitle => 'Выберите скин';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n скина',
      many: '$n скинов',
      few: '$n скина',
      one: '$n скин',
      zero: 'Пусто',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Не удалось опубликовать: в тексте есть недопустимые выражения. Исправьте текст и повторите попытку.';

  @override
  String get communityModerationContentScam =>
      'В сообществе запрещена реклама продажи аккаунтов, услуг бустинга и номера телефонов. Уберите это из текста и повторите попытку.';

  @override
  String get communityModerationContentTooComplex =>
      'В тексте слишком много разрозненных символов. Напишите проще и повторите попытку.';

  @override
  String get communityModerationAccountBanned =>
      'Этому аккаунту закрыт доступ к сообществу. Если вы считаете, что это ошибка, свяжитесь с ValHub в разделе «О приложении и правовая информация».';

  @override
  String get communityModerationAccountRestricted =>
      'Этому аккаунту временно запрещено публиковать посты, комментировать, искать напарников и голосовать. Повторите попытку позже или свяжитесь с ValHub в разделе «О приложении и правовая информация».';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Рейтинговая',
      'unrated': 'Без ранга',
      'swiftplay': 'Быстрая игра',
      'spikerush': 'Быстр. установка Spike',
      'deathmatch': 'Бой насмерть',
      'teamdeathmatch': 'Командный бой насмерть',
      'premier': 'Premier',
      'custom': 'Своя игра',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Азиатско-Тихоокеанский регион',
      'na': 'Северная Америка',
      'eu': 'Европа',
      'kr': 'Корея',
      'latam': 'Латинская Америка',
      'br': 'Бразилия',
      'other': 'Регион неизвестен',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'В этом рейтинге пока нет скинов';

  @override
  String get communityRankingEmptyVotes =>
      'Пока нет отметок «Нравится» для выбранной области и фильтров.';

  @override
  String get communityRankingEmptyRatings =>
      'Пока нет оценок в звездах для выбранной области и фильтров.';

  @override
  String get communityRankingEmptyReviews =>
      'Пока нет отзывов для выбранной области и фильтров.';

  @override
  String get communityRankingExplore =>
      'Найти скины, чтобы посмотреть и оценить';

  @override
  String get communityRankingExploreHint =>
      'Ищите по названию скина или оружия. В рейтинге появляются только реальные оценки сообщества.';

  @override
  String get communityRankingClear => 'Сбросить фильтры оружия и времени';

  @override
  String get communityRankingSort => 'Рейтинг по';

  @override
  String get communityRankingWeapon => 'Оружие';

  @override
  String get communityRankingNoSearch =>
      'Подходящих скинов нет. Попробуйте другое название или сбросьте фильтр оружия.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Не удалось загрузить список скинов. Закройте панель и повторите попытку после синхронизации данных.';

  @override
  String get communityConsentExitAccount =>
      'Отказаться · Выйти из этого аккаунта';

  @override
  String get communityRankingGlobalAllTime => 'Весь мир · За все время';

  @override
  String get communityRankingCatalogTitle => 'Все скины';

  @override
  String get communityReviewOwnershipRequired =>
      'Чтобы оценить этот скин, он должен быть в вашем аккаунте. Читать оценки и комментарии сообщества можно и без него.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Не удалось подтвердить, что скин ваш. Обновите коллекцию или повторите попытку, когда будете в сети.';

  @override
  String get communityReviewLegacyOwnership =>
      'Старый отзыв · Владение не подтверждено';

  @override
  String get communityReviewVerifiedOwner =>
      'Владение подтверждено на момент отзыва';

  @override
  String get communitySkinDiscussionHint =>
      'Комментировать может любой. Ставить звезды и писать отзывы могут только владельцы скина.';

  @override
  String get communityAddPhotos => 'Добавить фото';

  @override
  String get communityAllModes => 'Все';

  @override
  String get communityAllWeapons => 'Все оружие';

  @override
  String get communityAnonymousBanner => 'Анонимный просмотр';

  @override
  String get communityAnyLanguage => 'Любой язык';

  @override
  String get communityAnyRank => 'Любой ранг';

  @override
  String get communityAnyRole => 'Любая роль';

  @override
  String get communityApply => 'Применить';

  @override
  String get communityBackToMyCountry => 'К моей стране';

  @override
  String get communityBlockAuthor => 'Заблокировать на устройстве';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Сбросить';

  @override
  String get communityCodeAuto =>
      'Оставьте пустым: ValHub создаст код из вашей группы в игре при публикации.';

  @override
  String get communityCodeAutoFailed =>
      'Не удалось создать код группы. Откройте VALORANT или введите код вручную.';

  @override
  String get communityCodeInvalid =>
      'Код должен состоять ровно из 6 заглавных латинских букв или цифр.';

  @override
  String get communityCodeRequired => 'Введите или создайте код группы.';

  @override
  String get communityCommentHint => 'Напишите комментарий…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString комментария',
      many: '$nString комментариев',
      few: '$nString комментария',
      one: '$nString комментарий',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Комментарии · $n';
  }

  @override
  String get communityCommentsTitle => 'Комментарии';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Посты: $posts · Игроки: $authors';
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
      other: '$nString объявления о поиске напарников',
      many: '$nString объявлений о поиске напарников',
      few: '$nString объявления о поиске напарников',
      one: '$nString объявление о поиске напарников',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Любимое сообщества';

  @override
  String get communityComposerHint => 'Что вы думаете о VALORANT сегодня?';

  @override
  String get communityComposerTitle => 'Новый пост';

  @override
  String communityConsentAccount(String riotId) {
    return 'Аккаунт: $riotId';
  }

  @override
  String get communityConsentAgree => 'Принять и продолжить';

  @override
  String get communityConsentGateAction => 'Присоединиться';

  @override
  String get communityConsentGuidelines => 'Правила сообщества';

  @override
  String get communityConsentLater => 'Позже';

  @override
  String get communityConsentLocal =>
      'Ваш пароль и другие данные для входа всегда остаются на этом устройстве. Отозвать согласие можно в настройках.';

  @override
  String get communityConsentPrivacy => 'Политика конфиденциальности';

  @override
  String get communityConsentPublic =>
      'Другие игроки увидят ваш Riot ID, карточку игрока, ранг и страну.';

  @override
  String get communityConsentTitle => 'Конфиденциальность и сообщество ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub передает ваш доступ Riot серверу сообщества, чтобы подтвердить Riot ID при подключении и проверить владение скином, когда вы сохраняете отзыв. Сервер читает только нужные данные, сразу удаляет доступ после использования и не хранит его.';

  @override
  String get communityConsentWithdrawn =>
      'Согласие отозвано. Чтобы продолжить пользоваться приложением, нужно снова дать согласие.';

  @override
  String get communityCountriesTitle => 'Сообщества по странам';

  @override
  String get communityCountryNamesAE => 'ОАЭ';

  @override
  String get communityCountryNamesAL => 'Албания';

  @override
  String get communityCountryNamesAM => 'Армения';

  @override
  String get communityCountryNamesAR => 'Аргентина';

  @override
  String get communityCountryNamesAT => 'Австрия';

  @override
  String get communityCountryNamesAU => 'Австралия';

  @override
  String get communityCountryNamesAZ => 'Азербайджан';

  @override
  String get communityCountryNamesBA => 'Босния и Герцеговина';

  @override
  String get communityCountryNamesBD => 'Бангладеш';

  @override
  String get communityCountryNamesBE => 'Бельгия';

  @override
  String get communityCountryNamesBG => 'Болгария';

  @override
  String get communityCountryNamesBH => 'Бахрейн';

  @override
  String get communityCountryNamesBN => 'Бруней';

  @override
  String get communityCountryNamesBO => 'Боливия';

  @override
  String get communityCountryNamesBR => 'Бразилия';

  @override
  String get communityCountryNamesBY => 'Беларусь';

  @override
  String get communityCountryNamesCA => 'Канада';

  @override
  String get communityCountryNamesCH => 'Швейцария';

  @override
  String get communityCountryNamesCL => 'Чили';

  @override
  String get communityCountryNamesCN => 'Китай';

  @override
  String get communityCountryNamesCO => 'Колумбия';

  @override
  String get communityCountryNamesCR => 'Коста-Рика';

  @override
  String get communityCountryNamesCU => 'Куба';

  @override
  String get communityCountryNamesCY => 'Кипр';

  @override
  String get communityCountryNamesCZ => 'Чехия';

  @override
  String get communityCountryNamesDE => 'Германия';

  @override
  String get communityCountryNamesDK => 'Дания';

  @override
  String get communityCountryNamesDO => 'Доминиканская Республика';

  @override
  String get communityCountryNamesDZ => 'Алжир';

  @override
  String get communityCountryNamesEC => 'Эквадор';

  @override
  String get communityCountryNamesEE => 'Эстония';

  @override
  String get communityCountryNamesEG => 'Египет';

  @override
  String get communityCountryNamesES => 'Испания';

  @override
  String get communityCountryNamesET => 'Эфиопия';

  @override
  String get communityCountryNamesFI => 'Финляндия';

  @override
  String get communityCountryNamesFR => 'Франция';

  @override
  String get communityCountryNamesGB => 'Великобритания';

  @override
  String get communityCountryNamesGE => 'Грузия';

  @override
  String get communityCountryNamesGH => 'Гана';

  @override
  String get communityCountryNamesGR => 'Греция';

  @override
  String get communityCountryNamesGT => 'Гватемала';

  @override
  String get communityCountryNamesHK => 'Гонконг';

  @override
  String get communityCountryNamesHN => 'Гондурас';

  @override
  String get communityCountryNamesHR => 'Хорватия';

  @override
  String get communityCountryNamesHU => 'Венгрия';

  @override
  String get communityCountryNamesID => 'Индонезия';

  @override
  String get communityCountryNamesIE => 'Ирландия';

  @override
  String get communityCountryNamesIL => 'Израиль';

  @override
  String get communityCountryNamesIN => 'Индия';

  @override
  String get communityCountryNamesIQ => 'Ирак';

  @override
  String get communityCountryNamesIR => 'Иран';

  @override
  String get communityCountryNamesIS => 'Исландия';

  @override
  String get communityCountryNamesIT => 'Италия';

  @override
  String get communityCountryNamesJO => 'Иордания';

  @override
  String get communityCountryNamesJP => 'Япония';

  @override
  String get communityCountryNamesKE => 'Кения';

  @override
  String get communityCountryNamesKH => 'Камбоджа';

  @override
  String get communityCountryNamesKR => 'Южная Корея';

  @override
  String get communityCountryNamesKW => 'Кувейт';

  @override
  String get communityCountryNamesKZ => 'Казахстан';

  @override
  String get communityCountryNamesLA => 'Лаос';

  @override
  String get communityCountryNamesLB => 'Ливан';

  @override
  String get communityCountryNamesLK => 'Шри-Ланка';

  @override
  String get communityCountryNamesLT => 'Литва';

  @override
  String get communityCountryNamesLU => 'Люксембург';

  @override
  String get communityCountryNamesLV => 'Латвия';

  @override
  String get communityCountryNamesLY => 'Ливия';

  @override
  String get communityCountryNamesMA => 'Марокко';

  @override
  String get communityCountryNamesMD => 'Молдова';

  @override
  String get communityCountryNamesME => 'Черногория';

  @override
  String get communityCountryNamesMK => 'Северная Македония';

  @override
  String get communityCountryNamesMM => 'Мьянма';

  @override
  String get communityCountryNamesMN => 'Монголия';

  @override
  String get communityCountryNamesMO => 'Макао';

  @override
  String get communityCountryNamesMT => 'Мальта';

  @override
  String get communityCountryNamesMX => 'Мексика';

  @override
  String get communityCountryNamesMY => 'Малайзия';

  @override
  String get communityCountryNamesNG => 'Нигерия';

  @override
  String get communityCountryNamesNI => 'Никарагуа';

  @override
  String get communityCountryNamesNL => 'Нидерланды';

  @override
  String get communityCountryNamesNO => 'Норвегия';

  @override
  String get communityCountryNamesNP => 'Непал';

  @override
  String get communityCountryNamesNZ => 'Новая Зеландия';

  @override
  String get communityCountryNamesOM => 'Оман';

  @override
  String get communityCountryNamesPA => 'Панама';

  @override
  String get communityCountryNamesPE => 'Перу';

  @override
  String get communityCountryNamesPH => 'Филиппины';

  @override
  String get communityCountryNamesPK => 'Пакистан';

  @override
  String get communityCountryNamesPL => 'Польша';

  @override
  String get communityCountryNamesPR => 'Пуэрто-Рико';

  @override
  String get communityCountryNamesPT => 'Португалия';

  @override
  String get communityCountryNamesPY => 'Парагвай';

  @override
  String get communityCountryNamesQA => 'Катар';

  @override
  String get communityCountryNamesRO => 'Румыния';

  @override
  String get communityCountryNamesRS => 'Сербия';

  @override
  String get communityCountryNamesRU => 'Россия';

  @override
  String get communityCountryNamesSA => 'Саудовская Аравия';

  @override
  String get communityCountryNamesSE => 'Швеция';

  @override
  String get communityCountryNamesSG => 'Сингапур';

  @override
  String get communityCountryNamesSI => 'Словения';

  @override
  String get communityCountryNamesSK => 'Словакия';

  @override
  String get communityCountryNamesSV => 'Сальвадор';

  @override
  String get communityCountryNamesTH => 'Таиланд';

  @override
  String get communityCountryNamesTL => 'Восточный Тимор';

  @override
  String get communityCountryNamesTN => 'Тунис';

  @override
  String get communityCountryNamesTR => 'Турция';

  @override
  String get communityCountryNamesTW => 'Тайвань';

  @override
  String get communityCountryNamesUA => 'Украина';

  @override
  String get communityCountryNamesUS => 'США';

  @override
  String get communityCountryNamesUY => 'Уругвай';

  @override
  String get communityCountryNamesUZ => 'Узбекистан';

  @override
  String get communityCountryNamesVE => 'Венесуэла';

  @override
  String get communityCountryNamesVN => 'Вьетнам';

  @override
  String get communityCountryNamesZA => 'ЮАР';

  @override
  String get communityCreateLfg => 'Создать объявление';

  @override
  String get communityCreateLfgShort => 'Создать';

  @override
  String get communityDataDeleted => 'Ваши данные сообщества удалены.';

  @override
  String communityDataFooter(String riotId) {
    return 'Относится к текущему аккаунту: $riotId. Загружаемый файл не содержит пароль и данные для входа Riot.';
  }

  @override
  String get communityDataTitle => 'Ваши данные сообщества';

  @override
  String get communityDecrease => 'Уменьшить';

  @override
  String get communityDelete => 'Удалить';

  @override
  String get communityDeleteComment => 'Удалить комментарий';

  @override
  String get communityDeleteCommentBody =>
      'Этот комментарий будет удален навсегда.';

  @override
  String get communityDeleteCommentTitle => 'Удалить комментарий?';

  @override
  String get communityDeleteDataConfirm => 'Удалить навсегда';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Все посты, комментарии, отзывы о скинах, лайки, голоса, объявления о поиске напарников и фото $riotId в сообществе ValHub будут удалены навсегда без возможности восстановления. Вы вернетесь к анонимному просмотру, а чтобы снова присоединиться, нужно будет заново дать согласие.\n\nАккаунт Riot и игровые данные не затрагиваются. Если хотите сохранить копию, сначала загрузите свои данные.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Удалить данные сообщества?';

  @override
  String get communityDeleteDataSubtitle =>
      'Навсегда удалить все, что вы публиковали в сообществе.';

  @override
  String get communityDeleteDataTitle => 'Удалить мои данные сообщества';

  @override
  String get communityDeletePost => 'Удалить пост';

  @override
  String get communityDeletePostBody =>
      'Пост и все комментарии к нему будут удалены навсегда.';

  @override
  String get communityDeletePostTitle => 'Удалить пост?';

  @override
  String get communityDeleteReview => 'Удалить отзыв';

  @override
  String get communityDeleteReviewBody =>
      'Ваша оценка и отзыв об этом скине будут удалены.';

  @override
  String get communityDeleteReviewTitle => 'Удалить ваш отзыв?';

  @override
  String get communityDeleted => 'Удалено.';

  @override
  String get communityDiscard => 'Удалить';

  @override
  String get communityDiscardBody => 'Написанный текст не сохранится.';

  @override
  String get communityDiscardTitle => 'Отменить пост?';

  @override
  String get communityDownload => 'Загрузить и перевести';

  @override
  String get communityDownloadingModels => 'Загрузка языкового пакета…';

  @override
  String get communityEditReview => 'Изменить';

  @override
  String get communityEdited => 'изменено';

  @override
  String get communityEmptyPost => 'Напишите что-нибудь или добавьте фото.';

  @override
  String get communityExpired => 'Истекло';

  @override
  String communityExpiresIn(String t) {
    return 'Осталось: $t';
  }

  @override
  String get communityExportPreparing => 'Подготовка…';

  @override
  String get communityExportSubject => 'Данные сообщества ValHub';

  @override
  String get communityExportSubtitle =>
      'Копия всего, что вы публиковали в сообществе: посты, комментарии, отзывы, лайки, голоса и объявления о поиске напарников.';

  @override
  String get communityExportTitle => 'Загрузить мои данные';

  @override
  String get communityExtend => 'Продлить';

  @override
  String get communityExtended => 'Объявление продлено на 30 минут.';

  @override
  String get communityFeedEmptyBody =>
      'Станьте первым, кто поделится своим магазином, Ночным рынком или лучшими моментами!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Подходящих постов нет. Выберите другой язык или сбросьте фильтры.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Новых постов пока нет. Загляните позже или присоединяйтесь, чтобы делиться.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Посмотрите посты международного сообщества или измените фильтры.';

  @override
  String get communityFeedEmptyScopeTitle => 'Здесь пока нет постов';

  @override
  String get communityFeedEmptyTitle => 'Лента пуста';

  @override
  String get communityFilters => 'Фильтры';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Переведено Google';

  @override
  String get communityHelpful => 'Полезно';

  @override
  String communityHelpfulCount(String n) {
    return 'Полезно · $n';
  }

  @override
  String get communityHiddenAuthors => 'Скрытые и заблокированные игроки';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Вы никого не скрыли и не заблокировали';

  @override
  String get communityHiddenAuthorsHint =>
      'Действует только для этого аккаунта на этом устройстве. Их контент скрыт; они по-прежнему видят ваш публичный контент.';

  @override
  String communityImageOf(int i, int n) {
    return 'Фото $i/$n';
  }

  @override
  String get communityIncrease => 'Увеличить';

  @override
  String get communityJoin => 'Вступить';

  @override
  String get communityJoinCodeExpired =>
      'Код группы истек или больше не действует.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Вы покинете текущую группу в VALORANT и вступите в группу игрока $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Вступить в эту группу?';

  @override
  String get communityJoinGameNotRunning =>
      'Запустите VALORANT на ПК или консоли и повторите попытку.';

  @override
  String get communityJoinParty => 'Вступить в группу';

  @override
  String get communityJoinPartyFull => 'Эта группа уже заполнена.';

  @override
  String get communityJoinedHint =>
      'Вы в группе! Откройте VALORANT, чтобы играть вместе.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString запроса на вступление',
      many: '$nString запросов на вступление',
      few: '$nString запроса на вступление',
      one: '$nString запрос на вступление',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Ночной рынок';

  @override
  String get communityKindStore => 'Магазин сегодня';

  @override
  String get communityLanguage => 'Язык';

  @override
  String get communityLanguageFilter => 'Язык контента';

  @override
  String get communityLanguageFilterHint =>
      'Показывать только контент на выбранных языках. Оставьте пустым, чтобы видеть все.';

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
      other: '$n языка',
      many: '$n языков',
      few: '$n языка',
      one: '$n язык',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Создайте объявление, чтобы другие игроки могли вступить в вашу группу одним нажатием.';

  @override
  String get communityLfgEmptyTitle => 'Пока никто не ищет напарников';

  @override
  String get communityLfgExpiredRepost =>
      'Срок вашего объявления истек. Создайте новое, чтобы найти напарников.';

  @override
  String get communityLfgGateBody =>
      'Присоединяйтесь (один раз подтвердите Riot ID), чтобы видеть объявления игроков с вашего сервера и размещать свои. Ленту и рейтинг скинов можно смотреть как обычно.';

  @override
  String get communityLfgGateTitle =>
      'Поиск напарников — только для участников';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Вы просматриваете сервер $region — вступать в группы могут только игроки с того же сервера, что и ваш аккаунт.';
  }

  @override
  String get communityLfgPosted =>
      'Объявление о поиске напарников опубликовано!';

  @override
  String get communityLfgPreviewTitle => 'Ищите напарников своего ранга';

  @override
  String get communityLfgRemoved => 'Объявление снято.';

  @override
  String get communityLfgSameShardNote =>
      'Вступать в группу могут только игроки с того же сервера.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Регион: $region · Объявления автоматически истекают через 30 минут.';
  }

  @override
  String get communityLike => 'Нравится';

  @override
  String get communityLiveMembers => 'Участники';

  @override
  String get communityMatchMyRank => 'Подходит под ваш ранг';

  @override
  String communityMemberJoined(String name) {
    return 'Новый участник группы: $name';
  }

  @override
  String get communityMemberJoinedBody =>
      'Кто-то только что вступил в группу по вашему объявлению.';

  @override
  String get communityMic => 'Нужен микрофон';

  @override
  String get communityMicOn => 'Есть микрофон';

  @override
  String get communityMode => 'Режим';

  @override
  String communityModelSize(int mb) {
    return '$mb МБ';
  }

  @override
  String get communityMoreActions => 'Другие действия';

  @override
  String get communityMuteAuthor => 'Скрыть этого игрока';

  @override
  String get communityNewPost => 'Опубликовать';

  @override
  String communityNightMarketOf(String date) {
    return 'Ночной рынок $date';
  }

  @override
  String get communityNoAccountBody =>
      'Добавьте аккаунт Riot, чтобы публиковать посты, искать напарников и голосовать за скины.';

  @override
  String get communityNoAccountTitle => 'Войдите, чтобы присоединиться';

  @override
  String get communityNoComments => 'Комментариев пока нет. Будьте первым!';

  @override
  String get communityNoRatings => 'Оценок пока нет';

  @override
  String get communityNote => 'Примечание';

  @override
  String get communityNoteHint =>
      'Например: нужен 1 специалист, есть микрофон, играем для удовольствия';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Всего: $amount';
  }

  @override
  String get communityOpenReviews => 'Смотреть отзывы';

  @override
  String get communityOutOfRange => 'Вне диапазона рангов';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Код группы';

  @override
  String get communityPartyCodeHint => 'Например: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Код группы: $code';
  }

  @override
  String get communityPartySize => 'Сейчас в группе';

  @override
  String get communityPartySizeFromGame => 'Из вашей группы в игре';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n игрока',
      many: '$n игроков',
      few: '$n игрока',
      one: '$n игрок',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return 'Фото: $n/$max';
  }

  @override
  String get communityPlayVideo => 'Смотреть видео';

  @override
  String get communityPostLfg => 'Опубликовать';

  @override
  String get communityPostNotFound => 'Этот пост удален или скрыт.';

  @override
  String get communityPostTitle => 'Пост';

  @override
  String get communityPosted => 'Опубликовано!';

  @override
  String get communityPublish => 'Опубликовать';

  @override
  String get communityPublishing => 'Публикация…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'От';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Диапазон рангов';

  @override
  String get communityRankRangeInvalid =>
      'Минимальный ранг не может быть выше максимального.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Место $n: $name';
  }

  @override
  String get communityRankTo => 'До';

  @override
  String get communityRateLimitedTitle => 'Подождите немного';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString оценки',
      many: '$nString оценок',
      few: '$nString оценки',
      one: '$nString оценка',
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
      other: '$nString оценки',
      many: '$nString оценок',
      few: '$nString оценки',
      one: '$nString оценка',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Плохо';

  @override
  String get communityRatingWordsItem1 => 'Так себе';

  @override
  String get communityRatingWordsItem2 => 'Нормально';

  @override
  String get communityRatingWordsItem3 => 'Отлично';

  @override
  String get communityRatingWordsItem4 => 'Шедевр';

  @override
  String get communityRefreshList => 'Обновить';

  @override
  String get communityRegion => 'Регион';

  @override
  String get communityRemoveAttachment => 'Удалить вложение';

  @override
  String get communityRemoveLfg => 'Снять объявление';

  @override
  String get communityRemoveLfgBody =>
      'Другие игроки больше не увидят это объявление.';

  @override
  String get communityRemoveLfgTitle => 'Снять объявление о поиске напарников?';

  @override
  String get communityRemovePhoto => 'Удалить фото';

  @override
  String get communityReport => 'Пожаловаться';

  @override
  String get communityReportConfirmBody =>
      'Контент, на который пожаловались многие игроки, будет скрыт из сообщества.';

  @override
  String get communityReportConfirmTitle => 'Отправить жалобу?';

  @override
  String get communityReportPrompt => 'Почему вы жалуетесь на этот контент?';

  @override
  String get communityReportReasonsSpam => 'Спам или реклама';

  @override
  String get communityReportReasonsHarassment => 'Травля или оскорбления';

  @override
  String get communityReportReasonsInappropriate => 'Недопустимый контент';

  @override
  String get communityReportReasonsScam =>
      'Мошенничество или продажа аккаунтов';

  @override
  String get communityReportReasonsOther => 'Другая причина';

  @override
  String get communityReportTitle => 'Жалоба на контент';

  @override
  String get communityReported => 'Спасибо! Жалоба отправлена.';

  @override
  String get communityReviewDeleted => 'Отзыв удален.';

  @override
  String get communityReviewHint =>
      'Поделитесь мнением об этом скине (необязательно)';

  @override
  String get communityReviewSaved => 'Отзыв сохранен!';

  @override
  String get communityReviewTitle => 'Оценить скин';

  @override
  String get communityReviewsEmptyBody => 'Отзывов пока нет — будьте первым!';

  @override
  String get communityReviewsEmptyTitle => 'Отзывов пока нет';

  @override
  String communityReviewsHeader(String n) {
    return 'Отзывы · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'У Riot неполадки';

  @override
  String get communityRoleFlex => 'Любая';

  @override
  String get communityRoles => 'Нужные роли';

  @override
  String get communitySaveReview => 'Сохранить отзыв';

  @override
  String get communityScopeCountry => 'Ваша страна';

  @override
  String get communityScopeGlobal => 'Международное';

  @override
  String get communityScopeRegion => 'Регион';

  @override
  String get communitySectionFeed => 'Лента';

  @override
  String get communitySectionLfg => 'Напарники';

  @override
  String get communitySectionSkins => 'Рейтинг скинов';

  @override
  String get communitySend => 'Отправить';

  @override
  String get communitySendComment => 'Отправить комментарий';

  @override
  String get communityShareNightMarketHint =>
      'Похвастайтесь своим Ночным рынком';

  @override
  String communitySharePostTitle(String name) {
    return 'Пост игрока $name в ValHub';
  }

  @override
  String get communityShareStore => 'Поделиться в сообществе';

  @override
  String get communityShareStoreHint => 'Похвастайтесь сегодняшним магазином';

  @override
  String get communityShowOriginal => 'Показать оригинал';

  @override
  String get communityShowTranslation => 'Показать перевод';

  @override
  String get communitySignInToReview =>
      'Добавьте аккаунт Riot, чтобы оценивать скины.';

  @override
  String get communitySkinNotFound => 'Не удалось найти этот скин.';

  @override
  String get communitySlots => 'Нужно игроков';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'В группе максимум 5 игроков: осталось только $max места.',
      many: 'В группе максимум 5 игроков: осталось только $max мест.',
      few: 'В группе максимум 5 игроков: осталось только $max места.',
      one: 'В группе максимум 5 игроков: осталось только $max место.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Нужно $n игрока',
      many: 'Нужно $n игроков',
      few: 'Нужно $n игрока',
      one: 'Нужен $n игрок',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Самые полезные';

  @override
  String get communitySortNewest => 'Сначала новые';

  @override
  String get communitySortRating => 'Высшая оценка';

  @override
  String get communitySortReviews => 'Больше всего отзывов';

  @override
  String get communitySortVotes => 'Самые любимые';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n звезды',
      many: '$n звезд',
      few: '$n звезды',
      one: '$n звезда',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg из 5 звезд';
  }

  @override
  String get communityStatusFull => 'Заполнена';

  @override
  String get communityStatusInGame => 'В матче';

  @override
  String get communityStatusOpen => 'Ищут';

  @override
  String communityStoreOf(String date) {
    return 'Магазин $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Нажмите на звезды, чтобы оценить этот скин';

  @override
  String get communityTitle => 'Сообщество';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Не больше $max символа.',
      many: 'Не больше $max символов.',
      few: 'Не больше $max символов.',
      one: 'Не больше $max символа.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Перевести с Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Чтобы переводить с языка «$from» на язык «$to», ValHub нужно загрузить языковой пакет Google (около $size). Загрузка нужна один раз; перевод выполняется полностью на вашем устройстве и никуда не отправляется.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Загрузить языковой пакет на устройство?';

  @override
  String get communityTranslateFailed =>
      'Не удалось перевести. Повторите попытку.';

  @override
  String get communityTranslatedByGoogle => 'Автоматический перевод Google';

  @override
  String get communityTranslating => 'Перевод…';

  @override
  String get communityTrendingTitle => 'Самые любимые скины в мире';

  @override
  String get communityUnavailableBody =>
      'Не удалось подключиться к сообществу ValHub. Повторите попытку через несколько минут.';

  @override
  String get communityUnavailableTitle =>
      'Не удалось подключиться к сообществу';

  @override
  String get communityUnhideAuthor => 'Показать / разблокировать';

  @override
  String get communityUnknownPlayer => 'Игрок';

  @override
  String get communityUnlike => 'Убрать лайк';

  @override
  String get communityUnvote => 'Убрать сердечко';

  @override
  String get communityVote => 'Поставить сердечко скину';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString лайка',
      many: '$nString лайков',
      few: '$nString лайка',
      one: '$nString лайк',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Отозвать';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub перестанет использовать сообщество с аккаунтом $riotId: подключение к сообществу на этом устройстве будет удалено, и вы вернетесь к анонимному просмотру.\n\nОпубликованные посты, комментарии, отзывы, голоса и объявления о поиске напарников останутся в сообществе и будут показывать ваш Riot ID, пока вы не удалите их по одному или не выберете \"Удалить мои данные сообщества\". Присоединиться снова можно в любой момент.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Отозвать согласие?';

  @override
  String get communityWithdrawSubtitle =>
      'Перестать использовать сообщество с этим аккаунтом. Ваши посты сохранятся.';

  @override
  String get communityWithdrawTitle => 'Отозвать согласие';

  @override
  String get communityWriteFirstReview => 'Написать первый отзыв';

  @override
  String get communityYou => 'Вы';

  @override
  String get communityYourCountry => 'Ваша страна';

  @override
  String get communityYourReview => 'Ваш отзыв';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Вы: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Выбор агента';

  @override
  String get liveGameAnonymous => 'Аноним';

  @override
  String get liveGameAutoRefreshNote =>
      'Обновляется автоматически, когда вы в матче.';

  @override
  String get liveGameCurrentGame => 'Текущий матч';

  @override
  String get liveGameEmptyTeam => 'Игроков пока нет.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Команда противника появится, когда начнется матч.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Противники зафиксировали: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'В данных текущего матча нет убийств/смертей/помощи. Таблица счета появится, когда Riot опубликует данные после матча.';

  @override
  String get liveGameFinalScoreboard => 'Итоговая таблица';

  @override
  String get liveGameFlex => 'Флекс';

  @override
  String get liveGameInLobby => 'В лобби';

  @override
  String get liveGameInMatch => 'В матче';

  @override
  String get liveGameInQueue => 'В очереди';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'В очереди · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Уровень $n';
  }

  @override
  String get liveGameLiveScore => 'Текущий счет';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Снаряжение на выборе агента';

  @override
  String get liveGameLoadoutFromMatch => 'Снаряжение в этом матче';

  @override
  String get liveGameLobbyHint =>
      'Когда матч будет найден, ValHub покажет составы команд и ранги игроков.';

  @override
  String get liveGameLockedTag => 'Зафиксирован';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub повторит попытку автоматически. Таблица счета обычно появляется примерно через минуту.';

  @override
  String get liveGameNoAgentYet => 'Агент не выбран';

  @override
  String get liveGameNoLoadout => 'Нет данных о снаряжении этого игрока.';

  @override
  String get liveGameNotInGame => 'Не в матче';

  @override
  String get liveGameNotInGameHint =>
      'Откройте VALORANT и встаньте в очередь — подробности матча появятся здесь автоматически на этапе выбора агента.';

  @override
  String get liveGameNotInGameTitle => 'Вы не в матче';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Снаряжение игрока $name';
  }

  @override
  String get liveGameOpenParty => 'Группа и очередь';

  @override
  String get liveGameParty => 'Группа';

  @override
  String liveGamePeak(String rank) {
    return 'Пик: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Снаряжение игрока $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Снаряжение';

  @override
  String get liveGameQueueHint =>
      'Не закрывайте приложение — подробности матча появятся, как только он будет найден.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'За выход из матча можно получить наказание (потеря RR, запрет на очередь). Все равно выйти?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'За выход на этапе выбора агента можно получить наказание (потеря RR, запрет на очередь). Все равно выйти?';

  @override
  String get liveGameQuitConfirmTitle => 'Покинуть матч?';

  @override
  String get liveGameQuitDone => 'Вы покинули матч.';

  @override
  String get liveGameQuitFailed => 'Не удалось покинуть матч.';

  @override
  String get liveGameQuitMatch => 'Покинуть матч';

  @override
  String get liveGameQuitMatchChanged =>
      'Пока вы подтверждали, матч перешел на новый этап. Вы не покинули матч — повторите попытку.';

  @override
  String get liveGameRankUnavailable => 'Ранг неизвестен';

  @override
  String get liveGameRefresh => 'Обновить';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Обновление через $seconds секунды',
      many: 'Обновление через $seconds секунд',
      few: 'Обновление через $seconds секунды',
      one: 'Обновление через $seconds секунду',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Обновить сейчас';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Подробности матча';

  @override
  String get liveGameSprays => 'Граффити';

  @override
  String get liveGameStatusAgentSelect => 'Выбор агента';

  @override
  String get liveGameStatusEnded => 'Завершен';

  @override
  String get liveGameStatusInProgress => 'Идет';

  @override
  String get liveGameStatusUnavailable => 'Не удалось обновить статус матча';

  @override
  String get liveGameTabAllPlayers => 'Игроки';

  @override
  String get liveGameTabEnemyTeam => 'Противники';

  @override
  String get liveGameTabYourTeam => 'Ваша команда';

  @override
  String liveGameTimeLeft(String t) {
    return 'Осталось: $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Подробности матча';

  @override
  String get liveGameWeapons => 'Оружие';

  @override
  String get liveGameYou => 'ВЫ';

  @override
  String liveGameYouHover(String agent) {
    return 'Вы выбираете: $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Вы зафиксировали: $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Выбирайте и фиксируйте агента в VALORANT. ValHub показывает только оставшееся время и вашу команду.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins победы',
      many: '$wins побед',
      few: '$wins победы',
      one: '$wins победа',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses поражения',
      many: '$losses поражений',
      few: '$losses поражения',
      one: '$losses поражение',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws ничьи',
      many: ' – $draws ничьих',
      few: ' – $draws ничьи',
      one: ' – $draws ничья',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown матча с неизвестным результатом',
      many: ' – $unknown матчей с неизвестным результатом',
      few: ' – $unknown матча с неизвестным результатом',
      one: ' – $unknown матч с неизвестным результатом',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'время устройства ($offset)';
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
      'yes': ' с помощью $weapon',
      'other': '',
    });
    return '$killer убивает $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 дней',
      'days7': '7 дней',
      'other': 'Все время',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Агенты',
      'maps': 'Карты',
      'queues': 'Режимы',
      'sides': 'Атака / Защита',
      'trend': 'Динамика',
      'other': 'Режимы',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Все режимы';

  @override
  String get profileAbility => 'Умение';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n матча',
      many: '≈ $n матчей',
      few: '≈ $n матча',
      one: '≈ $n матч',
    );
    return '$_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Средний боевой счет';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins победы',
      many: '$wins побед',
      few: '$wins победы',
      one: '$wins победа',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games матча',
      many: '$games матчей',
      few: '$games матча',
      one: '$games матч',
    );
    return 'Этот акт: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Все игроки';

  @override
  String get profileAlreadyReached => 'Вы уже достигли этого ранга.';

  @override
  String get profileAtCurrentForm => 'При текущей форме';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'При текущей форме ($gain / $loss за матч)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'В лучшем случае: $n победы подряд',
      many: 'В лучшем случае: $n побед подряд',
      few: 'В лучшем случае: $n победы подряд',
      one: 'В лучшем случае: $n победа подряд',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'По доле побед';

  @override
  String get profileChooseMap => 'Фильтр по карте';

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
  String get profileCopyRiotId => 'Копировать Riot ID';

  @override
  String get profileCurrentRank => 'Текущий';

  @override
  String get profileDailyRrEmpty =>
      'На этом устройстве пока нет сохраненных рейтинговых матчей.';

  @override
  String get profileDailyRrFootnote =>
      'История RR хранится прямо на вашем устройстве, включая матчи, которые Riot больше не показывает.';

  @override
  String get profileDailyRrTitle => 'RR по дням';

  @override
  String profileDayBoundary(String zone) {
    return 'Дни по часовому поясу: $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня с матчами',
      many: '$n дней с матчами',
      few: '$n дня с матчами',
      one: '$n день с матчами',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Показаны все матчи';

  @override
  String get profileEnemyTeam => 'Противники';

  @override
  String get profileFallDamage => 'Падение';

  @override
  String get profileFilterAll => 'Все';

  @override
  String get profileFirstBloods => 'Первые убийства';

  @override
  String get profileFirstDeaths => 'Первые смерти';

  @override
  String get profileFirstHalf => 'Первая половина';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS и HS% считаются только для режимов с раундами.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n матча из списка еще не загружены для расчета.',
      many: '$n матчей из списка еще не загружены для расчета.',
      few: '$n матча из списка еще не загружены для расчета.',
      one: '$n матч из списка еще не загружен для расчета.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR и HS% учитывают только матчи с раундами: $roundGames/$games';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'Последние $games матча',
      many: 'Последние $games матчей',
      few: 'Последние $games матча',
      one: 'Последний $games матч',
    );
    String _temp1 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w победы',
      many: '$w побед',
      few: '$w победы',
      one: '$w победа',
    );
    String _temp2 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l поражения',
      many: '$l поражений',
      few: '$l поражения',
      one: '$l поражение',
    );
    return '$_temp0: $_temp1, $_temp2';
  }

  @override
  String get profileFriendsRow => 'Друзья и чат';

  @override
  String get profileHideKills => 'Скрыть убийства';

  @override
  String get profileHitBody => 'Тело';

  @override
  String get profileHitDistribution => 'Распределение попаданий';

  @override
  String get profileHitHead => 'Голова';

  @override
  String get profileHitLegs => 'Ноги';

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
      'Доля раундов, в которых вы убили, помогли, выжили или за вас отомстили';

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
      other: 'Последние $n дня',
      many: 'Последние $n дней',
      few: 'Последние $n дня',
      one: 'Последний $n день',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Последние $n матча',
      many: 'Последние $n матчей',
      few: 'Последние $n матча',
      one: 'Последний $n матч',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Таблица лидеров #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Уровень $n';
  }

  @override
  String get profileLevelHidden => 'Уровень скрыт';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Серия из $n поражения',
      many: 'Серия из $n поражений',
      few: 'Серия из $n поражений',
      one: 'Серия из $n поражения',
    );
    return '$_temp0';
  }

  @override
  String profileMapFilter(String map) {
    return 'Карта: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n матча',
      many: '$n матчей',
      few: '$n матча',
      one: '$n матч',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Подробности матча';

  @override
  String get profileMatchHistory => 'История матчей';

  @override
  String get profileMatchUnavailable => 'Не удалось загрузить матч';

  @override
  String get profileMatchesNeeded => 'Нужно матчей';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Ранга еще не было';

  @override
  String get profileNoKillsInRound =>
      'Пока нет данных об убийствах в этом раунде.';

  @override
  String get profileNoMatches => 'Матчей пока нет.';

  @override
  String get profileNoMatchesMap =>
      'Среди загруженных матчей нет матчей на этой карте.';

  @override
  String get profileNoMatchesQueue => 'Нет матчей в этом режиме.';

  @override
  String get profileNoPlayers => 'Пока нет данных об игроках этого матча.';

  @override
  String get profileNoRounds => 'Пока нет данных по раундам этого матча.';

  @override
  String get profileOvertime => 'Овертайм';

  @override
  String get profilePlayHubTitle => 'Матч и группа';

  @override
  String get profilePeakRank => 'Пик';

  @override
  String get profilePerformanceAttack => 'Атака';

  @override
  String get profilePerformanceDefense => 'Защита';

  @override
  String get profilePerformanceEmpty =>
      'На этом устройстве пока нет записанных матчей. Откройте историю матчей, чтобы записать сыгранные матчи.';

  @override
  String get profilePerformanceNoMatches => 'Нет матчей за выбранный период.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Учтено $n раунда',
      many: 'Учтено $n раундов',
      few: 'Учтено $n раунда',
      one: 'Учтен $n раунд',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Доли показываются только при наличии хотя бы 3 матчей. ACS, ADR, HS% и K/D учитывают только режимы с раундами.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Сторона (атака или защита) определена в раундах: $known/$total.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'История на устройстве с $date';
  }

  @override
  String get profilePerformanceTitle => 'Показатели';

  @override
  String profilePlacement(int n) {
    return 'Место $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike установлен на точке $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Профиль игрока';

  @override
  String get profilePlayerSummary => 'Показатели';

  @override
  String profileProgressTo(String rank) {
    return 'Прогресс до ранга $rank';
  }

  @override
  String get profileProgressToTarget => 'Прогресс до цели';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Оценка по недавним рейтинговым матчам; квалификационные матчи и защита от понижения не учитываются.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches матча до ранга $rank',
      many: '≈ $matches матчей до ранга $rank',
      few: '≈ $matches матча до ранга $rank',
      one: '≈ $matches матч до ранга $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'У вас уже ранг Бессмертный или выше — расчет доступен только до Бессмертного 1.';

  @override
  String get profileRankUpNoForm =>
      'Нет недавних рейтинговых матчей, чтобы оценить вашу форму.';

  @override
  String get profileRankUpOpen => 'Открыть калькулятор ранга';

  @override
  String get profileRankUpTitle => 'Калькулятор ранга';

  @override
  String get profileRankUpUnranked =>
      'Завершите квалификационные матчи, чтобы пользоваться калькулятором ранга.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Таблица рейтинговой игры';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w победы',
      many: '$w побед',
      few: '$w победы',
      one: '$w победа',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l поражения',
      many: '$l поражений',
      few: '$l поражения',
      one: '$l поражение',
    );
    return 'Недавняя форма: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Недавняя форма';

  @override
  String get profileRecentMatches => 'Недавние матчи';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$wВ · $lП · $dН',
      many: '$wВ · $lП · $dН',
      few: '$wВ · $lП · $dН',
      one: '$wВ · $lП · $dН',
      zero: '$wВ · $lП',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID скопирован';

  @override
  String profileRound(int n) {
    return 'Раунд $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n убийства',
      many: '$n убийств',
      few: '$n убийства',
      one: '$n убийство',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Раунд проигран';

  @override
  String get profileRoundTimeline => 'Ход раундов';

  @override
  String get profileRoundWon => 'Раунд выигран';

  @override
  String get profileRoundsHint =>
      'Нажмите на раунд, чтобы увидеть каждое убийство.';

  @override
  String profileRrLeft(String n) {
    return 'Осталось $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Динамика RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Таблица счета';

  @override
  String get profileSecondHalf => 'Вторая половина';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Показать убийства';

  @override
  String get profileSideSwitch => 'Смена сторон';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Целевой ранг';

  @override
  String get profileTeamBlue => 'Синяя команда';

  @override
  String get profileTeamMvp => 'MVP команды';

  @override
  String get profileTeamRed => 'Красная команда';

  @override
  String get profileTitle => 'Профиль';

  @override
  String profileToday(String text) {
    return 'Сегодня: $text';
  }

  @override
  String get profileTodayNone => 'Сегодня рейтинговых матчей не было';

  @override
  String get profileTruePeakLocal => 'По истории на этом устройстве';

  @override
  String get profileWeekdayShortItem0 => 'Пн';

  @override
  String get profileWeekdayShortItem1 => 'Вт';

  @override
  String get profileWeekdayShortItem2 => 'Ср';

  @override
  String get profileWeekdayShortItem3 => 'Чт';

  @override
  String get profileWeekdayShortItem4 => 'Пт';

  @override
  String get profileWeekdayShortItem5 => 'Сб';

  @override
  String get profileWeekdayShortItem6 => 'Вс';

  @override
  String get profileWinRate => 'Доля побед';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Серия из $n победы',
      many: 'Серия из $n побед',
      few: 'Серия из $n побед',
      one: 'Серия из $n победы',
    );
    return '$_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Ваш ранг';

  @override
  String get profileYourSummary => 'Ваши показатели';

  @override
  String get profileYourTeam => 'Ваша команда';

  @override
  String get profileYourWinRate => 'Ваша недавняя доля побед';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Режим: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Фильтр по режиму';

  @override
  String get profilePerformancePerMatchTitle => 'По матчам';

  @override
  String get profilePerformancePerMatchHint =>
      'Нажмите на столбец, чтобы открыть этот матч.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Среднее $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Для графика нужно хотя бы 2 матча с раундами, где есть этот показатель.';

  @override
  String get profilePerformanceOpeningsTitle => 'Стартовые дуэли';

  @override
  String get profilePerformanceOpeningWin => 'Выигранные стартовые дуэли';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Среди раундов с вашим первым убийством или первой смертью — доля первых убийств.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'Первые убийства за матч';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Первые смерти за матч';

  @override
  String get profilePerformanceMultiKillsTitle => 'Несколько убийств за раунд';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 убийства',
      'k4': '4 убийства',
      'ace': 'Эйс',
      'other': '2 убийства',
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
      other: 'На основе $nString матча с полными данными об убийствах.',
      many: 'На основе $nString матчей с полными данными об убийствах.',
      few: 'На основе $nString матчей с полными данными об убийствах.',
      one: 'На основе $nString матча с полными данными об убийствах.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Выигранные раунды';

  @override
  String get profilePerformanceDrillHint =>
      'Нажмите на строку, чтобы посмотреть только этого агента, карту или режим.';

  @override
  String get profilePerformanceLoadOlder => 'Анализировать старые матчи';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub анализирует только матчи, открытые на этом устройстве. Каждое нажатие добавляет более старые матчи (не больше $nString).';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Ищем более старые матчи…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Анализ матчей: $doneString/$totalString…';
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
      other: 'В анализ добавлено $nString матча.',
      many: 'В анализ добавлено $nString матчей.',
      few: 'В анализ добавлено $nString матча.',
      one: 'В анализ добавлен $nString матч.',
      zero: 'Нет новых матчей для добавления.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot больше не хранит более старые матчи.';

  @override
  String get profileEconomyTitle => 'Экономика вашей команды';

  @override
  String get profileEconomyHint =>
      'Тип закупки по общей стоимости снаряжения команды в начале раунда (принято на vlr.gg для 5 игроков): Eco — меньше 5 000, Semi-eco — меньше 10 000, Semi-buy — меньше 20 000, Full buy — от 20 000 кредитов. Первый раунд каждой половины — Pistol.';

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

    return 'Победы $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'Ваш помощник в VALORANT: ежедневный магазин, список желаемого, ранг, матчи, несколько аккаунтов и сообщество игроков прямо на вашем устройстве.';

  @override
  String get legalBackToTop => 'Наверх';

  @override
  String get legalConsentAnd => ' и ';

  @override
  String get legalConsentPrefix => 'Продолжая, вы принимаете ';

  @override
  String get legalConsentPrivacy => 'Политику конфиденциальности';

  @override
  String get legalConsentSuffix => ' приложения ValHub.';

  @override
  String get legalConsentTerms => 'Условия использования';

  @override
  String get legalContact => 'Связаться';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'КОНТАКТЫ';

  @override
  String legalEffectiveFrom(String date) {
    return 'Действует с $date';
  }

  @override
  String get legalLegalHeader => 'ПРАВОВАЯ ИНФОРМАЦИЯ';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Все права защищены.';

  @override
  String get legalThirdPartyLicenses => 'Стороннее ПО';

  @override
  String get legalThirdPartyLicensesBody =>
      'Лицензии ПО с открытым исходным кодом, которое использует ValHub';

  @override
  String get legalTocTitle => 'СОДЕРЖАНИЕ';

  @override
  String legalVersion(String version) {
    return 'Версия $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Язык этого документа: $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Не удалось открыть правовой документ. Повторите попытку или обратитесь в поддержку.';

  @override
  String get legalTranslationNotice =>
      'Этот перевод предоставлен для удобства. При расхождениях преимущественную силу имеет версия на вьетнамском языке.';

  @override
  String get settingsUiLanguageTitle => 'Язык приложения';

  @override
  String get settingsLanguageFollowDevice => 'Как на устройстве';

  @override
  String get settingsLanguageSaveFailed =>
      'Не удалось сохранить язык. Повторите попытку.';

  @override
  String get settingsGeoCountry => 'Страна';

  @override
  String get settingsGeoSearchCountry => 'Поиск по названию или коду страны';

  @override
  String get settingsGeoSupportedOnly => 'Только с подтвержденной поддержкой';

  @override
  String get settingsGeoUnknown => 'Поддержка не подтверждена';

  @override
  String get settingsGeoRestricted => 'Ограничено';

  @override
  String get settingsGeoSeparate => 'Отдельный сервис';

  @override
  String get settingsGeoAvailable => 'Поддерживается';

  @override
  String get settingsGeoNotApplicable => 'Неприменимо';

  @override
  String get settingsGeoConnection => 'Подключение к Riot';

  @override
  String get settingsGeoChooseRegion => 'Выбрать регион';

  @override
  String get settingsGeoAuto => 'Автоматически по аккаунту';

  @override
  String get settingsGeoManual => 'Выбрать вручную';

  @override
  String get settingsGeoNoRegion => 'Не удалось определить регион Riot';

  @override
  String get settingsGeoManualWarning =>
      'Этот выбор меняет только сервер, к которому подключается ValHub. Он не переносит регион вашего аккаунта Riot. Перед сохранением ValHub проверит подключение.';

  @override
  String get settingsGeoConnectionSaved => 'Подключение сохранено';

  @override
  String get settingsGeoValidationFailed =>
      'Не удалось подтвердить ваш аккаунт на этом сервере. Выберите регион заново.';

  @override
  String get settingsGeoHintOnly =>
      'Страна используется только для поиска и подсказок. Регион подключения зависит от аккаунта Riot.';

  @override
  String get settingsGeoSave => 'Проверить и сохранить';

  @override
  String get settingsGeoCancel => 'Отмена';

  @override
  String get settingsGeoLoading => 'Проверка подключения…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Этот выбор используется для названий стран, подсказок и примерных цен в VP. Сервер подключения и страну аккаунта в сообществе по-прежнему определяет Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'Страна аккаунта или устройства';

  @override
  String get settingsGeoSaveFailed =>
      'Не удалось сохранить выбор. Повторите попытку.';

  @override
  String get settingsGeoAllRegions => 'Все регионы';

  @override
  String get settingsGeoSuggestions => 'Подсказки';

  @override
  String get settingsGeoNoCountries => 'Нет стран, подходящих под фильтр.';

  @override
  String get settingsGeoActiveCountries => 'Активные';

  @override
  String get settingsGeoAllCountries => 'Все страны';

  @override
  String get settingsGeoActivityUnavailable =>
      'Не удалось загрузить активность стран. Вы можете выбрать страну во вкладке «Все страны».';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страны',
      many: '$count стран',
      few: '$count страны',
      one: '$count страна',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Вы выбрали: $manual, но Riot определяет регион вашего аккаунта как $detected. Продолжить проверку этого подключения?';
  }

  @override
  String get settingsGeoUnverified =>
      'Не удалось проверить подключение из-за неполадок на сервере или в сети. Сохранить этот выбор и проверить позже?';

  @override
  String get settingsGeoContinue => 'Продолжить';

  @override
  String settingsGeoMismatch(String region) {
    return 'Ручное подключение отличается от вашего региона Riot: $region. Перейти на автоматический выбор?';
  }

  @override
  String get settingsGeoUseAuto => 'Автоматически';

  @override
  String get settingsGeoKeepManual => 'Оставить вручную';

  @override
  String get settingsGeoReviewConnection => 'Подключение';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Последняя проверка: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Проверить снова';

  @override
  String get settingsPlatformMobile => 'Мобильное устройство';

  @override
  String get settingsPlatformOther => 'Другая платформа';

  @override
  String get settingsContentLanguageFollowApp => 'Как язык приложения';

  @override
  String get settingsContentLanguageHint =>
      'Выберите язык названий предметов. Это не меняет язык приложения и ваш сервер Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Язык: $language.';
  }

  @override
  String get settingsAboutHeader => 'ИНФОРМАЦИЯ';

  @override
  String get settingsAboutRowSubtitle =>
      'Конфиденциальность, условия, авторские права и контакты';

  @override
  String get settingsAboutTitle => 'О приложении и правовая информация';

  @override
  String get settingsAppHeader => 'ДОПОЛНИТЕЛЬНО';

  @override
  String get settingsAppearanceHeader => 'ВНЕШНИЙ ВИД';

  @override
  String settingsBuildNumber(String build) {
    return 'Сборка $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Удалено: $size';
  }

  @override
  String get settingsClearCache => 'Удалить временные данные';

  @override
  String get settingsClearCacheFailed =>
      'Не удалось удалить временные данные. Повторите попытку.';

  @override
  String get settingsClearCacheSubtitle =>
      'Изображения и данные, загруженные на устройство, включая записанные отчеты об ошибках';

  @override
  String get settingsExportLog => 'Отправить отчет об ошибке в ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Пока нечего отправлять. Попользуйтесь приложением и повторите попытку.';

  @override
  String get settingsExportLogSubtitle =>
      'Отчеты об ошибках не содержат ваш пароль и данные для входа Riot.';

  @override
  String get settingsFeedback => 'Отзыв о ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Открыть страницу отзывов ValHub';

  @override
  String get settingsItemLanguageEn => 'Английский';

  @override
  String get settingsItemLanguageLabel => 'Названия предметов';

  @override
  String get settingsItemLanguagePickerTitle => 'Язык названий предметов';

  @override
  String get settingsItemLanguageVi => 'Вьетнамский';

  @override
  String get settingsLinkOpenFailed =>
      'Не удалось открыть ссылку. Повторите попытку.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Отчет об ошибке';
  }

  @override
  String get settingsLogShareFailed =>
      'Не удалось отправить отчет об ошибке. Повторите попытку.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Когда открывается Ночной рынок';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Напоминает открыть карты предложений Ночного рынка';

  @override
  String get settingsNotifPermissionMissing =>
      'У приложения нет разрешения на уведомления.';

  @override
  String get settingsNotifStoreReset => 'Когда обновляется магазин';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Ежедневно в $time';
  }

  @override
  String get settingsNotifWishlist =>
      'Когда появляется скин из списка желаемого';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Проверяет магазин всех аккаунтов, даже когда приложение закрыто';

  @override
  String get settingsNotificationsHeader => 'УВЕДОМЛЕНИЯ';

  @override
  String get settingsOptionAutoOpenLiveGame => 'Автоматически открывать матч';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Открывать панель текущего матча сразу, как только матч найден';

  @override
  String get settingsOptionOwnPrice => 'Ваша цена набора VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Не указана — используется прайс-лист региона, если он есть';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Платформа';

  @override
  String get settingsOptionShowLiveScore => 'Показывать текущий счет';

  @override
  String get settingsOptionShowPeakRank =>
      'Показывать пиковый ранг в подробностях матча';

  @override
  String get settingsOptionShowPrice => 'Показывать примерные цены';

  @override
  String get settingsOptionShowPriceInfo => 'Как считаются примерные цены';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Рядом с ценой в VP, например $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Для вашего региона пока нет проверенного прайс-листа — укажите цену своего набора VP.';

  @override
  String get settingsOptionsHeader => 'ПАРАМЕТРЫ';

  @override
  String get settingsPhaseComplete => 'Завершено';

  @override
  String get settingsPhaseInProgress => 'Идет';

  @override
  String get settingsPhaseScheduled => 'Запланировано';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Для аккаунта: $account';
  }

  @override
  String get settingsPlatformHint =>
      'Выберите ПК, PlayStation или Xbox — там, где вы играете, — чтобы видеть правильную историю матчей.';

  @override
  String get settingsPlatformPickerTitle => 'Выберите платформу';

  @override
  String get settingsPrimingBody =>
      'Включите уведомления, чтобы узнавать об обновлении магазина и о появлении скинов из списка желаемого.';

  @override
  String get settingsPrimingEnable => 'Включить уведомления';

  @override
  String get settingsPrimingFootnote =>
      'Каждый тип уведомлений можно включить или отключить в любой момент в настройках.';

  @override
  String get settingsPrimingLater => 'Позже';

  @override
  String get settingsPrimingPointNightMarket =>
      'Узнавайте об открытии Ночного рынка';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Чтобы успеть открыть предложения, пока они не исчезли';

  @override
  String get settingsPrimingPointStore =>
      'Напоминания об обновлении ежедневного магазина';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Напоминание после обновления магазина вашего аккаунта';

  @override
  String get settingsPrimingPointWishlist =>
      'Оповещения о скинах, за которыми вы охотитесь';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Проверяет магазин всех аккаунтов, даже когда приложение закрыто';

  @override
  String get settingsPrimingTitle => 'Не упустите желанный скин';

  @override
  String settingsRemovedAccount(String account) {
    return 'Аккаунт удален: $account';
  }

  @override
  String get settingsServerStatus => 'Состояние серверов';

  @override
  String get settingsServerStatusMaintenance => 'Технические работы';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n уведомления',
      many: '$n уведомлений',
      few: '$n уведомления',
      one: '$n уведомление',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Технические работы и неполадки VALORANT по серверам';

  @override
  String get settingsSessionLogTitle => 'Отчет об ошибке ValHub';

  @override
  String get settingsSeverityCritical => 'Критично';

  @override
  String get settingsSeverityInfo => 'Информация';

  @override
  String get settingsSeverityWarning => 'Предупреждение';

  @override
  String get settingsSignedOutAll => 'Вы вышли из всех аккаунтов';

  @override
  String get settingsStatusAllGood => 'Серверы работают нормально';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'На сервере $region нет неполадок и технических работ.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Свернуть';

  @override
  String get settingsStatusIssues => 'Riot устраняет неполадки';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'На этом сервере $n сообщения о неполадках.',
      many: 'На этом сервере $n сообщений о неполадках.',
      few: 'На этом сервере $n сообщения о неполадках.',
      one: 'На этом сервере $n сообщение о неполадках.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Неполадки';

  @override
  String get settingsStatusKindMaintenance => 'Технические работы';

  @override
  String get settingsStatusMaintenanceNow => 'На сервере технические работы';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Возможно, сейчас не получится зайти в игру, а ValHub может временно не загружать данные.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Показать еще $n обновления',
      many: 'Показать еще $n обновлений',
      few: 'Показать еще $n обновления',
      one: 'Показать еще $n обновление',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Скоро технические работы';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Riot объявил $n периода технических работ.',
      many: 'Riot объявил $n периодов технических работ.',
      few: 'Riot объявил $n периода технических работ.',
      one: 'Riot объявил $n период технических работ.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Источник: официальная страница состояния серверов Riot Games. Время указано по часовому поясу устройства.';

  @override
  String settingsStatusStarted(String when) {
    return 'Начало: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Обновлено: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'ОБНОВЛЕНИЯ ОТ RIOT';

  @override
  String get settingsSupportHeader => 'ПОДДЕРЖКА';

  @override
  String settingsSwitchedTo(String account) {
    return 'Выбран аккаунт: $account';
  }

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsThemeLabel => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemePickerTitle => 'Выберите тему';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Ранг, история матчей, текущие матчи';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR за каждый матч, ранги соперников';

  @override
  String get settingsWelcomeBulletStore =>
      'Ежедневный магазин, Ночной рынок и наборы';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Цены, редкость, отсчет до обновления';

  @override
  String get settingsWelcomeBulletWishlist => 'Список желаемого и уведомления';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Оповещение, когда желанный скин появится в магазине';

  @override
  String get settingsWelcomeFootnote =>
      'Вы входите на официальной странице Riot. ValHub сохраняет пароль, только если вы сами решите сохранить данные для входа.';

  @override
  String get settingsWelcomeKicker => 'ПОМОЩНИК В VALORANT';

  @override
  String get settingsCountryPriceHeader => 'Страна и цены';

  @override
  String get settingsDataHeader => 'Данные на устройстве';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (оценки: $count) · ',
      'other': '',
    });
    return 'Сообщество: $_temp0лайки: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'В список желаемого';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Есть в магазине: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      daily,
      locale: localeName,
      other: '$daily раза в ежедневном магазине',
      many: '$daily раз в ежедневном магазине',
      few: '$daily раза в ежедневном магазине',
      one: '$daily раз в ежедневном магазине',
    );
    String _temp1 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night Ночного рынка',
      many: '$night Ночных рынков',
      few: '$night Ночных рынка',
      one: '$night Ночной рынок',
    );
    return 'В вашем магазине: $_temp0, $_temp1. Учитываются только данные на этом устройстве, записанные с $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Удалить историю магазина';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Удалить все записанные дни магазина для этого аккаунта на этом устройстве?';

  @override
  String get skinDetailInWishlist => 'В списке желаемого';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Закрыто';

  @override
  String get skinDetailMute => 'Выключить звук';

  @override
  String get skinDetailNotFound => 'Не удалось найти этот скин.';

  @override
  String get skinDetailOwned => 'В коллекции';

  @override
  String get skinDetailPause => 'Пауза';

  @override
  String get skinDetailPlay => 'Воспроизвести';

  @override
  String get skinDetailPlayVideo => 'Смотреть видео';

  @override
  String get skinDetailRemoveFromWishlist => 'Убрать из списка желаемого';

  @override
  String get skinDetailTitle => 'Подробности скина';

  @override
  String get skinDetailUnmute => 'Включить звук';

  @override
  String get skinDetailUpgrades => 'Улучшения';

  @override
  String get skinDetailVariants => 'Варианты';

  @override
  String get skinDetailVideoError =>
      'Не удалось воспроизвести видео. Проверьте подключение и повторите попытку.';

  @override
  String get socialPresenceInMatch => 'В матче';

  @override
  String get socialPresenceAgentSelect => 'Выбирает агента';

  @override
  String get socialPresenceQueue => 'В очереди';

  @override
  String get socialPresenceLobby => 'В лобби';

  @override
  String get socialPresenceCustom => 'В своей игре';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Открытая группа',
      'other': 'Только по приглашению',
    });
    return 'Игроки: $size/$max · $_temp0';
  }

  @override
  String get socialAccept => 'Принять';

  @override
  String get socialAcceptInGame => 'Примите это приглашение в игре.';

  @override
  String socialActionFailed(String message) {
    return 'Не удалось выполнить действие. $message';
  }

  @override
  String get socialAutoRefresh => 'Автообновление';

  @override
  String get socialAway => 'Нет на месте';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Отменить поиск · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Отменить поиск';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Группа не может встать в очередь «$queue»: $reason';
  }

  @override
  String get socialChangeQueue => 'Сменить очередь';

  @override
  String get socialChatUnavailable => 'Чат недоступен.';

  @override
  String get socialCloseParty => 'Закрыть группу';

  @override
  String get socialCodeInvalid =>
      'Код группы может содержать только буквы и цифры.';

  @override
  String get socialConnecting => 'Подключение к чату…';

  @override
  String get socialCopyCode => 'Копировать';

  @override
  String get socialCurrentQueue => 'Выбрано';

  @override
  String get socialCustomGameLobby => 'Ваша группа в лобби своей игры.';

  @override
  String get socialDecline => 'Отклонить';

  @override
  String get socialDisableCode => 'Отключить код';

  @override
  String get socialEmptyChat => 'Сообщений пока нет. Поздоровайтесь!';

  @override
  String get socialEmptyChatTitle => 'Начните общение';

  @override
  String get socialFailedBadge => 'Не отправлено';

  @override
  String get socialFilterAll => 'Все';

  @override
  String get socialFilterOnline => 'В сети';

  @override
  String get socialFilterUnread => 'Непрочитанные';

  @override
  String get socialFriendsPrivacyNote =>
      'Список друзей и сообщения берутся напрямую из Riot. ValHub больше нигде их не хранит.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total друга',
      many: '$total друзей',
      few: '$total друга',
      one: '$total друг',
    );
    return '$_temp0 · В сети: $online';
  }

  @override
  String get socialFriendsTitle => 'Друзья и чат';

  @override
  String get socialGameNotRunningBody =>
      'Группа и очередь работают, только когда VALORANT запущен на вашем ПК или консоли. Откройте игру и потяните вниз, чтобы обновить.';

  @override
  String get socialGameNotRunningTitle => 'Откройте VALORANT на ПК или консоли';

  @override
  String get socialGenerateCode => 'Создать код';

  @override
  String get socialIdleQueue => 'Можно искать матч';

  @override
  String get socialInMatchBanner =>
      'Вы в матче. Очередь снова откроется после окончания матча.';

  @override
  String get socialInValorant => 'В VALORANT';

  @override
  String get socialInviteByRiotId => 'Пригласить по Riot ID';

  @override
  String get socialInviteByRiotIdHint => 'Пригласите тех, кто еще не в друзьях';

  @override
  String get socialInviteFriends => 'Пригласить друзей';

  @override
  String socialInviteFrom(String name) {
    return 'Приглашение от игрока $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Пригласить: $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Riot ID этого игрока неизвестен, поэтому пригласить его пока нельзя.';

  @override
  String socialInviteSent(String name) {
    return 'Приглашение отправлено: $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Приглашение отправлено';
  }

  @override
  String get socialInvitesSection => 'Приглашения';

  @override
  String get socialJoin => 'Вступить';

  @override
  String get socialJoinConfirmBody =>
      'Вы покинете текущую группу и вступите в группу с этим кодом.';

  @override
  String get socialJoinConfirmTitle => 'Вступить в другую группу?';

  @override
  String get socialJoinSection => 'Вступить в другую группу';

  @override
  String get socialJoinWithCode => 'Введите код, чтобы вступить';

  @override
  String get socialJoined => 'Вы вступили в группу.';

  @override
  String socialLastOnline(String relative) {
    return 'Активность: $relative';
  }

  @override
  String get socialLeader => 'Лидер';

  @override
  String socialLeaderboardTop(String position) {
    return 'Топ $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Вы покинете текущую группу и вернетесь в одиночную.';

  @override
  String get socialLeaveConfirmTitle => 'Покинуть группу?';

  @override
  String get socialLeaveParty => 'Покинуть группу';

  @override
  String socialLevel(int n) {
    return 'Уровень $n';
  }

  @override
  String get socialMatchFound => 'Матч найден!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Участники ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Введите сообщение…';

  @override
  String get socialMoreActions => 'Другие действия';

  @override
  String get socialNoCode =>
      'Создайте код, чтобы друзья могли быстро вступить в вашу группу.';

  @override
  String get socialNoCodeMember =>
      'Лидер группы может создать код для быстрых приглашений.';

  @override
  String get socialNoFilterResults => 'Нет друзей, подходящих под этот фильтр.';

  @override
  String get socialNoFriends =>
      'Ваш список друзей Riot пуст. Добавляйте друзей в игре.';

  @override
  String get socialNoFriendsTitle => 'Друзей пока нет';

  @override
  String get socialNoOnlineFriends =>
      'Сейчас никого из ваших друзей нет в сети в VALORANT.';

  @override
  String get socialNoSearchResults => 'Подходящих друзей не найдено.';

  @override
  String get socialNoSearchResultsTitle => 'Ничего не найдено';

  @override
  String get socialNotReady => 'Не готов';

  @override
  String socialOfflineSection(int n) {
    return 'Не в сети ($n)';
  }

  @override
  String get socialOfflineStatus => 'Не в сети';

  @override
  String get socialOnlineMobile => 'В сети с телефона';

  @override
  String socialOnlineSection(int n) {
    return 'В сети ($n)';
  }

  @override
  String get socialOnlineStatus => 'В сети';

  @override
  String get socialOnlyLeader =>
      'Только лидер группы может менять очередь и начинать поиск матча.';

  @override
  String get socialOpenParty => 'Открыть группу';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Код группы';

  @override
  String socialPartyCodeValue(String code) {
    return 'Код группы: $code';
  }

  @override
  String get socialPartyInvite => 'Приглашение в группу';

  @override
  String socialPartyOf(int size, int max) {
    return 'Группа $size/$max';
  }

  @override
  String get socialPartyTitle => 'Группа и очередь';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Группа из $size игрока',
      many: 'Группа из $size игроков',
      few: 'Группа из $size игроков',
      one: 'Группа из $size игрока',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'Выберите очередь';

  @override
  String socialPing(int ms) {
    return '$ms мс';
  }

  @override
  String get socialPingTooltip => 'Лучший пинг до игровых серверов';

  @override
  String socialPlayingOther(String game) {
    return 'Играет в $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Играют ($n)';
  }

  @override
  String get socialQueueLabel => 'Очередь';

  @override
  String get socialQueueLocked => 'Нельзя сменить очередь во время матча.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'До $max игрока',
      many: 'До $max игроков',
      few: 'До $max игроков',
      one: 'До $max игрока',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Не удалось проверить состояние игры. Обновите, чтобы пользоваться готовностью и очередью.';

  @override
  String get socialReady => 'Готов';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Готовы: $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'у участника слишком низкий уровень аккаунта';

  @override
  String get socialReasonGeneric => 'группа пока не соответствует требованиям';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'группа слишком большая (максимум $max)';
  }

  @override
  String get socialReasonRankDisparity =>
      'слишком большая разница в рангах для рейтинговой игры';

  @override
  String socialReasonRestricted(String time) {
    return 'группе временно запрещен поиск матча (осталось $time)';
  }

  @override
  String get socialReconnecting => 'Связь с чатом потеряна. Переподключение…';

  @override
  String get socialRemoteNote =>
      'Изменения отправляются в Riot только после вашего нажатия. ValHub никогда не ищет матч и не фиксирует агента за вас.';

  @override
  String socialRemoveConfirmBody(String name) {
    return 'Игрок $name будет исключен из вашей группы.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Исключить из группы?';

  @override
  String get socialRemoveMember => 'Исключить из группы';

  @override
  String socialRequestFrom(String name) {
    return '$name хочет вступить в группу';
  }

  @override
  String get socialRequestsSection => 'Запросы на вступление';

  @override
  String get socialRiotIdFieldHint => 'Имя#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID состоит из имени (3–16 символов), знака # и тега (3–5 букв или цифр).';

  @override
  String get socialSearchHint => 'Поиск по Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'В очереди · $elapsed';
  }

  @override
  String get socialSend => 'Отправить';

  @override
  String get socialSendFailed =>
      'Не удалось отправить сообщение. Проверьте подключение и повторите попытку.';

  @override
  String get socialSendInvite => 'Отправить приглашение';

  @override
  String get socialShareCode => 'Поделиться';

  @override
  String socialShareCodeText(String code) {
    return 'Вступай в мою группу в VALORANT по коду: $code';
  }

  @override
  String get socialShootingRange => 'На стрельбище';

  @override
  String get socialShowEveryone => 'Показать всех';

  @override
  String get socialStartQueue => 'Начать поиск';

  @override
  String get socialSuggestionsItem0 => 'Привет!';

  @override
  String get socialSuggestionsItem1 => 'Сыграем пару матчей?';

  @override
  String get socialSuggestionsItem2 => 'Залетай ко мне в группу!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n непрочитанного сообщения',
      many: '$n непрочитанных сообщений',
      few: '$n непрочитанных сообщения',
      one: '$n непрочитанное сообщение',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Отменить готовность';

  @override
  String get socialViewProfile => 'Профиль';

  @override
  String get socialWaitingForConnection =>
      'Подключение… Отправлять сообщения можно будет после подключения.';

  @override
  String get socialYou => 'Вы';

  @override
  String get socialPartyUnavailable =>
      'Не удалось синхронизировать группу. Обновите, чтобы повторить попытку.';

  @override
  String get socialAcceptConfirmBody =>
      'Вы покинете текущую группу и вступите в группу, которая вас пригласила.';

  @override
  String get storeAccessoryEmpty => 'В магазине аксессуаров сейчас пусто.';

  @override
  String get storeAccessoryEmptyTitle => 'Аксессуаров пока нет';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Из: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Обновление через $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Обновление: $wall';
  }

  @override
  String get storeAddToWishlist => 'В список желаемого';

  @override
  String get storeBackToBundles => 'Наборы в продаже';

  @override
  String get storeBundleBuySeparateLabel => 'По отдельности';

  @override
  String get storeBundleDetailTitle => 'Подробности набора';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Завершится: $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Осталось: $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n предмета',
      many: '$n предметов',
      few: '$n предмета',
      one: '$n предмет',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Бесплатно';

  @override
  String get storeBundleItemsTitle => 'Предметы в наборе';

  @override
  String get storeBundleNotFound =>
      'Не удалось найти этот набор. Возможно, его срок истек.';

  @override
  String get storeBundleNotFoundTitle => 'Срок набора истек';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Уже есть: $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Цена набора';

  @override
  String get storeBundleSavingsLabel => 'Экономия';

  @override
  String get storeBundleWholesaleOnly =>
      'Продается только целым набором, не по отдельности.';

  @override
  String get storeBundlesEmpty => 'Сейчас нет наборов в продаже.';

  @override
  String get storeBundlesEmptyTitle => 'Наборов пока нет';

  @override
  String get storeDailyEmpty => 'Сегодня в магазине нет скинов.';

  @override
  String get storeDailyEmptyTitle => 'Магазин пуст';

  @override
  String storeDailyResetAt(String time) {
    return 'Обновляется ежедневно в $time';
  }

  @override
  String get storeDailyTotalLabel => 'Всего';

  @override
  String get storeNightMarketEmpty => 'Сейчас Ночного рынка нет.';

  @override
  String get storeNightMarketEmptyTitle => 'Ночной рынок закрыт';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Завершится: $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Завершится через $t';
  }

  @override
  String get storeNightMarketNote =>
      'Предложения Ночного рынка уникальны для вашего аккаунта и не обновляются.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Общая экономия: $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Не открыто';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'В коллекции';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Уже есть: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Убрать из списка желаемого';

  @override
  String get storeResetNotificationTitle => 'Магазин обновился';

  @override
  String storeResetsIn(String t) {
    return 'Обновление через $t';
  }

  @override
  String get storeSegmentAccessories => 'Аксессуары';

  @override
  String get storeSegmentBundles => 'Наборы';

  @override
  String get storeSegmentDaily => 'Ежедневный';

  @override
  String get storeSegmentNightMarket => 'Ночной рынок';

  @override
  String get storeShareButton => 'Поделиться';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Магазин сегодня';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Ночной рынок';

  @override
  String get storeShareCardPriceNote =>
      'Пересчитанные цены — лишь примерная оценка по наборам VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Экономия $vp';
  }

  @override
  String get storeShareCardTagline => 'Ваш помощник в VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Всего $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'До $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Поделиться сегодняшним магазином';

  @override
  String get storeShareFailed =>
      'Не удалось создать изображение. Повторите попытку.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Поделиться изображением';

  @override
  String get storeShareNightMarketTitle => 'Поделиться Ночным рынком';

  @override
  String get storeSharePreparing => 'Загрузка изображений скинов…';

  @override
  String get storeShareShowPrice => 'Показывать примерные цены';

  @override
  String get storeShareShowPriceHint =>
      'Пересчет по самому выгодному набору VP.';

  @override
  String get storeShareShowRiotId => 'Показывать Riot ID на изображении';

  @override
  String get storeShareShowRiotIdHint =>
      'По умолчанию выключено ради вашей конфиденциальности.';

  @override
  String get storeShareSubjectDaily => 'Мой магазин VALORANT сегодня';

  @override
  String get storeShareSubjectNightMarket => 'Мой Ночной рынок VALORANT';

  @override
  String get storeShareSubtitle =>
      'Поделитесь изображением магазина с друзьями через любое приложение.';

  @override
  String get storeTitle => 'Магазин';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Баланс: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'В списке желаемого: $n';
  }

  @override
  String get storeHistoryTitle => 'История магазина';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString дня',
      many: '$daysString дней',
      few: '$daysString дня',
      one: '$daysString день',
    );
    return 'Записывается на этом устройстве с $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Пока нет записанных дней. ValHub сохраняет ваш ежедневный магазин каждый раз, когда вы открываете приложение, только на этом устройстве.';

  @override
  String get storeHistoryMostOffered => 'Чаще всего в магазине';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString раза',
      many: '$nString раз',
      few: '$nString раза',
      one: '$nString раз',
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
      other: 'Ночной рынок · $countString предложения',
      many: 'Ночной рынок · $countString предложений',
      few: 'Ночной рынок · $countString предложения',
      one: 'Ночной рынок · $countString предложение',
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
      other: 'Записано на этом устройстве: $daysString дня',
      many: 'Записано на этом устройстве: $daysString дней',
      few: 'Записано на этом устройстве: $daysString дня',
      one: 'Записано на этом устройстве: $daysString день',
      zero: 'Запись началась сегодня',
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
      'yes': '$skin есть в магазине ($account) — осталось $left.',
      'other': '$skin есть в магазине ($account).',
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
      'discount': '$skin: скидка $percent%, цена $price ($account).',
      'price': '$skin всего за $price ($account).',
      'other': '$skin есть на Ночном рынке ($account).',
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
      'yes': '$skin входит в набор $bundle ($account).',
      'other': '$skin входит в набор, который сейчас продается ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'В магазине ($account): $names и еще $more скина.',
      many: 'В магазине ($account): $names и еще $more скинов.',
      few: 'В магазине ($account): $names и еще $more скина.',
      one: 'В магазине ($account): $names и еще $more скин.',
      zero: 'В магазине ($account): $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', в списке желаемого',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Добавить скины';

  @override
  String get wishlistAddToWishlist => 'В список желаемого';

  @override
  String get wishlistAllWeapons => 'Все оружие';

  @override
  String get wishlistBrowseCatalog => 'Все скины';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString скина',
      many: '$countString скинов',
      few: '$countString скина',
      one: '$countString скин',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Не удалось загрузить список скинов. Обновите, чтобы повторить попытку.';

  @override
  String get wishlistCatalogEmptyTitle => 'Скинов пока нет';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'В списке желаемого: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Нажмите ♡, чтобы добавить скин в список желаемого';

  @override
  String get wishlistCatalogTitle => 'Все скины';

  @override
  String get wishlistChooseWeapon => 'Выберите оружие';

  @override
  String get wishlistClearFilters => 'Сбросить фильтры';

  @override
  String get wishlistEmpty =>
      'Список желаемого пуст. Нажмите ♡ на любом скине, чтобы добавить его.';

  @override
  String get wishlistEmptyTitle => 'Скинов пока нет';

  @override
  String wishlistEndsIn(String time) {
    return 'Завершится через $time';
  }

  @override
  String get wishlistExcludedRewards => 'Без учета скинов-наград';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString скина',
      many: '$countString скинов',
      few: '$countString скина',
      one: '$countString скин',
    );
    return 'По фильтру: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Подходящих скинов нет. Сбросьте фильтры, чтобы увидеть больше.';

  @override
  String get wishlistNoMatchTitle => 'Скины не найдены';

  @override
  String get wishlistNotifBundleTitle =>
      'В новом наборе есть скин из списка желаемого';

  @override
  String get wishlistNotifDailyTitle => 'Скин из списка желаемого появился!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'На Ночном рынке скин, который вы хотели!';

  @override
  String get wishlistNotifPermissionMissing =>
      'У приложения нет разрешения на уведомления.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count скина из списка желаемого в продаже!',
      many: '$count скинов из списка желаемого в продаже!',
      few: '$count скина из списка желаемого в продаже!',
      one: '$count скин из списка желаемого в продаже!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Уведомления о списке желаемого';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Для этого аккаунта, даже когда приложение закрыто';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Список желаемого: $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count скина из списка желаемого в продаже!',
      many: '$count скинов из списка желаемого в продаже!',
      few: '$count скина из списка желаемого в продаже!',
      one: '$count скин из списка желаемого в продаже!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Нажмите на отмеченную строку, чтобы увидеть предложение.';

  @override
  String get wishlistOpenSettings => 'Открыть настройки';

  @override
  String get wishlistOwned => 'В коллекции';

  @override
  String get wishlistRemoveAction => 'Убрать из списка желаемого';

  @override
  String get wishlistRemoveFromWishlist => 'Убрать из списка желаемого';

  @override
  String wishlistRemoved(String name) {
    return '$name удален из списка желаемого';
  }

  @override
  String get wishlistSearchHint => 'Поиск скинов…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString скина',
      many: '$countString скинов',
      few: '$countString скина',
      one: '$countString скин',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'Название';

  @override
  String get wishlistSortPrice => 'Цена';

  @override
  String get wishlistSortRarity => 'Редкость';

  @override
  String get wishlistSortWeapon => 'Оружие';

  @override
  String get wishlistTitle => 'Список желаемого';

  @override
  String get wishlistTotalValue => 'Стоимость списка желаемого';

  @override
  String get wishlistUndo => 'Отменить';

  @override
  String get wishlistViewInStore => 'Открыть в магазине';

  @override
  String get wishlistWeapon => 'Оружие';

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
      'yes': ', в списке желаемого',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', в списке желаемого',
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
      'gain': 'плюс',
      'other': 'минус',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins победы',
      many: '$wins побед',
      few: '$wins победы',
      one: '$wins победа',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses поражения',
      many: '$losses поражений',
      few: '$losses поражения',
      one: '$losses поражение',
    );
    return 'Сегодня $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins победы',
      many: '$wins побед',
      few: '$wins победы',
      one: '$wins победа',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses поражения',
      many: '$losses поражений',
      few: '$losses поражения',
      one: '$losses поражение',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws ничьи',
      many: ', $draws ничьих',
      few: ', $draws ничьи',
      one: ', $draws ничья',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown матча с неизвестным результатом',
      many: ', $unknown матчей с неизвестным результатом',
      few: ', $unknown матча с неизвестным результатом',
      one: ', $unknown матч с неизвестным результатом',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Откройте настройку главной, чтобы снова их показать.';

  @override
  String get homeAllHiddenTitle => 'Вы скрыли все карточки';

  @override
  String get homeCardBattlePass => 'Боевой пропуск';

  @override
  String get homeCardBattlePassDesc =>
      'Уровень, нужный XP в день и еженедельные задания.';

  @override
  String get homeCardCommunity => 'Сообщество';

  @override
  String get homeCardCommunityDesc =>
      'Поиск напарников вашего ранга и самые любимые скины сообщества.';

  @override
  String get homeCardFriends => 'Друзья в игре';

  @override
  String get homeCardFriendsDesc =>
      'Друзья, которые сейчас в матче или в очереди.';

  @override
  String homeCardHidden(String name) {
    return 'Скрыто: \"$name\"';
  }

  @override
  String get homeCardLive => 'Текущий матч';

  @override
  String get homeCardLiveDesc =>
      'Отображается, когда вы в очереди, на выборе агента или в матче.';

  @override
  String get homeCardOtherAccounts => 'Другие аккаунты';

  @override
  String get homeCardOtherAccountsDesc =>
      'Статус и список желаемого других ваших аккаунтов.';

  @override
  String get homeCardRank => 'Ранг и форма';

  @override
  String get homeCardRankDesc =>
      'Ранг, RR за сегодня, серии и число матчей до повышения.';

  @override
  String get homeCardServerStatus => 'Состояние серверов';

  @override
  String get homeCardServerStatusDesc =>
      'Отображается только во время технических работ или неполадок.';

  @override
  String get homeCardStore => 'Магазин сегодня';

  @override
  String get homeCardStoreDesc =>
      'Ежедневные скины, список желаемого и Ночной рынок.';

  @override
  String get homeCustomize => 'Настроить главную';

  @override
  String get homeCustomizeHint =>
      'Перетаскивайте, чтобы менять порядок. Выключите, чтобы скрыть карточку.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Переход к разделу: $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Включить';

  @override
  String get homeFriendsConsentBody =>
      'Чтобы видеть, кто из друзей играет, ValHub подключается к чату Riot текущего аккаунта при каждом открытии главной. Друзья будут видеть вас в сети. Отключить это можно в настройке главной.';

  @override
  String get homeFriendsConsentDecline => 'Нет, скрыть';

  @override
  String get homeFriendsConsentTitle => 'Показывать, кто из друзей играет?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n друга в игре',
      many: '$n друзей в игре',
      few: '$n друга в игре',
      one: '$n друг в игре',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Все';

  @override
  String get homeHideCard => 'Скрыть карточку';

  @override
  String homeLeaderboard(String pos) {
    return 'Место $pos в таблице лидеров';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Осталось: $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Нужно $n игрока',
      many: 'Нужно $n игроков',
      few: 'Нужно $n игрока',
      one: 'Нужен $n игрок',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Напарники вашего ранга';

  @override
  String get homeLiveAllyLabel => 'Ваша команда';

  @override
  String get homeLiveEnemyLabel => 'Противники';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'В очереди, ожидание: $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Ваша команда $ally, противники $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Серия из $n поражения в рейтинговой игре',
      many: 'Серия из $n поражений в рейтинговой игре',
      few: 'Серия из $n поражений в рейтинговой игре',
      one: 'Серия из $n поражения в рейтинговой игре',
    );
    return '$_temp0';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n матча до ранга $rank',
      many: '≈ $n матчей до ранга $rank',
      few: '≈ $n матча до ранга $rank',
      one: '≈ $n матч до ранга $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Действия: $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Войдите снова, чтобы обновить магазин, ранг и боевой пропуск аккаунта $riotId. Сохраненную на устройстве версию можно смотреть и сейчас.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Осталось: $time';
  }

  @override
  String get homeNightMarketNew => 'Новое';

  @override
  String get homeNightMarketTitle => 'Ночной рынок';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n предложения ждут, когда вы их откроете',
      many: '$n предложений ждут, когда вы их откроете',
      few: '$n предложения ждут, когда вы их откроете',
      one: '$n предложение ждет, когда вы его откроете',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Сегодня рейтинговых матчей не было';

  @override
  String get homeOpenLfg => 'Все объявления о поиске напарников';

  @override
  String get homeOpenRanking => 'Рейтинг скинов';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Другие аккаунты ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n аккаунта',
      many: '+$n аккаунтов',
      few: '+$n аккаунта',
      one: '+$n аккаунт',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Есть скин из списка желаемого';

  @override
  String homePreviousAct(String rank) {
    return 'Прошлый акт: $rank';
  }

  @override
  String get homeQuietBody => 'Потяните вниз, чтобы обновить.';

  @override
  String get homeQuietTitle => 'Пока ничего нового';

  @override
  String homeRankToNext(int rr) {
    return 'До повышения: $rr RR';
  }

  @override
  String get homeResetLayout => 'Восстановить по умолчанию';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Сегодня $value';
  }

  @override
  String get homeStatusDetails => 'Подробнее';

  @override
  String homeStatusIncident(String region) {
    return 'Неполадки на сервере · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Технические работы · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Скоро технические работы · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n уведомления',
      many: '+$n уведомлений',
      few: '+$n уведомления',
      one: '+$n уведомление',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Обновление…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Обновление через $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Всего $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Кошелек $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n скина',
      many: '$n скинов',
      few: '$n скина',
      one: '$n скин',
    );
    return 'Кошелек $vp · хватит максимум на $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Скин из списка желаемого в магазине!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n скина из списка желаемого в продаже',
      many: '$n скинов из списка желаемого в продаже',
      few: '$n скина из списка желаемого в продаже',
      one: '$n скин из списка желаемого в продаже',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeTrendingTitle => 'Самые любимые скины в мире';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n лайка',
      many: '$n лайков',
      few: '$n лайка',
      one: '$n лайк',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Отменить';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Серия из $n победы в рейтинговой игре',
      many: 'Серия из $n побед в рейтинговой игре',
      few: 'Серия из $n побед в рейтинговой игре',
      one: 'Серия из $n победы в рейтинговой игре',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'Магазин обновился. ValHub пока не смог загрузить новый.';

  @override
  String get homeOfflineTitle => 'Нет сети';

  @override
  String get homeOfflineBody =>
      'Показаны данные, сохраненные на устройстве. ValHub обновит их, когда сеть появится.';

  @override
  String get homeCardOffline => 'Появится, когда будет сеть.';

  @override
  String get communityErrorConsent =>
      'Чтобы продолжить, разрешите показывать ваш Riot ID в сообществе.';

  @override
  String get communityErrorForbidden =>
      'Вы пока не можете это сделать. Ознакомьтесь с правилами сообщества или свяжитесь с ValHub.';

  @override
  String get communityErrorGeneric => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get communityErrorImageTooLarge =>
      'Изображение слишком большое (максимум 2 МБ). Выберите другое.';

  @override
  String get communityErrorImageType =>
      'Выберите изображение JPEG, PNG или WebP.';

  @override
  String get communityErrorInvalid =>
      'Контент не принят. Проверьте его и повторите попытку.';

  @override
  String get communityErrorNetwork =>
      'Не удалось подключиться к сообществу ValHub. Проверьте подключение и повторите попытку.';

  @override
  String get communityErrorNotFound => 'Этот контент больше не существует.';

  @override
  String get communityErrorPickImage =>
      'Не удалось открыть галерею. Повторите попытку.';

  @override
  String get communityErrorRateLimited =>
      'Сообщество получает слишком много запросов. Повторите попытку через несколько минут.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Сообщество получает слишком много запросов. Повторите попытку через $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot не смог подтвердить ваш аккаунт. Войдите в аккаунт Riot снова и повторите попытку.';

  @override
  String get communityErrorRiotUnavailable =>
      'У Riot возникли неполадки. Повторите попытку через несколько минут.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'У Riot возникли неполадки. Повторите попытку через $duration.';
  }

  @override
  String get communityErrorServer =>
      'В сообществе ValHub возникли неполадки. Повторите попытку через несколько минут.';

  @override
  String get communityErrorStorageFull =>
      'Хранилище фото сообщества заполнено. Публиковать посты можно, но прикреплять фото пока нельзя. Повторите попытку позже.';

  @override
  String get communityErrorTimeout =>
      'Сообщество ValHub слишком долго не отвечает. Повторите попытку.';

  @override
  String get communityErrorTitle => 'Не удалось завершить';

  @override
  String get communityErrorUnauthorized =>
      'Подключение к сообществу истекло. Повторите попытку.';

  @override
  String get communityErrorImageQuota =>
      'Место для изображений закончилось. Удалите несколько публикаций с изображениями и попробуйте снова.';

  @override
  String get smokePlain => 'Проверка генерации кода';

  @override
  String smokeGreeting(String name) {
    return 'Привет, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n элемента',
      many: '$n элементов',
      few: '$n элемента',
      one: '$n элемент',
    );
    return '$_temp0';
  }
}
